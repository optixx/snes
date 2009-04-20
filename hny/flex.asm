	;heap	O=128k			;max 128k object buffer                
	;size	4			;4 32kblocks                          
                                                                                  
	;SMC+				;yes, we want a smc header            
	;lrom				;yes, please split in 32k hunks       

.include "header.inc"           

VBlank:
    RTI; Definition, die laut "Header.inc" gebraucht  ; wird
    .bank 0
.section "MainCode" ; Der Code des Programms befindet sich in der  ; Speicherbank 0 des ROM


;==========================================================================
;      Code (c) 1993-94 -Pan-/ANTHROX   All code can be used at will!
;==========================================================================                     


Start:  
	phk			; Put current bank on stack
	plb			; make it current programming bank
				; if this program were used as an intro
				; and it was located at bank $20 then an
				; LDA $8000 would actually read from
				; $008000 if it were not changed!
				; JSRs and JMPs work fine, but LDAs do not! 
	clc			; Clear Carry flag
	xce			; Native 16 bit mode  (no 6502 Emulation!) 
;==========================================================================
	jsr	Snes_Init	; Cool Init routine! use it in your own code!!

	rep     #$10		; X,Y fixed -> 16 bit mode
	sep     #$20		; Accumulator ->  8 bit mode
	Lda	#$00		; mode 0, 8/8 dot
	Sta	$2105	

	Lda	#$75		; BG0 Tile Address $7400 (2 screens in use)
				; when bit 1 is on it means to use 2
				; horizontal screens
				; you can see the other screen if you use
				; $210d to scroll the screen
				; this is used because when scrolling the
				; screen the LEFT MOST character on the screen
				; shows up on the right most side of the screen
				; WE DON'T WANT TO SEE THAT CHARACTER!
	Sta	$2107
	lda	#$00
	Sta	$210b		; BG0 Graphics data $0000
	Lda	#$01		; BG0 Plane Enabled
	Sta	$212c
	stz	$1000		; start the flex tile at 0
	stz	$1001		; storage for flex tile data
	jsr	Copy_Gfx	; Put graf-x in vram
	jsr	Copy_colors	; put colors into color ram
	jsr	Make_tiles	; set up the screen
	jsr	Clear_ram	; clear ram "V-Ram" buffer for flex routine

	ldx	#$0000
	stx	$1002		; # of char data to draw

	ldx	#$0000
	stx	$1004		; # of scroll text chars to flex

	ldx	#$0000
	stx	$1006		; char graf-x offset

	ldx	#$0000
	stx	$1008		; scroll text ram offset

	ldx	#$0000
	stx	$100a		; current sine offset
	
	ldx	#$0000
	stx	$100c		; storage
	
	ldx	#$0000
	stx	$100e		; storage

	ldx	#$0000
	stx	$1010		; horizontal smooth scroll position

	ldx	#$0000
	stx	$1012		; scroll text offset

	lda	#$00
	sta	$10
	lda	#$80		; this puts #$7e8000 into address $10
	sta	$11		; in zero page
	lda	#$7e		; lda [$10] is equal to lda $7e8000
	sta	$12

	lda	#$0f
	sta	$2100		; turn the screen on
Waitloop:
	jsr	WaitVb		; wait for vertical blank
	jsr	Routines	; go do the scroll/flex routines
	bra	Waitloop	; constant loop

;===========================================================================
;                     Start of Vertical Blank Interrupt Routine
;===========================================================================


