/*
-scrolling		
	-have a counter that goes from 0 to 7 for x and y directions.
	 if it reaches $ff/8, load a new tileline in that direction.
	 also, reset the counter to 8/0, then upload updated tilemap.
	-4 routines for each scroll direction
	-each of these does the following:
		-take a 3bit scroll speed variable as input(speed 0-7 pixels per frame)
		-check if a scroll into a new tile has occured
		-if yes, update current bg map position and pointers to current h/v tile-row in vram, h/v tilemap-row in vram and pointer to first tile of tileline in map buffer(sa1 ram or rom)
			-upload the line of tiles and update the tilemap. tilemap tile-numbers must be derived from current value of tileline pointer.
				-get physical address of first tile of tileline to be uploaded
				-get vram adress to upload to by multiplying BgScrollOffsetPointerTilesX with 32, then adding bg1 tiles vram offset
				-for vertical tilelines: get space between tiles to upload by multiplying level x-size with 64, then upload screensizeY-1 tiles
				-for horizontal tilelines: just upload screensizeX-1 tiles

		-scroll layer


REMINDER:
normal routines and nmi must use two different dma channels to upload stuff, so nmi doesnt overwrite transfer settings

	
variables:
BgScrollCounterX		db	;ranges from 0-7 inside one tile
BgScrollCounterY		db
BgMapCurrentPositionX		db	;current upper left tile on screen
BgMapCurrentPositionY		db
BgScrollRowUploadDisplace	db	;number of tiles to add/substract when uploading tilerows. this gets added to current position in map depending on the scrolling direction.(scroll right: add 29/scroll left: substract 1)
BgScrollOffsetPointerTilesX		db	;pointer to current vertical column that holds the leftmost tiles onscreen(goes from 0-27)
BgScrollOffsetPointerTilesY		db
BgScrollOffsetPointerTilemapX		db	;pointer to current vertical column that holds the leftmost tiles onscreen for tilemap (goes from 0-32)
BgScrollOffsetPointerTilemapY		db
BgScrollTileSourcePointer	ds 3		;pointer to first tile of tileline to be uplodaded
*/


/*
in: a,3bits: number of pixels to scroll(max 8)
*/
BgScrollRight:
	php
	rep #$31
;************************************************
;check if tile upload is due
	and.w #%111		;get lower 3 bits(0-7) of pixels to scroll only
	beq BgScrollRightNoScroll
	sta.b TempBuffer
	sep #$20

	lda.w MapSizeX
	sec
	sbc.b #TileBufferSizeX		;get maximum value for map position+1 to detect overflows
	sta.b TempBuffer+2
	cmp.b BgMapCurrentPositionX
	bne BgScrollRightScroll

	lda.b BgScrollCounterX		;check if at right border of map
	clc
	adc.b TempBuffer		;add speed
	cmp.b #7
	bcc BgScrollRightScroll		;check if were overflowing from border
	
	lda.b #7
	sec				;calculate pixels left
	sbc.b BgScrollCounterX

	beq BgScrollRightNoScroll	;dont scroll at all if already at end

	sta.b TempBuffer		;store as new speed in order to scroll to the edge of the map
	
BgScrollRightScroll:
	rep #$31
	lda.b TempBuffer
	adc.b ScreenPixelPositionX	;store new pixel position of screen
	sta.b ScreenPixelPositionX
	sep #$20

	lda.b TempBuffer
	clc
	adc.b BgScrollCounterX		;add to current counter 
	bit.b #%11111000
	beq BgScrollRightNoTileReload	;scroll layer and dont upload new tiles if the scrollcounter didnt overflow
	
	and.b #%00000111		;store remainder of overflow in scrollcounter
	sta.b BgScrollCounterX
	lda.b BgMapCurrentPositionX
	cmp.b TempBuffer+2		;check if we are at the rightmost edge of the map
	bcc BgScrollRightCheckCurrentPositionX
	plp
	rts
BgScrollRightCheckCurrentPositionX:
	inc a
	sta.b BgMapCurrentPositionX	;store new position	
	lda.b BgScrollOffsetPointerTilesX
	inc a
	cmp.b #TileBufferSizeX			;check if pointer into vertical tilerows wraps around
	bcc BgScrollRightCheckCurrentPositionX2
	
	lda.b #0				;reset pointer to first row
BgScrollRightCheckCurrentPositionX2:
	sta.b BgScrollOffsetPointerTilesX	;store new pointer
	lda.b BgScrollOffsetPointerTilemapX
	inc a
	and.b #TileMapSizeX
	sta.b BgScrollOffsetPointerTilemapX
	lda.b #TileBufferSizeX-1			;get row right of rightmost tile on screen.
	sta.b BgScrollRowUploadDisplace
	lda.b #$00
	sta.b BgScrollTilemapRowUploadDisplaceX
	jsr BgScrollUploadVerticalTileRow

	lda.b BgScrollCounterX
BgScrollRightNoTileReload:
	sta.b BgScrollCounterX
	rep #$31
	lda.b BG1HOfLo			;scroll bg1
	adc.b TempBuffer
	sta.b BG1HOfLo
	plp
	rts
	
BgScrollRightNoScroll:
	plp
	rts


BgScrollLeft:
	php
	rep #$31
;************************************************
;check if tile upload is due
	and.w #%111		;get lower 3 bits(0-7) only
	beq BgScrollLeftNoScroll
	sta.b TempBuffer
	sep #$20
	lda.b BgMapCurrentPositionX	;this must be initialized by the levelloader.
	bne BgScrollLeftNoStop

	lda.b BgScrollCounterX
	sec
	sbc.b TempBuffer		;substract speed
	bpl BgScrollLeftNoStop		;check if were overflowing from border
					
	lda.b BgScrollCounterX		;the scroll counter is how many pixels are left

	beq BgScrollLeftNoScroll	;dont scroll at all if already at end

	sta.b TempBuffer		;store as new speed in order to scroll to the edge of the map

BgScrollLeftNoStop:
	rep #$31
	lda.b ScreenPixelPositionX	;store new pixel position of screen	
	sec
	sbc.b TempBuffer	
	sta.b ScreenPixelPositionX
	sep #$20

	lda.b BgScrollCounterX
	sec
	sbc.b TempBuffer		;add to current counter 
	bit.b #%11111000
	beq BgScrollLeftNoTileReload	;scroll layer and dont upload new tiles if the scrollcounter didnt overflow
	
	and.b #%00000111		;store remainder of overflow in scrollcounter
	sta.b BgScrollCounterX
	lda.b BgMapCurrentPositionX
	bne BgScrollLeftCheckCurrentPositionX

	plp
	rts
