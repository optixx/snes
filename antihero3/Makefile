ERASE=del

all: compile

compile: 
	tools\Pcx2Snes.exe ressource/kungfu -n -c16 -screen
	tools\Pcx2Snes.exe ressource/debugFont -n -c16 -s8 -o1
	wdc816cc -wl -wp -sop -MS main.c
	wdc816cc -wl -a -sop -MS main.c
	wdc816cc -wl -wp -sop -MS pad.c
	wdc816cc -wl -wp -sop -MS event.c
	wdc816cc -wl -wp -sop -MS myEvents.c
	wdc816cc -wl -wp -sop -MS PPU.c
	wdc816cc -wl -wp -sop -MS debug.c
	wdc816as -V startupSnes.asm
	wdc816as -V ressource.asm
	wdcln -HB -M21 -V -T -Pff -C008000,0000 -U0000,0000 -Avectors=FFE4,7FE4 -Aregistration_data=FFB0,7FB0 \
		-Aressource=18000,8000 -N startupSnes.obj main.obj ressource.obj pad.obj event.obj myEvents.obj PPU.obj debug.obj \
		-LC:\65xx_FreeSDK\lib\cs -O rom.smc
	tools\padbin.exe 0x40000 rom.smc

clean:
	-$(ERASE) *.obj
	-$(ERASE) *.usage
	-$(ERASE) *.map
	-$(ERASE) *.smc
	-$(ERASE) Valid.Ext