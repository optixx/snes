;----------------------------------------------------------------------------
; Sprite size test
; by Charles MacDonald
; WWW: http://cgfm2.emuviews.com
;
; Y = Toggle sprite size bit in OAM
; X = Toggle bit 2 of sprite size field of $2101
; B = Toggle bit 1 of sprite size field of $2101
; A = Toggle bit 0 of sprite size field of $2101
;
; Top byte is sprite #0 size bit
; Bottom byte is D7-D5 of $2101 (global sprite size)
;
;----------------------------------------------------------------------------

                        .MEMORYMAP
                        SLOTSIZE $8000
                        DEFAULTSLOT 0
                        SLOT 0 $8000
                        .ENDME
        
                        .ROMBANKSIZE $8000
                        .ROMBANKS 2
        
                        .BANK 0 SLOT 0
                        .org    $0000

;----------------------------------------------------------------------------
; Variables
;----------------------------------------------------------------------------

                        .ENUM $00
framecount              db
joy1_old                dw
joy1_new                dw
joy1_delta              dw
objsel                  db
size                    db
temp                    dw
                        .ENDE

;----------------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------------

__emu_reset:
                        sei
                        clc
                        xce             ; Native mode
                        rep     #$38
                        ldx     #$1FFF  ; Set stack top
                        txs
                        phk
                        plb
                        lda     #$0000  ; Set direct page to $0000xx
                        tcd
                        sep     #$20

                        jsr     ppu_init

                        ; Clear name table
                        ldx.w   #$0000
                        txy
                        stx     $2116
        clearnt:        sty     $2118
                        inx
                        cpx.w   #$4000
                        bne     clearnt

                        ; Load 4-bpp font @ $08000
                        ldx.w   #$4000
                        stx     $2116
                        ldx.w   #$0000
        loadfont4:      lda.l   font4+0,x
                        sta     $2118
                        lda.l   font4+1,x
                        sta     $2119
                        inx
                        inx
                        cpx.w   #$1000
                        bne     loadfont4

                        ; Load palette
                        stz     $2121
                        ldx.w   #$0000
        loadpal:        lda.w   palette,x
                        sta     $2122
                        inx
                        cpx.w   #$0200
                        bne     loadpal

                        ; Clear OAM
                        ldx     #$0000
                        stx     $2102
                        ldx     #$00
        clearoam1:      stz     $2104
                        lda     #$F0
                        sta     $2104
                        stz     $2104
                        stz     $2104
                        inx
                        cpx     #$80
                        bne     clearoam1

                        ; Clear OAM
                        ldx     #$00
                        lda     #%01010101
        clearoam2:      sta     $2104
                        inx
                        cpx     #$20
                        bne     clearoam2

                        ; Write test sprite
                        ldx     #$0000
                        stx     $2102

                        lda     #$40
                        sta     $2104   ; xpos
                        sta     $2104   ; ypos
                        lda     #$01
                        sta     $2104   ; name
                        stz     $2104   ; attr

                        ; Clear pending NMIs, then enable NMIs
                        lda     $4210
                        lda     #$80
                        sta     $4200

                        ; Turn screen on, full brightness
                        lda     #$0F
                        sta     $2100

                        ; Set up variables
                        lda     #$02
                        sta     objsel
                        lda     #%01010100
                        sta     size

;----------------------------------------------------------------------------

        loop:
                        wai
                        inc     framecount

                        ; Latch joypad button state
                        lda     #$01
                        sta     $4016
                        stz     $4016

                        ; Update previous frame button state
                        ldx     joy1_new
                        stx     joy1_old

                        ; Read out joypad buttons
                        .rept   8
                        lda     $4016
                        lsr     a
                        rol     joy1_new+0
                        .endr

                        .rept   8
                        lda     $4016
                        lsr     a
                        rol     joy1_new+1
                        .endr

                        rep     #$20
                        lda.w   joy1_new
                        eor.w   joy1_old
                        and.w   joy1_new
                        sta.w   joy1_delta
                        sep     #$20

                        ; AXLR---- BYSTUDLR

                        lda     #$80
                        bit     joy1_delta+1
                        beq     no_a
                        lda     objsel
                        eor     #$20
                        sta     objsel
        no_a:
                        lda     #$80
                        bit     joy1_delta+0
                        beq     no_b
                        lda     objsel
                        eor     #$40
                        sta     objsel
        no_b:
                        lda     #$40
                        bit     joy1_delta+1
                        beq     no_x
                        lda     objsel
                        eor     #$80
                        sta     objsel
        no_x:
                        lda     #$40
                        bit     joy1_delta+0
                        beq     no_y

                        lda     size
                        eor     #$02
                        sta     size
        no_y:
                        ; Update global sprite size
                        lda     objsel
                        sta     $2101

                        ; Update sprite #0 size
                        ldx     #$0100
                        stx     $2102
                        lda     size
                        sta     $2104
                        stz     $2104

                        stz     $2102
                        stz     $2103

                        lda     size
                        ldx     #$02
                        ldy     #$02
                        and     #$02
                        lsr     a
                        jsr     printhexb

                        lda     objsel
                        ldx     #$02
                        ldy     #$03
                        and     #$E0
                        lsr     a
                        lsr     a
                        lsr     a
                        lsr     a
                        lsr     a
                        jsr     printhexb

                        jmp     loop

;-----------------------------------------------------------------------------
; Subroutines
;-----------------------------------------------------------------------------

gotoxy:
                        pha
                        stx     temp
                        tya
                        asl     a
                        asl     a
                        asl     a
                        asl     a
                        asl     a
                        and     #$E0
                        ora     temp
                        sta     $2116
                        tya
                        lsr     a
                        lsr     a
                        lsr     a
                        and     #$03
                        sta     $2117
                        pla
                        rts


