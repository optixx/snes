EventPtTable:
	.dw EventRoutine0
	.dw EventRoutine1
	.dw EventRoutine2
	.dw EventRoutine3
	.dw EventRoutine4
	.dw EventRoutine5
	.dw EventRoutine6
	.dw EventRoutine7
	.dw EventRoutine8
	.dw EventRoutine9
	.dw EventRoutine10
	.dw EventRoutine11
	.dw EventRoutine12
	.dw EventRoutine13
	.dw EventRoutine14
	.dw EventRoutine15
	.dw EventRoutine16
	.dw EventRoutine17
	.dw EventRoutine18
	.dw EventRoutine19
	.dw EventRoutine20
	.dw EventRoutine21
	.dw EventRoutine22
	.dw EventRoutine23
	.dw EventRoutine24
	.dw EventRoutine25
	.dw EventRoutine26
	.dw EventRoutine27
	.dw EventRoutine28
	.dw EventRoutine29
	.dw EventRoutine30
	.dw EventRoutine31
	.dw EventRoutine32
	.dw EventRoutine33
	.dw EventRoutine34
	.dw EventRoutine35
	.dw EventRoutine36
	.dw EventRoutine37
	.dw EventRoutine38
	.dw EventRoutine39
	
;boot init, also debug menu check		
EventRoutine0:
	rep #$31
	lda.w #200
	sta.w GravityCutOffYPos

	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100

	jsr InitOam
	jsr ResetScrollOffsets
	jsr InitDmaFifo
	jsr ClearColObjList
	jsr ClearZBuffer
	
	stz.b FocusScreenFlags
	lda.b #1
	sta.b CheckJoypadMode		;set joypad check to 8 players
	lda.b #$80
	sta.w IrqBrightnessIncDec
	lda.b #20
	sta.w MaxGravObjCount

.IF DEBUG == 0
	lda.b #28								;goto gra logo if not in debug mode
	sta.b CurrentEvent	
	rts
.endif	

	lda.b #0				;load bgmode config #1
	jsr SetBGMode
	jsr DMATilesToVramBG3
	jsr ClearBg3TilemapBuffer		;cls
	ldx.w #0
	jsr LoadTextString		;print "startup ok"
	
	stz.b LoadMenuDoInit
	lda.b #$0f
	sta.b ScreenBrightness
	inc.b CurrentEvent
	rts

;debug menu play
EventRoutine1:
	jsr ObjectProcessor
	jsr ProcessHdmaList	
	ldx.w #0
	jsr LoadMenuFile
	rts
	
;intro scene 3 init
EventRoutine2:
	rep #$31
	stz.w IntroScene3ScrollPoint
	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100

	lda.b #2			;set bg mode 2.
	jsr SetBGMode
	jsr InitOam
	jsr ResetScrollOffsets
	jsr InitDmaFifo

	lda.b #1			;enable irq
	sta.b IrqRoutineNumber

	rep #$31
	lda.w #$3ff
	sta.b BG1VOfLo
	lda.b BG1HOfLo
	clc
	adc.w #128
	sta.b BG1HOfLo
	lda.b BG2HOfLo
	sec
	sbc.w #17
	sta.b BG2HOfLo
	
	lda.w CurrentBattleFile
	and.w #$ff
	asl a
	tax
	lda.l (BattleFileLUT+BaseAdress),x		;get pointer to current battle file
	sta.b TempBuffer+18			;put pointer into TempBuffer0-2
	
	sep #$20
	lda.b #(:BattleFileLUT+BaseAdress>>16)
	sta.b TempBuffer+20

;set bg color	
	ldy.w #1
	lda.b [TempBuffer+18],y
	sta.b FixedColourR
	iny
	lda.b [TempBuffer+18],y
	sta.b FixedColourG
	iny
	lda.b [TempBuffer+18],y
	sta.b FixedColourB

;upload background files	
	rep #$31
	iny
;bg1 sky
	lda.b [TempBuffer+18],y			;get background number
	and.w #$ff
	tax
	lda.w #%011001				;bg1, pal6, priority0
	jsr UploadBackgroundFile
	ldy.w #5
;bg0 scroll
	lda.b [TempBuffer+18],y			;get background number
	and.w #$ff
	tax
	lda.w #%0				;bg0, pal0, priority0
	jsr UploadBackgroundFile

	sep #$20
	ldy.w #6
	lda.b [TempBuffer+18],y			;get subroutine number		
	sta.b BattleSubroutine

	iny
	rep #$31
	lda.b [TempBuffer+18],y			;get z-scroll list
	and.w #$ff
	asl a
	tax
	
	lda.l (ZScrollListLut+BaseAdress),x	;get pointer to current z-scroll list
	sta.b TempBuffer+6			;put pointer into TempBuffer0-2
	
	sep #$20
	lda.b #(:ZScrollListLut+BaseAdress>>16)
	sta.b TempBuffer+8
	
	ldy.w #0
	tyx

