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

#define SAFE_DELETE( var ) if( var != NULL ) delete[] var; var=NULL

#define BIT0 1
#define BIT1 2
#define BIT2 4
#define BIT3 8
#define BIT4 16
#define BIT5 32
#define BIT6 64
#define BIT7 128

typedef unsigned char byte;
typedef unsigned short int word;
typedef unsigned int dword;
#include "files.h"

#include <stdio.h>
#include <cstring>

#include "types.h"
#include "mglobal.h"

int pr_channels;

#define pe_match_note  1
#define pe_match_inst  2
#define pe_match_vfx   4
#define pe_match_fx    8
#define pe_match_param 16
#define pe_match_all  (1|2|4|8|16)

#define cbit_n 1
#define cbit_I 2
#define cbit_i 4
#define cbit_v 8
#define cbit_E 16
#define cbit_e 32
#define cbit_r 64
#define cbit_c 128

typedef struct tpr_cstruct
{
	int note;
	int inst;
	int vfx;
	int fx;
	int param;
} pr_cstruct;

pr_cstruct pr_cdata[8];

int pr_last_SAMPOFF[8];
int pr_last_EXTRA[8];

int pr_last_VOLUME[80];

byte* pr_buffer=NULL;
int pr_buffersize;

int pr_read;
int pr_write;

int pr_extra_bytes;

int pr_warnings;

bool pr_hasjump;

pr_cstruct pr_rbuffer[8];

extern XMS_PATTERN* xpatterns;
extern XMS_HEAD xhead;
extern XMS_INSTRUMENT* xinst;
extern XMS_SAMPLE xsamp[];

void PR_ResizeBuffer( int amount );
int PR_Operation( byte** out_data, int chan, int index, int row );
bool PR_CheckNote( int note, int inst, int row, int chan );
int PR_GetAdjacentPatterns( int pat_index, int** b_return );
void PR_ResizeBufferExI( int old_size, int amount, int** buffer );
void PR_ResizeBufferExB( int old_size, int amount, byte** buffer );
bool PR_RampCheck( int note, int inst );
int PR_ScanOffset( XMS_PATTERN* pat, int row );

int pe_matches( pr_cstruct *dest, pr_cstruct *src );
int pe_entities( pr_cstruct *src );
int pe_insert_repeat( int w );

void FixPattern( int index )
{
	pr_warnings = 5;
	int row;
	int chan;
	
	pr_read = 0;
	int x;
	
	pr_read = 0;
	pr_write = 0;
	pr_extra_bytes = 0;
	
	int h;
	byte b;
	
	byte* odata=NULL;
	int osize;
	
	byte pbits;
	int pkwrite;
	
	SAFE_DELETE( pr_buffer );
	pr_buffersize = 0;
	
	for( row = 0; row < xpatterns[index].nrows; row++ )
	{
		pbits = 0;

		PR_ResizeBuffer( 1 );
		pkwrite = pr_write;
		pr_write++;
		// LOAD PATTERN ROW INTO MEMORY
		for( chan = 0; chan < pr_channels; chan++ )
		{
			h = xpatterns[index].data[pr_read]; pr_read++;
			if( h & 0x80 )
			{
				if( h & 1 )
				{
					b = xpatterns[index].data[pr_read]; pr_read++;
					pr_rbuffer[chan].note = b;
				}
				else
				{
					pr_rbuffer[chan].note = 0;
				}
				if( h & 2 )
				{
					b = xpatterns[index].data[pr_read]; pr_read++;
					pr_rbuffer[chan].inst = b;
				}
				else
				{
					pr_rbuffer[chan].inst = 0;
				}
				if( h & 4 )
				{
					b = xpatterns[index].data[pr_read]; pr_read++;
					pr_rbuffer[chan].vfx = b;
				}
				else
				{
					pr_rbuffer[chan].vfx = 0;
				}
				if( h & 8 )
				{
					b = xpatterns[index].data[pr_read]; pr_read++;
					pr_rbuffer[chan].fx = b;
				}
				else
				{
					pr_rbuffer[chan].fx = 0;
				}
				if( h & 16 )
				{
					b = xpatterns[index].data[pr_read]; pr_read++;
					pr_rbuffer[chan].param = b;
				}
				else
				{
					pr_rbuffer[chan].param = 0;
				}
			}
			else
			{
				pr_rbuffer[chan].note = h;
				h = 159;
				b = xpatterns[index].data[pr_read]; pr_read++;
				pr_rbuffer[chan].inst = b;
				b = xpatterns[index].data[pr_read]; pr_read++;
				pr_rbuffer[chan].vfx = b;
				b = xpatterns[index].data[pr_read]; pr_read++;
				pr_rbuffer[chan].fx = b;
				b = xpatterns[index].data[pr_read]; pr_read++;
				pr_rbuffer[chan].param = b;
			}
		}
		for( chan = 0; chan < pr_channels; chan++ )
		{
			osize = PR_Operation( &odata, chan, index, row );
			if( pr_rbuffer[chan].note > 0 && pr_rbuffer[chan].note < 97 )
			{
				pbits |= 1 << chan;
				if( (pr_rbuffer[chan].vfx & 0xF) == 0xF )
					pbits &= (255 - (1 << chan));
				else if( pr_rbuffer[chan].fx == 3 )
					pbits &= (255 - (1 << chan));
				else if( pr_rbuffer[chan].fx == 0xE && ((pr_rbuffer[chan].param & 0xF0) == 0xD0) )
					pbits &= (255 - (1 << chan));
				else if( !PR_RampCheck( pr_rbuffer[chan].note, pr_rbuffer[chan].inst ) )
					pbits &= (255 - (1 << chan));
			}
			PR_ResizeBuffer( osize );
			for( x = 0; x < osize; x++ )
			{
				pr_buffer[pr_write] = odata[x];
				pr_write++;
			}
		}
		pr_buffer[pkwrite] = pbits;
	}
	
	SAFE_DELETE( xpatterns[index].data );
	xpatterns[index].data = new byte[pr_buffersize];
	memcpy( xpatterns[index].data, pr_buffer, pr_buffersize );
	SAFE_DELETE( pr_buffer );
	xpatterns[index].data_size = pr_buffersize;
}

