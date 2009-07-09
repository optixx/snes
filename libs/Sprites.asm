;------------------------------------------------------------------------
;--  Sprite Initialization
;------------------------------------------------------------------------

;== Temporary Sprite Table Buffer ($0400-$061F) ==
.DEFINE SpriteTab1	$0000
.DEFINE SpriteTab2	$0200

;== Sprite Table 1 Offsets ==
.DEFINE spx	   		0
.DEFINE spy	   		1
.DEFINE sptile 		2
.DEFINE spstatus		3

;== Sprite Character Offsets ==
.DEFINE sp1			4
.DEFINE sp2			8


.BANK 0 SLOT 0
.ORG ROM_OFFSET
.SECTION "SpriteInit" SEMIFREE

;============================================================================
; SpriteInit -- Clears the sprite tables
;----------------------------------------------------------------------------
; Modifies: A
;----------------------------------------------------------------------------

SpriteInit:
	PHP
	REP #$30		;16bit mem/A, 16 bit X/Y

;********* Sprite Table 1 Clear
	ldx #$0000
	lda #$01       
_offscreen:
	sta SpriteTab1, x
	inx
	inx
	inx
	inx
	cpx #$0200
	bne _offscreen

;********* Sprite Table 2 Clear
	ldx #$0000
	lda #$5555
_clr:
	sta SpriteTab2, x
	inx
	inx
	cpx #$0020
	bne _clr	

	SEP #$20
	PLP
	RTS

;----------------------------------------------------------------------------

.ENDS