BattleLoaderZScrollLoop:
	lda.b [TempBuffer+6],y			;get byte from list
	sta.l Hdma3dScrollBuffer+4,x		;drop into z value of 3d-scroll linebuffer
	
	inx
	inx
	inx
	inx
	inx
	iny
	cpy.w #Hdma3dScrollLineNumber
	bne BattleLoaderZScrollLoop		
	
	
	sep #$20
	stz.w $4200						;disable irqs
	
	ldy.w #11
	rep #$31
BattleLoaderObjListLoop:
	lda.b [TempBuffer+18],y	;get first two bytes in object entry

	bpl BattleLoaderObjListFinished	;if "present" flag of exit isnt set, its the end of the list
	iny
	iny

	phy
	pha
	lda.b [TempBuffer+18],y	;get xy position
	tax
	
	iny
	iny
	lda.b [TempBuffer+18],y	;get z position
	and.w #$ff
	tay
	
	pla
	and.w #$ff
	
	jsr CreateObjectPosition
	ply
	iny
	iny
	iny
	bra BattleLoaderObjListLoop	
	
BattleLoaderObjListFinished:	
	sep #$20
	lda.b InterruptEnableFlags	;reenable irqs
	sta.w $4200		
	
	lda.b #2			;create pseudo-3d hdma effect
	jsr CreateHdmaEffect
	jsr WaitDmaTransfersDone

	ldx.w #45			;scroll down some pixels
EventRoutine2ScrollLoop:
	lda.b #1
	phx
	jsr Battle3dScrollDown
	plx

	dex
	bne EventRoutine2ScrollLoop

	ldx.w #90			;scroll left some pixels
EventRoutine2ScrollLoop2:

	lda.b #1
	phx
	jsr Battle3dScrollLeft
	plx	
	
	dex
	bne EventRoutine2ScrollLoop2

	lda.b #7											;cgadsub gradient
	jsr CreateHdmaEffect

	lda.b #1
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #3
	sta.w BrightnessEventBuffer	;jump to level play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent
	rts
	
	
;intro scene 3 play
EventRoutine3:
	jsr StartPressedBeginGame
	sep #$20
	ldx.w IntroScene3ScrollPoint
	lda.l (IntroScene3ScrollTable+BaseAdress),x
	
	beq Event3NoRight
	cmp.b #$ff
	beq EventRoutine3Exit
	phx
	jsr Battle3dScrollRight
	plx

Event3NoRight:
	inx
	lda.l (IntroScene3ScrollTable+BaseAdress),x
	beq Event3NoUp
	phx
	jsr Battle3dScrollUp
	plx

Event3NoUp:
	inx
	stx.w IntroScene3ScrollPoint	
	
	

EventRoutine3Exit:
	jsr ObjectProcessor
	jsr ProcessHdmaList	

	rep #$31
	lda.w SpcStreamFrame
	cmp.w #555
	bcc Event3StreamNotDone

	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #33
	sta.w BrightnessEventBuffer	;jump to video player

	lda.b #16			;brightness wait
	sta.b CurrentEvent	

Event3StreamNotDone:
	rts

;level playerselect init:
EventRoutine4:
	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100
	
	jsr InitDmaFifo
	jsr InitOam
	jsr InitHdma
	jsr ClearColObjList
	jsr ClearZBuffer

	stz.w SpcStreamVolume
	jsr SpcStopSong
	
	lda.b #0
	jsr SpcPlayStream	


	stz.w PlayersPresentFlags	;clear all present players
	lda.b #1
	sta.w PlayerState		;set  to menu


	ldx.w #0			;load select menu
	jsr LevelLoader

	ldx.w #6
	lda.b #%111101				;bg1, pal7, priority1
	jsr UploadBackgroundFile

	jsr ResetScrollOffsets

	lda.b MainScreen
	ora.b #%10					;enable bg1 on mainscreen
	sta.b MainScreen
	rep #$31
	stz.w PlayerSelectScrollCounter
	lda.w #$1f0
	sta.b BG1HOfLo
	lda.w #$3f8
	sta.b BG2VOfLo
	
	lda.w #0
	sta.l WinnerArray			;clear winner array
	sta.l WinnerArray+2
	sta.l WinnerArray+4
	sta.l WinnerArray+6
	sep #$20
	jsr WaitDmaTransfersDone

	lda.b #8											;cgadsub gradient
	jsr CreateHdmaEffect

	lda.b #10											;textfield zoomer
	jsr CreateHdmaEffect
	
	lda.b #1
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #5
	sta.w BrightnessEventBuffer	;jump to level play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent
	rts

;level playerselect play	
EventRoutine5:
	jsr ObjectProcessor
	jsr ProcessHdmaList	

