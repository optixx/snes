HdmaEffectSubroutineLUT:
	.dw HdmaEffectSubVoid				;0
	.dw HdmaEffectBg1ZoomInInit
	.dw HdmaEffectBg1ZoomIn
	.dw HdmaEffectTextGradientInit
	.dw HdmaEffectTextGradient
	.dw HdmaEffect3dScrollInit			;5
	.dw HdmaEffect3dScroll
	.dw HdmaEffectBattleStatusGradientInit
	.dw HdmaEffectBattleMainSubDesignation
	.dw HdmaEffectTitleNwarpZoomInit
	.dw HdmaEffectTitleNwarpZoom			;10
	.dw HdmaEffectCgadsubGradient
	.dw HdmaEffectPlayerSelectTextZoomInit
	.dw HdmaEffectPlayerSelectTextZoom

HdmaEffectSubVoid:
	rts


HdmaEffectPlayerSelectTextZoomInit:
	sep #$20
	ldx.b HdmaListPointer
	ldy.w #0

	lda.b #$df								;128 repeat
	
	sta.w HdmaBufferTable,x

	
	inx
	rep #$31
	lda.w #$3ff							

TextZoomInitLoop1:							;128 empty lines
	sta.w HdmaBufferTable,x
	dec a
	inx
	inx
	iny
	iny
	cpy.w #$be
	bcc TextZoomInitLoop1

	
	lda.w #$90								;16 lines repeat
	sta.w HdmaBufferTable,x					;upper warp

	txa										;upper warp data area
	clc
	adc.w #33
	tax	
	

	lda.w #32
	sta.w HdmaBufferTable,x					;24 lines unwarped text
	inx
	inx
	inx

	lda.w #$90								;16 lines repeat
	sta.w HdmaBufferTable,x					;upper warp

	txa										;lower warp data area
	clc
	adc.w #32
	tax
	inx
	lda.w #1
	sta.w HdmaBufferTable,x					;last entry
	inx
	lda.w #32
	sta.w HdmaBufferTable,x					;last entry
	inx
	inx
	stz.w HdmaBufferTable,x					;terminate table

	
	sep #$20
	ldx.b HdmaListPointer
	inc.w HdmaBufferSubRout,x						;goto textzoom play
	rts

HdmaEffectPlayerSelectTextZoom:
	rep #$31
	ldy.b HdmaListPointer
	ldx.w #0




HdmaEffectPlayerSelectTextZoomUpdateLoop1:	
	lda.b BG2VOfLo									;get bg2 offset
	sec
	sbc.l (HdmaPlayerSelectZoomLUT+BaseAdress),x
	sta.w HdmaBufferTable+$100-$40,y						;store in upper warp area
	inc a
	inc a
	iny
	iny
	inx
	inx
	cpx.w #16*2
	bne HdmaEffectPlayerSelectTextZoomUpdateLoop1

	lda.b BG2VOfLo									;get bg2 offset
	ldy.b HdmaListPointer
	sta.w HdmaBufferTable+$121-$40,y						;store in text display area
	ldx.w #0

HdmaEffectPlayerSelectTextZoomUpdateLoop2:	
	lda.b BG2VOfLo									;get bg2 offset
	clc
	adc.l (HdmaPlayerSelectZoomLUT2+BaseAdress),x
	sta.w HdmaBufferTable+$124-$40,y						;store in upper warp area
	inc a
	inc a
	iny
	iny
	inx
	inx
	cpx.w #16*2
	bne HdmaEffectPlayerSelectTextZoomUpdateLoop2
	
	iny
	lda.w #0
;	sta.w HdmaBufferTable+$124,y						;store in upper warp area
	rts


HdmaPlayerSelectZoomLUT:
.word  32 ,20  , 13 , 8 , 5 ,4, 3,3 
.word  2 , 2 , 2 , 1 , 1 , 1 , 1 , 0 

HdmaPlayerSelectZoomLUT2:
.word  0,1,1,1,1,2,2,2,3,3,4,5,8,13,20,32


