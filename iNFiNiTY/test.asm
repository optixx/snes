; ***********************************************************
; *** Code written for Tricks Assembler (TRASM) v1.11 by  ***
; *** Norman Yen.                                         ***
; ***********************************************************
; *** This code written by Yoshi of Digital Exodus. If    *** 
; *** any of this code is used, please make sure to give  ***
; *** me thanks or recognition somehow in your product.   ***
; ***********************************************************
; *** This piece of code does quite a few things, ranging ***
; *** from multi-BG scrolling to DMA transfers to using   *** 
; *** the colour +/- registers to make the BGs different. ***
; *** I was trying to figure out how to get that "overlay ***
; *** see-through" look, but failed. If anyone knows, do  ***
; *** contact me. Thanks.                                 ***
; ***********************************************************
	
	org $008000             

	name 'iNFiNiTY - by Yoshi'
	cou 1                   ; USA
	ver 1
	
	int
	res = Main              ; Reset vector is @Main
	nmi = NMI               ; NMI vector is @NMI
	end

; ***********************************************************
; *** Constants                                           ***
; ***********************************************************
Delay    equ 200                ; Wait 200 VBL cycles.
TileLen  equ 5856               ; Length of tile data
MSource1 equ M1                 ; Address of music
MSource2 equ M2                 ; Address of music (2nd part?)

; ***********************************************************
; *** Direct page (DP) variables                          ***
; ***********************************************************
DPLoc    equ $0000              ; Start DP at $00/0000

BG0X     equ $0                 ; Scroll registers...
BG0Y     equ $0+2               ; ...
BG1X     equ $0+4               ; ...
BG1Y     equ $0+8               ; ...
BG2X     equ $0+10              ; ...
BG2Y     equ $0+12              ; ...
JoypadLo equ $0+20              ; Joypad #1
JoypadHi equ $0+21              ; ...
FadeBase equ $0+22              ; Starting fade value
Fade     equ $0+23              ; Ending fade value
ADown    equ $0+24              ; 1 = A button being "held down"

; ***********************************************************
; *** Startup code                                        ***
; ***********************************************************

Main    sei
	phk
	plb
	clc
	xce
	
	rep #$30
	lda.w #DPLoc              ; Direct page shall rule the world.
	tcd
	
	stz BG0X
	stz BG0Y
	stz BG1X
	stz BG1Y
	stz BG2X
	stz BG2Y
	stz ADown
	
	jsr init_snes                   ; "Initialize" the SNES
	jsr Music                       ; Play music (grin)
	
	rep #$10
	lda #%00000001
	sta $2105                       ; MODE 1
	
	lda #$00                        ; BG1 = VRAM $0000 (32x32)
	sta $2107
	
	lda #$00                        ; BG2 = VRAM $0000 (32x32)
	sta $2108
	
	lda #$11                        ; BG1 & BG2 = $1000
	sta $210b

	lda #%00000011                  ; BG2 & BG1 = main screens
	sta $212c                       ; ...
	
	lda #%00000001                  ; BG1 = sub-screen
	sta $212d

	lda #%00000000
	sta $2130
	
	lda #%00000001                  ; Affect BG1
	sta $2131
	
	lda #%10000011                  ; Colour parms (BGR, 00, value)
	sta $2132

	stz $2133                       ; Screen setting register

	lda #%00000001                  ; 3.58Mhz access cycle
	sta $420d
	
	ldx.w #$0000
	stx $2116
	ldx.w #$1801
	stx $4300
	ldx.w #MapData&$FFFF
	stx $4302
	lda #{MapData<<8}&$FF
	sta $4304
	ldx.w #2048     
	stx $4305
	lda #$01        
	sta $420B

	ldx.w #$1000      
	stx $2116
	ldx.w #$1801      
	stx $4300
	ldx.w #TileData&$FFFF
	stx $4302
	lda #{TileData<<8}&$FF
	sta $4304
	ldx.w #TileLen                  
	stx $4305       
	lda #$01        
	sta $420B
	
	stz $2121                       ; Start @ colour 0.

	ldx.w #$2200    
	stx $4300   
	ldx.w #colData&$FFFF 
	stx $4302
	lda #{colData<<8}&$FF 
	sta $4304
	ldx.w #32
	stx.w $4305
	lda #$01        
	sta $420B
	
	lda #$0A                        ; Fade up from 0 to $A.
	sta Fade                        ; ...
	stz FadeBase                    ; ...
	jsr FadeIn                      ; ...

	ldx.w #200                      ; Wait awhile (or something).
-       jsr WaitVBL                     ; This actually waits for the
	dex                             ; VBL to pass by {X-index} times.
	bpl -                           ; ...

	lda Fade                        ; Switch Fade & FadeBase, then
	sta FadeBase                    ; fade up from $A to $F. Wow.
	lda #$0F                        ; ...
	sta Fade                        ; ...
	jsr FadeIn                      ; ...
	
	lda Fade                        ; Switch Fade & FadeBase again,
	sta FadeBase                    ; then fade out. Cool effect.
	stz Fade                        ; ...
	jsr FadeOut                     ; ...
	
	ldx.w #200
