font    equ             $0A
START   sei
	phk             ;GET THE CURRENT BANK AND STORE ON STACK
	plb             ;GET VALUE OFF STACK AND MAKE IT THE CURRENT
			;PROGRAMMING BANK
	clc             ;CLEAR CARRY BIT
	xce             ;NATIVE 16 BIT MODE (NO 6502 EMULATION!)

;==========================================================================
;               START OF SNES REGISTER INITIALIZATION
;==========================================================================
;
	   rep #$30
	   lda #$0000
	   tcd
	   lda #charset
	   sta font
	   SEP #$30     ; X,Y,A are 8 bit numbers
	   LDA #$8F     ; screen off, full brightness
	   STA $2100    ; brightness + screen enable register
	   LDA #$00     ;
	   STA $2101    ; Sprite register (size + address in VRAM)
	   LDA #$00
	   STA $2102    ; Sprite registers (address of sprite memory [OAM])
	   STA $2103    ;    ""                       ""
	   LDA #$00     ; Mode 0
	   STA $2105    ; Graphic mode register
	   LDA #$00     ; no planes, no mosaic
	   STA $2106    ; Mosaic register
	   LDA #$00     ;
	   STA $2107    ; Plane 0 map VRAM location
	   LDA #$00
	   STA $2108    ; Plane 1 map VRAM location
	   LDA #$00
	   STA $2109    ; Plane 2 map VRAM location
	   LDA #$00
	   STA $210A    ; Plane 3 map VRAM location
	   LDA #$00
	   STA $210B    ; Plane 0+1 Tile data location
	   LDA #$00
	   STA $210C    ; Plane 2+3 Tile data location
	   LDA #$00
	   STA $210D    ; Plane 0 scroll x (first 8 bits)
	   STA $210D    ; Plane 0 scroll x (last 3 bits) #$0 - #$07ff
	   STA $210E    ; Plane 0 scroll y (first 8 bits)
	   STA $210E    ; Plane 0 scroll y (last 3 bits) #$0 - #$07ff
	   STA $210F    ; Plane 1 scroll x (first 8 bits)
	   STA $210F    ; Plane 1 scroll x (last 3 bits) #$0 - #$07ff
	   STA $2110    ; Plane 1 scroll y (first 8 bits)
	   STA $2110    ; Plane 1 scroll y (last 3 bits) #$0 - #$07ff
	   STA $2111    ; Plane 2 scroll x (first 8 bits)
	   STA $2111    ; Plane 2 scroll x (last 3 bits) #$0 - #$07ff
	   STA $2112    ; Plane 2 scroll y (first 8 bits)
	   STA $2112    ; Plane 2 scroll y (last 3 bits) #$0 - #$07ff
	   STA $2113    ; Plane 3 scroll x (first 8 bits)
	   STA $2113    ; Plane 3 scroll x (last 3 bits) #$0 - #$07ff
	   STA $2114    ; Plane 3 scroll y (first 8 bits)
	   STA $2114    ; Plane 3 scroll y (last 3 bits) #$0 - #$07ff
	   LDA #$80     ; increase VRAM address after writing to $2119
	   STA $2115    ; VRAM address increment register
	   LDA #$00
	   STA $2116    ; VRAM address low
	   STA $2117    ; VRAM address high
	   STA $211A    ; Initial Mode 7 setting register
	   STA $211B    ; Mode 7 matrix parameter A register (low)
	   LDA #$01
	   STA $211B    ; Mode 7 matrix parameter A register (high)
	   LDA #$00
	   STA $211C    ; Mode 7 matrix parameter B register (low)
	   STA $211C    ; Mode 7 matrix parameter B register (high)
	   STA $211D    ; Mode 7 matrix parameter C register (low)
	   STA $211D    ; Mode 7 matrix parameter C register (high)
	   STA $211E    ; Mode 7 matrix parameter D register (low)
	   LDA #$01
	   STA $211E    ; Mode 7 matrix parameter D register (high)
	   LDA #$00
	   STA $211F    ; Mode 7 center position X register (low)
	   STA $211F    ; Mode 7 center position X register (high)
	   STA $2120    ; Mode 7 center position Y register (low)
	   STA $2120    ; Mode 7 center position Y register (high)
	   STA $2121    ; Color number register ($0-ff)
	   STA $2123    ; BG1 & BG2 Window mask setting register
	   STA $2124    ; BG3 & BG4 Window mask setting register
	   STA $2125    ; OBJ & Color Window mask setting register
	   STA $2126    ; Window 1 left position register
	   STA $2127    ; Window 2 left position register
	   STA $2128    ; Window 3 left position register
	   STA $2129    ; Window 4 left position register
	   STA $212A    ; BG1, BG2, BG3, BG4 Window Logic register
	   STA $212B    ; OBJ, Color Window Logic Register (or,and,xor,xnor)
	   LDA #$01
	   STA $212C    ; Main Screen designation (planes, sprites enable)
	   LDA #$00
	   STA $212D    ; Sub Screen designation
	   LDA #$00
	   STA $212E    ; Window mask for Main Screen
	   STA $212F    ; Window mask for Sub Screen
	   LDA #$30
	   STA $2130    ; Color addition & screen addition init setting
	   LDA #$00
	   STA $2131    ; Add/Sub sub designation for screen, sprite, color
	   LDA #$E0
	   STA $2132    ; color data for addition/subtraction
	   LDA #$00
	   STA $2133    ; Screen setting (interlace x,y/enable SFX data)
	   LDA #$00
	   STA $4200    ; Enable V-blank, interrupt, Joypad register
	   LDA #$FF
	   STA $4201    ; Programmable I/O port
	   LDA #$00
	   STA $4202    ; Multiplicand A
	   STA $4203    ; Multiplier B
	   STA $4204    ; Multiplier C
	   STA $4205    ; Multiplicand C
	   STA $4206    ; Divisor B
	   STA $4207    ; Horizontal Count Timer
	   STA $4208    ; Horizontal Count Timer MSB (most significant bit)
	   STA $4209    ; Vertical Count Timer
	   STA $420A    ; Vertical Count Timer MSB
	   STA $420B    ; General DMA enable (bits 0-7)
	   STA $420C    ; Horizontal DMA (HDMA) enable (bits 0-7)
	   STA $420D    ; Access cycle designation (slow/fast rom)
