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

////////////////////////
// XM2SNES		      //
////////////////////////

// Usage:
// xm2snes [options] input [output]
// 
// Options		Description
// -4			4-bit sample mode :)
// -q			Cancel "Set Pan" for all instruments.
// -p<percent>	Initial panning separation.
// -m			Volume ramp ending of non-looping samples.
// -d			Discard XMS.
// -i			Ignore sample/instrument arguments.
// -b			Build SPC copy.
// -t"string"	  Set SPC title. 32 characters
// -a"string"	  Set SPC author. 32 characters.
// -g"string"	  Set SPC "game". 32 characters.
// -c"string"	  Set Comments. 32 characters.
// -s<value>	  Set SPC length in seconds.
// -f<value>	  Set SPC fade in milliseconds.

#define offset_orders 0x14
#define offset_volenv 24
#define offset_panenv 48

//const char STR_USAGE[] = "Usage:\nxm2snes [options] input.xm output.xms\nxm2snes -e [options] input.spc\n\nOptions       Description\n-b            Builds SPC copy of file\n-m            Volume ramp ending of non-looping samples.\n-e            Edit SPC.\n-t\"string\"      Sets SPC title. 32 characters\n-a\"string\"      Sets SPC author. 32 characters.\n-g\"string\"      Sets SPC \"game\". 32 characters.\n-c\"string\"      Sets Comments. 32 characters.\n-s<value>       Sets SPC length in seconds.\n-f<value>       Sets SPC fade in milliseconds.\n\n";
const char STR_USAGE[] = "Usage:\n\
xm2snes [options] input [output]\n\
\n\
Input can be mod/s3m/xm/xms/txt/spc.\n\
XMS as input will make spc file.\n\
TXT as input will be treated as package script.\n\
SPC as input can be used to change the header.\n\
\n\
Options       Description\n\
-4            4-bit mode :)\n\
-q            Cancel \"Set Pan\" for all instruments.\n\
-p            Initial panning separation.\n\
-m            Volume ramp ending of non-looping samples.\n\
-d            Discard XMS.\n\
-i            Ignore sample/instrument arguments.\n\
-b            Builds SPC copy of file\n\
-t\"string\"      Sets SPC title. 32 characters\n\
-a\"string\"      Sets SPC author. 32 characters.\n\
-g\"string\"      Sets SPC \"game\". 32 characters.\n\
-c\"string\"      Sets Comments. 32 characters.\n\
-s<value>       Sets SPC length in seconds.\n\
-f<value>       Sets SPC fade in milliseconds.\n\n";

#define SAFE_DELETE( var ) if( var != NULL ) delete[] var; var=NULL

#define CERROR_NONE			0x0
#define CERROR_NOSOURCE		0x1
#define CERROR_INVALIDXM	0x2
#define CERROR_TOOLONG		0x3
#define CERROR_CHANNELS		0x4
#define CERROR_TOOBIG		0x5

#define STR_SPACER "----------------------\n"

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <cstring>
#include <math.h>
#include <string>
#include <vector>

#include "mglobal.h"
XMS_HEAD xhead;					// header
XMS_PATTERN* xpatterns=NULL;	// patterns
XMS_SAMPLE xsamp[128];			// samples

XMS_SAMPLEDATA* allsamp;
XMS_INSTRUMENT* xinst=NULL;		// instruments
XMS_FILTER xfilters[13];		// filter settings

int samp_num;

int asamp_num;

int XMS_FILE_MAX;

#include "files.h"

#include "simpmath.h"
#include "samples.h"
#include "patterns.h"
#include "brr.h"
#include "spc.h"
#include "wav.h"

// Program arguments
bool		arg_buildspc;
bool		arg_editspc;
bool		arg_m;
bool		arg_4bit;
bool		arg_i;
bool		arg_cpan;
SPC_INFO	arg_spci;
int			arg_spcf;
int			arg_unroll;
double		arg_pansep=0.5;		// 0.0-1.0 panning separation, 50% = default
bool		arg_discard;

int			arg_ctype;

char*		soutput_file=NULL;

int LoadXM( char* file_in );
int LoadMOD( char* file_in );
int LoadS3M( char* file_in );
void LoadXMB( char* file, int findex );
int WriteXMS( char* file_out, bool rawmode );
int BuildPackage( char* fscript );

void LoadSample( char* file );

void CompressSamples( void );
void CompressSample( XMS_SAMPLE* samp, int index, XMS_HEAD* xhead );

void LoadSong( char* filename );
void Init( void );
void Cleanup( void );
void BigCleanup( void );

int AddSamples( void );
void AddSample( XMS_SAMPLE* samp );
void CFixSample( XMS_SAMPLE* samp, int index, bool disp );

inline int Clamp16( int v );
inline int Clamp8( int v );

inline int Unsigned8( int v );
inline int Signed8( int v );

inline int hexnum( char c );

int main(int argc, char *argv[])
{
	if( argc == 1 )
	{
		printf( STR_USAGE );
		return 0;
	}
	// Get input from user
	int x;
	int input_file=0;
	int output_file=0;
	
	memset( &arg_spci, 0, sizeof( SPC_INFO ) );
	arg_spci.seconds = 180;
	arg_spci.fade = 5000;
	arg_spcf = 0;
	arg_buildspc	=false;
	arg_editspc		=false;
	arg_m			=false;
	arg_i			=false;
	arg_cpan		=false;
	arg_4bit		=false;
	arg_discard		=false;
	arg_unroll		=0;
	for( x = 1; x < argc; x++ )
	{
		if( argv[x][0] == '-' )
		{
			switch( argv[x][1] )
			{
			case 'b':
				arg_buildspc = true;
				break;
			case 'e':
				arg_editspc = true;
				break;
			case 'm':
				arg_m = true;
				break;
			case 'q':
				arg_cpan = true;
				break;
			case 'p':
				arg_pansep = (double)atoi( &argv[x][2] ) / 100;
				if( arg_pansep < 0 ) arg_pansep = 0;
				if( arg_pansep > 1 ) arg_pansep = 1;
				break;
			case '4':
				arg_4bit = true;
				break;
			case 'i':
				arg_i = true;
				break;
			case 'd':
				arg_discard = true;
			case 't':
				strcpy( arg_spci.title, &argv[x][2] );
				arg_spcf |= SPCE_TITLE;
				break;
			case 'a':
				strcpy( arg_spci.artist, &argv[x][2] );
				arg_spcf |= SPCE_ARTIST;
				break;
			case 'g':
				strcpy( arg_spci.game, &argv[x][2] );
				arg_spcf |= SPCE_GAME;
				break;
			case 'c':
				strcpy( arg_spci.comments, &argv[x][2] );
				arg_spcf |= SPCE_COMMENTS;
				break;
			case 's':
				arg_spci.seconds = atoi( &argv[x][2] );
				arg_spcf |= SPCE_SECONDS;
				break;
			case 'f':
				arg_spci.fade = atoi( &argv[x][2] );
				arg_spcf |= SPCE_FADE;
			case 'u':
				arg_unroll = atoi( &argv[x][2] );
				break;
			}
		}
		else
		{
			if( input_file == 0 )
			{
				input_file = x;
			}
			else if( output_file == 0 )
			{
				output_file = x;
			}
		}
	}
	if( input_file == 0 )
	{
		printf( "No source file!\n" );
		Cleanup();
		return 0;
	}
	arg_ctype = GetExt( argv[input_file] );
	int sl;
	if( output_file == 0 )
	{
		sl = strlen( argv[input_file] );
		soutput_file = new char[ sl + 1 ];
		memcpy( soutput_file, argv[input_file], sl );
		soutput_file[sl] = 0;
		SetExt( &soutput_file, "xms" );
	}
	else
	{
		sl = strlen( argv[output_file] );
		soutput_file = new char[ sl+1 ];
		memcpy( soutput_file, argv[output_file], sl );
		soutput_file[sl] = 0;
	}
	
	// clear samp data
	for( x = 0; x < 60; x++ )
		xsamp[x].samp_data = NULL;
	
	int cyn;
	if( !arg_editspc )
	{
		if( !File_Exists( argv[input_file] ) )
		{
			printf( "No source file!\n" );
			Cleanup();
			return 0;
		}
		Init();
		if( arg_ctype != EXT_XMS )
		{
			if( File_Exists( soutput_file ) )
			{
				cyn = 0;
				while( tolower(cyn) != 'y' && tolower(cyn) != 'n' )
				{
					printf( "Output file exists, overwrite? (y/n) " );
					cyn = getchar();
					while( getchar() != '\n' );
					//printf( "\n" );
				}
				if( tolower(cyn) == 'n' )
				{
					printf( "Operation canceled.\n" );
					Cleanup();
					return 0;
				}
			}
			int err;
			
			xhead.nfilters=0;
			switch( arg_ctype )
			{
			case EXT_XM:
				err = LoadXM( argv[input_file] );
				break;
			case EXT_MOD:
				err = LoadMOD( argv[input_file] );
				break; 
			case EXT_S3M:
				err = LoadS3M( argv[input_file] );
				break;
			case EXT_TXT:
				err = BuildPackage( argv[input_file] );
				BigCleanup();
				return 0;
				break;
			default:
				printf( "Unknown input format!\n" );
				err = CERROR_INVALIDXM;
			}
			
			if( err == CERROR_NONE )
			{
				err = WriteXMS( soutput_file, false );
			}
			if( arg_buildspc && err == CERROR_NONE )
			{
				BuildSPC( soutput_file, &arg_spci );
			}
			else if( err != CERROR_NONE )
			{
				File_Kill( soutput_file );
			}
			
			if( arg_discard )
			{
				File_Kill( soutput_file );
			}
		}
		else
		{
			BuildSPC( argv[input_file], &arg_spci );
		}
		Cleanup();
	}
	else
	{
		if( arg_spcf != 0 )
		{
			if( EditSPC( argv[input_file], &arg_spci, arg_spcf ) )
			{
				printf( "File not found!\n" );
			}
			else
			{
				printf( "Done.\n" );
			}
		}
		else
		{
			printf( "No flags specified!\n" );
		}
		Cleanup();
	}
	
	return 0;
}