void FixPattern2( int index )
{
	int row;
	int chan;
	int r = 0;
	int w = 0;
	int w_c = 0;
	int lu_w = -1;
	int lu_c = 0;
	int matches;
	int entities;
	int x, y;
	int h;
	bool lu_b = false;
	bool reg_store;

	xpatterns[index].old_size = xpatterns[index].data_size;
	
	int last_head[8] = {-1,-1,-1,-1,-1,-1,-1,-1};
	
	pr_buffersize = 0;
	
	byte prefix;
	byte c_byte;
	for( row = 0; row < 8; row++ )
	{
		pr_cdata[row].fx = -1;
		pr_cdata[row].inst = -1;
		pr_cdata[row].note = -1;
		pr_cdata[row].param = -1;
		pr_cdata[row].vfx = -1;
		pr_rbuffer[row].fx = 0;
		pr_rbuffer[row].inst = 0;
		pr_rbuffer[row].note = 0;
		pr_rbuffer[row].param = 0;
		pr_rbuffer[row].vfx = 0;
	}
	for( row = 0; row < xpatterns[index].nrows; row++ )
	{

		prefix = xpatterns[index].data[r];
		r++;
		PR_ResizeBuffer( 1 );
		pr_buffer[w] = prefix;
		w++;
		for( chan = 0; chan < pr_channels; chan++ )
		{
			h = xpatterns[index].data[r];
			r++;
			if( h & 128 )
			{
				if( h & 1 )
				{
					pr_rbuffer[chan].note = xpatterns[index].data[r];
					r++;
				}
				else if( h & 32 )
				{
					pr_rbuffer[chan].note = 97;
				}
				else
				{
					pr_rbuffer[chan].note = 0;
				}
				if( h & 2 )
				{
					pr_rbuffer[chan].inst = xpatterns[index].data[r];
					r++;
				}
				else
				{
					pr_rbuffer[chan].inst = 0;
				}
				if( h & 4 )
				{
					pr_rbuffer[chan].vfx = xpatterns[index].data[r];
					r++;
				}
				else
				{
					pr_rbuffer[chan].vfx = 0;
				}
				if( h & 8 )
				{
					pr_rbuffer[chan].fx = xpatterns[index].data[r];
					r++;
				}
				else
				{
					pr_rbuffer[chan].fx = 0;
				}
				if( h & 16 )
				{
					pr_rbuffer[chan].param = xpatterns[index].data[r];
					r++;
				}
				else
				{
					pr_rbuffer[chan].param = 0;
				}
			}
			else
			{
				pr_rbuffer[chan].note = h;
				pr_rbuffer[chan].inst = xpatterns[index].data[r]; r++;
				pr_rbuffer[chan].vfx = xpatterns[index].data[r]; r++;
				pr_rbuffer[chan].fx = xpatterns[index].data[r]; r++;
				pr_rbuffer[chan].param = xpatterns[index].data[r]; r++;
			}
			
			matches = pe_matches( &pr_rbuffer[chan], &pr_cdata[chan] );
			entities = pe_entities( &pr_rbuffer[chan] );
			reg_store = true;
			
			if( xpatterns[index].row_marks[row] )
			{
				matches = 0;
			}
			
			if( ((matches & (pe_match_inst | pe_match_fx | pe_match_param)) == 0) && ( entities == pe_match_all ) )
			{
				// store all data
				PR_ResizeBuffer( 5 );
				pr_buffer[w+0] = pr_rbuffer[chan].note  ;
				pr_buffer[w+1] = pr_rbuffer[chan].inst  ;
				pr_buffer[w+2] = pr_rbuffer[chan].vfx   ;
				pr_buffer[w+3] = pr_rbuffer[chan].fx    ;
				pr_buffer[w+4] = pr_rbuffer[chan].param ;
				w += 5;
				last_head[chan] = -1;
			}
			else
			{
				
				if( entities == 0 && (!xpatterns[index].row_marks[row]) )
				{
					
					if( last_head[chan] != -1 )
					{
						
						// repeat empty
						x=pe_insert_repeat(last_head[chan]);
						if( !(pr_buffer[last_head[chan]] & cbit_r) )
						{
							
							// new byte
							w++; // increase write pointer (byte inserted)
							for( y = 0; y < 8; y++ )
							{
								if( last_head[y] >= x ) last_head[y]++;
							}
							pr_buffer[last_head[chan]] |= cbit_r;
							pr_buffer[x] = 129;
							reg_store=false;
							
						}
						else
						{
							
							// old byte (can be unusable)
							if( pr_buffer[x] & BIT7 )
							{
								// repeat ok
								if( pr_buffer[x] != 255 )
								{
									pr_buffer[x]++;
									reg_store=false;
								}
								else
								{
									// do regular store (buffer full )
								}
							}
							else
							{
								// do regular store (non-empty repeat)
							}
							
						}
						
					}
					
				}
				else if( ((matches & (4|8|16)) == (4|8|16)) && ((entities & (1|2))==0) && (!xpatterns[index].row_marks[row]) )
				{
					if( last_head[chan] != -1 )
					{
						// repeat byte
						x=pe_insert_repeat(last_head[chan]);
						if( !(pr_buffer[last_head[chan]] & cbit_r) )
						{
							// new byte
							w++; // increase write pointer (byte inserted)
							for( y = 0; y < 8; y++ )
								if( last_head[y] >= x ) last_head[y]++;
							pr_buffer[last_head[chan]] |= cbit_r;
							pr_buffer[x] = 1;
							
							reg_store=false;
						}
						else
						{
							// old byte (can be unusable)
							if( pr_buffer[x] & BIT7 )
							{
								// empty repeat only (store regular)
							}
							else
							{
								if( pr_buffer[x] != 127 )
								{
									pr_buffer[x]++;
									reg_store=false;
								}
								else
								{
									// do regular store (buffer full)
								}
								// repeat ok
							}
						}
					}
				}
				
				if( reg_store )
				{
					PR_ResizeBuffer( 1 );
					lu_w = w;
					w++;
					c_byte = 0;

					if( entities & pe_match_note )
					{
						if( (matches & pe_match_note) && (entities & pe_match_inst) )
						{
							if( matches & pe_match_inst )
							{
								c_byte |= cbit_I | cbit_i;					// 110
							}
							else
							{
								c_byte |= cbit_n | cbit_I | cbit_i;			// 111
								PR_ResizeBuffer( 1 );
								pr_buffer[w] = pr_rbuffer[chan].inst; w++;
							}
						}
						else
						{
							c_byte |= cbit_n;
							PR_ResizeBuffer( 1 );
							pr_buffer[w] = pr_rbuffer[chan].note; w++;
							if( entities & pe_match_inst )
							{
								if( matches & pe_match_inst )
								{
									c_byte |= cbit_I;						// 011
								}
								else
								{
									c_byte |= cbit_i;						// 101
									PR_ResizeBuffer( 1 );
									pr_buffer[w] = pr_rbuffer[chan].inst; w++;
								}
								
							}
							else
							{
																			// 001
							}
						}
					}
					else
					{
						if( entities & pe_match_inst )
						{
							if( matches & pe_match_inst )
							{
								c_byte |= cbit_I;							// 010
							}
							else
							{
								c_byte |= cbit_i;							// 100
								PR_ResizeBuffer( 1 );
								pr_buffer[w] = pr_rbuffer[chan].inst; w++;
							}
							
						}
						else
						{
																			// 000
						}
					}

					if( entities & pe_match_vfx )
					{
						c_byte |= cbit_v;
						PR_ResizeBuffer( 1 );
						pr_buffer[w] = pr_rbuffer[chan].vfx; w++;
					}
					if( entities & pe_match_fx )
					{
						if( (matches & (pe_match_fx|pe_match_param)) == (pe_match_fx|pe_match_param) )
						{
							// param&fx repeat
							c_byte |= cbit_E;
						}
						else if( matches & (pe_match_fx) )
						{
							// fx repeat
							c_byte |= cbit_E|cbit_e;
							PR_ResizeBuffer( 1 );
							pr_buffer[w] = pr_rbuffer[chan].param; w++;
						}
						else
						{
							c_byte |= cbit_e;
							PR_ResizeBuffer( 2 );
							pr_buffer[w] = pr_rbuffer[chan].fx; w++;
							pr_buffer[w] = pr_rbuffer[chan].param; w++;
						}
					}
					c_byte |= cbit_c;
					pr_buffer[lu_w] = c_byte;
					last_head[chan] = lu_w;
				}
			}
			
			pr_cdata[chan].note  = pr_rbuffer[chan].note;
			pr_cdata[chan].inst  = pr_rbuffer[chan].inst;
			pr_cdata[chan].vfx   = pr_rbuffer[chan].vfx;
			pr_cdata[chan].fx    = pr_rbuffer[chan].fx;
			pr_cdata[chan].param = pr_rbuffer[chan].param;
		
			if( pr_rbuffer[chan].fx == 0x0D )
			{
				if( pr_rbuffer[chan].param != 0 )
				{
					if( xpatterns[index].data[r] == 0 )
					{
						PR_ResizeBuffer( 3 );
						pr_buffer[w+0] = xpatterns[index].data[r+0];
						pr_buffer[w+1] = xpatterns[index].data[r+1];
						pr_buffer[w+2] = xpatterns[index].data[r+2];
						r += 3;
						w += 3;
					}
					else
					{
						PR_ResizeBuffer( 1 );
						pr_buffer[w] = xpatterns[index].data[r];
						y = pr_buffer[w]/3;
						w++; r++;
						for( x = 0; x < y; x++ )
						{
							PR_ResizeBuffer( 3 );
							pr_buffer[w+0] = xpatterns[index].data[r+0];
							pr_buffer[w+1] = xpatterns[index].data[r+1];
							pr_buffer[w+2] = xpatterns[index].data[r+2];
							r += 3;
							w += 3;
						}
					}
				}
			}
			
		}
	}
	SAFE_DELETE( xpatterns[index].data );
	xpatterns[index].data = new byte[pr_buffersize];
	memcpy( xpatterns[index].data, pr_buffer, pr_buffersize );
	xpatterns[index].data_size = pr_buffersize;
	SAFE_DELETE( pr_buffer );
	File_Open( "temp.a", FILE_MODE_WRITE, 3 );
	File_WriteData( xpatterns[index].data, pr_buffersize, 3 );
	File_Close( 3 );
}

