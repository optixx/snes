.Section "Zscrolllut" superfree
;this is the pseudo-3d lookup table that defines how much to scroll each scanline depending on that scanlines z-value.
;has 6 extra bits of precision for smooth scrolling.(all scroll values are shifted right 6 times before being written to scroll regs via hdma)
;z-value 0:nearest/fastest scroll. z-value 255:farthest/slowest scroll

BattleZScrollLUT:


.dw 64
.dw 63
.dw 62
.dw 61
.dw 60

.dw 59
.dw 58
.dw 57
.dw 56
.dw 55
.dw 54
.dw 53
.dw 52
.dw 51
.dw 50

.dw 49
.dw 48
.dw 47
.dw 46
.dw 45
.dw 44
.dw 43
.dw 42
.dw 41
.dw 40

.dw 39
.dw 38
.dw 37
.dw 36
.dw 35
.dw 34
.dw 33
.dw 32
.dw 31
.dw 30

.dw 29
.dw 28
.dw 27
.dw 26
.dw 25
.dw 24
.dw 23
.dw 22
.dw 21
.dw 20

.dw 19
.dw 18
.dw 17
.dw 16
.dw 15
.dw 14
.dw 13
.dw 12
.dw 11
.dw 10

.dw 09
.dw 08
.dw 07
.dw 06
.dw 05
.dw 04
.dw 03
.dw 02
.dw 01
.dw 00




BattleZScrollLUTSprites:

.dw 64/4
.dw 63/4
.dw 62/4
.dw 61/4
.dw 60/4

.dw 59/4
.dw 58/4
.dw 57/4
.dw 56/4
.dw 55/4
.dw 54/4
.dw 53/4
.dw 52/4
.dw 51/4
.dw 50/4

.dw 49/4
.dw 48/4
.dw 47/4
.dw 46/4
.dw 45/4
.dw 44/4
.dw 43/4
.dw 42/4
.dw 41/4
.dw 40/4

.dw 39/4
.dw 38/4
.dw 37/4
.dw 36/4
.dw 35/4
.dw 34/4
.dw 33/4
.dw 32/4
.dw 31/4
.dw 30/4

.dw 29/4
.dw 28/4
.dw 27/4
.dw 26/4
.dw 25/4
.dw 24/4
.dw 23/4
.dw 22/4
.dw 21/4
.dw 20/4

.dw 19/4
.dw 18/4
.dw 17/4
.dw 16/4
.dw 15/4
.dw 14/4
.dw 13/4
.dw 12/4
.dw 11/4
.dw 10/4

.dw 09/4
.dw 08/4
.dw 07/4
.dw 06/4
.dw 05/4
.dw 04/4
.dw 03/4
.dw 02/4
.dw 01/4
.dw 00/4
.ends
