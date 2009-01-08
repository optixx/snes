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

#include "mglobal.h"

byte	file_byte;
word	file_word;
dword	file_dword;

int		file_active[4] = {0};

#define FILE_MODE_CLOSED 0
#define FILE_MODE_READ 1
#define FILE_MODE_WRITE 2

#include <fstream>

std::ifstream file_in[4];
std::ofstream file_out[4];

void File_Open( char* filename, int mode, int id );
void File_Close( int id );
void File_Skip( int nbytes, int id );
void File_Seek( int offset, int id );
int  File_Exists( char* filename );
byte  File_ReadB( int id );
word  File_ReadW( int id );
dword File_ReadD( int id );
void  File_WriteB( byte data, int id );
void  File_WriteW( word data, int id );
void  File_WriteD( dword data, int id );

void File_Open( char* filename, int mode, int id )
{
	switch( mode )
	{
	case FILE_MODE_READ:
		file_in[id].open( filename, std::ios::in | std::ios::binary );
		file_active[id] = mode;
		break;
	case FILE_MODE_WRITE:
		file_out[id].open( filename, std::ios::out | std::ios::trunc | std::ios::binary );
		file_active[id] = mode;
		break;
	}
}

void File_OpenW( char* filename, int id )
{
	file_out[id].open( filename, std::ios::in | std::ios::out | std::ios::binary );
	file_active[id] = FILE_MODE_WRITE;
}

void File_Close( int id )
{
	switch( file_active[id] )
	{
	case FILE_MODE_READ:
		file_in[id].close();
		file_active[id] = FILE_MODE_CLOSED;
		break;
	case FILE_MODE_WRITE:
		file_out[id].close();
		file_active[id] = FILE_MODE_CLOSED;
	}
}

int File_IsOpen( int mode, int id )
{
	if( mode == FILE_MODE_READ )
	{
		return file_in[id].is_open();
	}
	else if( mode == FILE_MODE_WRITE )
	{
		return file_out[id].is_open();
	}
	return 0;
}

void File_Skip( int nbytes, int id )
{
	switch( file_active[id] )
	{
	case FILE_MODE_READ:
		file_in[id].seekg( nbytes, std::ios::cur );
		break;
	case FILE_MODE_WRITE:
		file_out[id].seekp( nbytes, std::ios::cur );
	}
}

void File_Seek( int offset, int id )
{
	switch( file_active[id] )
	{
	case FILE_MODE_READ:
		file_in[id].seekg( offset, std::ios::beg );
		break;
	case FILE_MODE_WRITE:
		file_out[id].seekp( offset, std::ios::beg );
	}
	
}

int File_Tell( int id )
{
	switch( file_active[id] )
	{
	case FILE_MODE_READ:
		return (int)file_in[id].tellg();
	case FILE_MODE_WRITE:
		return (int)file_out[id].tellp();
	}
	return -1;
}

int File_Exists( char* filename )
{
	std::ifstream f;
	f.open( filename, std::ios::in );
	f.seekg( 0, std::ios::end );
	int p;
	p = f.tellg();
	f.close();
	if( p == -1 || p == 0 )
		return 0;
	return p;
}

byte File_ReadB( int id )
{
	file_in[id].read( (char*)&file_byte, 1 );
	return file_byte;
}

word File_ReadW( int id )
{
	file_in[id].read( (char*)&file_word, 2 );
	return file_word;
}

dword File_ReadD( int id )
{
	file_in[id].read( (char*)&file_dword, 4 );
	return file_dword;
}

void File_WriteB( byte data, int id )
{
	file_byte = data;
	file_out[id].write( (char*)&file_byte, 1 );
}

void File_WriteW( word data, int id )
{
	file_word = data;
	file_out[id].write( (char*)&file_word, 2 );
}

void File_WriteD( dword data, int id )
{
	file_dword = data;
	file_out[id].write( (char*)&file_dword, 4 );
}

void File_ReadData( void* pdata, int length, int id )
{
	file_in[id].read( (char*)pdata, length );
}

void File_WriteData( void* pdata, int length, int id )
{
	file_out[id].write( (char*)pdata, length );
}

void File_Kill( char* filename )
{
	remove( filename );
}
