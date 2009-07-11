AniSubroutineJumpLUT:
	.dw AniSubroutineMaincharaInit		;0
	.dw AniSubroutineMainchara
	.dw AniSubroutineVoid
	.dw AniSubroutineMaincharaPunch
	.dw AniSubroutineFalling
	.dw AniSubroutineMaincharaFiercePunch	;5
	.dw AniSubroutineFallingFar
	.dw AniSubroutineMaincharaMenuRunningInit
	.dw AniSubroutineMaincharaMenuRunning
	.dw AniSubroutineHealthbarInit
	.dw AniSubroutineMaincharaDead		;10
	.dw AniSubroutineMond
	.dw AniSubroutineMaincharaCheering
	.dw AniSubroutineMaincharaRevive				;prevents animation frame glitch, reset animation frame
	.dw AniSubroutineMaincharaStandUpandReverse		;used after knockdown
	.dw AniSubroutineMaincharaBlocking	;15
	.dw AniSubroutine8x8Particle
	.dw AniSubRandomParticlesInit
	.dw AniSubroutineCpuUsage

AniSubroutineCpuUsage:
	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.w CpuUsageScanline
	asl a												;add subpixel precision
	asl a
	asl a
	asl a	
	sta.w ObjEntryYPos,x
	lda.b #16*16-1								;*16=subpixel precision
	sta.w ObjEntryXPos,x
	rts
	
;this is needed to be able to immediately enter commands while blocking animation is still in effect.
;it does allow for light punching, nothing else
AniSubroutineMaincharaBlocking:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.w BattleFinished
	bpl AniSubroutineMaincharaBlockingNoFinished
	
	lda.b #2
	sta.w ObjEntrySubRout,x				;set to idle
	rts
	
AniSubroutineMaincharaBlockingNoFinished:
	rep #$31

	stz.w ObjEntryMaleInvinc,x			;make character vulnerable if he was invincible before
	lda.w ObjEntryObjectNumber,x
	and.w #$7					;use object number as pointer into joypad data
	asl a
	tax
	lda.w JoyPortBufferTrigger&$ffff,x			;check if a or y(for nes joypad) has been triggered
	and.w #$4080
	beq AniSubroutineMaincharaBlockingNoPunch
	
	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.b #3
	sta.w ObjEntrySubRout,x				;set to punch subroutine

	lda.w ObjEntryMaleDirection,x		;get direction
	and.b #$3
	sta.b TempBuffer
	
	stz.w ObjEntryMaleBlockCounter,x	;reset block counter when attacking
	lda.b R1							;get one of four moves randomly(2 kicks, 2 punches)
	and.b #%1100							;have it already aligned to a *4, because every move has 4 directions
	clc
	adc.b TempBuffer					;add direction
	clc
	adc.b #36							;add number of first normal attack move
	sta.w ObjEntryTileset,x				;set tileset according to direction

	lda.b #3
	sta.w ObjEntryAniList,x				;set punching anilist
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame
	jsr CreateObjUploadSpriteFrame			;upload that frame

	lda.b #6
	jsr SpcPlaySoundEffectObjectXPos
	
	rts

AniSubroutineMaincharaBlockingNoPunch:
	lda.w JoyPortBufferTrigger&$ffff,x			;check if b has been triggered
	bpl AniSubroutineMaincharaBlockingNoFiercePunch

	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.b #2
	sta.w ObjEntrySubRout,x				;set subroutine to void.

	stz.w ObjEntryMaleBlockCounter,x	;reset block counter when attacking
	lda.w ObjEntryMaleDirection,x
	and.b #$3
	clc
	adc.b #12
	sta.w ObjEntryTileset,x				;set tileset according to direction

	lda.b #7
	sta.w ObjEntryAniList,x				;set punching anilist
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame
	jsr CreateObjUploadSpriteFrame			;upload that frame

	rts


AniSubroutineMaincharaBlockingNoFiercePunch:

	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryMaleBlockCounter,x
	beq MaincharaBlockingNoBlockDecrease

	dec.w ObjEntryMaleBlockCounter,x	;decrease block counter till 0	

MaincharaBlockingNoBlockDecrease:

	rts


	
;stand up and turn around, facing attacker after knockdown
AniSubroutineMaincharaStandUpandReverse:
	ldx.b ObjectListPointerCurrent
	rep #$31
	lda.w ObjEntryMaleDirection,x					;load player direction
	and.w #3
	phx
	tax		
	lda.l (MaleTurnAroundLUT+BaseAdress),x						;get opposite direction of attacked player
	plx
	sep #$20
	sta.w ObjEntryMaleDirection,x							;
	

;prevents animation frame glitch, resets animation frames
AniSubroutineMaincharaRevive:
	sep #$20
	ldx.b ObjectListPointerCurrent
	stz.w ObjEntryAniFrame,x
	stz.w ObjEntryTilesetFrame,x
	lda.b #$01
	sta.w ObjEntrySubRout,x
	jmp AniSubroutineMainchara
	
AniSubroutineVoid:
	rts


	
AniSubroutineMond:
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.b FrameCounterLo
	and.w #$7
	bne AniSubroutineMondExit
	

	lda.w ObjEntryYPos,x
	clc
	adc.w #1*16
	sta.w ObjEntryYPos,x
;	inc.w ObjEntryYPos,x


	lda.b FrameCounterLo
	and.w #$8
	bne AniSubroutineMondExit

	lda.w ObjEntryYPos,x
	sec
	sbc.w #1*16
	sta.w ObjEntryYPos,x	
	
;	dec.w ObjEntryXPos,x
	
AniSubroutineMondExit:	
	rts	
	
AniSubroutineMaincharaInit:
	rep #$31
	lda.w PlayerState
	and.w #$3					;4 states max
	asl a
	tax
	jsr (AniSubroutineMaincharaModeSelectLUT,x)
	rts


AniSubroutineMaincharaModeSelectLUT:
	.dw AniSubroutineMaincharaBattleInit
	.dw AniSubroutineMaincharaMenuInit
	.dw AniSubroutineMaincharaResultsInit
	.dw AniSubroutineMaincharaVoid

AniSubroutineMaincharaBattleInit:
	ldx.b ObjectListPointerCurrent
	rep #$31
;check if enabled or not. if not, immediately delete itself	
	lda.w ObjEntryObjectNumber,x
	and.w #7
	phx
	tax
	sep #$20
	lda.l (PlayersPresentFlagsLUT+BaseAdress),x			;get flag for this player
	plx
	sta.b TempBuffer
	lda.w PlayersPresentFlags
	and.b TempBuffer
	bne AniSubroutineMaincharaBattleInitPresent


	stz.w ObjEntryType,x				;delete object
	rts
	