scrolltextja:
	rep #$31
	inc.w PlayerSelectScrollCounter
	lda.w PlayerSelectScrollCounter
	and.w #$ff
	lsr a												;divide by 32, multiply by 2 for table
	lsr a
	lsr a
	asl a
	tax
	lda.l (PlayerSelectScrollCounterTable+BaseAdress),x	;get amount of pixels to move this frame
	clc
	adc.b BG2VOfLo	
	sta.b BG2VOfLo	

;check for active player flags. a minimum of 2 must be present to start the match	
	sep #$20
	ldy.w #0
	ldx.w #0
	lda.w PlayersPresentFlags	

PlayerSelectLoop:
	lsr a
	bcc PlayerSelectNotPresent

	iny
	cpy.w #2
	bne PlayerSelectNotPresent		;if a minimum of 2 players are playing, start match

	stz.w SpcStreamVolume
	stz.w SpcStreamFrame
	stz.w SpcStreamFrame+1
	lda.b #1
	jsr SpcPlayStream

	lda.b #19
	sta.b CurrentEvent

	lda.b #0		;clear word: $0000
	ldy.w #$800
	ldx.w #Bg2MapBuffer&$ffff
	jsr ClearWRAM
	inc.b NMIBg2UploadFlag
	
	jsr WaitFrame
	ldx.w #7
	lda.b #%111101				;bg1, pal7, priority1
	jsr UploadBackgroundFile
	

;calculate random level and shuffle direction first
	lda.b R1				
	and.b #%10000111		;get random number 0-3 + shuffle direction
	sta.w RandomLevelCounter
	lda.b R2				
	and.b #%10000111		;get random number 0-3 + shuffle direction
	sta.w RandomStreamCounter

	rep #$31
	lda.w #$3e8
	sta.b BG2VOfLo	


LevelSelectDontStartBattle:
	rts




PlayerSelectNotPresent:
	inx
	cpx.w #8
	bne PlayerSelectLoop

	rts
	
		
;debug audio menu init	
EventRoutine6:
	sep #$20
	jsr ClearBg3TilemapBuffer		;cls
	ldx.w #3
	jsr LoadTextString		;print audio menu
	stz.b LoadMenuDoInit
	inc CurrentEvent

;debug audio menu play	
EventRoutine7:
	jsr ObjectProcessor
	jsr ProcessHdmaList	

	ldx.w #1
	jsr LoadMenuFile
	ldx.w #13
	jsr LoadTextString		;print timecode
	ldx.w #14
	jsr LoadTextString
	ldx.w #30
	jsr LoadTextString		;print channel volume output
	ldx.w #31
	jsr LoadTextString	
	rts
	
;debug input menu init	
EventRoutine8:
	sep #$20
	jsr ClearBg3TilemapBuffer		;cls
	ldx.w #4
	jsr LoadTextString		;print audio menu
	stz.b LoadMenuDoInit
	inc CurrentEvent
	
;debug input menu play	
EventRoutine9:
	jsr ObjectProcessor
	jsr ProcessHdmaList	

	ldx.w #2
	jsr LoadMenuFile

	ldx.w #5
	jsr LoadTextString
	ldx.w #6
	jsr LoadTextString
	ldx.w #7
	jsr LoadTextString
	ldx.w #8
	jsr LoadTextString
	ldx.w #9
	jsr LoadTextString
	ldx.w #10
	jsr LoadTextString
	ldx.w #11
	jsr LoadTextString
	ldx.w #12
	jsr LoadTextString
	ldx.w #32
	jsr LoadTextString
	ldx.w #33
	jsr LoadTextString
	ldx.w #34
	jsr LoadTextString
	ldx.w #35
	jsr LoadTextString
	ldx.w #36
	jsr LoadTextString
	ldx.w #37
	jsr LoadTextString
	ldx.w #38
	jsr LoadTextString
	ldx.w #39
	jsr LoadTextString

	rts

EventRoutine10:	
EventRoutine11:

;battlelevel init:
EventRoutine12:
	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100
	stz.w BattleFinished
	stz.w SpcStreamVolume
	stz.w PlayerState		;set to battle

EventRoutine12WaitStreamDone:
	lda.b SpcHandlerState		;wait for audio stream to finish and exit
	cmp.b #1
	bne EventRoutine12WaitStreamDone

;randomly select a level
	ldx.w CurrentLevel			;load select menu

	lda.w RandomLevelCounter
	bpl LevelLoadAdd

	clc
	adc.b #6				;substract 2
	and.b #$87

LevelLoadAdd:
	
	inc a
	sta.w RandomLevelCounter
	rep #$31
	and.w #$3				;4 different levels max
	clc
	adc.w #$3				;levels 3-6
	tax
		
	jsr LevelLoader
	jsr ResetScrollOffsets
	
	sep #$20
	lda.b #8
	sta.w ActivePlayers		;this is a bogus value. Actually must just be bigger than 1

	rep #$31
	lda #$1f0
	sta.b BG1HOfLo
	sep #$20

	jsr WaitDmaTransfersDone

	lda.b #2
	jsr SpcPlaySong
	lda.b #0
	jsr SpcIssueSamplePackUpload	