BgScrollLeftCheckCurrentPositionX:
	dec a
	sta.b BgMapCurrentPositionX	;store new position	
	lda.b #$00				;get row left of leftmost tile on screen. maybe $ff/$fd depending on carry?
	sta.b BgScrollRowUploadDisplace
	lda.b #$04				;get row left of leftmost tile on screen. maybe $ff/$fd depending on carry?
	sta.b BgScrollTilemapRowUploadDisplaceX
	jsr BgScrollUploadVerticalTileRow
	
	lda.b BgScrollOffsetPointerTilesX
	dec a
	bpl BgScrollLeftCheckCurrentPositionX2
	
	lda.b #TileBufferSizeX-1			;maybe #TileBufferSizeX-1 ???
BgScrollLeftCheckCurrentPositionX2:
	sta.b BgScrollOffsetPointerTilesX	;store new pointer
	lda.b BgScrollOffsetPointerTilemapX
	dec a
	and.b #TileMapSizeX
	sta.b BgScrollOffsetPointerTilemapX
	lda.b BgScrollCounterX
BgScrollLeftNoTileReload:
	sta.b BgScrollCounterX
	rep #$31
	lda.b BG1HOfLo			;scroll bg1
	sec
	sbc.b TempBuffer
	sta.b BG1HOfLo
BgScrollLeftNoScroll:
	plp
	rts



BgScrollDown:
	php
	rep #$31
;************************************************
;check if tile upload is due
	and.w #%111		;get lower 3 bits(0-7) only
	beq BgScrollDownNoScroll
	sta.b TempBuffer
	sep #$20

	lda.w MapSizeY
	sec
	sbc.b #TileBufferSizeY		;get maximum value for map position+1 to detect overflows
	sta.b TempBuffer+2
	cmp.b BgMapCurrentPositionY
	bne BgScrollDownScroll

	lda.b BgScrollCounterY		;check if at right border of map
	clc
	adc.b TempBuffer		;add speed
	cmp.b #7
	bcc BgScrollDownScroll		;check if were overflowing from border
	
	lda.b #7
	sec				;calculate pixels left
	sbc.b BgScrollCounterY

	beq BgScrollDownNoScroll	;dont scroll at all if already at end

	sta.b TempBuffer		;store as new speed in order to scroll to the edge of the map
;	beq BgScrollDownNoScroll
	
BgScrollDownScroll:
	rep #$31
	lda.b ScreenPixelPositionY
	adc.b TempBuffer
	sta.b ScreenPixelPositionY
	sep #$20

	lda.b TempBuffer
	clc
	adc.b BgScrollCounterY		;add to current counter 
	bit.b #%11111000
	beq BgScrollDownNoTileReload	;scroll layer and dont upload new tiles if the scrollcounter didnt overflow
	
	and.b #%00000111		;store remainder of overflow in scrollcounter
	sta.b BgScrollCounterY
	lda.b BgMapCurrentPositionY
	cmp.b TempBuffer+2		;check if we are at the Downmost edge of the map
	bcc BgScrollDownCheckCurrentPositionY
	plp
	rts
BgScrollDownCheckCurrentPositionY:
	inc a
	sta.b BgMapCurrentPositionY	;store new position	
	lda.b BgScrollOffsetPointerTilesY
	inc a
	cmp.b #TileBufferSizeY			;check if pointer into vertical tilerows wraps around
	bcc BgScrollDownCheckCurrentPositionY2
	
	lda.b #0				;reset pointer to first row
BgScrollDownCheckCurrentPositionY2:
	sta.b BgScrollOffsetPointerTilesY	;store new pointer
	lda.b BgScrollOffsetPointerTilemapY
	inc a
	and.b #TileMapSizeY
	sta.b BgScrollOffsetPointerTilemapY
	lda.b #TileBufferSizeY-1			;get row Down of Downmost tile on screen.
	sta.b BgScrollRowUploadDisplace
	lda.b #$00
	sta.b BgScrollTilemapRowUploadDisplaceY
	jsr BgScrollUploadHorizontalTileRow

	lda.b BgScrollCounterY
BgScrollDownNoTileReload:
	sta.b BgScrollCounterY
	rep #$31
	lda.b BG1VOfLo			;scroll bg1
	adc.b TempBuffer
	sta.b BG1VOfLo
	plp
	rts
	
BgScrollDownNoScroll:
	plp
	rts

BgScrollUp:
	php
	rep #$31
;************************************************
;check if tile upload is due
	and.w #%111		;get lower 3 bits(0-7) only
	beq BgScrollUpNoScroll
	sta.b TempBuffer
	sep #$20
	lda.b BgMapCurrentPositionY	;this must be initialized by the levelloader.
	bne BgScrollUpNoStop

;	lda.b BgScrollCounterY
;	beq BgScrollUpNoScroll

	lda.b BgScrollCounterY
	sec
	sbc.b TempBuffer		;substract speed
	bpl BgScrollUpNoStop		;check if were overflowing from border
					
	lda.b BgScrollCounterY		;the scroll counter is how many pixels are left

	beq BgScrollUpNoScroll	;dont scroll at all if already at end

	sta.b TempBuffer		;store as new speed in order to scroll to the edge of the map


BgScrollUpNoStop:
	rep #$31
	lda.b ScreenPixelPositionY
	sec
	sbc.b TempBuffer
	sta.b ScreenPixelPositionY
	sep #$20

	lda.b BgScrollCounterY
	sec
	sbc.b TempBuffer		;add to current counter 
	bit.b #%11111000
	beq BgScrollUpNoTileReload	;scroll layer and dont upload new tiles if the scrollcounter didnt overflow
	
	and.b #%00000111		;store remainder of overflow in scrollcounter
	sta.b BgScrollCounterY
	lda.b BgMapCurrentPositionY
	bne BgScrollUpCheckCurrentPositionY

	plp
	rts
BgScrollUpCheckCurrentPositionY:
	dec a
	sta.b BgMapCurrentPositionY	;store new position	
	lda.b #$00				;get row Up of Upmost tile on screen. maybe $ff/$fd depending on carry?
	sta.b BgScrollRowUploadDisplace
	lda.b #$06				;get row Up of Upmost tile on screen. maybe $ff/$fd depending on carry?
	sta.b BgScrollTilemapRowUploadDisplaceY
	jsr BgScrollUploadHorizontalTileRow
	
	lda.b BgScrollOffsetPointerTilesY
	dec a
	bpl BgScrollUpCheckCurrentPositionY2
	
	lda.b #TileBufferSizeY-1			;maybe #TileBufferSizeX-1 ???