AniSubroutineMaincharaBattleInitPresent:	
	lda.b #1					;goto normal mainchara battle subroutine that gets executed every frame
	sta.w ObjEntrySubRout,x
	
;draw win marks:
	rep #$31
	lda.w ObjEntryObjectNumber,x
	and.w #7
	tax
	asl a
	sta.b TempBuffer
	lda.w (WinnerArray&$ffff),x
	and.w #$ff
	beq AniSubroutineMaincharaBattleInitNoWins
	
	dec a
	clc
	adc.b TempBuffer 
	asl a
	tax
	jsr (WinmarkDrawLUT,x)


AniSubroutineMaincharaBattleInitNoWins:	
	rts


WinmarkDrawLUT:
	.dw WinmarkP11
	.dw WinmarkP12
	
	.dw WinmarkP21
	.dw WinmarkP22

	.dw WinmarkP31
	.dw WinmarkP32

	.dw WinmarkP41
	.dw WinmarkP42

	.dw WinmarkP51
	.dw WinmarkP52

	.dw WinmarkP61
	.dw WinmarkP62

	.dw WinmarkP71
	.dw WinmarkP72

	.dw WinmarkP81
	.dw WinmarkP82


WinmarkP12:
	sep #$20
	lda.b #51
	ldx.w #$0309
	jsr CreateObjectPosition
WinmarkP11:
	sep #$20
	lda.b #51
	ldx.w #$0209
	jsr CreateObjectPosition
	rts

WinmarkP22:
	sep #$20
	lda.b #51
	ldx.w #$030f
	jsr CreateObjectPosition
WinmarkP21:
	sep #$20
	lda.b #51
	ldx.w #$020f
	jsr CreateObjectPosition
	rts

WinmarkP32:
	sep #$20
	lda.b #51
	ldx.w #$0315
	jsr CreateObjectPosition
WinmarkP31:
	sep #$20
	lda.b #51
	ldx.w #$0215
	jsr CreateObjectPosition
	rts

WinmarkP42:
	sep #$20
	lda.b #51
	ldx.w #$031b
	jsr CreateObjectPosition
WinmarkP41:
	sep #$20
	lda.b #51
	ldx.w #$021b
	jsr CreateObjectPosition
	rts

WinmarkP52:
	sep #$20
	lda.b #51
	ldx.w #$1709
	jsr CreateObjectPosition
WinmarkP51:
	sep #$20
	lda.b #51
	ldx.w #$1609
	jsr CreateObjectPosition
	rts

WinmarkP62:
	sep #$20
	lda.b #51
	ldx.w #$170f
	jsr CreateObjectPosition
WinmarkP61:
	sep #$20
	lda.b #51
	ldx.w #$160f
	jsr CreateObjectPosition
	rts

WinmarkP72:
	sep #$20
	lda.b #51
	ldx.w #$1715
	jsr CreateObjectPosition
WinmarkP71:
	sep #$20
	lda.b #51
	ldx.w #$1615
	jsr CreateObjectPosition
	rts

WinmarkP82:
	sep #$20
	lda.b #51
	ldx.w #$171b
	jsr CreateObjectPosition
WinmarkP81:
	sep #$20
	lda.b #51
	ldx.w #$161b
	jsr CreateObjectPosition
	rts


AniSubroutineHealthbarInit:
	ldx.b ObjectListPointerCurrent
	rep #$31
;check if corresponding player is enabled or not. if not, immediately delete itself	
	lda.w ObjEntryObjectNumber,x
	and.w #7
	phx
	tax
	sep #$20
	lda.l (PlayersPresentFlagsLUT+BaseAdress),x			;get flag for this player
	plx
	sta.b TempBuffer
	lda.w PlayersPresentFlags
	and.b TempBuffer
	bne AniSubroutineHealthbarPresent


	stz.w ObjEntryType,x				;delete object

AniSubroutineHealthbarPresent:	
;	lda.b #2					;goto void subroutine
	lda.w ObjEntryType,x				;disable subroutine processing for this sprite
	and.b #%11110111
	sta.w ObjEntryType,x
	rts

;executed after death slide animation:
AniSubroutineMaincharaDead:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.w BattleFinished
	bpl AniSubroutineDeadNoFinished
	
	lda.b #2
	sta.w ObjEntrySubRout,x				;set to idle
	rts
	
AniSubroutineDeadNoFinished:

	sep #$20
	lda.w ObjEntryType,x
	and.b #%11111011					;make character uncollidable
	sta.w ObjEntryType,x
	rep #$31
	lda.w ObjEntryObjectNumber,x
	and.w #$7					;use object number as pointer into joypad data
	asl a
	tax
	lda.w JoyPortBufferTrigger&$ffff,x			;check if any button has been triggered
	
	beq AniSubroutineMaincharaMenuNoSpasm

	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.b #13
	sta.w ObjEntryAniList,x				;set spasm anilist
	stz.w ObjEntryAniFrame,x			;reset frame
	lda.w ObjEntryMaleSpasmCount,x			;increment spasm counter
	inc a
	sta.w ObjEntryMaleSpasmCount,x
	cmp.b #SpasmToRespawn				;check if spasm count to respawn was reached
	bne AniSubroutineMaincharaMenuNoSpasm



	rep #$31
	lda.w ObjEntryObjectNumber,x			;get targets object number
	and.w #$7
	clc
	adc.w #8					;add 8 to get corresponding healthmeter
	jsr SeekObject
	bcs ReviveHealthmeterNotFound

	sep #$20


	
	inc.w ObjEntryTilesetFrame,x			;increase healthmeter 
	jsr CreateObjUploadSpriteFrame			;upload that frame	

	ldx.b ObjectListPointerCurrent

	lda.w ObjEntryType,x
	ora.b #%100					;make character collidable again
	sta.w ObjEntryType,x

	lda.b #4
	sta.w ObjEntryAniList,x				;set to standing still
	stz.w ObjEntryAniFrame,x
	stz.w ObjEntryTilesetFrame,x
	stz.w ObjEntryTileset,x	
	
	inc.w ObjEntryMaleHP,x
	lda.b #1
	sta.w ObjEntrySubRout,x
	
	jsr CheckRemainingPlayers			;update number of active players
ReviveHealthmeterNotFound:	



AniSubroutineMaincharaMenuNoSpasm:
	rts

