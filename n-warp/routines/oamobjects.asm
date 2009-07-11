.Section "oam objects" superfree
;relative pointers to objects:
ObjectLUT:
	.dw (Object000-ObjectLUT)
	.dw (Object001-ObjectLUT)
	.dw (Object002-ObjectLUT)
	.dw (Object003-ObjectLUT)
	.dw (Object004-ObjectLUT)
	.dw (Object005-ObjectLUT)
	.dw (Object006-ObjectLUT)
	.dw (Object007-ObjectLUT)
	.dw (Object008-ObjectLUT)
	.dw (Object009-ObjectLUT)
	.dw (Object010-ObjectLUT)
	.dw (Object011-ObjectLUT)
	.dw (Object012-ObjectLUT)
	.dw (Object013-ObjectLUT)
	.dw (Object014-ObjectLUT)
	.dw (Object015-ObjectLUT)
	.dw (Object016-ObjectLUT)
	.dw (Object017-ObjectLUT)
	.dw (Object018-ObjectLUT)
	.dw (Object019-ObjectLUT)
	.dw (Object020-ObjectLUT)
	.dw (Object021-ObjectLUT)
	.dw (Object022-ObjectLUT)
	.dw (Object023-ObjectLUT)
	.dw (Object024-ObjectLUT)
	.dw (Object025-ObjectLUT)
	.dw (Object026-ObjectLUT)
	.dw (Object027-ObjectLUT)
	.dw (Object028-ObjectLUT)
	.dw (Object029-ObjectLUT)
	.dw (Object030-ObjectLUT)
	.dw (Object031-ObjectLUT)
	.dw (Object032-ObjectLUT)
	.dw (Object033-ObjectLUT)
	.dw (Object034-ObjectLUT)
	.dw (Object035-ObjectLUT)
	.dw (Object036-ObjectLUT)
	.dw (Object037-ObjectLUT)	
	.dw (Object038-ObjectLUT)
	.dw (Object039-ObjectLUT)
	.dw (Object040-ObjectLUT)
	.dw (Object041-ObjectLUT)
	.dw (Object042-ObjectLUT)
	.dw (Object043-ObjectLUT)
	.dw (Object044-ObjectLUT)			
	.dw (Object045-ObjectLUT)
	.dw (Object046-ObjectLUT)
	.dw (Object047-ObjectLUT)
	.dw (Object048-ObjectLUT)
	.dw (Object049-ObjectLUT)
	.dw (Object050-ObjectLUT)
	.dw (Object051-ObjectLUT)
	.dw (Object052-ObjectLUT)
	.dw (Object053-ObjectLUT)
	.dw (Object054-ObjectLUT)


								
Object000:
	.db %11011010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db $02			;number of subroutine. executed if bit6 of object type is set
	.db 0			;tileset to use
	.db $00			;current "frame" of tileset to display
	.db $08			;starting tile in vram
	.db %00110110		;palette and config
	.dw $80			;x position
	.dw $80			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 0			;palette number to upload for this sprite
	.dw 0			;object number

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 7			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable



;cpu usage indicator
Object001:
	.db %11101000	;object type designation
					;bit0=X position sign of sprite(usually 0)
					;bit1=Object size flag
					;bit2=collidable
					;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
					;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
					;bit5=bg-bound? if set, this object must move in accordance with background layer 0
					;bit6=object active? if set, this object is active and needs to be drawn. if clear, this sprite doesnt need to be drawn, but must be processed, anyway
					;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00100000	;object type designation 2
					;bit7=pseudo 3d sprite that needs to be moved according to z-value when background moves
					;bit6=don't upload tiles for this sprite. useful for stuff like particles and such where lots of sprites share the same tiles.
					;bit5=don't upload palette for this sprite.
					;bits0-3: current position in vector angle LUT (didn't fit anywhere else)
	
	.db 18			;number of subroutine. executed if bit6 of object type is set
	.db 63			;tileset to use
	.db $00			;current "frame" of tileset to display
	.db $ff			;starting tile in vram
	.db %00110001	;palette and config
	.dw 1*16			;x position
	.dw 1			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 0			;palette number to upload for this sprite
	.dw 0			;object number

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. bit0-2:subpixel speed. bit3-5:pixel speed.  bit7 set: target speed met  
	.db 0			;vector target speed. bit0-2:subpixel speed target. bit3-5:pixel speed target. bit6,7: movement type(direct, linear slow, linear fast, smooth)
	.db 0			;vector direction. bit0-5:direction.0=facing up. bit6=turning direction.(set=clockwise) msb set=target direction met.
	.db 0			;vector target dir. bit0-5:target direction.0=facing up.  bit6,7: movement type(direct, linear slow, linear fast, smooth)
	.db 0			;subpixel buffer. bit0-2:vector speed subpixel buffer. bit3-7: direction turn speed sub-pixel buffer. 
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object002:
	.db %11010110		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 3			;number of subroutine. executed if bit6 of object type is set
	.db 9			;tileset to use
	.db $00			;current "frame" of tileset to display
	.db $44			;starting tile in vram
	.db %00111000		;palette and config
	.dw 400			;x position
	.dw 400			;y position
	.db 0			;current frame in animation list
	.db 7			;object command list to use	
	.db 0			;object offset in object list.
	.db 5			;palette number to upload for this sprite
	.dw 0			;object number

	.db 16			;x-displacement
	.db 56			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 8			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object003:
	.db %11010010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 3			;number of subroutine. executed if bit6 of object type is set
	.db 9			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db $48			;starting tile in vram
	.db %00111000		;palette and config
	.dw 400			;x position
	.dw 432			;y position
	.db 0			;current frame in animation list
	.db 5			;object command list to use	
	.db 0			;object offset in object list.
	.db 5			;palette number to upload for this sprite
	.dw 0			;object number

	.db 16			;x-displacement
	.db 56			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 6			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;male walking player 1
Object004:
	.db %11011110		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 0			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db 0			;starting tile in vram
	.db %00010010		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 0			;palette number to upload for this sprite
	.dw 0			;object number (port1,joy1)

	.db 19			;x-displacement
	.db 22			;y-displacement
	.db 32			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;direction 0=down 1=up 2=left 3=right
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db MaleHitpoints	;hp - health
	.db 0			;spare variable
	.db 0			;spare variable

;male player 2
Object005:
	.db %11011110		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 0			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db 4			;starting tile in vram
	.db %00010100		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 1			;palette number to upload for this sprite
	.dw 1			;object number (port2,joy1)

	.db 19			;x-displacement
	.db 22			;y-displacement
	.db 32			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement).
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db MaleHitpoints	;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
;male player 3
Object006:
	.db %11011110		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 0			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db 8			;starting tile in vram
	.db %00010110		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 2			;palette number to upload for this sprite
	.dw 2			;object number (port2,joy1)

	.db 19			;x-displacement
	.db 22			;y-displacement
	.db 32			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db MaleHitpoints	;hp - health
	.db 0			;spare variable
	.db 0			;spare variable

;male player 4
Object007:
	.db %11011110		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 0			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $c			;starting tile in vram
	.db %00011000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 3			;palette number to upload for this sprite
	.dw 3			;object number (port2,joy1)

	.db 19			;x-displacement
	.db 22			;y-displacement
	.db 32			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db MaleHitpoints	;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
;male player 5
Object008:
	.db %11011110		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 0			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $40			;starting tile in vram
	.db %00011010		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 4			;palette number to upload for this sprite
	.dw 4			;object number (port2,joy1)

	.db 19			;x-displacement
	.db 22			;y-displacement
	.db 32			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db MaleHitpoints	;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
;male player 6
Object009:
	.db %11011110		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 0			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $44			;starting tile in vram
	.db %00011100		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 5			;palette number to upload for this sprite
	.dw 5			;object number (port2,joy1)

	.db 19			;x-displacement
	.db 22			;y-displacement
	.db 32			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db MaleHitpoints	;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
;male player 7
Object010:
	.db %11011110		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 0			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $48			;starting tile in vram
	.db %00011110		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 6			;palette number to upload for this sprite
	.dw 6			;object number (port2,joy1)

	.db 19			;x-displacement
	.db 22			;y-displacement
	.db 32			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db MaleHitpoints	;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