int BuildPackage( char* fscript )
{
	std::vector<char*>file_list;
	char* f_entry;
	XMP_HEAD xphead;
	xphead.nsongs =0;
	xphead.nsamps=0;
	xphead.song_adr = NULL;
	xphead.samp_adr = NULL;
	memset( xphead.desc, 0, 13 );

	int slen;
	slen = File_Exists( fscript );
	if( slen == 0 || slen == -1 )
		return CERROR_NOSOURCE;
	File_Open( fscript, FILE_MODE_READ, 1 );
	// parse
	int a;
	int b;
	char c;
	std::string str;
	std::string sOut;
	
	int ssize=0;
	bool nextline=false;
	int mode=0;
	int submode=0;
	for( a = 0; a < slen; a++ )
	{
		c = File_ReadB( 1 );
		if( c == '#' ) nextline = true;
		if( c == 13  ) nextline = true;
		if( c == 9   ) nextline = true;
		if( c != '\n' )
		{
			if( !nextline )
			{
				str.append( 1, c );
			}
		}
		else if( c == '\n' )
		{
			nextline = false;
			// process
			
			if( str.compare( "/songs" ) == 0 )
				mode = 1;
			else if( str.compare( "/samples" ) == 0 )
				mode = 2;
			else if( str.compare( "/output" ) == 0 )
				mode = 3;
			else
			{
				switch( mode )
				{
				case 0:
					if( (b=str.find( '=', 0 )) != -1 )
					{
						std::string s1;
						std::string s2;
						s1 = str.substr( 0, b );
						s2 = str.substr( b+1 );
						s2.resize( 12, 0 );
						if( s1.compare( "desc" ) == 0 )
						{
							s2.copy( xphead.desc, 12 );
						}
					}
					break;
				case 1:
					// add song
					if( str.size() != 0 )
					{
						LoadSong( (char*)str.c_str() );
						f_entry = new char[str.length()];
						str.copy( f_entry, str.length() );
						SetExt( &f_entry, "xmr" );
						file_list.push_back( f_entry );
						CompressSamples();
						AddSamples();
						WriteXMS( f_entry, true );
					}
					break;
				case 2:
					// add sample
					LoadSample( (char*)str.data() );
					break;
				case 3:
					// set output
					sOut = str;
					break;
				}
			}
			str.erase();
		}
		
		
	}

	File_Close( 1 );
	// cluster songs
	byte* song_data;
	byte* song_data2;
	int song_datal=0;
	int nsongs = file_list.size();
	u32 song_off = 0x10 + (3*nsongs) + (3*asamp_num);
	
	u32* song_offsets;
	song_offsets = new u32[nsongs];
	
	for( a = 0; a < nsongs; a++ )
	{
		song_offsets[a] = song_datal + song_off;
		b = File_Exists( file_list[a] );
		File_Open( file_list[a], FILE_MODE_READ, 1 );
		song_data2 = new byte[ song_datal + b ];
		
		if( song_datal != 0 )
		{
			memcpy( song_data2, song_data, song_datal );
			delete[] song_data;
		}
		File_ReadData( song_data2+song_datal, b, 1 );
		File_Close( 1 );
		song_datal += b;
		delete[] file_list[a];
		song_data = song_data2;
	}
	u32* samp_offsets;
	samp_offsets = new u32[asamp_num];
	b = song_datal + song_off;
	for( a = 0; a < asamp_num; a++ )
	{
		samp_offsets[a] = b;
		b += allsamp[a].clength + 6;				/// 6 = xmb header size
	}
	File_Open( (char*)sOut.c_str(), FILE_MODE_WRITE, 1 );
	File_WriteW( nsongs, 1 );
	File_WriteW( asamp_num, 1 );
	File_WriteW( (0x10 + nsongs*3), 1 );
	File_WriteData( xphead.desc, 10, 1 );
	for( a = 0; a < nsongs; a++ )
	{
		File_WriteB( song_offsets[a] & 0xFF, 1 );
		File_WriteB( (song_offsets[a]>>8) & 0x7F, 1 );
		File_WriteB( (song_offsets[a]>>15) & 0xFF, 1 );
	}
	for( a = 0; a < asamp_num; a++ )
	{
		File_WriteB( samp_offsets[a] & 0xFF, 1 );
		File_WriteB( (samp_offsets[a]>>8) & 0x7F, 1 );
		File_WriteB( (samp_offsets[a]>>15) & 0xFF, 1 );
	}
	File_WriteData( song_data, song_datal, 1 );
	printf( "SAMPLE LIST:\n");
	for( a = 0; a < asamp_num; a++ )
	{
		printf( "%i: %s\n", a, allsamp[a].sname );
		File_WriteW( ((allsamp[a].clength+6)/3), 1 );
		if( allsamp[a].loop_type )
			File_WriteW( (allsamp[a].loop_start/16)*9, 1 );
		else
			File_WriteW( 0xFFFF, 1 );
		File_WriteB( XMB_VERSION, 1 );
//		File_WriteW( 0, 1 );
		File_WriteB( 0, 1 );
		File_WriteData( allsamp[a].comp_data, allsamp[a].clength, 1 );
	}
	File_Close( 1 );
	delete[] song_data;
	delete[] song_offsets;
	delete[] samp_offsets;
	
	return 0;
}

void LoadXMB( char* file, int findex )
{
	File_Open( file, FILE_MODE_READ, findex );
	XMS_SAMPLE s;
	strcpy( s.sname, file );
	s.clength = File_ReadW( findex );
	s.loop_start = File_ReadW( findex );
	s.loop_type = s.loop_start == 0xFFFF ? 0 : 1 ;
	File_Skip( 4, findex );
	s.comp_data = new byte[s.clength];
	File_ReadData( s.comp_data, s.clength, findex );
	File_Close( findex );
	AddSample( &s );
	delete[] s.comp_data;
}

void LoadSample( char* file )
{
	if( GetExt( file ) == 'xmb' )
	{
		LoadXMB( file, 2 );
	}
	if( GetExt( file ) == 'wav' )
	{
		XMS_SAMPLE s;
		memset( (void*)&s, 0, sizeof( XMS_SAMPLE ) );
		LoadWAV( file, &s, 2 );
		strcpy( s.sname, file );
		CompressSample( &s, 0, NULL );
		AddSample( &s );
	}
}

void CompressSamples( void )
{
	int x;
//	byte* fb=NULL;
//	int b;
//	double sampamp;
//	sampamp=1.0;
//	cstatus comp_results;
	for( x = 0; x < xhead.smp; x++ )
	{
		CompressSample( &xsamp[x], x, &xhead );
//		b = ((xsamp[x].length + 15) / 16) * 9;
//		xsamp[x].clength = b;
//		if( b != 0 )
//		{
//			SAFE_DELETE( xsamp[x].comp_data );
//			xsamp[x].comp_data = new byte[b];
//			while( BRR_AutoFilter( &xsamp[x], xsamp[x].comp_data, 0, &xhead, x, xsamp[x].filter, &comp_results, sampamp ) != 0 )
//				sampamp -= 0.05;
//			
//		}
	}
}

void CompressSample( XMS_SAMPLE* samp, int index, XMS_HEAD* xhead )
{
	byte* fb=NULL;
	int b;
	cstatus comp_results;
	double sampamp=1.0;

	b = ((samp->length + 15) / 16) * 9;
	samp->clength = b;
	if( b != 0 )
	{
		SAFE_DELETE( samp->comp_data );
		samp->comp_data = new byte[b];
		while( BRR_AutoFilter( samp, samp->comp_data, 0, xhead, index, 4, &comp_results, sampamp ) != 0 )
			sampamp -= 0.05;
	}
}

void LoadSong( char* filename )
{
	Cleanup();
	int a = GetExt( filename );
	switch( a )
	{
	case EXT_MOD:
		LoadMOD( filename );
		break;
	case EXT_S3M:
		LoadS3M( filename );
		break;
	case EXT_XM:
		LoadXM( filename );
	}
}

void DupCheck( int p )
{
	bool dup_check=false;
	int dup_num=0;
	int c,d;
	for( c = 0; c < p; c++ )
	{
		dup_num = c;
		dup_check = true;
		if( xsamp[c].length > 0 )
		{
			if( xsamp[c].length == xsamp[p].length )
			{
				for( d = 0; d < xsamp[c].length; d++ )
				{
					if( xsamp[c].samp_data[d] != xsamp[p].samp_data[d] )
					{
						dup_check = false;
						break;
					}
				}
			}
			else
			{
				dup_check = false;
			}
		}
		else
		{
			dup_check = false;
		}
		if( dup_check )
			break;
	}
	if( dup_check )
	{
		xsamp[p].duplicate = dup_num + 1;
	}
	else
	{
		xsamp[p].duplicate = 0;
	}
}

