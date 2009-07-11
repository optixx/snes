
InitHdma:
	php
	ldx.w #HdmaBuffer-HdmaBuffer
	jsr ClearHdmaBuffer
	ldx.w #HdmaBuffer1-HdmaBuffer
	jsr ClearHdmaBuffer
	ldx.w #HdmaBuffer2-HdmaBuffer
	jsr ClearHdmaBuffer
	ldx.w #HdmaBuffer3-HdmaBuffer
	jsr ClearHdmaBuffer
	ldx.w #HdmaBuffer4-HdmaBuffer
	jsr ClearHdmaBuffer
	ldx.w #HdmaBuffer5-HdmaBuffer
	jsr ClearHdmaBuffer
	
	stz.w HdmaFlags
	plp
	rts

;in: 	x,16bit=offset in bank $7e to clear
ClearHdmaBuffer:
	php
	rep #$31
	txa												;calculate offset of hdma table to clear
	adc.w #HdmaBuffer&$ffff
	tax
	lda.w #$0000			;clear with y-position at line 255
	
	ldy.w #HdmaBufferSize
	jsr ClearWRAM

/*
	lda.w #0			;clear with y-position at line 201
	ldy.w #HdmaBufferSize
ClearHdmaBufferLoop:
	sta.l (HdmaBuffer &$ffff + $7e0000),x
	inx
	inx
	dey
	dey
	bne ClearHdmaBufferLoop
*/
	plp
	rts

;in:	a,8bit=number of hdma effect to load
CreateHdmaEffect:
	php
	phb
	sep #$20
	pha
	lda.b #$7e
	pha
	plb
	pla
	rep #$31
	sei
	and.w #$ff					;get number of hdma effect
	asl a
	tax
	lda.l (HdmaEffectFileLUT+BaseAdress),x		;get pointer to effect
	sta.b ThreeBytePointerLo
	sep #$20
	lda.b #(:HdmaEffectFileLUT+BaseAdress>>16)
	sta.b ThreeBytePointerBank

;clear buffer	
	rep #$31
	ldy.w #0
	lda.b [ThreeBytePointerLo],y			;get number of hdma buffer table to use
	and.w #$ff
	asl a
	tax
	lda.l HdmaBufferRelativePointerLUT+BaseAdress,x	;get pointer to table in ram from LUT
	tax						;x now contains relative pointer to hdma ram buffer table
	phx
	jsr ClearHdmaBuffer				;clear the corresponding ram buffer first

;upload effect file
	plx
	ldy.w #0
	lda.b [ThreeBytePointerLo],y
	sta.w HdmaBufferTableEntry & $ffff,x
	iny
	iny
	lda.b [ThreeBytePointerLo],y
	sta.w HdmaBufferBBusTarget & $ffff,x
	iny
	iny
	lda.b [ThreeBytePointerLo],y
	sta.w HdmaBufferRomDataTbl & $ffff,x
	iny
	iny
	lda.b [ThreeBytePointerLo],y
	sta.w HdmaBufferSubRout & $ffff,x

	lda.w HdmaBufferRomDataTbl & $ffff,x		;calculate data table adress
	and.w #$ff
	asl a
	phx
	tax
	lda.l HdmaDataFileLUT+BaseAdress,x
	sta.b TempBuffer				;get file position

	lda.l HdmaDataFileLUT+BaseAdress+2,x		;get file+1 position to calculate length
	sec	
	sbc.b TempBuffer

	plx
	sta.w HdmaBufferRomDataLength,x
	lda.b TempBuffer
	sta.w HdmaBufferRomDataPnt,x

	sep #$20
	lda.b #(:HdmaDataFileLUT+BaseAdress>>16)
	sta.w HdmaBufferRomDataPnt+2,x			;store bank
	rep #$31

	lda.w HdmaBufferRomCountTbl & $ffff,x		;calculate data table adress
	and.w #$ff
	asl a
	phx
	tax
	lda.l HdmaCountFileLUT+BaseAdress,x
	plx
	sta.w HdmaBufferRomCountPnt,x
	lda.w #(:HdmaCountFileLUT+BaseAdress>>16)
	sta.w HdmaBufferRomCountPnt+2,x			;store bank

	txa						;setup relative pointer to hdma table in ram
;	clc
;	adc.w #HdmaBuffer
	sta.w HdmaBufferEntryPnt,x

