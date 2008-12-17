;============================================================================
; Includes
;============================================================================

;== Include MemoryMap, Vector Table, and HeaderInfo ==
.INCLUDE "header.inc"

;== Include SNES Initialization routines ==
.INCLUDE "init.inc"
.INCLUDE "LoadGraphics.asm"



;============================================================================
; Main Code
;============================================================================

.BANK 0 SLOT 0
.ORG 0
.SECTION "MainCode"

Start:
    InitSNES    ; Clear registers, etc.

    ; Load Palette for our tiles
    LoadPalette BoardPalette, 0, 4

    ; Load Tile data to VRAM
    LoadBlockToVRAM BoardData, $0000, $0010	; 1 tiles, 2bpp, = 16 bytes
   
    ; Setup Video modes and other stuff, then turn on the screen
    jsr SetupVideo
    
    lda #$80
    sta $4200

Infinity:
    ;WAI

    jmp Infinity    ; bwa hahahahaha
    



;============================================================================
VBlank:
    rep #$30        ; A/mem=16 bits, X/Y=16 bits (to push all 16 bits)
    phb
	pha
	phx
	phy
	phd

    sep #$20        ; A/mem=8 bit    
    
    lda $0000
    
    sta $210D
    sta $210D
    sta $210E
    stz $210E
    
    inc $0000

    lda $4210       ; Clear NMI flag
    
    rep #$30        ; A/Mem=16 bits, X/Y=16 bits 
    
    PLD 
	PLY 
	PLX 
	PLA 
	PLB 

    sep #$20
    RTI
;============================================================================

;============================================================================
; SetupVideo -- Sets up the video mode and tile-related registers
;----------------------------------------------------------------------------
; In: None
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
SetupVideo:

    lda #$00
    sta $2105           ; Set Video mode 0, 8x8 tiles, 4 color BG1/BG2/BG3/BG4

    lda #$04            ; Set BG1's Tile Map offset to $0400 (Word address)
    sta $2107           ; And the Tile Map size to 32x32

    stz $210B           ; Set BG1's Character VRAM offset to $0000 (word address)

    lda #$01            ; Enable BG1
    sta $212C

    lda #$0F
    sta $2100           ; Turn on screen, full Brightness

    rts
;============================================================================

.ENDS

;============================================================================
; Character Data
;============================================================================
.BANK 1 SLOT 0
.ORG 0
.SECTION "CharacterData"

    .INCLUDE "board.inc"

.ENDS