void FIRScan( char* str )
{
	int b;
//	printf( "\n" );
//	printf( "Scanning for FIR kernels\n" );
	byte filt_c;
	double filt_v;
	if( str[0] == '>' && strlen( str ) == 22 )
	{
		if( xhead.nfilters < 13 )
		{
			printf( "FKERNEL/%i: ", xhead.nfilters );
			memcpy( xfilters[xhead.nfilters].code, str, 22 );
			xfilters[xhead.nfilters].code[22] = 0;
			filt_c = xfilters[xhead.nfilters].code[1];
			if( filt_c >= 32 && filt_c <= 79 )
				filt_v = roundf( (127.0/47.0) * (double)(filt_c - 32) );
			else if( filt_c >= 80 && filt_c <= 126 )
				filt_v = -roundf( (128.0/46.0) * (double)(filt_c - 80) );
			else
				filt_v = 0;
			printf( "%i, ", (int)filt_v );
			if( filt_v < 0 ) filt_v += 256;
			xfilters[xhead.nfilters].binary[0] = (int)filt_v;
			
			filt_c = xfilters[xhead.nfilters].code[2];
			if( filt_c >= 32 && filt_c <= 79 )
				filt_v = roundf( (127.0/47.0) * (double)(filt_c - 32) );
			else if( filt_c >= 80 && filt_c <= 126 )
				filt_v = -roundf( (128.0/46.0) * (double)(filt_c - 80) );
			else
				filt_v = 0;
			printf( "%i / ", (int)filt_v );
			if( filt_v < 0 ) filt_v += 256;
			xfilters[xhead.nfilters].binary[1] = (int)filt_v;
			
			for( b = 0; b < 8; b++ )
			{
				filt_c = hexnum( xfilters[xhead.nfilters].code[ 3 + b*2 ] ) * 16
 					+hexnum( xfilters[xhead.nfilters].code[ 3 + b*2 +1 ] );
				xfilters[xhead.nfilters].binary[2 + b] = filt_c;
				if( b < 7 )
					printf( "%i,", filt_c );
				else
					printf( "%i / ", filt_c );
			}
			
			xfilters[xhead.nfilters].binary[10] = hexnum( xfilters[xhead.nfilters].code[19] );
			xfilters[xhead.nfilters].binary[11] = hexnum( xfilters[xhead.nfilters].code[20] )*16 + hexnum( xfilters[xhead.nfilters].code[21] ) ;
			printf( "%ims, %i\n", xfilters[xhead.nfilters].binary[10] * 16, xfilters[xhead.nfilters].binary[11] );
			xhead.nfilters++;
		}
		else
		{
			//printf( "Extra filter(s) skipped\n" );
			printf( "Extra filter skipped\n" );
		}
	}
}

int WritePatternData( byte* data, int note, int samp, int vfx, int fx, int param )
{
	int w;
	data[0] = 0;
	if( note && samp && vfx && fx && param )
	{
		data[0] = note;
		data[1] = samp;
		data[2] = vfx;
		data[3] = fx;
		data[4] = param;
		return 5;
	}
	else
	{
		w = 1;
		data[0] = 128;
		if( note )
		{
			data[w] = note; w++;
			data[0] |= 1;
		}
		if( samp )
		{
			data[w] = samp; w++;
			data[0] |= 2;
		}
		if( vfx )
		{
			data[w] = vfx; w++;
			data[0] |= 4;
		}
		if( fx )
		{
			data[w] = fx; w++;
			data[0] |= 8;
		}
		if( param )
		{
			data[w] = param; w++;
			data[0] |= 16;
		}
		return w;
	}
	
}

int LoadMOD( char* file_in )
{
	int a;
	if( !(a = File_Exists( file_in )) )
	{
		printf( "No source file!\n" );
		return CERROR_NOSOURCE;
	}
	printf( "Starting MOD Conversion... " );
	printf( "Old Size: %i\n", a );
	
	xhead.PN[0] = 128 - ((int)roundf(128.0 * arg_pansep));
	xhead.PN[1] = 128 + ((int)roundf(127.0 * arg_pansep));
	xhead.PN[2] = 128 + ((int)roundf(127.0 * arg_pansep));
	xhead.PN[3] = 128 - ((int)roundf(128.0 * arg_pansep));
	xhead.PN[4] = 128 - ((int)roundf(128.0 * arg_pansep));
	xhead.PN[5] = 128 + ((int)roundf(127.0 * arg_pansep));
	xhead.PN[6] = 128 + ((int)roundf(127.0 * arg_pansep));
	xhead.PN[7] = 128 - ((int)roundf(128.0 * arg_pansep));

	xhead.spd = 6;
	xhead.bpm = 125;
	xhead.lin = 0;
	XMS_FILE_MAX = XMS_FILE_MAXA;
	xhead.restart = 0;
	
	File_Open( file_in, FILE_MODE_READ, 0 );
	File_Seek( 0x438, 0 );
	char mod_sig[5]={0};
	File_ReadData( mod_sig, 4, 0 );
	if( strcmp( mod_sig, "M.K." ) == 0 )
		xhead.chn = 4;
	else if( strcmp( mod_sig, "6CHN" ) == 0 )
		xhead.chn = 6;
	else if( strcmp( mod_sig, "8CHN" ) == 0 )
		xhead.chn = 8;
	else
	{
		printf( "Unknown MOD format.\n" );
		return CERROR_INVALIDXM;
	}
	File_Seek( 0, 0 );
	File_Skip( 20, 0 );
	
	int x, y;
	int samp_lastused=-1;
	for( x = 0; x < 31; x++ )
	{
		File_ReadData( xsamp[x].sname, 22, 0 );
		xsamp[x].sname[22] = 0;
		FIRScan( xsamp[x].sname );
		xsamp[x].length = (File_ReadB( 0 ) << 8);
		xsamp[x].length += File_ReadB( 0 );
		xsamp[x].length <<= 1;
		if( xsamp[x].length != 0 )
		{
			samp_lastused = x;
		}
		xsamp[x].rel_note = 0;
		a = File_ReadB( 0 );
		a *= 16;
		xsamp[x].finetune = a;
		xsamp[x].volume = File_ReadB( 0 );
		xsamp[x].loop_start = (File_ReadB( 0 ) << 8 );
		xsamp[x].loop_start += (File_ReadB( 0 ));
		xsamp[x].loop_start <<= 1;
		xsamp[x].loop_length = (File_ReadB( 0 ) << 8 );
		xsamp[x].loop_length += (File_ReadB( 0 ));
		xsamp[x].loop_length <<= 1;
		if( xsamp[x].loop_length > 2 )
			xsamp[x].loop_type = 1;
		else
			xsamp[x].loop_type = 0;
		xsamp[x].duplicate = 0;
		xsamp[x].bit16 = false;
		xsamp[x].setpan = 0;
		xsamp[x].panning = 128;
		SampScanOptions( &xsamp[x] );
	}
	xhead.smp = samp_lastused+1;
	xhead.length = File_ReadB( 0 );
	File_ReadB( 0 );
	xhead.orders = new byte[ xhead.length ];
	xhead.pat = 1;
	for( x = 0; x < 128; x++ )
	{
		if( x < xhead.length )
		{
			xhead.orders[x] = File_ReadB( 0 );
			if( xhead.orders[x] > xhead.pat - 1 )
			{
				xhead.pat = xhead.orders[x] + 1;
			}
		}
		else
		{
			File_ReadB( 0 );
		}
	}
	
	File_ReadD( 0 ); // skip mod signature
	xpatterns = new XMS_PATTERN[xhead.pat];
	int pat_note;
	int pat_period;
	int pat_samp;
	int pat_fx;
	int pat_param;
	int pat_write;
	for( x = 0; x < xhead.pat; x++ )
	{
		memset( xpatterns[x].row_marks, 0, 256 );
		xpatterns[x].nrows = 64;
		xpatterns[x].data_size = (xhead.chn * 64) * 5; // samp, note, effect, param
		xpatterns[x].data = new byte[ xpatterns[x].data_size ];
		pat_write = 0;
		for( y = 0; y < 64*xhead.chn; y++ )
		{
			File_ReadB( 0 );
			pat_samp = (file_byte & 0xF0);
			pat_period = (file_byte & 0xF) << 8;
			File_ReadB( 0 );
			pat_period |= file_byte;
			File_ReadB( 0 );
			pat_samp |= file_byte >> 4;
			pat_fx = file_byte & 0xF;
			pat_param = File_ReadB( 0 );
			if( pat_period )
			{
				pat_note = (int)roundf(12.0*log( (856.0)/(double)pat_period )/log(2)) + 37; // edit note offset
			}
			else
			{
				pat_note = 0;
			}
			pat_write += WritePatternData( xpatterns[x].data + pat_write, pat_note, pat_samp, 0, pat_fx, pat_param );
		}
	}
	xhead.ins = 1;
	for( x = 0; x < xhead.smp; x++ )
	{
		if( xsamp[x].length > 0 )
		{
			xhead.ins = x + 1;
			xsamp[x].samp_data = new int[xsamp[x].length];
			for( y = 0; y < xsamp[x].length; y++ )
			{
				a = File_ReadB( 0 );
				if( a >= 128 ) a -= 256;
				a *= 256;
				xsamp[x].samp_data[y] = a;
			}
			CFixSample( &xsamp[x], x, true );
			DupCheck( x );
		}
	}
	xinst = new XMS_INSTRUMENT[xhead.ins];
	for( x = 0; x < xhead.ins; x++ )
	{
		// maek basic instrument
		memset( (void*)&xinst[x], 0, sizeof( XMS_INSTRUMENT ) );
		memcpy( xinst[x].sName, xsamp[x].sname, 22 );
		xinst[x].nsamps = 1;
		xinst[x].note_map[0] = x;
	}
	
	pr_channels = xhead.chn;
	
	for( x = 0; x < xhead.pat; x++ )
	{
		printf( STR_SPACER );
		printf( "Fixing pattern %i...\n", x );
		FixPattern( x );
	}
	printf( STR_SPACER );
	printf( "Finalizing patterns...\n" );
	for( x = 0; x < xhead.pat; x++ )
		FixPattern2( x );
//	FIRScan();
	File_Close( 0 );
	return CERROR_NONE;
}

