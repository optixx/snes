;	heap	O=512k		;max 128k object buffer                
;	size	8			;4 32kblocks                          
;	SMC+				;yes, we want a smc header            
;	lrom				;yes, please split in 32k hunks       

.INCLUDE "header.inc"  
.INCLUDE "init.inc"  


.EQU planeflip	    $400
.EQU joydata		planeflip+2
.EQU set2133		joydata+2
.EQU random1		set2133+2
.EQU random2		random1+2
.EQU verthtime		random2+2
.EQU logox		    verthtime+2
.EQU logomove		logox+2
.EQU fadetimer		logomove+2
.EQU fadeoffset		fadetimer+2
.EQU menuscroll		fadeoffset+2
.EQU menutimer		menuscroll+2
.EQU menumotion		menutimer+2
.EQU menudirection	menumotion+2
.EQU menuoffset		menudirection+2
.EQU currentline	menuoffset+2
.EQU numconv		currentline+2
.EQU low2			numconv+2
.EQU low1			low2+2
.EQU low0			low1+2
.EQU high6			low0+2
.EQU high5			high6+2
.EQU high4			high5+2
.EQU hundreds		high4+2
.EQU ones			hundreds+2
.EQU tens			ones+2
.EQU numbertimer	tens+2
.EQU bottomtimer	numbertimer+2
.EQU bottomfadeon	bottomtimer+2
.EQU bottomoffset	bottomfadeon+2
.EQU csh0			bottomoffset+2
.EQU ssh4			csh0+2
.EQU cst2			ssh4+2
.EQU sst6			cst2+2
.EQU sms8			sst6+2
.EQU ssa			sms8+2
.EQU scs			ssa+2
.EQU sinedir		scs+2
.EQU scrpal			sinedir+2
.EQU scrolldrop		scrpal+2
.EQU endflag		scrolldrop+2
.EQU endtimer		endflag+2
.EQU endhoriz		endtimer+2
.EQU toggle			endhoriz+2
.EQU storage		toggle+2

.EQU UnpackBuffr         $7f0000
.EQU Buff2		$000200	; 24-bit address of $1A0 byte buffer
.EQU in		    $65
.EQU out		$68
.EQU wrkbuf		$6a
.EQU counts		$6d
.EQU blocks		$4f
.EQU bitbufl	$51
.EQU bitbufh	$43
.EQU bufbits	$55
.EQU bitlen		$57
.EQU hufcde		$59
.EQU hufbse		$5b
.EQU temp1		$5d
.EQU temp2		$5f
.EQU temp3		$61
.EQU temp4		$63
.EQU tmptab		0	; indexed from Buff2
.EQU rawtab		$20	; indexed from Buff2
.EQU postab		$a0	; indexed from Buff2
.EQU slntab		$120	; indexed from Buff2

;==========================================================================
;      Code (c) 1995 -Pan-/ANTHROX   All code can be used at will!
;==========================================================================                     


;	jmp	IRQ  

Start:
;	
;
;	phk			; Put current bank on stack
;	plb			; make it current programming bank
;				; if this program were used as an intro
;				; and it was located at bank $20 then an
;				; LDA $8000 would actually read from
;				; $008000 if it were not changed!
;				; JSRs and JMPs work fine, but LDAs do not! 
;	clc			; Clear Carry flag
;	xce			; Native 16 bit mode  (no 6502 Emulation!) 
;==========================================================================

;	jsr	Snes_Init

;
    InitSNES


	rep	#$10
	sep	#$20
	ldx	#music		; CRUNCHED FILE
	stx	$65
	phk
	pla
	;lda	#^Picture1		; CRUNCHED FILE BANK
	sta	$67
	ldx	#$0000		; LOW WORD UNPACK BUFFER
	stx	$68
	lda	#$7f		; UNPACK BUFFER BANK
	pha
	plb
	jsr	UNPACK				;Requires A[8] XY[16]

	phk
	plb

	jsr	musique

	rep	#$30
	sep	#$20

	jsr	Copy_Gfx
	jsr	Make_tiles
	jsr	Copy_colors
	jsr	HDMA
	jsr	Sprite_setup

	jsr	Option_Setup

	lda	#$01
	sta	$2105
	
	lda	#$03
	sta	$212c

	;lda	#$02
	;sta	$212d

	lda	#$79
	sta	$2107
	
	lda	#$10
	sta	$2108

	lda	#$03
	sta	$210b



	ldx	#$0000
	stx	set2133

	ldx	#$0000
	stx	random1
	stx	random2

	ldx	#$01a0
	stx	verthtime

	ldx	#$0100
	stx	logox
	
	ldx	#$0000
	stx	logomove

	ldx	#$0000
	stx	fadetimer 
	stx	fadeoffset

	ldx	#$0000
	stx	menuscroll
	stx	menutimer
	stx	menumotion   
	stx	menudirection
	stx	menuoffset

	ldx	#$0001		; menu's starting currentline
	stx	currentline

	ldx	#$0000
	stx	numbertimer

	ldx	#$0000
	stx	bottomtimer
	stx	bottomfadeon
	stx	bottomoffset
	ldx	#$0001
	stx	csh0
	dex
	stx	ssh4
	stx	cst2
	stx	sst6
	stx	sms8
	stx	ssa 
	stx	scs
	
	ldx	#$0002
	stx	sinedir

	ldx	#%0000
	stx	scrpal

	ldx	#$0000
	stx	scrolldrop
	stx	endflag
	stx	endtimer
	stx	endhoriz


	lda	#$c3		; planes 1 uses Window 1 plane 2 uses Window 2
	sta	$2123
	lda	#$00
	sta	$2124

	lda	#$c0		; Color window uses window 2
	sta	$2125		; Obj window uses window 1
	
	lda	#$00		; window 1 start
	sta	$2126
	lda	#$ff		; window 1 end
	sta	$2127

	lda	#$00		; window 2 start
	sta	$2128
	lda	#$00		; Window 2 end
	sta	$2129

	lda	#$04		; Color Window Logic 0 = or
	sta	$212b		; 4 =and , 8 = xor, c = xnor

	lda	#$01		; Main screen mask belongs to obj, and planes
	sta	$212e		; same with subscreen
	lda	#$02
	sta	$212f

	lda	#$22;22		; sub screen window, effect happens INSIDE
	sta	$2130		; window	; 30 = turn effect OFF
						; 20 = turn effect on in window
						; 00 = on ALWAYS
	lda	#%10000010 	; ; 10000010 Color addition
 	sta	$2131		; not 1/2 bright, back, no obj, bg0-3

	lda	#%11100100	; blue off, green on, red off
	;sta	$2132		; lowest 5 bits = brightness

	lda	#$00
	sta	$210d
	lda	#$01
	sta	$210d

	lda	#$0f
	sta	$2100

	lda	#$01
	sta	$4200

	jsr	tune


Waitlooper:
	jsr	WaitVb

	stz	$212c
	stz	$2133
	ldx	verthtime
	beq	novhold

	lda	set2133
	sta	$2133
	eor	#$04
	sta	set2133

	dex
	stx	verthtime


novhold:

	lda	#$13
	sta	$212c

    rep #$38

	lda	random1
	ldx	randomnumbers
	sta	$210f
	stz	$210f
	
	ldx	random2
	lda	randomnumbers,x
	sta	$2110
	stz	$2110
	ldx	verthtime
	beq	okforintro
	jmp	endofintrovbi


okforintro:

	lda	logomove		; beginning of intro routine
	bne	dontmovelogo		; bring logo and other features
	jsr	movelogo		; together on the screen
	jsr	fadeline
	jmp	endofintrovbi
dontmovelogo:
	lda	endflag
	bne	skipallroutines
	jsr	joypad
	jsr	buttselect
	jsr	Sprscroll
	jsr	fadeline
	jsr	movemenu
	jsr	bottomchanger
	jsr	Movescroll

	rep	#$30
	lda	menuscroll
	clc
	adc	#$0088
	sta	$1e28
	sep	#$20
	jsr	teststart







endofintrovbi:
	inc	random1

	lda	random2
	clc
	adc	#$03
	adc	random1
	sta	random2
	jmp	Waitlooper

skipallroutines:
	jsr	endmove
	jsr	Sprscroll
	jsr	fadeline
	jsr	bottomchanger
	jsr	Movescroll

	bra	endofintrovbi