BgScrollUpCheckCurrentPositionY2:
	sta.b BgScrollOffsetPointerTilesY	;store new pointer
	lda.b BgScrollOffsetPointerTilemapY
	dec a
	and.b #TileMapSizeY
	sta.b BgScrollOffsetPointerTilemapY
	lda.b BgScrollCounterY
BgScrollUpNoTileReload:
	sta.b BgScrollCounterY
	rep #$31
	lda.b BG1VOfLo			;scroll bg1
	sec
	sbc.b TempBuffer
	sta.b BG1VOfLo
BgScrollUpNoScroll:
	plp
	rts




BgScrollUploadHorizontalTileRow:
	php
;************************************************
;calculate offset of first tile of tilerow to be uploaded

	sep #$31
	lda.b #0
	sbc.b BgScrollRowUploadDisplace		;get inverted value of displacement to increase tile source pointer x
	tax
	rep #$20
	lda.w MapSizeX
	and.w #$00ff
	sta.b TempBuffer+2
	lda.w #0

BgScrollHorCalcTotalStartPositionLoop:
	cpx.b BgMapCurrentPositionY
	beq BgScrollHorCalcTotalStartPositionDone
	clc
	adc.b TempBuffer+2
	inx
	bra BgScrollHorCalcTotalStartPositionLoop

BgScrollHorCalcTotalStartPositionDone:
	pha
	lda.b BgMapCurrentPositionX		;add current x position
	and.w #$00ff
	rep #$31
	sta.b TempBuffer+2
	pla
	clc
	adc.b TempBuffer+2			;a now contains the number of the first tile of the leftmost tilerow on screen
	sta.b TempBuffer+2
	
	jsr LoadLevelCalculateFilePosition	;calculate position in file
;upload vertical tileline.
;TempBuffer+2:			amount of bytes to advance between individual tiles(one tileline in complete map)
;x,16bit:			vram target adress
;ThreeBytePointerLo2,24bit:	pointer to current tile in source
;y,16bit:			counter for number of tiles already transfered	
    
	rep #$21
	sep #$10
	ldx.b #0
	lda.w #0

BgScrollHorCalcTotalStartPositionLoop2:
	cpx.b BgScrollOffsetPointerTilesY
	beq BgScrollHorCalcTotalStartPositionDone2
	clc
	adc.w #TileBufferSizeX				;count tiles for vertical lines
	inx
	bra BgScrollHorCalcTotalStartPositionLoop2

BgScrollHorCalcTotalStartPositionDone2:
	sta.b TempBuffer+6				;store first tile of line
	pha
	lda.b BgScrollOffsetPointerTilesX		;add x position
	and.w #$ff
	inc a						;increase by one because BgScrollOffsetPointerTilesX always shows the current, not the next line
	cmp #TileBufferSizeX
	bcc BgScrollHorCalcTotalStartPositionDone2NoWrap
	
	lda #0						;load 0 if it wraps around
BgScrollHorCalcTotalStartPositionDone2NoWrap:
	sta.b TempBuffer+4				;TempBuffer+2 now contains the current v-row pointer and can be used to calculate number of tiles to transfer and secend transfer if not zero.
	pla
	clc
	adc.b TempBuffer+4				;add to y-counter

	asl a
	asl a
	asl a
	asl a
	asl a
	adc.b VramBg1Tiles
;	sta.w $2116
	rep #$31
	ldx.b DmaFifoPointer
	sta.l DmaFifoEntryTarget,x	
	
;BgScrollVerticalRowDMALoop:
	lda #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x

	lda.b ThreeBytePointerLo2
	sta.l DmaFifoEntrySrcLo,x			;Store the data offset into DMA source offset
	lda.b ThreeBytePointerHi2	;store high byte and bank
	sta.l DmaFifoEntrySrcHi,x
	lda.w #TileBufferSizeX		;variable length
	sec
	sbc.b TempBuffer+4		;substract y-row offset to get number of tiles to transfer
	clc
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a				;multiply by 64(size of one tile)
	sta.l DmaFifoEntryCount,x			;length: one horizontal 256color tileline
	
	txa
	clc
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer

;check if line is split in tilebuffer and a second transfer needs to be done
	lda.b TempBuffer+4			;dont do a second dma transfer if at v-row 0
	beq UpdateHorLineUpdateTilemap
	
	lda.b TempBuffer+2			;get tilenumber of first tile in row(in the level source file)
	clc
	adc.w #TileBufferSizeX			;add another screen line
	sec
	sbc.b TempBuffer+4			;substract offset to get first tile number of additional dma transfer
	
	jsr LoadLevelCalculateFilePosition	;calculate position in file
	
	ldx.b DmaFifoPointer
	lda #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x

	lda.b ThreeBytePointerLo2
	sta.l DmaFifoEntrySrcLo,x		;source 4202
	lda.b ThreeBytePointerHi2	;store high byte and bank
	sta.l DmaFifoEntrySrcHi,x		;source 4203
	lda.b TempBuffer+4		;calculate number of bytes to transfer(number of tiles*64)
	clc
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a				;multiply by 64(size of one tile)
	sta.l DmaFifoEntryCount,x		;length 4205
	sta TempBuffer+8		;total length of transfer
	lda.b TempBuffer+6		;get initial v-line for transfer and multiply by 32
	clc
	asl a
	asl a
	asl a
	asl a
	asl a
	adc.b VramBg1Tiles
	sta.b TempBuffer+10
	sta.l DmaFifoEntryTarget,x		;vram target 2116

	txa						;update fifo entry pointer
	clc
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer

/*
	sep #$20
	lda.b #$01
	sta.w $420b			;init transfer
	rep #$31
*/
;check if transfer is crossing a bank boundary
	lda.b TempBuffer+8		;get transfer length
	adc.b ThreeBytePointerLo2	;check if bank overflows
	bcc HorTileUploadNoWrap1

	jsr HorTileUploadDoDmaFifoEntry

	
HorTileUploadNoWrap1:

;******************************************	
;update tilemap:
;a,16bit:	tilenumber counter
;x,16bit:	target buffer pointer	
;y,16bit:	number of tilemap entries/rows to update
/*
write position depends on x and y tilemap pointern.
if the write wraps around, it must be reset to the beginning of the line
*/
UpdateHorLineUpdateTilemap:
;get current position in tilemap output buffer to write to next(in bytes), put into x
	sep #$20
	lda.b BgScrollOffsetPointerTilemapY	;position in tilemap(0-31, starts at 25)
	clc
	adc.b BgScrollTilemapRowUploadDisplaceY	;add displacement depending on scroll direction
	rep #$31
	and.w #TileMapSizeY
	
	asl a					;multiply by 32 to get line offset in tilemap
	asl a
	asl a
	asl a
	asl a
	
	sta.b TempBuffer+2
	sta.b TempBuffer+6			;we will issue a dma fifo for 2 consecutive lines from this point on later(just uploading 2 full lines is easier than calculating the exact start and end position of the updated tiles)
	lda.w #0
	sep #$20
	lda.b BgScrollOffsetPointerTilemapX
	adc.b #5
	and.b #TileMapSizeX
	rep #$31
	adc.b TempBuffer+2

	asl a					;multiply by 2 because tilemap entries are words
	tax
	phx
	
	clc
	lda.b BgScrollOffsetPointerTilesY	;position in screen tiles(0-25, starts at 25)
	and.w #$00ff

;calculate position in tile output buffer(in tiles)
	rep #$21
	sep #$10
	ldy.b #0
	lda.w #0				;a

BgScrollHorCalcTotalStartPositionLoop3:
	cpy.b BgScrollOffsetPointerTilesY
	beq BgScrollHorCalcTotalStartPositionDone3
	clc
	adc.w #TileBufferSizeX				;add the number of tiles in a row(28) to get total y-line tilecount
	iny
	bra BgScrollHorCalcTotalStartPositionLoop3

BgScrollHorCalcTotalStartPositionDone3:
;add x-position of tilebuffer counter:
	sta.b TempBuffer+2
	lda.w #$0
	sep #$20	
	lda.b BgScrollOffsetPointerTilesX	;get current
	inc a
	cmp.b #TileBufferSizeX
	bcc BgScrollHorCalcTotalStartPositionDone4

	lda.b #0
BgScrollHorCalcTotalStartPositionDone4:
	rep #$31
	sta.b TempBuffer+4
	adc.b TempBuffer+2

	plx
	ldy.w #0				;clear linelength counter	
BgScrollHorizontalRowUpdateTilemapLoop:
	sta.l Bg1MapBuffer,x			;store in tilemap buffer
	inx					;next tilemap entry
	inx
	
	pha
	txa
	bit.w #%111111				;check if at beginning of new line(only occurs if line wraps around)
	bne BgScrollHorizontalRowUpdateTilemapLoopNoWrap
	
	sec
	sbc.w #64				;substract one line and start over at last one
	tax
	
BgScrollHorizontalRowUpdateTilemapLoopNoWrap:	
	pla
	inc a					;increase tilecounter and reset if it crossed the 27th tile boundary
	pha
	lda.b TempBuffer+4
	inc a
	cmp.w #TileBufferSizeX
	bcc BgScrollHorCalcTotalStartPositionDone5

	stz.b TempBuffer+4
	pla
	sec
	sbc.w #TileBufferSizeX
	bra BgScrollHorCalcTotalStartPositionDone6
BgScrollHorCalcTotalStartPositionDone5:
	sta.b TempBuffer+4
	pla

BgScrollHorCalcTotalStartPositionDone6:
	iny
	cpy.w #TileBufferSizeX
	bne BgScrollHorizontalRowUpdateTilemapLoop
	
;	inc.b NMIBg1UploadFlag			;update tilemap during nmi
;	jsr UploadBg1TilemapFifo			

	rep #$31
	ldx.b DmaFifoPointer
	lda #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x
	
	lda.b TempBuffer+6					;get starting line position in bg1 map buffer
	clc
	adc.b VramBg1Tilemap					;and add bg1 tilemap position in vram
	sta.l DmaFifoEntryTarget,x		;vram target 2116
	lda.b TempBuffer+6					;get position in bg1 map buffer
	asl a							;each entry is 2 bytes
	clc	
	adc.w #Bg1MapBuffer & $ffff				;and add buffer offset
	sta.l DmaFifoEntrySrcLo,x		;source 4302
	lda.w #(TileMapSizeX+1)*2				;each tilemap entry is 2 bytes and we`re uploading 2 lines. previously set to *4, now *2 to prevent overflow writes into sprite tile buffer. may cause problems in the long run
	sta.l DmaFifoEntryCount,x		;length 4305
	sep #$20
	lda.b #(Bg1MapBuffer >> 16)
	sta.l DmaFifoEntrySrcBank,x		;source 4304
	rep #$31
	txa						;update fifo entry pointer
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer


	plp
	rts

HorTileUploadDoDmaFifoEntry:
	ldx.b DmaFifoPointer
;store length of additional bank-wrap transfer:
	sta.l DmaFifoEntryCount,x		;length 4205
;calculate vram target of additional bank-wrap transfer:
	eor.w #$ffff			;this is actually a subtraction, but doing it with a reversed addition is easier
	sec
	adc.b TempBuffer+8		;get relevant length of last transfer
	clc
	lsr a				;/2, vram word align
	clc
	adc.b TempBuffer+10
	sta.l DmaFifoEntryTarget,x		;vram target 2116
	
;update dma source, beginning of next bank:
	lda.w #0
	sta.l DmaFifoEntrySrcLo,x		;source 4202
	lda.b ThreeBytePointerBank2
	and.w #$ff
	inc a
	sta.l DmaFifoEntrySrcBank,x		;source 4204
	sep #$20
	lda #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x
	rep #$31
	
	txa						;update fifo entry pointer
;	clc
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer

	
;	stz.w $4302			;Store the data offset into DMA source offset
;	sep #$20
;	inc.w $4304
;init transfer	
;	lda.b #$01
;	sta.w $420b			;init transfer
	rts

	
BgScrollUploadVerticalTileRow:
	php
;************************************************
;calculate offset of first tile of tilerow to be uploaded
	rep #$21
	sep #$10
	lda.w MapSizeX
	and.w #$00ff
	sta.b TempBuffer+2
	
	ldx.b #0
	lda.w #0

BgScrollCalcTotalStartPositionLoop:
	cpx.b BgMapCurrentPositionY
	beq BgScrollCalcTotalStartPositionDone
	clc
	adc.b TempBuffer+2
	inx
	bra BgScrollCalcTotalStartPositionLoop

BgScrollCalcTotalStartPositionDone:
	pha
	lda.b BgMapCurrentPositionX		;add current x position
	and.w #$00ff
	sep #$20
	clc
	adc.b BgScrollRowUploadDisplace		;do a 8bit add only so negative values can be used to substract

	rep #$31
	sta.b TempBuffer+2
	pla
	clc
	adc.b TempBuffer+2			;a now contains the number of the first tile of the leftmost tilerow on screen

	jsr LoadLevelCalculateFilePosition	;calculate position in file
