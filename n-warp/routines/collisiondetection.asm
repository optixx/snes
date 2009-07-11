;input: x=x-pixel(16bit)
;	y=y-pixel(16bit)
;output: carry(set if pixel is solid,clear if its free)
;collision map format:8 horizontal pixels per byte

CheckCollisionBGandExit:

	phx
	phy
	jsr CheckCollisionBackground
	ply
	plx
;	phx
;	phy
;	jsr CheckCollisionExit
;	ply
;	plx

	phx
	phy
	jsr CheckCollisionObject
	ply
	plx
	rts

CheckCollisionBGandMainChara:
	phx
	phy
	jsr CheckCollisionBackground
	ply
	plx
	jsr CheckCollisionMainChara
	rts

CheckCollisionMainChara:
;this routine checks for collision with exits and executes levelloader if hit
;input: x=x-pixel(16bit)
;	y=y-pixel(16bit)
;output: carry(set if exit has been hit)
	php
	rep #$31
	dey	;align position
	dex
	txa
	ldx.b ObjectListPointerCurrent
	sta.b CollisionPixelX
	tya
	sta.b CollisionPixelY

;check right side of mainchara
	lda.w MainCharaXPos
	sec
	sbc.w #MainCharaHotspotSize/2
	cmp.b CollisionPixelX			;if carry is set, object is left of mainchara
	bcs CheckCollisionMainCharaExit

;check left side of mainchara
	clc
	adc.w #MainCharaHotspotSize

	cmp.b CollisionPixelX			;if carry is clear, object is right of mainchara
	bcc CheckCollisionMainCharaExit

;check upper side of mainchara
	lda.w MainCharaYPos
	sec
	sbc.w #MainCharaHotspotSize/2
	cmp.b CollisionPixelY			;if carry is set, object is left of mainchara
	bcs CheckCollisionMainCharaExit

;check lower side of mainchara
	clc
	adc.w #MainCharaHotspotSize

	cmp.b CollisionPixelY			;if carry is clear, object is right of mainchara
	bcc CheckCollisionMainCharaExit






/*
	lda.w MainCharaYPos
	clc
	lsr a	;divide by 16
	lsr a
	lsr a
	lsr a
	lsr a
	and.w #$ff		;mask off some bits
	cmp.b CollisionPixelY
	bne CheckCollisionMainCharaExit
*/
	plp
	sec			;set carry to signal mainchara has been hit,
	rts

CheckCollisionMainCharaExit:
	plp
	rts


CheckCollisionBackground:
	php
	phb
	sep #$20
	lda.b #0
	pha
	plb
	rep #$31

	txa
	sec
	sbc.w #20
	tax

	stx.b CollisionPixelX
	sty.b CollisionPixelY
;	txa
	lsr a			;divide by 8 to get byte offset in collision map
	lsr a
	lsr a
	and.w #$3fff		;mask off upper two bits because of lsr
	tax

	sep #$30
	lda.w MapSizeX
;	and.w #$ff
	sta.w $4202		;calculate byte position by multiplying map size with y-pixels
	sty.w $4203	
	nop
	nop				;2

/*
	sep #$20
	lda.l $004216
	sta.b CollisionTemp
	lda.l $004217
	sta.b CollisionTemp+1

	rep #$31
*/
	rep #$31	;3
	txa			;2, load x byte counter
	adc.w $4216		;add y byte counter to get actual file position
;	adc.b R1
	sta.b CollisionTemp
;because the multiplication registers are only 8bit, we have to manually add bit 8 of y
	tya
	lda.b CollisionPixelY
	bit.w #$100
	beq BgColNoStupidMultOverflow

	lda.w MapSizeX			;multiply by $ff
	and.w #$ff
	xba
	clc

	adc.b CollisionTemp		;add rest of multiplication
	sta.b CollisionTemp
