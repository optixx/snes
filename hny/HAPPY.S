	heap	O=128k			;max 128k object buffer                
	size	4			;4 32kblocks                          
                                                                                  
	SMC+				;yes, we want a smc header            
	lrom				;yes, please split in 32k hunks       


;==========================================================================
;      Code (c) 1993-94 -Pan-/ANTHROX   All code can be used at will!
;                  Music is copyrighted by its respectful owners
;                      and was used without permission
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
	xce			; Native 16 bitmode  (no 6502 Emulation!) 
;==========================================================================
	jsr	Snes_Init	; Cool Init routine! use it in your own code!!
	jsl	>song		; jsl to sound
				; note: this sound is AMAZING! it took
				; 2 seconds to rip and 3 seconds to relocate!
				; all that you must do to relocate is change
				; the long LDA bank address and the one
				; lda #$02 pha plb
				; change it to the bank you need!
				; quite nice!
	rep     #$10		; X,Y fixed -> 16 bit mode
	sep     #$20		; Accumulator ->  8 bit mode
	Lda	#$02		; mode 2, 8/8 dot
	Sta	$2105	

	Lda	#$74		; BG0 Tile Address $7400
	Sta	$2107
	lda	#$70		; BG1 Tile Address $7000
	sta	$2108	
	lda	#$78		; BG2 location, also sine wave location
				; Address $7800
	sta	$2109
	lda	#$30
	Sta	$210b		; BG0 Graphics data $0000
				; BG1 Graphics data $3000
	Lda	#$13		; BG0 + BG1 Plane Enabled; Sprites enabled
	Sta	$212c
	jsr	Copy_Gfx	; Put graf-x in vram
	jsr	Copy_colors	; put colors into color ram
	jsr	Make_tiles	; set up the screen
	jsr	HDMA_setup
	jsr	Sprite_setup
	stz	$1000		;sine timer!
	stz	$1001		;sine offset lo
	stz	$1002		;sine offset hi
	lda	#$fd
	sta	$1003		;sine speed	0-ff
	lda	#$01		;sine angle	0-1f
	sta	$1004
	lda	#$00
	sta	$1005		;sine angle high byte
	ldx	#$7400
	stx	$1006		;Vram address for text
	ldx	#$00
	stx	$1008		;counter for text printer!
	lda	#$00
	sta	$100a		;flag to stop text writer (1=stop)
	stz	$100b		;data storage for $4218
	stz	$100c		;data storage for $4219
	lda	#$03
	sta	$100d		; song # (2-7)
	stz	$100e		; storage junk
	stz	$100f		; storage junk
	stz	$1010		; HDMA wave offset lo
	stz	$1011		; HDMA wave offset high
	stz	$1012
	stz	$1013		; hdma waves offset high	
	lda	#$08
	sta	$1014		; number of HDMA waves		
	lda	#$01
	sta	$1015		; speed of HDMA wave
	lda	#$08
	sta	$1016		; WIDTH between "other bars"
	lda	#$00
	sta	$1017		; counter for # of sprites
	sta	$1018		; sprite horizontal sine offset low
	sta	$1019		; sprite horizontal sine offset high
	sta	$101a		; sprite vertical sine offset low
	sta	$101b		; sprite vertical sine offset high
	sta	$101e		; sprite movement (horizontal)
	sta	$101f		; sprite movement (vertical)
	sta	$1020		; sprite flag for left/right movement
	sta	$1021		; sprite flag for up/down movement
	jsr	WaitVb		; start HDMA in vertical blank
	lda	#$03
	sta	$420c		; enable first two HDMAs
	lda	#$0f
	sta	$2100		; enable screen
	lda	$100d
	sta	$2140		; turn on the MUSIC!!
	lda	#$81
	sta	$4200		; turn on vertical blank IRQ and joypad
Waitloop:
	jsr	WaitVb		; wait for vertical blank
	bra	Waitloop	; constant loop

;===========================================================================
;                     Start of Vertical Blank Interrupt Routine
;===========================================================================