;sitting idle in menu
AniSubroutineMaincharaMenuInit:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.b #18				
	sta.w ObjEntryTileset,x				;set tileset, sitting
	lda.b #11
	sta.w ObjEntryAniList,x				;set punching anilist

	rep #$31
	lda.w ObjEntryObjectNumber,x
	and.w #$7					;use object number as pointer into joypad data
	asl a
	tax
	lda.w JoyPortBufferTrigger&$ffff,x			;check if any button has been triggered
	
	beq AniSubroutineMaincharaMenuNoStart

	ldx.b ObjectListPointerCurrent


;	lda.w PlayersPresentFlags
	phx
	lda.w ObjEntryObjectNumber,x
	and.w #7
	tax
	sep #$20
	lda.l (PlayersPresentFlagsLUT+BaseAdress),x			;get flag for this player
	ora.w PlayersPresentFlags
	sta.w PlayersPresentFlags			;save to player present flag var
	
	plx
	lda.b #12					;stand up and nod
	sta.w ObjEntryAniList,x
	stz.w ObjEntryAniFrame,x
	stz.w ObjEntryTilesetFrame,x
	lda.b #2
	sta.w ObjEntrySubRout,x				;set subroutine to void(else this subroutine here overwrites the animation list)

AniSubroutineMaincharaMenuNoStart:	
	rts


AniSubroutineMaincharaMenuRunningInit:	
	sep #$20
	ldx.b ObjectListPointerCurrent
;	stz.w ObjEntryMaleInvinc,x			;make character vulnerable if he was invincible before

	lda.b #4
	sta.w ObjEntryAniList,x				;set to standing still
	stz.w ObjEntryAniFrame,x
	stz.w ObjEntryTilesetFrame,x
	stz.w ObjEntryTileset,x	
	lda.b #8
	sta.w ObjEntrySubRout,x				;set subroutine to void(else this subroutine here overwrites the animation list)

	jsr CreateObjUploadSpriteFrame			;upload that frame
	rts

AniSubroutineMaincharaCheering:
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryObjectNumber,x
	and.w #$7					;use object number as pointer into joypad data
	asl a
	tax
	lda.w JoyPortBuffer&$ffff+1,x		;get start bit of winner joypad (only winner can reset game)
	sep #$20
	bit.b #%00010000
	beq AniSubroutineMaincharaCheeringNoReset

	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #28
	sta.w BrightnessEventBuffer	;jump to gra logo play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent	


AniSubroutineMaincharaCheeringNoReset:
	rts	

AniSubroutineMaincharaMenuRunning:
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryObjectNumber,x
	and.w #$7					;use object number as pointer into joypad data
	asl a
	tax
	lda.w JoyPortBuffer&$ffff+1,x		;get left/right/up/down bits of joypad
	and.w #$f
	asl a
	tax				;use as pointer into jump table
	jsr (MainCharaMoveLUT,x)

	rts


PlayersPresentFlagsLUT:
	.db %1
	.db %10
	.db %100
	.db %1000
	.db %10000
	.db %100000
	.db %1000000
	.db %10000000



AniSubroutineMaincharaResultsInit:
	ldx.b ObjectListPointerCurrent
	rep #$31
;check if enabled or not. if not, immediately delete itself	
	lda.w ObjEntryObjectNumber,x
	and.w #7
	phx
	tax
	sep #$20
	lda.l (PlayersPresentFlagsLUT+BaseAdress),x			;get flag for this player
	plx
	sta.b TempBuffer
	lda.w PlayersPresentFlags
	and.b TempBuffer
	bne AniSubroutineMaincharaBattleInitPresent2


	stz.w ObjEntryType,x				;delete itself
	rts
AniSubroutineMaincharaBattleInitPresent2:	

;	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.w ObjEntryObjectNumber,x
	cmp.w WinningPlayer
	beq AniSubroutineMaincharaResultsWinner

	lda.b #9
	sta.w ObjEntryAniList,x				;set to crying
	stz.w ObjEntryAniFrame,x
	stz.w ObjEntryTilesetFrame,x
	lda.b #16					;tileset crying
	sta.w ObjEntryTileset,x
	lda.b #2
	sta.w ObjEntrySubRout,x				;set to void
		
	rts



AniSubroutineMaincharaResultsWinner:
	rep #$31
	lda.w #16*8*16
	sta.w ObjEntryXPos,x				;move winner to podium
	lda.w #11*8*16
	sta.w ObjEntryYPos,x

	sep #$20
	lda.b #14
	sta.w ObjEntryAniList,x				;set to crying
	stz.w ObjEntryAniFrame,x
	stz.w ObjEntryTilesetFrame,x
	lda.b #19					;tileset crying
	sta.w ObjEntryTileset,x
	lda.b #12
	sta.w ObjEntrySubRout,x				;wait for start pressed to reset	
	rts
	
AniSubroutineMaincharaVoid:
	rts

AniSubroutineMainchara:	
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.w BattleFinished
	bpl AniSubroutineMaincharaNoFinished

	lda.w ObjEntryType,x
	and.b #%11100111					;disable subroutine and animation
	sta.w ObjEntryType,x
	
;	lda.b #2
;	sta.w ObjEntrySubRout,x				;set to idle
	rts
	
AniSubroutineMaincharaNoFinished:
	rep #$31

	stz.w ObjEntryMaleInvinc,x			;make character vulnerable if he was invincible before
	lda.w ObjEntryObjectNumber,x
	and.w #$7					;use object number as pointer into joypad data
	asl a
	tax
	lda.w JoyPortBufferTrigger&$ffff,x			;check if a or y(for nes joypad) has been triggered
	and.w #$4080
	beq AniSubroutineMaincharaNoPunch
	
	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.b #3
	sta.w ObjEntrySubRout,x				;set to punch subroutine

	stz.w ObjEntryMaleBlockCounter,x	;reset block counter when attacking
	lda.w ObjEntryMaleDirection,x		;get direction
	and.b #$3
	sta.b TempBuffer
	
	lda.b R1							;get one of four moves randomly(2 kicks, 2 punches)
	and.b #%1100							;have it already aligned to a *4, because every move has 4 directions
	clc
	adc.b TempBuffer					;add direction
	clc
	adc.b #36							;add number of first normal attack move
	sta.w ObjEntryTileset,x				;set tileset according to direction

	lda.b #3
	sta.w ObjEntryAniList,x				;set punching anilist
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame
	jsr CreateObjUploadSpriteFrame			;upload that frame

	lda.b #6
	jsr SpcPlaySoundEffectObjectXPos
	rts

