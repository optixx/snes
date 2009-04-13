;:ts=8
R0	equ	1
R1	equ	5
R2	equ	9
R3	equ	13
	code
	xdef	__initInternalRegisters
	func
__initInternalRegisters:
	longa	on
	longi	on
	stz	|__characterLocation
	stz	|__characterLocation+2
	stz	|__characterLocation+4
	stz	|__characterLocation+6
	jsr	__initDebugMap
	rts
L2	equ	0
L3	equ	1
	ends
	efunc
	code
	xdef	__preInit
	func
__preInit:
	longa	on
	longi	on
	rts
L5	equ	0
L6	equ	1
	ends
	efunc
	code
	xdef	__main
	func
__main:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L8
	tcs
	phd
	tcd
	jsr	__initInternalRegisters
	pea	#<$0
	pea	#<$0
	pea	#<$1000
	jsr	__setTileMapLocation
	pea	#<$0
	pea	#<$2000
	jsr	__setCharacterLocation
	pea	#<$1be0
	pea	#<$2000
	lda	#<__title_pic
	pha
	jsr	__VRAMLoad
	pea	#<$800
	pea	#<$1000
	lda	#<__title_map
	pha
	jsr	__VRAMLoad
	pea	#<$100
	pea	#<$0
	lda	#<__title_pal
	pha
	jsr	__CGRAMLoad
	sep	#$20
	longa	off
	lda	#$1
	sta	|8453
	sta	|8492
	dea
	sta	|8493
	lda	#$f
	sta	|8448
	rep	#$20
	longa	on
	stz	|__currentScrollEvent
	stz	|__scrollValue
	jsr	__initEvents
	jsr	__enablePad
	pea	#<$1
	pea	#<__NMIReadPad
	jsr	__addEvent
L10001:
	jsr	__waitForVBlank
	lda	|__pad1
	bit	#$2
	beq	L10003
	lda	|__currentScrollEvent
	bne	L10003
	pea	#<$1
	pea	#<__scrollLeft
	jsr	__addEvent
	sta	|__currentScrollEvent
L10003:
	lda	|__pad1
	bit	#$1
	beq	L10005
	lda	|__currentScrollEvent
	beq	L10005
	lda	|__currentScrollEvent
	pha
	jsr	__removeEvent
	stz	|__currentScrollEvent
L10005:
	lda	|__pad1
	bit	#$8
	beq	L10007
	pea	#<$1
	pea	#<__fadeOut
	jsr	__addEvent
	pea	#<$1
	pea	#<__mosaicIn
	jsr	__addEvent
L10007:
	lda	|__pad1
	bit	#$4
	beq	L10008
	pea	#<$1
	pea	#<__fadeIn
	jsr	__addEvent
	pea	#<$1
	pea	#<__mosaicOut
	jsr	__addEvent
L10008:
	lda	|__pad1
	bit	#$10
	beq	L10001
	jsr	__debug
	bra	L10001
L8	equ	0
L9	equ	1
	ends
	efunc
	code
	xdef	__IRQHandler
	func
__IRQHandler:
	longa	on
	longi	on
	rts
L17	equ	0
L18	equ	1
	ends
	efunc
	code
	xdef	__NMIHandler
	func
__NMIHandler:
	longa	on
	longi	on
	jsr	__processEvents
	rts
L20	equ	0
L21	equ	1
	ends
	efunc
	xref	__debug
	xref	__initDebugMap
	xref	__CGRAMLoad
	xref	__VRAMLoad
	xref	__setCharacterLocation
	xref	__setTileMapLocation
	xref	__waitForVBlank
	xref	__scrollLeft
	xref	__NMIReadPad
	xref	__mosaicIn
	xref	__mosaicOut
	xref	__fadeIn
	xref	__fadeOut
	xref	__processEvents
	xref	__removeEvent
	xref	__addEvent
	xref	__initEvents
	xref	__enablePad
	udata
	xdef	__scrollValue
__scrollValue
	ds	2
	ends
	udata
	xdef	__currentScrollEvent
__currentScrollEvent
	ds	2
	ends
	udata
	xdef	__pad1
__pad1
	ds	2
	ends
	xref	__characterLocation
	xref	__title_pal
	xref	__title_pic
	xref	__title_map
