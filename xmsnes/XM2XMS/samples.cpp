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

#define sc_padlength 16

#define nramp_size 32

#include "mglobal.h"
#include "simpmath.h"

#include <cstring>
#include <math.h>

void FixSample( XMS_SAMPLE* samp, bool m, int unroll );
void NNResample( XMS_SAMPLE* samp, double rate );
void LinearResample( XMS_SAMPLE* samp, double rate );
void GoodResample( XMS_SAMPLE* samp, double rate );
void SampAmp( XMS_SAMPLE* samp, double amp );
void SampTune( XMS_SAMPLE* samp, double rate );

extern bool arg_i;
extern bool arg_4bit;

void FixSample( XMS_SAMPLE* samp, bool m, int unroll )
{
	int* newdata;
	double a,b;
	int x;
	int y;
	a = (float)(samp->loop_length % 16);
	// resample
	
	if( a != 0 && samp->loop_type != 0 )
	{
		b = (double)(samp->loop_length + (16 - a));
		b = b / ((double)( samp->loop_length ));
		switch( samp->resamp )
		{
		case 0:
			NNResample( samp, b );
			break;
		case 1:
			LinearResample( samp, b );
			break;
		default:
			LinearResample( samp, b );//GoodResample( samp, b );
			break;
		}

		samp->loop_start = (int)roundf( ((float)samp->loop_start) * b );
		samp->loop_length= samp->loop_length + (16 - (int)a);
	}
	
	// fix loop start
	a = (float)(samp->loop_start % 16);
	if( a != 0 && samp->loop_type != 0 )
	{
		newdata = new int[(samp->length + (16 - (int)a))];
		samp->loop_start += (16 - (int)a);
		samp->length += (16 - (int)a);
		for( x = samp->length - 1; x >= (16 - (int)a); x-- )
		{
			newdata[x] = samp->samp_data[ x - (16 - (int)a) ];
		}
		for( x = 0; x < (16 - (int)a); x++ )
		{
			newdata[x] = 0;
		}
		delete[] samp->samp_data;
		samp->samp_data = newdata;
	}
	
	// trim off end data
	a = (float)(samp->loop_start + samp->loop_length);
	if( a != 0 && samp->length != (samp->loop_start + samp->loop_length) && samp->loop_type != 0 )
	{
		newdata = new int[(int)a];
		memcpy( newdata, samp->samp_data, (int)(a)*4 );
		delete[] samp->samp_data;
		samp->samp_data = newdata;
		samp->length = (int)a;
	}
	
	// unwrap BIDI loop
	if( samp->loop_type == 2 )
	{
		samp->loop_type = 1;
		newdata = new int[samp->length + samp->loop_length];
		memcpy( newdata, samp->samp_data, samp->length*4 );
		for( x = 0; x < samp->loop_length; x++ )
		{
			newdata[samp->loop_start + samp->loop_length + x] =
				samp->samp_data[samp->loop_start + samp->loop_length - x - 1];
		}
		delete[] samp->samp_data;
		samp->samp_data = newdata;
		samp->length += samp->loop_length;
		samp->loop_length = samp->loop_length * 2;
	}
	
	// check for pad
	a = 0;
	if( !( samp->length < sc_padlength ) )
	{
		for( x = 0; x < sc_padlength; x++ )
		{
			if( samp->samp_data[x] != 0 )
				a = 1;
		}
	}
	else
	{
		a = 1;
	}
	if( samp->loop_type != 0 && samp->loop_start <= sc_padlength - 1 )
		a = 1;
	if( a )
	{
		newdata = new int[samp->length + sc_padlength];
		samp->length += sc_padlength;
		samp->loop_start += sc_padlength;
		for( x = samp->length - 1; x >= sc_padlength; x-- )
		{
			newdata[x] = samp->samp_data[x - sc_padlength];
		}
		for( x = 0; x < sc_padlength; x++ )
		{
			newdata[x] = 0;
		}
		delete[] samp->samp_data;
		samp->samp_data = newdata;
	}
	if( samp->loop_type != 0 )
	{
		samp->samp_data[samp->loop_start - 2] = samp->samp_data[samp->loop_start + samp->loop_length - 2];
		samp->samp_data[samp->loop_start - 1] = samp->samp_data[samp->loop_start + samp->loop_length - 1];
	}
	int u_times = 1;
	if( samp->loop_type != 0 )
	{
		u_times = samp->unroll;
		if( u_times == -1 )
		{
			u_times = 0;
			while( samp->loop_length * (u_times+1) < unroll )
			{
				u_times++;
			}
		}
		if( u_times >= 1 )
		{
			newdata = new int[samp->length + (u_times * samp->loop_length)];
			memcpy( newdata, samp->samp_data, samp->length *4 );
			for( x = 0; x < u_times; x++ )
			{
				for( y = 0; y < samp->loop_length; y++ )
				{
					newdata[ samp->length + (x * samp->loop_length) + y ] = newdata[ samp->loop_start + y ];
				}
			}
			samp->length += (u_times * samp->loop_length);
			samp->loop_length += (u_times * samp->loop_length);
			delete[] samp->samp_data;
			samp->samp_data = newdata;
		}
	}
	if( m && samp->loop_type == 0 )
	{
		for( x = 0; x < nramp_size; x++ )
		{
			a = samp->samp_data[samp->length - nramp_size + x];
			a = a * ( 1-( ( 1 / ((double)nramp_size) ) * (double)x ) );
			samp->samp_data[samp->length - nramp_size + x] = (int)roundf(a);
		}
	}
}