;upload vertical tileline.
;TempBuffer+2:			amount of bytes to advance between individual tiles(one tileline in complete map)
;x,16bit:			vram target adress
;ThreeBytePointerLo2,24bit:	pointer to current tile in source
;y,16bit:			counter for number of tiles already transfered	
	rep #$31
	
	lda.w MapSizeX			;calculate amount of bytes to advance in source buffer between tiles
	and.w #$00ff
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	sta.b TempBuffer+2 

	sep #$20
;calculate current y position in tilebuffer to upload tiles to	
	clc
	lda.b BgScrollOffsetPointerTilesY
	inc a
	cmp.b #TileBufferSizeY
	bcc BgScrollVertPosCalc1		;check if it wraps around
	lda.b #0

BgScrollVertPosCalc1:
	sta.b TempBuffer+6			;this is the current yline in tilebuffer to upload tiles to
	rep #$21
	sep #$10
	
	ldx.b #0
	lda.w #0

BgScrollHorCalcTotalStartPositionLoop7:
	cpx.b TempBuffer+6
	beq BgScrollHorCalcTotalStartPositionDone7
	clc
	adc.w #TileBufferSizeX				;count tiles for vertical lines
	inx
	bra BgScrollHorCalcTotalStartPositionLoop7

BgScrollHorCalcTotalStartPositionDone7:
	sta.b TempBuffer+6			;this is the new y-tileposition in tilebuffer to uplad to				;store first tile of line
	lda.b BgScrollOffsetPointerTilesX		;add x position
	and.w #$ff
	clc
	adc.b TempBuffer+6				;add to y-counter

	asl a
	asl a
	asl a
	asl a
	asl a
	adc.b VramBg1Tiles
	rep #$31
	tax					;x is vram target adress
	ldy.w #TileBufferSizeY			;y is number of tiles to upload, minus the additional buffer tile

BgScrollVerticalRowDMALoop:	
	stx.b TempBuffer+10
	txa
	ldx.b DmaFifoPointer
	sta.l DmaFifoEntryTarget,x		;vram target 2116
;	stx.w $2116
	lda #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x

	lda.b ThreeBytePointerLo2
	sta.l DmaFifoEntrySrcLo,x		;source 4202
	lda.b ThreeBytePointerHi2	;store high byte and bank
	sta.l DmaFifoEntrySrcHi,x		;source 4203
	lda.w #64
	sta.l DmaFifoEntryCount,x		;length 4205
	sta.b TempBuffer+8
	
	txa						;update fifo entry pointer
	clc
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer
	
	ldx.b TempBuffer+10

;check if transfer is crossing a bank boundary
	lda.b TempBuffer+8		;get transfer length
	adc.b ThreeBytePointerLo2	;check if bank overflows
	bcc VertTileUploadNoWrap1

	jsr VertTileUploadWrap

VertTileUploadNoWrap1:


	rep #$31
	txa
	adc.w #TileBufferSizeX*32	;add one screenline-buffertile to vram target adress
	tax
	cmp.w #TileBufferSizeY*TileBufferSizeX*32	;check
	bcc BgScrollVerticalRowDMALoopNoBufferWrap
	lda.b BgScrollOffsetPointerTilesX		;add x position
	and.w #$ff
	asl a
	asl a
	asl a
	asl a
	asl a
	tax	
BgScrollVerticalRowDMALoopNoBufferWrap:
	lda.b ThreeBytePointerLo2
	clc
	adc.b TempBuffer+2
	bcc BgScrollVerticalRowDMANoBankWrap

	inc.b ThreeBytePointerBank2	;increase source bank if an overflow occured
BgScrollVerticalRowDMANoBankWrap:
	sta.b ThreeBytePointerLo2 
	dey
	bne BgScrollVerticalRowDMALoop

BgScrollVerticalUpdateTilemap:
;******************************************	
;update tilemap:
;a,16bit:	tilenumber counter
;x,16bit:	target buffer pointer	
;y,16bit:	number of tilemap entries/rows to update
;$38
	sep #$20
	lda.b BgScrollOffsetPointerTilemapY	;position in tilemap(0-31, starts at 25)
	clc
	adc.b #7
	rep #$31
	and.w #TileMapSizeY
	
	asl a					;multiply by 32 to get line offset in tilemap
	asl a
	asl a
	asl a
	asl a
	
	sta.b TempBuffer+2
	lda.w #0
	sep #$20
	lda.b BgScrollOffsetPointerTilemapX
	clc
	adc.b BgScrollTilemapRowUploadDisplaceX	;add displacement depending on scroll direction
	and.b #TileMapSizeX
	rep #$31
	sta.b TempBuffer+8			;this is our starting y-line of the two we`re going to upload to vram
	adc.b TempBuffer+2

	asl a					;multiply by 2 because tilemap entries are words
	tax
	phx



;calculate position in tile output buffer(in tiles)
	sep #$20
	lda.b BgScrollOffsetPointerTilesY
	inc a
	cmp.b #TileBufferSizeY
	bcc BgScrollVertCalcTotalStartPositionDone8

	lda.b #0
BgScrollVertCalcTotalStartPositionDone8:
	sta.b TempBuffer+4
	rep #$21
	sep #$10
	ldy.b #0
	lda.w #0
					;a

BgScrollVertCalcTotalStartPositionLoop3:
	cpy.b TempBuffer+4
	beq BgScrollVertCalcTotalStartPositionDone3
	clc
	adc.w #TileBufferSizeX				;add the number of tiles in a row(28) to get total y-line tilecount
	iny
	bra BgScrollVertCalcTotalStartPositionLoop3
	
	sta.b TempBuffer+6
BgScrollVertCalcTotalStartPositionDone3:
;add x-position of tilebuffer counter:
	sta.b TempBuffer+2
	lda.w #$0
	sep #$20	
	lda.b BgScrollOffsetPointerTilesX	;get current
	rep #$31
	sta.b TempBuffer+4
	adc.b TempBuffer+2
	plx
	ldy.w #0				;clear linelength counter	

BgScrollVerticalRowUpdateTilemapLoop:
	sta.l Bg1MapBuffer,x			;store in tilemap buffer
	
	pha
	txa
	clc
	adc.w #(TileMapSizeX+1)*2			;add one tileline (32 entries, each 2 bytes) to counter

	cmp.w #(TileMapSizeY+1)*(TileMapSizeX+1)*2
	bcc BgScrollVertRowUpdateTilemapLoopNoWrap
	
	sec
	sbc.w #(TileMapSizeY+1)*(TileMapSizeX+1)*2
BgScrollVertRowUpdateTilemapLoopNoWrap:	
	tax
	pla
	clc
	adc.w #TileBufferSizeX			;add one line to tile counter

	cmp.w #TileBufferSizeY*TileBufferSizeX
	bcc BgScrollVertRowUpdateTilemapLoopNoWrap2
	
	sec
	sbc.w #TileBufferSizeY*TileBufferSizeX
BgScrollVertRowUpdateTilemapLoopNoWrap2:	

	iny
	cpy.w #TileBufferSizeY
	bne BgScrollVerticalRowUpdateTilemapLoop
	
;	inc.b NMIBg1UploadFlag			;update tilemap during nmi
;	jsr UploadBg1TilemapFifo						
	
;	rep #$31


	rep #$31
	ldy.w #0
BgScrollUploadVertRowDmaFifoLoop:
/*
	ldx.b DmaFifoPointer
	lda #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x
	
	lda.b TempBuffer+8					;get starting line position in bg1 map buffer
;	lsr a
	clc
	adc.b VramBg1Tilemap					;and add bg1 tilemap position in vram
	sta.l DmaFifoEntryTarget,x		;vram target 2116
	lda.b TempBuffer+8					;get position in bg1 map buffer
	asl a							;each entry is 2 bytes
	clc	
	adc.w #Bg1MapBuffer & $ffff				;and add buffer offset
	sta.l DmaFifoEntrySrcLo,x		;source 4302
	lda.w #4				;each tilemap entry is 2 bytes and we`re uploading 2 lines
	sta.l DmaFifoEntryCount,x		;length 4305
	sep #$20
	lda.b #(Bg1MapBuffer >> 16)
	sta.l DmaFifoEntrySrcBank,x		;source 4304
	rep #$31
	txa						;update fifo entry pointer
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer
	
	lda.b TempBuffer+8				;goto next line
	clc
	adc.w #TileMapSizeX+1
	sta.b TempBuffer+8

	iny
	cpy.w #TileMapSizeY+1				;create 32 dma uploads
	bne BgScrollUploadVertRowDmaFifoLoop