;===========================================================================
;                        END OF INIT ROUTINE
;===========================================================================
	rep     #$30    ; X,Y,A fixed -> 16 bit mode
	sep     #$20    ; Accumulator ->  8 bit mode
	lda     #$10            ; Screen map data @ VRAM location $1000
	sta     $2107           ; Plane 0 Map location register
	lda     #$02            ; Plane 0 Tile graphics @ $2000
	sta     $210b           ; Plane 0 Tile graphics register
	lda     #$00            ; MODE 0 value
	sta     $2105           ; Graphics mode register
	lda     #$01            ; Plane 0 value (bit one)
	sta     $212c           ; Plane enable register
	lda     #$00
	sta     $2121           ; Set color number to 0 (background)
	lda     #$46            ; blue color, lower 8 bits
	sta     $2122           ; enter color value #$46 to color num. (low)
	lda     #$60            ; blue color, higher 8 bits
	sta     $2122           ; enter color value #$69 to color num. (high)
	lda     #$ff            ; white color, lower 8 bits
	sta     $2122           ; write to next color number (01)
	sta     $2122           ; enter same value to color number (01)
	lda     #$40            ; color number (10)
	sta     $2122
	sta     $2122
	lda     #$80            ; color number (11)
	sta     $2122
	sta     $2122
	lda     #$01
	sta     $4200           ; ENABLE JOYPAD READ (bit one)
;==========================================================================
;                      Start transfer of graphics to VRAM
;==========================================================================
	ldx     #$2000          ; Assign VRAM location $2000 to $2116/7
	stx     $2116           ; writing to $2118/9 will store data here!
	ldy     #$0000
copychar lda    (font),y        ; Get CHARACTER SET DATA (Font DATA)
	sta     $2118           ; store bitplane 1
	stz     $2119           ; clear bitplane 2 and increase VRAM address
	iny
	cpy     #$0200          ; Transfer $0200 bytes
	bne     copychar
;
	ldx     #$1000          ; Assign VRAM location $1000 to $2116/7
	stx     $2116
	ldx     #$0000
textinfo lda    TEXTPAN,x       ; Get ASCII text data
	and     #$3f            ; we only want the first 64 characters
;                               ; convert ascii to C64 screen code
	sta     $2118
	stz     $2119           ; clear unwanted bits, no H/V flipping
	inx
	cpx     #$0400          ; transfer entire screen