-       jsr WaitVBL                     
	dex                             
	bpl -                        

	lda #$0A                        ; Fade up from 0 to $A.
	sta Fade                        ; ...
	stz FadeBase                    ; ...
	jsr FadeIn                      ; ...

	lda #$81                        ; Enable auto joypad/NMI
	sta $4200                       ; access.

; ***********************************************************
; *** The following loop is what's done "realtime" - this ***        
; *** means all of this is calculated over and over NOT   ***
; *** inside the NMI or any other interrupt.              ***
; ***********************************************************
				      
	cli                             ; Start interrupts.
MainLoop wai
	lda JoypadHi
	bit #$08
	beq NotUp
	
	pha
	lda #1
	cmp ADown
	bne Just1a
	inc BG1Y
Just1a  inc BG1Y
	pla

NotUp   bit #$04
	beq NotDown

	pha
	lda #1
	cmp ADown
	bne Just1b
	dec BG1Y
Just1b  dec BG1Y
	pla

NotDown bit #$02
	beq NotLeft

	pha
	lda #1
	cmp ADown
	bne Just1c
	inc BG1X
Just1c  inc BG1X
	pla

NotLeft bit #$01
	beq NotRight

	pha
	lda #1
	cmp ADown
	bne Just1d
	dec BG1X
Just1d  dec BG1X
	pla

NotRight bra MainLoop
	
; ***********************************************************
; *** Miscellaneous routines                              ***
; ***********************************************************
FadeIn  pha
	lda FadeBase
-       inc
	sta $2100
	jsr WaitVBL
	jsr WaitVBL
	cmp Fade
	bne -
	pla
	rts

FadeOut pha
	lda FadeBase
-       dec
	sta $2100
	jsr WaitVBL
	jsr WaitVBL
	cmp Fade
	bpl -
	pla
	rts

WaitVBL pha
-       lda $4210
	bpl -
	lda $4210               ; Reset it
	pla
	rts

; ***********************************************************
; *** The NMI is located here. This is what's done via an ***
; *** interrupt. Don't worry too much about it.           ***
; ***********************************************************
NMI     php
	pha
	phx
	rep #$10                ; INDEX=16
	sep #$20                ; ACC=8
	
	inc BG0X                ; Automatically scroll BG3.
	dec BG0Y

	lda BG0X
	sta $210D
	lda BG0X+1
	sta $210D

	lda BG0Y
	sta $210E
	lda BG0Y+1
	sta $210E

	lda BG1X
	sta $210F
	lda BG1X+1
	sta $210F

	lda BG1Y
	sta $2110
	lda BG1Y+1
	sta $2110

	lda BG2X
	sta $2111
	lda BG2X+1
	sta $2111

	lda BG2Y
	sta $2112
	lda BG2Y+1
	sta $2112

-       lda $4212
	and #$01
	bne -

	ldx.w $4218               
	stx JoypadLo

	stz ADown
	lda JoypadLo
	bit #%10000000
	beq Next2
	lda #1
	sta ADown

Next2   plx
	pla
	plp
	rti

; ***********************************************************
init_snes        
	sep #$20
	lda #$80
	sta $2100               ; Screen off, 0 brightness.
	stz $2101
	stz $2102
	stz $2103
	stz $2104
	stz $2105
	stz $2106
	stz $2107
	stz $2108
	stz $2109
	stz $210a
	stz $210b
	stz $210c
	stz $210d
	stz $210d
	stz $210e
	stz $210e
	stz $210f
	stz $210f
	stz $2110
	stz $2110
	stz $2111
	stz $2111
	stz $2112
	stz $2112
	stz $2113               
	stz $2113               
	stz $2114
	stz $2114
	lda #$80
	sta $2115
	stz $2116
	stz $2117
	stz $211a
	stz $211b
	lda #$01
	sta $211b
	stz $211c
	stz $211c
	stz $211d
	stz $211d
	stz $211e       
	lda #$01
	sta $211e
	stz $211f
	stz $211f
	stz $2120
	stz $2120
	stz $2121
	stz $2123
	stz $2124
	stz $2125
	stz $2126
	stz $2127
	stz $2128
	stz $2129
	stz $212a
	stz $212b
	stz $212c
	stz $212d
	stz $212e
	stz $212f
	stz $4200
	lda #$ff
	sta $4201
	stz $4202
	stz $4203
	stz $4204
	stz $4205
	stz $4206
	stz $4207
	stz $4208
	stz $4209
	stz $420a
	stz $420b
	stz $420c
	stz $420d
	rts

Music   src music

coldata bin pic16.col
mapdata bin pic16.map
tiledata bin pic16.set

M1      bin     music1.bin
M2      bin     music2.bin