;==========================================================================
;                   Move Screen At End Of Intro
;==========================================================================

endmove:


	rep	#$30
	lda	logox
	inc a
	sta	logox
	and	#$00ff
	beq	stoplogomove2
	sep	#$20
returnmovelogo2:
	lda	logox		; move logo in HDMA list
	eor	#$ff
	sta	$1e21
	sta	$1e2b
	sta	$1e30
	lda	logox+1
	eor	#$ff
	sta	$1e22
	sta	$1e2c
	sta	$1e31

	lda	logox
	sta	$1e26		; move menu in HDMA list
	lda	logox+1
	sta	$1e27

	lda	logox		; shade the static
	eor	#$ff
	sta	$1e03		; dark static window left

	lda	logox
	lsr a
	lsr a
	inc a
	inc a
	sta	scrolldrop

	rts


stoplogomove2:

	jsr	tuneoff
	rep	#$30
	sep	#$20
	ldx	#$0000
	stx	endtimer
	stx	endhoriz

	lda	#$00
	sta	$2126
	lda	#$ff
	sta	$2127

	lda	#$02
	sta	$212e
	lda	#$30
	sta	$2123

	
	;stz 	$2123   ; BG1 & BG2 Window mask setting register
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

	stz 	$212F   ; Window mask for Sub Screen
	lda 	#$30
	sta 	$2130   ; Color addition & screen addition init setting
	stz 	$2131   ; Add/Sub sub designation for screen, sprite, color
	lda 	#$E0
	sta 	$2132   ; color data for addition/subtraction




	jsr	WaitVb
	stz	$420c
	stz	$420b

	ldx	#$0000
copy212clist:
	lda	list212c,x
	sta	$1e00,x
	inx
	cpx	#$0020
	bne	copy212clist


	lda     #$00          
	sta     $4300         
	lda     #$2c         
	sta     $4301         
	ldx     #$1e00  
	stx     $4302         
	lda	#$7e          
	sta     $4304
	lda	#$01
	sta	$420c




	bra	Waitcont


Waitblank:
	jsr	WaitVb


Waitcont:


	ldx	random1
	lda	randomnumbers,x
	sta	$210f
	stz	$210f
	
	ldx	random2
	lda	randomnumbers,x
	sta	$2110
	stz	$2110

	inc	random1

	lda	random2
	clc
	adc	#$03
	adc	random1
	sta	random2


	lda	$1e02
	sec
	sbc	#$05
	sta	$1e02

	lda	$1e04
	sec
	sbc	#$05
	sta	$1e04

	lda	$1e00
	clc
	adc	#$05
	sta	$1e00

	lda	endhoriz
	clc
	adc	#$05
	sta	endhoriz
	sta	$2126

	eor	#$ff
	sta	$2127

	ldx	endtimer
	inx
	inx
	inx
	inx
	inx
	stx	endtimer
	cpx	#$007d
	beq	endagain
	bra	Waitblank
endagain:

	ldx	#$0f00
	stx	fadetimer






Waitblank2:
	jsr	WaitVb

	
	ldx	random1
	lda	randomnumbers,x
	sta	$210f
	stz	$210f
	
	ldx	random2
	lda	randomnumbers,x
	sta	$2110
	stz	$2110

	inc	random1

	lda	random2
	clc
	adc	#$03
	adc	random1
	sta	random2

	lda	fadetimer
	dec a
	and	#$03
	sta	fadetimer
	bne	Waitblank2

	dec	fadetimer+1
	lda	fadetimer+1
	sta	$2100
	beq	Waitblank3

	bra	Waitblank2


Waitblank3:
	jsr	WaitVb
	jsr	Snes_Init
Watblank4:
	jmp	gameover


list212c:
	.db	1,0
	.db	$7f,$2
	.db	$7f,$2
	.db	1,0
	.db	0,0



;==========================================================================
;                  Test If Start Button Was Pressed
;==========================================================================

teststart:
	lda	joydata+1
	cmp	#$10
	beq	startpressed
	rts
startpressed:
	lda	#$01
	sta	endflag
	ldx	#$0000
	stx	joydata
	rts

;==========================================================================
;                      Sprite Scroll Routine
;==========================================================================

Sprscroll:
	rep	#$10	; x,y = 16 bit
	sep	#$20	; a = 8 bit
			; start of General DMA graphics copy routine!
	lda	#$00
	sta	$4370		; 0= 1 byte per register (not a word!)
	lda	#$04
	sta	$4371		; 21xx   this is 2118 (VRAM)
	lda	#$00
	sta	$4372
	lda	#$05		; address = $7e0500
	sta	$4373
	lda	#$7e
	sta	$4374		; bank address of data in ram
	ldx	#$0044
	stx	$4375		; # of bytes to be transferred

	ldx	#$0000
	stx	$2102

	lda	#$80		; turn on bit 8 (%1000=8) of G-DMA channel
	sta	$420b
	ldx	#$0100
	stx	$2102
	lda	sms8
	sta	$2104
	rts




Movescroll:



	stz	sms8
	lda	csh0
	sta	scs
	sec
	sbc	#$11
	sta	ssh4

	and	#$80
	asl a
	rol	sms8
	

	ldx	#$0000
	stx	sst6


	ldx	#$0000
	txy
				; csh0 = current scroll H pos
				; ssh4 = storage scroll h pos
				; cst2 = current scroll text pos
				; sst6	= storage scroll text pos
				; sms8 = storage of MSB

scrollwriter:
	lda	ssh4	
	sta	$0500,x
	inx
	phx
	rep	#$30
	lda	scs
	clc
	adc	ssa
	and	#$00ff
	tax
	rep	#$30
	lda	vertsine,x		; vert pos
	and	#$00ff
	clc
	adc	#$9f
	clc
	adc	scrolldrop
	cmp	#$00e0
	bcc	noyposset	
	lda	#$00e0

noyposset:
	sep	#$20
	plx
	sta	$0500,x
	inx
	rep	#$30

	

	phy
	ldy	sst6

	lda	$0550,y
	
	and	#$0ff
	sec
	sbc	#$20
	phx
	tax
	sep	#$20
	lda	fontpos,x	
	plx
	sta	$0500,x
	inx	    ;;	
	
	lda	$0570,y
	asl a
	ora	#%00110000

	;lda	#%00110000
	sta	$0500,x
	ply

	inx

	phx
	ldx	sst6
	inx
	stx	sst6
	plx


	lda	scs
	clc
	adc	#$10
	sta	scs


	lda	ssh4
	clc
	adc	#$10
	sta	ssh4
	iny
	cpy	#$0011
	bne	scrollwriter

	lda	ssa
	sec
	sbc	sinedir
	sta	ssa

	dec	csh0
	lda	csh0
	beq	movescrolltext
	rts
movescrolltext:
	lda	#$10
	sta	csh0

	inc	$1102
	inc	$1106


	ldx	#$0000
	sep	#$20
copyscrolltext:
	lda	$0551,x
	sta	$0550,x

	lda	$0571,x		; palette type/palette
	sta	$0570,x

	inx
	cpx	#$0010
	bne	copyscrolltext


readtext:


	ldx	cst2
	lda	scrolltext,x
	cmp	#'#'
	beq	leftright
	cmp	#'$'
	beq	rightleft
	cmp	#'%'
	beq	paleffect
	cmp	#$00
	beq	endscroll
	cmp	#$60
	bcc	noand5f
	and	#$5f
noand5f:
	sta	$0560
	lda	scrpal
	sta	$0580

	ldx	cst2
	inx
	stx	cst2
	rts


endscroll:
	ldx	#$0000
	stx	cst2
	bra	readtext

leftright:
	lda	#$02
	sta	sinedir
	ldx	cst2
	inx
	stx	cst2
	bra	readtext

rightleft:
	lda	#$fc
	sta	sinedir
	ldx	cst2
	inx
	stx	cst2
	bra	readtext

paleffect:
	ldx	cst2
	inx
	stx	cst2
	lda	scrolltext,x
	sec
	sbc	#$30
	and	#$07
	sta	scrpal
	ldx	cst2
	inx
	stx	cst2
	bra	readtext

;==========================================================================
;                       Bottom Text Changer Routine
;==========================================================================