void TranslateS3M( int* pFX, int* pPA, int fx, int pa )
{
	*pPA = pa;	// alot of parameters are the same
	switch( fx )
	{
	case 0:
	case 255:
		*pFX = 0;
		*pPA = 0;
		break;
	case 1:  // Axx Set Speed
		*pFX = 0xF;
		if( pa > 31 )
			pa = 31;
		*pPA = pa;
		break;
	case 2:  // Bxx Pattern Jump
		*pFX = 0xB;
		break;
	case 3:  // Cxx Pattern Break
		*pFX = 0xD;
		// ARE PATTERN BREAK PARAMETERS DECIMAL???
		break;
	case 4:  // Dxy Volume Slide
		*pFX = 0xA;
		if( (pa & 0xF0) && (pa & 0x0F) )
		{
			// both params are set
			if( (pa & 0xF0) == 0xF0 ) // fine volslide down
			{
				*pFX = 0xE;
				*pPA = 0xB0 | (pa & 0xF);
			}
			else if( (pa & 0xF) == 0xF ) // fine volslide up
			{
				*pFX = 0xE;
				*pPA = 0xA0 | ((pa >> 4) & 0xF);
			}
		}
		break;
	case 5:  // Exx Porta Down
		*pFX = 0x2;
		if( (pa & 0xF0) == 0xF0 )
		{
			*pFX = 0xE;
			*pPA = 0x20 | (pa & 0xF);
		}
		else if( (pa & 0xF0) == 0xE0 )
		{
			*pFX = 0x21;
			*pPA = 0x20 | (pa & 0xF);
		}
		break;
	case 6:  // Fxx Porta Up
		*pFX = 0x1;
		if( (pa & 0xF0) == 0xF0 )
		{
			*pFX = 0xE;
			*pPA = 0x10 | (pa & 0xF);
		}
		else if( (pa & 0xF0) == 0xE0 )
		{
			*pFX = 0x21;
			*pPA = 0x10 | (pa & 0xF);
		}
		break;
	case 7:  // Gxx Glissando
		*pFX = 0x3;
		break;
	case 8:  // Hxy Vibrato
		*pFX = 0x4;
		break;
	case 9:  // Ixy Tremor
		*pFX = 0x1D;
		break;
	case 10:  // Jxy Arpeggio
		*pFX = 0x0;
		break;
	case 11: // Kxy VolSlide+Vibrato
		*pFX = 0x6;
		if( (pa & 0xF0) && (pa & 0x0F) )
		{
			// both params are set :|
			if( (pa & 0xF0) == 0xF0 ) // fine volslide down
			{
				*pPA = 0;
			}
			else if( (pa & 0xF) == 0xF ) // fine volslide up
			{
				*pPA = 0;
			}
		}
		break;
	case 12: // Lxy VolSlide+Glissando
		*pFX = 0x5;
		if( (pa & 0xF0) && (pa & 0x0F) )
		{
			// both params are set :|
			if( (pa & 0xF0) == 0xF0 ) // fine volslide down
			{
				*pPA = 0;
			}
			else if( (pa & 0xF) == 0xF ) // fine volslide up
			{
				*pPA = 0;
			}
		}
		break;
	case 13: // Mxx Channel Volume (NOT IMPLEMENTED)
	case 14: // Nxy Channel Volslide (NOT IMPLEMENTED)
		*pFX = 0x0;
		*pPA = 0x0;
		break;
	case 15: // Oxx Sample Offset
		*pFX = 0x9;
		break;
	case 16: // Pxy Panning Slide
		*pFX = 0x19;
		break;
	case 17: // Qxy Retrigger Note
		*pFX = 0x1B;
		break;
	case 18: // Rxy Tremolo
		*pFX = 0x7;
		break;
	case 19: // Sxy Extra Effects
		*pFX = 0xE;
		switch( pa & 0xF0 )
		{
		case 0x00: // set filter
			break;
		case 0x10: // glissando control
		case 0x20: // set finetune
		case 0x50: // Panbrello waveform
		case 0x60: // Fine pattern delay
		case 0x70: // Unused
		case 0x90: // Sound control
		case 0xA0: // set high offset
			*pFX = 0; // unimplemented
			*pPA = 0;
			break;
		case 0x30: // Vibrato waveform
			*pPA = 0x40 | (pa & 0xF);
			break;
		case 0x40: // Tremolo waveform
			*pPA = 0x70 | (pa & 0xF);
			break;
		case 0x80: // set panning
			break;
		case 0xB0: // pattern loop
			*pPA = 0x60 | (pa & 0xF);
			break;
		case 0xC0: // Note Cut
		case 0xD0: // Note Delay
		case 0xE0: // Pattern Delay
		case 0xF0: // Message SNES
			break;
		}
		break;
	case 20: // Txx Set Tempo
		if( pa >= 32 )
		{
			*pFX = 0xF;
		}
		else
		{
			// tempo slides not supported :(
			*pFX = 0x00;
			*pPA = 0x00;
		}
		break;
	case 21: // Uxy Fine Vibrato
		*pFX = 0; // TODO
		*pPA = 0;
		break;
	case 22: // Vxx Global Volume
		*pFX = 0x10;
		break;
	case 23: // Wxy Unused
		break;
	case 24: // Xxx Set Panning
		*pFX = 0x8;
		break;
	case 25: // Yxy Panbrello (not implemented)
	case 26: // Zxx Unused
		*pFX = 0x0;
		*pPA = 0x0;
	}
}

