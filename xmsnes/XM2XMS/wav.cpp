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

// a little wav lib

#include "mglobal.h"
#include "files.h"
#include "wav.h"
#include "simpmath.h"

int LoadWAV( char* file, XMS_SAMPLE* s, int findex )
{
	File_Open( file, FILE_MODE_READ, findex );
	int file_size;
	File_Skip( 4, findex );				// "RIFF"
	file_size = File_ReadD( findex ) + 8;
	File_Skip( 4, findex );				// "WAVE"

	int chunk_size;
	
	int a;

	int bit_depth;

	bool hasformat=false;
	bool hasdata=false;

	unsigned int chunk_code;
	while( 1 )
	{
		if( File_Tell( findex ) >= file_size ) break;
		chunk_code = File_ReadD( findex );
		reversecode4( &chunk_code );
		chunk_size = File_ReadD( findex );
		switch( chunk_code )
		{
		case 'fmt ':	/// format chunk
			a = File_ReadW( findex ); // compression code
			if( a != 1 )
			{
				File_Close( findex );
				return LOADWAV_UNKNOWN_COMP;				// unknown compression
			}
			a = File_ReadW( findex ); // #channels
			if( a != 1 )
			{
				File_Close( findex );
				return LOADWAV_TOOMANYCHANNELS;
			}
			File_Skip( 4, findex );					// sample rate
			File_Skip( 4, findex );					// average something
			File_Skip( 2, findex );					// wBlockAlign
			bit_depth = File_ReadW( findex );
			if( bit_depth != 8 && bit_depth != 16 )
			{
				File_Close( findex );
				return LOADWAV_UNSUPPORTED_BD;
			}
//			File_Skip( 2, findex );
			if( (chunk_size - 0x10) > 0 )
				File_Skip( (chunk_size - 0x10), findex );
			hasformat=true;
			break;
		case 'data':
			switch( bit_depth )
			{
			case 8:
				s->samp_data = new int[chunk_size];
				s->length = chunk_size;
				for( a = 0; a < s->length; a++ )
					s->samp_data[a] = (((int)File_ReadB( findex ))-128) * 256;
				hasdata=true;
				break;
			case 16:
				s->samp_data = new int[chunk_size/2];
				s->length = chunk_size/2;
				for( a = 0; a < s->length; a++ )
					s->samp_data[a] = (signed short)File_ReadW( findex );
				hasdata=true;
				break;
			default:
				File_Close( findex );
				return LOADWAV_BADDATA;
			}
		default:
			File_Skip( chunk_size, findex );
		}
	}
	File_Close( findex );
	return (hasformat && hasdata) ? LOADWAV_OK : LOADWAV_CORRUPT;
	
}