bottomchanger:
	lda	bottomfadeon
	cmp	#$01
	beq	bottomfadein
	cmp	#$02
	beq	bottomfadeout

	lda	bottomtimer
	dec a
	and	#$ff
	sta	bottomtimer
	beq	changebottom
	rts
changebottom:
	lda	#$01
	sta	bottomfadeon
	ldx	#$0000
	stx	bottomoffset

bottomfadein:
	ldx	bottomoffset
	lda	bottommosaic,x
	sta	$1e4a
	inx
	stx	bottomoffset
	cpx	#$000f
	beq	enablefadeout
	rts

enablefadeout:
	lda	#$02
	sta	bottomfadeon
	lda	$1e32
	clc
	adc	#$10
	sta	$1e32
	rts

bottomfadeout:
	ldx	bottomoffset
	lda	bottommosaic,x
	sta	$1e4a
	inx
	stx	bottomoffset
	cpx	#$001e
	beq	stopfading
	rts
stopfading:
	ldx	#$00
	stx	bottomfadeon
	stx	bottomoffset
	rts

bottommosaic:
	.db	$11,$21,$31,$41,$51,$61,$71,$81,$91,$a1,$b1,$c1,$d1
	.db	$e1,$f1
	.db	$e1,$d1,$c1,$b1,$a1,$91,$81,$71,$61,$51,$41,$31,$21,$11,$01



;==========================================================================
;                   Change Trainer Value And Print Yes/No/#
;==========================================================================

buttselect:
	lda	joydata+1
	bit	#$80
	bne	OptB
	bit	#$02
	bne	OptB
	bit	#$01
	bne	OptA
	lda	joydata
	bit	#$80
	bne	OptA
	stz	numbertimer
	rts

OptA:
	jmp	Incopt
OptB:
	jmp	Decopt

Incopt:
	ldx	currentline		; get current option line
	dex
	lda	Type,x
	beq	Textopt
	jmp	Numberopt
Textopt:
	lda	#$01
	sta	$1c00,x
	jmp	displayyn	

Numberopt:
	lda	numbertimer
	inc a
	and	#$03
	sta	numbertimer
	beq	Numberoptinc
	rts
Numberoptinc:
	lda	$1c00,x
	cmp	Max,x
	bne	Incnumber
	rts
Incnumber:
	inc	$1c00,x
	lda	$1c00,x
PrintDec:
	sta	numconv
	jsr	Hex2Dec

	rep	#$30
	lda	currentline
	dec a
	asl a
	asl a
	asl a
	asl a
	asl a
	clc
	adc	#$7019
	sta	$2116
	sep	#$20
	lda	hundreds
	clc
	adc	#$10
	adc	#$7f
	sta	$2118
	lda	#$04
	sta	$2119
	lda	tens
	clc
	adc	#$10
	adc	#$7f
	sta	$2118
	lda	#$04
	sta	$2119
	lda	ones
	clc
	adc	#$10
	adc	#$7f
	sta	$2118
	lda	#$04
	sta	$2119
	rts




Decopt:
	ldx	currentline		; get current option line
	dex
	lda	Type,x
	beq	Textopt1
	jmp	Numberopt1
Textopt1:
	lda	#$00
	sta	$1c00,x
	jmp	displayyn	

Numberopt1:
	lda	numbertimer
	inc a
	and	#$03
	sta	numbertimer
	beq	Numberoptdec
	rts

Numberoptdec:
	lda	$1c00,x
	cmp	Min,x
	bne	Decnumber
	rts
Decnumber:
	dec	$1c00,x
	lda	$1c00,x
	sta	numconv
	jsr	Hex2Dec

	rep	#$30
	lda	currentline
	dec a
	asl a
	asl a
	asl a
	asl a
	asl a
	clc
	adc	#$7019
	sta	$2116
	sep	#$20
	lda	hundreds
	clc
	adc	#$10
	adc	#$7f
	sta	$2118
	lda	#$04
	sta	$2119
	lda	tens
	clc
	adc	#$10
	adc	#$7f
	sta	$2118
	lda	#$04
	sta	$2119
	lda	ones
	clc
	adc	#$10
	adc	#$7f
	sta	$2118
	lda	#$04
	sta	$2119
	rts




displayyn:
	rep	#$30
	lda	currentline
	dec a
	asl a
	asl a
	asl a
	asl a
	asl a
	clc
	adc	#$7019
	sta	$2116
	sep	#$20
	lda	$1c00,x
	beq	TxtNo
	ldx	#$0000
copyyes:
	lda	YES,x
	sec
	sbc	#$20
	clc
	adc	#$7f
	sta	$2118
	lda	#$04
	sta	$2119
	inx
	cpx	#$03
	bne	copyyes
	rts
TxtNo:
	ldx	#$0000
copyno:
	lda	NO,x
	sec
	sbc	#$20
	clc
	adc	#$7f
	sta	$2118
	lda	#$04
	sta	$2119
	inx
	cpx	#$03
	bne	copyno
	rts


	

;==========================================================================
;                          Move Menu Up/Down
;==========================================================================

movemenu:
	lda	menumotion
	beq	menucheckpad
	lda	menudirection
	beq	md3
	bne	mu3

menucheckpad:
	lda	joydata+1
	;and	#$0c
	bit	#$08
	bne	movedown
	bit	#$04
	bne	moveup
	rts

movedown:
	jmp	movedown2
moveup:
	jmp	moveup2

movedown2:
	lda	currentline
	cmp	#$01
	beq	md4
	dec	currentline
	lda	#$01
	sta	menumotion	; turn on menu motor!

	stz	menudirection	; 0 = moving down
	stz	menuoffset	; set to 0
	;rts
md3:
	dec	menuscroll
	lda	menuoffset
	inc a
	sta	menuoffset
	cmp	#$08
	beq	md4
	rts
md4:
	stz	menumotion
	rts


moveup2:
	lda	currentline
	cmp	options
	beq	mu4
	inc	currentline
	lda	#$01
	sta	menumotion
	lda	#$01
	sta	menudirection
	stz	menuoffset
	;rts

mu3:
	inc	menuscroll
	lda	menuoffset
	inc a
	sta	menuoffset
	cmp	#$08
	beq	mu4
	rts
mu4:
	stz	menumotion
	rts


	
	

;==========================================================================
;                          Joypad Routine
;==========================================================================

joypad:
	lda	$4212
	and	#$01
	beq	joypad
joypad2:
	lda	$4212
	and	#$01
	bne	joypad2

	ldx	$4218
	stx	joydata
	rts


;==========================================================================
;                     Fading Selection Bar Routine
;==========================================================================

fadeline:
	lda	fadetimer
	dec a
	and	#$03
	sta	fadetimer
	beq	fadelineok
	rts
fadelineok:
	ldx	fadeoffset
	lda	fadingcolors,x
	ora	#%01100000
	sta	$1e13
	
	lda	fadeoffset
	inc a
	cmp	#$01e
	bne	writefadeoffset
	lda	#$00
writefadeoffset:
	sta	fadeoffset
	rts

fadingcolors:
	.db	4,5,6,7,8,9,$a,$b,$c,$d,$e,$f,$e,$d,$c,$b,$a,9,8,7,6,5,4,3
	.db	2,1,0,1,2,3



;==========================================================================
;                   Move Logo Left After Vertical Hold Routine
;==========================================================================

movelogo:
	rep	#$30
	lda	logox
	dec a
	sta	logox
	beq	stoplogomove
	sep	#$20
returnmovelogo:
	lda	logox		; move logo in HDMA list
	eor	#$ff
	sta	$1e21
	sta	$1e2b
	sta	$1e30
	lda	logox+1
	eor	#$ff
	sta	$1e22
	sta	$1e2c
	sta	$1e31

	lda	logox
	sta	$1e26		; move menu in HDMA list
	lda	logox+1
	sta	$1e27

	lda	logox		; shade the static
	eor	#$ff
	sta	$1e03		; dark static window left
	rts
stoplogomove:
	sep	#$20
	lda	#$01
	sta	logomove
	bra	returnmovelogo

;==========================================================================
;                              Vertical Blank
;==========================================================================

WaitVb:
	lda	$4210
	bpl	WaitVb
WaitVb2:
	lda	$4210
	bmi	WaitVb2
	rts


;==========================================================================
;       	     SETUP ROUTINES FOR PROGRAM
;==========================================================================