int pe_insert_repeat( int w ) // returns address of repeat byte
{
	int offset = w+1;
	switch( pr_buffer[w] & (cbit_n|cbit_I|cbit_i) )
	{
	case 0:     //000:
	case 2:     //010:
	case 2|4:   //110:
		break;
	case 1:     //001:
	case 1|2:   //011:
	case 4:     //100:
	case 1|2|4: //111:
		offset += 1;
		break;
	case 1|4:   //101:
		offset += 2;
	}
	if( pr_buffer[w] & cbit_v )
		offset++;
	switch( pr_buffer[w] & (cbit_e|cbit_E) )
	{
	case cbit_e:
		offset += 2;
		break;
	case cbit_e|cbit_E:
		offset++;
	}
	
	if( !(pr_buffer[w] & cbit_r) )
	{
		byte* new_buffer;
		new_buffer = new byte[pr_buffersize + 1];
		if( pr_buffersize != 0 )
		{
			memcpy( new_buffer, pr_buffer, offset );
			new_buffer[offset] = 0;
			memcpy( new_buffer+offset+1, pr_buffer+offset, pr_buffersize-offset );
			delete[] pr_buffer;
			pr_buffer = new_buffer;
		}
		pr_buffer = new_buffer;
		pr_buffersize += 1;
		return offset;
	}
	else
	{
		return offset;
	}
}

