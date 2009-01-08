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

#define SPCE_TITLE		1
#define SPCE_ARTIST		2
#define SPCE_GAME		4
#define SPCE_COMMENTS	8
#define SPCE_SECONDS	16
#define SPCE_FADE		32

#include "mglobal.h"
#include "files.h"
#include "simpmath.h"

#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

const char	SPC_HEAD[]			= "SNES-SPC700 Sound File Data v0.30"; // len = 33
const byte	SPC_VERSION			= 30;
const byte	SPC_ID666ENABLE		= 26;
const byte	SPC_ID666DISABLE	= 27;

const word	SPC_PC		=0x618;		// PROGRAM COUNTER
const byte	SPC_A		=0x00;		// ACCUMULATOR
const byte	SPC_X		=0x00;		// INDEX REGISTER
const byte	SPC_Y		=0x00;		// INDEX REGISTER
const byte	SPC_PSW		=0x00;		// PROGRAM STATUS WORD
const byte  SPC_SP		=0xEF;		// STACK POINTER

const char	SPC_DUMPER[]="XMSNES\0";

int SPX_IMAGE_SIZE;
const int SPX_IMAGE_SPACE	=6912;

extern XMS_HEAD xhead;
extern int XMS_FILE_MAX;

typedef struct tSPC_INFO
{
	char title[32];
	char artist[32];
	char game[32];
	char dumper[16];
	char comments[32];
	int seconds;
	int fade;
} SPC_INFO;

void WriteString( char* string, int length );

