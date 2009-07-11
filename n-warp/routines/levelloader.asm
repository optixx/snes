/*
concept:
-have 112 color backgrounds using mode1.
-scroll in all directions with continual tile streaming.
-maximum screen size about 512x512pixels per map, but not limited per se.
-use palettes 1-7(112 colors)
-all individual tiles, no initial tilemap needed.
-complete map must be accessible to the snes cpu uncompressed, either by storing it in rom uncompressed or by decompressing it into ram (about 256kb/2mbit of ram needed)
-current/starting position on a map must be available as a global variable
-vram organization:
	-$0000-$b7ff	: bg1 tiles 728 out of 736 possible tiles used(tile 729 is blank)
	-$b800-$bfff	: bg1 tilemap
	-$c000-$ffff	: sprite tiles
-starting position on map must be passed via global variable, measured in tiles


todo-list:
-implement 112color background loading and streaming to a 224x208(28x26 tiles) vram buffer  (46kb/728 tiles, 216x200 visible) (peak dma load: $d80 bytes for diagonal scrolling)
	-initialize mode1, loadbgmode function, mode3, 32x32 tilemap at $b800, tiles for bg1 at $0, sprite tiles at $c000
	-upload palette
	-initialize tilemap
		-upload "clear tile" 729 (64bytes value $00 to vram adress B640)
		-clear tilemap
		-set background tiles for screen, borders have invisible vertical/horizontal tileline
		-upload initial tiles to vram according to map starting position.
		-if screen size/2 + starting position exceeds map size, starting position is map size - screen size/2
		-if screen size/2 - starting position is lower than 0, starting position isscreen size/2
		-base tile adress for screen fetch = starting position for x and y - screen size/2 (upper left tile is first)
		
		

level format:
byte	function
0	size in tiles, x
1	size in tiles, y
2	background color,r
3	background color,g
4	background color,b
5	relative pointer(16bit) to palette
7	relative pointer(16bit) to collision map
9	relative pointer(16bit) to image
11	relative pointer(24bit) to EOF
14	relative pointer to Map exits
16	relative pointer to map objects


*/


/*
in: x,16bit=level number
starting coordinates in tiles must be written to
MapStartPosX	db		
MapStartPosY	db

varibles needed:
MapStartPosX	db		;map start position set by external routine
MapStartPosY	db
MapSizeX	db		;/must not be seperated cause they may be written to both at the same time in word-mode
MapSizeY	db		;\
BGMapStartPosX	db		;start position for bg upload(may differ from sprite location if near a border)
BGMapStartPosY	db
CurrentMapNumber	db	;number of currently loaded map
CurrentMapPointer	ds 3	;24bit pointer to current map file


values needed:
.define TileBufferSizeX	28
.define TileBufferSizeY	26

LUTS needed:
LevelLUT	(24bit pointer)
*/
LevelLoader:
	php
	rep #$31
	phx
	stz.w MapSizeX
	stz.w BGMapStartPosX
	stz.w NMIOamUploadFlag
	stz.w NMIBg1UploadFlag
	stz.w CurrentMapPointer+1
	stz.w CurrentColMapPointer
	stz.w CurrentColMapPointer+1
	stz.w BgScrollCounterX
	stz.w BgMapCurrentPositionX
	stz.w ScreenPixelPositionX
	stz.w ScreenPixelPositionY
	stz.w BgScrollRowUploadDisplace
	stz.w BgScrollTilemapRowUploadDisplaceX
	stz.w BgScrollOffsetPointerTilesX
	stz.w BgScrollOffsetPointerTilemapX
	stz.w BgScrollTileSourcePointer
	stz.w BgScrollTileSourcePointer+1

	