int pe_matches( pr_cstruct *dest, pr_cstruct *src )
{
	int ret=0;
	if( src->note  == dest->note  ) ret |= pe_match_note ;
	if( src->inst  == dest->inst  ) ret |= pe_match_inst ;
	if( src->vfx   == dest->vfx   ) ret |= pe_match_vfx  ;
	if( src->fx    == dest->fx    ) ret |= pe_match_fx   ;
	if( src->param == dest->param ) ret |= pe_match_param;
	return ret;
}

int pe_entities( pr_cstruct *src )
{
	int ret=0;
	if( src->note  ) ret |= pe_match_note ;
	if( src->inst  ) ret |= pe_match_inst ;
	if( src->vfx   ) ret |= pe_match_vfx  ;
	if( src->fx    ) ret |= pe_match_fx   ;
	if( src->param ) ret |= pe_match_param | pe_match_fx;
	return ret;
}

void FixPattern3( int index )
{
	// fix pattern break offsets (what a waste...)
	int row, chan;
	int r = 0;
	int h;
	int b,c,d;
	int rowskip[8];
	for( chan = 0; chan < 8; chan++ )
	{
		pr_cdata[chan].fx = 0;
		pr_cdata[chan].param = 0;
		pr_rbuffer[chan].fx=0;
		pr_rbuffer[chan].param=0;
		rowskip[chan] = -1;
	}
	for( row = 0; row < xpatterns[index].nrows; row++ )
	{
		r++; // skip prefix
		for( chan = 0; chan < pr_channels; chan++ )
		{
			if( rowskip[chan] == -1 )
			{
				h = xpatterns[index].data[r];
				if( h & cbit_c )
				{
					if( h & cbit_n )
						r++;
					if( h & cbit_i )
						r++;
					if( h & cbit_v )
						r++;
					switch( h & (cbit_E|cbit_e) )
					{
					case 0:
						pr_rbuffer[chan].fx=0;
						pr_rbuffer[chan].param=0;
						break;
					case cbit_E:
						pr_rbuffer[chan].fx = pr_cdata[chan].fx;
						pr_rbuffer[chan].param = pr_cdata[chan].param;
						break;
					case cbit_e:
						pr_rbuffer[chan].fx = xpatterns[index].data[r]; r++;
						pr_rbuffer[chan].param = xpatterns[index].data[r]; r++;
						break;
					case cbit_e|cbit_E:
						pr_rbuffer[chan].fx = pr_cdata[chan].fx;
						pr_rbuffer[chan].param = xpatterns[index].data[r]; r++;
					}
					if( h & cbit_r )
					{
						// repeat stuff..
						rowskip[chan] = xpatterns[index].data[r]; r++;
					}
				}
				else
				{
					pr_rbuffer[row].note = h;
					pr_rbuffer[row].inst = xpatterns[index].data[r]; r++;
					pr_rbuffer[row].vfx = xpatterns[index].data[r]; r++;
					pr_rbuffer[row].fx = xpatterns[index].data[r]; r++;
					pr_rbuffer[row].param = xpatterns[index].data[r]; r++;
				}
				pr_cdata[chan].fx = pr_rbuffer[chan].fx;
				pr_cdata[chan].param = pr_rbuffer[chan].param;
			}
			else
			{
				if( rowskip[chan] & BIT7 )
				{
					rowskip[chan]--;
					if( rowskip[chan] == 127 )
					{
						rowskip[chan] = -1;
					}
					pr_rbuffer[chan].note=0;
					pr_rbuffer[chan].inst=0;
					pr_rbuffer[chan].vfx=0;
					pr_rbuffer[chan].fx=0;
					pr_rbuffer[chan].param=0;
				}
				else
				{
					rowskip[chan]--;
				}

			}
			pr_cdata[chan].note  = pr_rbuffer[chan].note;
			pr_cdata[chan].inst  = pr_rbuffer[chan].inst;
			pr_cdata[chan].vfx   = pr_rbuffer[chan].vfx;
			pr_cdata[chan].fx    = pr_rbuffer[chan].fx;
			pr_cdata[chan].param = pr_rbuffer[chan].param;
			
			if( pr_cdata[chan].fx == 0xD )
			{
				c = pr_cdata[chan].param;
				if( c != 0 )
				{
					b = xpatterns[index].data[r];
					r++;
					if( b == 0 )
					{
						b = xpatterns[index].data[r];
						c = PR_ScanOffset( &xpatterns[b], row );
						xpatterns[index].data[r] = c & 255;
						xpatterns[index].data[r+1] = c >> 8;
						r += 2;
					}
					else
					{
						b = b / 3;
						while( b > 0 )
						{
							d = xpatterns[index].data[r];
							r++;
							c = PR_ScanOffset( &xpatterns[d], c );
							xpatterns[index].data[r] = c & 255;
							xpatterns[index].data[r+1] = c >> 8;
							r += 2;
							b--;
						}
					}
				}
			}
		}
	}
}

