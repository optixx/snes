;------------------------------ Header File ---------------------------------

; == HiRom ========================= 
.MEMORYMAP             		; Tell WLA that the SNES has ROM at locations 0000-$FFFF in every bank
  SLOTSIZE $10000        	; and that this area is $10000 bytes in size.
  DEFAULTSLOT 0          	; There is only a single slot in SNES, other consoles
  SLOT 0 $0000           	;	may have more slots per bank.
.ENDME
 
.ROMBANKSIZE $10000    		; Every ROM bank is 64 KBytes in size, also necessary.
.ROMBANKS 8           		; 4Mbits -- Tells WLA that you want to use 8 ROM banks.
.DEFINE ROM_OFFSET $8000

.SNESHEADER
  ID "SNES"					; 1-4 letter string, just leave it as "SNES"
  
  NAME "                     "	; Program Title - can't be over 21 bytes,
    ;  "123456789012345678901"	; use spaces for unused bytes of the name.

  FASTROM
  HiROM

  CARTRIDGETYPE $02		; $02 = ROM & SRAM, see WLA documentation for others
  ROMSIZE $09			; $09 = 4 Mbits,  see WLA doc for more..
  SRAMSIZE $03			; $03 = 64 kilobits,   see WLA doc for more..
  COUNTRY $01			; $01 = U.S.  $00 = Japan, that's all I know
  LICENSEECODE $00		; Just use $00
  VERSION $00			; $00 = 1.00, $01 = 1.01, etc.
.ENDSNES


; == Interrupt Vector Table ========
.SNESNATIVEVECTOR			; Define Native Mode interrupt vector table
  COP EmptyHandler
  BRK EmptyHandler
  ABORT EmptyHandler
  NMI VBlank
  IRQ IRQ
.ENDNATIVEVECTOR

.SNESEMUVECTOR			; Define Emulation Mode interrupt vector table
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET Start
  IRQBRK EmptyHandler
.ENDEMUVECTOR


; == Empty Vectors ==================
.BANK 0 SLOT 0			; Defines the ROM bank and the slot it is inserted in memory.
.ORG ROM_OFFSET			; .ORG is really wherever the slot begins
.SECTION "EmptyVectors" SEMIFREE

EmptyHandler:
        rti

.ENDS
.EMPTYFILL $00			; Fill Empty Bytes with $00
.BASE $80				; sets a long jump base bank of $80