Routines:
	rep	#$10	; x,y = 16 bit
	sep	#$20	; a = 8 bit

			; start of General DMA graphics copy routine!
	lda	#$00
	sta	$4330		; 0= 1 byte per register (not a word!)
	lda	#$18
	sta	$4331		; 21xx   this is 2118 (VRAM)
	lda	#$00
	sta	$4332
	lda	#$80		; address = $7e8000
	sta	$4333
	lda	#$7e
	sta	$4334		; bank address of data in ram
	ldx	#$0800
	stx	$4335		; # of bytes to be transferred
	lda	#$00
	sta	$2115		; increase V-Ram address after writing to
				; $2118
	ldx	#$0000
	stx	$2116		; address of VRAM to copy garphics in
	lda	#$08		; turn on bit 4 (%1000=8) of G-DMA channel
	sta	$420b
	lda	#$80		; increase V-Ram address after writing to
	sta	$2115		; $2119

	lda	$1010		; read current scroll offset
	sta	$210d		; scroll the screen
	stz	$210d		; clear other bits
	jsr	Scroll		; go to scroll text routine
	jsr	Flex		; go to flex routine
	rts

;============================================================================
;                        Scrolling Text/Screen Routine
;============================================================================

Scroll:
	lda	$1010		; get current horizontal scroll offset
	clc
	adc	#$01		; add one to move it to the left
	sta	$1010		; increase the #$01 to speed up the scroll
	cmp	#$08		; did it move 8 pixels?
	bcs	scrolltexts	; yeah, maybe even more!
	rts
scrolltexts:
	stz	$1010		; reset the position to 0
	ldy	$1012		; get the scroll text offset
	ldx	#$0000
copyscroll:
	lda	TEXT,y		; read the scroll text
	cmp	#$ff		; did it reach the end?
	beq	endscroll	; if so go to endscroll
	sta	$7e7000,x	; store the data into ram
	iny
	inx
	cpx	#$0020		; copy 32 characters into ram
	bne	copyscroll
	ldy	$1012		; get the current scroll text offset
	iny			; increase it by 1 and store it
	sty	$1012
	rts
endscroll:
	ldy	#$0000
	sty	$1012		; scroll text ends, reset the offset to the
	bra	copyscroll	; beginning, go back and re-copy

;============================================================================
;                           Start Of FLEX Routine
;============================================================================

Flex:
	ldy	$100a		; read REAL sine offset
	sty	$100e		; store it to use in creation of all
				; flexing chars
Flex1:
	ldy	$100e		; read the offset
	sty	$100c		; store it to use in creation of a single
				; flexing char
	ldx	$1008		; read current text char offset
	rep	#$30		; A = 16 bit
	lda	$7e7000,x	; read scroll text char
	and	#$003f		; convert ASCII->C64 charset code
				; and mask out high byte
	asl a	;(*2)		; now we want to take the current Char Value
	asl a	;(*4)		; and find it's graphic offset
	asl a	;(*8)		; since the charset is 16 lines high we need
				; to multiply by 16
	asl a	;(*16)		; the easy way to do this is to use 4 ASLs
	sta	$1006		; store it
	tax			; put graphics offset in X register
Flexdraw:
	ldy	$100c		; read sine offset for single flexing char
	rep	#$30
	lda	SINE,y		; read sine data
	and	#$00ff		; leave out hi byte
	tay			; transfer A to Y
	sep	#$20		; A = 8 bits
	lda	$7ea000,x	; read the charset lying at $7ea000
	sta	[$10],y		; store it in current Flex Char Column
				; this works much better than 
				; STA $7e8000,x  since we can't re-write
				; rom to increase to the next column
				; we use zero page addressing
				; which we can modify as much as we want!
	inx			; get next graphic byte
	inc	$100c		; get next sine offset value
	inc	$1002		; 
	lda	$1002		; get # of graphics drawn
	cmp	#$10		; did we do 16 lines?
	bne	Flexdraw	; no! continue finishing the
				; character


	stz	$1002		; all done, now to reset it to zero
	inc	$1004		; go to the next column
	lda	$1004
	cmp	#$20		; did we do 32 columns?
	beq	okgood		; if so then branch to okgood
	rep	#$30		; no, make A = 16
	lda	$10		; read address $10
	clc
	adc	#$0040		; add #$0040 to the address
				; each column is 8 chars high
				; and since each char is 8 lines high
				; we multiply 8*8 to 64
				; #64 = $40...  thats how we get to the next
				; flex column
	sta	$10		; store it back into address $10
	sep	#$20		; A = 8
	lda	$100e
	clc
	adc	#$fe		; $fe is going backwards 2
				; would be the same as SBC #$02
	sta	$100e		; increase sine offset before going to draw
				; the next character
				; the higher the number, the steeper the
				; sine angle will be
	inc	$1008		; increase text ram offset
	bra	Flex1		; go to Flex1
	rts
