.Section "hdma tables" superfree
HdmaCountDataFileLUT:
	;currently void

HdmaEffectFileLUT:
	.dw HdmaEffectFile00
	.dw HdmaEffectFile01
	.dw HdmaEffectFile02
	.dw HdmaEffectFile03
	.dw HdmaEffectFile04
	.dw HdmaEffectFile05
	.dw HdmaEffectFile06
	.dw HdmaEffectFile07
	.dw HdmaEffectFile08
	.dw HdmaEffectFile09
	.dw HdmaEffectFile10
	.dw HdmaEffectFile11
	.dw HdmaEffectFile12

;zoom in bg1
HdmaEffectFile00:
	.db 2		;ram buffer to use,0-5
	.db $80		;flags
	.db $0e		;target reg b-bus
	.db %01000010	;hdma config
	.db 2		;number of rom data table to use
	.db 1		;number of rom count table to use
	.db 1		;number of subroutine

;nwarp logo gradient
HdmaEffectFile01:
	.db 1		;ram buffer to use,0-5
	.db $80		;flags
	.db $21		;target reg b-bus
	.db %01000011	;hdma config (indirect, write 2 regs twice, first cgram adress x2, then color word
	.db 0		;number of rom data table to use
	.db 2		;number of rom count table to use
	.db 3		;number of subroutine

;battle bg0 3d scroll
HdmaEffectFile02:
	.db 0		;ram buffer to use,0-5
	.db $80		;flags
	.db $0d		;target reg b-bus
	.db %00000011	;hdma config (direct, write 2 regs twice, first bg0 hof, then bg0 vof)
	.db 0		;number of rom data table to use
	.db 0		;number of rom count table to use
	.db 5		;number of subroutine
;battle statusbox gradient	
HdmaEffectFile03:
	.db 1		;ram buffer to use,0-5
	.db $80		;flags
	.db $21		;target reg b-bus
	.db %01000011	;hdma config (indirect, write 2 regs twice, first cgram adress x2, then color word
	.db 3		;number of rom data table to use
	.db 2		;number of rom count table to use
	.db 7		;number of subroutine

;main/sub settings for battlemode
HdmaEffectFile04:
	.db 2		;ram buffer to use,0-5
	.db $80		;flags
	.db $2c		;target reg b-bus
	.db %00000001	;hdma config (indirect, write 2 regs once, main/sub designation
	.db 0		;number of rom data table to use
	.db 3		;number of rom count table to use
	.db 8		;number of subroutine

;titlescreen nwarp logo zoom
HdmaEffectFile05:
	.db 2		;ram buffer to use,0-5
	.db $80		;flags
	.db $10		;target reg b-bus (bg2 v-scroll)
	.db %00000010	;hdma config (direct, write 1 reg twice)
	.db 0		;number of rom data table to use
	.db 0		;number of rom count table to use
	.db 9		;number of subroutine

;hdma gradient intro scene 1
HdmaEffectFile06:
	.db 0		;ram buffer to use,0-5
	.db $80		;flags
	.db $31		;target reg b-bus (bg2 v-scroll)
	.db %01000001	;hdma config (indirect, write 2 regs once)
	.db 4		;number of rom data table to use
	.db 0		;number of rom count table to use
	.db 11		;number of subroutine

;hdma gradient intro scene 3
HdmaEffectFile07:
	.db 1		;ram buffer to use,0-5
	.db $80		;flags
	.db $31		;target reg b-bus (bg2 v-scroll)
	.db %01000001	;hdma config (indirect, write 2 regs once)
	.db 5		;number of rom data table to use
	.db 5		;number of rom count table to use
	.db 11		;number of subroutine

;hdma gradient player select
HdmaEffectFile08:
	.db 0		;ram buffer to use,0-5
	.db $80		;flags
	.db $31		;target reg b-bus (bg2 v-scroll)
	.db %01000001	;hdma config (indirect, write 2 regs once)
	.db 6		;number of rom data table to use
	.db 6		;number of rom count table to use
	.db 11		;number of subroutine
	
;hdma gradient 3d video
HdmaEffectFile09:
	.db 0		;ram buffer to use,0-5
	.db $80		;flags
	.db $31		;target reg b-bus (cgadsub)
	.db %01000001	;hdma config (indirect, write 2 regs once)
	.db 7		;number of rom data table to use
	.db 7		;number of rom count table to use
	.db 11		;number of subroutine	

;text zoomer player select
HdmaEffectFile10:
	.db 1		;ram buffer to use,0-5
	.db $80		;flags
	.db $10		;target reg b-bus (bg2 h-scroll)
	.db %00000010	;hdma config (indirect, write 1 regs twice)
	.db 0		;number of rom data table to use
	.db 0		;number of rom count table to use
	.db 12		;number of subroutine	

;hdma gradient credits
HdmaEffectFile11:
	.db 0		;ram buffer to use,0-5
	.db $80		;flags
	.db $31		;target reg b-bus (cgadsub)
	.db %01000001	;hdma config (indirect, write 2 regs once)
	.db 8		;number of rom data table to use
	.db 8		;number of rom count table to use
	.db 11		;number of subroutine	

;small nwarp logo gradient
HdmaEffectFile12:
	.db 1		;ram buffer to use,0-5
	.db $80		;flags
	.db $21		;target reg b-bus
	.db %01000011	;hdma config (indirect, write 2 regs twice, first cgram adress x2, then color word
	.db 9		;number of rom data table to use
	.db 2		;number of rom count table to use
	.db 3		;number of subroutine


;warning: there must always be one more entry present than actual data files. otherwise, length of hdma data table cant be calculated correctly
HdmaDataFileLUT:
	.dw HdmaDataFile0
	.dw HdmaDataFile1
	.dw HdmaDataFile2
	.dw HdmaDataFile3
	.dw HdmaDataFile4
	.dw HdmaDataFile5
	.dw HdmaDataFile6
	.dw HdmaDataFile7
	.dw HdmaDataFile8
	.dw HdmaDataFile9
	.dw HdmaDataFile10

HdmaDataFile0:
	.include "data/hdma/titlegradient.asm"
HdmaDataFile1:
	.dw 0000	
	.dw 0001
	.dw 0002
	.dw 0003
	.dw 0004
	.dw 0005
HdmaDataFile2:
	.dw $ffff
	.dw $3ff
	.dw $3fe
	.dw $3fd
	.dw $3fc
	.dw $3fb
	.dw $3fa
	.dw $3f9
	.dw $3f8
	.dw $3f7
	.dw $3f6
	.dw $3f5
	.dw $3f4
	.dw $3f3
	.dw $3f2
	.dw $3f1
	.dw $3f0
	.dw $3ef
	.dw $3ee
	.dw $3ed
	.dw $3ec
	.dw $3eb
	.dw $3ea
	.dw $3e9
	.dw $3e8
	.dw $3e7
	.dw $3e6
	.dw $3e5
	.dw $3e4
	.dw $3e3
	.dw $3e2
	.dw $3e1
	.dw $3e0
	.dw $3df
	.dw $3de
	.dw $3dd
	.dw $3dc
	.dw $3db
	.dw $3da
	.dw $3d9
	.dw $3d8
	.dw $3d7
	.dw $3d6
	.dw $3d5
	.dw $3d4
	.dw $3d3
	.dw $3d2
	.dw $3d1
	.dw $3d0
	.dw $3cf
	.dw $3ce
	.dw $3cd
	.dw $3cc
	.dw $3cb
	.dw $3ca
	.dw $3c9
	.dw $3c8
	.dw $3c7
	.dw $3c6
	.dw $3c5
	.dw $3c4
	.dw $3c3
	.dw $3c2
	.dw $3c1
	.dw $3c0
	.dw $3bf
	.dw $3be
	.dw $3bd
	.dw $3bc
	.dw $3bb
	.dw $3ba
	.dw $3b9
	.dw $3b8
	.dw $3b7
	.dw $3b6
	.dw $3b5
	.dw $3b4
	.dw $3b3
	.dw $3b2
	.dw $3b1
	.dw $3b0
	.dw $3af
	.dw $3ae
	.dw $3ad
	.dw $3ac
	.dw $3ab
	.dw $3aa
	.dw $3a9
	.dw $3a8
	.dw $3a7
	.dw $3a6
	.dw $3a5
	.dw $3a4
	.dw $3a3
	.dw $3a2
	.dw $3a1
	.dw $3a0
	.dw $39f
	.dw $39e
	.dw $39d
	.dw $39c
	.dw $39b
	.dw $39a
	.dw $399
	.dw $398
	.dw $397
	.dw $396
	.dw $395
	.dw $394
	.dw $393
	.dw $392
	.dw $391
	.dw $390
	.dw $38f
	.dw $38e
	.dw $38d
	.dw $38c
	.dw $38b
	.dw $38a
	.dw $389
	.dw $388
	.dw $387
	.dw $386
	.dw $385
	.dw $384
	.dw $383
	.dw $382
	.dw $381
	.dw $380
	.dw $37f
	.dw $37e
	.dw $37d
	.dw $37c
	.dw $37b
	.dw $37a
	.dw $379
	.dw $378
	.dw $377
	.dw $376
	.dw $375
	.dw $374
	.dw $373
	.dw $372
	.dw $371
	.dw $370
	.dw $36f
	.dw $36e
	.dw $36d
	.dw $36c
	.dw $36b
	.dw $36a
	.dw $369
	.dw $368
	.dw $367
	.dw $366
	.dw $365
	.dw $364
	.dw $363
	.dw $362
	.dw $361
	.dw $360
	.dw $35f
	.dw $35e
	.dw $35d
	.dw $35c
	.dw $35b
	.dw $35a
	.dw $359
	.dw $358
	.dw $357
	.dw $356
	.dw $355
	.dw $354
	.dw $353
	.dw $352
	.dw $351
	.dw $350
	.dw $34f
	.dw $34e
	.dw $34d
	.dw $34c
	.dw $34b
	.dw $34a
	.dw $349
	.dw $348
	.dw $347
	.dw $346
	.dw $345
	.dw $344
	.dw $343
	.dw $342
	.dw $341
	.dw $340
	.dw $33f
	.dw $33e
	.dw $33d
	.dw $33c
	.dw $33b
	.dw $33a
	.dw $339
	.dw $338
	.dw $337
	.dw $336
	.dw $335
	.dw $334
	.dw $333
	.dw $332
	.dw $331
	.dw $330




HdmaDataFile3:
	.include "data/hdma/battleboxgradienttbl.asm"
HdmaDataFile4:
	.include "data/hdma/introscene1cgadsubdata.asm"
HdmaDataFile5:
	.include "data/hdma/introscene3cgadsubdata.asm"
HdmaDataFile6:
	.include "data/hdma/playerselectcgadsubdata.asm"
HdmaDataFile7:
	.include "data/hdma/3dvideocgadsubdata.asm"
HdmaDataFile8:
	.include "data/hdma/creditscgadsubdata.asm"
HdmaDataFile9:	
	.include "data/hdma/creditsgradient.asm"
HdmaDataFile10:	

HdmaCountFileLUT:
	.dw HdmaCountFile0
	.dw HdmaCountFile1
	.dw HdmaCountFile2
	.dw HdmaCountFile3
	.dw HdmaCountFile4
	.dw HdmaCountFile5
	.dw HdmaCountFile6
	.dw HdmaCountFile7
	.dw HdmaCountFile8
	
	
;$ff: loop table from beginning
;$fe: end table
HdmaCountFile0:
	.include "data/hdma/introscene1cgadsubcount.asm"
HdmaCountFile1:
	.db 01
	.db 01
	.db 02
	.db 02
	.db 03
	.db 04
	.db 05
	.db 04
	.db 03
	.db 02
	.db 02
	.db 01
	.db 01	
	.db $ff
HdmaCountFile2:
	.db $08
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01

	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01

	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01

	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01
	.db 01

	.db 01
	.db 01
	.db 01
	.db 01

	.db 00		;terminate

HdmaCountFile3:
	.db $7f
	.db 10
	.db 1
	.db 0		;terminate
HdmaCountFile4:
HdmaCountFile5:
	.include "data/hdma/introscene3cgadsubcount.asm"	
HdmaCountFile6:
	.include "data/hdma/playerselectcgadsubcount.asm"	
HdmaCountFile7:
	.include "data/hdma/3dvideocgadsubcount.asm"	
HdmaCountFile8:
	.include "data/hdma/creditscgadsubcount.asm"	
.ends
	