AniSubroutineMaincharaNoPunch:	
	lda.w JoyPortBufferTrigger&$ffff,x			;check if b has been triggered
	bpl AniSubroutineMaincharaNoFiercePunch

	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.b #2
	sta.w ObjEntrySubRout,x				;set subroutine to void.

	stz.w ObjEntryMaleBlockCounter,x	;reset block counter when attacking
	lda.w ObjEntryMaleDirection,x
	and.b #$3
	clc
	adc.b #12
	sta.w ObjEntryTileset,x				;set tileset according to direction

	lda.b #7
	sta.w ObjEntryAniList,x				;set punching anilist
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame
	jsr CreateObjUploadSpriteFrame			;upload that frame

	rts


AniSubroutineMaincharaNoFiercePunch:
	sep #$20
	lda.w JoyPortBufferTrigger&$ffff,x
	phx
	ldx.b ObjectListPointerCurrent
	and.b #$40
	beq MaincharaNoBlockRefresh			
;if any direction has been triggered, init block counter
	lda.b #DefaultBlockCounter
	sta.w ObjEntryMaleBlockCounter,x	;set block counter

	lda.w ObjEntryMaleDirection,x
	and.b #$03
	clc
	adc.b #28
	sta.w ObjEntryTileset,x				;set blocking tileset

	lda.b #2						;x now contains relative pointer to that sprite
	sta.w ObjEntrySubRout,x			;set to idle

	lda.b #22
	sta.w ObjEntryAniList,x				;set falling anilist
	
;	lda.b TempBuffer				;set direction
	
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame


	
	jsr CreateObjUploadSpriteFrame			;upload that frame	

	plx
	rts

MaincharaNoBlockRefresh:

	lda.w ObjEntryMaleBlockCounter,x
	beq MaincharaNoBlockDecrease

	dec.w ObjEntryMaleBlockCounter,x	;decrease block counter till 0	

MaincharaNoBlockDecrease:
	plx
	rep #$31
	lda.w JoyPortBuffer&$ffff+1,x		;get left/right/up/down bits of joypad
	and.w #$f
	asl a
	tax				;use as pointer into jump table
	jsr (MainCharaMoveLUT,x)
	ldx.b ObjectListPointerCurrent
	rts

AniSubroutineFalling:
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryMaleDirection,x
	and.w #$3			;get direction
	sta.b TempBuffer
	asl a
	tax				;use as pointer into jump table
	phx
	jsr (MainCharaFallingLUT,x)	;
	plx
	jsr (MainCharaFallingLUT,x)	;move two pixels per frame

	rts

AniSubroutineFallingFar:
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryMaleDirection,x
	and.w #$3			;get direction
	sta.b TempBuffer
	asl a
	tax				;use as pointer into jump table
	phx
	jsr (MainCharaFallingLUT,x)	;
	plx
	phx
	jsr (MainCharaFallingLUT,x)	;move three pixels per frame
	plx
	jsr (MainCharaFallingLUT,x)	

	rts
MainCharaFallingLUT:
	.dw MainCharaFallDown
	.dw MainCharaFallUp
	.dw MainCharaFallLeft
	.dw MainCharaFallRight

MainCharaFallUp:
	ldx.b ObjectListPointerCurrent
	rep #$31
	lda.w ObjEntryMaleDirection,x
	and.w #$3			;get direction
	sta.b TempBuffer
		
	lda ObjEntryYPos,x
	lsr a														;remove subpixel precision
	lsr a
	lsr a
	lsr a
	sec
	sbc.w #(NPCHotspotSizeY/2)+1		;make this one bigger
;	dec a
	tay
	lda ObjEntryXPos,x
	lsr a														;remove subpixel precision
	lsr a
	lsr a
	lsr a
	
	tax

	phy
	phx
	jsr CheckCollisionBackground
	plx
	ply	
	bcs MainCharaFallUpBGColli

;only check for sprite collision if no wall has been hit:
	jsr AniSubroutineMainCharaPunchExec
	bcs MainCharaFallUpBGColli
	
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryYPos,x
;	dec a
	sec
	sbc.w #1*16
	sta.w ObjEntryYPos,x				;upper body
	rts

MainCharaFallUpBGColli:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.b #$2					;put into idle if wall was hit
	sta.w ObjEntrySubRout,x				;upper body

	rts
	
	
MainCharaFallLeft:
	ldx.b ObjectListPointerCurrent
	rep #$31
	lda.w ObjEntryMaleDirection,x
	and.w #$3			;get direction
	sta.b TempBuffer
		
	rep #$31
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a

	sec
	sbc.w #(NPCHotspotSizeX/2)+1
;	dec a
	tax

	phy
	phx
	jsr CheckCollisionBackground
	plx
	ply	
	bcs MainCharaFallLeftBGColli

;only check for sprite collision if no wall has been hit:
	jsr AniSubroutineMainCharaPunchExec
	bcs MainCharaFallLeftBGColli
	
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryXPos,x
;	dec a
	sec
	sbc.w #1*16
	sta.w ObjEntryXPos,x				;upper body
	rts

MainCharaFallLeftBGColli:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.b #$2					;put into idle if wall was hit
	sta.w ObjEntrySubRout,x				;upper body

	rts
MainCharaFallRight:
	ldx.b ObjectListPointerCurrent
	rep #$31
	lda.w ObjEntryMaleDirection,x
	and.w #$3			;get direction
	sta.b TempBuffer
		
	rep #$31
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a

	clc
	adc.w #(NPCHotspotSizeX/2)+1
;	inc a
	tax

	phy
	phx
	jsr CheckCollisionBackground
	plx
	ply	
	bcs MainCharaFallRightBGColli

;only check for sprite collision if no wall has been hit:
	jsr AniSubroutineMainCharaPunchExec
	bcs MainCharaFallRightBGColli
	
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryXPos,x
;	inc a
	clc
	adc.w #1*16
	sta.w ObjEntryXPos,x				;upper body
	rts

MainCharaFallRightBGColli:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.b #$2					;put into idle if wall was hit
	sta.w ObjEntrySubRout,x				;upper body

	rts


MainCharaFallDown:
	ldx.b ObjectListPointerCurrent
	rep #$31
	lda.w ObjEntryMaleDirection,x
	and.w #$3			;get direction
	sta.b TempBuffer
		
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	adc.w #(NPCHitPointSizeY/2)+1			;make this one bigger
;	inc a
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	tax

	phy
	phx
	jsr CheckCollisionBackground
	plx
	ply	
	bcs MainCharaFallDownBGColli

;only check for sprite collision if no wall has been hit:
	jsr AniSubroutineMainCharaPunchExec
	bcs MainCharaFallDownBGColli
	
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryYPos,x
;	inc a
	clc
	adc.w #1*16
	sta.w ObjEntryYPos,x				;upper body
	rts