void NNResample( XMS_SAMPLE* samp, double rate )
{
	int x;
	int* resamp;
	int nl;
	nl = (int)roundf((float)samp->length * rate);
	resamp = new int[ nl ];
	double b;
	int c;
	for( x = 0; x < nl; x++ )
	{
		b = ((double)x) / rate;
		c = samp->samp_data[(int)roundf(b)];
		resamp[x] = c;
		if( resamp[x] < -32768 )
			resamp[x] = -32768;
		if( resamp[x] > 32767 )
			resamp[x] = 32767;
	}
	delete[] samp->samp_data;
	samp->samp_data = resamp;
	samp->length = nl;
	SampTune( samp, rate );
}

void LinearResample( XMS_SAMPLE* samp, double rate )
{
	int a;
	int nl;
	nl = (int)roundf((double)samp->length * rate);
	int* resamp;
	resamp = new int[ nl ];
	double b,c,d,e;
	e = 0;
	for( a = 0; a < nl; a++ )
	{
		d = ((double)a) / rate;
		b = samp->samp_data[(int)floor(d)];
		if( !(((int)floor(d)) + 1 >= samp->length) )
		{
			c = samp->samp_data[((int)floor(d)) + 1];
		}
		else
		{
			if( samp->loop_type != 0 )
				c = samp->samp_data[samp->loop_start];
			else
				c = 0;
		}
		b = b + (c - b) * (e / rate);
		e++;
		while( e > rate )
			e -= rate;
		resamp[a] = (int)roundf(b);
		if( resamp[a] < -32768 )
			resamp[a] = -32768;
		if( resamp[a] > 32767 )
			resamp[a] = 32767;
	}
	delete[] samp->samp_data;
	samp->samp_data = resamp;
	samp->length = nl;
	SampTune( samp, rate );
}

double CubicInterpolate(double a, double b, double c, double d, double x)
{
	if (x <= 0) return b; else if (x >= 1)
	{
		return c;
	}
	else
	{
		double x2 = x * x, x3 = x2 * x, p = (d - c) - (a - b);
		return (p * x3) + ((a - b - p) * x2) + ((c - a) * x) + b;
	}
}