int PR_Operation( byte** out_data, int chan, int index, int row )
{
	byte* suffix = NULL;
	int suffix_size=0;
	int DxxA;
	int* DxxB = NULL;
	int DxxJ;

	int x;

	int bits=0;
	if( pr_rbuffer[chan].note != 0 )
	{
		if( pr_rbuffer[chan].note != 97 )
		{
			pr_cdata[chan].note = pr_rbuffer[chan].note;
			bits |= 1;
		}
		else
		{
			bits |= 32;
		}
	}
	if( pr_rbuffer[chan].inst != 0 )
	{
		pr_cdata[chan].inst = pr_rbuffer[chan].inst;
		bits |= 2;
	}
	if( pr_rbuffer[chan].vfx != 0 )
	{
		pr_cdata[chan].vfx = pr_rbuffer[chan].vfx;
		bits |= 4;
	}
	else
	{
		pr_cdata[chan].vfx = 0;
	}
	if( pr_cdata[chan].vfx >= 0x60 )
	{
		if( (pr_cdata[chan].vfx & 15) == 0 )
		{
			if( (pr_cdata[chan].vfx >> 4) == 0xC )
				pr_cdata[chan].vfx = pr_last_VOLUME[chan + ((pr_cdata[chan].vfx >> 4) - 6) * 8];
			else
				pr_last_VOLUME[chan + ((pr_cdata[chan].vfx >> 4) - 6) * 8] = pr_cdata[chan].vfx;
		}
		else
		{
			pr_last_VOLUME[chan + ((pr_cdata[chan].vfx >> 4) - 6) * 8] = pr_cdata[chan].vfx;
		}
	}
	if( pr_rbuffer[chan].fx != 0 )
	{
		pr_cdata[chan].fx = pr_rbuffer[chan].fx;
		bits |= 8;
	}
	else
	{
		pr_cdata[chan].fx = 0;
	}
	if( pr_rbuffer[chan].param != 0 )
	{
		pr_cdata[chan].param = pr_rbuffer[chan].param;
		bits |= 16;
	}
	else
	{
		pr_cdata[chan].param = 0;
	}

	if( pr_rbuffer[chan].note != 0 )
	{
		PR_CheckNote( pr_rbuffer[chan].note, pr_rbuffer[chan].inst, row, chan );
	}

	switch( pr_cdata[chan].fx )
	{
	case 0x9:
		if( pr_cdata[chan].param == 0 )
		{
			pr_cdata[chan].param = pr_last_SAMPOFF[chan];
			bits |= 16;
		}
		else
		{
			pr_last_SAMPOFF[chan] = pr_cdata[chan].param;
		}
		break;
	case 0xE:
		if( pr_cdata[chan].param == 0 )
		{
			pr_cdata[chan].param = pr_last_EXTRA[chan];
			bits |= 16;
		}
		else
		{
			pr_last_EXTRA[chan] = pr_cdata[chan].param;
			if( pr_cdata[chan].param == 0x60 )						// PATTERN LOOP
			{
				xpatterns[index].row_marks[row] = 1;
			}
		}
		break;
	case 0xD:
		DxxJ = -1;
		for( x = chan+1; x < pr_channels; x++ )
		{
			if( pr_rbuffer[x].fx == 0xD )
			{
				pr_cdata[chan].fx = 0;
				pr_cdata[chan].param = 0;
				bits &= (255 - 8 - 16 );
				break;
			}
			if( pr_rbuffer[x].fx == 0xB )
			{
				DxxJ = xhead.orders[pr_rbuffer[x].param];
			}
		}
		if( pr_cdata[chan].param != 0 )
		{
			if( DxxJ == -1 )
			{
				pr_cdata[chan].param = (pr_cdata[chan].param & 0xF) + ((pr_cdata[chan].param >> 4) * 10);
				DxxA = PR_GetAdjacentPatterns( index, &DxxB );
				if( DxxA > 0 )
				{
					suffix_size = 1;
					suffix = new byte[1];
					suffix[0] = DxxA * 3;
					for( x = 0; x < DxxA; x++ )
					{
						PR_ResizeBufferExB( suffix_size, 3, &suffix );
						suffix_size += 3;
						suffix[ 1 + x*3 ] = DxxB[x];
						xpatterns[DxxB[x]].row_marks[pr_cdata[chan].param] = 1;
					}
				}
				else
				{
					pr_cdata[chan].param = 0;
				}
				SAFE_DELETE( DxxB );
			}
			else
			{
				pr_cdata[chan].param = (pr_cdata[chan].param & 0xF) + ((pr_cdata[chan].param >> 4) * 10);
				suffix_size = 3;
				suffix = new byte[3];
				suffix[0] = 0;
				suffix[1] = DxxJ;
			}
		}
		break;
	case 0xB:
		for( x = chan + 1; x < pr_channels; x++ )
		{
			if( (pr_rbuffer[x].fx == 0xB) | (pr_rbuffer[x].fx == 0xD) )
			{
				pr_cdata[chan].fx = 0;
				pr_cdata[chan].param = 0;
			}
		}
	}
	
	int out_length;
	int cput;
	cput = 0;
	if( ((bits & 31) != 31) || ((bits & 32) == 32) )
	{
		cput = 0;
		out_length = 1;

		if( bits & 1 )
			out_length++;
		if( bits & 2 )
			out_length++;
		if( bits & 4 )
			out_length++;
		if( bits & 8 )
			out_length++;
		if( bits & 16 )
			out_length++;
		out_length += suffix_size;
		SAFE_DELETE( (*out_data) );
		(*out_data) = new byte[out_length];
		(*out_data)[cput] = 128 | bits;
		cput++;
		if( bits & 1 )
		{
			(*out_data)[cput] = pr_cdata[chan].note;
			cput++;
		}
		if( bits & 2 )
		{
			(*out_data)[cput] = pr_cdata[chan].inst;
			cput++;
		}
		if( bits & 4 )
		{
			(*out_data)[cput] = pr_cdata[chan].vfx;
			cput++;
		}
		if( bits & 8 )
		{
			(*out_data)[cput] = pr_cdata[chan].fx;
			cput++;
		}
		if( bits & 16 )
		{
			(*out_data)[cput] = pr_cdata[chan].param;
			cput++;
		}
	}
	else
	{
		out_length = 5 + suffix_size;
		SAFE_DELETE( *out_data );
		(*out_data) = new byte[out_length];
		(*out_data)[cput] = pr_cdata[chan].note;  cput++;
		(*out_data)[cput] = pr_cdata[chan].inst;  cput++;
		(*out_data)[cput] = pr_cdata[chan].vfx;   cput++;
		(*out_data)[cput] = pr_cdata[chan].fx;    cput++;
		(*out_data)[cput] = pr_cdata[chan].param; cput++;
	}
	for( x = 0; x < suffix_size; x++ )
	{
		(*out_data)[cput] = suffix[x];
		cput++;
	}
	SAFE_DELETE( suffix );
	return out_length;
}

