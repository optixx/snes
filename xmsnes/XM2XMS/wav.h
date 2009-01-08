#define LOADWAV_OK				0x00
#define LOADWAV_CORRUPT			0x01
#define LOADWAV_UNKNOWN_COMP	0x11
#define LOADWAV_TOOMANYCHANNELS	0x12
#define LOADWAV_UNSUPPORTED_BD	0x13
#define LOADWAV_BADDATA			0x14

int LoadWAV( char* file, XMS_SAMPLE* s, int findex );