*/
	ldx.b DmaFifoPointer
	lda #2					;transfer type normal dma
	sta.l DmaFifoEntryType,x
	lda.b TempBuffer+8					;get starting line position in bg1 map buffer
	clc
	adc.b VramBg1Tilemap					;and add bg1 tilemap position in vram
	sta.l DmaFifoEntryTarget,x		;vram target 2116
	lda.b TempBuffer+8					;get position in bg1 map buffer
	asl a							;each entry is 2 bytes
	clc	
	adc.w #Bg1MapBuffer & $ffff				;and add buffer offset
	sta.l DmaFifoEntrySrcLo,x		;source 4302
;	rep #$31
	txa						;update fifo entry pointer
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer

	plp
	rts
	
	
	
VertTileUploadWrap:	
	phx
	ldx.b DmaFifoPointer
;store length of additional bank-wrap transfer:
	sta.l DmaFifoEntryCount,x		;length 4205
;calculate vram target of additional bank-wrap transfer:
	eor.w #$ffff			;this is actually a subtraction, but doing it with a reversed addition is easier
	sec
	adc.b TempBuffer+8		;get relevant length of last transfer
	clc
	lsr a				;/2, vram word align
	clc
	adc.b TempBuffer+10
	sta.l DmaFifoEntryTarget,x		;vram target 2116
	lda.w #0
	sta.l DmaFifoEntrySrcLo,x		;source 4202
	lda.b ThreeBytePointerBank2
	and.w #$ff
	inc a
	sta.l DmaFifoEntrySrcBank,x		;source 4204

	sep #$20
	lda #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x
	rep #$31	

	txa						;update fifo entry pointer
;	clc
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer

	
	
	plx
	rts
/*
;update dma source, beginning of next bank:
	stz.w $4302			;Store the data offset into DMA source offset
	sep #$20
	inc.w $4304
;init transfer	
	lda.b #$01
	sta.w $420b			;init transfer
*/	

/*
this routine focusses the screen on a specified object.
input variables:
FocusScreenFlags	db		;flags for focus
					;bit7=enable focus on object
FocusScreenObject	db		;number of object in object list to focus to
FocusScreenSpline	db		;number of preset table to use for scrolling depending on distance to object(linear,sine,exp etc)
FocusScreenXWait	db		;frame wait counters for spline entries below 1
FocusScreenYWait	db

spline format:
128 entries per spline
lower nibble: movement speed
upper nibble: frames to wait between moving(only applicable if movement speed=0)

*/

FocusScreenOnObject:
	php
	phb
	rep #$31
	sep #$20
	lda.b #$7e			;data bank $7e, wram
	pha
	plb
	lda.b FocusScreenFlags		;check if focus is enabled
	bpl FocusScreenOnObjectExit	

	rep #$31
	lda.b FocusScreenSpline
	and.w #7			;maximum number of splines:8
	clc
	asl a
	tax	
	lda.l (FocusScreenSplineLut+BaseAdress),x
	
	sta.b ThreeBytePointerLo
	sep #$20	
	lda.b #(:FocusScreenSplineLut+BaseAdress>>16)
	sta.b ThreeBytePointerBank	;setup pointer to spline
	
	rep #$31
	lda.b FocusScreenObject
	and.w #$3f			;max object number:64

	asl a				;multiply by 16 to get pointer into object list
	asl a
	asl a
	asl a
	tax
	lda.w ObjEntryType,x 			;check if theres an object present in the selected slot, otherwise disable focussing
	bit.w #$80
	beq FocusScreenOnObjectExit

	
	jsr FocusScreenTestX	
	jsr FocusScreenTestY

FocusScreenOnObjectExit:
	plb
	plp
	rts


FocusScreenTestX:
	rep #$31
	lda.w ObjEntryXPos,x
	lsr a													;subpixel precision
	lsr a
	lsr a
	lsr a
	sta.w TempBufferTest
	lda.b ScreenPixelPositionX
	adc.w #(TileBufferSizeX/2)*8	;add half a screen pixelwidth
	sec
	sbc.w TempBufferTest