bool PR_CheckNote( int note, int inst, int row, int chan )
{
	if( pr_warnings >= 0 )
	{
		note--;
		if( note == 96 ) return false;
		int samp_index, rel_note, finetune, period;
		if( inst == 0 ) return false;
		if( inst > xhead.ins ) return false;
		inst--;
		
		if( xinst[inst].nsamps > 0 )
		{
			if( xinst[inst].nsamps > 1 )
			{
				samp_index = xinst[inst].note_map[note - 1];
			}
			else
			{
				samp_index = xinst[inst].note_map[0];
			}

			rel_note = xsamp[samp_index].rel_note;
			finetune = xsamp[samp_index].finetune;
			if( rel_note >= 128 ) rel_note -= 256;
			if( finetune >= 128 ) finetune -= 256;
			note += rel_note;
			period = 7680 - (note * 64) - (((finetune << 7) + 128) >> 8);
			if( period < 1600 )
			{
				if( pr_warnings > 0 )
					printf( "Note breaks limit at: row %i, channel %i\n", row, chan );
				else
					printf( "Other notes were higher than 128khz too\n" );
				pr_warnings--;
				return true;
			}
		}
	}
	return false;
}

int PR_GetAdjacentPatterns( int pat_index, int** b_return )
{
	// give NULL buffer (b_return)
	int x;
	int y;
	int nresults=0;
	bool hasnum;
	for( x = 0; x < xhead.length; x++ )
	{
		if( !(x+1 >= xhead.length) )
		{
			if( xhead.orders[x] == pat_index )
			{
				hasnum = false;
				for( y = 0; y < nresults; y++ )
				{
					if( (*b_return)[y] == xhead.orders[x+1] )
					{
						hasnum = true;
						break;
					}
				}

				if( !hasnum )
				{
					PR_ResizeBufferExI( nresults, 1, b_return );
					(*b_return)[nresults] = xhead.orders[ x+1 ];
					nresults++;
				}
			}
		}
	}
	return nresults;
}