int LoadS3M( char* file_in )
{
	int a, b;
	int ffi;
	int panning_mode; // 0 == mono, 1 == gravis, 2 == sbpro
	if( !(a = File_Exists( file_in )) )
	{
		printf( "No source file!\n" );
		return CERROR_NOSOURCE;
	}
	printf( "Starting S3M Conversion... " );
	printf( "Old Size: %i\n", a );
	File_Open( file_in, FILE_MODE_READ, 0 );
	File_Skip( 28, 0 );
	if( File_ReadB( 0 ) != 0x1A )
	{
		printf( "Unknown format!\n" );
		return CERROR_INVALIDXM;
	}
	if( File_ReadB( 0 ) != 16 )
	{
		printf( "Unknown format!\n" );
		return CERROR_INVALIDXM;
	}
	File_Skip( 2, 0 );
	
	xhead.lin = 1;										/////////////////////////////////////////
	XMS_FILE_MAX = XMS_FILE_MAXA;

	xhead.length = (byte)File_ReadW( 0 );
	xhead.smp = (byte)File_ReadW( 0 );
	xhead.pat = (byte)File_ReadW( 0 );
	
	
	File_Skip( 2, 0 ); // old flags
	File_Skip( 2, 0 ); // tracker version
	ffi = File_ReadW( 0 );
	if( File_ReadD( 0 ) != 0x4D524353 )
	{
		printf( "Unknown format!\n" );
		return CERROR_INVALIDXM;
	}
	File_ReadB( 0 );						// global volume! add byte in xms format!
	xhead.spd = File_ReadB( 0 );
	xhead.bpm = File_ReadB( 0 );
	if( File_ReadB( 0 ) & 0x80 )			// mono / stereo
	{
		panning_mode = 2;
	}
	else
	{
		panning_mode = 0;
	}
	File_ReadB( 0 );						// ultra click removal ??
	if( File_ReadB( 0 ) == 252 && (panning_mode != 0) )
		panning_mode = 1;
	File_Skip( 8, 0 );						// reserved
	File_ReadW( 0 );						// pointer to special custom data (non-standard)
	
	int x, y ;
	bool channels_over=false;
	for( x = 0; x < 32; x++ )
	{
		File_ReadB( 0 );
		if( file_byte != 255 && x >= 8 )
		{
			channels_over = true;
		}
		else if( file_byte != 255 && x < 8 )
		{
			xhead.chn = x+1;
		}
		if( x < 8 )
		{
			if( file_byte < 8 )
				xhead.PN[x] = Unsigned8(Clamp8((int)roundf(-128.0 * arg_pansep)));
			else if( file_byte < 16 )
				xhead.PN[x] = Unsigned8(Clamp8((int)roundf( 127.0 * arg_pansep)));
			else
				xhead.PN[x] = 128;
		}
	}
	if( channels_over )
	{
		printf( "S3M contains more than 8 channels, some channels will be ignored.\n" );
	}
	xhead.orders = new byte[xhead.length];
	for( x = 0; x < xhead.length; x++ )
	{
		if( File_ReadB( 0 ) != 255 )
		{
			xhead.orders[x] = file_byte;
		}
		else
		{
			x++;
			a = x;
			break;
		}
	}
	for( ; x < xhead.length; x++ )
		File_ReadB( 0 );
	xhead.length = a;
	int* p_inst=NULL;
	int* p_patt=NULL;
	p_inst = new int[xhead.smp];
	p_patt = new int[xhead.pat];
	for( x = 0; x < xhead.smp; x++ )
		p_inst[x] = File_ReadW( 0 ) * 16;
	for( x = 0; x < xhead.pat; x++ )
		p_patt[x] = File_ReadW( 0 ) * 16;
	if( panning_mode == 1 )
	{
		for( x = 0; x < 8; x++ )
		{
			File_ReadB( 0 );
			if( file_byte & (1<<5) )
			{
				
				xhead.PN[x] = (file_byte & 0xF) << 4;
			}
		}
	}
	// load sample headers
	int p_sampmem;
	int samp_lastused=-1;
	for( x = 0; x < xhead.smp; x++ )
	{
		File_Seek( p_inst[x], 0 );
		File_ReadB( 0 );			// instrument type
		File_Skip( 12, 0 );			// dos filename
		a = File_ReadB( 0 ) << 16;	// sampledata pointer
		a |= File_ReadW( 0 );
		p_sampmem = a*16;
		xsamp[x].length = File_ReadD( 0 );
		if( xsamp[x].length != 0 )
		{
			samp_lastused = x;
		}
		xsamp[x].loop_start = File_ReadD( 0 );
		xsamp[x].loop_length = File_ReadD( 0 ) - xsamp[x].loop_start;
		xsamp[x].volume = File_ReadB( 0 );
		File_ReadB( 0 );	// reserved
		File_ReadB( 0 );	// packing method (not used by st3.01)
		File_ReadB( 0 );	// flags
		if( file_byte & 1 )
			xsamp[x].loop_type = 1;
		else
			xsamp[x].loop_type = 0;
//		if( file_byte & 2 )	stereo (not supported)
		if( file_byte & 4 )
			xsamp[x].bit16 = true;
		else
			xsamp[x].bit16 = false;
		CsFreq( &a, &b, File_ReadD( 0 ) ); // get frequency, convert to native
		xsamp[x].rel_note = a;
		xsamp[x].finetune = b;
		xsamp[x].setpan = 0;
		File_ReadD( 0 ); // reserved
		File_ReadW( 0 ); // internal, GP
		File_ReadW( 0 ); // internal, 512
		File_ReadD( 0 ); // internal, last used..
		File_ReadData( xsamp[x].sname, 22, 0 ); xsamp[x].sname[22] = 0;
		FIRScan( xsamp[x].sname );
		File_Skip( 6, 0 ); // skip extra 6 characters
		File_Skip( 4, 0 ); // validation
		SampScanOptions( &xsamp[x] );
		// load sample data
		File_Seek( p_sampmem, 0 );
		xsamp[x].samp_data = new int[xsamp[x].length];
		for( y = 0; y < xsamp[x].length; y++ )
		{
			if( ffi == 2 )	// unsigned
			{
				if( xsamp[x].bit16 )
				{
					a = File_ReadW( 0 );
					a -= 32768;
				}
				else
				{
					a = File_ReadB( 0 ) - 128;
					a *= 256;
				}
			}
			else if( ffi == 1 )	// signed (rare)
			{
				if( xsamp[x].bit16 )
				{
					a = File_ReadW( 0 );
					if( a >= 32768 ) 
						a -= 65536;
				}
				else
				{
					a = File_ReadB( 0 );
					if( a >= 128 ) a -= 256;
					a *= 256;
				}
			}
			xsamp[x].samp_data[y] = a;
		}
		CFixSample( &xsamp[x], x, true );
		DupCheck( x );
	}

	xhead.smp = samp_lastused+1;
	SAFE_DELETE( p_inst );
	// load pattern data
	xpatterns = new XMS_PATTERN[xhead.pat];
	int spat_row;
	int spat_chan;
	
	int spat_note[8]={255,255,255,255,255,255,255,255}; // buffer all data :(
	int spat_inst[8]={0,0,0,0,0,0,0,0};
	int spat_vol[8]={255,255,255,255,255,255,255,255};
	int spat_fx[8]={255,255,255,255,255,255,255,255};
	int spat_param[8]={0,0,0,0,0,0,0,0};
	int pat_write;
	for( x = 0; x < xhead.pat; x++ )
	{
		File_Seek( p_patt[x], 0 );
		File_Skip( 2, 0 );
		memset( xpatterns[x].row_marks, 0, 256 );
		xpatterns[x].nrows = 64;
		xpatterns[x].data_size = 64*xhead.chn*6;
		xpatterns[x].data = new byte[xpatterns[x].data_size];
		spat_row = 0;
		spat_chan = 0;
		pat_write = 0;
		while( spat_row < 64 )
		{
			File_ReadB( 0 );
			if( file_byte == 0 )
			{
				spat_row++;
				// input data
				for( y = 0; y < xhead.chn; y++ )
				{
					TranslateS3M( &a, &b, spat_fx[y], spat_param[y] );
					if( spat_note[y] == 254 )
						spat_note[y] = 97;
					else if( spat_note[y] != 255 )
						spat_note[y] = ((spat_note[y] & 0xF0) >> 4)*12 + (spat_note[y] & 0xF) +1; // TWEAK BASE OFFSET
					else
						spat_note[y] = 0;
					if( spat_vol[y] == 255 )
						spat_vol[y] = 0;
					else
						spat_vol[y] += 0x10;
					pat_write += WritePatternData( xpatterns[x].data + pat_write, spat_note[y], spat_inst[y], spat_vol[y], a, b );
					spat_note[y]  =255;
					spat_inst[y]  =0;
					spat_vol[y]   =255;
					spat_fx[y]    =255;
					spat_param[y] =0;
				}
			}
			else
			{
				a = file_byte;
				if( a & 32 )
				{
					File_ReadB( 0 );
					if( (a&31) < 8 )
						spat_note[(a&31)] = file_byte;
					File_ReadB( 0 );
					if( (a&31) < 8 )
						spat_inst[(a&31)] = file_byte;
				}
				if( a & 64 )
				{
					File_ReadB( 0 );
					if( (a&31) < 8 )
						spat_vol[(a&31)] = file_byte;
				}
				if( a & 128 )
				{
					File_ReadB( 0 );
					if( (a&31) < 8 )
						spat_fx[(a&31)] = file_byte;
					File_ReadB( 0 );
					if( (a&31) < 8 )
						spat_param[(a&31)] = file_byte;
				}
			}
		}
	}
	SAFE_DELETE( p_patt );
	xhead.ins = xhead.smp;
	xinst = new XMS_INSTRUMENT[xhead.ins];
	for( x = 0; x < xhead.ins; x++ )
	{
		// maek basic instrument
		memset( (void*)&xinst[x], 0, sizeof( XMS_INSTRUMENT ) );
		memcpy( xinst[x].sName, xsamp[x].sname, 22 );
		xinst[x].nsamps = 1;
		xinst[x].note_map[0] = x;
	}

	pr_channels = xhead.chn;
	for( x = 0; x < xhead.pat; x++ )
	{
		printf( STR_SPACER );
		printf( "Fixing pattern %i...\n", x );
		FixPattern( x );
	}
	printf( STR_SPACER );
	printf( "Finalizing patterns...\n" );
	for( x = 0; x < xhead.pat; x++ )
		FixPattern2( x );
//	FIRScan();
	File_Close( 0 );
	return CERROR_NONE;
}