;***************************************
;get pointer to level
;	txa
	rep #$31
	pla
	and.w #$7fff			;clear msb
	sta.b CurrentMapNumber
	sta.b TempBuffer
	asl a
	adc.b TempBuffer
	tax
	lda.l (LevelLUT+BaseAdress),x		;get pointer to level
	sta.b CurrentMapPointer
	
	inx
	lda.l (LevelLUT+BaseAdress),x
	sta.b CurrentMapPointer+1
	ldy.w #$0000			;get map size x,y
	lda.b [CurrentMapPointer],y	
	sta.w MapSizeX

	ldy.w #$7			;load pointer to collision map
	lda.b [CurrentMapPointer],y	;load relative pointer
	clc
	adc.b CurrentMapPointer		;add map offset to get real pointer
	sta.b CurrentColMapPointer
	sep #$20
	lda.b CurrentMapPointer+2	;store bank
	sta.b CurrentColMapPointer+2


	lda.b #$01				;load bgmode config #1
	jsr SetBGMode

;	stz.b IrqRoutineNumber		;disable dma fifo uploads while uploading the level cause otherwise, the irq potentially cuts in the middle of the dma loop
	rep #$31
	jsr InitDmaFifo
	jsr InitOam
	jsr ResetScrollOffsets
	
	jsr ClearColObjList
	jsr ClearZBuffer
	lda #$1f0
	sta.b BG1HOfLo
	stz.b FocusScreenFlags	
;upload exit list:
	phb
	lda.w #$7e7e
	pha
	plb
	plb
	ldx.w #ExitFileSize*16
	clc
ClearExitBufferLoop:
	dex
	dex
	stz.w ExitTargetMap,x
;	cpx.w #$0000
	bne ClearExitBufferLoop



	ldy.w #14
	ldx.w #0
	lda.b [CurrentMapPointer],y	;get relative pointer to exit list
	tay

LevelLoaderExitListLoop:
	lda.b [CurrentMapPointer],y	;get relative pointer to exit list	

	bpl LevelLoaderExitListFinished	;if "present" flag of exit isnt set, its the end of the list
	sta.w ExitTargetMap,x
	iny
	iny
	lda.b [CurrentMapPointer],y	;get relative pointer to exit list	
	sta.w ExitXPosition,x
	iny
	iny
	lda.b [CurrentMapPointer],y	;get relative pointer to exit list	
	sta.w ExitXTargetPosition,x
	iny
	iny
	lda.b [CurrentMapPointer],y	;get relative pointer to exit list	
	sta.w ExitTargetMap+6,x		;void entries
	iny
	iny
	txa
	clc
	adc.w #ExitFileSize		;add one entry to target counter
	tax
	cpx.w #ExitFileSize*16		;exit if overflow due to corrupt list occured
	bcc LevelLoaderExitListLoop


LevelLoaderExitListFinished:
;	rep #$31

;upload all map objects such as foreground sprites, npcs etc.
;this must be done after bgmode initialization, otherwise the sprite size among other things wont be set yet.
	ldy.w #16
	ldx.w #0
	lda.b [CurrentMapPointer],y	;get relative pointer to obj list
	tay

LevelLoaderObjListLoop:
	lda.b [CurrentMapPointer],y	;get first two bytes in object entry

	bpl LevelLoaderObjListFinished	;if "present" flag of exit isnt set, its the end of the list

	pha
	iny
	iny
	lda.b [CurrentMapPointer],y	;get xy position
	tax
	pla
	and.w #$7fff
	phy
	jsr CreateObjectPosition
	ply
	iny
	iny
	bra LevelLoaderObjListLoop

LevelLoaderObjListFinished:

;***************************************
;upload levelmap palette
	plb
	ldy.w #$0005
	lda.b [CurrentMapPointer],y	;get relative pointer to palette
	sta.b TempBuffer
	clc
	adc.b CurrentMapPointer
	sta.b ThreeBytePointerLo2
	iny
	iny
	lda.b [CurrentMapPointer],y	;get relative pointer to collision map(in order to calculate tilemap length)
	sec
	sbc.b TempBuffer
	tax					;get length, store in x
	ldy.w #$0000				;clear target/source counter						

	sep #$20
	lda.b #PaletteBuffer >> 16		;store target adress(palette buffer) in ram port.
	and.b #$01				;only 1 or 0 valid for banks $7e or $7f
	sta.l $2183
	rep #$31
	lda.w #PaletteBuffer & $ffff
	sta.l $2181				;store target adress in ram port(16bpp palette entry in palette buffer $0)
	lda.b CurrentMapPointer+1		;get source bank of palette
	sta.b ThreeBytePointerHi2		;

	sep #$20