/*
	lda.w HdmaBufferSubRout,x
	and.w #$ff
	asl a
	tax
;	phy
	jsr (HdmaEffectSubroutineLUT,x)

;	ply

*/

	sep #$20
	lda.w HdmaBufferFlags,x				;set active flag
	ora.b #$80
	sta.w HdmaBufferFlags,x
	
	rep #$31
	lda.w HdmaBufferSubRout,x
	stx.w HdmaListPointer
	and.w #$ff
	asl a
	tax
	
	jsr (HdmaEffectSubroutineLUT,x)	;execute subroutine once without irq interfering so it can properly init

	
		
	cli
	plb
	plp
	rts
ProcessHdmaListExitPause:
	sep #$20
	stz.b HdmaFlags
	jmp ProcessHdmaListExit

;executed during irq so that other routines can wait for hdma effects to finish
ProcessHdmaList:
	php
	phb
	sep #$20
	lda.b #$7e
	pha
	plb
;	stz.b HdmaFlags		;clear hdma flags. do this here, not in the nmi. otherwise, effects will flicker if the hdma handler happens to be not executed for a frame or two
	lda.b HdmaPause
	bmi ProcessHdmaListExitPause		;dont execute if pause flag is set
	
	stz.b HdmaListCounter		;clear hdma list counter
	rep #$31
;	stz.b HdmaListPointer
	ldy.w #0
	

ProcessHdmaListLoop:
	lda.w HdmaBufferTableEntry,y			;check if channel is active
	bpl ProcessHdmaListChVoid

	
	sty.b HdmaListPointer			;save pointer for subroutine
	lda.w HdmaBufferSubRout,y
	and.w #$ff
	asl a
	tax
	phy
	jsr (HdmaEffectSubroutineLUT,x)

	ply
	rep #$31
	lda.w HdmaBufferTableEntry,y
	and.w #$7					;get number of hdma table
	inc a						;increment by 2 because lower 2 channels are used by dma
	inc a
	inc a
	asl a						;move to upper nibble
	asl a
	asl a
	asl a
	tax						;use as pointer into dma regs

	lda.w HdmaBufferEntryPnt,y		;get relative pointer to current hdma effect buffer
	clc
	adc.w #HdmaBufferTable & $ffff		;make absolute, start of actual hdma table
	sta.l $4302,x				;store in hdma table pointer

;	lda.w #$00
	sep #$20
	lda.w HdmaBufferWriteConfig,y
	sta.l $4300,x
	lda.w HdmaBufferBBusTarget,y
	sta.l $4301,x

	lda.b #$7e				;hdma table bank
	sta.l $4304,x
	
	lda.w HdmaBufferRomDataPnt+2,y
	sta.l $4307,x				;indirect data table bank

	lda.w HdmaBufferTableEntry,y
	rep #$31
	and.w #$7					;get number of hdma table
	inc a						;increment by 2 because lower 2 channels are used by dma
	inc a
	inc a
	phx

	tax
	sep #$20
	lda.l (HdmaChannelOrLUT+BaseAdress),x			;get corresponding channel bit
	ora.b HdmaFlags
	sta.b HdmaFlags					;set bit in hdma flags
	plx
;	bra ProcessHdmaListChComplete
	

ProcessHdmaListChComplete:	
	sep #$20
	inc.w HdmaListCounter
	
	rep #$31
	tya
	clc
	adc.w #HdmaBufferSize
	tay
	cmp.w #HdmaBufferSize*5
	bcc ProcessHdmaListLoop


ProcessHdmaListExit:	
	plb
	plp
	rts

	
	
ProcessHdmaListChVoid:	
	sep #$20
	lda.w HdmaListCounter
	and.b #$7					;get number of hdma table
	inc a						;increment by 2 because lower 2 channels are used by dma
	inc a
	inc a
	phx
	tax
	lda.l (HdmaChannelOrLUT+BaseAdress),x			;get corresponding channel bit
	eor.b #$ff
	and.b HdmaFlags
	sta.b HdmaFlags					;clear bit in hdma flags if channel isn't active
	plx
	bra ProcessHdmaListChComplete