MainCharaFallDownBGColli:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.b #$2					;put into idle if wall was hit
	sta.w ObjEntrySubRout,x				;upper body

	rts

FiercePunchNoColliDetect:	
	rts

AniSubroutineMaincharaFiercePunch:
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryMaleDirection,x
	and.w #$3			;get direction
	sta.b TempBuffer
	stx.b TempBuffer+18	;keep pointer in case hit is blocked
	asl a
	tax				;use as pointer into jump table
	jsr (MainCharaPunchLUT,x)	;setup collision pixel

	clc
	jsr CheckCollisionObject
	bcc FiercePunchNoColliDetect

	sep #$20					;collision with object detected

	

	lda.w ObjEntryMaleInvinc,x
	bne FiercePunchNoColliDetect				;do no harm if object is invincible

	lda.w ObjEntryMaleBlockCounter,x
	beq FiercePunchNoBlock		;blocking?

;check if players are facing each other. if the aren't, block has no effect
	rep #$31
	lda.w ObjEntryMaleDirection,x					;load player direction
	and.w #3
	phx
	tax		
	lda.l (MaleTurnAroundLUT+BaseAdress),x						;get opposite direction of attacked player
	plx
	sep #$20
	cmp.b TempBuffer
	bne FiercePunchNoBlock
	
	jmp BlockSuccess

FiercePunchNoBlock:	
	
	
	inc.w ObjEntryMaleInvinc,x			;make player invincible when hit

	rep #$31
	phx
	lda.b TempBuffer
	pha
	lda.w ObjEntryObjectNumber,x			;get targets object number
	and.w #$ff
	clc
	adc.w #8					;add 8 to get corresponding healthmeter
	jsr SeekObject
	bcs FiercePunchHealthmeterNotFound

	sep #$20
	dec.w ObjEntryTilesetFrame,x			;decrease healthmeter 
	beq FiercePunchHealthmeterZero
	dec.w ObjEntryTilesetFrame,x
	
	

FiercePunchHealthmeterZero:	
	jsr CreateObjUploadSpriteFrame			;upload that frame	

FiercePunchHealthmeterNotFound:	
	rep #$31
	pla
	sta.b TempBuffer
	plx
	sep #$20
	
	lda.b #6					;x now contains relative pointer to that sprite
	sta.w ObjEntrySubRout,x				;set to falling subroutine

	lda.b #8
	clc
	adc.b TempBuffer
	sta.w ObjEntryTileset,x				;set falling tileset

	lda.b #8
	sta.w ObjEntryAniList,x				;set falling far anilist
	
	lda.b TempBuffer				;set direction
	sta.w ObjEntryMaleDirection,x
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame

	lda.b #2
	jsr OamSubCreateParticles
	
	dec.w ObjEntryMaleHP,x				;decrease health by 2
	beq AniSubroutineMainCharaPunchDie
	dec.w ObjEntryMaleHP,x
	beq AniSubroutineMainCharaPunchDie

	jsr CreateObjUploadSpriteFrame			;upload that frame	
	
	lda.b #3
	jsr SpcPlaySoundEffectObjectXPos



	rts

AniSubroutineMainCharaPunchDie:
;	stz.w ObjEntryMaleSpasmCount,x			;reset spasm counter
	lda.b #10
	sta.w ObjEntryAniList,x				;set dying anilist
	jsr CreateObjUploadSpriteFrame			;upload that frame	

	

	lda.b #4
	jsr SpcPlaySoundEffectObjectXPos

	jsr CheckRemainingPlayers	
	rts
	




;for falling, fierce punch and all other unblockable moves
AniSubroutineMainCharaPunchExec:
	clc
	jsr CheckCollisionObject
	bcc PunchNoColliDetect

;	sep #$20					;collision with object detected
;	lda.w ObjEntryMaleBlockCounter,x
;	bne PunchNoColliDetect		;just a test for blocking
	lda.w ObjEntryMaleInvinc,x
	bne PunchNoColliDetect				;do no harm if object is invincible
	
	inc a
	sta.w ObjEntryMaleInvinc,x			;make player invincible when hit


	rep #$31
	phx
	lda.b TempBuffer
	pha
	lda.w ObjEntryObjectNumber,x			;get targets object number
	and.w #$ff
	clc
	adc.w #8					;add 8 to get corresponding healthmeter
	jsr SeekObject
	bcs PunchHealthmeterNotFound

	sep #$20
	dec.w ObjEntryTilesetFrame,x			;decrease healthmeter 
	jsr CreateObjUploadSpriteFrame			;upload that frame	


PunchHealthmeterNotFound:	
	rep #$31
	pla
	sta.b TempBuffer
	plx
	sep #$20

	
	
	lda.b #4					;x now contains relative pointer to that sprite
	sta.w ObjEntrySubRout,x				;set to falling subroutine

	lda.b #8
	clc
	adc.b TempBuffer
	sta.w ObjEntryTileset,x				;set falling tileset

	lda.b #5
	sta.w ObjEntryAniList,x				;set falling anilist
	
	lda.b TempBuffer				;set direction
	sta.w ObjEntryMaleDirection,x
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame

	lda.b #1
	jsr OamSubCreateParticles
	
	dec.w ObjEntryMaleHP,x
	beq AniSubroutineMainCharaPunchDie

	
	jsr CreateObjUploadSpriteFrame			;upload that frame	
	
	lda.b R1
	and.b #%11
	clc
	adc.b #7								;choose randomly between 4 punching sounds(only pitch differs)
	jsr SpcPlaySoundEffectObjectXPos


	sec
PunchNoColliDetect:	
	rts


;	jsr SpcPlaySoundEffectObjectXPos

MainCharaPunchLUT:
	.dw MainCharaPunchDown
	.dw MainCharaPunchUp
	.dw MainCharaPunchLeft
	.dw MainCharaPunchRight




MainCharaPunchDown:
	ldx.b ObjectListPointerCurrent
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	adc.w #NPCHitPointSizeY
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a

	inc a
	tax
	rts

MainCharaPunchUp:
	ldx.b ObjectListPointerCurrent
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
	sec
	sbc.w #NPCHitPointSizeY
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
	inc a
	tax
	rts
MainCharaPunchLeft:
	ldx.b ObjectListPointerCurrent
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	sec
	sbc.w #NPCHitPointSizeX+6	
;	inc a
	tax
	rts
MainCharaPunchRight:
	ldx.b ObjectListPointerCurrent
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a

	clc
	adc.w #NPCHitPointSizeX+6
