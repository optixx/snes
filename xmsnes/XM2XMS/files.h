#define FILE_MODE_CLOSED 0
#define FILE_MODE_READ 1
#define FILE_MODE_WRITE 2

extern void  File_Open( char* filename, int mode, int id );
extern void  File_Close( int id );
extern void  File_Skip( int nbytes, int id );
extern void  File_Seek( int offset, int id );
extern int   File_Exists( char* filename );
extern byte  File_ReadB( int id );
extern word  File_ReadW( int id );
extern dword File_ReadD( int id );
extern void  File_WriteB( byte data, int id );
extern void  File_WriteW( word data, int id );
extern void  File_WriteD( dword data, int id );
extern void  File_ReadData( void* pdata, int length, int id );
extern void  File_WriteData( void* pdata, int length, int id );
extern int   File_Tell( int id );
extern int   File_IsOpen( int mode, int id );
extern void  File_OpenW( char* filename, int id );
extern void  File_Kill( char* filename );

extern byte file_byte;
extern word file_word;
extern dword file_dword;