;==========================================================================
;                         Copy graf-x data
;==========================================================================

Copy_Gfx:
	ldx	#$0000		; Vram address $0000 
	stx	$2116		; 
	ldx	#$0000
Clearvr:
	stz	$2118		; clear entire Vram
	stz	$2119
	inx
	bne	Clearvr

	rep	#$30


	ldx	#$0000
	stx	$2116


	ldx	#$0000
	
copystaticgfx:
	lda	staticgfx,x
	sta	$2118
	inx
	inx
	cpx	#$1000
	bne	copystaticgfx




	rep	#$10
	sep	#$20
	ldx	#atxgfx		; CRUNCHED FILE
	stx	$65
	phk
	pla
	;lda	#^Picture1		; CRUNCHED FILE BANK
	sta	$67
	ldx	#$0000		; LOW WORD UNPACK BUFFER
	stx	$68
	lda	#$7f		; UNPACK BUFFER BANK
	pha
	plb
	jsr	UNPACK				;Requires A[8] XY[16]

	phk
	plb

	rep	#$30
	;sep	#$20



	ldx	#$3000
	stx	$2116

	ldx	#$0000
copyatxgfx:
	lda	>$7f0000,x
	sta	$2118
	inx
	inx
	cpx	#$1be0
	bne	copyatxgfx




	rep	#$10
	sep	#$20
	ldx	#sprtgfx		; CRUNCHED FILE
	stx	$65
	phk
	pla
	;lda	#^Picture1		; CRUNCHED FILE BANK
	sta	$67
	ldx	#$0000		; LOW WORD UNPACK BUFFER
	stx	$68
	lda	#$7f		; UNPACK BUFFER BANK
	pha
	plb
	jsr	UNPACK				;Requires A[8] XY[16]

	phk
	plb

	rep	#$30
	;sep	#$20




	ldx	#$4000
	stx	$2116

	ldx	#$0000
copysprtgfx:
	lda	$7f0000,x
	sta	$2118
	inx
	inx
	cpx	#$1c00
	bne	copysprtgfx


	sep	#$20

	rts

;==========================================================================
;                      Copy Colors
;==========================================================================
Copy_colors:
	stz	$2121		; Select Color Register 1
	ldx	#$0000
CopCol:	
	lda	Colors,X
	sta	$2122
	inx
	cpx	#$0200 		; copy 32 colors ($20*2)
	bne	CopCol
	rts
;==========================================================================
;                      Make Tiles
;==========================================================================

Make_tiles:

	rep	#$30

	ldx	#$1000
	stx	$2116
	ldx	#$0000
	ldy	#$0000
	lda	#$0000
	sta	planeflip
copystatictile:
	lda	randomnumbers,y
	and	#$c000
	ora	planeflip
	sta	$2118

	lda	planeflip
	clc
	adc	#$05	; 9
	and	#$007f	; ff
	sta	planeflip

	tya
	inc a
	and	#$00ff
	tay

	inx
	inx
	cpx	#$0800
	bne	copystatictile




	rep	#$10
	sep	#$20
	ldx	#atxtile		; CRUNCHED FILE
	stx	$65
	phk
	pla
	;lda	#^Picture1		; CRUNCHED FILE BANK
	sta	$67
	ldx	#$0000		; LOW WORD UNPACK BUFFER
	stx	$68
	lda	#$7f		; UNPACK BUFFER BANK
	pha
	plb
	jsr	UNPACK				;Requires A[8] XY[16]

	phk
	plb

	rep	#$30
	;sep	#$20


	ldx	#$7840
	stx	$2116
	ldx	#$0000
copyatxtile:
	lda	$7f0000,x
	sta	$2118
	inx
	inx
	cpx	#$0200
	bne	copyatxtile

	ldx	#$6800
	stx	$2116

	ldx	#$0000
drawfont:
	lda	bottext,x
	clc
	adc	#$7f
	sta	$2118
	inx
	inx
	cpx	#64*32		;(rows*number of lines)
	bne	drawfont	

	ldx	#$7c00
	stx	$2116
	ldx	#$0000
	lda	#$0000
copyatxtile2:
	sta	$2118
	inx
	cpx	#$0400
	bne	copyatxtile2

	ldx	#$7000
	stx	$2116
	
	ldx	#$0000
copymenutxt:
	lda	menutxt,x
	and	#$00ff
	sec
	sbc	#$20
	clc
	adc	#$7f
	ora	#$0800
	sta	$2118
	inx
	cpx	#$0400-128
	bne	copymenutxt
copymenutxt2:
	lda	menutxt,x
	and	#$00ff
	sec
	sbc	#$20
	clc
	adc	#$7f
	ora	#$0c00
	sta	$2118
	inx
	cpx	#$0400
	bne	copymenutxt2
	


	sep	#$20


	rts


;=========================================================================
;                         Hex to Decimal Conversion
;=========================================================================

Hex2Dec:

	;lda	#$8f
	;sta	$1f28		; number to be converted

	rep	#$30
	lda	numconv
	and	#$000f
	asl a
	asl a
	tax
	sep	#$20
	inx
	inx
	inx
	lda	LOW,x
	sta	low2
	dex
	lda	LOW,x
	sta	low1
	dex
	lda	LOW,x
	sta	low0

	rep	#$30
	lda	numconv
	and	#$00f0
	lsr a
	lsr a
	lsr a
	lsr a
	asl a
	asl a
	tax
	sep	#$20
	inx
	inx
	inx
	lda	HIGH,x
	sta	high6
	dex	
	lda	HIGH,x
	sta	high5
	dex
	lda	HIGH,x
	sta	high4

oneadd:
	lda	high6
	clc
	adc	low2
	cmp	#$0a
	bcs	onehigh
	stz	hundreds
	sta	ones
	bra	tenadd
onehigh:
	sec
	sbc	#$0a
	sta	ones
	lda	#$01
	sta	hundreds

tenadd:
	lda	high5
	clc
	adc	low1
	clc
	adc	hundreds

	cmp	#$0a
	bcs	tenhigh
	stz	hundreds
	sta	tens
	bra	hundadd
tenhigh:
	sec	
	sbc	#$0a
	sta	tens
	lda	#$01
	sta	hundreds
	
hundadd:
	lda	high4
	clc
	adc	low0
	clc
	adc	hundreds
	sta	hundreds
	rts


;==========================================================================
;                            Option Setup Routine
;==========================================================================

Option_Setup:

	
	ldx	#$0000
clearopts:
	stz	$1c00,x
	inx
	cpx	#$0100
	bne	clearopts

	ldx	#$0000
SetOptRam:
	lda	Type,x
	bne	Numberthing
SetRamOpt:
	inx
	cpx	options
	bne	SetOptRam
	jmp	thisthat

Numberthing:
	lda	Begin,x
	sta	$1c00,x
	bra	SetRamOpt


thisthat:

	
	ldx	#$0001
	stx	currentline
	
printopt:
	ldx	currentline
	dex
	lda	Type,x
	bne	numbtype
	jsr	displayyn
contOptram:
	ldx	currentline
	inx
	stx	currentline
	ldx	currentline
	dex 
	cpx	options
	bne	printopt
	rts
numbtype:
	
	ldx	currentline
	dex
	lda	$1c00,x
	jsr	PrintDec
	bra	contOptram

	

;==========================================================================
;                        Start of HDMA routine
;==========================================================================

HDMA:
	rep	#$10
	sep	#$20

	ldx	#$0000
copy2129list:
	lda	list2129,x
	sta	$1e00,x
	inx
	cpx	#$0008
	bne	copy2129list

	ldx	#$0000
copy2132list:
	lda	list2132,x
	sta	$1e10,x
	inx
	cpx	#$0010
	bne	copy2132list


	ldx	#$0000
copy210dlist:
	lda	list210d,x
	sta	$1e20,x
	inx
	cpx	#$0020
	bne	copy210dlist

	ldx	#$0000
