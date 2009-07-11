.Section "Battlefiles" superfree
/*
format:
0		;background color,r
1		;background color,g
2		;background color,b
3		;number of background file to load for bg1 sky
4		;number of background file to load for bg0 scroll
5		;number of subroutine for this file
6		;number of z-scroll list for this file
7		;tablist to load
8		;enemy stats to load
9		;allowed instruments for this battle and special flags.
 		;msb set=don't go to instrument select screen, directly proceed to battle with all allowed instruments enabled
		;bit0= joypad
		;bit1= guitar
		;bit2= bass
		;bit3= drumpad 
10	;object list
		.db		;object number
		.db		;obj present flag
		.db		;x-pos/8
		.db		;y-pos/8
		.db		;z-pos

.dw 0		;terminator for obj list

*/


BattleFileLUT:
	.dw BattleFile0
	.dw BattleFile1
	
	

BattleFile0:
	.db	(BattleFile0End-BattleFile0)
	.db 0		;background color,r
	.db 0		;background color,g
	.db 0		;background color,b
	.db 0		;number of background file to load for bg1 sky
	.db 1		;number of background file to load for bg0 scroll
	.db 0		;number of subroutine for this file
	.db 0		;number of z-scroll list for this file
	.db 1		;number of tablist to use. tablist autoloads song
	.db 1		;number of enemy stat to load
	.db %1111		;allowed instruments for this battle and special flags.
;object list


;main chara top
		.db 34		;object number
		.db $80		;obj present flag
		.db 20		;x-pos/8
		.db 17		;y-pos/8
		.db 1		;z-pos		

;main chara bottom
		.db 35		;object number
		.db $80		;obj present flag
		.db 20		;x-pos/8
		.db 21		;y-pos/8
		.db 1		;z-pos		

;main chara top
		.db 36		;object number
		.db $80		;obj present flag
		.db 13		;x-pos/8
		.db 15		;y-pos/8
		.db 17		;z-pos		

;main chara bottom
		.db 37		;object number
		.db $80		;obj present flag
		.db 13		;x-pos/8
		.db 19		;y-pos/8
		.db 17		;z-pos	

;main chara top
		.db 38		;object number
		.db $80		;obj present flag
		.db 11		;x-pos/8
		.db 16		;y-pos/8
		.db 7		;z-pos		

;main chara bottom
		.db 39		;object number
		.db $80		;obj present flag
		.db 11		;x-pos/8
		.db 20		;y-pos/8
		.db 7		;z-pos	

;small mainchara
		.db 40		;object number
		.db $80		;obj present flag
		.db 17		;x-pos/8
		.db 16		;y-pos/8
		.db 40		;z-pos	

;small mainchara
		.db 41		;object number
		.db $80		;obj present flag
		.db 8		;x-pos/8
		.db 16		;y-pos/8
		.db 37		;z-pos	


.dw 0		;terminator for obj list
BattleFile0End:		

BattleFile1:
	.db	(BattleFile1End-BattleFile1)
	.db 0		;background color,r
	.db 0		;background color,g
	.db 0		;background color,b
	.db 0		;number of background file to load for bg1 sky
	.db 1		;number of background file to load for bg0 scroll
	.db 0		;number of subroutine for this file
	.db 0		;number of z-scroll list for this file
	.db 0		;number of tablist to use. tablist autoloads song. (use special user generated ram tablist here)
	.db 1		;number of enemy stat to load
	.db 0		;allowed instruments for this battle and special flags.
;object list

;cpu usage
		.db 1		;object number
		.db $80		;obj present flag
		.db 16		;x-pos/8
		.db 0		;y-pos/8
		.db 0		;z-pos
/*
;main chara top
		.db 25		;object number
		.db $80		;obj present flag
		.db 20		;x-pos/8
		.db 9		;y-pos/8
		.db 10		;z-pos		

;main chara bottom
		.db 26		;object number
		.db $80		;obj present flag
		.db 20		;x-pos/8
		.db 13		;y-pos/8
		.db 10		;z-pos		
*/
/*
;pirate girl chara top
		.db 29		;object number
		.db $80		;obj present flag
		.db 10		;x-pos/8
		.db 6		;y-pos/8
		.db 38		;z-pos		

;pirate girl bottom
		.db 30		;object number
		.db $80		;obj present flag
		.db 10		;x-pos/8
		.db 10		;y-pos/8
		.db 38		;z-pos	
*/
;bg obj1
		.db 27		;object number
		.db $80		;obj present flag
		.db 21		;x-pos/8
		.db 13		;y-pos/8
		.db 35		;z-pos	

		.db 27		;object number
		.db $80		;obj present flag
		.db 29		;x-pos/8
		.db 11		;y-pos/8
		.db 50		;z-pos		

		.db 27		;object number
		.db $80		;obj present flag
		.db 28		;x-pos/8
		.db 16		;y-pos/8
		.db 8		;z-pos				

;bg obj2
		.db 28		;object number
		.db $80		;obj present flag
		.db 10		;x-pos/8
		.db 14		;y-pos/8
		.db 18		;z-pos	

		.dw 0		;terminator for obj list
BattleFile1End:

.ends