; $ff in count table means loop around
HdmaHelperUploadCountTable:
	php
	rep #$31
	ldx.b HdmaListPointer
	lda.w #3
	sta.b TempBuffer+4			;add counter

	lda.w #600
	sta.b TempBuffer+2			;end counter
	lda.w HdmaBufferWriteConfig,x		;get write config
	bit.w #%01000111			;check transfer mode (1 reg write once direct)
	bne HdmaHelperUploadCountIndirect

	lda.w #400
	sta.b TempBuffer+2			;end counter

	lda.w #2
	sta.b TempBuffer+4			;add counter

HdmaHelperUploadCountIndirect:
	lda.b HdmaListPointer			;get relative list pointer
	tax
	clc
	adc.b TempBuffer+2
	sta.b TempBuffer			;this is our upload counter

	lda.w HdmaBufferRomCountPnt,x		;store pointer to count table
	sta.b ThreeBytePointerLo
	lda.w HdmaBufferRomCountPnt+1,x
	sta.b ThreeBytePointerHi

	ldy.w #0
	sep #$20
	
HdmaHelperUploadCountTableLoop:
	lda.b [ThreeBytePointerLo],y

;	cmp.b #$fe
	beq HdmaHelperUploadCountTableExit

	cmp.b #$ff
	bne HdmaHelperUploadCountTableNoWrap


	ldy.w #0				;reset rom table pointer
	bra HdmaHelperUploadCountTableLoop

HdmaHelperUploadCountTableNoWrap:
	sta.w HdmaBufferTable,x
	iny

;	inx
;	inx
;	inx

	rep #$31
	txa
	adc.b TempBuffer+4
	tax
	
	sep #$20

	cpx.b TempBuffer
	bcc HdmaHelperUploadCountTableLoop

HdmaHelperUploadCountTableExit:
	stz.w HdmaBufferTable,x			;always store "terminate" command when done
	plp
	rts

HdmaHelperWobble:
	php
	rep #$31
	lda.b FrameCounterLo
	and.w #3
	beq HdmaHelperWobbleNoExit

	plp
	rts
	
HdmaHelperWobbleNoExit:	
	lda.b HdmaListPointer			;get relative list pointer
	tax
	adc.w #600
	sta.b TempBuffer+2			;this is our upload counter

	lda.w HdmaBufferRomDataLength,x		;get rom data table length
	clc
	adc.w HdmaBufferRomDataPnt,x		;add total file offset
	sta.b TempBuffer+6			;max value for indirect hdma pointer

	lda.w HdmaBufferRomDataPnt,x		;get rom data table initial offset
	sta.b TempBuffer+4			;minimum indirect hdma pointer


HdmaHelperWobbleLoop:
	lda.w HdmaBufferTable,x			;check if ram table finished
	and.w #$ff
	beq HdmaHelperWobbleExit

	lda.w HdmaBufferTable+1,x		;store in indirect adress
	inc a
	inc a
	cmp.b TempBuffer+6			;compare if at maximum of data table
	bcc HdmaHelperWobbleNoWrap

	lda.b TempBuffer+4			;get rom data table initial offset
	
HdmaHelperWobbleNoWrap:
	sta.w HdmaBufferTable+1,x

	inx
	inx
	inx
	
	cpx.b TempBuffer+2
	bne HdmaHelperWobbleLoop

HdmaHelperWobbleExit:
	plp
	rts

;uploads rom data table to wram and updates pointers when the rom is bankswitched and hdma cant access is correctly	
HdmaHelperUploadDataTableWram:
	php
	rep #$31
	ldx.b HdmaListPointer			;get relative list pointer

	lda.w HdmaBufferRomDataLength,x		;get rom data table length
	sta.b TempBuffer			;this is our upload counter	
	lda.w HdmaBufferRomDataPnt,x		;get pointer to data table
	sta.b TempBuffer+2
	lda.w HdmaBufferRomDataPnt+1,x		;get pointer to data table
	sta.b TempBuffer+3
	ldy.w #0

	
HdmaHelperUploadDataTableWramLoop:
	lda.b [TempBuffer+2],y
	sta.w HdmaDataBuffer1&$ffff,y
	iny
	iny
	cpy.b TempBuffer
	bcc HdmaHelperUploadDataTableWramLoop

	lda.w #$7e00	
	sta.w HdmaBufferRomDataPnt+1,x		;store new bank
	lda.w #HdmaDataBuffer1&$ffff
	sta.w HdmaBufferRomDataPnt,x		;store new adress in ram
	plp
	rts

