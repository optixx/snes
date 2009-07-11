;plays "videos", simply loads 16 colour 32x32 background images to bg0 every other frame.
;frame format:			0-$7ff=tilemap
;										$800-?=tiles
;video file format:	
;0			=number of frames
;1			=video framerate
;1-32		=palette
;33-?		=3 byte absolute pointers to video frames, 2 byte length per frame(total 5 bytes per frame)
;the whole video has only one palette
;uses palette 0

;when playing back video file, upload tiles directly, but copy map to ram, setting the bg priority map in the process.


VideoHandler:
	php
	rep #$31
	lda.b VideoHandlerState
	and.w #$ff
	asl a
	tax
	jsr (VideoHandlerFSMLUT,x)
	
	plp
	rts
	
	
	
VideoHandlerFSMLUT:
		.dw VideoHandlerInit
		.dw VideoHandlerPlay
		.dw VideoHandlerIdle
		.dw VideoHandlerReset				;same as init, but without clearing screen and frame buffer. used for seamlessy tieing videos together

VideoHandlerIdle:
		rts

VideoHandlerPlay:
		lda.w FrameCounterLo
		and.w VideoFrameRate
		beq VideoPlayNoCancel
		rts

VideoPlayNoCancel:		
		lda.w CurrentVideo
		and.w #$f								;max number of videos: 16
		asl a
		tax
		lda.l (VideoLUT+BaseAdress),x	;get pointer to video
		sta.b TempBuffer
		sep #$20
		lda.b #(:VideoLUT+BaseAdress >> 16)
		sta.b TempBuffer+2

		jsr VideoUploadFrame

	;	sep #$20
		jsr WaitDmaTransfersDone
		inc.w CurrentVideoFrame
		lda.w CurrentVideoFrame
		cmp.w VideoFrames
		bcc VideoPlayNoEnd

		inc.w VideoHandlerState		;goto idle

VideoPlayNoEnd:		
		rts

VideoHandlerInit:
;clear tilemap:
		jsr ClearBg2TilemapBuffer
		sep #$20
		ldx.b DmaFifoPointer
		lda.b #1					;transfer type
		sta.l DmaFifoEntryType,x
		
		lda.b #$7e
		sta.l DmaFifoEntrySrcLo+2,x
		rep #$31
		lda.w VramBg2Tilemap			;tilemap space
		sta.l DmaFifoEntryTarget,x
		lda.w #Bg2MapBuffer&$ffff
		sta.l DmaFifoEntrySrcLo,x
	
		lda.w #$800						;clear whole bg2 tilemap to prevent garbage on the edges of the video
		sta.l DmaFifoEntryCount,x
		txa						;update fifo entry pointer
		clc
		adc.w #DmaFifoEntryLength
		sta.b DmaFifoPointer


		lda.w CurrentVideo
		and.w #$f								;max number of videos: 16
		asl a
		tax
		lda.l (VideoLUT+BaseAdress),x	;get pointer to video
		sta.b TempBuffer
		sep #$20
		
		lda.b #(:VideoLUT+BaseAdress >> 16)
		sta.b TempBuffer+2
		
		stz.w CurrentVideoFrame
		ldy.w #0
		lda.b [TempBuffer],y				;get number of frames
		sta.w VideoFrames						;store in number of frames
		iny
		lda.b [TempBuffer],y				;get framerate
		sta.w VideoFrameRate
		stz.w VideoFrameRate+1
		
	
		
		rep #$31
		ldx.w #0
		iny
;copy palette
VideoHandlerInitCopyPalLoop:
		lda.b [TempBuffer],y
		sta.w PaletteBuffer&$ffff,x
		iny
		iny
		inx
		inx
		cpx.w #32
		bne VideoHandlerInitCopyPalLoop
/*		
;upload map and tiles of first frame		
		sep #$20
		
		ldx.b DmaFifoPointer
		lda #1					;transfer type
		sta.l DmaFifoEntryType,x
		rep #$31
		lda.w #$c00
		sta.l DmaFifoEntryTarget,x
		lda.b [TempBuffer],y
		sta.l DmaFifoEntrySrcLo,x
		iny
		lda.b [TempBuffer],y
		sta.l DmaFifoEntrySrcLo+1,x
		iny
		iny
		lda.b [TempBuffer],y
		sta.l DmaFifoEntryCount,x
		txa						;update fifo entry pointer
		clc
		adc.w #DmaFifoEntryLength
		sta.b DmaFifoPointer
*/

		jsr VideoUploadFrame
				
		sep #$20
		inc.b NMIPaletteUploadFlag
		inc.b VideoHandlerState					;goto play routine
		inc.w CurrentVideoFrame
		rts