LevelLoaderUploadPaletteLoop:
	lda.b [ThreeBytePointerLo2],y		;load byte from ThreeBytePointer
	sta.l $2180
	iny
	dex					;byte-dec length counter
	bne LevelLoaderUploadPaletteLoop	;done if length counter = 0
	
	inc.b NMIPaletteUploadFlag

;***********************************************	
;upload blank tile
	rep #$31
	lda.b VramBg1Tiles
	adc.w #729*64/2					;tile number * tile size / vram word aligned

	tay
	lda.w #2
	jsr GeneralVramUploader



;***********************************************	
;clear bg1 tilemap

	lda.w #4		;clear word: $0000
	ldy.w #$800
	ldx.w #Bg1MapBuffer&$ffff
	jsr ClearWRAM

;***********************************************
;setup initial bg1 tilemap
	rep #$31		
	lda.w #0			;start at tile number 0
	sta.b TempBuffer		;vertical line counter
	tax				;target buffer pointer
	tay				;horizontal line counter
LoadLevelSetupBg1TilemapLoop:
	sta.l Bg1MapBuffer,x
	inx				;increment pointer in target
	inx
	inc a				;increment tile number
	iny
	cpy.w #TileBufferSizeX		;check if one line of tiles was drawn
	bne LoadLevelSetupBg1TilemapLoop
	
	pha				;if horizontal line complete,
	ldy.w #0			;reset hor linecounter
	txa
	clc
	adc.w #(32-(TileBufferSizeX & $00ff))*2	;add the remaining number of tilemap entries to complete the line
	tax
	sep #$20
	lda.b TempBuffer		;check if done with all vertical lines
	inc a
	sta.b TempBuffer
	cmp.b #TileBufferSizeY
	rep #$30
	beq LoadLevelSetupBg1TilemapDone
	
	pla
	bra LoadLevelSetupBg1TilemapLoop

LoadLevelSetupBg1TilemapDone:
	pla