int PR_ScanOffset( XMS_PATTERN* pat, int row )
{
	int x, y;
	int off;
	byte h;
	int a, b;
	int la, lb;
	int rowskip[8] = {-1,-1,-1,-1,-1,-1,-1,-1};
	if( row >= pat->nrows )
		return 0;
	off=0;
	for( y = 0; y < pat->nrows; y++ )
	{
		if( y == row ) break;
		off++;
		for( x = 0; x < pr_channels; x++ )
		{
			if( rowskip[x] == -1 )
			{
				h = pat->data[off];
				if( h & 0x80 )
				{
					off++;
//					if( h & cbit_n ) off++;
//					if( h & cbit_i ) off++;
					switch( h & (cbit_n|cbit_I|cbit_i) )
					{
					case 0:     //000:
					case 2:     //010:
					case 2|4:   //110:
						break;
					case 1:     //001:
					case 1|2:   //011:
					case 4:     //100:
					case 1|2|4: //111:
						off += 1;
						break;
					case 1|4:   //101:
						off += 2;
					}
					if( h & cbit_v ) off++;
					switch( h & (cbit_e | cbit_E) )
					{
					case 0:
						a=0;
						b=0;
						break;
					case cbit_e:
						a=pat->data[off]; off++;
						b=pat->data[off]; off++;
						break;
					case cbit_E:
						a=la;
						b=lb;
						break;
					case cbit_e|cbit_E:
						a=la;
						b=pat->data[off]; off++;
					}
					if( h & cbit_r )
					{
						rowskip[x] = pat->data[off]; off++;
					}
				}
				else
				{
					off += 3;
					a = pat->data[off];
					b = pat->data[off+1];
					off+=2;
				}
			}
			else
			{
				if( rowskip[x] & BIT7 )
				{
					rowskip[x]--;
					if( rowskip[x] == 127 )
						rowskip[x] = -1;
					a=0; b=0;
				}
				else
				{
					rowskip[x]--;
				}
			}
			la=a;
			lb=b;
			if( a == 0xD )
			{
				if( b != 0 )
				{
					a = pat->data[off];
					if( a == 0 )
						off += 3;
					else
						off += a;
				}
			}
		}
	}
	return off;
}