int LoadXM( char* file_in )
{
	int a;
	int b;
	int c;
	int d;
	int e;
	
	if( !(a = File_Exists( file_in )) )		// Check if file exists
	{
		printf( "No source file!\n" );
		return CERROR_NOSOURCE;
	}
	printf( "Starting XM Conversion... " );	// Print stuff..
	printf( "Old Size: %i\n", a );

	// set initial pannings
	if( !arg_cpan )
	{
		for( a = 0; a < 8; a++ )
			xhead.PN[a] = 128;
	}
	else
	{
		xhead.PN[0] = 128 - ((int)roundf(128.0 * arg_pansep)); // use MOD panning
		xhead.PN[1] = 128 + ((int)roundf(127.0 * arg_pansep));
		xhead.PN[2] = 128 + ((int)roundf(127.0 * arg_pansep));
		xhead.PN[3] = 128 - ((int)roundf(128.0 * arg_pansep));
		xhead.PN[4] = 128 - ((int)roundf(128.0 * arg_pansep));
		xhead.PN[5] = 128 + ((int)roundf(127.0 * arg_pansep));
		xhead.PN[6] = 128 + ((int)roundf(127.0 * arg_pansep));
		xhead.PN[7] = 128 - ((int)roundf(128.0 * arg_pansep));
	}
	
	File_Open( file_in, FILE_MODE_READ, 0 );	// open file
	File_Skip( 37, 0 );							// seek to validation
	File_ReadB( 0 );							// check validation
	if( file_byte != 0x1A )
	{
		printf( "ERROR: Invalid XM\n" ); // if != 0x1A, exit with error
		File_Close( 0 );
		return CERROR_INVALIDXM;
	}
	File_Skip( 22, 0 );
	File_ReadD( 0 );
	a = (int)file_dword;	// ?
	File_ReadW( 0 );
	if( file_word > 255 ) 
	{
		printf( "ERROR: Song is too long!\n" );
		File_Close( 0 );
		return CERROR_TOOLONG;
	}
	xhead.length = file_word & 255;
	File_ReadW( 0 );
	xhead.restart = file_word & 255;
	File_ReadW( 0 );
	xhead.chn = file_word & 255;
	if( xhead.chn > 8 )
	{
		printf( "ERROR: Too many channels!\n" );
		File_Close( 0 );
		return CERROR_CHANNELS;
	}
	File_ReadW( 0 );
	xhead.pat = (byte)file_word;
	File_ReadW( 0 );
	xhead.ins = (byte)file_word;
	File_ReadW( 0 );
	if( (file_word & 1) == 1 )
	{
		xhead.lin = true;
		XMS_FILE_MAX = XMS_FILE_MAXL;
	}
	else
	{
		xhead.lin = false;
		XMS_FILE_MAX = XMS_FILE_MAXA;
	}
	File_ReadW( 0 );
	xhead.spd = (byte)file_word;
	File_ReadW( 0 );
	xhead.bpm = (byte)file_word;
	xhead.orders = new byte[xhead.length];
	File_ReadData( (void*)xhead.orders, xhead.length, 0 );
	File_Skip( 256 - xhead.length, 0 );
	
	// print data
	printf( STR_SPACER );
	printf( "Length:        %i\n", xhead.length );
	printf( "Channels:      %i\n", xhead.chn );
	printf( "Instruments    %i\n", xhead.ins );
	printf( "Patterns:      %i\n", xhead.pat );
	printf( "Speed:         %i\n", xhead.spd );
	printf( "BPM:           %i\n", xhead.bpm );
	if( xhead.lin )
		printf( "Linear Freqs: yes\n" );
	else
		printf( "Linear Freqs: no\n" );
	
	// PATTERNS
	xpatterns = new XMS_PATTERN[xhead.pat];
	pr_channels = xhead.chn;
	for( a = 0; a < xhead.pat; a++ )
	{
		printf( "Loading pattern %i...\n", a );
		File_Skip( 5, 0 );
		File_ReadW( 0 );
		memset( xpatterns[a].row_marks, 0, 256 );
		xpatterns[a].nrows = file_word;
		File_ReadW( 0 );
		if( file_word != 0 )
		{
			xpatterns[a].data = new byte[file_word];
			File_ReadData( xpatterns[a].data, file_word, 0 );
			xpatterns[a].data_size = file_word;
		}
		else
		{
			xpatterns[a].data = new byte[xpatterns[a].nrows * xhead.chn];
			memset( xpatterns[a].data, 0x80, xpatterns[a].nrows * xhead.chn );
			xpatterns[a].data_size = xpatterns[a].nrows * xhead.chn;
		}
	}
	
	// INSTRUMENTS/SAMPLES
	int inst_lastused = -1;
	int samp_lastused = -1;
	xinst = new XMS_INSTRUMENT[ xhead.ins ];
	samp_num = 0;
	for( a = 0; a < xhead.ins; a++ )
	{
		printf( STR_SPACER ); 
		printf( "Loading instrument %i...\n", a );
		File_ReadD( 0 );
		b = file_dword;
		memset( xinst[a].sName, 0, 23 );
		File_ReadData( xinst[a].sName, 22, 0 );
		FIRScan( xinst[a].sName );
		File_Skip( 1, 0 );
		if( strstr( xinst[a].sName, "-n" ) != NULL )
			xinst[a].noise = 1;
		else
			xinst[a].noise = 0;
		File_ReadW( 0 );
		xinst[a].nsamps = (byte)file_word;
		if( file_word > 0 )
		{
			File_Skip( 4, 0 );
			if( xinst[a].nsamps == 1 )
			{
				File_Skip( 96, 0 );
				xinst[a].note_map[0] = samp_num;
			}
			else
			{
				File_ReadData( xinst[a].note_map, 96, 0 );
				for( b = 0; b < 96; b++ )
				{
					xinst[a].note_map[b] += samp_num;
				}
			}
			
			File_ReadData( xinst[a].env_vol, 48, 0 );
			File_ReadData( xinst[a].env_pan, 48, 0 );
			
			xinst[a].nvpoints = File_ReadB( 0 );
			xinst[a].nppoints = File_ReadB( 0 );
			
			xinst[a].vol_sus   = File_ReadB( 0 );
			xinst[a].vol_loopS = File_ReadB( 0 );
			xinst[a].vol_loopE = File_ReadB( 0 );
			xinst[a].pan_sus   = File_ReadB( 0 );
			xinst[a].pan_loopS = File_ReadB( 0 );
			xinst[a].pan_loopE = File_ReadB( 0 );
			xinst[a].env_flags = File_ReadB( 0 );
			xinst[a].env_flags |=File_ReadB( 0 ) * 8;
			xinst[a].vib_type  = File_ReadB( 0 );
			xinst[a].vib_sweep = File_ReadB( 0 );
			xinst[a].vib_depth = File_ReadB( 0 );
			xinst[a].vib_rate  = File_ReadB( 0 );
			xinst[a].fadeout   = File_ReadW( 0 );
			File_Skip( 22, 0 );
			c = samp_num;
			for( b = 0; b < xinst[a].nsamps; b++ )
			{
				xsamp[samp_num].length = File_ReadD( 0 );
				if( xsamp[samp_num].length != 0 )
				{
					samp_lastused = samp_num;
					inst_lastused = a;
				}
				xsamp[samp_num].loop_start = File_ReadD( 0 );
				xsamp[samp_num].loop_length = File_ReadD( 0 );
				xsamp[samp_num].volume = File_ReadB( 0 );
				xsamp[samp_num].finetune = File_ReadB( 0 );
				xsamp[samp_num].loop_type = File_ReadB( 0 ) & 3;
				xsamp[samp_num].bit16 = ((file_byte & 16) != 0);
				xsamp[samp_num].panning = File_ReadB( 0 );
				xsamp[samp_num].rel_note = File_ReadB( 0 );
				File_Skip( 1, 0 );
				memset( xsamp[samp_num].sname, 0, 23 );
				File_ReadData( xsamp[samp_num].sname, 22, 0 );
				SampScanOptions( &xsamp[samp_num] );
				if( xsamp[samp_num].bit16 )
				{
					xsamp[samp_num].length >>= 1;
					xsamp[samp_num].loop_start >>= 1;
					xsamp[samp_num].loop_length >>= 1;
				}
				if( !arg_cpan )
					xsamp[samp_num].setpan = 1;
				else
					xsamp[samp_num].setpan = 0;
				samp_num++;
			}
			samp_num = c;
			// sample data
			for( b = 0; b < xinst[a].nsamps; b++ )
			{
				if( xsamp[samp_num].length > 0 )
				{
					if( (xinst[a].noise == 0) || (b == 0) )
					{
						xsamp[samp_num].samp_data = new int[xsamp[samp_num].length];
						d = 0;
						for( c = 0; c < xsamp[samp_num].length; c++ )
						{
							if( xsamp[samp_num].bit16 )
							{
								e = File_ReadW( 0 );
								if( e >= 32768 ) e -= 65536;
							}
							else
							{
								e = (File_ReadB( 0 ));
								if( e >= 128 ) e -= 256;
								e *= 256;
							}
							e += d;
							if( e >= 32768 ) e -= 65536;
							if( e < -32768 ) e += 65536;
							xsamp[samp_num].samp_data[c] = e;
							d = e;
						}

						CFixSample( &xsamp[samp_num], samp_num, true );
/*
						bool dup_check=false;
						int dup_num=0;
						for( c = 0; c < samp_num; c++ )
						{
							dup_num = c;
							dup_check = true;
							if( xsamp[c].length > 0 )
							{
								if( xsamp[c].length == xsamp[samp_num].length )
								{
									for( d = 0; d < xsamp[c].length; d++ )
									{
										if( xsamp[c].samp_data[d] != xsamp[samp_num].samp_data[d] )
										{
											dup_check = false;
											break;
										}
									}
								}
								else
								{
									dup_check = false;
								}
							}
							else
							{
								dup_check = false;
							}
							if( dup_check )
								break;
						}
						if( dup_check )
						{
							xsamp[samp_num].duplicate = dup_num + 1;
						}
						else
						{
							xsamp[samp_num].duplicate = 0;
						}
*/
						DupCheck( samp_num );
					}
					else
					{
						printf( STR_SPACER );
						printf( "Skipping Sample %i (noise)", samp_num );
						if( xsamp[samp_num].bit16 )
							File_Skip( xsamp[samp_num].length * 2, 0 );
						else
							File_Skip( xsamp[samp_num].length, 0 );
					}
				}
				samp_num++;
			}
		}
		else
		{
			File_Skip( b - 29, 0 );
		}
		if( xinst[a].noise )
		{
			samp_num = c + 1;
			xinst[a].nsamps = 1;
			xinst[a].note_map[0] = c;
		}
	}
//	xhead.smp = samp_num;
	xhead.smp = samp_lastused+1;
	xhead.ins = inst_lastused+1;
	for( a = 0; a < xhead.pat; a++ )
	{
		printf( STR_SPACER );
		printf( "Fixing pattern %i...\n", a );
		FixPattern( a );
	}
	printf( STR_SPACER );
	printf( "Finalizing patterns...\n" );
	for( a = 0; a < xhead.pat; a++ )
	{
		printf( "pattern index %i\n", a );
		FixPattern2( a );
	}
	for( a = 0; a < xhead.pat; a++ )
	{
		//FixPattern3( a );
	}
//	FIRScan();
	File_Close( 0 );
	return CERROR_NONE;
}

