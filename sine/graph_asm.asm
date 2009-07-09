.include "hdr.asm"

.ramsection ".registers" bank 0 slot 1
move_sine dsb 5
.ends

.section "graphics" superfree

.macro bankin
    phb
    lda.w #0
    pha
    plb
    plb
.endm

.macro bankout
    plb
.endm


.accu 16
.index 16
.16bit
; void settiles(unsigned int b, unsigned char *p1, unsigned int size) {
settiles:
    bankin
    LDA.L sine_do_copy; $0229;
    AND #$003F;
    ASL
    ASL
    ASL
    TAX

    LDA #$0000;
    STA.l sine_dma_transfers + 7,X;	// assign transfer type
   
    ; tile data
    LDA 7,s ;p1 lo
    STA.l sine_dma_transfers + 0,X
    LDA 9,s ;p1 hi
    STA.l sine_dma_transfers + 2,X
    LDA 5,s ;b
    INA;
    XBA;
    ASL;
    ASL;
    ASL;
    ASL;
    STA.l sine_dma_transfers + 3,X;
    LDA 11,s ;size
    STA.l sine_dma_transfers + 5,X;

    ; signal the nmi to copy data to vram
    lda.l sine_do_copy
    ina
    sta.l sine_do_copy
    ;INC $0229;
    bankout
    rtl

;void setmap(unsigned int b, unsigned char *p1) {
setmap:
    bankin
    LDA.L sine_do_copy; $0229;
    AND #$003F;
    ASL
    ASL
    ASL
    TAX

    LDA #$0000;
    STA.l sine_dma_transfers + 7,X;	// assign transfer type
   
    ; tile data
    LDA 7,s ;p1 lo
    STA.l sine_dma_transfers + 0,X
    LDA 9,s ;p1 hi
    STA.l sine_dma_transfers + 2,X
    LDA 5,s ;b
    XBA;
    ASL;
    ASL;
    STA.l sine_dma_transfers + 3,X
    LDA #$0800
    STA.l sine_dma_transfers + 5,X

    ; signal the nmi to copy data to vram
    lda.l sine_do_copy
    ina
    sta.l sine_do_copy
    ;INC $0229;
    bankout
    rtl

;void setpalette(unsigned char *pal) {
setpalette:
    bankin
    ; color data
    LDA #((:sine_palette << 8) + $54);
    STA.b move_sine ;$0014;
    lda 7,s ; pal hi
    STA.b move_sine + 2 ; $0016;
    LDA #$006B;
    STA.b move_sine + 3 ; $0017;
    lda 5,s ; pal lo
    tax
    LDY #sine_palette ;$0600;
    LDA #$01FF;
    JSL move_sine ;$7E0014;

    LDA #$0040;
    ora.l sine_do_copy
    sta.l sine_do_copy
    ;TSB $0229;	signal NMI to copy palette table
    bankout
    rtl

;void setsprite(unsigned int s, unsigned char x, unsigned char y, unsigned char t, unsigned char p) {
setsprite:
    bankin
    LDA 5,s ;s
    ASL
    ASL
    TAX

    SEP #$20
    LDA 7,s ;x
    STA.l sine_oam_table1,X
    LDA 8,s ;y
    STA.l sine_oam_table1 + 1,X
    LDA 9,s ;t
    STA.l sine_oam_table1 + 2,X
    LDA 10,s ;p
    STA.l sine_oam_table1 + 3,X
    REP #$20

    LDA #$0080
    ora.l sine_do_copy
    sta.l sine_do_copy
    ;TSB $0229	; signal NMI to copy sprite table
    bankout
    rtl

;void resettimer() {
resettimer:
  bankin
    LDA #$0001;
    ora.l sine_timer_enabled
    sta.l sine_timer_enabled
    ;TSB $0200;	// turn timer on
    lda.w #0
    STA.L sine_timers;	// reset timer
  bankout
  rtl

;void sync(unsigned int d) {
sync:
  bankin
-   LDA.L sine_timers   ; compare timer
    CMP 5,s ;d
    BCC -
  bankout
  rtl

.ends