BattleLevelInitWaitSoundUpload:
	lda.b SpcUploadedFlag
	bit.b #$40
	beq BattleLevelInitWaitSoundUpload
	
	lda.b #1
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #13
	sta.w BrightnessEventBuffer	;jump to level play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent

	lda.b #0
	jsr CreateHdmaEffect
	rts

;battlelevel play
EventRoutine13:
	sep #$20
	jsr ObjectProcessor
	jsr ProcessHdmaList	
	rts

;results setup	
EventRoutine14:
	sep #$20
	stz.b ScreenBrightness
	sta.l $2100
	lda.b #0
	jsr SpcPlaySong

	lda.b #1
	sta.w SpcReportType
	jsr SpcSetReportType
	
	lda.b #2
	sta.w PlayerState		;set to results 
	ldx.w #1			;load results screen
	jsr LevelLoader
	jsr ResetScrollOffsets

	rep #$31
	lda.w #$1f0
	sta.b BG1HOfLo

	sep #$20
	jsr WaitDmaTransfersDone
	lda.b #1
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #15
	sta.w BrightnessEventBuffer	;jump to level play after brightness increase

	lda.b #16			;brightness fade wait
	sta.b CurrentEvent

	rts
	
;results waitloop. jump to credits if nothing has been pressed for a couple of seconds	
EventRoutine15:
	sep #$20
	jsr ObjectProcessor
	jsr ProcessHdmaList	
	
	rep #$31
	lda.l SpcReportBuffer+2		;get spc timecode
	cmp.w #300
	bcc EventRoutine15CreditsWait
	
	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #36
	sta.w BrightnessEventBuffer	;jump to level play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent	
	
EventRoutine15CreditsWait:	
	rts

;brightness fade wait. returns to preset event after done
EventRoutine16:	
	sep #$20
	lda.w IrqBrightnessIncDec		;done decreasing/increasing?
	bpl EventRoutine16Exit
	
	lda.w BrightnessEventBuffer
	sta.b CurrentEvent

EventRoutine16Exit:
	jsr ObjectProcessor			;process sprites
	jsr ProcessHdmaList	
	rts

;intro scene 1 init
EventRoutine17:
	sep #$20
	lda.b #0		;define starting position for player
	sta.w MapStartPosX
	lda.b #0
	sta.w MapStartPosY
	
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100

	ldx.w #7			;load intro - nightsky
	jsr LevelLoader
	jsr ResetScrollOffsets

	rep #$31
	lda.w #$1f0
	sta.b BG1HOfLo
	sep #$20
	jsr WaitDmaTransfersDone

	lda.b #6											;cgadsub gradient
	jsr CreateHdmaEffect

	lda.b #3
	jsr SpcPlayStream
	lda.b #1
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #18
	sta.w BrightnessEventBuffer	;jump to level play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent

	jsr ObjectProcessor		;prevent graphic glitches
	rts
	
		
;intro scene 1 play
EventRoutine18:
	sep #$20
	jsr ObjectProcessor
	jsr ProcessHdmaList	
	jsr StartPressedBeginGame
	lda.b FrameCounterLo
	and.b #%1
	jsr BgScrollDown		;scroll every 2nd frame
	
	rep #$31
	lda.w SpcStreamFrame
	cmp.w #140
	bcc Event18StreamNotDone

	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #21
	sta.w BrightnessEventBuffer	;jump to scene 2

	lda.b #16			;brightness wait
	sta.b CurrentEvent	


Event18StreamNotDone:	
	rts

;player select countdown
EventRoutine19:
	sep #$20
	jsr ObjectProcessor
	jsr ProcessHdmaList	

	lda.b FrameCounterLo
	and.b #%111
	bne Event19NoTextFlip
	
	lda.b MainScreen				;toggle bg1 every 7 frames
	eor.b #%10
	sta.b MainScreen

Event19NoTextFlip:	
	rep #$31
	lda.w SpcStreamFrame
	cmp.w #350
	bcc Event19Exit
	
	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #12
	sta.w BrightnessEventBuffer	;jump to level play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent	

	
Event19Exit:
	rts	

;wait for "end of match"-speech to finish	
EventRoutine20:
	sep #$20
	jsr ObjectProcessor
	jsr ProcessHdmaList	

	rep #$31
	inc.w PlayerSelectScrollCounter
	lda.w PlayerSelectScrollCounter
	and.w #$ff
	lsr a												;divide by 32, multiply by 2 for table
	lsr a
	lsr a
	asl a
	tax
	lda.l (PlayerSelectScrollCounterTable+BaseAdress),x	;get amount of pixels to move this frame
	clc
	adc.b BG2VOfLo	
	sta.b BG2VOfLo		
	
	lda.w SpcStreamFrame
	cmp.w #400
	bcc Event20Exit
	
	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #14
	sta.w BrightnessEventBuffer	;jump to results after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent	

	
Event20Exit:
	rts	