;	inc a
	tax
	rts


AniSubroutineMaincharaPunchExit:
	rts	

AniSubroutineMaincharaPunch:
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryMaleDirection,x
	and.w #$3			;get direction
	sta.b TempBuffer
	stx.b TempBuffer+18	;keep pointer in case hit is blocked
	asl a
	tax				;use as pointer into jump table
	jsr (MainCharaPunchLUT,x)	;setup collision pixel

;normal punch, blockable
	clc
	jsr CheckCollisionObject
	bcc AniSubroutineMaincharaPunchExit

	sep #$20					;collision with object detected

	lda.w ObjEntryMaleInvinc,x
	bne AniSubroutineMaincharaPunchExit				;do no harm if object is invincible
	
	lda.w ObjEntryMaleBlockCounter,x
	beq NormalPunchNoBlock		;blocking?

;check if players are facing each other. if the aren't, block has no effect
	rep #$31
	lda.w ObjEntryMaleDirection,x					;load player direction
	and.w #3
	phx
	tax		
	lda.l (MaleTurnAroundLUT+BaseAdress),x						;get opposite direction of attacked player
	plx
	sep #$20
	cmp.b TempBuffer
	bne NormalPunchNoBlock

BlockSuccess:
	lda.w ObjEntryMaleDirection,x
	and.b #$03
	clc
	adc.b #56
	sta.w ObjEntryTileset,x				;set blocking tileset

	lda.b #2						;x now contains relative pointer to that sprite
	sta.w ObjEntrySubRout,x			;set to idle subroutine

	lda.b #23
	sta.w ObjEntryAniList,x				;set falling anilist
	
;	lda.b TempBuffer				;set direction
	
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame


	
	jsr CreateObjUploadSpriteFrame			;upload that frame	

	

	lda.b #2								;block sound
	jsr SpcPlaySoundEffectObjectXPos
	

;stun attacking player
	ldx.b TempBuffer+18
	
	lda.b #2						;x now contains relative pointer to that sprite
	sta.w ObjEntrySubRout,x			;set to idle subroutine

	lda.b #52
	clc
	adc.w ObjEntryMaleDirection,x
	sta.w ObjEntryTileset,x				;set stun tileset

	lda.b #21
	sta.w ObjEntryAniList,x				;set stun anilist
	
;	lda.b TempBuffer				;set direction
	
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame


	
	jsr CreateObjUploadSpriteFrame			;upload that frame	
	
	
	rts
	
NormalPunchNoBlock:	
	lda.w ObjEntryMaleInvinc,x
	inc a
	sta.w ObjEntryMaleInvinc,x			;make player invincible when hit


	rep #$31
	phx
	lda.b TempBuffer
	pha
	lda.w ObjEntryObjectNumber,x			;get targets object number
	and.w #$ff
	clc
	adc.w #8					;add 8 to get corresponding healthmeter
	jsr SeekObject
	bcs NormalPunchHealthmeterNotFound

	sep #$20
	dec.w ObjEntryTilesetFrame,x			;decrease healthmeter 
	jsr CreateObjUploadSpriteFrame			;upload that frame	


NormalPunchHealthmeterNotFound:	
	rep #$31
	pla
	sta.b TempBuffer
	plx
	sep #$20

	
	
	lda.b #4					;x now contains relative pointer to that sprite
	sta.w ObjEntrySubRout,x				;set to falling subroutine

	lda.b #8
	clc
	adc.b TempBuffer
	sta.w ObjEntryTileset,x				;set falling tileset

	lda.b #5
	sta.w ObjEntryAniList,x				;set falling anilist
	
	lda.b TempBuffer				;set direction
	sta.w ObjEntryMaleDirection,x
	
	stz.w ObjEntryAniFrame,x			;reset animation frame
	stz.w ObjEntryTilesetFrame,x			;reset animation frame

	lda.b #1
	jsr OamSubCreateParticles
	
	dec.w ObjEntryMaleHP,x
	beq AniSubroutineMainCharaPunchDieStep

	
	jsr CreateObjUploadSpriteFrame			;upload that frame	
	
	lda.b R1
	and.b #%11
	clc
	adc.b #7								;choose randomly between 4 punching sounds(only pitch differs)
	jsr SpcPlaySoundEffectObjectXPos


	sec
NormalPunchNoColliDetect:	
	rts

MaleTurnAroundLUT:
	.db %01
	.db %00
	.db %11
	.db %10



AniSubroutineMainCharaPunchDieStep:
	jmp AniSubroutineMainCharaPunchDie




MainCharaMoveLUT:
	.dw MainCharaNoMove		;nothing pressed
	.dw MainCharaMoveRight		;right pressed
	.dw MainCharaMoveLeft		;left pressed
	.dw MainCharaNoMove		;left/right pressed
	.dw MainCharaMoveDown		;down pressed
	.dw MainCharaMoveDownRight	;down/right pressed
	.dw MainCharaMoveDownLeft	;down/left pressed
	.dw MainCharaNoMove		;down/left/right pressed
	.dw MainCharaMoveUp		;up pressed
	.dw MainCharaMoveUpRight	;up/right pressed
	.dw MainCharaMoveUpLeft		;up/left pressed
	.dw MainCharaNoMove		;up/left/ right pressed
	.dw MainCharaNoMove		;up/down pressed		
	.dw MainCharaNoMove		;up/down/right pressed
	.dw MainCharaNoMove		;up/down/left pressed
	.dw MainCharaNoMove		;left/right/up/down pressed

MainCharaNoMove:
;	rts
	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryAniList,x
	cmp.b #4					;check if were already in idle mode. if we are, dont reset the ani frame counter every frame, as it creates massive overhead, uploading the idle frame to vram every second
	beq MainCharaNoMoveSkip

	stz.w ObjEntryAniFrame,x

	lda.b #4
	sta.w ObjEntryAniList,x
	lda.b #5

MainCharaNoMoveSkip:
	rts

MainCharaMoveRight:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.b #3
	sta.w ObjEntryMaleDirection,x
	lda #2
	sta.w ObjEntryAniList,x
	inc a

	rep #$31

;	rep #$31
;	ldx.b ObjectListPointerCurrent
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #56			;add hotspot
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	inc a
	clc
	adc.w #(NPCHotspotSizeX/2)+1			;one pixel right of players hitbox, upper pixel
	tax

	jsr CheckCollisionBGandExit	
	bcs BGColliDetectRight
	
	tya
	clc
	adc.w #(NPCHotspotSizeY/2)				;lower pixel
	tay
	
	jsr CheckCollisionBGandExit	
	bcs BGColliDetectRight
	
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryXPos,x
	clc
	adc.w #1*16