HdmaEffectCgadsubGradient:
	jsr HdmaHelperUploadCountTable
	sep #$20
	lda.b #2														;word access
	jsr HdmaHelperUploadDataTableLinear

	ldx.b HdmaListPointer								;get relative list pointer
	stz.w HdmaBufferSubRout,x						;idle
	rts


HdmaEffectTitleNwarpZoomInit:
	rep #$31
	ldx.b HdmaListPointer
	ldy.w #0
	lda.w #$3ff
	sta.b TempBuffer
	lda.w #1
	sta.b TempBuffer+2

HdmaEffectTitleNwarpZoomInitLoop:
	sep #$20
	lda.b #1
	sta.w HdmaBufferTable,x
	rep #$31	
	inx
	lda.b TempBuffer			;scroll data
	sta.w HdmaBufferTable,x
	inx
	inx
	dec.b TempBuffer
	iny
	
	sep #$20
	lda.b TempBuffer+2			;count
	sta.w HdmaBufferTable,x
	inc a
	sta.b TempBuffer+2
	rep #$31	
	inx
	lda.b TempBuffer			;scroll data
	sta.w HdmaBufferTable,x
	inx
	inx
	dec.b TempBuffer
	iny
	
	
	cpy.w #200
	bne HdmaEffectTitleNwarpZoomInitLoop

;clear last entry	
	lda.w #1
	sta.w HdmaBufferTable,x
	inx
	stz.w HdmaBufferTable,x
	inx
	inx
;table terminator:

	lda.b #1
	sta.w HdmaBufferTable,x
	inx
	inx
	inx
	stz.w HdmaBufferTable,x
	
	sep #$20
	ldx.b HdmaListPointer
	inc.w HdmaBufferSubRout,x		;goto main zoom routine


HdmaEffectTitleNwarpZoom:
	rep #$31
	ldy.w #0
	ldx.b HdmaListPointer
	
HdmaEffectTitleNwarpZoomLoop:
	sep #$20
	lda.w HdmaBufferTable,x
	cmp.b #1
	beq HdmaEffectTitleNwarpZoomCountZero
	
	dec a
	sta.w HdmaBufferTable,x
HdmaEffectTitleNwarpZoomCountZero:	

	rep #$31
	inx
	lda.w HdmaBufferTable,x
	
	cmp.w #$3ff
	beq HdmaEffectTitleNwarpZoomZero

	inc a
	sta.w HdmaBufferTable,x
HdmaEffectTitleNwarpZoomZero:
	
;	inx
	inx
	inx
	iny
	cpy.w #200
	bne HdmaEffectTitleNwarpZoomLoop
	rts


HdmaEffectBattleMainSubDesignation:
	sep #$20
	ldx.b HdmaListPointer			;get relative list pointer
	lda.b #$7f
	sta.w HdmaBufferTable,x
	lda.b #16
	sta.w HdmaBufferTable+3,x
	lda.b #1
	sta.w HdmaBufferTable+6,x	
	lda.b #0
	sta.w HdmaBufferTable+9,x
	
	rep #$31
	lda.b MainScreen
	sta.w HdmaBufferTable+1,x
	sta.w HdmaBufferTable+4,x
	and.w #%1110111111101111		;disable sprites on sub/main
	sta.w HdmaBufferTable+7,x
	stz.w HdmaBufferSubRout,x		;return to idle

	rts
	
	
HdmaEffect3dScrollInit:
	sep #$20
	lda.b #1
	sta.w Pseudo3dScrollUpdateFlag		;start first update
	jsr ClearHdma3dBuffer

	ldx.b HdmaListPointer			;get relative list pointer
	lda.b #$78				;wait for 80 lines
	sta.w Hdma3dScrollCountV
	sta.w HdmaBufferTable,x
	lda.b #$d0				;then repeat for 80 times
	sta.w HdmaBufferTable+5,x
	lda.b #0
	sta.w HdmaBufferTable+650,x		;terminate table

	lda.b #$6
	sta.w HdmaBufferSubRout,x		;goto main zoom routine
	

	rep #$31
	stz.b BG1VOfLo				;clear scroll counter
	
	rts


ClearHdma3dBuffer:
	php
	rep #$31
	lda.w #$ffc0				;v-scroll init value
	sta.b TempBuffer
	
	ldx.w #Hdma3dScrollLineNumber*5
