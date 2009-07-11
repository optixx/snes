MenuSubroutineLUT:
	.dw MenuSubroutineVoid			;0
	.dw MenuSubroutineLoadLevel
;	.dw MenuSubroutineLoadBattle
	.dw MenuSubroutineLoadIntro
	.dw MenuSubroutineAudioMenu

	.dw MenuSubroutineStartStream
	.dw MenuSubroutinePlaySong		;5
	.dw MenuSubroutineUploadSEPack
	.dw MenuSubroutinePlaySE
	.dw SpcStopSong				
	.dw SpcSetSongSpeed
	.dw SpcSetSongChannelMask		;10
	.dw SpcSetReportType
	.dw MenuSubroutineInputMenu
	.dw MenuSubroutineReturnMain
	.dw MenuSubroutineTablistRecorder
	.dw MenuSubroutineExecTablistRec	;15
	.dw MenuSubroutinePlayTablist
	.dw MenuSubroutineDelTablist
	.dw MenuSubroutineLoadDebugmap
	.dw MenuSubroutineLoadCredits

MenuSubroutineExecTablistRec:
	sep #$20
	lda.b #2
	sta.b BattleMusicState
	rts
MenuSubroutinePlayTablist:
	sep #$20
	lda.b #4
	sta.b BattleMusicState
	rts
	
MenuSubroutineDelTablist:
	sep #$20
	stz.b BattleMusicState			;just init the whole tablist fsm 
	rts
	
MenuSubroutineStartStream:
	lda.b SpcCurrentStreamSet
	jsr SpcPlayStream
	rts
MenuSubroutinePlaySong:
	lda.b PtPlayerCurrentSong			;play song
	jsr SpcPlaySong
	rts
MenuSubroutineUploadSEPack:
	sep #$20
	lda.b PtPlayerCurrentSamplePack
	jsr SpcIssueSamplePackUpload
	rts
MenuSubroutinePlaySE:
	sep #$20
	lda.w SpcSEVolume
	xba
	lda.w SpcSEPitch
	rep #$31
	tax
	sep #$20
	lda.b PtPlayerCurrentSoundEffect
	jsr SpcPlaySoundEffect
	rts



MenuSubroutineVoid:
	rts

MenuSubroutineReturnMain:
	sep #$20
	lda.b #0
	sta.b CurrentEvent
	rts

MenuSubroutineTablistRecorder:
	sep #$20
	lda.b #10
	sta.b CurrentEvent
	rts
	
MenuSubroutineInputMenu:
	sep #$20
	lda.b #8
	sta.b CurrentEvent
	rts

MenuSubroutineAudioMenu:
	sep #$20
	lda.b #6
	sta.b CurrentEvent
	rts

MenuSubroutineLoadLevel:
	sep #$20
	lda.b #4
	sta.b CurrentEvent
	rts

MenuSubroutineLoadBattle:
	sep #$20
	lda.b #2
	sta.b CurrentEvent
	rts

MenuSubroutineLoadIntro:
	sep #$20
	lda.b #28
	sta.b CurrentEvent
	rts

MenuSubroutineLoadDebugmap:
	sep #$20
	lda.b #37
	sta.b CurrentEvent
	rts

MenuSubroutineLoadCredits:
	sep #$20
	lda.b #36
	sta.b CurrentEvent
;	stz.b ScreenBrightness
	rts	
	