;	sbc.w ObjEntryXPos,x		;check if we`re in the middle of the screen
;	sec
;	sbc.w #16

	beq FocusScreenTestRetY		;goto y test if x is already focussed
	bcs FocusScreenSpriteIsLeft	;if carry is set, sprite is left of center
	bpl FocusScreenSpriteIsRightNoXor
	
	eor.w #$ffff			;if result is negative, xor
	inc a
FocusScreenSpriteIsRightNoXor:
	tay				;use remainder of substraction as pointer into spline table
	and.w #$ff80			;check if the value exceeds spline table
	beq FocusScreenSpriteIsRightnoMax
	
	lda.w #$7f			;if maximum is exceeded, load max value
	tay
FocusScreenSpriteIsRightnoMax:
	sep #$20
	lda.b [ThreeBytePointerLo],y
	beq FocusScreenTestRetY			;directly skip to y-test if speed and frame wait counter are 0

	clc
	adc.b FocusScreenXWait
	sta.b FocusScreenXWait
	
	lsr a												;divide by 16, remove subpixel precision
	lsr a
	lsr a
	lsr a
	
	phx
	jsr BgScrollRight
	plx
	lda.b FocusScreenXWait
	and.b #$0f								;just keep subpixel precicion
	sta.b FocusScreenXWait
	bra FocusScreenTestRetY

FocusScreenSpriteIsLeft:
	bpl FocusScreenSpriteIsLeftNoXor
	
	eor.w #$ffff
	inc a
FocusScreenSpriteIsLeftNoXor:
	tay				;use remainder of substraction as pointer into spline table
	and.w #$ff80			;check if the value exceeds spline table
	beq FocusScreenSpriteIsLeftnoMax
	
	lda.w #$7f			;if maximum is exceeded, load max value
	tay
FocusScreenSpriteIsLeftnoMax:
	sep #$20
	lda.b [ThreeBytePointerLo],y

	beq FocusScreenTestRetY			;directly skip to y-test if speed and frame wait counter are 0
	clc
	adc.b FocusScreenXWait
	sta.b FocusScreenXWait
	
	lsr a												;divide by 16, remove subpixel precision
	lsr a
	lsr a
	lsr a
	
	phx
	jsr BgScrollLeft
	plx
	lda.b FocusScreenXWait
	and.b #$0f								;just keep subpixel precicion
	sta.b FocusScreenXWait
FocusScreenTestRetY:
	rts

FocusScreenTestY:
	rep #$31
	lda.w ObjEntryYPos,x
	lsr a													;subpixel precision
	lsr a
	lsr a
	lsr a	
	sta.w TempBufferTest+2
	lda.b ScreenPixelPositionY
	adc.w #(TileBufferSizeY/2)*8	;add half a screen pixelwidth
	sec
	sbc.w TempBufferTest+2
;	sbc.w ObjEntryYPos,x		;check if we`re in the middle of the screen

	beq FocusScreenTestRet		;goto y test if x is already focussed
	bcs FocusScreenSpriteIsUp	;if carry is set, sprite is left of center
	bpl FocusScreenSpriteIsDownNoXor
	
	eor.w #$ffff			;if result is negative, xor
	inc a
FocusScreenSpriteIsDownNoXor:
	tay				;use remainder of substraction as pointer into spline table
	and.w #$ff80			;check if the value exceeds spline table
	beq FocusScreenSpriteIsDownnoMax
	
	lda.w #$7f			;if maximum is exceeded, load max value
	tay
FocusScreenSpriteIsDownnoMax:
	sep #$20
	lda.b [ThreeBytePointerLo],y
	beq FocusScreenTestRet
	clc
	adc.b FocusScreenYWait
	sta.b FocusScreenYWait
	
	lsr a												;divide by 16, remove subpixel precision
	lsr a
	lsr a
	lsr a
	
	phx
	jsr BgScrollDown
	plx
	lda.b FocusScreenYWait
	and.b #$0f								;just keep subpixel precicion
	sta.b FocusScreenYWait
	bra FocusScreenTestRet

FocusScreenSpriteIsUp:
	bpl FocusScreenSpriteIsUpNoXor
	
	eor.w #$ffff
	inc a
FocusScreenSpriteIsUpNoXor:
	tay				;use remainder of substraction as pointer into spline table
	and.w #$ff80			;check if the value exceeds spline table
	beq FocusScreenSpriteIsUpnoMax
	
	lda.w #$7f			;if maximum is exceeded, load max value
	tay
FocusScreenSpriteIsUpnoMax:
	sep #$20
	lda.b [ThreeBytePointerLo],y
	beq FocusScreenTestRet
	clc
	adc.b FocusScreenYWait
	sta.b FocusScreenYWait
	
	lsr a												;divide by 16, remove subpixel precision
	lsr a
	lsr a
	lsr a
	
	phx
	jsr BgScrollUp
	plx
	lda.b FocusScreenYWait
	and.b #$0f								;just keep subpixel precicion
	sta.b FocusScreenYWait
FocusScreenTestRet:
	rts



Battle3dScrollLeft:
	php
	phb
	sep #$20
	lda.b #$7e
	pha
	plb
	rep #$31
	ldy.w #0

Battle3dScrollLeftLoop:
	lda.w Hdma3dScrollBuffer&$ffff+4,y		;get first entries z-value
	and.w #$ff
	asl a					;word entries
	tax
	lda.l (BattleZScrollLUT+BaseAdress),x	;get corresponding scroll add value
	sta.b TempBuffer
;update h-scroll
	lda.w Hdma3dScrollBuffer&$ffff,y
	clc
	adc.b TempBuffer
	sta.w Hdma3dScrollBuffer&$ffff,y
	iny
	iny
	iny
	iny
	iny
	cpy.w #Hdma3dScrollLineNumber*5
	bne Battle3dScrollLeftLoop

;search all 3d sprites and scroll them:
	ldx.w #0
Battle3dScrollLeftObjLoop:
	lda.w ObjEntryType-1,x
;	bit.w #$0080				;end search if non-present object was encountered
;	xba
	bpl Battle3dScrollLeftObjEnd
	lda.w ObjEntryType,x
	bpl Battle3dScrollLeftObjNot3d		;sprite is present, check if it needs 3d processing
	
;update sprite position:
	lda.w ObjEntryZDisplacement,x		;get z-value
	and.w #$ff
	asl a					;word entries
	phx
	tax
	lda.l (BattleZScrollLUTSprites+BaseAdress),x	;get corresponding scroll add value
	plx
	sta.b TempBuffer
;update h-scroll
	lda.w ObjEntryXPos,x
	sec
	sbc.b TempBuffer
	sta.w ObjEntryXPos,x	


Battle3dScrollLeftObjNot3d:
	txa
	clc
	adc.w #ObjectFileSize			;goto next entry
	tax
	cpx.w #ObjectFileSize*64		;check all 64 entries.
	bne Battle3dScrollLeftObjLoop	
	
Battle3dScrollLeftObjEnd:	
	sep #$20
	inc.w Pseudo3dScrollUpdateFlag	

	plb
	plp
	rts

Battle3dScrollRight:
	php
	phb
	sep #$20
	lda.b #$7e
	pha
	plb
	rep #$31
	ldy.w #0

