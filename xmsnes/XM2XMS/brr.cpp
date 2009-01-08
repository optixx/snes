//------------------------------------------------------------------------------------------------------------------------
// Copyright (c) 2007, Mukunda Johnson
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
// 
//     * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//     * Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//-----------------------------------------------------------------------------------

// SPECIAL THANKS TO DMV47 AND MADBRAIN!!

#define looploss_tolerance 30000	// tweak? :O

#include "mglobal.h"
#include "simpmath.h"
#include <math.h>
#include <stdio.h>

#define SAMPHEAD_END	1
#define SAMPHEAD_LOOP	2
#define SAMPHEAD_FILTER 12
#define SAMPHEAD_RANGE	240

int BRR_AutoFilter( XMS_SAMPLE* samp, byte* fb, int file_offset, XMS_HEAD* head, int index, int ffixed, cstatus* stat, double amp );
void BRR_CompressBlock( int* source, int* dest, cresult* presult, int ffixed );
int ComputeFilter( int x_2, int x_1, int filter );
int  ClampNibble( int n );
int  ClampWord( int n );


inline static unsigned char test_overflow( const int* ls );

int BRR_AutoFilter( XMS_SAMPLE* samp, byte* fb, int file_offset, XMS_HEAD* head, int index, int ffixed, cstatus* stat, double amp )
{
	int a;					// general variables
	int b;					//
	int w;					// write position
	
	int w_loop;				// loop start
	int loop_v1;			// loop start values
	bool use_filter0=false;
	bool redo_loopf=true;
	
	bool got_loop = false;
	
	int		sbuffer[18];	// uncompressed data, includes 2 previous entries
	int		cbuffer[16];	// compressed data
	cresult	cres;			// compression results
	
	sbuffer[0] = 0;		// reset previous data
	sbuffer[1] = 0;		//
	
	stat->fc[0] = 0;	// reset status
	stat->fc[1] = 0;	//
	stat->fc[2] = 0;	//
	stat->fc[3] = 0;	//
	stat->overloss = 0;	//
	
	// Loop through sample data 16 bytes at a time
	a = 0;
	w = 0;
	
	while( redo_loopf )
	{
		redo_loopf = false;
		
		for( ; a < samp->length; a += 16 )
		{
			// Load buffer with 16 samples
			for( b = 0; b < 16; b++ )
			{
				if( (a + b) >= samp->length && (a + b) >= 0 )
					sbuffer[ b+2 ] = 0;
				else
					sbuffer[ b+2 ] = ClampWord((int)roundf( (double)samp->samp_data[ a+b ] * amp ));
			}
			
			// Compress block, use filter0 on first sample
			
			if( a != 0 && !use_filter0 )
				BRR_CompressBlock( sbuffer + 2, cbuffer, &cres, ffixed );
			else
				BRR_CompressBlock( sbuffer + 2, cbuffer, &cres, 0  );
			
			use_filter0 = false;
			
			// Save loop start(write-pos) and data
			if( a == samp->loop_start )
			{
				w_loop = w;
				loop_v1 = cres.samp[0];
			}
			
			if( cres.overflow )
			{
				return 1;
			}
			
			// increment counter for filter selected
			stat->fc[cres.filter]++;
			
			// add to sample loss
			stat->overloss += cres.samp_loss;
			
			// set previous data for next loop
			sbuffer[1] = cres.samp[15];
			sbuffer[0] = cres.samp[14];
			
			// write header
			fb[w] = (cres.range << 4) + (cres.filter << 2);
			for( b = 0; b < 8; b++ )
				fb[ w+1+b ] = cbuffer[ b*2 ] *16 + cbuffer[ b*2 +1 ];	// write data (big endian)
			
			// check for loop
			if( samp->loop_type != 0 )
			{
				// set loop flag
				fb[w] |= SAMPHEAD_LOOP;
				// check if read counter is past loop_start
				if( !got_loop && a >= samp->loop_start && a < (samp->loop_start + samp->loop_length) )
				{
					// set loop offset
					if( head != NULL )
						head->samp_loop[index] = file_offset + w;
					got_loop = true;
				}
			}
			// increment write position
			w += 9;
		}
		
		// set sample end flag
		w -= 9;
		fb[w] = fb[w] | SAMPHEAD_END;
		if( samp->loop_type == 1 )
			fb[w] = fb[w] | SAMPHEAD_LOOP;
		
		// calculate percentages
		double st;
		st = (double)( stat->fc[0] + stat->fc[1] + stat->fc[2] + stat->fc[3] );
		stat->fp[0] = roundf( (((double)stat->fc[0]) / st) *100 );
		stat->fp[1] = roundf( (((double)stat->fc[1]) / st) *100 );
		stat->fp[2] = roundf( (((double)stat->fc[2]) / st) *100 );
		stat->fp[3] = roundf( (((double)stat->fc[3]) / st) *100 );
		stat->overlp = ((double)stat->overloss) / st;
		
		// check loop loss...
		if( samp->loop_type == 1 )
		{
			int lc_range;
			int lc_filter;
			int lc_value;
			lc_filter = (fb[w_loop] & SAMPHEAD_FILTER) >> 2;
			if( lc_filter == 0 )	// check filter setting
			{
				return 0;					// skip if zero (no loss)
			}
			else
			{
				lc_range = (fb[w_loop] & SAMPHEAD_RANGE) >> 4;
				lc_value = fb[w_loop+1] >> 4;
				lc_value <<= lc_range;
				lc_value += ComputeFilter( sbuffer[15], sbuffer[14], lc_filter );
				if( abs( lc_value - loop_v1 ) > looploss_tolerance )
				{
					// redo compression...
					a = samp->loop_start;
					w = w_loop;
					redo_loopf = true;
					use_filter0 = true;
				}
			}
		}
		
	}
	return 0;
}