copy2106list:
	lda	list2106,x
	sta	$1e40,x
	inx
	cpx	#$0020
	bne	copy2106list


	lda     #$00          
	sta     $4300         
	lda     #$29         
	sta     $4301         
	ldx     #$1e00  
	stx     $4302         
	lda	#$7e          
	sta     $4304

	lda	#$00
	sta	$4310
	lda	#$32
	sta	$4311
	ldx	#$1e10
	stx	$4312
	lda	#$7e
	sta	$4314

	lda	#$03
	sta	$4320
	lda	#$0d
	sta	$4321
	ldx	#$1e20
	stx	$4322
	lda	#$7e
	sta	$4324
	
	lda	#$01
	sta	$4330
	lda	#$06
	sta	$4331
	ldx	#$1e40
	stx	$4332
	lda	#$7e
	sta	$4334
	


	jsr	WaitVb
	lda	#%00001111
	sta	$420c
	rts

list2129:	
	.db	$57,0,$48,$00,$1,$0,$0,$0

list2132:
	.db	$77,%11100111
	.db	$8,$0		;%11100111
	.db	$8,%11100111
	.db	$0,0,0,$0,$0

list210d:
	.db	$57,$00,$01,$00,$01
	.db	$48,$00,$01,$88,$00	; yay
	.db	$8,$00,$01,$00,$01
	.db	$10,$00,$01,$d8,0		:<-bot text
	.db	$01,$00,$01,$00,$01,0,0,0,0

list2106:
	.db	$57,$00,$79
	.db	$48,$00,$71
	.db	$08,$00,$79
	.db	$10,$00,$69		;x1<mosaic line 
	.db	$01,$00,$79
	.db	$0,$0,$0






;==========================================================================
;                           Sprite Setup routine
;==========================================================================

Sprite_setup:
	lda	#$62
	sta	$2101
	stz	$2102
	stz	$2103
	ldx	#$0000
sprtclear:
	stz	$2104		; Horizontal position
	lda	#$f0
	sta	$2104		; Vertical position
	stz	$2104		; sprite object = 0
	lda	#%00110000
	sta	$2104		; pallete = 0, priority = 0, h;v flip = 0
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

	ldx	#$0000
clearspritememory:
	lda	#$20
	sta	$0500,x
	inx
	cpx	#$0220
	bne	clearspritememory

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




;===========================================================================
;                         Start Of Unpack Routine
;===========================================================================

;---------------------------------------------------------
; PRO-PACK Unpack Source Code - Super NES, Method 1
;
; Copyright (c) 1992 Rob Northen Computing
;
; File: RNC_1.S
;
; Date: 9.03.92
;---------------------------------------------------------
;---------------------------------------------------------
; Unpack Routine - Super NES, Method 1
;
; To unpack a packed file (in any data bank) to an output
; buffer (in any data bank) Note: the packed and unpacked
; files are limited to 65536 bytes in length.
;
; To call (assumes 16-bit accumulator)
;
;
; On exit,
;
; A, X, Y undefined, M=0, X=0
;---------------------------------------------------------
;---------------------------------------------------------
; Equates
;---------------------------------------------------------


;---------------------------------------------------------
UNPACK	rep	#$39	; 16-bit AXY, clear D and C
	lda	#Buff2
	sta	wrkbuf
	lda	#^Buff2
	sta	wrkbuf+2
	lda	#17
	adc	in
	sta	in
	lda	[in]
	and	#$00ff
	sta	blocks
	inc	in
	lda	[in]
	sta	bitbufl
	stz	bufbits
	lda	#2
	jsr	gtbits
unpack2	ldy	#rawtab
	jsr	makehuff
	ldy	#postab
	jsr	makehuff
	ldy	#slntab
	jsr	makehuff
	lda	#16
	jsr	gtbits
	sta	counts
	jmp	unpack8
unpack3	ldy	#postab
	jsr	gtval
	sta	temp2
	lda	out
	clc
	sbc	temp2
	sta	temp3
	ldy	#slntab
	jsr	gtval
	inc	a
	inc	a
	lsr	a
	tax
	ldy	#0
	lda	temp2
	bne	unpack5
	sep	#$20	; 8-bit accumulator
	lda	(temp3),y
	xba
	lda	(temp3),y
	rep	#$20	; 16-bit accumulator
unpack4	sta	(out),y
	iny
	iny
	dex
	bne	unpack4
	bra	unpack6
unpack5	lda	(temp3),y
	sta	(out),y
	iny
	iny
	dex
	bne	unpack5
unpack6	bcc	unpack7
	sep	#$20	; 8-bit accumulator
	lda	(temp3),y
	sta	(out),y
	iny
	rep	#$21	; 16-bit accumulator, clear carry
unpack7	tya
	adc	out
	sta	out
unpack8	ldy	#rawtab
	jsr	gtval
	tax
	beq	unpack14
	ldy	#0
	lsr	a
	beq	unpack10
	tax
unpack9	lda	[in],y
	sta	(out),y
	iny
	iny
	dex
	bne	unpack9
unpack10	bcc	unpack11
	sep	#$20	; 8-bit accumulator
	lda	[in],y
	sta	(out),y
	rep	#$21	; 16-bit accumulator, clear carry
	iny
unpack11	tya
	adc	in
	sta	in
	tya
	adc	out
	sta	out
	stz	bitbufh
	lda	bufbits
	tay
	asl	a
	tax
	lda	[in]
	cpy	#0
	beq	unpack13
unpack12	asl	a
	rol	bitbufh
	dey
	bne	unpack12
unpack13	sta	temp1
	phb
	phk
	plb
	lda	msktab,x		;>
	plb
	and	bitbufl
	ora	temp1
	sta	bitbufl
unpack14	dec	counts
	beq	Mark1
	jmp	unpack3
Mark1	dec	blocks
	beq	Mark2
	jmp	unpack2
Mark2	rts
;-----------------------------------------------------------
gtval	ldx	bitbufl
	bra	gtval3
gtval2	iny
	iny
gtval3	txa
	and	[wrkbuf],y
	iny
	iny
	cmp	[wrkbuf],y
	bne	gtval2
	tya
	adc	#(15*4+1)
	tay
	lda	[wrkbuf],y
	pha
	xba
	and	#$ff
	jsr	gtbits
	pla
	and	#$ff
	cmp	#2
	bcc	gtval4
	dec	a
	asl	a
	pha
	lsr	a
	jsr	gtbits
	plx
	phb
	phk
	plb
	ora	bittab,x		;>
	plb
gtval4	rts
bittab	.dw	1
	.dw	2
	.dw	4
	.dw	8
	.dw	$10
	.dw	$20
	.dw	$40
	.dw	$80
	.dw	$100
	.dw	$200
	.dw	$400
	.dw	$800
	.dw	$1000
	.dw	$2000
	.dw	$4000
	.dw	$8000
;-----------------------------------------------------------
gtbits	tay
	asl	a
	tax
	phb
	phk
	plb
	lda	msktab,x		;>
	plb
	and	bitbufl
	pha
	lda	bitbufh
	ldx	bufbits
	beq	gtbits3
gtbits2	lsr	a
	ror	bitbufl
	dey
	beq	gtbits4
	dex
	beq	gtbits3
	lsr	a
	ror	bitbufl
	dey
	beq	gtbits4
	dex
	bne	gtbits2
gtbits3	inc	in
	inc	in
	lda	[in]
	ldx	#16
	bra	gtbits2
gtbits4	dex
	stx	bufbits
	sta	bitbufh
	pla
gtbits5	rts
msktab	.dw	0
	.dw	1
	.dw	3
	.dw	7
	.dw	$f
	.dw	$1f
	.dw	$3f
	.dw	$7f
	.dw	$ff
	.dw	$1ff
	.dw	$3ff
	.dw	$7ff
	.dw	$fff
	.dw	$1fff
	.dw	$3fff
	.dw	$7fff
	.dw	$ffff
;-----------------------------------------------------------
makehuff	sty	temp4
	lda	#5
	jsr	gtbits
	beq	gtbits5
	sta	temp1
	sta	temp2
	ldy	#0
makehuff2	phy
	lda	#4
	jsr	gtbits
	ply
	sta	[wrkbuf],y
	iny
	iny
	dec	temp2
	bne	makehuff2
	stz	hufcde
	lda	#$8000
	sta	hufbse
	lda	#1
	sta	bitlen
makehuff3	lda	bitlen
	ldx	temp1
	ldy	#0
makehuff4	cmp	[wrkbuf],y
	bne	makehuff8
	phx
	sty	temp3
	asl	a
	tax
	phb
	phk
	plb
	lda	msktab,x		;>
	plb
	ldy	temp4
	sta	[wrkbuf],y
	iny
	iny
	lda	#16
	sec
	sbc	bitlen
	pha
	lda	hufcde
	sta	temp2
	ldx	bitlen
