START   sei             ;STOP INTERRUPTS
	phk             ;GET THE CURRENT BANK AND STORE ON STACK
	plb             ;GET VALUE OFF STACK AND MAKE IT THE CURRENT
			;PROGRAMMING BANK
	clc             ;CLEAR CARRY BIT
	xce             ;NATIVE 16 BIT MODE (NO 6502 EMULATION!) 
	rep     #$30    ; X,Y,A fixed -> 16 bit mode
	sep     #$20    ; Accumulator ->  8 bit mode

	lda     #$10            ; Screen map data @ VRAM location $1000
	sta     $2107           ; Plane 0 Map location register
	lda     #$02            ; Plane 0 Tile graphics @ $2000  
	sta     $210b           ; Plane 0 Tile graphics register
	lda     #$01            ; MODE 1 value
	sta     $2105           ; Graphics mode register
	lda     #$01            ; Plane 0 value (bit one)
	sta     $212c           ; Plane enable register
	lda     #$00
	sta     $2121           ; Set color number to 0 (background)
	lda     #$00        ; color 0, black
	sta     $2122           
	sta     $2122        
	lda     #$40        ; color 1, blue
	sta     $2122
	sta     $2122
	lda     #$66        ; color 2, light blue
	sta     $2122
        lda     #$66
	sta     $2122
	lda     #$0f        ; color 3, dark red
	sta     $2122
	stz     $2122
	lda     #$ff        ; color 4, orange
	sta     $2122
        lda     #$02
	sta     $2122
	lda     #$ff        ; color 5, yellow
	sta     $2122
        lda     #$03
	sta     $2122
	lda     #$fa        ; color 6
	sta     $2122
        lda     #$12
	sta     $2122
	lda     #$f0        ; color 7
	sta     $2122
	stz     $2122
	lda     #$88        ; color 8, dark brown
	sta     $2122
	sta     $2122
	lda     #$13        ; color 9, red
	sta     $2122
	stz     $2122
	lda     #$1A        ; color 10, light red
	sta     $2122
	stz     $2122
	lda     #$FF        ; color 11
	sta     $2122
	sta     $2122
	lda     #$FF        ; color 12
	sta     $2122
	sta     $2122
	lda     #$FF        ; color 13
	sta     $2122
        lda     #$FF
	sta     $2122
	lda     #$FF        ; color 14
	sta     $2122
	sta     $2122
	lda     #$ff        ; color 15, white
	sta     $2122        
	sta     $2122       
	lda     #$01
	sta     $4200        ; ENABLE JOYPAD READ (bit one)

        lda     #$01
        sta     $210D
        lda     #$00
        sta     $210D

;---------------------------------------------------------------------------
; Store tiles-data in VRAM with general purpose DMA

	ldx     #$2000      ; Assign VRAM location to $2000 
	stx     $2116       

        stz     $420B       ; disable all DMA channels
        lda     #$01        ; set DMA transfer parameters
        sta     $4300       
        lda     #$18        ; VRAM data address
        sta     $4301
        ldx     #charset    ; base address tiles
        stx     $4302
        stz     $4304       ; bank $00
        lda     #$40        ; number of bytes to transfer: $05E0
        sta     $4305
        lda     #$06
        sta     $4306

        lda     #$01        ; start DMA on channel 0
        sta     $420B

;-------------------------------------------------------------------------
; Store low bytes of screen map data in VRAM with general purpose DMA

	ldx     #$1000      ; Assign VRAM location to $1000 
	stx     $2116

        stz     $2115       ; increase VRAM address after writing to $2118
        stz     $420B       ; disable all DMA channels
        stz     $4300       ; set DMA transfer parameters
        ldx     #screen     ; base address screen map data (low bytes only)
        stx     $4302       
        stz     $4305       ; number of bytes to transfer: $0400
        lda     #$04
        sta     $4306
        lda     #$01        ; start DMA on channel 0
        sta     $420B
        lda     #$80        ; incrase VRAM address after writing to $2119
        sta     $2115

;-------------------------------------------------------------------------
; Store high bytes of screen map data in VRAM with general purpose DMA
; All zero's transfered !!!!!!!!!!!!

        ldx     #$1000      ; Assign VRAM location to $1000
        stx     $2116

        stz     $420B       ; disable all DMA channels
        lda     #$19        ; VRAM data address (high bytes)
        sta     $4301
        ldx     #zero       ; zero data
        stx     $4302
        stz     $4305       ; number of bytes to transfer: $0400
        lda     #$04
        sta     $4306
        lda     #$01        ; start DMA on channel 0
        sta     $420B
        stz     $420B       ; disable all DMA channels

#fade_on
	lda     #$0f            ; SCREEN ENABLED, FULL BRIGHTNESS
	sta     $2100           ; 
	cli                     ; Clear interrupt bit
runaround 
	lda     $4210           ; check for Vertical blank
	and     #$80
	beq     runaround       ; no blank..  jump back!

joypad
	lda     $4212           ; is joypad ready to be read?
	and     #$01
	bne     joypad          ; no? go back until it is! 
	lda     $4219           ; read joypad high byte
	and     #$10            ; leave only "start" bit
	bne     reset           ; "start" pressed? go to RESET
	jmp     runaround       ; if not then jump back to loop
reset   
mos_off
	sep     #$30
	lda     #$00
	pha                     ; push #$00 to stack
	plb                     ; pull #$00 from stack and make it the
				; the programming bank
	jmp.l   START           ; jump long to $008000

charset
	bin tweetie.bin


screen
;line 1
	 dcb    $01,$00,$00,$00,$00,$00,$00,$00
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 2
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 3
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 4
	 dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$01,$02,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 5
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$03,$04,$05,$06,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 6
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$07,$08,$09,$0A,$0B,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 7
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $0C,$0D,$0E,$0F,$10,$11,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 8 
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $12,$13,$14,$15,$16,$17,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 9
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$18,$19,$1A,$1B,$1C,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 10
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$1D,$1E,$1F,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 11
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$20,$21,$22,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 12
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $23,$24,$25,$26,$27,$28,$29,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
;line 13
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $2A,$2B,$2C,$2D,$2E,$2F,$30,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
         dc.b    $00,$00,$00,$00,$00,$00,$00,$00
zero
 
