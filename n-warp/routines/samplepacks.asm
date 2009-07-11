.Section "SamplepackLUT" superfree				
PtPlayerSamplePackPointertable:
		.dw SamplePack0
		.db (:SamplePack0+BaseAdress>>16)
		.dw SamplePack1
		.db (:SamplePack1+BaseAdress>>16)
.ends

.Section "sample pack 0" superfree
SamplePack0:
	.dw (SamplePack0End-SamplePack0)

SamplePackStart0:
	.db 11				;number of samples in this pack

Sample0Header:
	.dw (Sample0-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample0-SamplePackStart0)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $400			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

Sample1Header:
	.dw (Sample1-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample1-SamplePackStart0)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $400			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

Sample2Header:
	.dw (Sample2-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample2-SamplePackStart0)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $400			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

Sample3Header:
	.dw (Sample3-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample3-SamplePackStart0)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $400			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

Sample4Header:
	.dw (Sample4-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample4-SamplePackStart0)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $300			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

;evading
Sample5Header:
	.dw (Sample5-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample5-SamplePackStart0)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $400			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

;punching old, too quiet
Sample6Header:
	.dw (Sample5-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample5-SamplePackStart0)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $900			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

;punch 1
Sample7Header:
	.dw (Sample6-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample6-SamplePackStart0)	;relative loop pointer
	.db $6f				;volume l
	.db $6f				;volume r
	.dw $800			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

;punch 2
Sample8Header:
	.dw (Sample6-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample6-SamplePackStart0)	;relative loop pointer
	.db $6f				;volume l
	.db $6f				;volume r
	.dw $7d0			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

;kick 1
Sample9Header:
	.dw (Sample6-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample6-SamplePackStart0)	;relative loop pointer
	.db $6f				;volume l
	.db $6f				;volume r
	.dw $7a0			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

;kick 2
Sample10Header:
	.dw (Sample6-SamplePackStart0)	;relative pointer to sample	
	.dw (Sample6-SamplePackStart0)	;relative loop pointer
	.db $6f				;volume l
	.db $6f				;volume r
	.dw $840			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

Sample0:
	.incbin "data/sounds/hit.brr"

Sample1:
	.incbin "data/sounds/ouch.brr"		
Sample2:
	.incbin "data/sounds/ding.brr"		
Sample3:
	.incbin "data/sounds/fall.brr"	
Sample4:
	.incbin "data/sounds/uah.brr"	
Sample5:
	.incbin "data/sounds/woosh.brr"
Sample6:
	.incbin "data/sounds/punch.brr"	
SamplePack0End:
.ends

.Section "sample pack 1" superfree
SamplePack1:

	.dw (SamplePack1End-SamplePack1)

SamplePackStart1:
	.db 3				;number of samples in this pack

;metalhit
SamplePack1Sample0Header:
	.dw (SamplePack1Sample0-SamplePackStart1)	;relative pointer to sample	
	.dw (SamplePack1Sample0-SamplePackStart1)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $400			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

;nwarp
SamplePack1Sample1Header:
	.dw (SamplePack1Sample1-SamplePackStart1)	;relative pointer to sample	
	.dw (SamplePack1Sample1-SamplePackStart1)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $400			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

;daisakusen
SamplePack1Sample2Header:
	.dw (SamplePack1Sample2-SamplePackStart1)	;relative pointer to sample	
	.dw (SamplePack1Sample2-SamplePackStart1)	;relative loop pointer
	.db $7f				;volume l
	.db $7f				;volume r
	.dw $400			;pitch
	.dw $0000			;adsr
	.db %00011111				;gain
	.db 0
	.db 0
	.db 0
	.db 0
	.db 0

SamplePack1Sample0:
	.incbin "data/sounds/metalhit.brr"

SamplePack1Sample1:
	.incbin "data/sounds/nwarp.brr"		
SamplePack1Sample2:
	.incbin "data/sounds/daisakusen.brr"		
SamplePack1End:
.ends



