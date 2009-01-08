#define SPCE_TITLE		1
#define SPCE_ARTIST		2
#define SPCE_GAME		4
#define SPCE_COMMENTS	8
#define SPCE_SECONDS	16
#define SPCE_FADE		32

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

extern void BuildSPC( char* filename, SPC_INFO* info );
int EditSPC( char* filename, SPC_INFO* info, int flags );