Event21StreamNotDone:	
	rts

;intro scene 2 init
EventRoutine21:
	rep #$31
	lda.w #0
	sta.l HdmaBuffer			;terminate cgadsub gradient
	
	lda.w SpcStreamFrame
	cmp.w #170
	bcc Event21StreamNotDone

	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100
	
	jsr InitOam
	lda.b #0		;define starting position for player
	sta.w MapStartPosX
	lda.b #30
	sta.w MapStartPosY
	ldx.w #7			;load intro - nightsky
	jsr LevelLoader

	jsr WaitDmaTransfersDone

	lda.b #3
	jsr SetBGMode			
	stz.w $4200						;disable irqs
	lda.b #20

;moon		
	ldx.w #$1c13
	jsr CreateObjectPosition

	lda.b #21
	ldx.w #$1c1b
	jsr CreateObjectPosition

	lda.b #23
	ldx.w #$2413
	jsr CreateObjectPosition
	lda.b #24
	ldx.w #$241b
	jsr CreateObjectPosition

	lda.b #26
	ldx.w #$2c13
	jsr CreateObjectPosition
	lda.b #27
	ldx.w #$2c1b
	jsr CreateObjectPosition

;moon corona
	lda.b #28
	ldx.w #$160f
	jsr CreateObjectPosition
	lda.b #29
	ldx.w #$1617
	jsr CreateObjectPosition
	lda.b #30
	ldx.w #$1e0f
	jsr CreateObjectPosition

	lda.b #31
	ldx.w #$260f
	jsr CreateObjectPosition

	lda.b #32
	ldx.w #$2e0f
	jsr CreateObjectPosition

	lda.b #33
	ldx.w #$2e17
	jsr CreateObjectPosition

	lda.b InterruptEnableFlags	;reenable irqs
	sta.w $4200
	
	lda.b #1
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #22
	sta.w BrightnessEventBuffer	;jump to scene 2

	lda.b #16			;brightness wait
	sta.b CurrentEvent	

	jsr ObjectProcessor		;prevent graphic glitches
	rts

;intro scene 2 play
EventRoutine22:
	sep #$20
	jsr ObjectProcessor
	jsr ProcessHdmaList	
	jsr StartPressedBeginGame
	lda.b FrameCounterLo
	and.b #%1
	jsr BgScrollDown		;scroll every 2nd frame

	rep #$31
	lda.w SpcStreamFrame
	cmp.w #315
	bcc Event22StreamNotDone

	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #2
	sta.w BrightnessEventBuffer	;jump to results after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent	


Event22StreamNotDone:	
	rts

;titlescreen init:
EventRoutine23:
	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100
	
	jsr InitHdma
	lda.b #1
	jsr SpcPlaySong
	lda.b #1
	jsr SpcIssueSamplePackUpload
	lda.b #1
	sta.w SpcReportType
	
	
	jsr SpcSetReportType	
	lda.b #4
	jsr SetBGMode
	jsr ResetScrollOffsets
	jsr ClearVRAM	
	jsr InitOam
	

;bg1 nwarp logo
	lda.b #$1f
	sta.b FixedColourR
	sta.b FixedColourG
	sta.b FixedColourB
	
	rep #$31
	ldx.w #2
	lda.w #%111101				;bg1, pal7, priority1
	jsr UploadBackgroundFile

;bg0 backdrop

	ldx.w #3
	lda.w #%0				;bg0, pal0, priority0
	jsr UploadBackgroundFile

	lda.w #$3f0
	sta.w BG1HOfLo		;
	sta.w BG2HOfLo		;
TitleScreenInitWaitSongUploaded:	
	lda.l SpcReportBuffer+2		;get spc timecode
	cmp.w #2
	bne TitleScreenInitWaitSongUploaded

	sep #$20
	lda.b #1				;gradient nwarp logo
	jsr CreateHdmaEffect
	lda.b #5				;nwarp logo zoom
	jsr CreateHdmaEffect	
	
	
	lda.b #1
	jsr SpcPlaySoundEffectSimple		;nwarp
	lda.b #1
	jsr SpcPlaySoundEffectSimple		;nwarp
	lda.b #$0f
	sta.b ScreenBrightness	
	inc.b CurrentEvent

	jsr ObjectProcessor		;prevent graphic glitches	
	rts

;titlescreen play, 
EventRoutine24:
	jsr StartPressedBeginGame
	
	rep #$31
	lda.l SpcReportBuffer+2		;get spc timecode
	cmp.w #$10
	bcc EventRoutine24NoExit

	sep #$20
	lda.b #2
	jsr SpcPlaySoundEffectSimple		;daisakusen
	lda.b #2
	jsr SpcPlaySoundEffectSimple		;daisakusen
;dai
	lda.b #42
	ldx.w #$060c
	jsr CreateObjectPosition