okgood:
	lda	#$00		;   put #$8000 into $10
	sta	$10		;   $12 will not change since nothing
	lda	#$80		;   affected it. 
	sta	$11		;
	stz	$1008		; reset text offset back to $0
	stz	$1004		; reset column counter back to $0
	inc	$100a		
	inc	$100a		; increase REAL sine offset to get movement
				; 2 incs move the sine faster
	rts


;==========================================================================
;                        Vertical Blank Wait Routine
;==========================================================================
WaitVb:	
	lda	$4210
	bpl     WaitVb	; is the number higher than #$7f? (#$80-$ff)
			; bpl tests bit #7 ($80) if this bit is set it means
			; the byte is negative (BMI, Branch on Minus)
			; BPL (Branch on Plus) if bit #7 is set in $4210
			; it means that it is at the start of V-Blank
			; if not it will keep testing $4210 until bit #7
			; is on (which would make it a negative (BMI)
	rts

;==========================================================================
;       	     SETUP ROUTINES FOR PROGRAM
;==========================================================================

;==========================================================================
;                         Copy graf-x data
;==========================================================================

Copy_Gfx:
	ldx	#$0000		; Vram address $0000
	stx	$2116
	ldx	#$0000
Clearvr:
	stz	$2118		; clear entire Vram
	stz	$2119
	inx
	cpx	#$0000		;
	bne	Clearvr

	ldx	#$0000
	txy
Chardouble:			; we have an 8*8 charset but 8*16 looks better
				; this routine will copy the charset to
				; ram but will copy each byte twice
	lda	Charset,y	; read the charset data
	sta	$7ea000,x	; store a byte into ram
	inx
	sta	$7ea000,x	; store the same byte again right next to it
	inx
	iny
	cpy	#$0200		; read all 64 chars (64*8=512=$200)
	bne	Chardouble
	rts
;==========================================================================
;                      Copy Colors
;==========================================================================
;Copy_colors:
;	stz	$2121		; Select Color Register 1
;	ldx	#$0000
;CopCol:	
;	lda	Colors,X
;	sta	$2122
;	inx
;	cpx	#$0004 		; copy all colors
;	bne	CopCol
;	rts

Copy_colors:
    stz $2121; Adresse 00h im Farb-RAM
    lda #$FD; High Byte des Hintergrundes
    sta $2122
    lda #$FF; Low Byte des Hintergrundes
    sta $2122
    lda #$7C; High Byte der Textfarbe
    sta $2122
    lda #$00; Low Byte der Textfarbe
    sta $2122
                                        rts


;==========================================================================
;                      Make Tiles
;==========================================================================

Make_tiles:
	ldx	#$7400		
	stx	$2116
	ldx	#$0000
clearscreen:
	lda	#$00
	sta	$2118		;
	lda	#$01
	sta	$2119		;   clear the text screen (with unused tile)
	inx			;
	cpx	#$0400		;
	bne	clearscreen	;
	ldx	#$7800
	stx	$2116
	ldx	#$0000
clearscreen2:
	lda	#$00
	sta	$2118		; clear second screen (unseen except for
	lda	#$01		; right most side of monitor)
	sta	$2119
	inx
	cpx	#$0400
	bne	clearscreen2

;============================================================================
;                          Flex Column Tile Draw Routine
;============================================================================


; the flex routine works easily with tiles because of the format tiles
; are stored in.    We read characters left to right, but the CPU
; reads it top to bottom.   the characters sets are stored in sequence
; we see ABCDEFG
; while the computer knows:
; A
; B
; C
; D
; E
; F
; G

; and since each letter is made up 8 bytes then the byte are in sequence
; also!

; this means we can make a column of characters in sequence and re-draw the
; graphics to make them look like they are bouncing (DYCP) or totally bend
; (FLEX) 


	ldx	#$7540		; set the V-ram address to start drawing
				; columns
	stx	$2116
	ldx	#$0000
drawchar:
	lda	$1000		; get first char 
	sta	$1001		; make it the current char
drawflexpattern:
	lda	$1001		;current char
	sta	$2118		; write it into V-Ram
	stz	$2119		; clear pallete #
	lda	$1001
	clc
	adc	#$08		; add #8 to the current char value
				; since our grid will be 32 columns
				; and 8 rows we add #8 to the current
				; char value for the next character
				; store it back
	sta	$1001
	inx
	cpx	#$0020		; did we do 32 columns?
	bne	drawflexpattern
	ldx	#$0000		; set X back to $0
	inc	$1000		; increase Row counter
	lda	$1000
	cmp	#$08		; did we do all 8 rows?
	bne	drawchar	
	rts

; this is the basic idea of how a flex grid looks like:
; this grid is 5 columns * 5 rows
;  
; @EJOT
; AFKPU
; BGLQV
; CHMRW 
; DINSX



;============================================================================
;                                  Clear Ram Bank
;============================================================================

Clear_ram:
	ldx	#$0000
clearram:
	lda	#$00		; clear Flex graphics buffer
	sta	$7e8000,x
	inx
	cpx	#$0800		; clear 2k of ram
	bne	clearram

	ldx	#$0000
clearscrolltext:
	lda	#$20		; clear ram area where we will store
	sta	$7e7000,x	; scroll text data by filling it with
				; spaces
	inx
	cpx	#$0020
	bne	clearscrolltext
	rts
;==========================================================================
;                   SNES Register Initialization routine
;==========================================================================
Snes_Init:
	sep 	#$30    ; X,Y,A are 8 bit numbers
	lda 	#$8F    ; screen off, full brightness
	sta 	$2100   ; brightness + screen enable register 
	stz 	$2101   ; Sprite register (size + address in VRAM)
	stz 	$2102   ; Sprite registers (address of sprite memory [OAM])
	stz 	$2103   ;    ""                       ""
	stz 	$2105   ; Mode 0, = Graphic mode register
	stz 	$2106   ; noplanes, no mosaic, = Mosaic register
	stz 	$2107   ; Plane 0 map VRAM location
	stz 	$2108   ; Plane 1 map VRAM location
	stz 	$2109   ; Plane 2 map VRAM location
	stz 	$210A   ; Plane 3 map VRAM location
	stz 	$210B   ; Plane 0+1 Tile data location
	stz 	$210C   ; Plane 2+3 Tile data location
	stz 	$210D   ; Plane 0 scroll x (first 8 bits)
	stz 	$210D   ; Plane 0 scroll x (last 3 bits) #$0 - #$07ff
	stz 	$210E   ; Plane 0 scroll y (first 8 bits)
	stz 	$210E   ; Plane 0 scroll y (last 3 bits) #$0 - #$07ff
	stz 	$210F   ; Plane 1 scroll x (first 8 bits)
	stz 	$210F   ; Plane 1 scroll x (last 3 bits) #$0 - #$07ff
	stz 	$2110   ; Plane 1 scroll y (first 8 bits)
	stz 	$2110   ; Plane 1 scroll y (last 3 bits) #$0 - #$07ff
	stz 	$2111   ; Plane 2 scroll x (first 8 bits)
	stz 	$2111   ; Plane 2 scroll x (last 3 bits) #$0 - #$07ff
	stz 	$2112   ; Plane 2 scroll y (first 8 bits)
	stz 	$2112   ; Plane 2 scroll y (last 3 bits) #$0 - #$07ff
	stz 	$2113   ; Plane 3 scroll x (first 8 bits)
	stz 	$2113   ; Plane 3 scroll x (last 3 bits) #$0 - #$07ff
	stz 	$2114   ; Plane 3 scroll y (first 8 bits)
	stz 	$2114   ; Plane 3 scroll y (last 3 bits) #$0 - #$07ff
	lda 	#$80    ; increase VRAM address after writing to $2119
	sta 	$2115   ; VRAM address increment register
	stz 	$2116   ; VRAM address low
	stz 	$2117   ; VRAM address high
	stz 	$211A   ; Initial Mode 7 setting register
	stz 	$211B   ; Mode 7 matrix parameter A register (low)
	lda 	#$01
	sta 	$211B   ; Mode 7 matrix parameter A register (high)
	stz 	$211C   ; Mode 7 matrix parameter B register (low)
	stz 	$211C   ; Mode 7 matrix parameter B register (high)
	stz 	$211D   ; Mode 7 matrix parameter C register (low)
	stz 	$211D   ; Mode 7 matrix parameter C register (high)
	stz 	$211E   ; Mode 7 matrix parameter D register (low)
	sta 	$211E   ; Mode 7 matrix parameter D register (high)
	stz 	$211F   ; Mode 7 center position X register (low)
	stz 	$211F   ; Mode 7 center position X register (high)
	stz 	$2120   ; Mode 7 center position Y register (low)
	stz 	$2120   ; Mode 7 center position Y register (high)
	stz 	$2121   ; Color number register ($0-ff)
	stz 	$2123   ; BG1 & BG2 Window mask setting register
	stz 	$2124   ; BG3 & BG4 Window mask setting register
	stz 	$2125   ; OBJ & Color Window mask setting register
	stz 	$2126   ; Window 1 left position register
	stz 	$2127   ; Window 2 left position register
	stz 	$2128   ; Window 3 left position register
	stz 	$2129   ; Window 4 left position register
	stz 	$212A   ; BG1, BG2, BG3, BG4 Window Logic register
	stz 	$212B   ; OBJ, Color Window Logic Register (or,and,xor,xnor)
	sta 	$212C   ; Main Screen designation (planes, sprites enable)
	stz 	$212D   ; Sub Screen designation
	stz 	$212E   ; Window mask for Main Screen
	stz 	$212F   ; Window mask for Sub Screen
	lda 	#$30
	sta 	$2130   ; Color addition & screen addition init setting
	stz 	$2131   ; Add/Sub sub designation for screen, sprite, color
	lda 	#$E0
	sta 	$2132   ; color data for addition/subtraction
	stz 	$2133   ; Screen setting (interlace x,y/enable SFX data)
	stz 	$4200   ; Enable V-blank, interrupt, Joypad register
	lda 	#$FF
	sta 	$4201   ; Programmable I/O port
	stz 	$4202   ; Multiplicand A
	stz 	$4203   ; Multiplier B
	stz 	$4204   ; Multiplier C
	stz 	$4205   ; Multiplicand C
	stz 	$4206   ; Divisor B
	stz 	$4207   ; Horizontal Count Timer
	stz 	$4208   ; Horizontal Count Timer MSB (most significant bit)
	stz 	$4209   ; Vertical Count Timer
	stz 	$420A   ; Vertical Count Timer MSB
	stz 	$420B   ; General DMA enable (bits 0-7)
	stz 	$420C   ; Horizontal DMA (HDMA) enable (bits 0-7)
	stz 	$420D	; Access cycle designation (slow/fast rom)
	rts
                             
SINE:


 .db  32,32,33,34,35,35,36,37,38,38,39,40,41,41,42,43,44,44,45,46
 .db  46,47,48,48,49,50,50,51,51,52,53,53,54,54,55,55,56,56,57,57
 .db  58,58,59,59,59,60,60,60,61,61,61,61,62,62,62,62,62,63,63,63
 .db  63,63,63,63,63,63,63,63,63,63,63,63,62,62,62,62,62,61,61,61
 .db  61,60,60,60,59,59,59,58,58,57,57,56,56,55,55,54,54,53,53,52
 .db  51,51,50,50,49,48,48,47,46,46,45,44,44,43,42,41,41,40,39,38
 .db  38,37,36,35,35,34,33,32,32,31,30,29,28,28,27,26,25,25,24,23
 .db  22,22,21,20,19,19,18,17,17,16,15,15,14,13,13,12,12,11,10,10
 .db  9,9,8,8,7,7,6,6,5,5,4,4,4,3,3,3,2,2,2,2,1,1,1,1,1,0,0,0,0,0
 .db  0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,2,2,2,2,3,3,3,4,4,4,5,5,6,6,7
 .db  7,8,8,9,9,10,10,11,12,12,13,13,14,15,15,16,17,17,18,19,19,20
 .db  21,22,22,23,24,25,25,26,27,28,28,29,30,31



Colors:
	;character set font colors
	.db	$00,$00	; black background
	.db	$52,$5a	; light gray scroll

Charset:
;============================================================================
;= Cyber Font-Editor V1.4  Rel. by Frantic (c) 1991-1992 Sanity Productions =
;============================================================================
	.db	$0	;we need to clear the bottom and the top lines
			;of each character so we don't get any "leaks" 
			;remove this byte and you'll see what i mean!
	.db	$3c,$42,$99,$a1,$a1,$99,$42,$00	;' '
	.db	$3e,$60,$c6,$fe,$c6,$c6,$66,$00	;'!'
	.db	$fc,$06,$ce,$fc,$c6,$ce,$fc,$00	;'"'
	.db	$3e,$60,$c0,$c0,$c0,$c6,$7c,$00	;'#'
	.db	$fc,$06,$c6,$c6,$cc,$dc,$f0,$00	;'$'
	.db	$fe,$00,$c0,$f8,$c0,$e6,$7c,$00	;'%'
	.db	$fe,$00,$c0,$f8,$c0,$c0,$60,$00	;'&'
	.db	$7c,$e6,$c0,$ce,$c6,$ce,$7c,$00	;'''
	.db	$c6,$06,$c6,$fe,$c6,$c6,$66,$00	;'('
	.db	$fc,$00,$30,$30,$30,$30,$7c,$00	;')'
	.db	$7e,$00,$18,$18,$98,$d8,$70,$00	;'*'
	.db	$c6,$0c,$d8,$f0,$d8,$cc,$46,$00	;'+'
	.db	$c0,$00,$c0,$c0,$c0,$d8,$f6,$00	;','
	.db	$26,$70,$fe,$d6,$d6,$c6,$66,$00	;'-'
	.db	$66,$e0,$f6,$fe,$ce,$c6,$66,$00	;'.'
	.db	$7c,$e6,$c6,$c6,$c6,$ce,$7c,$00	;'/'
	.db	$fc,$06,$c6,$fc,$c0,$c0,$60,$00	;'0'
	.db	$7c,$e6,$c6,$c6,$c6,$ce,$76,$00	;'1'
	.db	$fc,$06,$c6,$fc,$d8,$cc,$66,$00	;'2'
	.db	$7c,$e6,$c0,$7c,$06,$ce,$7c,$00	;'3'
	.db	$fc,$00,$30,$30,$30,$30,$18,$00	;'4'
	.db	$c6,$c0,$c6,$c6,$c6,$6e,$3e,$00	;'5'
	.db	$c6,$c0,$c6,$c6,$66,$36,$1c,$00	;'6'
	.db	$66,$c0,$c6,$d6,$fe,$76,$32,$00	;'7'
	.db	$66,$e0,$7c,$18,$7c,$ee,$66,$00	;'8'
	.db	$c6,$c0,$c6,$6c,$38,$38,$38,$00	;'9'
	.db	$7e,$46,$0c,$18,$30,$66,$7c,$00	;':'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;';'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'<'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'='
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'>'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'?'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'@'
	.db	$18,$18,$18,$18,$18,$00,$0c,$00	;'A'
	.db	$6c,$6c,$36,$00,$00,$00,$00,$00	;'B'
	.db	$00,$6c,$fe,$6c,$6c,$fe,$6c,$00	;'C'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'D'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'E'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'F'
	.db	$0c,$0c,$18,$00,$00,$00,$00,$00	;'G'
	.db	$30,$60,$60,$c0,$60,$60,$30,$00	;'H'
	.db	$18,$0c,$0c,$06,$0c,$0c,$18,$00	;'I'
	.db	$10,$54,$38,$fe,$38,$54,$10,$00	;'J'
	.db	$00,$10,$10,$7c,$10,$10,$00,$00	;'K'
	.db	$00,$00,$00,$00,$00,$18,$30,$00	;'L'
	.db	$00,$00,$00,$7c,$00,$00,$00,$00	;'M'
	.db	$00,$00,$00,$00,$00,$30,$30,$00	;'N'
	.db	$00,$06,$0c,$18,$30,$60,$c0,$00	;'O'
	.db	$7c,$e6,$c6,$c6,$c6,$ce,$7c,$00	;'P'
	.db	$70,$c0,$30,$30,$30,$30,$38,$00	;'Q'
	.db	$3c,$60,$06,$1c,$30,$66,$7c,$00	;'R'
	.db	$fc,$00,$06,$3c,$06,$c6,$7c,$00	;'S'
	.db	$1c,$20,$6c,$cc,$fe,$0c,$0e,$00	;'T'
	.db	$fe,$00,$c0,$fc,$06,$ce,$7c,$00	;'U'
	.db	$3c,$66,$c0,$fc,$c6,$ce,$7c,$00	;'V'
	.db	$7e,$00,$06,$06,$0c,$0c,$0c,$00	;'W'
	.db	$7c,$e0,$c6,$7c,$c6,$ce,$7c,$00	;'X'
	.db	$7c,$e0,$c6,$7e,$06,$ce,$7c,$00	;'Y'
	.db	$00,$00,$00,$18,$00,$18,$00,$00	;'Z'
	.db	$00,$00,$00,$18,$00,$18,$30,$00	;'['
	.db	$18,$30,$70,$e0,$70,$30,$18,$00	;'\'
	.db	$00,$00,$3c,$00,$3c,$00,$00,$00	;']'
	.db	$30,$18,$1c,$0e,$1c,$18,$30,$00	;'^'
	.db	$7c,$c6,$66,$0c,$18,$00,$18,$00	;'_'


TEXT:
	.db	"                                "
	.db	"HI THERE! HERE'S A FLEX SCROLLER FOR YOU "
	.db	"TO PLAY WITH!   THIS WASN'T CODED TO RUN "
	.db	"FAST, BUT JUST TO SEE IT IN ACTION. "
	.db	" THE ENTIRE FLEX AND SCROLL ROUTINE TAKE UP "
	.db	"ABOUT 3/4 OF THE RASTER TIME! THAT'S A LOT! "
	.db	"BUT THE CODE COULD ALWAYS BE FIXED TO RUN FASTER.  "
	.db	"THE SIZE OF THIS ENTIRE ROUTINE OUT-CLASSES THE C64 "
	.db	"VERSION!   THE C64 WAS TOO SLOW AND YOU HAD TO "
	.db	"CONTROL EACH COLUMN SEPARATLY...   "
	.db	"WHO CARES!  THIS IS A FAST AND NICE JOB.. "
	.db	" SEE YA LATER!    -PAN-/ANTHROX            "
	.db	"                                ",$ff
.ends
