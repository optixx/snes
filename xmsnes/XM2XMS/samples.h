#define SAMP_RESAMP_NEAREST
#define SAMP_RESAMP_LINEAR
#define SAMP_RESAMP_HQ

extern void FixSample( XMS_SAMPLE* samp, bool m, int unroll );
extern void NNResample( XMS_SAMPLE*, double );
extern void LinearResample( XMS_SAMPLE*, double );
extern void GoodResample( XMS_SAMPLE*, double );
extern void SampAmp( XMS_SAMPLE* samp, double amp );
extern void SampTune( XMS_SAMPLE*, double );
extern void SampScanOptions( XMS_SAMPLE* samp );
extern void CsTuning( int rel_note, int finetune, double* hz );
extern void CsFreq( int* rel_note, int* finetune, double hz );
