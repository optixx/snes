;== Include memorymap, header info, and SNES initialization routines
.INCLUDE "header.inc"
.INCLUDE "init.inc"

;========================
; Start
;========================

.BANK 0 SLOT 0
.ORG 0
.SECTION "MainCode"

Start:
    InitSNES            ; Init Snes :)

    stz $2121           ; Edit color 0 - snes' screen color
                        ; you can write it in binary or hex
    lda #%00011111      ; binary is more visual, but if you
    sta $2122           ; wanna be cool, use hex ;)
    stz $2122           ; second byte is 0, so we write a 0

    lda #$0F            ; = 00001111
    sta $2100           ; Turn on screen, full brightness
    

forever:
    jmp forever

.ENDS
