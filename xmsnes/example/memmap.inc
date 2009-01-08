.MEMORYMAP
  SLOTSIZE $8000
  DEFAULTSLOT 0
  SLOT 0 $8000
  SLOT 1 $0000
  SLOT 2 $2000
  SLOTSIZE $40000
  SLOT 3 $8000
.ENDME

.ROMBANKMAP
BANKSTOTAL 3
BANKSIZE $8000
BANKS 2
BANKSIZE $40000
BANKS 1
.ENDRO

.SMC


.SNESHEADER

  ID "SNES"

  NAME "XMSNES               "      ; Title (can't be over 21 bytes)
  ;    "123456789012345678901"              (just a guide)

  SLOWROM                           ; Slow ROM
  LOROM                             ; LO ROM

  CARTRIDGETYPE $01                 ; ROM Cartridage with
  ROMSIZE $09                        ; unknown KB of ROM space
  SRAMSIZE $00                      ; no SRAM

  COUNTRY $01                       ; An Australan Game (the US is $01)
  LICENSEECODE 30                   ; Open System Licence (The best one on the list)
  VERSION $00                       ; First Version

.ENDSNES