void BuildSPC( char* filename, SPC_INFO* info )
{	
	char* newfile=NULL;
	int fnlen;
	fnlen = strlen( filename );
	newfile = new char[fnlen+1];
	memcpy( newfile, filename, fnlen );
	newfile[fnlen+0] = 0;
	SetExt( &newfile, "spc" );
	if( File_Exists( newfile ) )
	{
		int cyn = 0;
		while( tolower(cyn) != 'y' && tolower(cyn) != 'n' )
		{
			printf( "SPC exists, overwrite? (y/n) " );
			cyn = getchar();
			while( getchar() != '\n' );
			//printf( "\n" );
		}
		if( tolower(cyn) == 'n' )
		{
			printf( "Operation canceled.\n" );
			return;
		}
	}
	File_Open( newfile, FILE_MODE_WRITE, 0 );
	File_WriteData( (void*)SPC_HEAD, 33, 0 );
	File_WriteB( 26, 0 );
	File_WriteB( 26, 0 );
	File_WriteB( SPC_ID666ENABLE, 0 );
	File_WriteB( SPC_VERSION, 0 );
	File_WriteW( SPC_PC, 0 );
	File_WriteB( SPC_A, 0 );
	File_WriteB( SPC_X, 0 );
	File_WriteB( SPC_Y, 0 );
	File_WriteB( SPC_PSW, 0 );
	File_WriteB( SPC_SP, 0 );
	File_WriteW( 0, 0 );
	WriteString( info->title, 32 );
	WriteString( info->game, 32 );
	WriteString( (char*)SPC_DUMPER, 16 );
	WriteString( info->comments, 32 );
	
	// write date
	char stime[11];
	stime[10] = 0;
	time_t rawtime;
	struct tm* timeinfo;
	time( &rawtime );
	timeinfo = localtime( &rawtime );
	stime[0] = ((timeinfo->tm_mon+1) / 10) + 48;
	stime[1] = ((timeinfo->tm_mon+1) % 10) + 48;
	
	stime[3] = (timeinfo->tm_mday / 10) + 48;
	stime[4] = (timeinfo->tm_mday % 10) + 48;
	
	stime[6] = ((timeinfo->tm_year+1900) / 1000) + 48;
	stime[7] = (((timeinfo->tm_year+1900) / 100) % 10) + 48;
	stime[8] = (((timeinfo->tm_year+1900) / 10) % 10) + 48;
	stime[9] = ((timeinfo->tm_year+1900) % 10) + 48;
	
	stime[2] = '/';
	stime[5] = '/';
	
	WriteString( stime, 11 );
	char strPut[8];
	itoa( info->seconds, strPut, 10 );
	WriteString( strPut, 3 );
	itoa( info->fade, strPut, 10 );
	WriteString( strPut, 5 );
	WriteString( info->artist, 32 );
	File_WriteB( 0, 0 );
	File_WriteB( '0', 0 );
	int x;
	for( x = 0; x < 45; x++ )
		File_WriteB( 0, 0 );
	
	int fsize;
	// SPC RAM ...
	byte buffer[1024];	// 1kb
	if( !File_Exists( "dp_snap.bin" ) )
	{
		printf( "Missing \"dp_snap.bin\"!" );
		File_Close( 0 );
		File_Kill( newfile );
		delete[] newfile;
		return;
	}
	File_Open( "dp_snap.bin", FILE_MODE_READ, 1 );
	File_ReadData( buffer, 512, 1 );
	File_Close( 1 );
	File_WriteData( buffer, 512, 0 );
	File_WriteData( buffer, 256, 0 ); // dummy data

	// load frequency table
	if( xhead.lin )
	{
		if( !File_Exists( "spx_lft.bin" ) )
		{
			printf( "Missing \"spx_lft.bin\"!" );
			File_Close( 0 );
			File_Kill( newfile );
			delete[] newfile;
			return;
		}
		File_Open( "spx_lft.bin", FILE_MODE_READ, 1 );
		File_ReadData( buffer, 768, 1 );
		File_Close( 1 );
	}
	else
	{
		if( !File_Exists( "spx_aft.bin" ) )
		{
			printf( "Missing \"spx_aft.bin\"!" );
			File_Close( 0 );
			File_Kill( newfile );
			delete[] newfile;
			return;
		}
		File_Open( "spx_aft.bin", FILE_MODE_READ, 1 );
		File_ReadData( buffer, 768, 1 );
		File_Close( 1 );
	}
	File_WriteData( buffer, 768, 0 );
	byte spx_core[SPX_IMAGE_SPACE];
	fsize = File_Exists( "spx_core.bin" );
	if( fsize == -1 || fsize == 0 )
	{
		printf( "Missing \"spx_core.bin\"!" );
		File_Close( 0 );
		File_Kill( newfile );
		delete[] newfile;
		
		return;
	}
	SPX_IMAGE_SIZE = fsize;
	File_Open( "spx_core.bin", FILE_MODE_READ, 1 );
	File_ReadData( spx_core, SPX_IMAGE_SIZE, 1 );
	File_Close( 1 );
	File_WriteData( spx_core, SPX_IMAGE_SPACE, 0 );
	
	fsize = File_Exists( filename );
	if( fsize == -1 || fsize == 0 )
	{
		// Bad Input
		File_Close( 0 );
		File_Kill( newfile );
		delete[] newfile;
		return;
	}
	if( fsize > XMS_FILE_MAX )
	{
		// File too big
		printf( "XMS is too large!\n" );
		File_Close( 0 );
		File_Kill( newfile );
		delete[] newfile;
		return;
	}
	byte* xms_file;
	xms_file = new byte[fsize];
	File_Open( filename, FILE_MODE_READ, 1 );
	File_ReadData( xms_file, fsize, 1 );
	File_Close( 1 );
	File_WriteData( xms_file, fsize, 0 );
	delete[] xms_file;
	if( xhead.lin )
	{
		xms_file = new byte[ 0x10100 - File_Tell( 0 ) ];
		File_WriteData( xms_file, 0x10100 - File_Tell( 0 ), 0 );
	}
	else
	{
		xms_file = new byte[ 0xF100 - File_Tell( 0 ) ];
		File_WriteData( xms_file, 0xF100 - File_Tell( 0 ), 0 );
		delete[] xms_file;
		fsize = File_Exists( "spx_aftf.bin" );
		if( fsize == -1 || fsize == 0 )
		{
			printf( "Missing \"spx_aftf.bin\"!" );
			File_Close( 0 );
			File_Kill( newfile );
			delete[] newfile;
			return;
		}
		File_Open( "spx_aftf.bin", FILE_MODE_READ, 1 );
		xms_file = new byte[4096];
		File_ReadData( xms_file, 4096, 1 );
		File_Close( 1 );
		File_WriteData( xms_file, 4096, 0 );
	}
	delete[] xms_file;
	if( !File_Exists( "dsp_snap.bin" ) )
	{
		printf( "Missing \"dsp_snap.bin\"!" );
		File_Close( 0 );
		File_Kill( newfile );
		delete[] newfile;
		return;
	}
	File_Open( "dsp_snap.bin", FILE_MODE_READ, 1 );
	File_ReadData( buffer, 256, 1 );
	File_Close( 1 );
	File_WriteData( buffer, 256, 0 );
	File_Close( 0 );
	
	delete[] newfile;
}

int EditSPC( char* filename, SPC_INFO* info, int flags )
{
	if( !File_Exists( filename ) )
		return 1;
	File_OpenW( filename, 0 );

	if( flags & SPCE_TITLE )
	{
		File_Seek( 0x2E, 0 );
		WriteString( info->title, 32 );
	}
	if( flags & SPCE_GAME )
	{
		File_Seek( 0x4E, 0 );
		WriteString( info->game, 32 );
	}
	if( flags & SPCE_COMMENTS )
	{
		File_Seek( 0x7E, 0 );
		WriteString( info->comments, 32 );
	}
	if( flags & SPCE_ARTIST )
	{
		File_Seek( 0xB1, 0 );
		WriteString( info->artist, 32 );
	}
	char strPut[8];
	if( flags & SPCE_SECONDS )
	{
		File_Seek( 0xA9, 0 );
		itoa( info->seconds, strPut, 10 );
		WriteString( strPut, 3 );
	}
	if( flags & SPCE_FADE )
	{
		File_Seek( 0xAC, 0 );
		itoa( info->fade, strPut, 10 );
		WriteString( strPut, 5 );
	}
	
	File_Close( 0 );
	return 0;
}

void WriteString( char* string, int length )
{
	int x = 0;
	while( x < length )
	{
		if( string[x] != 0 )
			File_WriteB( string[x], 0 );
		else
			break;
		x++;
	}
	while( x < length )
	{
		File_WriteB( 0, 0 );
		x++;
	}
}