;                               ; $20*$20=$0400  (1024 bytes)
	bne     textinfo
;
	lda     #$0f            ; SCREEN ENABLED, FULL BRIGHTNESS
	sta     $2100           ;
	cli                     ; Clear interrupt bit
runaround lda   $4210           ; check for Vertical blank
	and     #$80
	beq     runaround       ; no blank..  jump back!
;
joypad  lda     $4212           ; is joypad ready to be read?
	and     #$01
	bne     joypad          ; no? go back until it is!
	lda     $4219           ; read joypad high byte
	and     #$10            ; leave only "start" bit
	bne     reset           ; "start" pressed? go to RESET
	jmp     runaround       ; if not then jump back to loop
;       brl     runaround
reset   sep     #$30
	ldy     #$0f
lus1    ldx     #$06
	dey
	sty     $2100
wait    lda     $4210
	and     #$80
	beq     wait
	dex
	cpx     #$00
	bne     wait
	cpy     #$00
	bne     lus1
	rep     #$10
	ldx     #$0fff
dark    lda     $4210
	and     #$80
	beq     dark
	dex
	cpx     #$0000
	bne     dark
	sep     #$30
	lda     #$00
	pha                     ; push #$00 to stack
	plb                     ; pull #$00 from stack and make it the
;                               ; the programming bank
;       dcb     $5c,$00,$80,$00 ; jump long to $008000
	jmp   START