int WriteXMS( char* file_out, bool rawmode )
{
	int bytes_other;
	int bytes_patterns;
	int bytes_instruments;
	int bytes_samples;
	
	int a;
	int b;
	File_Open( file_out, FILE_MODE_WRITE, 0 );
	xhead.patt_off = new int[xhead.pat];
	xhead.inst_off = new int[xhead.ins];
	
	File_WriteW( 0, 0 );
	
	File_WriteB( xhead.length		, 0 );		// start writing stuff..
	File_WriteB( xhead.chn			, 0 );
	File_WriteB( xhead.ins			, 0 );
	File_WriteB( xhead.smp			, 0 );
	File_WriteB( xhead.pat			, 0 );
	File_WriteB( xhead.spd			, 0 );
	File_WriteB( xhead.bpm			, 0 );
	if( xhead.lin )
		File_WriteB( 1, 0 );
	else
		File_WriteB( 0, 0 );
	file_word = (offset_orders + xhead.length + xhead.pat * 2 + xhead.ins * 2 + xhead.smp * 4);
	File_WriteW( file_word			, 0 );
	File_WriteB( xhead.restart		, 0 );
	
	for( a = 0; a < 8; a++ )
		File_WriteB( xhead.PN[a], 0 );			// write initial panning
	
	File_WriteB( XMS_VERSION, 0 );				// write version

	for( a = 0; a < 8; a++ )
		File_WriteB( 0, 0 );		// reserve space for offsets
	
	for( a = 0; a < xhead.length; a++ )
		File_WriteB( xhead.orders[a], 0 );		// write orders
	
	
	for( a = 0; a < xhead.pat + xhead.ins + xhead.smp*2; a++ )
		File_WriteW( 0, 0 );
	
	for( a = 0; a < xhead.nfilters; a++ )
		File_WriteData( (void*)xfilters[a].binary, 12, 0 );
	
	bytes_other = File_Tell( 0 );
	
	for( a = 0; a < xhead.pat; a++ )
	{
		xhead.patt_off[a] = File_Tell( 0 );
		File_WriteB( xpatterns[a].nrows-1, 0 );
		File_WriteData( xpatterns[a].data, xpatterns[a].data_size, 0 ); // dont forget to fill in data_size
	}

	bytes_patterns = File_Tell( 0 ) - bytes_other;
	
	for( a = 0; a < xhead.ins; a++ )
	{
		if( xinst[a].nsamps == 0 )
		{
			xhead.inst_off[a] = 0;
		}
		else
		{
			xhead.inst_off[a] = File_Tell( 0 );
			File_WriteB( xinst[a].nsamps					, 0 );
			File_WriteB( xinst[a].noise						, 0 );
			File_WriteB( xinst[a].nvpoints+offset_volenv-1	, 0 );
			File_WriteB( xinst[a].nppoints+offset_panenv-1	, 0 );
			File_WriteB( xinst[a].env_flags					, 0 );
			// volume env
			if( xinst[a].env_flags & 2 )
				File_WriteB( xinst[a].env_vol[xinst[a].vol_sus*4] & 255, 0 );
			else
				File_WriteB( 255, 0 );
			if( xinst[a].env_flags & 4 )
				File_WriteB( xinst[a].env_vol[xinst[a].vol_loopS*4] & 255, 0 );
			else
				File_WriteB( 255, 0 );
			File_WriteB( xinst[a].vol_loopS + offset_volenv, 0 );
			if( xinst[a].env_flags & 4 )
				File_WriteB( xinst[a].env_vol[xinst[a].vol_loopS*4+2] & 255, 0 );
			else
				File_WriteB( 0, 0 );
			if( xinst[a].env_flags & 4 )
			{
				if( xinst[a].vol_loopS != (xinst[a].nvpoints-1) )
				{
					file_byte = xinst[a].env_vol[(xinst[a].vol_loopS + 1) * 4] & 255;
					file_byte -= xinst[a].env_vol[(xinst[a].vol_loopS) * 4] & 255;
				}
				else
				{
					file_byte = 1;
				}
			}
			else
			{
				file_byte = 0;
			}
			File_WriteB( file_byte, 0 );

			if( xinst[a].env_flags & 4 )
				File_WriteB( xinst[a].env_vol[xinst[a].vol_loopE * 4] & 255, 0 );
			else
				File_WriteB( 255, 0 );
			// panning env
			if( xinst[a].env_flags & 4 )
				File_WriteB( xinst[a].env_pan[xinst[a].pan_sus * 4] & 255, 0 );
			else
				File_WriteB( 255, 0 );
			if( xinst[a].env_flags & 16 )
				File_WriteB( xinst[a].env_pan[xinst[a].pan_loopS * 4] & 255, 0 );
			else
				File_WriteB( 255, 0 );
			File_WriteB( xinst[a].pan_loopS + offset_panenv, 0 );
			if( xinst[a].env_flags & 32 )
				File_WriteB( xinst[a].env_pan[xinst[a].pan_loopS * 4 + 2] & 255, 0 );
			else
				File_WriteB( 0, 0 );
			if( xinst[a].env_flags & 32 )
			{
				if( xinst[a].pan_loopS != xinst[a].nppoints-1 )
				{
					file_byte = xinst[a].env_pan[(xinst[a].pan_loopS+1)*4] & 255;
					file_byte -= xinst[a].env_pan[(xinst[a].pan_loopS)*4] & 255;
				}
				else
				{
					file_byte = 1;
				}
			}
			else
			{
				file_byte = 0;
			}
			File_WriteB( file_byte, 0 );

			if( xinst[a].env_flags & 32 )
			{
				File_WriteB( xinst[a].env_pan[xinst[a].pan_loopE * 4] & 255, 0 );
			}
			else
			{
				File_WriteB( 255, 0 );
			}
			// fadeout & vibrato
			File_WriteW( xinst[a].fadeout * 2, 0 ); // *2 ??
			File_WriteB( xinst[a].vib_type, 0 );
			File_WriteW( 0xFF0/(xinst[a].vib_sweep+1), 0 );  /// 0xFF0 ??? CHECK FOR ERRORS
			File_WriteB( xinst[a].vib_depth, 0 );
			File_WriteB( xinst[a].vib_rate, 0 );
			if( xinst[a].nvpoints > 0 )
			{
				for( b = 0; b < xinst[a].nvpoints; b++ )
					File_WriteB( xinst[a].env_vol[ b*4 ] & 255, 0 );
				for( b = 0; b < (12 - xinst[a].nvpoints); b++ )
					File_WriteB( 255, 0 );
				for( b = 0; b < xinst[a].nvpoints; b++ )
					File_WriteB( xinst[a].env_vol[ b*4 +2 ] & 255, 0 );
				for( b = 0; b < (12 - xinst[a].nvpoints); b++ )
					File_WriteB( 0, 0 );
			}
			else
			{
				for( b = 0; b < 6; b++ )
					File_WriteD( 0, 0 );
			}
			if( xinst[a].nppoints > 0 )
			{
				for( b = 0; b < xinst[a].nppoints; b++ )
					File_WriteB( xinst[a].env_pan[ b*4 ] & 255, 0 );
				for( b = 0; b < (12-xinst[a].nppoints); b++ )
					File_WriteB( 255, 0 );
				for( b = 0; b < xinst[a].nppoints; b++ )
					File_WriteB( xinst[a].env_pan[ b*4 +2 ] & 255, 0 );
				for( b = 0; b < (12-xinst[a].nppoints); b++ )
					File_WriteB( 0, 0 );
			}
			else
			{
				for( b = 0; b < 6; b++ )
					File_WriteD( 0, 0 );
			}

			if( xinst[a].nsamps == 1 )
				File_WriteB( xinst[a].note_map[0], 0 );
			else
				File_WriteData( xinst[a].note_map, 96, 0 );
		}
	}
	
	bytes_instruments = File_Tell( 0 ) - bytes_patterns - bytes_other;
	
	byte* fb=NULL;
	int samp_overflow=1;
	int samp_offset=File_Tell( 0 );
	double samp_amp = 1.0;
	for( a = 0; a < xhead.smp; a++ )		// fix finetune
	{
 		xsamp[a].finetune = (byte)(((sbyte)xsamp[a].finetune) / 2);
		if( (char)(xsamp[a].finetune) < 0 )
		{
			xsamp[a].finetune = (unsigned char)((char)(xsamp[a].finetune) + 64);
			xsamp[a].rel_note = (unsigned char)((char)(xsamp[a].rel_note) - 1);
		}
		if( !xhead.lin )
		{
			xsamp[a].finetune = xsamp[a].finetune & 0xFE;
		}
	}
	printf( STR_SPACER );
	printf( "Compressing samples...\n" );
	printf( "  [index: filter, usage0, usage1, usage2, usage3, error]\n" );
	while( samp_overflow )
	{
		samp_overflow = 0;
		File_Seek( samp_offset, 0 );
		for( a = 0; a < xhead.smp; a++ )
		{
			xhead.samp_off[a] = File_Tell( 0 );
			File_WriteB( xsamp[a].finetune		, 0 );
			File_WriteB( xsamp[a].volume		, 0 );
			file_byte = (xsamp[a].panning >> 2) | (xsamp[a].setpan << 7);
			File_WriteB( file_byte				, 0 );
			File_WriteB( xsamp[a].rel_note		, 0 );
			if( !rawmode )
			{
				File_WriteB( xsamp[a].duplicate		, 0 );
			
				if( xsamp[a].duplicate == 0 )
				{
					b = ((xsamp[a].length + 15) / 16) * 9;
					if( b != 0 )
					{
						SAFE_DELETE( fb );
						fb = new byte[b];
						if( xsamp[a].loop_type == 0 )
						{
							xhead.samp_loop[a] = 0xFFFF - c_xmsoffset;
						}
						printf( "  Sample %i: ", a );
						if( xsamp[a].filter == 4 )
							printf( "auto, " );
						else
							printf( "%i, ", xsamp[a].filter );
						
						cstatus comp_results;
redocompress:
						samp_overflow =  BRR_AutoFilter( &xsamp[a], fb, File_Tell( 0 ), &xhead, a, xsamp[a].filter, &comp_results, samp_amp );
						if( samp_overflow )
						{
							//printf( "\nOverflow!\n" );
							samp_amp -= 0.05;
							goto redocompress;
						}
						else
						{
							printf( "%i (%i%%), %i (%i%%), %i (%i%%), %i (%i%%), %i%%\n",   (int)roundf( comp_results.fc[0] ), (int)roundf( comp_results.fp[0] ), \
																							(int)roundf( comp_results.fc[1] ), (int)roundf( comp_results.fp[1] ), \
																							(int)roundf( comp_results.fc[2] ), (int)roundf( comp_results.fp[2] ), \
																							(int)roundf( comp_results.fc[3] ), (int)roundf( comp_results.fp[3] ), \
																							(int)roundf( comp_results.overlp ) );
							File_WriteData( fb, b, 0 );
						}
					}
					else
					{
						printf( "  Empty sample.\n" );
					}
				}
				else
				{
					printf( "  Duplicate sample.\n" );
				}

			}
			//if( samp_overflow ) break;
			
		}
	}
	SAFE_DELETE( fb );
	
	bytes_samples = File_Tell( 0 ) - bytes_instruments - bytes_patterns - bytes_other;

	int fs;
	fs = File_Tell( 0 );
	File_Seek( 0, 0 );
	File_WriteW( (fs/3)+1, 0 );

	File_Seek( 0x16, 0 );
	File_WriteW( xhead.length + 0x1E + c_xmsoffset, 0 );
	File_WriteW( xhead.pat*2 + xhead.length + 0x1E + c_xmsoffset, 0 );
	File_WriteW( xhead.ins*2 + xhead.pat*2 + xhead.length + 0x1E + c_xmsoffset, 0 );
	File_WriteW( xhead.smp*2 + xhead.ins*2 + xhead.pat*2 + xhead.length + 0x1E + c_xmsoffset, 0 );
	
	File_Seek( 0x1E + xhead.length, 0 );		// orders offset + length
	printf( STR_SPACER );
	printf( "Writing Offsets...\n" );
	for( a = 0; a < xhead.pat; a++ )
		File_WriteW( xhead.patt_off[a] + c_xmsoffset, 0 );
	for( a = 0; a < xhead.ins; a++ )
		File_WriteW( xhead.inst_off[a] + c_xmsoffset, 0 );
	for( a = 0; a < xhead.smp; a++ )
		File_WriteW( xhead.samp_off[a] + c_xmsoffset, 0 );
	if( !rawmode )
	{
		for( a = 0; a < xhead.smp; a++ )
			File_WriteW( xhead.samp_loop[a] + c_xmsoffset, 0 );
	}
	else
	{
		for( a = 0; a < xhead.smp; a++ )
			File_WriteW( xsamp[a].samp_pointer, 0 );
	}
	File_Close( 0 );

	int bytes_patterns_old=0;
	for( a = 0; a < xhead.pat; a++ )
	{
		bytes_patterns_old += xpatterns[a].old_size;
//		printf( "new pattern size %i: %i (%i):\n", xpatterns[a].old_size, xpatterns[a].data_size, xpatterns[a].data_size-xpatterns[a].nrows );
	}

	printf( STR_SPACER );
	printf( "Conversion complete!\n" );
	int NEW_SIZE;
	NEW_SIZE = File_Exists( file_out );
	
	if( NEW_SIZE <= XMS_FILE_MAX )
	{
		printf( "New Size: %i\n", NEW_SIZE );
		printf( "Samples: %i bytes (%i%%)\n", bytes_samples, (int)roundf((((double)bytes_samples)/((double)NEW_SIZE))*100) );
		printf( "Patterns: %i bytes (%i%%), used to be %i bytes\n", bytes_patterns, (int)roundf((((double)bytes_patterns)/((double)NEW_SIZE))*100)   , bytes_patterns_old );
		printf( "Instruments: %i bytes (%i%%)\n", bytes_instruments, (int)roundf((((double)bytes_instruments)/((double)NEW_SIZE))*100) );
		printf( "Other: %i bytes (%i%%)\n\n", bytes_other, (int)roundf((((double)bytes_other)/((double)NEW_SIZE))*100) );
		return CERROR_NONE;
	}
	else
	{
		printf( "New Size: %i (TOO LARGE, MAX=%i)\n\n", NEW_SIZE, XMS_FILE_MAX );
		printf( "Samples: %i bytes (%i%%)\n", bytes_samples, (int)roundf((((double)bytes_samples)/((double)NEW_SIZE))*100) );
		printf( "Patterns: %i bytes (%i%%), used to be %i bytes\n", bytes_patterns, (int)roundf((((double)bytes_patterns)/((double)NEW_SIZE))*100)   , bytes_patterns_old );
		printf( "Instruments: %i bytes (%i%%)\n", bytes_instruments, (int)roundf((((double)bytes_instruments)/((double)NEW_SIZE))*100) );
		printf( "Other: %i bytes (%i%%)\n\n", bytes_other, (int)roundf((((double)bytes_other)/((double)NEW_SIZE))*100) );
		return CERROR_TOOBIG;
	}
}