ClearHdma3dBufferLoop:
/*
	lda.b TempBuffer
	sta.l Hdma3dScrollBuffer-3,x
	sec
	sbc.w #64				;decrease scroll value by 1
	sta.b TempBuffer
*/
	lda.w #$8000				;start in the middle, avoid overflow glitch. under/overflowing on the $ffff/$0000 border causes priority errors
	sta.l Hdma3dScrollBuffer-3,x
	
	lda.w #$2000				;h-scroll init value

	sta.l Hdma3dScrollBuffer-5,x

	dex
	dex
	dex
	dex
	dex	
	bne ClearHdma3dBufferLoop
	plp
	rts
	
HdmaEffect3dScroll:
	jsr Hdma3dScrollUpdateTable
	rts


/*
;old version
Hdma3dScrollUpdateTable:

	php
	rep #$31
	ldy.w #0
	ldx.b HdmaListPointer

Hdma3dScrollUpdateTableLoop:	
	lda.w Hdma3dScrollBuffer&$ffff,y		;get h-scroll value
	lsr a					;lower precision
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	sta.w HdmaBufferTable&$ffff+6,x 		;store in hdma table

	lda.w #$3ff
	sta.w HdmaBufferTable&$ffff+8,x 		;store in hdma table
	
	iny					;5 bytes
	iny
	iny
	iny
	iny
	
	inx
	inx
	inx
	inx
	cpy.w #80*5
	bne Hdma3dScrollUpdateTableLoop
	
	
	plp
	rts
*/
Hdma3dScrollUpdateSkip:	
	plp
	rts

Hdma3dScrollUpdateTable:

	php
	sep #$20
	lda.w Pseudo3dScrollUpdateFlag		;don't update if flag isn't set
	beq Hdma3dScrollUpdateSkip
	
	ldx.w HdmaListPointer
	lda.w Hdma3dScrollCountV		;store wait counter
	sta.w HdmaBufferTable,x	
	rep #$31

	
	ldy.w #(Hdma3dScrollLineNumber-1)*5				;start at bottom of table
	lda.b HdmaListPointer
	adc.w #(Hdma3dScrollLineNumber-1)*4
	tax

	lda.w Hdma3dScrollBuffer&$ffff+2,y	;get last v-scroll value to determine base scroll value for lowest scanline of field
	lsr a					;lower precision
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	sta.b TempBuffer
	
	lda.w Hdma3dScrollBuffer&$ffff+2,y
	dec a
	sta.b TempBuffer+2			;line skip counter

Hdma3dScrollUpdateTableLoop:
;only draw lines that are not covered up by other lines in front.
;start at the bottom of the table and compare the shifted scroll value to the next upper entry.
;if its equal, draw that line also
;if new value is smaller, dont write that scanline to hdma table, skip it, but use its scroll value as new compare value, then go to next entry.
	lda.w Hdma3dScrollBuffer&$ffff+2,y	;get v-scroll value
	lsr a					;lower precision
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	sta.b TempBuffer+4
	lda.b TempBuffer+2
				
	cmp.b TempBuffer+4
	bcc Hdma3dDrawLine

	lda.b TempBuffer+4
	dec a	
	sta.b TempBuffer+2

	dey					;5 bytes
	dey
	dey
	dey
	dey


	bne Hdma3dScrollUpdateTableLoop
	bra Hdma3dScrollUpdateTableLoopEnd


Hdma3dDrawLine:
	lda.b TempBuffer+4
	dec a	
	sta.b TempBuffer+2
	lda.w Hdma3dScrollBuffer&$ffff,y		;get h-scroll value
	lsr a					;lower precision
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	sta.w HdmaBufferTable&$ffff+6,x 		;store in hdma table

	lda.w Hdma3dScrollBuffer&$ffff+2,y		;get v-scroll value
	lsr a					;lower precision
	lsr a
	lsr a
	lsr a
	lsr a
	lsr a
	sec
	sbc.b TempBuffer
	sta.w HdmaBufferTable&$ffff+8,x 		;store in hdma table




	dex
	dex
	dex
	dex		
	
	dey					;5 bytes
	dey
	dey
	dey
	dey


	bne Hdma3dScrollUpdateTableLoop
	