VBI:			;Vertical Blank Interrupt
	pha		;
	phx		;
	phy		;     make sure to store all registers
	phb		;     before you run your IRQ routine
	php		;     and pull them back after you're done
	phk		;     so when it returns it will not have screwed
	plb		;     up anything!
	rep	#$10	; x,y = 16 bit
	sep	#$20	; a = 8 bit
	lda	$4210   ; reset NMI flag
			; Nintendo says its necessary (maybe it's like D012
			; for C64??)
			; start of General DMA sprite copy routine!
	lda	#$00
	sta	$4320		; 0= 1 byte per register (not a word!)
	lda	#$04
	sta	$4321		; 21xx   this is 2104 (sprites)
	lda	#$00		;---------------|
	sta	$4322		;              \/
	lda	#$0c		; address = $0c00
	sta	$4323
	lda	#$7e		; $7e = ram bank
	sta	$4324		; bank address of data in ram
	ldx	#$0080
	stx	$4325		; # of bytes to be transferred
	ldx	#$0000
	stx	$2101		; address of OAM ram to copy to
	lda	#$04		; turn on bit 3 (%100=4) of G-DMA
	sta	$420b

testpad:
	lda	$4212	; read pad status
	and	#$01
	bne	testpad	; pad not ready??
	ldx	$4218	; read joypad and store data
	stx	$100b
Dostuff:
	ldx	#$7820  ; set vram address to store vertical sine data
	stx	$2116
	ldx	$1001	; read from $1001 to get offset
	ldy	#$0000
Sinewaver:
	lda	SINE,x
	sta	$2118	; store sine value in v-ram
	lda	#$40
	sta	$2119	; sine wave to affect second plane only!
			; making this to $60 affects both plane 0 and plane 1!
	rep	#$30
	txa
	clc
	adc	$1004	; create sine angle by adding to the offset
	and	#$00ff	; make sure it doesn't go past 256 bytes in the
			; sine data!
	tax	
	sep	#$20
	iny
	cpy	#$0020	; only #32 needed, only 32 chars per line!
	bne	Sinewaver
	lda	$1001
	clc
	adc	$1003	; add sine speed
	sta	$1001
	lda	$100a	; test text print flag 0=ok to print
	beq	Textok
	jsr	Cleartextscreen	;do backwards clear
Textok:	
	inc	$1000	;timer, otherwise everything would be too fast!
	lda	$1000
	cmp	#$05		; when the timer reaches 5 it will do the
	beq	routines	; joypad and text writer routines
Continue1:
	jsr	Hwave		; this does the red HDMA bar wave
	jsr	Spritemover	; this moves the circular bouncing sprites
	plp	;	pull original registers back!
	plb	;
	ply	;
	plx	;
	pla	;
	rti	;	ReTurn from Interrupt
;===========================================================================
;                        Backwards Text Clear Routine
;===========================================================================

Cleartextscreen:
			; this routine makes the cursor go backwards
			; to clear the screen
	ldx	$1006
	dex		;    get the current cursor position (Vram address)
	stx	$2116	;    put it as the current Vram address
	lda	#$00	;
	sta	$2118	;    put character #0 (cursor) into VRAM
	lda	#$08	;    make the pallete number..
	sta	$2119	;    
	lda	#$20	;    clear the original tile by making it a space
	sta	$2118	;
	lda	#$08	;    make the pallete number
	sta	$2119	;
	ldx	$1006	;
	dex		;    decrease the current cursor position 
	stx	$1006	;    and store it again
	cpx	#$73ff	;    did it reach the top of the screen?
	beq	textwriteon
	rts
textwriteon:
	dec	$100a	; set the textwriter flag on (0 = write text)
	ldx	#$7400	;	fix the Vram address
	stx	$1006
	rts

;=========================================================================


routines:
	stz	$1000		; set the timer flag to 0 again!
	jsr	Joypad		; examine joypad readings
	jsr	Printletter	; prints 1 letter of text
	jmp	Continue1	; jmp back to RTI routine

;==========================================================================
;                      Joypad Control Routine
;==========================================================================