makehuff5	asl	temp2
	ror	a
	dex
	bne	makehuff5
	plx
	beq	makehuff7
makehuff6	lsr	a
	dex
	bne	makehuff6
makehuff7	sta	[wrkbuf],y
	iny
	iny
	sty	temp4
	tya
	clc
	adc	#(15*4)
	tay
	lda	bitlen
	xba
	sep	#$20	; 8-bit accumulator
	lda	temp3
	lsr	a
	rep	#$21	; 16-bit accumulator, clear carry
	sta	[wrkbuf],y
	lda	hufbse
	adc	hufcde
	sta	hufcde
	lda	bitlen
	ldy	temp3
	plx
makehuff8	iny
	iny
	dex
	bne	makehuff4
	lsr	hufbse
	inc	bitlen
	cmp	#16
	bne	makehuff3
	rts





.EQU MOFF		$0200	;stop music 
.EQU MBONUS		$0201	;timer bonus countdown
.EQU MCHEAT		$0202	;cheat mode enabled
.EQU MCLICK		$0203	;button click
.EQU MOVER		$0204	;game over/time up
.EQU MTRING		$0205	;tring for startup of the wildcard
.EQU MSOLVED	$0206	;puzzle solved tune
.EQU MTUNE		$0207	;New tune....
.EQU MWINDOW	$0208	;Open selection window
.EQU MSELECT	$0209	;Move cursor up and down
.EQU MRESET		$0400	; reset the music controller

tune	rep #$30
	;lda #MTUNE
	lda	#MBONUS
	jsr NewSound_l
	sep #$20
 	rts

tuneoff:
	rep	#$30
	lda	#MRESET
	jsr	NewSound_l
	sep	#$20
	rts


	rep 	#$30
NewSound_l 	
	ora	toggle 
	sta	$2140 
	lda	toggle 
	eor	#$0100 
	sta	toggle 
	rts


musique:
	
	rep	#$30
	stz	toggle

 	sep	#$20
	lda	#$7f
	sta $a5 
	lda #00 
	sta $a4 
	sta $a3 
 

	php       
	rep     #$30  
	ldy     #$0000  
	lda     #$bbaa  
L00f7b6 cmp     $2140 
	bne     L00f7b6  
	sep     #$20  
	lda     #$cc  
	bra     L00f7f5 
L00f7c1 lda     [$a3],y  
	iny       
	bpl     L00f7cb		; check for bank overflow 
	ldy     #$0000 		; if so, zero y 
	inc     $a5		; and inc work reg bank 
L00f7cb xba       
	lda     #$00  
	bra     L00f7e2 
L00f7d0 xba       
	lda     [$a3],y  
	iny       
	bpl     L00f7db    	; check for bank overflow 
	ldy     #$0000		; if so, zero y 
	inc     $a5 		; and inc work reg bank 
L00f7db xba       
L00f7dc cmp     $2140 
	bne     L00f7dc  
	inc     a  
L00f7e2 rep     #$20  
	sta     $2140 
	sep     #$20  
	dex       
	bne     L00f7d0  
L00f7ec cmp     $2140 
	bne     L00f7ec  
L00f7f1 adc     #$03  
	beq     L00f7f1  
L00f7f5 pha       
	rep     #$20  
	lda     [$a3],y  
	iny       
	iny       
	tax       
	lda     [$a3],y  
	iny       
	iny       
	sta     $2142 
	sep     #$20  
	cpx     #$0001  
	lda     #$00  
	rol     a  
	sta     $2141 
	adc     #$7f  
	pla       
	sta     $2140 
L00f815 cmp     $2140 
	bne     L00f815  
	bvs     L00f7c1  
	plp       
	sep     #$30  
	rts     


.BANK 1
.ORG 0
.SECTION "data"


Colors:

	; static colors (grey)

	.dw	$0000,$4208,$8410,$C618,$0821,$4A29,$8C31,$CE39
	.dw	$1042,$524A,$9452,$D65A,$1863,$5A6B,$9C73,$FF7F 
 

	; atx colors (greys/blues..)

	.dw	$4631,$1888,$739C,$6B58,$6316,$5AD4,$5A92,$5250
	.dw	$4A0E,$420C,$41CC,$39CA,$398A,$2988,$2946,$20C4 

	; font colors 
	;                   orange
	.dw	$4210,$739C,$675C,$5F1B,$52DB,$4ABA,$3E79,$3639
	.dw	$2DF8,$25D8,$1D97,$1577,$0D36,$0515,$00F5,$18c6
	;                   blue
	.dw	$4210,$739C,$737A,$6F38,$6EF6,$6AD3,$6691,$664F
	.dw	$622D,$61EB,$5DA8,$5D86,$5944,$5902,$54E0,$0000
	;                   cyan
	.dw	$4210,$739C,$6F7A,$6758,$5F36,$5B14,$52F1,$4ACF
	.dw	$468D,$3E6B,$3648,$3226,$2A04,$21E2,$1DC0,$0000
	;		    red
	.dw	$4210,$7FFF,$7BBF,$737E,$6F1E,$66DD,$627C,$5A3C
	.dw	$55DB,$4D9B,$493A,$40F9,$3C99,$3458,$3018,$0000 
	;		    yellow
	.dw	$4210,$7FFF,$77DF,$6FBE,$637D,$5B5C,$533B,$4AFA
	.dw	$3ED9,$36B8,$2E77,$2656,$1A15,$11F5,$09D4,$0000 
	;			; green
	.dw	$4210,$6BFF,$63DE,$5BBC,$539B,$4B79,$4358,$3B36
	.dw	$3314,$2AF3,$22B1,$1A90,$126E,$0A4D,$022B,$0000 
	;		sprite colors
	;                   yellow
	.dw	$0000,$0193,$7FFF,$6739,$033F,$02FF,$02BD,$027B
	.dw	$0239,$01D7,$0195,$0153,$0111,$00CE,$008C,$000A 
	;	
	.dw	$0000,$02EF,$7FFF,$6739,$03FF,$03BD,$037A,$0337
	.dw	$02D4,$0291,$024E,$020B,$01A8,$0165,$0123,$00E0 
	;
	.dw	$0000,$5A40,$7FFF,$6739,$7FE0,$77A0,$6F40,$66E0
	.dw	$5EA0,$5240,$49E0,$41A0,$3940,$2CE0,$24A0,$1C40 
	;
	.dw	$0000,$01DB,$7FFF,$6739,$3B3F,$36DE,$329D,$2A5B
	.dw	$261A,$21B9,$1977,$1536,$10D5,$0893,$0452,$0010 
	;
	.dw	$0000,$4AFB,$7FFF,$6739,$3B3F,$3ADE,$3E9D,$3E5B
	.dw	$3E1A,$3DB9,$3D77,$4136,$40D5,$4093,$4052,$4010 
	;
	.dw	$0000,$6718,$7FFF,$6739,$739C,$6F5A,$6718,$5ED5
	.dw	$5693,$5251,$4A0F,$41CD,$3D8A,$3548,$2D06,$28C4 
	;
	.dw	$0000,$6718,$7FFF,$6739,$6B7C,$631C,$5EDC,$5A7C
	.dw	$563C,$51DB,$4D9B,$493B,$44FB,$3CBB,$385B,$341B 
	;
	.dw	$0000,$4E99,$7FFF,$6739,$6B7C,$5F3B,$56FA,$4E99
	.dw	$4258,$3A18,$2DD7,$2596,$1D55,$1114,$08D3,$0092 

 