;
;============================================================================
;= Cyber Font-Editor V1.4  Rel. by Frantic (c) 1991-1992 Sanity Productions =
;============================================================================
charset 
	dcb     $C0,$B8,$87,$80,$80,$80,$80,$80 ;'@'
	dcb     $00,$3c,$66,$7e,$66,$66,$66,$00 ;'A'
	dcb     $00,$7c,$66,$7c,$66,$66,$7c,$00 ;'B'
	dcb     $00,$3c,$66,$60,$60,$66,$3c,$00 ;'C'
	dcb     $00,$78,$6c,$66,$66,$6c,$78,$00 ;'D'
	dcb     $00,$7e,$60,$78,$60,$60,$7e,$00 ;'E'
	dcb     $00,$7e,$60,$78,$60,$60,$60,$00 ;'F'
	dcb     $00,$3c,$66,$60,$6e,$66,$3c,$00 ;'G'
	dcb     $00,$66,$66,$7e,$66,$66,$66,$00 ;'H'
	dcb     $00,$3c,$18,$18,$18,$18,$3c,$00 ;'I'
	dcb     $00,$1e,$0c,$0c,$0c,$6c,$38,$00 ;'J'
	dcb     $00,$6c,$78,$70,$78,$6c,$66,$00 ;'K'
	dcb     $00,$60,$60,$60,$60,$60,$7e,$00 ;'L'
	dcb     $00,$63,$77,$7f,$6b,$63,$63,$00 ;'M'
	dcb     $00,$66,$76,$7e,$7e,$6e,$66,$00 ;'N'
	dcb     $00,$3c,$66,$66,$66,$66,$3c,$00 ;'O'
	dcb     $00,$7c,$66,$66,$7c,$60,$60,$00 ;'P'
	dcb     $00,$3c,$66,$66,$66,$3c,$0e,$00 ;'Q'
	dcb     $00,$7c,$66,$66,$7c,$6c,$66,$00 ;'R'
	dcb     $00,$3e,$60,$3c,$06,$66,$3c,$00 ;'S'
	dcb     $00,$7e,$18,$18,$18,$18,$18,$00 ;'T'
	dcb     $00,$66,$66,$66,$66,$66,$3c,$00 ;'U'
	dcb     $00,$66,$66,$66,$66,$3c,$18,$00 ;'V'
	dcb     $00,$63,$63,$6b,$7f,$77,$63,$00 ;'W'
	dcb     $00,$66,$3c,$18,$3c,$66,$66,$00 ;'X'
	dcb     $00,$66,$66,$3c,$18,$18,$18,$00 ;'Y'
	dcb     $00,$7e,$0c,$18,$30,$60,$7e,$00 ;'Z'
	dcb     $00,$00,$FF,$00,$00,$00,$00,$0F ;'['
	dcb     $00,$00,$FF,$00,$00,$00,$00,$00 ;'\'
	dcb     $03,$1D,$E1,$01,$01,$01,$01,$01 ;']'
	dcb     $80,$80,$80,$80,$80,$80,$80,$80 ;'^'
	dcb     $07,$03,$03,$07,$07,$0F,$0F,$1F ;'_'
	dcb     $00,$00,$00,$00,$00,$00,$00,$00 ;' '
	dcb     $C0,$E0,$F0,$F0,$F0,$F8,$F8,$F8 ;'!'
	dcb     $01,$01,$01,$01,$01,$01,$01,$01 ;'"'
	dcb     $80,$80,$80,$81,$87,$8F,$9F,$9F ;'#'
	dcb     $1F,$1F,$0F,$C0,$E1,$F3,$F7,$F7 ;'$'
	dcb     $F8,$F0,$E0,$06,$8F,$CF,$EF,$EF ;'%'
	dcb     $01,$01,$01,$09,$99,$F9,$F9,$F9 ;'&'
	dcb     $9F,$99,$50,$40,$40,$40,$40,$20 ;'''
	dcb     $F3,$F1,$60,$07,$0F,$1F,$1F,$1F ;'('
	dcb     $CF,$87,$03,$F0,$F8,$F8,$F8,$F0 ;')'
	dcb     $F1,$E1,$82,$02,$02,$02,$02,$04 ;'*'
	dcb     $20,$20,$10,$10,$08,$08,$04,$04 ;'+'
	dcb     $00,$00,$00,$00,$00,$18,$18,$30 ;','
	dcb     $F0,$E0,$E0,$C0,$C0,$E0,$F0,$00 ;'-'
	dcb     $00,$00,$00,$00,$00,$18,$18,$00 ;'.'
	dcb     $04,$04,$08,$08,$10,$10,$20,$20 ;'/'
	dcb     $00,$3c,$66,$6e,$76,$66,$3c,$00 ;'0'
	dcb     $00,$18,$38,$18,$18,$18,$7e,$00 ;'1'
	dcb     $00,$7c,$06,$0c,$30,$60,$7e,$00 ;'2'
	dcb     $00,$7e,$06,$1c,$06,$66,$3c,$00 ;'3'
	dcb     $00,$0e,$1e,$36,$7f,$06,$06,$00 ;'4'
	dcb     $00,$7e,$60,$7c,$06,$66,$3c,$00 ;'5'
	dcb     $00,$3e,$60,$7c,$66,$66,$3c,$00 ;'6'
	dcb     $00,$7e,$06,$0c,$0c,$0c,$0c,$00 ;'7'
	dcb     $00,$3c,$66,$3c,$66,$66,$3c,$00 ;'8'
	dcb     $00,$3c,$66,$3e,$06,$66,$3c,$00 ;'9'
	dcb     $01,$01,$01,$01,$01,$01,$01,$01 ;':'
	dcb     $02,$01,$00,$00,$00,$00,$00,$00 ;';'
	dcb     $00,$00,$80,$40,$20,$18,$06,$01 ;'<'
	dcb     $00,$00,$01,$02,$04,$18,$60,$80 ;'='
	dcb     $40,$80,$00,$00,$00,$00,$00,$00 ;'>'
	dcb     $1F,$0F,$0F,$0F,$07,$03,$00,$00 ;'?'
;
;
;               ;12345678901234567890123456789012
TEXTPAN dcb     "                                "
	dcb     "                                "
	dcb     "                                "
	dcb     "                                "
	dcb     "   @[\]                  @[\]   "
	dcb     "   ^_!:       THE        ^_!:   "
	DCB     "   #$%&                  #$%&   "
	dcb     "   '()*   INQUISITION    '()*   "
	DCB     "   +?-/                  +?-/   "
	dcb     "   ;<=>                  ;<=>   "
	DCB     "                                "
	DCB     "                                "
	DCB     "            PRESENTS            "
	DCB     "                                "
	DCB     "                                "
	DCB     " A SIMPLE DEMO FOR USE WITH OUR "
	DCB     "      FINE SNES ASSEMBLER       "
	DCB     "                                "
	DCB     "                                "
	DCB     "    PLEASE CHECK THE SNESASM    "
	dcB     "          SUPPORT BBS           "
	DCB     " THE VOYAGE OF THE DAWN TREADER "
	DCB     "        31 10 4526979           "
	DCB     " ONLY BETWEEN 2200 AND 700 CET  "
	DCB     "                                "
	DCB     "                                "
	DCB     "                                "
	DCB     "                                "
	DCB     "                                "