Joypad:
				; quick Joypad info:
				; 4218:
				; 80 = a
				; 40 = x
				; 20 = top left
				; 10 = top right
				; 
				; 4219:
				; 80 = b
				; 40 = y
				; 20 = select
				; 10 = start
				;  8 = up
				;  4 = down
				;  2 = left
				;  1 = right 

	lda	$100b		; read lo-byte of joypad data
	bit	#$10		; was it Top Left?
	bne	decsineang
	bit	#$20		; was it Top Right?
	bne	incsineang
	bit	#$40		; was it X?
	bne	incbarwidth	
	lda	$100c		; read high byte of joypad data
	bit	#$02		; was it Left?
	bne	decsinespeed
	bit	#$01		; was it Right?
	bne	incsinespeed
	bit	#$80		; was it B?
	bne	changesound
	bit	#$40		; was it Y?
	bne	incwavespeed
	rts
decsineang:
	dec	$1004		; decrease sine angle data offset
	lda	$1004
	and	#$1f		; 0 - 1f are the limits
	sta	$1004
	rts
incsineang:
	inc	$1004
	lda	$1004
	and	#$1f		; increase sine angle data offset
	sta	$1004
	rts
incbarwidth:
	inc	$1016
	lda	$1016
	cmp	#$09		; not higher than 8!
	bne	ibwok
	stz	$1016
ibwok:
	rts
decsinespeed:
	dec	$1003		; slow down/reverse
	rts
incsinespeed:
	inc	$1003		; speed up/forward
	rts
changesound:
	inc	$100d
	lda	$100d
	cmp	#$08		; did it go past sound 7?
	beq	oopssound
	sta	$2140
	rts
oopssound:
	lda	#$02		; set it to sound 2 (first sound)
	sta	$100d
	sta	$2140
	rts
incwavespeed:
	inc	$1015
	lda	$1015
	cmp	#$08
	bne	iwsok
	stz	$1015		; put zero into $1015
iwsok:
	rts

;===========================================================================
;                             Text Writer Routine
;===========================================================================


Printletter:

	lda	$100a		; is it ok to print the text?
	beq	PL
	rts
PL:
	ldx	$1006		; get current Vram text address
	stx	$2116
	ldy	$1008		; get current text offset
	lda	TEXT,y
	cmp	#$0a		; was it a carriage return?
	bne	nocr		; no? go to NO Carriage Return
	stx	$2116		; yes!! store the Vram text address in 2116
	lda	#$20		; remove that left over cursor!
	sta	$2118
	lda	#$08		; pallete #
	sta	$2119
	rep	#$30
	lda	$1006
	and	#$ffe0		; make sure to only get start of line addresses
	clc
	adc	#$0020		; add 32 to get to next line
	sta	$1006
	sep	#$20
	ldy	$1008
	iny			; increase text offset to get next char
	sty	$1008
	bra	PL		; go back and get re-do text draw

nocr:
	and	#$3f		; no carriage return!!  turn ASCII->C64
	sta	$2118		; screen code
	lda	#$08		;
	sta	$2119		; pallete #
	lda	#$00
	sta	$2118		; make a cursor
	lda	#$08
	sta	$2119
	ldx	$1006
	inx			; increase Vram address
	stx	$1006
	ldx	$1008
	inx			; increase text offset
	stx	$1008
	ldx	$1008
	lda	TEXT,x		; is the next byte a stop flag?
	beq	Stoptext	; yes! 
	cmp	#$01		; is the byte a reset text offset flag?
	beq	Resettext	; yes!
	rts
Stoptext:
	inc	$100a		; stop text, enable backwards clear
	ldx	$1008
	inx
	stx	$1008		; since the next byte will be a stop flag
				; we must skip it to get the next character
	rts
Resettext:
	inc	$100a		; stop text, enable backwards clear
	ldx	#$0000		; return text offset to start of TEXT
	stx	$1008
	rts
;===========================================================================
;                      Horizontal DMA Color Wave Routine
;===========================================================================


Hwave:				; HDMA red waving bars routine
	stz	$1012		; reset the "other bars" offset
	jsr	Hwsetup		; go to sine offset routine
	ldy	#$0020		; get start of BLACK colors offset
	lda	#$40		; get end of BLACK colors offset
	sta	$100e
	stz	$100f		
	jsr	Copyhwave	; draw colors