printhexb:
                        php
                        sep     #$30

                        jsr     gotoxy

                        pha
                        lsr     a
                        lsr     a
                        lsr     a
                        lsr     a
                        and     #$0F
                        tax
                        lda.w   hextable,x
                        sta     $2118
                        stz     $2119

                        pla
                        and     #$0F
                        tax
                        lda.w   hextable,x
                        sta     $2118
                        stz     $2119

                        plp
                        rts


ppu_init:
                        stz     $4200   ; NMI and auto joypad reading off

                        stz     $4016   ; Clear joypad latch strobe
                        lda     #$C0    
                        sta     $4201   ; Set I/O port D7, D6 to inputs

                        lda     #$80    ; Screen off
                        sta     $2100   ; INIDISP
                        stz     $2101   ; OBJSEL
                        lda     #$01    ; Mode 1
                        sta     $2105   ; BGMODE
                        stz     $2106   ; MOSAIC

                        ; BG1SC @ $00000
                        ; BG2SC @ $02000
                        ; BG3SC @ $04000
                        ; BG4SC @ $06000
                        lda     #$00
                        sta     $2107
                        lda     #$10
                        sta     $2108
                        lda     #$20
                        sta     $2109
                        lda     #$30
                        sta     $210A

                        ; BG1NBA @ $08000
                        ; BG2NBA @ $08000
                        ; BG3NBA @ $08000
                        ; BG4NBA @ $08000
                        lda     #$44
                        sta     $210B
                        lda     #$44
                        sta     $210C

                        stz     $210D   ; BG1HOFS
                        stz     $210D   ;
                        stz     $210E   ; BG1VOFS
                        stz     $210E   ;
                        stz     $210F   ; BG2HOFS
                        stz     $210F   ;
                        stz     $2110   ; BG2VOFS
                        stz     $2110   ;
                        stz     $2111   ; BG3HOFS
                        stz     $2111   ;
                        stz     $2112   ; BG3VOFS
                        stz     $2112   ;
                        stz     $2113   ; BG4HOFS
                        stz     $2113   ;
                        stz     $2114   ; BG4VOFS
                        stz     $2114   ;

                        lda     #$80    ; Byte access
                        sta     $2115   ; VMAIN

                        stz     $211A   ; M7SEL
                        stz     $211B   ; M7A
                        stz     $211B   
                        stz     $211C   ; M7B
                        stz     $211C   
                        stz     $211D   ; M7C
                        stz     $211D   
                        stz     $211E   ; M7D
                        stz     $211E   
                        stz     $211F   ; M7X
                        stz     $211F   
                        stz     $2120   ; M7Y
                        stz     $2120

                        stz     $2123   ; W12SEL
                        stz     $2124   ; W34SEL
                        stz     $2125   ; WOBJSEL
                        stz     $2126   ; WH0
                        stz     $2127   ; WH1
                        stz     $2128   ; WH2
                        stz     $2129   ; WH3
                        stz     $212A   ; WBGLOG
                        stz     $212B   ; WOBJLOG

                        lda     #$11    ; Enable BG1, OBJ
                        sta     $212C   ; TM
                        stz     $212D   ; TS
                        stz     $212E   ; TMW
                        stz     $212F   ; TSW

                        stz     $2130   ; CGWSEL
                        stz     $2131   ; CGADSUB
                        stz     $2132   ; COLDATA

                        stz     $2133   ; SETINI

                        stz     $4207   ; HTIMEL
                        stz     $4208   ; HTIMEH
                        stz     $4209   ; VTIMEL
                        stz     $420A   ; VTIMEH

                        lda     $213E   ; STAT77
                        lda     $213F   ; STAT78


                        rts

;----------------------------------------------------------------------------
; Native mode exception handlers
;----------------------------------------------------------------------------

__native_cop:
                        rti
__native_brk:
                        rti
__native_abort:
                        rti
__native_nmi:
                        rti
__native_unused:
                        rti
__native_irq:
                        rti

;----------------------------------------------------------------------------
; Emulation mode exception handlers
;----------------------------------------------------------------------------

__emu_cop:
                        rti
__emu_unused:
                        rti
__emu_abort:
                        rti
__emu_nmi:
                        rti
__emu_irq:
                        rti

;----------------------------------------------------------------------------
; Data
;----------------------------------------------------------------------------

font4:                  .incbin "font.4"
palette:                .incbin "cgram.bin"

                        .org    $7F00
hextable:               .db     "0123456789ABCDEF"

;----------------------------------------------------------------------------
; Cartridge header
;----------------------------------------------------------------------------

                        .org    $7FC0
                        .db     "SNES Sprite Test  "

                        .org    $7FD6
                        .db     $00
                        .db     $08
                        .db     $00
                        .db     $01
                        .db     $00
                        .db     $00
                        .dw     $0000
                        .dw     $0000

;----------------------------------------------------------------------------
; Native mode vector table
;----------------------------------------------------------------------------

                        .org    $7FE4
                        .dw     __native_cop
                        .dw     __native_brk
                        .dw     __native_abort
                        .dw     __native_nmi
                        .dw     __native_unused ; Unused
                        .dw     __native_irq

;----------------------------------------------------------------------------
; Emulation mode vector table
;----------------------------------------------------------------------------

                        .org    $7FF4
                        .dw     __emu_cop
                        .dw     __emu_unused    ; Unused
                        .dw     __emu_abort
                        .dw     __emu_nmi
                        .dw     __emu_reset
                        .dw     __emu_irq
        
;----------------------------------------------------------------------------
; Data
;----------------------------------------------------------------------------