;expl	
	lda.b #45
	ldx.w #$0408
	jsr CreateObjectPosition		

	lda.b #46
	ldx.w #$0410
	jsr CreateObjectPosition		

	lda.b #47
	ldx.w #$0c08
	jsr CreateObjectPosition		

	lda.b #48
	ldx.w #$0c10
	jsr CreateObjectPosition	
	inc.b CurrentEvent

EventRoutine24NoExit:
	jsr ObjectProcessor
	jsr ProcessHdmaList
	rts

EventRoutine25:
	jsr StartPressedBeginGame
	rep #$31
	lda.l SpcReportBuffer+2		;get spc timecode
	cmp.w #$16
	bcc EventRoutine25NoExit

	sep #$20
;saku
	lda.b #43
	ldx.w #$0e07			;y-2, x-4
	jsr CreateObjectPosition
;expl	
	lda.b #45
	ldx.w #$0c03
	jsr CreateObjectPosition		

	lda.b #46
	ldx.w #$0c0b
	jsr CreateObjectPosition		

	lda.b #47
	ldx.w #$1403
	jsr CreateObjectPosition		

	lda.b #48
	ldx.w #$140b
	jsr CreateObjectPosition	
	inc.b CurrentEvent

EventRoutine25NoExit:
	jsr ObjectProcessor
	jsr ProcessHdmaList	
	jsr FadeTitleBg1In
	rts
	
EventRoutine26:
	jsr StartPressedBeginGame
	rep #$31
	lda.l SpcReportBuffer+2		;get spc timecode
	cmp.w #$1c
	bcc EventRoutine26NoExit

	sep #$20
;sen
	lda.b #44
	ldx.w #$0e11
	jsr CreateObjectPosition	
;expl	
	lda.b #45
	ldx.w #$0c0d
	jsr CreateObjectPosition		

	lda.b #46
	ldx.w #$0c15
	jsr CreateObjectPosition		

	lda.b #47
	ldx.w #$140d
	jsr CreateObjectPosition		

	lda.b #48
	ldx.w #$1415
	jsr CreateObjectPosition	
	inc.b CurrentEvent

EventRoutine26NoExit:
	jsr ObjectProcessor
	jsr ProcessHdmaList	
	jsr FadeTitleBg1In	
	rts
	
EventRoutine27:
	jsr StartPressedBeginGame
	jsr ObjectProcessor
	jsr ProcessHdmaList
	jsr FadeTitleBg1In
	rep #$31
	lda.l SpcReportBuffer+2		;get spc timecode
	cmp.w #$1dd
	bcc EventRoutine27NoExit	
;reset to gra logo:

	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #28
	sta.w BrightnessEventBuffer	;jump to gra logo

	lda.b #16			;brightness wait
	sta.b CurrentEvent	

EventRoutine27NoExit:	
	rts


;gra logo init
EventRoutine28:
	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100
	
	lda.b #5
	jsr SetBGMode
	jsr ResetScrollOffsets
	jsr ClearVRAM	
	jsr InitOam
	jsr InitHdma
	jsr SpcStopSong
	lda.b #8
	jsr SpcPlayStream

	rep #$31
	ldx.w #4
	lda.w #%011100				;bg1, pal7, priority0
	jsr UploadBackgroundFile
	sep #$20

;gra g
	lda.b #49
	ldx.w #$070c
	jsr CreateObjectPosition

	lda.b #1
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #29
	sta.w BrightnessEventBuffer	;jump to gra logo play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent	
	rts

;gra logo play
EventRoutine29:
	jsr ObjectProcessor	
	
	rep #$31
	lda.w SpcStreamFrame
	cmp.w #90

	bcc EventRoutine29NoExit

	sep #$20
;gra gra
	lda.b #50
	ldx.w #$0d0c
	jsr CreateObjectPosition

	inc.b CurrentEvent
EventRoutine29NoExit:
	rts


EventRoutine30:
	jsr ObjectProcessor
	rep #$31
	stz.w BgMapCurrentPositionX
	stz.w BgMapCurrentPositionY

	lda.w SpcStreamFrame
	cmp.w #190
	bcc EventRoutine30NoExit

	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #17
	sta.w BrightnessEventBuffer	;jump to gra logo play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent	

EventRoutine30NoExit:
	rts

;titlescreen flash init
EventRoutine31:
	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100
	jsr InitHdma

	lda.b #6
	jsr SetBGMode
	jsr ResetScrollOffsets	
	jsr InitOam


;bg1 nwarp logo
	lda.b #$1f
	sta.b FixedColourR
	sta.b FixedColourG
	sta.b FixedColourB
	
	rep #$31
	ldx.w #2
	lda.w #%111101				;bg1, pal7, priority1
	jsr UploadBackgroundFile

;bg0 backdrop

	ldx.w #3
	lda.w #%0				;bg0, pal0, priority0
	jsr UploadBackgroundFile

	lda.w #$3f0
	sta.w BG1HOfLo		;
	sta.w BG2HOfLo		;

	sep #$20