Hwaverout:
	jsr	Hwsetup		; go to sine offset routine
	ldy	#$0006		; get start of RED colors
	lda	#$18		; get end of RED colors
	sta	$100e
	jsr	Copyhwave	; draw colors
	dec	$1014		; decrease # of bars to draw
	lda	$1014
	bne	Hwaverout	; did it hit 0?
	lda	#$08
	sta	$1014		; yes, put 8 back in for next time
	lda	$1010
	clc
	adc	$1015		; increase sine data offset
	sta	$1010
	rts

Hwsetup:
	rep	#$30
	lda	$1010		; get sine data offset
	clc
	adc	$1012		; add "other bars" offset so we can see
				; the other bars!

	and	#$00ff		; make sure it doesn't go past 256 bytes
				; in sine data		
	tax
	sep	#$20
	lda	SINE,x		; read sine data and store it
	sta	$100e
	stz	$100f
	rep	#$30
	lda	$100e		; get sine data back
	clc
	adc	#$0040		; add #$40 to get it centered in the screen 
	sta	$100e		; store it
	asl a			; multiply it by 2 by shifting left
	clc
	adc	$100e		; add it with itself to get *3
				; we do this because the HDMA color data
				; is stored as WIDTH, Colorlo, Colorhi
				; if we wanted the second line it would be this
				; 1*2+1=3
				; the first line would be:
				; 0*2+0=0
	inc a			; add 1 to it to skip the WIDTH byte
	clc
	tax
	sep	#$20
	rts

Copyhwave:
	lda	Colorbar,y	; read the color data
	sta	$0600,x		; store it in HDMA color list
	iny
	inx			
	lda	Colorbar,y	; get next color byte 
	sta	$0600,x		; store in HDMA color list
	inx
	inx			; increase X again to skip the WIDTH byte
	iny
	cpy	$100e		; did it copy all the needed colors?
	bne	Copyhwave

	lda	$1012
	clc
	adc	$1016		; add to the "other bars" offset
				; changing this number makes the bars closer
				; together or further apart
	sta	$1012
	sep	#$20
	rts

;===========================================================================
;                              Sprite Circle Maker
;===========================================================================

Spritemover:			; Start of Sprite Sine draw routine
	rep	#$30
	sep	#$20
	ldy	#$0000
Sprtinfo_setup:
	ldx	$1018		; Get offset for first sine (Horizontal)
	lda	SINE,x
	clc
	adc	$101e		; add with horizontal movement (left/right)
	cmp	#$18		; is it past the left border?
	bcs	lookhoriz	; no! it's more or equal to #$18
	lda	#$18		; yes, stay at #$18
	bra	okhoriz
lookhoriz:
	cmp	#$e0		; is it past the right border?
	bcc	okhoriz		; no! it is less than #$e0
	lda	#$e0		; make it #$e0 if its greater than
okhoriz:
	sta	$0c00,y
	iny
	ldx	$101a		; get offset for second sine (Vertical)
	lda	SINE+60,x	; get SINE+60 to create co-sine and make
				; a circle
	clc
	adc	$101f		; add vertical movement (up/down)
	cmp	#$18		; did it go past top border?
	bcs	lookvert	; no! it's greater than/equal to #$18
	lda	#$18		; yes! make it #$18
	bra	okvert
lookvert:
	cmp	#$c0		; did it go past bottom border?
	bcc	okvert		; no! it's less than #$c0
	lda	#$c0		; yes! make it #$c0