void BRR_CompressBlock( int* source, int* dest, cresult* presult, int ffixed )
{
	// source   = source buffer
	// dest     = return buffer (compressed data)
	// presults = result return
	// ffixed   = filter selection
	int		r_shift;
	int		r_half;
	int		c;
	int		s1;
	int		s2;
	int		rs1;
	int		rs2;
	int		ra;
	int		rb;
	int		cp;
	int		c_1;
	int		c_2;
	int		x;
	int		block_data[16];
	int		block_error;
	int		block_errorb=2147483647; // max
	int		block_datab[16];
	int		block_samp[16];
	int		block_sampb[18];
	int		block_rangeb;
	int		block_filterb;
	int		filter;
	int		fmin;
	int		fmax;
	// set filter ranges
	if( ffixed == 4 )
	{
		fmin = 0;
		fmax = 3;
	}
	else
	{
		fmin = ffixed;
		fmax = ffixed;
	}
	// loop through filters
	for( filter = fmin; filter <= fmax; filter++ )
	{
		// loop through ranges
		for( r_shift = 12; r_shift >= 0; r_shift-- )
		{
			r_half		=(1 << r_shift) >> 1;	// half shift value (for rounding)
			c_1			=source[-1];			// previous samp 1
			c_2			=source[-2];			// previous samp 2
			block_error =0;						// reset error
			// loop through samples
			for( x = 0; x < 16; x++ )
			{
				// calculate filter values
				cp = ComputeFilter( c_2, c_1, filter );
				c = source[x] >> 1;						// load sample, /2
				s1 = (signed short int)(c & 0x7FFF);	// uhh? :)
				s2 = (signed short int)(c | 0x8000);	// 
				s1 -= cp;								// undo filter
				s2 -= cp;								//
				
				s1 <<= 1;								// restore lost bit
				s2 <<= 1;								//
				
				s1 += r_half;							// shift and round
				s2 += r_half;							//
				s1 >>= r_shift;							//
				s2 >>= r_shift;							//

				s1 = ClampNibble( s1 );					// clamp
				s2 = ClampNibble( s2 );					//
				rs1 = s1;								// save data
				rs2 = s2;								//
				
				s1 = (s1 << r_shift) >> 1;				// undo shift
				s2 = (s2 << r_shift) >> 1;				//
				
				if( filter >= 2 )						// apply filter
				{										//
					s1 = ClampWord( s1 + cp );			//
					s2 = ClampWord( s2 + cp );			//
				}										//
				else									//
				{										//
					s1 = s1 + cp;						//
					s2 = s2 + cp;						//
				}										//
				
				s1 = ((signed short int)( s1 << 1 )) >> 1;	// sign extend
				s2 = ((signed short int)( s2 << 1 )) >> 1;	//
				
				ra = (c) - s1;							// check difference
				rb = (c) - s2;							//
				
				if( ra < 0 ) ra = -ra;					// absolute value
				if( rb < 0 ) rb = -rb;					//
				
				if( ra < rb )							// pick lesser error value
				{										//
					block_error += (int)ra;				// add error value
					block_data[x] = rs1;				// set data
				}										//
				else									//
				{										//
					block_error += (int)rb;				// add error value
					block_data[x] = rs2;				// set data
					s1 = s2;							//
				}										//

				if( block_data[x] < 0 )					// unsign nibble
					block_data[x] += 16;
				c_2 = c_1;								// set previous samples
				c_1 = s1;								//
				
				block_samp[x] = s1;						// save sample
			}
			// check if error rate is lower than current
			if( block_error < block_errorb )
			{
				// copy all data to "best" buffer
				block_errorb = block_error;
				block_rangeb = r_shift;
				block_filterb = filter;
				for( x = 0; x < 16; x++ )
					block_datab[x] = block_data[x];
				for( x = 0; x < 16; x++ )
					block_sampb[x+2] = block_samp[x];
			}
		}
	}
	
	unsigned int overflow=0;
	
	block_sampb[0] = block_sampb[14+2];
	block_sampb[1] = block_sampb[15+2];
	for( x = 0; x < 16; x++ )
	{
		overflow = (overflow << 1) | test_overflow( block_sampb + x );
	}
	
	// copy best buffer to output
	for( x = 0; x < 16; x++ )
		dest[x] = block_datab[x];
	
	// copy affected sample data
	for( x = 0; x < 16; x++ )
		presult->samp[x] = block_sampb[x+2];
	
	// return results
	presult->range = block_rangeb;
	presult->filter = block_filterb;
	presult->samp_loss = block_errorb;
	
	if( overflow )
		presult->overflow = true;
	else
		presult->overflow = false;
}