fontpos:
	.db	0	;SP
	.db	$a	;!
	.db	$c	;"
	.db	0	;#
	.db	0 	;$
	.db	0 	;%
	.db	$2a	;&
	.db	$2	;'
	.db	$4	;(
	.db	$6	;)
	.db	$28	;* HE
	.db	$2a	;+
	.db	$2c	;,
	.db	$2e	;-
	.db	$0e	;.
	.db	$00	;/
	.db	$20	;0
	.db	$22	;1
	.db	$24	;2
	.db	$26	;3
	.db	$48	;4
	.db	$4a	;5
	.db	$4c	;6
	.db	$4e	;7
	.db	$60	;8
	.db	$62	;9
	.db	$40	;:
	.db	$40	;;
	.db	$4	;<
	.db	$46	;=
	.db	$6	;>
	.db	$6c	;?
	.db	$00	;@
	.db	$80	;A
	.db	$82	;B
	.db	$84	;C
	.db	$64	;D
	.db	$66	;E
	.db	$68	;F
	.db	$6a	;G
	.db	$8e	;H
	.db	$a0	;I
	.db	$a2	;J
	.db	$a4	;k
	.db	$a6	;l
	.db	$a8	;m
	.db	$86	;n
	.db	$88	;o
	.db	$8a	;p
	.db	$8c	;q
	.db	$c0	;r
	.db	$c2	;s
	.db	$c4	;t
	.db	$c6	;u
	.db	$c8	;v
	.db	$ca	;w
	.db	$aa	;x
	.db	$ac	;y
	.db	$ae	;z
 

YES:	.db	"YES"

NO:
	.db	"NO "

LOW:
	.db	0,0,0,0
	.db	0,0,0,1
	.db	0,0,0,2
	.db	0,0,0,3
	.db	0,0,0,4
	.db	0,0,0,5
	.db	0,0,0,6
	.db	0,0,0,7
	.db	0,0,0,8
	.db	0,0,0,9
	.db	0,0,1,0
	.db	0,0,1,1
	.db	0,0,1,2
	.db	0,0,1,3
	.db	0,0,1,4
	.db	0,0,1,5
	
HIGH:
	.db	0,0,0,0
	.db	0,0,1,6
	.db	0,0,3,2
	.db	0,0,4,8
	.db	0,0,6,4
	.db	0,0,8,0
	.db	0,0,9,6
	.db	0,1,1,2
	.db	0,1,2,8
	.db	0,1,4,4
	.db	0,1,6,0
	.db	0,1,7,6
	.db	0,1,9,2
	.db	0,2,0,8
	.db	0,2,2,4
	.db	0,2,4,0


vertsine:

 .db  24,25,25,26,26,27,28,28,29,29,30,30,31,32,32,33,33,34,34,35
 .db  35,36,36,37,37,38,38,39,39,40,40,41,41,41,42,42,43,43,43,44
 .db  44,44,45,45,45,45,46,46,46,46,47,47,47,47,47,47,48,48,48,48
 .db  48,48,48,48,48,48,48,48,48,48,48,48,48,47,47,47,47,47,47,46
 .db  46,46,46,45,45,45,45,44,44,44,43,43,43,42,42,41,41,41,40,40
 .db  39,39,38,38,37,37,36,36,35,35,34,34,33,33,32,32,31,30,30,29
 .db  29,28,28,27,26,26,25,25,24,23,23,22,22,21,20,20,19,19,18,18
 .db  17,16,16,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7,7,7
 .db  6,6,5,5,5,4,4,4,3,3,3,3,2,2,2,2,1,1,1,1,1,1,0,0,0,0,0,0,0,0
 .db  0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,5,5,5,6
 .db  6,7,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17
 .db  18,18,19,19,20,20,21,22,22,23,23


 


randomnumbers:
;	.db	$3A,$A7,$3E,$CB,$3A,$50,$96,$84,$68,$07,$6D,$BA,$0F,$A0
;	.db	$C4,$55,$72,$2F,$32,$80,$63,$0A,$A4,$02,$24,$4E,$3F,$F7,$FB,$B5
;	.db	$83,$F4,$72,$10,$01,$65,$66,$88,$12,$48,$51,$6B,$43,$BB,$E4,$01
;	.db	$65,$6A,$71,$44,$75,$25,$C2,$AE,$E4,$55,$B7,$A9,$90,$87,$5E,$33
;	.db	$8C,$23,$00,$2A,$33,$B1,$A6,$1E,$19,$89,$E1,$AA,$FC,$54,$8A,$0B
;	.db	$17,$22,$1F,$EE,$92,$26,$07,$9B,$68,$D5,$10,$90,$FE,$C8,$3B,$4C
;	.db	$10,$DA,$EF,$06,$A4,$71,$46,$B7,$4D,$47,$19,$84,$3F,$3F,$FC,$58
;	.db	$D0,$E2,$B6,$01,$EC,$F3,$56,$47,$41,$13,$73,$8B,$30,$5F,$91,$4A
;	.db	$86,$65,$42,$0B,$D4,$5B,$88,$25,$F3,$B6,$F2,$C1,$AB,$EF,$96,$CA
;	.db	$4B,$D7,$A1,$D4,$8D,$0C,$A6,$B1,$EF,$4C,$03,$3E,$8F,$AF,$CE,$49
;	.db	$49,$75,$72,$FD,$95,$52,$13,$66,$3F,$BE,$67,$F9,$61,$BF,$30,$7C
;	.db	$2B,$57,$0F,$BF,$05,$C1,$FA,$A3,$0E,$8E,$DA,$0D,$6B,$DA,$E1,$01
;	.db	$DF,$3D,$CB,$F2,$8C,$3A,$0D,$97,$BE,$D5,$FA,$D5,$30,$D9,$36,$1D
;	.db	$9C,$81,$3C,$27,$5B,$BD,$45,$EE,$2C,$62,$8B,$21,$54,$24,$19,$76
;	.db	$3D,$5B,$37,$78,$75,$99,$3E,$B8,$6A,$92,$3C,$30,$BF,$88,$2F,$27
;	.db	$AB,$E4,$C5,$0F,$25,$6F,$15,$AF,$FB,$7C,$BF,$5C,$34,$07,$DC,$CE
;	.db	$36,$1A



    .dw $3AA7,$3ECB,$3A50,$9684,$6807,$6DBA,$0FA0
    .dw $C455,$722F,$3280,$630A,$A402,$244E,$3FF7,$FBB5
    .dw $83F4,$7210,$0165,$6688,$1248,$516B,$43BB,$E401
    .dw $656A,$7144,$7525,$C2AE,$E455,$B7A9,$9087,$5E33
    .dw $8C23,$002A,$33B1,$A61E,$1989,$E1AA,$FC54,$8A0B
    .dw $1722,$1FEE,$9226,$079B,$68D5,$1090,$FEC8,$3B4C
    .dw $10DA,$EF06,$A471,$46B7,$4D47,$1984,$3F3F,$FC58
    .dw $D0E2,$B601,$ECF3,$5647,$4113,$738B,$305F,$914A
    .dw $8665,$420B,$D45B,$8825,$F3B6,$F2C1,$ABEF,$96CA
    .dw $4BD7,$A1D4,$8D0C,$A6B1,$EF4C,$033E,$8FAF,$CE49
    .dw $4975,$72FD,$9552,$1366,$3FBE,$67F9,$61BF,$307C
    .dw $2B57,$0FBF,$05C1,$FAA3,$0E8E,$DA0D,$6BDA,$E101
    .dw $DF3D,$CBF2,$8C3A,$0D97,$BED5,$FAD5,$30D9,$361D
    .dw $9C81,$3C27,$5BBD,$45EE,$2C62,$8B21,$5424,$1976
    .dw $3D5B,$3778,$7599,$3EB8,$6A92,$3C30,$BF88,$2F27
    .dw $ABE4,$C50F,$256F,$15AF,$FB7C,$BF5C,$3407,$DCCE
    .dw $361A


bottext:

	.db	    $10,"     Intro Coded By: -Pan-      "
	.db	$10," Music Composed By: The Doctor  "

	.db	$14,"       U.S.S. Enterprise        "
	.db	$14,"  412-233-2611  Sysop: Picard   "

	.db	$18,"     Intro Coded By: -Pan-      "
	.db	$18," Music Composed By: The Doctor  "

	.db	$1c,"           Trade Line           "
	.db	$1c," 514-966-9569 Sysop: Wild Fire  "

	.db	$10,"     Intro Coded By: -Pan-      "
	.db	$10," Music Composed By: The Doctor  "

	.db	$14,"            Dial Hard           "
	.db	$14,"  +41-7350-0155   Sysop: Fury   "

	.db	$18,"     Intro Coded By: -Pan-      "
	.db	$18," Music Composed By: The Doctor  "

	.db	$1c,"              Synergy           "
	.db	$1c," +49-PRIVATE Sysop: Sigma Seven "

	.db	$10,"     Intro Coded By: -Pan-      "
	.db	$10," Music Composed By: The Doctor  "

	.db	$14,"       U.S.S. Enterprise        "
	.db	$14,"  412-233-2611  Sysop: Picard   "

	.db	$18,"     Intro Coded By: -Pan-      "
	.db	$18," Music Composed By: The Doctor  "

	.db	$1c,"           Trade Line           "
	.db	$1c," 514-966-9569 Sysop: Wild Fire  "

	.db	$10,"     Intro Coded By: -Pan-      "
	.db	$10," Music Composed By: The Doctor  "

	.db	$14,"            Dial Hard           "
	.db	$14,"  +41-7350-0155   Sysop: Fury   "

	.db	$18,"     Intro Coded By: -Pan-      "
	.db	$18," Music Composed By: The Doctor  "

	.db	$1c,"              Synergy           "
	.db	$1c," +49-PRIVATE Sysop: Sigma Seven "