okvert:

	sta	$0c00,y
	iny
	lda	#$2a		; get asterisk * for star (the sprite
				; object)
	sta	$0c00,y
	iny
	lda	#$00		; pallete 0, set priority, no h/v flips
	sta	$0c00,y
	iny
	lda	$1018
	clc
	adc	#$08		; space out the stars (by skipping 8)
	sta	$1018
	lda	$101a
	sec
	sbc	#$08		; space out the stars (by skipping 8)
	sta	$101a
	inc	$1017		; ok we did a sprite
	lda	$1017
	cmp	#$20		; did we do 32 sprites?
	bne	Sprtinfo_setup	; no! finish the rest!
	stz	$1017		; ok all done! let's reset it for next
				; time!

				; now to make the sprites move in a direction


	lda	$1020		; do we move left or right? 0=right
	bne	decrease1e	; not right! we jump to the left!
				; ok, it's right
	dec	$1018		; dec 18, inc 1a = move clockwise
	inc	$101a		;
	inc	$101e		; inc 1e = right (2 INCs are twice as fast)
	inc	$101e		; inc 1e = right
	lda	$101e
	cmp	#$98		; is it time to go left?
	bcc	testvertical	; nope! it's less than #$98
	inc	$1020		; ok turn on the move left flag; 1=left
	bra	testvertical	; jump to the vertical test
decrease1e:
	inc	$1018		; when we move left we want the spin to
				; change too! now it's counter-clockwise!
	dec	$101a		;
	dec	$101e		; dec 1e = left
	dec	$101e		; dec 1e = left
	lda	$101e
	cmp	#$01		; is it time to go right?
	bcs	testvertical	; nope.. it's higher than #$01
	dec	$1020		; yes, set the move right flag; 0=right
testvertical:
	lda	$1021		; do we move up or down? 0=down
	bne	decrease1f	; nope! move up!
	inc	$101f		; inc 1f = down
	inc	$101f		; inc 1f = down
	inc	$101f		; inc 1f = down
				; 3 incs to add an oddity, making the bounce
				; go every where on the screen
	lda	$101f
	cmp	#$80		; is it time to go up?
	bcc	endhvtest	; nope! it's less! go end the tests
	inc	$1021		; yes! set the move up flag; 1=up
	bra	endhvtest	; go end the test
decrease1f:
	dec	$101f		; dec 1f = up
	dec	$101f		; dec 1f = up
	lda	$101f
	cmp	#$02		; time to go down yet?
	bcs	endhvtest	; nope! its more than 2!
	dec	$1021		; yes! set move down flag; 0=down
endhvtest:
	rts			; end of this routine!



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
;                         Copy Graf-x Data
;==========================================================================

Copy_Gfx:
	ldx	#$3000		; Select Vram address $3000
	stx	$2116
	ldx	#$0000
Copgfx:	
	lda	>GFX,X		; read graphics data (HAPPY NEW YEAR 1994)
	sta	$2118		; from other bank (LDA $018000,x)
	inx
	lda	>GFX,X
	sta	$2119
	inx
	cpx	#$5800		; 32*22*8*4=22528 = $5800
				; 32 chars a line
				; 22 lines
				; 8 bytes per char per plane
				; 4 planes
	bne	Copgfx		; didn't finish? go back!
	ldx	#$0000		; Vram address $0000
	stx	$2116
	ldx	#$0000
Copystuff:
	lda	>Charset,x	; read charset from other bank
	sta	$2118
	inx
	lda	>Charset,x
	sta	$2119
	inx
	cpx	#$0800		; 32*2*8*4=2048 = $0800
	bne	Copystuff
	rts
;==========================================================================
;                                Copy Colors
;==========================================================================
Copy_colors:
	stz	$2121		; Select Color Register 1
	ldx	#$0000
CopCol:	
	lda	>Colors,X
	sta	$2122
	inx
	cpx	#$0060		; Number of Colors * 2(word)
				; 16+16+16*2=96 = $60 
	bne	CopCol
	lda	#$80		; Color Register 128 (start of sprite colors)
	sta	$2121
	ldx	#$0000
CopCol2:
	lda	>Spritecolors,x
	sta	$2122
	inx
	cpx	#$0020
	bne	CopCol2
	rts
;==========================================================================
;                                Make Tiles
;==========================================================================

Make_tiles:
	Ldx	#$7000		; Select Vram Address $7000
	Stx	$2116
	ldx	#$0000
clearscreen1:			;
	lda	#$00		;
	sta	$2118		;    clear the whole graphics screen
	lda	#$00		;
	sta	$2119		;    by placing a blank tile on the matrix
	inx			;
	cpx	#$0400		;
	bne	clearscreen1	;
	ldx	#$7400		
	stx	$2116
	ldx	#$0000
