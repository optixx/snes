#include "types.h"

#define XMS_VERSION 108
#define XMB_VERSION 100

#define XMS_FILE_MAXA (0xF000 - 0x2100)
#define XMS_FILE_MAXL (0x10000 - 0x2100)

#define samp_normal 32768* 0.7
#define c_xmsoffset 0x2100

#define		EXT_NONE  0
#define		EXT_MOD	  1
#define		EXT_S3M	  2
#define		EXT_XM	  3
#define		EXT_XMS   4
#define		EXT_SPC   5
#define		EXT_TXT   6
#define		EXT_OTHER 7

typedef		unsigned int u32;

typedef struct tXMS_HEAD
{
	byte	length;
	byte	chn;
	byte	ins;
	byte	smp;
	byte	pat;
	byte	spd;
	byte	bpm;
	byte	restart;
	byte	lin;
	byte*	orders;
	int*	patt_off;
	int*	inst_off;
	int		samp_off[60];
	int		samp_loop[60];
	int 	F_OFF;
	int		PN[8];
	int 	nfilters;
} XMS_HEAD;

typedef struct tXMS_FILTER
{
	char	code[23];
	byte	binary[12];
} XMS_FILTER;

typedef struct tXMS_PATTERN
{
	int		nrows;
	int		data_size;
	byte*	data;
	byte	row_marks[256];
	int		old_size;
} XMS_PATTERN;

typedef struct tXMS_INSTRUMENT 
{
	char	sName[23];
	byte	nsamps;
	byte	noise;
	byte	nvpoints;
	byte	nppoints;
	byte	env_flags;
	byte	vol_sus;
	byte	vol_loopS;
	byte	vol_loopE;
	byte	pan_sus;
	byte	pan_loopS;
	byte	pan_loopE;
	sdword	fadeout;
	byte	vib_type;
	byte	vib_sweep;
	byte	vib_depth;
	byte	vib_rate;
	byte	note_map[96];
	byte	env_vol[48];
	byte	env_pan[48];
} XMS_INSTRUMENT;

typedef struct tXMS_SAMPLE
{
	char    sname[23];
	// Info & data
	byte	volume;
	byte	finetune;
	byte	panning;
	byte	rel_note;
	byte	duplicate;
	byte	setpan;
	int*	samp_data;
	byte*	comp_data;
	int		samp_pointer;
	
	// Length & Loop
	bool	bit16;
	sdword	length;
	sdword	clength;
	byte	loop_type;
	sdword	loop_start;
	sdword	loop_length;
	
	// Sample Quality Options
	byte	filter;
	byte	resamp;
	bool	ramping;
	int		unroll;
} XMS_SAMPLE;
/*
typedef struct tXMS_SAMPHEAD
{
	char    sname[23];
	// Info & data	
	byte	volume;
	byte	finetune;
	byte	panning;
	byte	rel_note;
	byte	duplicate;
	byte	setpan;
	int		samp_pointer;
	
	// Sample Quality Options
	byte	resamp;
	bool	ramping;
	int		unroll;
} XMS_SAMPHEAD;
*/
typedef struct tXMS_SAMPLEDATA
{
	char	sname[23];
	byte*	comp_data;
	
	// Length & Loop
	sdword	clength;
	byte	loop_type;
	sdword	loop_start;
	sdword	loop_length;
	
} XMS_SAMPLEDATA;

typedef struct tXMP_HEAD
{
	int nsongs;
	int nsamps;
	char desc[13];
	int* song_adr;
	int* samp_adr;
} XMP_HEAD;

typedef struct tcstatus
{
	int fc[4];
	double fp[4];
	int overloss;
	double overlp;
} cstatus;

typedef struct tcresult
{
	int samp_loss;
	int range;
	int filter;
	int peak;
	int samp[16];
	bool overflow;
} cresult;