gameover:
	rep	#$30
	sep	#$20
	ldx	#$0000
copycheatdata:
	lda	$1c00,x
	sta	>$700000,x
	inx
	cpx	#$0020
	bne	copycheatdata

	sep	#$30
	lda	#$00
	phk
	plb
	;.db	$5c,$00,$80,$00		: <- jump to game!!



menutxt:
	.db	"   Unlimited Lives:      Yes    "
	.db	"   Unlimited Health:     Yes    "
	.db	"   In-Game Buttons:      Yes    "
	.db	"      Read Scroll Text For      "
	.db	"         In-Game Buttons        "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"                                "
	.db	"         Putty Squad +3         "
	.db	"     Original by Mad Turnip     "
	.db    "     Trained By -Pan- + TWK     "
	.db    "                                "

	; 0 = yellow
	; 1 = yellow/green
	; 2 = sky blue
	; 3 = red/orange
	; 4 = purple/pink
	; 5 = silver
	; 6 = pink
	; 7 = brown

scrolltext:
	.db	" #%1-putty squad- %0was released and "
    .db "trained by %7anthrox%0 on %54-30-95%0  "
	.db	"  $we greet these fine groups: #Censor   "
    .db "Cyberforce   Elite   Nightfall "
	.db	"and others that TWK forgot!         "
    .db "$the in game butts be: "
	.db	"sel+top left = level skip    sel+top right = "
    .db "open all doors  sel+a = select item 1  "
	.db	"     # %4 see ya!!      %1-pan-     "
	.db	"                           ",0



options:
	.db	3		;<- # of options
Type:                              
        .db    0,0,0,0,0,0,0,0,0,0,0,0,1  
                                   
Min:                               
        .db    1,0,1,1,0,1,1,1,3,0,0,0,1
                                   
Max:                               
        .db    9,5,5,5,5,6,1,1,1,1,1,1,12 
                                   
Begin:                             
        .db    2,4,4,1,0,1,1,1,3,0,0,0,1  

.ends

.BANK 1
.ORG 0
.SECTION "GFX"
staticgfx:
	.INCBIN	"static2.dat"
atxgfx:
	.INCBIN	"logofont.rnc"	; both files packed into one
atxtile:
	.INCBIN	"atxchar.rnc"
sprtgfx:
	.INCBIN "scroll.rnc"

music:
	.INCBIN	"atxchip4.rnc"
.ends


Slow:
	php
	sep	#$30
	.db	$af,$00,$00,$70
	and	#$01
	eor	#$01
	sta	$420d
	plp
	rtl




Cheat:
	.db	$ad,$18,$42
	.db	$85,$7a
	pha
	php
	sep	#$30
	.db	$af,$01,$80,$70
	beq	Livesoff
	lda	#$09
	sta	$1da1
	sta	$1da3
Livesoff:
	.db	$af,$02,$80,$70
	beq	Damage
	lda	#$0a
	sta	$1d09
	sta	$1d0b

Damage:
	;.db	$af,$03,$80,$70
	;beq	noammo
	;lda	#$99
	;sta	$1096
noammo:
	.db	$af,$03,$80,$70
	beq	nohyper
	lda	#$01
	sta	$1db1
	sta	$1db3

nohyper:
	.db	$af,$04,$80,$70
	beq	nothingy
	lda	#$01
	.db	$8f,$e0,$65,$7e
nothingy:
	;.db	$af,$05,$80,$70
	;beq	nojumpy
	;rep	#$30
	;.db	$a5,$7a
	;cmp	#$2020
	;bne	nojumpy
	;stz	$7a
	;sep	#$20
	;stz	$1e05

nojumpy:
	sep	#$20
	
	plp
	pla
	rtl
Time1:

	php
	sep	#$20
	.db	$af,$03,$80,$70
	beq	timeoff
	plp
	.db	$5c,$ab,$89,$01
	rtl
timeoff:
	plp
	.db	$a9,$e5,$04
	.db	$85,$e9
	.db	$5c,$9f,$89,$01
	;rtl
LEVEL:

	lda	$1a03
	bne	levelhere2
	bra	levelhere
levelthing:
	.db	$5c,$7d,$9e,$1d


levelhere:
	php
	rep	#$30
	.db	$af,$0c,$00,$70
	and	#$00ff
	dec a
	asl a
	asl a
	asl a
	sta	>$7e1a03
	plp
	lda	>$7e1a03
	beq	levelthing
	.db	$5c,$95,$9e,$1d

levelhere2:
	lda	$7e1a03
	.db	$5c,$95,$9e,$1d
	rtl

leveljunk:
	.dw	$8,$b,$14,$1d,$29,$33

IRQ:
	;.db	$ee,$c6,$ec
	;.db	$af,$10,$42,$00
	pha
	php
	sep	#$20
	.db	$af,$00,$00,$70
	beq	IRQnrg
	lda	#$03
	sta	>$7e0035
	sta	>$7e0037
IRQnrg:
	.db	$af,$01,$00,$70
	beq	IRQtime

	lda	#$4e
	sta	>$7e0026
	sta	>$7e0028
IRQtime:
	.db	$af,$02,$00,$70
	bne	IRQinvul



IRQend:
	plp
	pla
	rtl

IRQinvul:

	lda	>$7e1776
	ora	>$7e1778
	cmp	#$20
	beq	selectison
	plp
	pla
	rtl
selectison:

	lda	>$7e1775
	ora	>$7e1777
	and	#$20
	cmp	#$20
	bne	nolevelskippy
	sep	#$30
	;lda	>$7e0039
	lda	>$7e003a
	cmp	#$ff
	bne	nolevelskippy

	phx
	ldx	#$fe
levelloop:
	inx
	inx
	cpx	#$4c
	beq	forgetitall
	lda	>$0084f2,x
	cmp	>$7e003b
	bne	levelloop
	inx
	inx
	lda	>$0084f2,x
	sta	>$7e0039
	lda	#$00
	sta	>$7e003a
	plx	
	plp
	pla
	rtl

forgetitall:
	ldx	#$4e
	lda	>$0084f2,x
	sta	>$7e0039
	lda	#$00
	sta	>$7e003a
	plx
	plp
	pla
	rtl

nolevelskippy:
	lda	>$7e1775
	ora	>$7e1777
	and	#$10		; 10
	cmp	#$10
	bne	nodooropen
	lda	#$00
	sta	>$7e0024
	plp
	pla
	rtl

nodooropen:
	lda	>$7e1775	; 6
	and	#$80		; 80
	cmp	#$80
	bne	noitemsel1
	
	lda	>$70000f
	inc a
	and	#$07
	sta	>$70000f
	bne	noitemsel1


	lda	>$7e006d
	inc a
	inc a
	cmp	#$0c
	bcs	item1over
	sta	>$7e006d
	plp
	pla
	rtl

item1over:
	lda	#$00
	sta	>$7e006d
	plp
	pla
	rtl

noitemsel1:

	lda	>$7e1777
	and	#$80
	cmp	#$80
	bne	noitemsel2

	lda     >$70000f  
	inc a             
	and     #$07      
	sta     >$70000f  
	bne     noitemsel2


	lda	>$7e006f
	inc a
	inc a
	cmp	#$0c
	bcs	item2over
	sta	>$7e006f
	plp
	pla
	rtl

item2over:
	lda	#$00
	sta	>$7e006f
noitemsel2:
	plp
	pla
	rtl





	;.org	$fffc	;reset vector in 6502 mode
	;.dw	Start