clearscreen2:
	lda	#$20		; 
	sta	$2118		;
	stz	$2119		;   clear the text screen (fill with spaces)
	inx			;
	cpx	#$0400		;
	bne	clearscreen2	;
	ldx	#$7800	
	stx	$2116
	ldx	#$0000		;
clearscreen3:			;
	stz	$2118		;   make sure that the Horizontal and Vertical
	stz	$2119		;   shifts are cleared (especially the Horiz.)  
	inx			;
	cpx	#$40		;  32*2=60 = $40  (first 32 are the horizontal)
	bne	clearscreen3

	ldx	#$7160
	stx	$2116	
	Rep	#$20		; A = 16 bits
	Lda	#$ffff
MTiles1:	Inc a
	Sta	$2118
	Cmp	#$01e0		; draw graphic tiles up to the 1994
	Bne	MTiles1
MTiles2:
	inc a
	pha
	ora	#$0400		; make sure the 1994 uses the next pallete!
	sta	$2118
	pla
	cmp	#$02a0
	bne	MTiles2

	Sep	#$20		; A = 8 bits
	rts

;==========================================================================
;                                HDMA data setup routine
;==========================================================================
HDMA_setup
	ldx	#$0000
	txy			; transfer x to y, that way Y=X (y=#$0000)
HDMApal:
	lda	#$01		; 1 scan line width 
	sta	$0400,x
	inx
	lda	#$00		; color # 0
	sta	$0400,x
	inx
	iny
	cpy	#$00f0		; number of scan lines to create
	bne	HDMApal
	stz	$0400,x		; end of hdma (0 scan line width=end)
	inx
	stz	$0400,x
	ldx	#$0000
	txy
HDMAcol:
	lda	#$01
	sta	$0600,x		; 1 scan line width
	inx
	lda	#$00		; color for color #0 = black
	sta	$0600,x
	inx
	lda	#$00		; black (high byte)
	sta	$0600,x
	inx
	iny
	cpy	#$00f0		; # of lines to make
	bne	HDMAcol
	stz	$0600,x		; end hdma
	inx
	stz	$0600,x
	inx
	stz	$0600,x

	lda	#$00		; type of byte pattern? 0=1 byte register
	sta	$4300
	lda	#$21		; 21xx   this makes it register 2121 (pallete)
	sta	$4301
	lda	#$00		; low byte of ram address of HDMA data
	sta	$4302
	lda	#$04		; high byte = $0400
	sta	$4303
	lda	#$7e		; bank of data location in ram
	sta	$4304
				; next HDMA
	lda	#$02
	sta	$4310		; 2= 2 bytes per register (not a word!)
	lda	#$22
	sta	$4311		; 21xx   this is 2122 (colors)
	lda	#$00
	sta	$4312
	lda	#$06		; address = $0600
	sta	$4313
	lda	#$7e
	sta	$4314		; bank address of data in ram
	
	rts
;==========================================================================
;                      Sprite (OAM) Initialization Routine
;==========================================================================
Sprite_setup:
	stz	$2101		; must be set before writing to sprite ram!
	stz	$2102		;
	stz	$2103		; sets sprite size and location in VRAM
				; for graf-x (points to location $0000)
				; same as the character set (text font)
	ldx	#$0000
sprtclear:
	stz	$2104		; Horizontal position = 0
	stz	$2104		; Vertical position = 0
	lda	#$20		; 
	sta	$2104		; sprite object = 20 (space char)
				; invisible on the screen
	stz	$2104		; pallete = 0, priority = 0, h;v flip = 0
	inx
	cpx	#$0080		; (128 sprites)
	bne	sprtclear
	ldx	#$0000
sprtdataclear:
	stz	$2104		; clear H-position MSB
	stz	$2104		; and make size small
	inx
	cpx	#$0020		; 32 extra bytes for sprite data
				; info
	bne	sprtdataclear
	jsr	Spritemover	; set up the first sprites
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
                             

;==========================================================================
;                              Start of Data
;==========================================================================

TEXT:
		;********************************
	dc.b	"  "
	dc.b	$0a,$0a,$0a,$0a
	DC.B	"          HAPPY NEW YEAR",$0a
	dc.b	"            ! 1994 !",$0a,$0a,$0a
	DC.B	"  HERE'S A LATE CHRISTMAS GIFT",$0a
	DC.B	"   TO THE NEW SNES CODERS",$0a
	DC.B	" WAITING TO DO SOMETHING IN THE",$0a
	DC.B	" NEW YEAR! THIS THING WAS CODED",$0a
	DC.B	" IN A FEW HOURS JUST OUT OF THE "
	DC.B	" USUAL BOREDOME OF THE HOLIDAYS "
	DC.B	$0a,$0a
	DC.B	"  USE THE JOYPAD TO PLAY WITH",$0a
	DC.B	"         THE SINUS WAVE",$0a
	DC.B	"  TOP LEFT: DECREASE SINE ANGLE "
	DC.B	" TOP RIGHT: INCREASE SINE ANGLE "
	DC.B	"      LEFT: DECREASE SINE SPEED "
	DC.B	"     RIGHT: INCREASE SINE SPEED "
	dc.b	"         B: CHANGE SONG",$0a
	dc.b	"         X: CHANGE BAR WIDTH",$0a
	dc.b	"         Y: CHANGE WAVE SPEED",$0a
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	"                                "
	dc.b	0
	dc.b	"  ",$0a,$0a,$0a
	dc.b	"     CHEAP CODING BY -PAN-",$0a,$0a
	DC.B	"     FONT WAS MADE BY -PAN-",$0a,$0a
	DC.B	" FONTS FOR GRAPHICS ARE UNKNOWN ",$0a
	DC.B	" I TOOK THEM FROM A COLLECTION",$0a
	DC.B	"   OF FONTS ON SOME NEW AMIGA",$0a
	DC.B	" COLOR FONT EDITOR...",$0a,$0a
	DC.B	"  THE MUSIC IS FROM BIO-METAL",$0a
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	0
	dc.b	"  ",$0a,$0a,$0a
	dc.b	"          GREETINGS TO:"
	DC.B	$0A
	DC.B	"        THE WHITE KNIGHT",$0A
	dc.b	"              MICRO",$0A
	DC.B	"          XAD/NIGHTFALL",$0A
	DC.B	"           SIGMA SEVEN!",$0A
	DC.B	"             POTHEAD",$0A
	DC.B	"             SLAPSHOT",$0A
	DC.B	"             LOVERMAN",$0A
	DC.B	"            BELGARION",$0A
	DC.B	"              PICARD",$0A
	dc.b	"            AYATOLLAH",$0a
	DC.B	"      ALL ANTHROX MEMBERS",$0A
	DC.B	"             AND YOU!",$0A
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	DC.B	"                                "
	dc.b 1
SINE:
		; sine data  wave form: 0-100   length 256 bytes

 dc.b  50,51,52,54,55,56,57,59,60,61,62,63,65,66,67,68,69,70,71,72
 dc.b  74,75,76,77,78,79,80,81,82,83,84,84,85,86,87,88,89,89,90,91
 dc.b  92,92,93,94,94,95,95,96,96,97,97,97,98,98,99,99,99,99,99,100
 dc.b  100,100,100,100,100,100,100,100,100,100,99,99,99,99,99,98,98
 dc.b  97,97,97,96,96,95,95,94,94,93,92,92,91,90,89,89,88,87,86,85
 dc.b  84,84,83,82,81,80,79,78,77,76,75,74,72,71,70,69,68,67,66,65
 dc.b  63,62,61,60,59,57,56,55,54,52,51,50,49,48,46,45,44,43,41,40
 dc.b  39,38,37,35,34,33,32,31,30,29,28,26,25,24,23,22,21,20,19,18
 dc.b  17,16,16,15,14,13,12,11,11,10,9,8,8,7,6,6,5,5,4,4,3,3,3,2,2
 dc.b  1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,2,2,3,3,3,4,4,5,5
 dc.b  6,6,7,8,8,9,10,11,11,12,13,14,15,16,16,17,18,19,20,21,22,23
 dc.b  24,25,26,28,29,30,31,32,33,34,35,37,38,39,40,41,43,44,45,46
 dc.b  48,49

		; copy of same sine data for sprite
		; sine sine+60 will overlap 256 we need another copy of it
		; so it won't mess up!

 dc.b  50,51,52,54,55,56,57,59,60,61,62,63,65,66,67,68,69,70,71,72
 dc.b  74,75,76,77,78,79,80,81,82,83,84,84,85,86,87,88,89,89,90,91
 dc.b  92,92,93,94,94,95,95,96,96,97,97,97,98,98,99,99,99,99,99,100
 dc.b  100,100,100,100,100,100,100,100,100,100,99,99,99,99,99,98,98
 dc.b  97,97,97,96,96,95,95,94,94,93,92,92,91,90,89,89,88,87,86,85
 dc.b  84,84,83,82,81,80,79,78,77,76,75,74,72,71,70,69,68,67,66,65
 dc.b  63,62,61,60,59,57,56,55,54,52,51,50,49,48,46,45,44,43,41,40
 dc.b  39,38,37,35,34,33,32,31,30,29,28,26,25,24,23,22,21,20,19,18
 dc.b  17,16,16,15,14,13,12,11,11,10,9,8,8,7,6,6,5,5,4,4,3,3,3,2,2
 dc.b  1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,2,2,3,3,3,4,4,5,5
 dc.b  6,6,7,8,8,9,10,11,11,12,13,14,15,16,16,17,18,19,20,21,22,23
 dc.b  24,25,26,28,29,30,31,32,33,34,35,37,38,39,40,41,43,44,45,46
 dc.b  48,49


Colorbar:

		;    red bars
	dc.w	$0000,$0000,$0000,$1A20,$DC28,$5C31,$1E3A,$9E42
	dc.w	$1E3A,$5C31,$DC28,$1A20,$0000,$0000,$0000,$0000 
 	
		;    black bars (used to erase the red bars)
		;    although you'll notice on some patterns the red bars
		;    appear to "leak" through.. this is due to the reading
		;    of the sine data (it skips some lines, so it may skip a
		;    red line as well)
		   
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

;========================================================================
;                            Info Block Section
;========================================================================

	org	$ffea	;nmi vector in 65816 mode !! (Vertical blank IRQ)                         
	dcr.w	VBI
	org	$fffc	;reset vector in 6502 mode
	dcr.w	Start
	.pad		; fill the rest of the bank with #$00

;========================================================================
;                           Start Of Bank #$01
;========================================================================

Colors:
	; happy new year colors  grays, reds, greens

	dc.w	$0000,$DE7B,$9C73,$5863,$D65A,$9452,$524A,$0E42
	dc.w	$4003,$8002,$0002,$4001,$1E3A,$9E29,$1E19,$9E08 
 
	; 1994 logo colors	golds, dark blue
	dc.w	$0000,$9E53,$DA3A,$1422,$5011,$CC08,$CE08,$0018 
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	;character set font colors	red -> gold -> blue
	dc.w	$0000,$1E00,$9E08,$1E11,$9E19,$5E22,$DE2A,$5E33
	dc.w	$DE43,$5A4B,$D652,$525A,$8C61,$0869,$8470,$0078 
 

Spritecolors:
	; sprite colors	gold -> blue
	
	dc.w	$0000,$9E03,$5C0B,$1A13,$D81A,$9622,$542A,$1232
	dc.w	$D041,$8C49,$4A51,$0859,$C660,$8468,$4270,$0078 
 

GFX:
	.bin happy.dat		; include happy new year/1994 logo data
Charset:
	.bin char.dat		; include charset data
	.pad			; fill up the rest of the bank with zeros

;==========================================================================
;                             Start Of Bank #$02
;==========================================================================
song:
	.bin song		; include the song data!
				; since the data is 32768 bytes long it
				; will use up the entire bank
				; so there's no need to .pad out the rest
;==========================================================================
;                                  THE END
;==========================================================================
; BTW: this whole demo can be made on any BASIC compiler using these
; 3 lines:
; 10 Print "-Pan- Rules",
; 20 Print ":) :) :) :)",
; 30 Goto 10
;
; although it doesn't give the same colorful effect it will work!