BgColNoStupidMultOverflow:
	lda.b CollisionTemp
	tay
	lda.b [CurrentColMapPointer],y	;get byte from collision map
	and.w #$ff
	beq ColBackgroundPixelClear

	tay				;save byte
	lda.b CollisionPixelX
	and.w #%111			;only get position in a tile(0-7)
	asl a
	tax
	lda.l ColBackgroundBitLUT+BaseAdress,x	;get correct mask bit with a fast LUT
	sta.b CollisionTemp
	tya
	and.b CollisionTemp
	beq ColBackgroundPixelClear

ColBackgroundPixelSolid:
	plb
	plp
	sec
	rts

ColBackgroundPixelClear:
	plb
	plp
	clc
	rts

ColBackgroundBitLUT:
	.dw $0080
	.dw $0040
	.dw $0020
	.dw $0010
	.dw $0008
	.dw $0004
	.dw $0002
	.dw $0001

	.dw $0001
	.dw $0002
	.dw $0004
	.dw $0008
	.dw $0010
	.dw $0020
	.dw $0040
	.dw $0080

CheckCollisionObject:
;this routine checks for collision with objects
;input: x=x-pixel(16bit)
;	y=y-pixel(16bit)
;output: carry(set if exit has been hit)
;	x=relative pointer to object in objectlist that has been hit
	php
	rep #$31
;	sep #$20
	
	txa
	sta.b CollisionPixelX

	tya
	sta.b CollisionPixelY
	
	ldx.w #0
CheckCollisionObjLoop:
	lda.w ObjEntryType-1,x			;object present?
	bpl CheckCollisionObjExit
	bit.w #$0400				;object collidable?
	beq CheckCollisionObjXNoMatch		;if not, proceed to next object.

;check right side of npc
	lda.w ObjEntryXPos,x
	lsr a												;subpixel precision
	lsr a
	lsr a
	lsr a	
	sec
	sbc.w #NPCHotspotSizeX/2
	cmp.b CollisionPixelX			;if carry is set, object is left of mainchara (check if pixel is on the right side of the left border of this object)
	bcs CheckCollisionObjXNoMatch

;check left side of npc
	clc
	adc.w #NPCHotspotSizeX

	cmp.b CollisionPixelX			;if carry is clear, object is right of mainchara (check if pixel is on the left side of the right border of this object)
	bcs CheckCollisionObjXMatch

CheckCollisionObjXNoMatch:
	txa				;update pointer to next list entry
	clc
	adc #ObjectFileSize
	tax
	cpx.w #ObjectFileSize*NumberOfCollidableObjects
	beq CheckCollisionObjExit
	bra CheckCollisionObjLoop

CheckCollisionObjXMatch:

;check upper side of npc
	lda.w ObjEntryYPos,x
	lsr a												;subpixel precision
	lsr a
	lsr a
	lsr a	
	sec
	sbc.w #NPCHotspotSizeY/2
	cmp.b CollisionPixelY			;if carry is set, object is left of mainchara
	bcs CheckCollisionObjYNoMatch

;check lower side of npc
	clc
	adc.w #NPCHotspotSizeY

	cmp.b CollisionPixelY			;if carry is clear, object is right of mainchara
	bcs CheckCollisionObjYMatch

CheckCollisionObjYNoMatch:
	txa				;update pointer to next list entry
	clc
	adc #ObjectFileSize
	tax
	cpx.w #ObjectFileSize*NumberOfCollidableObjects
	beq CheckCollisionObjExit
	bra CheckCollisionObjLoop


CheckCollisionObjYMatch:


	plp
	sec				;collision detected
	rts

CheckCollisionObjExit:
	plp
;	clc				;don't do this. otherwise, bg collision isn't counted
	rts


CheckCollisionExit:
;this routine checks for collision with exits and executes levelloader if hit
;input: x=x-pixel(16bit)
;	y=y-pixel(16bit)
;output: carry(set if exit has been hit)
	php
	rep #$31
;	sep #$20
	dey	;align position
	dex
	txa
	clc
	lsr a	;divide by 32
	lsr a
	lsr a
	lsr a
	lsr a
	and.w #$ff		;mask off some bits
	sta.b CollisionPixelX

	tya
	clc
	lsr a	;divide by 32
	lsr a
	lsr a
	lsr a
	lsr a
	and.w #$ff		;mask off some bits
	sta.b CollisionPixelY
	
	ldx.w #0