;dai
	lda.b #42
	ldx.w #$060c				;x-2, y-4
	jsr CreateObjectPosition	
;saku
	lda.b #43
	ldx.w #$0e07
	jsr CreateObjectPosition
;sen
	lda.b #44
	ldx.w #$0e11
	jsr CreateObjectPosition
	jsr WaitDmaTransfersDone

	lda.b #3
	jsr SpcPlaySong
	jsr SpcSetSongChannelMask
	lda.b #1
	sta.w SpcReportType
	jsr SpcSetReportType	



	sep #$20	
TitleFlashInitWaitSoundUpload:
	lda.b SpcUploadedFlag
	bit.b #$80
	beq TitleFlashInitWaitSoundUpload
	
	lda.b #0
	sta.l SpcReportBuffer+2
	sta.l SpcReportBuffer+3


	lda.b #1				;gradient nwarp logo
	jsr CreateHdmaEffect
	
	lda.b #$0f
	sta.b ScreenBrightness	
	inc.b CurrentEvent
	jsr ObjectProcessor		;prevent graphic glitches
	rts
;titlescreen flash play
EventRoutine32:
	jsr ObjectProcessor
	jsr ProcessHdmaList	

	sep #$20
	lda.b FrameCounterLo
	and.b #$1
	bne EventRoutine32FadeDone
	lda.b FixedColourR
	beq EventRoutine32FadeDone
	dec a					;fade bg1 in
	sta.b FixedColourR
	sta.b FixedColourG
	sta.b FixedColourB

EventRoutine32FadeDone:

	rep #$31
	lda.l SpcReportBuffer+2		;get spc timecode
	cmp.w #$10
	bcc EventRoutine32NoExit

	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #4
	sta.w BrightnessEventBuffer	;jump to gra logo play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent
EventRoutine32NoExit:
	rts


;intro scene 4, video, init	
EventRoutine33:
	rep #$31
	lda.w #0
	sta.l HdmaBuffer1			;terminate cgadsub gradient
	sta.l HdmaBuffer			;terminate 3d scroll

	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100
	
	jsr InitOam
	jsr ResetScrollOffsets	
	
	stz.b VideoHandlerState
	stz.w CurrentVideo
	lda.b #7
	jsr SetBGMode

	ldx.w #5					;3d-sky
	lda.b #%000000				;bg1, pal7, priority0
	jsr UploadBackgroundFile

	jsr VideoHandler			;run once so video is initialized
	jsr ObjectProcessor			;run once so objects are cleared	
	jsr WaitDmaTransfersDone	

	lda.b #9					;cgadsub gradient 3d video
	jsr CreateHdmaEffect

	lda.b #1
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #34
	sta.w BrightnessEventBuffer	;jump to video after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent	
	rep #$31
	lda.w #$3ff-16
	sta.b BG2VOfLo
	lda.w #$3ff-48
	sta.b BG1VOfLo	
	lda.w #$3ff-255
	sta.b BG1HOfLo	


	rts
;intro scene 4, video, play
EventRoutine34:
	jsr VideoHandler
	jsr ProcessHdmaList	
	jsr StartPressedBeginGame
	rep #$31
	dec.b BG1HOfLo
	dec.b BG1HOfLo
	dec.b BG1HOfLo
	lda.w SpcStreamFrame
	cmp.w #615
	bcc Event34StreamNotDone

	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #23
	sta.w BrightnessEventBuffer	;jump to titlescreen

	lda.b #16			;brightness wait
	sta.b CurrentEvent	
	stz.w SpcStreamVolume

Event34StreamNotDone:
	rts

;wait for "next round"-speech to finish		
EventRoutine35:

	sep #$20
	jsr ObjectProcessor
	jsr ProcessHdmaList	

	lda.b FrameCounterLo
	and.b #%11111
	bne Event35NoTextFlip
	
	lda.b MainScreen				;toggle bg1 every 7 frames
	eor.b #%10
	sta.b MainScreen

Event35NoTextFlip:	
	
	rep #$31
	lda.w SpcStreamFrame
	cmp.w #200
	bcc Event35Exit
	
	sep #$20
	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #12
	sta.w BrightnessEventBuffer	;jump to another battlemap

	lda.b #16			;brightness wait
	sta.b CurrentEvent	

	
Event35Exit:
	rts	