void GoodResample( XMS_SAMPLE* samp, double rate )
{
	int a;
	int nl;
	nl = (int)roundf((double)samp->length * rate);
	int* resamp;
	resamp = new int[ nl ];
	double b,d,e;

	double x1, x2, x3, x4;
	e = 0;
	for( a = 0; a < nl; a++ )
	{
		d = ((double)a) / rate;
		if( !( ((int)floor(d)) - 2 < 0 ) )
			x1 = samp->samp_data[((int)floor(d)) - 2];
		else
			x1 = 0;
		if( !( ((int)floor(d)) - 1 < 0 ) )
			x2 = samp->samp_data[((int)floor(d)) - 1];
		else
			x2 = 0;
		x3 = samp->samp_data[((int)floor(d))];
		if( !( ((int)floor(d)) + 1 >= samp->loop_length ) )
			x4 = samp->samp_data[((int)floor(d)) + 1];
		else
		{
			if( samp->loop_type != 0 )
				x4 = samp->samp_data[samp->loop_start];
			else
				x4 = 0;
		}
		b = CubicInterpolate( x1, x2, x3, x4, e );
		
		e++;
		while( e > rate )
			e -= rate;
		resamp[a] = (int)roundf(b);
		if( resamp[a] < -32768 )
			resamp[a] = -32768;
		if( resamp[a] > 32767 )
			resamp[a] = 32767;
	}
	delete[] samp->samp_data;
	samp->samp_data = resamp;
	samp->length = nl;
	SampTune( samp, rate );
}

void SampAmp( XMS_SAMPLE* samp, double amp )
{
	int a;
	double b;
	for( a = 0; a < samp->length; a++ )
	{
		b = (double)samp->samp_data[a];
		b = roundf( b * amp );
		samp->samp_data[a] = (int)b;
	}
}

void CsTuning( int rel_note, int finetune, double* hz )
{
	double rn = (double)rel_note;
	double ft = (double)finetune;
	double p, f;
	if( rn > 128 ) rn -= 256;
	rn += 48;
	if( ft > 128 ) ft -= 256;
	p = 7680 - (rn * 16 * 4) - (ft / 2);
	f = (8363 * ( pow( 2, ((4608 - p) / (12*16*4)) ) ));
	*hz = f;
}

void CsFreq( int* rel_note, int* finetune, double hz )
{
	double rn = (double)*rel_note;
	double ft = (double)*finetune;
	double p, f, a;
	f = hz;
	p = -(((log(f/8363) / log(2)) * 768) - 4608);
	a = (7680 - p) * 2;
	a = 96 * 128 - a;
	rn = (double)(-(((int)floor(a))/128));
	ft = (double)(-(((int)floor(a))%128));
	rn += 48;
	if( rn < 0 ) rn += 256;
	if( ft < 0 ) ft += 256;
	*rel_note = (int)rn;
	*finetune = (int)ft;
}

void SampTune( XMS_SAMPLE* samp, double rate )
{
	/*
	double p;
	double f;
	double a;
	double rn;
	double ft;
	rn = (double)samp->rel_note;
	if( rn > 128 ) rn -= 256;
	rn += 48;
	ft = (double)samp->finetune;
	if( ft > 128 ) ft -= 256;
	p = 7680 - (rn * 16 * 4) - (ft / 2);
	f = (8363 * ( pow( 2, ((4608 - p) / (12*16*4)) ) ));
	f *= rate;
	p = -(((log(f/8363) / log(2)) * 768) - 4608);
	a = (7680 - p) * 2;
	a = 96 * 128 - a;
	rn = (float)(-(((int)floor(a))/128));
	ft = (float)(-(((int)floor(a))%128));
	rn += 48;
	if( rn < 0 ) rn += 256;
	if( ft < 0 ) ft += 256;
	samp->rel_note = (int)rn;
	samp->finetune = (int)ft;
	*/
	double hz;
	CsTuning( samp->rel_note, samp->finetune, &hz );
	hz *= rate;
	int a, b;
	CsFreq( &a, &b, hz );
	samp->rel_note = a;
	samp->finetune = b;
}

void SampScanOptions( XMS_SAMPLE* samp )
{
	char* s;
	s = strstr( samp->sname, "-f" );
	if( s != NULL && (!arg_i) )
		samp->filter = s[2] - 48;
	else
		samp->filter = 4;
	if( arg_4bit )
		samp->filter = 0;
	if( strcmp( samp->sname, "-c" ) || arg_i )
		samp->ramping = true;
	else
		samp->ramping = false;
	s = strstr( samp->sname, "-r" );
	if( s != NULL && (!arg_i) )
		samp->resamp = s[2] - 48;
	else
		samp->resamp = 2;
	s = strstr( samp->sname, "-u" );
	if( s != NULL && (!arg_i) )
		samp->unroll = s[2] - 48;
	else
		samp->unroll = -1;
}