Hdma3dScrollUpdateTableLoopEnd:	
	txa					;fill untouched rest of buffer with zeroes(if there is any rest)
	beq Hdma3dScrollUpdateTableExit

;	lda.w #100
Hdma3dScrollUpdateTableClearRestLoop:

	lda.w HdmaBufferTable&$ffff+10,x
	sta.w HdmaBufferTable&$ffff+6,x
	lda.w HdmaBufferTable&$ffff+12,x	
	sta.w HdmaBufferTable&$ffff+8,x 



	dex
	dex
	dex
	dex
	bne Hdma3dScrollUpdateTableClearRestLoop

Hdma3dScrollUpdateTableExit:
	lda.w HdmaBufferTable&$ffff+10,x
	sta.w HdmaBufferTable&$ffff+6,x			;store in second hdma entry
	sta.w HdmaBufferTable&$ffff+1,x			;store in first hdma entry
	lda.w HdmaBufferTable&$ffff+12,x	
	sta.w HdmaBufferTable&$ffff+8,x 
	sta.w HdmaBufferTable&$ffff+3,x 
	lda.b HdmaListPointer
	adc.w #(Hdma3dScrollLineNumber-1)*4
	tax
	lda.w #0
	sta.w HdmaBufferTable&$ffff+6,x			;store in very last hdma entry so 3d scroll doesn't overflow into status box
	sta.w HdmaBufferTable&$ffff+8,x			;
	
	sep #$20
	stz.w Pseudo3dScrollUpdateFlag			;clear update flag
	plp
	rts


HdmaEffectTextGradientInit:
	jsr HdmaHelperUploadCountTable
	sep #$20
	lda.b #4				;doubleword access
	jsr HdmaHelperUploadDataTableLinear


	ldx.b HdmaListPointer			;get relative list pointer
;	lda.b #0
	stz.w HdmaBufferSubRout,x		;goto main zoom routine

	rts

HdmaEffectTextGradient:
	rts

HdmaEffectBattleStatusGradientInit:
	jsr HdmaHelperUploadCountTable
	sep #$20
	lda.b #4				;doubleword access
	jsr HdmaHelperUploadDataTableLinear


	ldx.b HdmaListPointer			;get relative list pointer
	lda.b #$0
	sta.w HdmaBufferSubRout,x		;goto main zoom routine

	rts
	
HdmaEffectBg1ZoomInInit:
	jsr HdmaHelperUploadCountTable
	
	sep #$20
	lda.b #2				;word access
	jsr HdmaHelperUploadDataTableLinear
	ldx.b HdmaListPointer			;get relative list pointer
	lda.b #$2
	sta.w HdmaBufferSubRout,x		;goto main zoom routine
	rts
	
HdmaEffectBg1ZoomIn:
;	lda.b FrameCounterLo
;	lsr a
;	bcc HdmaEffectBg1ZoomInNoEnd
	
	ldx.b HdmaListPointer			;get relative list pointer
	ldy.w #0
	lda.w HdmaBufferTable+1,x		;get second entry in hdma table
	sta.b TempBuffer

HdmaEffectBg1ZoomInLoop:
	lda.w HdmaBufferTable+1,x		;get second entry in hdma table
	cmp.b TempBuffer
	beq HdmaEffectBg1ZoomInSkip

	dec a					;decrease all lines till they are at first data table entry
	dec a
	sta.w HdmaBufferTable+1,x
HdmaEffectBg1ZoomInSkip:
	inx
	inx
	inx
	iny
	cpy.w #85				;process all lines
	bne HdmaEffectBg1ZoomInLoop
	
	dex					;check if last entry is = first entry to see if the effect is done
	dex
	dex
	lda.w HdmaBufferTable+1,x
	
	cmp.b TempBuffer
	bne HdmaEffectBg1ZoomInNoEnd
	
	ldx.b HdmaListPointer			;get relative list pointer
	sep #$20
	lda.b #$0
	sta.w HdmaBufferFlags,x			;disable hdma effect


HdmaEffectBg1ZoomInNoEnd:
	rts
