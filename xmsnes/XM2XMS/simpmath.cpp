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

// also contains other goodies
#include "mglobal.h"

#include <float.h>
#include <math.h>
#include <stdlib.h>
#include <cstring>

double roundf( double d ) { return floor(d+0.5); }
//double roundf( double d ) { return d < 0.0 ? ceil(d - 0.5) : floor(d + 0.5); }
double fint( double d ) { if( d < 0 ) return ceil(d); return floor(d); }

void reversecode4( unsigned int* code )
{
	unsigned int c2;
	c2 = ((*code)>>24) & 0xFF;
	c2 |= ((*code)>>8) & 0xFF00;
	c2 |= ((*code)<<8) & 0xFF0000;
	c2 |= ((*code)<<24) & 0xFF000000;
	*code = c2;
}

unsigned int GetExt( char* fn )
{
	int x, y;
	char ex[4];
	ex[3] = 0;
	x = 0;
	y = 0;
	bool found_ext = false;
	while( fn[x] != 0 )
	{
		if( y < 3 )
		{
			ex[y] = tolower(fn[x]);
			y++;
		}
		if( fn[x] == '.' )
		{
			found_ext = true;
			y = 0;
		}
		x++;
	}
	ex[y] = 0;
	if( !found_ext )
		return EXT_NONE;
	if( strcmp( ex, "mod" ) == 0 )
		return EXT_MOD;
	if( strcmp( ex, "s3m" ) == 0 )
		return EXT_S3M;
	if( strcmp( ex, "xm" ) == 0 )
		return EXT_XM;
	if( strcmp( ex, "xms" ) == 0 )
		return EXT_XMS;
	if( strcmp( ex, "spc" ) == 0 )
		return EXT_SPC;
	if( strcmp( ex, "txt" ) == 0 )
		return EXT_TXT;
	return (ex[0]<<16) + ((ex[1])<<8) + ((ex[2]));
}

void SetExt( char** fn, const char* ext )
{
	char* newfn;
	int x=0, y=0, z=0;
	int es=0;
	while( (*fn)[x] != 0 )
	{
		if( y == 0 )
		{
			es = x;
			if( (*fn)[x] == '.' )
			{
				y = 1;
			}
		}
		else
		{
			if( (*fn)[x] == '.' )
			{
				es = x;
			}
		}
		x++;
	}
	z = strlen( ext );
	if( y == 1 )
	{
		newfn = new char[es+1 + z + 1];
		memcpy( newfn, (*fn), es+1 );
	}
	else
	{
		newfn = new char[es+2 + z + 1];
		memcpy( newfn, (*fn), es+1 );
		es++;
		newfn[es] = '.';
	}
	
	delete (*fn);
	memcpy( newfn+es+1, ext, z );
	newfn[es+1+z] = 0;
	(*fn) = newfn;
}