;	jsr UploadBg1TilemapFifo
;determine starting offset on map(uppermost and leftmost tile on visible screen
;		-if screen size/2 + starting position exceeds map size, starting position is map size - screen size/2
;		-if screen size/2 - starting position is lower than 0, starting position isscreen size/2
;MapSizeX
;MapStartPosX	db		;map start position set by external routine
;BGMapStartPosX	db		;start position for bg upload(may differ from sprite location if near a border)

CheckBgStartPosX:
	sep #$20
	inc.b NMIBg1UploadFlag
	clc
	lda.b #TileBufferSizeX
	dec a
	sta.b BgScrollOffsetPointerTilesX	;needed for scrolling routine
	sta.b BgScrollOffsetPointerTilemapX

	lda.b #TileBufferSizeY
	dec a
	sta.b BgScrollOffsetPointerTilesY	;needed for scrolling routine
	sta.b BgScrollOffsetPointerTilemapY



	lda.b #TileBufferSizeX
	lsr a
	sta.b TempBuffer	;new tilemap size x/2
	clc
	adc.w MapStartPosX	;check if starting point is too far on the right
	cmp.w MapSizeX
	bcc CheckBgStartPosXNotTooBig

	lda.w MapSizeX		;calculate new x-startpos
	sec
	sbc.b TempBuffer	;substract half of the screen
	bra CheckBgStartPosY	;skip checking if x is too small

CheckBgStartPosXNotTooBig:
	clc
	lda.w MapStartPosX
	cmp.b TempBuffer	;check if mapstartpos is smaller than tilemap size x/2
	bcs CheckBgStartPosXNotTooSmall
	
	lda.b TempBuffer		;start map at half screen

CheckBgStartPosXNotTooSmall:
CheckBgStartPosY:

	sec
	sbc.b TempBuffer	;substract half of the screen
	sta.w BGMapStartPosX	;store x-startpos for map
	sta.b BgMapCurrentPositionX
	clc
	asl a			;multiply by 8 to get pixel position of screen
	asl a
	asl a
	sta.b ScreenPixelPositionX

	clc
	sep #$20
	lda.b #TileBufferSizeY
	lsr a
	sta.b TempBuffer	;new tilemap size y/2
	clc
	adc.w MapStartPosY	;check if starting point is too far on the right
	cmp.w MapSizeY
	bcc CheckBgStartPosYNotTooBig

	lda.w MapSizeY		;calculate new y-startpos
	sec
	sbc.b TempBuffer	;substract half of the screen
	bra CheckBgStartPosYDone	;skip checking if y is too small

CheckBgStartPosYNotTooBig:
	clc
	lda.w MapStartPosY
	cmp.b TempBuffer	;check if mapstartpos is smaller than tilemap size y/2
	bcs CheckBgStartPosYNotTooSmall
	
	lda.b TempBuffer		;start map at half screen

CheckBgStartPosYNotTooSmall:
CheckBgStartPosYDone:
	sec
	sbc.b TempBuffer	;substract half of the screen
	sta.w BGMapStartPosY	;store y-startpos for map
	sta.b BgMapCurrentPositionY
	clc
	asl a
	asl a
	asl a
	sta.b ScreenPixelPositionY	;multiply by 8 to get pixel position of screen
	
;****************************************************	
;upload tiles:	
	lda.b CurrentMapPointer+2
	sta.b ThreeBytePointerBank2
	rep #$21
	sep #$10
	lda.w MapSizeX
	and.w #$00ff
	sta.b TempBuffer
	
	ldx.b #$0
	lda.w #0
;	and.w #$00ff			;and multiply by y start position
;	clc
LoadLevelCalcTotalStartPositionLoop:
	cpx.w BGMapStartPosY
	beq LoadLevelCalcTotalStartPositionDone
	clc
	adc.b TempBuffer
	inx
	bra LoadLevelCalcTotalStartPositionLoop

LoadLevelCalcTotalStartPositionDone:


	pha
	lda.w BGMapStartPosX
	and.w #$00ff
	sta.b TempBuffer
	pla
	clc
	adc.b TempBuffer	

	jsr LoadLevelCalculateFilePosition



	rep #$31
	ldy.w #0			;y-tileline counter
	lda.w VramBg1Tiles
	sta.b TempBuffer+4
	
	lda.w #TileBufferSizeX		;multiply tilenumber by 64 to get line length
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	sta.b TempBuffer	

	lda.w MapSizeX
	and.w #$00ff
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	sta.b TempBuffer+6					;total length of one line
	sei

LoadLevelDmaStartTilesLoop:
	ldx.b DmaFifoPointer
	lda.b ThreeBytePointerLo2
	sta.l DmaFifoEntrySrcLo,x			;Store the data offset into DMA source offset
	lda.b ThreeBytePointerHi2	;store high byte and bank
	sta.l DmaFifoEntrySrcHi,x
	
	lda.b TempBuffer
	sta.l DmaFifoEntryCount,x 		  	;Store the size of the data block
	lda.b TempBuffer+4
	sta.l DmaFifoEntryTarget,x			;vram destination adress (bg1 tilespace)
	sep #$20
	lda.b #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x
	rep #$31
	txa						;update fifo entry pointer
	clc
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer

;check if current transfer overflowed. if it did, cut last transfer and initiate an additional one for the other half in the next bank
	lda.b ThreeBytePointerLo2
	clc
	adc.b TempBuffer
	bcc LoadLevelDmaTilesNoWrap2

	
	pha																;save transfer length of add
	lda.b ThreeBytePointerLo2
	eor.w #$ffff
	inc a
	sta.l DmaFifoEntryCount,x 		  	;Adjust size of last transfer

;additional transfer
	lsr a															;new transfer vram addr
	clc
	adc.b TempBuffer+4
	ldx.b DmaFifoPointer
	sta.l DmaFifoEntryTarget,x			;vram destination adress (bg1 tilespace)
	pla

	sta.l DmaFifoEntryCount,x 		  	;Store the size of the data block
	lda.w #0
	sta.l DmaFifoEntrySrcLo,x			;Store the data offset into DMA source offset
	lda.b ThreeBytePointerHi2	;store high byte and bank
	and.w #$ff00
	clc
	adc.w #$100								;add one bank
	sta.l DmaFifoEntrySrcHi,x
	
	

	sep #$20
	lda.b #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x
	rep #$31
	txa						;update fifo entry pointer
	clc
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer

LoadLevelDmaTilesNoWrap2:



;increase source pointer and check if next transfer will start on another bank
	lda.b ThreeBytePointerLo2
	clc
	adc.b TempBuffer+6
	bcc LoadLevelDmaTilesNoWrap1
	
	inc.b ThreeBytePointerBank2			

LoadLevelDmaTilesNoWrap1:
	sta.b ThreeBytePointerLo2				;store new source pointer
	
	lda.b TempBuffer								;store new target pointer
	lsr a
	clc
	adc.b TempBuffer+4
	sta.b TempBuffer+4

	
	iny				;check if all lines processed
	cpy.w #TileBufferSizeY
	bne LoadLevelDmaStartTilesLoopStep



/*
	rep #$31
	

	ldy.w #0			;y-tileline counter
;	ldx.w VramBg1Tiles		;vram target
	lda.w VramBg1Tiles
	sta.b TempBuffer+4
	
	lda.w #TileBufferSizeX		;multiply tilenumber by 64 to get line length
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	sta.b TempBuffer	
	sei

LoadLevelDmaStartTilesLoop:
	ldx.b DmaFifoPointer

	lda.b ThreeBytePointerLo2
	sta.l DmaFifoEntrySrcLo,x			;Store the data offset into DMA source offset
	lda.b ThreeBytePointerHi2	;store high byte and bank
	sta.l DmaFifoEntrySrcHi,x
	
	lda.b TempBuffer
	sta.l DmaFifoEntryCount,x 		  	;Store the size of the data block
	lda.b TempBuffer+4
	sta.l DmaFifoEntryTarget,x			;vram destination adress (bg1 tilespace)
	sep #$20
	lda.b #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x
	rep #$31
	txa						;update fifo entry pointer
	clc
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer



	lda.w MapSizeX
	and.w #$00ff
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	clc
	adc.b ThreeBytePointerLo2

	bcc LoadLevelDmaStartTilesNoWrap
jajapeter:
;calculate overhang transfer length:
;xor last transfer source adress (ThreeBytePointerLo2) to get the number of bytes already transfered.
;substract this number from total transfer length (TempBuffer) to get the number of bytes left to transfer
;
;in order to get vram target adress, get number of bytes already transfered, divide by 2(vram adress) and add to x
	pha
	lda.b ThreeBytePointerLo2
	eor.w #$ffff			;get number of bytes already transfered
	sta.l DmaFifoEntryCount,x 		  	;update length of last transfer
	sta.b TempBuffer+2
	lda.b TempBuffer		;substract from total transfer length to get length of remaining transfer in new bank
	sec
	sbc.b TempBuffer+2		;if the result is negative, there occured a wrap when adding a whole map-tileline, but not when adding a screen-tileline
	bcs LoadLevelDmaStartTilesNoWholeTilelinewrap

	inc.b ThreeBytePointerBank2
	bra LoadLevelDmaStartTilesNoWrap2 ;skip the additional dma transfer if theres no screen-tileline wrap

LoadLevelDmaStartTilesNoWholeTilelinewrap:	
	ldx.b DmaFifoPointer
;	sta.w $4305 		  	;Store the size of the data block
	sta.l DmaFifoEntryCount,x		;length 4305

	lda.b TempBuffer+2
	lsr a				;divide number of already transfered bytes by two
	sta.b TempBuffer+2
;	txa
	lda.b TempBuffer+4
	clc
	adc.b TempBuffer+2		;add to current vram adress to get new vram target adress
	inc a
	sta.l DmaFifoEntryTarget,x		;vram target 2116
	
	lda #0
	sta.l DmaFifoEntrySrcLo,x		;source 4302
	sep #$20

	lda.b ThreeBytePointerBank2	;start transferring at the beginning of the new bank
	inc a
	sta.b ThreeBytePointerBank2
	sta.l DmaFifoEntrySrcBank,x		;source 4304
;	lda #$01    			;Initiate the DMA transfer
;	sta $420B
	lda.b #1					;transfer type normal dma
	sta.l DmaFifoEntryType,x
	
	rep #$31
	txa						;update fifo entry pointer
	clc
	adc.w #DmaFifoEntryLength
	sta.b DmaFifoPointer


LoadLevelDmaStartTilesNoWrap2:
	pla
LoadLevelDmaStartTilesNoWrap:
	sta.b ThreeBytePointerLo2
	
	lda.b TempBuffer		;increase target pointer by one line/2 (vram word adress)
	pha
	lsr a
	sta.b TempBuffer
;	txa
	lda.b TempBuffer+4
	clc
	adc.b TempBuffer
;	tax
	sta.b TempBuffer+4
	pla
	sta.b TempBuffer
	
	iny				;check if all lines processed
	cpy.w #TileBufferSizeY
	bne LoadLevelDmaStartTilesLoopStep
*/
LoadLevelFinishedExit:
	cli
	sep #$20
	lda.b #$7f
;	sta.b ScreenBrightness
;	lda.b #1
;	sta.b IrqRoutineNumber

	plp
	rts
LoadLevelDmaStartTilesLoopStep:
	jmp LoadLevelDmaStartTilesLoop
	
;in: a,16bit:			number of tile in mapfile
;out ThreeBytePointerLo2:	24bit adress of tile in mapfile
;note: CurrentMapPointer must have been set up previously
LoadLevelCalculateFilePosition:	
	php
	rep #$31
	pha
	sep #$20
	lda.b CurrentMapPointer+2
	sta.b ThreeBytePointerBank2

	rep #$31
	pla
	ldx.w #6		;asl 6 times, multiply by 64
	clc
LoadLevelUploadTilesLoop:
;	clc
;	clv
	rol a
	

	dex
	bne LoadLevelUploadTilesLoop

	pha				;calculate bank number
	rol a				;put carry into bit0
	sep #$20
	and.b #%1111111			;this is the number of banks that were added
	clc
	adc.b ThreeBytePointerBank2
	sta.b ThreeBytePointerBank2
	rep #$31
	pla
	
	and.w #%1111111111000000	;get the 16bit value multiplied by 64
			
	sta.b ThreeBytePointerLo2
	ldy.w #9			;get image base adress relative pointer
	lda.b [CurrentMapPointer],y
	clc
	adc.b CurrentMapPointer	;add map file pointer to get real adress
/*
	bcc LoadLevelUploadTilesNoWrap3

	inc.b ThreeBytePointerBank2	;careful, 16bit increase on 8bit variable!
LoadLevelUploadTilesNoWrap3:
*/
	clc
	adc.b ThreeBytePointerLo2	;add tile x,y offset
	bcc LoadLevelUploadTilesNoWrap2

	inc.b ThreeBytePointerBank2	;careful, 16bit increase on 8bit variable!
LoadLevelUploadTilesNoWrap2:
	sta.b ThreeBytePointerLo2	;store total offset in map file to get tiles from
	plp
	rts	


	
	
	