;	inc a
	sta.w ObjEntryXPos,x				;upper body


BGColliDetectRight:
	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.b #$3			;walking right tileset
	sta.w ObjEntryTileset,x				;upper body

	sta.w ObjEntryPalNumber,x				;upper body

	rts

MainCharaMoveLeft:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.b #2
	sta.w ObjEntryMaleDirection,x
	lda #2
	sta.w ObjEntryAniList,x
	inc a

	rep #$31
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #56			;add hotspot
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #16-1			;add hotspot
	sec
	sbc.w #(NPCHotspotSizeX/2)+1
;	dec a
	tax

	jsr CheckCollisionBGandExit
	
	bcs BGColliDetectLeft

	tya
	clc
	adc.w #(NPCHotspotSizeY/2)				;lower pixel
	tay
	
	jsr CheckCollisionBGandExit	
	bcs BGColliDetectLeft

	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryXPos,x
	sec
	sbc.w #1*16
;	dec a
	sta.w ObjEntryXPos,x				;upper body

BGColliDetectLeft:
	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.b #$2			;walking right tileset
	sta.w ObjEntryTileset,x				;upper body

	sta.w ObjEntryPalNumber,x				;upper body

	rts

MainCharaMoveDown:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.b #0
	sta.w ObjEntryMaleDirection,x	
	lda #2
	sta.w ObjEntryAniList,x
	inc a

	rep #$31
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
	clc
	adc.w #(NPCHotspotSizeY/2)+1			;add hotspot
;	inc a
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
	clc
	adc.w #(NPCHotspotSizeX/2)				;right pixel
	tax

	jsr CheckCollisionBGandExit
	bcs BGColliDetectDown

	txa
	sec
	sbc.w #NPCHotspotSizeX				;left pixel
	tax
	
	jsr CheckCollisionBGandExit
	bcs BGColliDetectDown
	
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryYPos,x
;	inc a
	clc
	adc.w #1*16
	sta.w ObjEntryYPos,x				;upper body
	clc
	adc.w #31


BGColliDetectDown:
	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.b #$0			;walking right tileset
	sta.w ObjEntryTileset,x				;upper body
;	sta.w (ObjEntryTileset+ObjectFileSize),x	;lower body
	sta.w ObjEntryPalNumber,x				;upper body

	rts

MainCharaMoveUp:
	ldx.b ObjectListPointerCurrent
	sep #$20
	lda.b #1
	sta.w ObjEntryMaleDirection,x	
	lda #2
	sta.w ObjEntryAniList,x
	inc a

	rep #$31
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
	sec
	sbc.w #(NPCHotspotSizeY/2)			;+1			;add hotspot
;	dec a
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
	clc
	adc.w #(NPCHotspotSizeX/2)				;right pixel
	tax

	jsr CheckCollisionBGandExit
	bcs BGColliDetectUp

	txa
	sec
	sbc.w #NPCHotspotSizeX				;left pixel
	tax

	jsr CheckCollisionBGandExit
	bcs BGColliDetectUp
	
	rep #$31
	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryYPos,x
;	dec a
	sec
	sbc.w #1*16
	sta.w ObjEntryYPos,x				;upper body	
	clc
	adc.w #31

BGColliDetectUp:
	sep #$20
	ldx.b ObjectListPointerCurrent
	lda.b #$1			;walking right tileset
	sta.w ObjEntryTileset,x				;upper body

	sta.w ObjEntryPalNumber,x				;upper body

	rts

MainCharaMoveDownRight:
	jsr MainCharaMoveDown
	sep #$20
	lda.b #0
	sta.w ObjEntryMaleDirection,x
	rep #$31
	lda.w FrameCounterLo
	bit.w #1					;divide speed by 2 if going diagonally
	beq MainCharaMoveDownRightWait

;	rep #$31
;	ldx.b ObjectListPointerCurrent
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #56			;add hotspot
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	inc a
	clc
	adc.w #(NPCHotspotSizeX/2)+1			;one pixel right of players hitbox
	tax

	jsr CheckCollisionBGandExit
;	ldx.b ObjectListPointerCurrent
	bcs MainCharaMoveDownRightWait

	tya
	clc
	adc.w #(NPCHotspotSizeY/2)				;lower pixel
	tay

	jsr CheckCollisionBGandExit
	bcs MainCharaMoveDownRightWait


	ldx.b ObjectListPointerCurrent	
	lda.w ObjEntryXPos,x
;	inc a
	clc
	adc.w #1*16
	sta.w ObjEntryXPos,x				;upper body


MainCharaMoveDownRightWait:
	rts

MainCharaMoveDownLeft:
	jsr MainCharaMoveDown
	sep #$20
	lda.b #0
	sta.w ObjEntryMaleDirection,x

	rep #$31
	lda.w FrameCounterLo
	bit.w #1					;divide speed by 2 if going diagonally
	beq MainCharaMoveDownLeftWait

;	rep #$31
;	ldx.b ObjectListPointerCurrent
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #56			;add hotspot
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #16-1			;add hotspot
	sec
	sbc.w #(NPCHotspotSizeX/2)+1
;	dec a
	tax

	jsr CheckCollisionBGandExit
;	ldx.b ObjectListPointerCurrent
	bcs MainCharaMoveDownLeftWait

	tya
	clc
	adc.w #(NPCHotspotSizeY/2)				;lower pixel
	tay

	jsr CheckCollisionBGandExit
	bcs MainCharaMoveDownLeftWait


	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryXPos,x
;	dec a
	sec
	sbc.w #1*16
	sta.w ObjEntryXPos,x				;upper body

MainCharaMoveDownLeftWait:
	rts

MainCharaMoveUpRight:
	jsr MainCharaMoveUp
	sep #$20
	lda.b #1
	sta.w ObjEntryMaleDirection,x
	
	rep #$31
	lda.w FrameCounterLo
	bit.w #1					;divide speed by 2 if going diagonally
	beq MainCharaMoveUpRightWait
	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #56			;add hotspot
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #16-1			;add hotspot
	clc
	adc.w #(NPCHotspotSizeX/2)+1
;	inc a
	tax

	jsr CheckCollisionBGandExit
;	ldx.b ObjectListPointerCurrent
	bcs MainCharaMoveUpRightWait

	tya
	clc
	adc.w #(NPCHotspotSizeY/2)				;lower pixel
	tay

	jsr CheckCollisionBGandExit
	bcs MainCharaMoveUpRightWait


	ldx.b ObjectListPointerCurrent	
	lda.w ObjEntryXPos,x