bool PR_RampCheck( int note, int inst )
{
	note--;
	if( note == 96 ) return false;
	int samp_index;
	if( inst == 0 ) return false;
	if( inst > xhead.ins ) return false;
	inst--;
	if( xinst[inst].nsamps > 0 )
	{
		if( xinst[inst].nsamps > 1 )
			samp_index = xinst[inst].note_map[note-1];		// MINUS 1? CHECK FOR ERRORS
		else
			samp_index = xinst[inst].note_map[0];
		return xsamp[samp_index].ramping;
	}
	return false;
}

void PR_ResizeBuffer( int amount )
{
	byte* new_buffer;
	new_buffer = new byte[pr_buffersize + amount];
	if( pr_buffersize != 0 )
	{
		memcpy( new_buffer, pr_buffer, pr_buffersize );
		delete[] pr_buffer;
		pr_buffer = new_buffer;
	}
	pr_buffer = new_buffer;
	pr_buffersize += amount;
}

void PR_ResizeBufferExI( int old_size, int amount, int** buffer )
{
	int* new_buffer;
	new_buffer = new int[old_size+amount];
	if( (*buffer) != NULL )
	{
		memcpy( new_buffer, (*buffer), old_size*4 );
		delete[] (*buffer);
	}
	(*buffer) = new_buffer;
}

void PR_ResizeBufferExB( int old_size, int amount, byte** buffer )
{
	byte* new_buffer;
	new_buffer = new byte[ old_size+amount ];
	if( (*buffer) != NULL )
	{
		memcpy( new_buffer, (*buffer), old_size );
		delete[] (*buffer);
	}
	(*buffer) = new_buffer;
}