VideoHandlerReset:
/*
;clear tilemap:
		jsr ClearBg2TilemapBuffer
		sep #$20
		ldx.b DmaFifoPointer
		lda.b #1					;transfer type
		sta.l DmaFifoEntryType,x
		
		lda.b #$7e
		sta.l DmaFifoEntrySrcLo+2,x
		rep #$31
		lda.w VramBg2Tilemap			;tilemap space
		sta.l DmaFifoEntryTarget,x
		lda.w #Bg2MapBuffer&$ffff
		sta.l DmaFifoEntrySrcLo,x
	
		lda.w #$800						;clear whole bg2 tilemap to prevent garbage on the edges of the video
		sta.l DmaFifoEntryCount,x
		txa						;update fifo entry pointer
		clc
		adc.w #DmaFifoEntryLength
		sta.b DmaFifoPointer

*/
		rep #$31
		lda.w CurrentVideo
		and.w #$f								;max number of videos: 16
		asl a
		tax
		lda.l (VideoLUT+BaseAdress),x	;get pointer to video
		sta.b TempBuffer
		sep #$20
		
		lda.b #(:VideoLUT+BaseAdress >> 16)
		sta.b TempBuffer+2
		
		stz.w CurrentVideoFrame
		ldy.w #0
		lda.b [TempBuffer],y				;get number of frames
		sta.w VideoFrames						;store in number of frames
		iny
		lda.b [TempBuffer],y				;get framerate
		sta.w VideoFrameRate
		stz.w VideoFrameRate+1
		
	
		
		rep #$31
		ldx.w #0
		iny
;copy palette
VideoHandlerResetCopyPalLoop:
		lda.b [TempBuffer],y
		sta.w PaletteBuffer&$ffff,x
		iny
		iny
		inx
		inx
		cpx.w #32
		bne VideoHandlerResetCopyPalLoop
/*		
;upload map and tiles of first frame		
		sep #$20
		
		ldx.b DmaFifoPointer
		lda #1					;transfer type
		sta.l DmaFifoEntryType,x
		rep #$31
		lda.w #$c00
		sta.l DmaFifoEntryTarget,x
		lda.b [TempBuffer],y
		sta.l DmaFifoEntrySrcLo,x
		iny
		lda.b [TempBuffer],y
		sta.l DmaFifoEntrySrcLo+1,x
		iny
		iny
		lda.b [TempBuffer],y
		sta.l DmaFifoEntryCount,x
		txa						;update fifo entry pointer
		clc
		adc.w #DmaFifoEntryLength
		sta.b DmaFifoPointer
*/

		jsr VideoUploadFrame
				
		sep #$20
		inc.b NMIPaletteUploadFlag
		lda.b #1
		sta.b VideoHandlerState					;goto play routine
		inc.w CurrentVideoFrame
		rts
		rts

VideoUploadFrame:
		php
		rep #$31
;get current frame		
		lda.w CurrentVideoFrame
		and.w #$ff
;calculate position of pointer in video file - multiply with 5		
		sta.b TempBuffer+3
		asl a
		asl a
		clc
		adc.b TempBuffer+3
		clc
		adc.w #34
		sta.b TempBuffer+3		;store for later

;setup pointer to map
		tay		
		lda.b [TempBuffer],y
		sta.b TempBuffer+5
		iny
		lda.b [TempBuffer],y
		sta.b TempBuffer+6
		
		ldy.w #0				;clear source counter
		tyx						;clear target counter

PlayVideoSetupTilemapLoop:
		lda.b [TempBuffer+5],y
		ora.w #$2000			;set priority bit
		sta.w Bg2MapBuffer&$ffff,x
		inx
		inx
		iny
		iny
		cpy.w #32*23*2			;total tilemap size reached?
		bne PlayVideoSetupTilemapLoop





		


;upload tilemap
		sep #$20
		ldx.b DmaFifoPointer
		lda #1					;transfer type
		sta.l DmaFifoEntryType,x
		
		lda.b #$7e
		sta.l DmaFifoEntrySrcLo+2,x
		rep #$31
		lda.w VramBg2Tilemap			;tilemap space
		sta.l DmaFifoEntryTarget,x
		lda.w #Bg2MapBuffer&$ffff
		sta.l DmaFifoEntrySrcLo,x
	
		lda.w #32*23*2
		sta.l DmaFifoEntryCount,x
		txa						;update fifo entry pointer
		clc
		adc.w #DmaFifoEntryLength
		sta.b DmaFifoPointer		


;upload tiles
		sep #$20
		ldy.b TempBuffer+3
		ldx.b DmaFifoPointer
		lda #1					;transfer type
		sta.l DmaFifoEntryType,x
		rep #$31
		lda.w VramBg2Tiles			;tile space
		sta.l DmaFifoEntryTarget,x
		lda.b [TempBuffer],y
		clc
		adc.w #$800				;add tilemap base
		sta.l DmaFifoEntrySrcLo,x
		iny
		iny
		sep #$20
		lda.b [TempBuffer],y
		sta.l DmaFifoEntrySrcLo+2,x
		rep #$31
		
		iny
		lda.b [TempBuffer],y
		sec
		sbc.w #$800				;sub tilemap base
		sta.l DmaFifoEntryCount,x
		txa						;update fifo entry pointer
		clc
		adc.w #DmaFifoEntryLength
		sta.b DmaFifoPointer		
		plp
		rts