;	inc a
	clc
	adc.w #1*16
	sta.w ObjEntryXPos,x				;upper body

MainCharaMoveUpRightWait:
	rts

MainCharaMoveUpLeft:
	jsr MainCharaMoveUp
	sep #$20
	lda.b #1
	sta.w ObjEntryMaleDirection,x
	rep #$31
	lda.w FrameCounterLo
	bit.w #1					;divide speed by 2 if going diagonally
	beq MainCharaMoveUpLeftWait

	lda ObjEntryYPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #56			;add hotspot
	tay
	lda ObjEntryXPos,x
	lsr a
	lsr a
	lsr a
	lsr a
	
;	clc
;	adc.w #16-1			;add hotspot
	sec
	sbc.w #(NPCHotspotSizeX/2)+1
;	dec a
	tax

	jsr CheckCollisionBGandExit
	bcs MainCharaMoveUpLeftWait

	tya
	clc
	adc.w #(NPCHotspotSizeY/2)				;lower pixel
	tay

	jsr CheckCollisionBGandExit
	bcs MainCharaMoveUpLeftWait


	ldx.b ObjectListPointerCurrent
	lda.w ObjEntryXPos,x
;	dec a
	sec
	sbc.w #1*16
	sta.w ObjEntryXPos,x				;upper body

MainCharaMoveUpLeftWait:
	rts


;count number of remaining players
CheckRemainingPlayers:
	php
	sep #$20
	lda.b #$ff
	sta.w WinningPlayer		;invalidate number of winning player in case of a draw game

	stz.w ActivePlayers			;counter for player objects
	rep #$31
	ldx.w #0

DieSeekRemainingPlayersLoop:
	lda.w ObjEntryObjectNumber,x		;get object number
	and.w #$FFF8					;mask off 0-7
	bne DieSeekRemainingPlayersNoMatch


	lda.w ObjEntryType-1,x
	bpl DieSeekRemainingPlayersNoMatch	;object present?
	
	lda.w ObjEntryMaleHP,x
	and.w #$ff
	beq DieSeekRemainingPlayersNoMatch	;not dead yet?
	
;match found:
	sep #$20
	inc.w ActivePlayers
	
	lda.w ObjEntryObjectNumber,x
	sta.w WinningPlayer		;needed for later. if only one player is left, this is the winner and his number is written here
	stx.w WinningPlayerPointer
	rep #$31

DieSeekRemainingPlayersNoMatch:
	txa
	clc
	adc.w #ObjectFileSize			;goto next entry
	tax
	cpx.w #ObjectFileSize*33		;check all 16 entries.
	bne DieSeekRemainingPlayersLoop	
	
	sep #$20
	lda.w ActivePlayers
	cmp.b #1
	bne SeekPlayersNoMatchEnd	

	ldx.w WinningPlayerPointer
	lda.w ObjEntryObjectNumber,x
	rep #$31
	and.w #$ff
	tax
	sep #$20
	inc.w WinnerArray&$ffff,x
	lda.w WinnerArray&$ffff,x
	cmp.b #3
	beq SeekRemainingPlayersGameOver		;check if player has won two times

;jump to next round
	jsr SpcWaitAllCommandsProcessed
	
	lda.b #$80
	sta.w BattleFinished
;	lda.b #2
/*
;	rep #$31
	lda.b R1				;get random l
	and.b #$3				;4 different max
	clc
	adc.b #4				;select frame 5-8
*/
	lda.w RandomStreamCounter

	bpl StreamLoadAdd

	clc
	adc.b #6				;substract 2
	and.b #$87

StreamLoadAdd:
	
	inc a
	sta.w RandomStreamCounter
	and.b #$3				;4 different levels max
	clc
	adc.b #$4				;stream 4-7

	jsr SpcPlayStream


	lda.b #35			;wait for "thats it" to finish
	sta.b CurrentEvent	
	ldx.w #9
	lda.b #%111101				;bg1, pal7, priority1
	jsr UploadBackgroundFile

	lda.b MainScreen
	ora.b #%10					;enable bg1 on mainscreen
	sta.b MainScreen
	
	rep #$31
	lda.w #$3e8
	sta.b BG2VOfLo	
;	jsr WaitDmaTransfersDone
			


SeekPlayersNoMatchEnd:	
	plp
	rts

SeekRemainingPlayersGameOver:
	jsr SpcWaitAllCommandsProcessed
	
	lda.b #$80
	sta.w BattleFinished
	lda.b #2
	jsr SpcPlayStream


	lda.b #20			;wait for "thats it" to finish
	sta.b CurrentEvent	
	ldx.w #8
	lda.b #%111101				;bg1, pal7, priority1
	jsr UploadBackgroundFile

	lda.b MainScreen
	ora.b #%10					;enable bg1 on mainscreen
	sta.b MainScreen
	
	rep #$31
	stz.w PlayerSelectScrollCounter
	lda.w #$3f8
	sta.b BG2VOfLo	
;	jsr WaitDmaTransfersDone
			
	plp
	rts	






AniSubroutine8x8Particle:
	sep #$20
	ldx.b ObjectListPointerCurrent

	lda.b R1
	and.b #$f					;get random number 0-16
	clc
	adc.b #$38					;angle facing up
	ora.b #$80					;set reached flag
	sta.w ObjEntryVectorDir,x

	lda.b R2
	and.b #$f					;get random number 0-16
	clc
	adc.b #$2d					;speed $2d-$3e
	ora.b #$80					;set reached flag
	sta.w ObjEntryVectorSpeed,x

	lda.b R3
	and.b #$7					;get random number 0-8
	adc.b #25					;select random animation list 25-33
	sta.w ObjEntryAniList,x
	stz.w ObjEntryAniFrame,x	;reset animation frame
	
	lda.b #2
	sta.w ObjEntrySubRout,x				;set to idle
	rts	

;make y- and x-speed a bit random
AniSubRandomParticlesInit:
	rep #$31
	ldx.b ObjectListPointerCurrent
	
	lda.b R2														;get random y-speed
	and.w #$1f
	clc
	adc.w ObjEntryYSpeed,x
	sta.w ObjEntryYSpeed,x
	
	sep #$20
	lda.b R3														;get random x-speed
	and.b #$f
	clc
	adc.w ObjEntryXSpeed,x
	sta.w ObjEntryXSpeed,x

	lda.b R4														;get random lifecounter
	and.b #$3f
	sta.w ObjEntryLifeCounter,x

	lda.w ObjEntryType,x							;disable subroutine
	and.b #%11110111
	sta.w ObjEntryType,x


	rts	