CheckCollisionLoop:
	lda.w ExitTargetMap,x
	bpl CheckCollisionExitExit

	lda.w ExitXPosition,x
	and.w #$ff
	cmp.b CollisionPixelX
	beq CheckCollisionXMatch
	
	txa				;update pointer to next list entry
	clc
	adc #ExitFileSize
	tax
	cpx.w #ExitFileSize*16
	beq CheckCollisionExitExit
	bra CheckCollisionLoop

CheckCollisionXMatch:
	lda.w ExitYPosition,x
	and.w #$ff
	cmp.b CollisionPixelY
	beq CheckCollisionYMatch

	txa				;update pointer to next list entry
	clc
	adc #ExitFileSize
	tax
	cpx.w #ExitFileSize*16
	beq CheckCollisionExitExit
	bra CheckCollisionLoop


CheckCollisionYMatch:
	txa
	and.w #$ff			;mask some bits off
	ora.w #$8000			;set "exit hit" flag	
	sta.b ExitCollisionPointer

	lda.w ExitTargetMap,x		;get target map
	and.w #$ff			;mask some bits off
	ora.w #$8000			;set "exit hit" flag	

	sta.w ExitMapTarget
	lda.w ExitXTargetPosition,x
	and.w #$ff
	sta.w ExitXTarget
	lda.w ExitYTargetPosition,x
	and.w #$ff
	sta.w ExitYTarget


CheckCollisionExitExit:
	plp
	rts

CheckCollisionExitLevelLoader:
	php
	sep #$20
	phb
	lda.b #$7e
	pha
	plb

;	rep #$31
;	lda.b ExitCollisionPointer	;check if "exit hit" flag is set
	lda.w ExitMapTarget+1
	bpl CheckCollisionExitLevelLoaderExit
	
;	and.w #$ff			;mask off flag
;	tax				;and get pointer into exit list

;	sep #$20
	lda.w ExitMapTarget		;get target map
	cmp.b CurrentMapNumber
	beq CheckCollisionExitLevelLoaderSameLevel

	lda.b #0
	sta.b ScreenBrightness
	lda.w ExitXTarget
	sta.w MapStartPosX
	lda.w ExitYTarget
	sta.w MapStartPosY
	
	rep #$31



/*	
	lda.b ExitCollisionPointer
	and.w #$ff
	tax
	lda.w ExitTargetMap,x		;get target map
*/	
	lda.w ExitMapTarget
	and.w #$ff
	tax
	jsr LevelLoader			;and load new level

ExitLevelLoaderWaitForUpload:
	lda.b DmaFifoPointer
	bne ExitLevelLoaderWaitForUpload

	sep #$20
	lda.b #4			;create player object
	jsr CreateObject


	lda.b #$ff
	sta.b ScreenBrightness


;	rep #$31	
	



CheckCollisionExitLevelLoaderExit:
	rep #$31
	stz.b ExitCollisionPointer	;clear flag
	stz.w ExitMapTarget
	plb
	plp
	rts

CheckCollisionExitLevelLoaderSameLevel:
	rep #$31
	lda.w ExitYTarget
	and.w #$ff
	pha
	lda.w ExitXTarget
	and.w #$ff
	pha
	lda.w MainCharaObjectNumber
	and.w #$ff	
	clc
	asl a		;multiply by 16 to get offset in object list
	asl a
	asl a
	asl a
	tax
	pla
	clc
	asl a		;multiply by 16 to get new x-pixel position
	asl a
	asl a
	sta.w ObjEntryXPos,x
	sta.w ObjEntryXPos+ObjectFileSize,x
	pla
	clc
	asl a		;multiply by 16 to get new x-pixel position
	asl a
	asl a
	sta.w ObjEntryYPos,x
	clc
	adc #32
	sta.w ObjEntryYPos+ObjectFileSize,x

	bra CheckCollisionExitLevelLoaderExit