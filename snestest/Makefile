# SDK Config

SDK=/Users/david/Devel/arch/snes/devkit
SDK=/Users/david/.wine/drive_c/65xx_FreeSDK

WINE=/opt/local/bin/wine
#WINE=wine.sh

CC=$(WINE) $(SDK)/bin/WDC816CC.exe
AS=$(WINE) $(SDK)/bin/WDC816AS.exe
LD=$(WINE) $(SDK)/bin/WDCLN.exe

EMU=/Applications/ZSNES.app/Contents/MacOS/ZSNES 

# External Tools

PADBIN=$(WINE) tools/padbin.exe
PCX2SNES=$(WINE) tools/Pcx2Snes.exe

# Project

LIBS=$(SDK)/lib/cs
OBJS=StartupSnes.obj main.obj pad.obj event.obj myEvents.obj PPU.obj debug.obj ressource.obj
APP=rom.smc
GFX=kungfu debugfont

all:  $(APP)

run:  
	$(EMU) $(APP)

kungfu:
		$(PCX2SNES) ressource/kungfu -n -c16 -screen

debugfont:
		$(PCX2SNES) ressource/debugFont -n -c16 -s8 -o1

%.obj: %.asm
		$(AS) -V $?

%.obj: %.c
		$(CC) -wl -wp -sop -MS $?

$(APP): $(GFX) $(OBJS)
		$(LD) -HB -M21 -V -T -Pff \
                -C008000,0000 -U0000,0000 \
                -Avectors=FFE4,7FE4 \
                -Aregistration_data=FFB0,7FB0 \
                -Aressource=18000,8000 \
                -N $(OBJS) -L$(LIBS) -O $@
		$(PADBIN) 0x40000 rom.smc

clean:
		rm -vf $(APP) *.obj