;male player 8
Object011:
	.db %11011110		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 0			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $4c			;starting tile in vram
	.db %00010000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 7			;palette number to upload for this sprite
	.dw 7			;object number (port2,joy1)

	.db 19			;x-displacement
	.db 22			;y-displacement
	.db 32			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db MaleHitpoints	;hp - health
	.db 0			;spare variable
	.db 0			;spare variable

;healthmeter player 1 
Object012:
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 9			;number of subroutine. executed if bit6 of object type is set
	.db 17			;tileset to use
	.db 8			;current "frame" of tileset to display
	.db $80			;starting tile in vram
	.db %00110010		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 0			;palette number to upload for this sprite
	.dw 8			;object number (port1,joy1)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;direction 0=down 1=up 2=left 3=right
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 6			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;healthmeter player 2
Object013:
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 9			;number of subroutine. executed if bit6 of object type is set
	.db 17			;tileset to use
	.db 8			;current "frame" of tileset to display
	.db $84			;starting tile in vram
	.db %00110100		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 1			;palette number to upload for this sprite
	.dw 9			;object number (port2,joy1)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 6			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
;healthmeter player 3
Object014:
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 9			;number of subroutine. executed if bit6 of object type is set
	.db 17			;tileset to use
	.db 8			;current "frame" of tileset to display
	.db $88			;starting tile in vram
	.db %00110110		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 2			;palette number to upload for this sprite
	.dw 10			;object number (port2,joy1)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 6			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;healthmeter player 4
Object015:
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 9			;number of subroutine. executed if bit6 of object type is set
	.db 17			;tileset to use
	.db 8			;current "frame" of tileset to display
	.db $8c			;starting tile in vram
	.db %00111000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 3			;palette number to upload for this sprite
	.dw 11			;object number (port2,joy1)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 6			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
;healthmeter player 5
Object016:
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 9			;number of subroutine. executed if bit6 of object type is set
	.db 17			;tileset to use
	.db 8			;current "frame" of tileset to display
	.db $c0			;starting tile in vram
	.db %00111010		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 4			;palette number to upload for this sprite
	.dw 12			;object number (port2,joy1)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 6			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
;healthmeter player 6
Object017:
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 9			;number of subroutine. executed if bit6 of object type is set
	.db 17			;tileset to use
	.db 8			;current "frame" of tileset to display
	.db $c4			;starting tile in vram
	.db %00111100		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 5			;palette number to upload for this sprite
	.dw 13			;object number (port2,joy1)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 6			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
;healthmeter player 7
Object018:
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 9			;number of subroutine. executed if bit6 of object type is set
	.db 17			;tileset to use
	.db 8			;current "frame" of tileset to display
	.db $c8			;starting tile in vram
	.db %00111110		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 6			;palette number to upload for this sprite
	.dw 14			;object number (port2,joy1)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 6			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
;healthmeter player 8
Object019:
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 9			;number of subroutine. executed if bit6 of object type is set
	.db 17			;tileset to use
	.db 8			;current "frame" of tileset to display
	.db $cc			;starting tile in vram
	.db %00110000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 2			;object command list to use	
	.db 0			;object offset in object list.
	.db 7			;palette number to upload for this sprite
	.dw 15			;object number (port2,joy1)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 6			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable


Object020:
;mond 1
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 20			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $00			;starting tile in vram
	.db %00110000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 8			;palette number to upload for this sprite
	.dw 16			;object number (mon)

	.db 0			;x-displacement
	.db 6			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object021:
;mond 2
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 20			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db $08			;starting tile in vram
	.db %00110000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 8			;palette number to upload for this sprite
	.dw 16			;object number (mon)

	.db 0			;x-displacement
	.db 6			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object022:
;mond 3
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 20			;tileset to use
	.db 2			;current "frame" of tileset to display
	.db $80			;starting tile in vram
	.db %00110000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 8			;palette number to upload for this sprite
	.dw 16			;object number (mon)

	.db 0			;x-displacement
	.db 6			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object023:
;mond 3
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 20			;tileset to use
	.db 3			;current "frame" of tileset to display
	.db $88			;starting tile in vram
	.db %00110000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 8			;palette number to upload for this sprite
	.dw 16			;object number (mon)

	.db 0			;x-displacement
	.db 6			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object024:
;mond 4
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 20			;tileset to use
	.db 3			;current "frame" of tileset to display
	.db $88			;starting tile in vram
	.db %01110000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 8			;palette number to upload for this sprite
	.dw 16			;object number (mon)

	.db 0			;x-displacement
	.db 6			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable


Object025:
;mond 5
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 20			;tileset to use
	.db 5			;current "frame" of tileset to display
	.db $08			;starting tile in vram
	.db %00110001		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 8			;palette number to upload for this sprite
	.dw 16			;object number (mon)

	.db 0			;x-displacement
	.db 6			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable


Object026:
;mond 6
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 20			;tileset to use
	.db 6			;current "frame" of tileset to display
	.db $80			;starting tile in vram
	.db %00110001		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 8			;palette number to upload for this sprite
	.dw 16			;object number (mon)

	.db 0			;x-displacement
	.db 6			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable



Object027:
;mond 7
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 20			;tileset to use
	.db 7			;current "frame" of tileset to display
	.db $88			;starting tile in vram
	.db %00110001		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 8			;palette number to upload for this sprite
	.dw 16			;object number (mon)

	.db 0			;x-displacement
	.db 6			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable


Object028:
;mond corona 1
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 21			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $80			;starting tile in vram
	.db %00001000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 9			;palette number to upload for this sprite
	.dw 17			;object number (mond corona)

	.db 5			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	

Object029:
;mond corona 2
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 21			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db $00			;starting tile in vram
	.db %00001001		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 9			;palette number to upload for this sprite
	.dw 17			;object number (mond corona)

	.db 5			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable


Object030:
;mond corona 3
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 21			;tileset to use
	.db 2			;current "frame" of tileset to display
	.db $08			;starting tile in vram
	.db %00001001		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 9			;palette number to upload for this sprite
	.dw 17			;object number (mond corona)

	.db 5			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object031:
;mond corona 4
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 21			;tileset to use
	.db 2			;current "frame" of tileset to display
	.db $08			;starting tile in vram
	.db %10001001		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 9			;palette number to upload for this sprite
	.dw 17			;object number (mond corona)

	.db 5			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object032:
;mond corona 5
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 21			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $80			;starting tile in vram
	.db %10001000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 9			;palette number to upload for this sprite
	.dw 17			;object number (mond corona)

	.db 5			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object033:
;mond corona 6
	.db %11001010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 11			;number of subroutine. executed if bit6 of object type is set
	.db 21			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db $00			;starting tile in vram
	.db %10001001		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 9			;palette number to upload for this sprite
	.dw 17			;object number (mond corona)

	.db 5			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object034:
;mainchara battle steady standing still, view from behind, top:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %10000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 22			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db 0			;starting tile in vram
	.db %00110000		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 15			;object command list to use	
	.db 0			;object offset in object list.
	.db 10			;palette number to upload for this sprite
	.dw OamTypeMainCharaCtrl		;object number

	.db 16			;x-displacement
	.db 10			;y-displacement
	.db 2			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 7			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;mainchara battle steady standing still, view from behind, top:
Object035:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %10000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 22			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db 4			;starting tile in vram
	.db %00110000		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 15			;object command list to use	
	.db 0			;object offset in object list.
	.db 10			;palette number to upload for this sprite
	.dw OamTypeMainCharaCtrl		;object number

	.db 16			;x-displacement
	.db 10			;y-displacement
	.db 2			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 7			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object036:
;mainchara battle steady standing still, view from behind, top:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %11000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 22			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db 0			;starting tile in vram
	.db %00110010		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 15			;object command list to use	
	.db 0			;object offset in object list.
	.db 11			;palette number to upload for this sprite
	.dw OamTypeMainCharaCtrl		;object number

	.db 16			;x-displacement
	.db 10			;y-displacement
	.db 2			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 7			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;mainchara battle steady standing still, view from behind, top:
Object037:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %11000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 22			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db 4			;starting tile in vram
	.db %00110010		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 15			;object command list to use	
	.db 0			;object offset in object list.
	.db 11			;palette number to upload for this sprite
	.dw OamTypeMainCharaCtrl		;object number

	.db 16			;x-displacement
	.db 10			;y-displacement
	.db 2			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 7			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object038:
;mainchara battle steady standing still, view from behind, top:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %11000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 22			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db 0			;starting tile in vram
	.db %00111010		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 15			;object command list to use	
	.db 0			;object offset in object list.
	.db 12			;palette number to upload for this sprite
	.dw OamTypeMainCharaCtrl		;object number

	.db 16			;x-displacement
	.db 10			;y-displacement
	.db 2			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 7			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;mainchara battle steady standing still, view from behind, top:
Object039:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %11000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 22			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db 4			;starting tile in vram
	.db %00111010		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 15			;object command list to use	
	.db 0			;object offset in object list.
	.db 12			;palette number to upload for this sprite
	.dw OamTypeMainCharaCtrl		;object number

	.db 16			;x-displacement
	.db 10			;y-displacement
	.db 2			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 7			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;small mainchara battle steady standing still, view from behind:
Object040:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %10000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 23			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db 8			;starting tile in vram
	.db %00111100		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 16			;object command list to use	
	.db 0			;object offset in object list.
	.db 13			;palette number to upload for this sprite
	.dw OamTypeMainCharaCtrl		;object number

	.db 16			;x-displacement
	.db 10			;y-displacement
	.db 2			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 7			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;small mainchara battle steady standing still, view from behind:
Object041:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %11000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 23			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db 8			;starting tile in vram
	.db %00111110		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 16			;object command list to use	
	.db 0			;object offset in object list.
	.db 14			;palette number to upload for this sprite
	.dw OamTypeMainCharaCtrl		;object number

	.db 16			;x-displacement
	.db 10			;y-displacement
	.db 2			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 7			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

Object042:
;dai
	.db %11100010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 2			;number of subroutine. executed if bit6 of object type is set
	.db 24			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $00			;starting tile in vram
	.db %00111000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 15			;palette number to upload for this sprite
	.dw 18			;object number (dai)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 64			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable


Object043:
;saku
	.db %11100010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 2			;number of subroutine. executed if bit6 of object type is set
	.db 24			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db $08			;starting tile in vram
	.db %00111000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 15			;palette number to upload for this sprite
	.dw 18			;object number (dai)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 64			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object044:
;sen
	.db %11100010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 2			;number of subroutine. executed if bit6 of object type is set
	.db 24			;tileset to use
	.db 2			;current "frame" of tileset to display
	.db $80			;starting tile in vram
	.db %00111000		;palette and config
	.dw $ff			;x position
	.dw $ff			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 15			;palette number to upload for this sprite
	.dw 18			;object number (dai)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 64			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object045:
;explosion 1 master
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 2			;number of subroutine. executed if bit6 of object type is set
	.db 25			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $00			;starting tile in vram
	.db %00110011		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 18			;object command list to use	
	.db 0			;object offset in object list.
	.db 16			;palette number to upload for this sprite
	.dw 18			;object number (dai)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 1			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object046:
;explosion 2
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 2			;number of subroutine. executed if bit6 of object type is set
	.db 25			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db $08			;starting tile in vram
	.db %00110011		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 18			;object command list to use	
	.db 0			;object offset in object list.
	.db 16			;palette number to upload for this sprite
	.dw 18			;object number (dai)

	.db 64			;x-displacement
	.db 0			;y-displacement
	.db 1			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object047:
;explosion 3
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 2			;number of subroutine. executed if bit6 of object type is set
	.db 25			;tileset to use
	.db 2			;current "frame" of tileset to display
	.db $80			;starting tile in vram
	.db %00110011		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 18			;object command list to use	
	.db 0			;object offset in object list.
	.db 16			;palette number to upload for this sprite
	.dw 18			;object number (dai)

	.db 0			;x-displacement
	.db 64			;y-displacement
	.db 1			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object048:
;explosion 4
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 2			;number of subroutine. executed if bit6 of object type is set
	.db 25			;tileset to use
	.db 3			;current "frame" of tileset to display
	.db $88			;starting tile in vram
	.db %00110011		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 18			;object command list to use	
	.db 0			;object offset in object list.
	.db 16			;palette number to upload for this sprite
	.dw 18			;object number (dai)

	.db 64			;x-displacement
	.db 64			;y-displacement
	.db 1			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object049:
;gra -g
	.db %11010010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 2			;number of subroutine. executed if bit6 of object type is set
	.db 27			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $00			;starting tile in vram
	.db %00110000		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 19			;object command list to use	
	.db 0			;object offset in object list.
	.db 18			;palette number to upload for this sprite
	.dw 19			;object number (graaarrr)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 1			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
Object050:
;gra -gra
	.db %11010010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 2			;number of subroutine. executed if bit6 of object type is set
	.db 26			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $08			;starting tile in vram
	.db %00110010		;palette and config
	.dw $10			;x position
	.dw $10			;y position
	.db 0			;current frame in animation list
	.db 20			;object command list to use	
	.db 0			;object offset in object list.
	.db 17			;palette number to upload for this sprite
	.dw 19			;object number (graaarrr)

	.db 0			;x-displacement
	.db 6			;y-displacement
	.db 1			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable	

Object051:
;winmark
	.db %11000000		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 60			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $40			;starting tile in vram
	.db %00110101	;palette and config
	.dw $20			;x position
	.dw $20			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 19			;palette number to upload for this sprite
	.dw 20			;object number (graaarrr)

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable		

;small nwarp daisakusen logo, credits, left
Object052:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 61			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $40			;starting tile in vram
	.db %00111111	;palette and config
	.dw $70*16			;x position
	.dw $0			;y position
	.db 0			;current frame in animation list
	.db 24			;object command list to use	
	.db 0			;object offset in object list.
	.db 20			;palette number to upload for this sprite
	.dw 21			;object number

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;small nwarp daisakusen logo, credits, right
Object053:
	.db %11110010		;object type designation
				;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
				;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
				;bit5=screen-bound? if set, this object must move in accordance with background layer 0
				;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
				;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00000000		;object type designation 2
	.db 0			;number of subroutine. executed if bit6 of object type is set
	.db 61			;tileset to use
	.db 1			;current "frame" of tileset to display
	.db $48			;starting tile in vram
	.db %00111111	;palette and config
	.dw $b0*16		;x position
	.dw $0			;y position
	.db 0			;current frame in animation list
	.db 24			;object command list to use	
	.db 0			;object offset in object list.
	.db 20			;palette number to upload for this sprite
	.dw 21			;object number

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db 0			;vector speed. 3bit + 3bit sub-pixel accuracy. msb set=target speed met.(speed=0: don't calc vector movement)
	.db 0			;void
	.db 0			;void
	.db 0			;void
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;hp - health
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

;8x8 vector testsprite particle
Object054:
	.db %11101000		;object type designation
						;bit3=subroutine? if set, this object has its own subroutine that must be executed every frame
						;bit4=animate? if set, this object is animated(a special table for each object specifies the exact animation with commands for tileloading, waiting, animation loop etc)
						;bit5=screen-bound? if set, this object must move in accordance with background layer 0
						;bit6=object active? if set, this object is active and needs to be processed. if clear, this sprite doesnt need to be processed
						;bit7=object present? if set, this slot has an object. if clear, its considered empty and can be overwritten
	.db %00110000		;object type designation 2
	.db 17			;number of subroutine. executed if bit6 of object type is set
	.db 62			;tileset to use
	.db 0			;current "frame" of tileset to display
	.db $b0			;starting tile in vram
	.db %00110001	;palette and config
	.dw $80			;x position
	.dw $60			;y position
	.db 0			;current frame in animation list
	.db 0			;object command list to use	
	.db 0			;object offset in object list.
	.db 21			;palette number to upload for this sprite
	.dw 0			;object number

	.db 0			;x-displacement
	.db 0			;y-displacement
	.db 0			;z-displacement
	.db 0			;animation repeat counter for nop
	.db 0			;collision subroutine
	.db $78			;x-speed. center is $80
	.dw $ffd0			;y-speed
	.db 2			;gravity
	.db 80			;lifecounter
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable
	.db 0			;spare variable

.ends