void CFixSample( XMS_SAMPLE* samp, int index, bool disp )
{
	// commented fix sample
	if( disp )
	printf( "sampfix %i: %i,%i,%i,%i,%i /",  index, \
											xsamp[index].length, \
											xsamp[index].loop_start, \
											xsamp[index].loop_length, \
											(signed char)xsamp[index].rel_note, \
											(signed char)xsamp[index].finetune );
	FixSample( samp, arg_m, arg_unroll );
	if( disp )
	printf( " %i,%i,%i,%i,%i\n", xsamp[index].length, \
								xsamp[index].loop_start, \
								xsamp[index].loop_length, \
								(signed char)xsamp[index].rel_note, \
								(signed char)xsamp[index].finetune );
}

void Init( void )
{
	memset( &xhead, 0, sizeof( xhead ) );
	memset( &xsamp, 0, sizeof( XMS_SAMPLE ) * 60 );
	xpatterns = NULL;
}

void Cleanup( void )
{
	int x;
	
	SAFE_DELETE( xhead.orders );
	SAFE_DELETE( xhead.patt_off );
	SAFE_DELETE( xhead.inst_off );
	if( xpatterns != NULL )
	{
		for( x = 0; x < xhead.pat; x++ )
		{
			SAFE_DELETE( xpatterns[x].data );
		}
		SAFE_DELETE( xpatterns );
	}
	SAFE_DELETE( xinst );
	for( x = 0; x < xhead.smp; x++ )
	{
		SAFE_DELETE( xsamp[x].samp_data );
		SAFE_DELETE( xsamp[x].comp_data );
	}
	SAFE_DELETE( soutput_file );
}

void BigCleanup( void )
{
	Cleanup();
	int x;
	for( x = 0; x < asamp_num; x++ )
	{
		delete[] allsamp[x].comp_data;
	}
	delete[] allsamp;
}

void AddSample( XMS_SAMPLE* samp )
{
	int x;
	int y;
	bool match=false;
	for( x = 0; x < asamp_num; x++ )
	{
		if( samp->clength == allsamp[x].clength )
		{
			if( (samp->loop_start == allsamp[x].loop_start) )
			{
				match=true;
				for( y = 0; y < allsamp[x].clength; y++ )
				{
					if( samp->comp_data[y] != allsamp[x].comp_data[y] )
					{
						match = false;
						break;
					}
				}
				if( match )
				{
					samp->samp_pointer = x;
					break;
				}
			}
		}
	}
	if( !match )
	{
		samp->samp_pointer = asamp_num;
		asamp_num++;
		XMS_SAMPLEDATA* newsamps;
		newsamps = new XMS_SAMPLEDATA[ asamp_num ];
		memcpy( newsamps, allsamp, sizeof( XMS_SAMPLEDATA ) * (asamp_num-1) );
		if( asamp_num != 1 )
			delete[] allsamp;
		allsamp = newsamps;
		strcpy( allsamp[asamp_num-1].sname, samp->sname );
		allsamp[asamp_num-1].clength = samp->clength;
		allsamp[asamp_num-1].loop_start = samp->loop_start;
		allsamp[asamp_num-1].loop_length = samp->loop_length;
		allsamp[asamp_num-1].loop_type = samp->loop_type;
		allsamp[asamp_num-1].comp_data = new byte[ samp->clength ];
		memcpy( allsamp[asamp_num-1].comp_data, samp->comp_data, samp->clength );
	}
}

int AddSamples( void )
{
	int a;
	bool match=false;
	XMS_SAMPLE* samp;
	for( a = 0; a < xhead.smp; a++ )
	{
		samp = &xsamp[a];
		AddSample( samp );
	}
	return 0;
}

inline int Clamp16( int v )
{
	if( v < -32768 ) v = -32768;
	if( v > 32767 ) v = 32767;
	return v;
}

inline int Clamp8( int v )
{
	if( v < -128 ) v = -128;
	if( v > 127 ) v = 127;
	return v;
}

inline int Unsigned8( int v )
{
	if( v < 0 ) v += 256;
	return v;
}

inline int Signed8( int v )
{
	if( v >= 128 ) v -= 256;
	return v;
}

inline int Unsigned16( int v )
{
	if( v < 0 ) v += 65536;
	return v;
}

inline int Signed16( int v )
{
	if( v >= 32768 ) v -= 65536;
	return v;
}

inline int hexnum( char c )
{
	if( c >= 48 && c <= 57 )
		return (c - 48);
	else if( c >= 65 && c <= 70 )
		return (c - 65 + 10);
	else
		return 0;
}