;uploads complete direct data/count table from table LUT. table must have one byte count, two bytes data
;in: a,8bit :number of table to load
HdmaHelperUploadDirectTable:
	php
	rep #$31
	and.w #$ff
	asl a
	tax
	

	
	lda.l HdmaCountDataFileLUT+BaseAdress,x
	sta.b TempBuffer+2
	
	sep #$20
	lda.b #(:HdmaCountDataFileLUT+BaseAdress>>16)
	sta.b TempBuffer+4
		
;	lda.w HdmaBufferRomDataLength,x		;get rom data table length
;	lda.w HdmaBufferRomCountPnt,x		;get pointer to data table
;	sta.b TempBuffer+2
;	lda.w HdmaBufferRomCountPnt+1,x		;get pointer to data table
;	sta.b TempBuffer+3

	rep #$31
	lda.b HdmaListPointer			;get relative list pointer
	tax
;	clc
	adc.w #200*3				;maximum number of scanlines:
	sta.b TempBuffer			;this is our upload counter	

	ldy.w #0

	
HdmaHelperUploadDirectTableLoop:
	lda.b [TempBuffer+2],y
	and.w #$ff
	beq HdmaHelperUploadDirectTableExit	;check if table ends prematurely
;	sta.w HdmaDataBuffer1&$ffff,y
	cmp.w #$ff
	bne HdmaHelperUploadDirectTableNoWrap	;check if table wraps around

	ldy.w #0
	bra HdmaHelperUploadDirectTableLoop

HdmaHelperUploadDirectTableNoWrap:
	sta.w HdmaBufferTable,x			;store count byte
	iny
	inx
	lda.b [TempBuffer+2],y	
	sta.w HdmaBufferTable,x			;store data word
	
	iny
	iny
	

	inx
	inx
	cpx.b TempBuffer			;end if hdma table overflows
	bcc HdmaHelperUploadDirectTableLoop

HdmaHelperUploadDirectTableExit:
	plp
	rts



	
;sets pointer so that each data table entry goes to one count value. 
;input	a,8bit:number of bytes of every data table entry(1 for bytewise, 2 for wordwise etc)
HdmaHelperUploadDataTableLinear:
	php
	rep #$31
	and.w #$7				;max value:7
	sta.b TempBuffer			;store count value
	lda.b HdmaListPointer			;get relative list pointer
	tax
	adc.w #600
	sta.b TempBuffer+2			;this is our upload counter

	lda.w HdmaBufferRomDataLength,x		;get rom data table length
	clc
	adc.w HdmaBufferRomDataPnt,x		;add total file offset
	sta.b TempBuffer+6			
	lda.w HdmaBufferRomDataPnt,x		;get pointer to data table
	sta.b TempBuffer+4


HdmaHelperUpdateDataTableLoop:

	tay
	lda.w HdmaBufferTable,x			;check if ram table finished
	and.w #$ff
	beq HdmaHelperUpdateDataTableExit
	
	tya

	cmp.w TempBuffer+6			;check if at end of rom data file
	bcc HdmaHelperUpdateDataTable
	
	lda.b TempBuffer+4			;wrap rom data table if at end

HdmaHelperUpdateDataTable:	
	
	sta.w HdmaBufferTable+1,x		;store in indirect adress
	clc
	adc.b TempBuffer


	inx
	inx
	inx


	cpx.b TempBuffer+2
	bcc HdmaHelperUpdateDataTableLoop

HdmaHelperUpdateDataTableExit:	
	plp
	rts




HdmaChannelOrLUT:
	.db %00000001			;channel 1, unused for hdma
	.db %00000010			;channel 2, unused for hdma
	.db %00000100
	.db %00001000
	.db %00010000
	.db %00100000
	.db %01000000
;	.db %10000000
	.db %00000000			;never use channel 7, it's reserved for spc streaming

HdmaBufferRelativePointerLUT:
	.dw HdmaBuffer-HdmaBuffer
	.dw HdmaBuffer1-HdmaBuffer
	.dw HdmaBuffer2-HdmaBuffer
	.dw HdmaBuffer3-HdmaBuffer
	.dw HdmaBuffer4-HdmaBuffer
	.dw HdmaBuffer5-HdmaBuffer
	
	
	