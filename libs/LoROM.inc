;------------------------------ Header File ---------------------------------

; == LoRom =========================
.MEMORYMAP                      ; Begin describing the system architecture.
  SLOTSIZE $8000                ; The slot is $8000 bytes in size. More details on slots later.
  DEFAULTSLOT 0                 ; There's only 1 slot in SNES, there are more in other consoles.
  SLOT 0 $8000                  ; Define's Slot 0's starting address.
.ENDME          ; End MemoryMap definition

.ROMBANKSIZE $8000              ; Every ROM bank is 32 KBytes in size
.ROMBANKS 16           		  ; 4Mbits -- Tells WLA that you want to use 16 ROM banks.
.DEFINE ROM_OFFSET $0000

.SNESHEADER
  ID "SNES"                     ; 1-4 letter string, just leave it as "SNES"
  
  NAME "                     "  ; Program Title - can't be over 21 bytes,
    ;  "123456789012345678901"  ; use spaces for unused bytes of the name.

  SLOWROM
  LoROM

  CARTRIDGETYPE $02             ; $02 = ROM & SRAM, see WLA documentation for others
  ROMSIZE $09                   ; $09 = 4 Mbits,  see WLA doc for more..
  SRAMSIZE $01                  ; $01 - 16 kilobits,   see WLA doc for more..
  COUNTRY $01                   ; $01 = U.S.  $00 = Japan, that's all I know
  LICENSEECODE $00              ; Just use $00
  VERSION $00                   ; $00 = 1.00, $01 = 1.01, etc.
.ENDSNES


; == Interrupt Vector Table ========
.SNESNATIVEVECTOR               ; Define Native Mode interrupt vector table
  COP EmptyHandler
  BRK EmptyHandler
  ABORT EmptyHandler
  NMI VBlank
  IRQ EmptyHandler
.ENDNATIVEVECTOR

.SNESEMUVECTOR                  ; Define Emulation Mode interrupt vector table
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET Start
  IRQBRK EmptyHandler
.ENDEMUVECTOR


; == Empty Vectors ==================
.BANK 0 SLOT 0                  ; Defines the ROM bank and the slot it is inserted in memory.
.ORG ROM_OFFSET            	; .ORG is really wherever the slot begins
.SECTION "EmptyVectors" SEMIFREE

EmptyHandler:
        rti

.ENDS
.EMPTYFILL $00