int ComputeFilter( int x_2, int x_1, int filter )
{
	int cp;
	switch( filter )
	{
	case 0:											// 0, 0
		cp = 0;										// add 0
		break;
	case 1:											// 15/16
		cp  = x_1;									// add 16/16
		cp += -x_1 >> 4;							// add -1/16
		break;
	case 2:											// 61/32, -15/16
		cp  = x_1<<1;								// add 64/32
		cp += -(x_1 + (x_1 << 1)) >> 5;				// add -3/32
		cp += -x_2;									// add -16/16
		cp += x_2 >> 4;								// add 1/16
		break;
	case 3:											// 115/64, -13/16
		cp  = x_1 << 1;								// add 128/64
		cp += -(x_1 + (x_1 << 2) + (x_1 << 3)) >> 6;// add -13/64
		cp += -x_2;									// add -16/16
		cp += (x_2 + (x_2 << 1)) >> 4;				// add 3/16
	}
	return cp;
}

int ClampNibble( int n )
{
	if( n < -8 ) n = -8;
	if( n >  7 ) n =  7;
	return n;
}

int ClampWord( int n )
{
	if( n < -32768 ) n = -32768;
	if( n >  32767 ) n =  32767;
	return n;
}

template <int G4, int G3, int G2>
inline static unsigned char test_gauss( const int* ls )
{
	int s;
	s =  int( G4 * ls[0] ) >> 11;
	s += int( G3 * ls[1] ) >> 11;
	s += int( G2 * ls[2] ) >> 11;
	return( s > 0x3FFF ) || ( s < -0x4000 );
}

inline static unsigned char test_overflow( const int* ls )
{
	unsigned char r;
	
	// p = -256; gauss_table[255, 511, 256]
	r =  test_gauss<370, 1305, 374>( ls );
	
	// p = -255; gauss_table[254, 510, 257]
	r |= test_gauss<366, 1305, 378>( ls );
	
	// p = -247; gauss_table[246, 502, 265]
	r |= test_gauss<336, 1303, 410>( ls );
	
	return r;
}
