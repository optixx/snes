;------------------------------------------------------------------------
;- Written by: Bazz
;-    This code introduces the programmer to the VBLANK interrupt, and
;-    teaches him/her its powers. This should be pretty simple & easy
;-    to go through.
;------------------------------------------------------------------------

;== Include MemoryMap, HeaderInfo, and interrupt Vector table ==
.INCLUDE "header.inc"

;== Include Library Routines ==
.INCLUDE "init.inc"
.INCLUDE "LoadGraphics.asm"

;== EQUates ==
.EQU PalNum $0000       ; Use some RAM

;==========================================
; Main Code
;==========================================

.MACRO Stall
    .REPT 7
        WAI
    .ENDR
.ENDM

.BANK 0 SLOT 0
.ORG 0
.SECTION "MainCode"

Start:
    InitSNES

    rep #$10
    sep #$20
    
    stz PalNum

    LoadPalette BG_Palette, 0, 14
    LoadBlockToVRAM Tiles, $0000, $0020
    
    lda #$80
    sta $2115
    ldx #$0400
    stx $2116
    lda #$01
    sta $2118

    jsr SetupVideo
    
    lda #$80
    sta $4200       ; Enable NMI

Infinity:
    Stall           ; I use this just to stall the game a little
                    ; I wait 7 VBLANKS instead of just 1. I DONT RECOMMEND THIS
                    ; if you are writing something serious.

    ;lda PalNum
    ;clc
    ;adc #$04
    ;and #$0C        ; If > palette starting color > 24 (00011100), make 0
    ;sta PalNum

_done:
    JMP Infinity

;============================================================================
VBlank:
    rep #$30        ; A/mem=16 bits, X/Y=16 bits (to push all 16 bits)
    phb
	pha
	phx
	phy
	phd

    sep #$20        ; A/mem=8 bit    
    
    stz $2115       ; Setup VRAM
    ldx #$0400
    stx $2116       ; Set VRAM address
    
    lda PalNum
    clc
    adc #$04
    and #$0C        ; If > palette starting color > 24 (00011100), make 0
    sta PalNum


    ;lda PalNum
    sta $2119       ; Write to VRAM

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
    sta $2105           ; Set Video mode 1, 8x8 tiles, 16 color BG1/BG2, 4 color BG3

    lda #$04            ; Set BG1's Tile Map offset to $0400 (Word address)
    sta $2107           ; And the Tile Map size to 32x32

    stz $210B           ; Set BG1's Character VRAM offset to $0000 (word address)

    lda #$01            ; Enable BG1
    sta $212C

    lda #$0F
    sta $2100           ; Turn on screen, full Brightness

    rts

.ENDS
;============================================================================

.BANK 1 SLOT 0
.ORG 0
.SECTION "CharacterData"

Tiles:
    .DW $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .DB $00,$00,$24,$00,$24,$00,$24,$00
    .DB $00,$00,$81,$00,$FF,$00,$00,$00

BG_Palette:
    .DB $00, $00, $FF, $03
    .DW $0000, $0000, $0000
    .DB $1F, $00
    .DW $0000, $0000, $0000
    .DB $E0, $5D
    .DW $0000, $0000, $0000
    .DB $E0, $02

.ENDS