Battle3dScrollRightLoop:
	lda.w Hdma3dScrollBuffer&$ffff+4,y		;get first entries z-value
	and.w #$ff
	asl a					;word entries
	tax
	lda.l (BattleZScrollLUT+BaseAdress),x	;get corresponding scroll add value
	sta.b TempBuffer
;update h-scroll
	lda.w Hdma3dScrollBuffer&$ffff,y
	sec
	sbc.b TempBuffer
	sta.w Hdma3dScrollBuffer&$ffff,y
	iny
	iny
	iny
	iny
	iny
	cpy.w #Hdma3dScrollLineNumber*5
	bne Battle3dScrollRightLoop

;search all 3d sprites and scroll them:
	ldx.w #0
Battle3dScrollRightObjLoop:
	lda.w ObjEntryType-1,x
;	bit.w #$0080				;end search if non-present object was encountered
;	xba
	bpl Battle3dScrollRightObjEnd
	lda.w ObjEntryType,x
	bpl Battle3dScrollRightObjNot3d		;sprite is present, check if it needs 3d processing
	
;update sprite position:
	lda.w ObjEntryZDisplacement,x		;get z-value
	and.w #$ff
	asl a					;word entries
	phx
	tax
	lda.l (BattleZScrollLUTSprites+BaseAdress),x	;get corresponding scroll add value
	plx
	sta.b TempBuffer
;update h-scroll
	lda.w ObjEntryXPos,x
	clc
	adc.b TempBuffer
	sta.w ObjEntryXPos,x	


Battle3dScrollRightObjNot3d:
	txa
	clc
	adc.w #ObjectFileSize			;goto next entry
	tax
	cpx.w #ObjectFileSize*64		;check all 64 entries.
	bne Battle3dScrollRightObjLoop	
	
Battle3dScrollRightObjEnd:

	sep #$20
	inc.w Pseudo3dScrollUpdateFlag	
	plb
	plp
	rts	


Battle3dScrollDown:
	php
	phb
	sep #$20
	
	lda.b #$7e
	pha
	plb
;	dec.w Hdma3dScrollCountV
	rep #$31
;	inc.w BG1VOfLo
	ldy.w #0

Battle3dScrollDownLoop:
	lda.w Hdma3dScrollBuffer&$ffff+4,y		;get first entries z-value
	and.w #$ff
	asl a					;word entries
	tax
	lda.l (BattleZScrollLUT+BaseAdress),x	;get corresponding scroll add value
	sta.b TempBuffer
;update v-scroll
	lda.w Hdma3dScrollBuffer&$ffff+2,y
	clc
	adc.b TempBuffer
	sta.w Hdma3dScrollBuffer&$ffff+2,y
	iny
	iny
	iny
	iny
	iny
	cpy.w #Hdma3dScrollLineNumber*5
	bne Battle3dScrollDownLoop
 
; 	inc.b BG1VOfLo

;search all 3d sprites and scroll them:
	ldx.w #0
Battle3dScrollDownObjLoop:
	lda.w ObjEntryType-1,x
;	bit.w #$0080				;end search if non-present object was encountered
;	xba
	bpl Battle3dScrollDownObjEnd
	lda.w ObjEntryType,x
	bpl Battle3dScrollDownObjNot3d		;sprite is present, check if it needs 3d processing
	
;update sprite position:
	lda.w ObjEntryZDisplacement,x		;get z-value
	and.w #$ff
	eor.w #$3f
	asl a					;word entries
	phx
	tax
	lda.l (BattleZScrollLUTSprites+BaseAdress),x	;get corresponding scroll add value
	plx
	
	sta.b TempBuffer
;update h-scroll
	lda.w ObjEntryYPos,x
	clc
	adc.b TempBuffer
	sta.w ObjEntryYPos,x	


Battle3dScrollDownObjNot3d:
	txa
	clc
	adc.w #ObjectFileSize			;goto next entry
	tax
	cpx.w #ObjectFileSize*64		;check all 64 entries.
	bne Battle3dScrollDownObjLoop	
	
Battle3dScrollDownObjEnd:
	sep #$20
	inc.w Pseudo3dScrollUpdateFlag	

	plb
	plp
	rts


Battle3dScrollUp:
	php
	phb
	sep #$20
	lda.b #$7e
	pha
	plb
;	inc.w Hdma3dScrollCountV
	rep #$31
	lda.b BG1VOfLo
;	beq Battle3dScrollUpExit		;don't scroll lower than 0
	
;	dec.b BG1VOfLo
	
;	dec.w BG1VOfLo
	ldy.w #0

Battle3dScrollUpLoop:
	lda.w Hdma3dScrollBuffer&$ffff+4,y		;get first entries z-value
	and.w #$ff
	asl a					;word entries
	tax
	lda.l (BattleZScrollLUT+BaseAdress),x	;get corresponding scroll add value
	sta.b TempBuffer
;update v-scroll
	lda.w Hdma3dScrollBuffer&$ffff+2,y
	sec
	sbc.b TempBuffer
	sta.w Hdma3dScrollBuffer&$ffff+2,y
	iny
	iny
	iny
	iny
	iny
	cpy.w #Hdma3dScrollLineNumber*5
	bne Battle3dScrollUpLoop
	
Battle3dScrollUpExit:


	dec.b BG1VOfLo
	
;search all 3d sprites and scroll them:
	ldx.w #0
Battle3dScrollUpObjLoop:
	lda.w ObjEntryType-1,x
;	bit.w #$0080				;end search if non-present object was encountered
;	xba
	bpl Battle3dScrollUpObjEnd
	lda.w ObjEntryType,x
	bpl Battle3dScrollUpObjNot3d		;sprite is present, check if it needs 3d processing
	
;update sprite position:
	lda.w ObjEntryZDisplacement,x		;get z-value
	and.w #$ff
	eor.w #$3f
	asl a					;word entries
	phx
	tax
	lda.l (BattleZScrollLUTSprites+BaseAdress),x	;get corresponding scroll add value
	plx
	
	sta.b TempBuffer
;update h-scroll
	lda.w ObjEntryYPos,x
	sec
	sbc.b TempBuffer
	sta.w ObjEntryYPos,x	


Battle3dScrollUpObjNot3d:
	txa
	clc
	adc.w #ObjectFileSize			;goto next entry
	tax
	cpx.w #ObjectFileSize*64		;check all 64 entries.
	bne Battle3dScrollUpObjLoop	
	
Battle3dScrollUpObjEnd:
	sep #$20
	inc.w Pseudo3dScrollUpdateFlag	
	
	

	plb
	plp
	rts