;outro credits, video, init	
EventRoutine36:
	rep #$31

	sep #$20
	lda.b #0
	sta.b ScreenBrightness
	sta.l $2100
	
	jsr InitOam
	jsr ResetScrollOffsets	
	jsr InitHdma
	lda.b #4
	jsr SpcPlaySong
	
	lda.b #3
	sta.w SpcReportType
	jsr SpcSetReportType
	
	
	stz.b VideoHandlerState
	lda.b #1
	sta.w CurrentVideo
	lda.b #8
	jsr SetBGMode

	ldx.w #10					;3d-sky
	lda.b #%000000				;bg1, pal7, priority0
	jsr UploadBackgroundFile
	jsr WaitDmaTransfersDone
	jsr VideoHandler			;run once so video is initialized
	jsr ObjectProcessor			;run once so objects are cleared
	jsr WaitDmaTransfersDone	

	lda.b #52
	jsr CreateObject
	lda.b #53
	jsr CreateObject	
	
	lda.b #11					;cgadsub gradient 3d video
	jsr CreateHdmaEffect

	lda.b #12					;gradient small nwarp logo
	jsr CreateHdmaEffect
				
	lda.b #1
	sta.w IrqBrightnessIncDec	;set to brightness increase
	lda.b #38
	sta.w BrightnessEventBuffer	;jump to video after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent
	
	
	inc.b VideoHandlerState
	lda.b #0
	sta.l SpcReportBuffer+6
	sta.w SpecialReportOld	
	rep #$31
	lda.w #$3ff-12
	sta.b BG2VOfLo
	lda.w #20
	sta.b BG2HOfLo

	lda.w #$3ff-16
	sta.b BG1VOfLo	
	lda.w #$3ff-16
	sta.b BG1HOfLo	
	rts



;debuglevel init:
EventRoutine37:
	sep #$20
	lda.b #0
	stz.b ScreenBrightness
	sta.l $2100
	
	rep #$31
	lda.w #0
	sta.l WinnerArray			;clear winner array
	sta.l WinnerArray+2
	sta.l WinnerArray+4
	sta.l WinnerArray+6	

	sep #$20
	stz.w BattleFinished
	stz.w SpcStreamVolume
	stz.w PlayerState		;set to battle
	lda.b #8
	sta.w ActivePlayers		;this is a bogus value. Actually must just be bigger than 1
	lda.b #$ff					;enable all players
	sta.w PlayersPresentFlags	
	ldx.w #8
	jsr LevelLoader
	
	jsr ResetScrollOffsets
	
	rep #$31
	lda #$1f0
	sta.b BG1HOfLo

	sep #$20

	lda.b #0
	jsr SpcIssueSamplePackUpload	

	jsr WaitDmaTransfersDone	
	lda.b #$1f
	sta.b ScreenBrightness
	lda.b #39				;goto debugmap play
	sta.b CurrentEvent

	rts


;credits
EventRoutine38:
	sep #$20
	jsr ObjectProcessor
	jsr ProcessHdmaList	
	lda.l SpcReportBuffer+6
	cmp.w SpecialReportOld
	beq CreditsNoBeat
	
	sta.w SpecialReportOld
	lda.b #1
	sta.b VideoHandlerState
	lda.w CurrentVideo
	eor.b #%11						;switch between videos 1,2
	sta.w CurrentVideo
	stz.w CurrentVideoFrame

CreditsNoBeat:
	jsr VideoHandler

	lda.w JoyPortBuffer&$FFFF+1
	ora.w JoyPortBuffer&$FFFF+3
	ora.w JoyPortBuffer&$FFFF+5
	ora.w JoyPortBuffer&$FFFF+7
	ora.w JoyPortBuffer&$FFFF+9
	ora.w JoyPortBuffer&$FFFF+11
	ora.w JoyPortBuffer&$FFFF+13
	ora.w JoyPortBuffer&$FFFF+15
	and.b #%00010000
	beq CreditsStartNotPressed

	lda.b #0
	sta.w IrqBrightnessIncDec	;set to brightness decrease
	lda.b #28
	sta.w BrightnessEventBuffer	;jump to gra logo play after brightness increase

	lda.b #16			;brightness wait
	sta.b CurrentEvent	
	
CreditsStartNotPressed:	
	
	rts
	
;debug level play	
EventRoutine39:	
	rep #$31

	jsr ObjectProcessor
	jsr ProcessHdmaList	

	rts
	
	
StartPressedBeginGame:
	php
	sep #$20
	lda.w JoyPortBuffer&$FFFF+1
	ora.w JoyPortBuffer&$FFFF+3
	ora.w JoyPortBuffer&$FFFF+5
	ora.w JoyPortBuffer&$FFFF+7
	ora.w JoyPortBuffer&$FFFF+9
	ora.w JoyPortBuffer&$FFFF+11
	ora.w JoyPortBuffer&$FFFF+13
	ora.w JoyPortBuffer&$FFFF+15
	and.b #%00010000
	beq StartNotPressed
	
	lda.b #31			;4=goto player select screen, 31=goto titlescreen flash
	sta.b CurrentEvent	


StartNotPressed:	
	plp
	rts

FadeTitleBg1In:
	php
	sep #$20
	lda.b FrameCounterLo
	and.b #$3
	bne EventRoutine27FadeDone
	lda.b FixedColourR
	beq EventRoutine27FadeDone
	dec a					;fade bg1 in
	sta.b FixedColourR
	sta.b FixedColourG
	sta.b FixedColourB

EventRoutine27FadeDone:
	plp
	rts

