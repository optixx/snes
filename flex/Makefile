#wla-65816 -o %1.asm %1.obj
#wlalink -vr temp.prj %1.smc


AS=wla-65816
LD=wlalink

OBJS=flex.o
APP=flex.smc
EMU=/Applications/ZSNES.app/Contents/MacOS/ZSNES

all: clean $(APP)

zsnes::  
	$(EMU) $(APP)
bsnes:
	open /Applications/BSNES.app $(APP)
run: bsnes

linkfile:
	echo "[objects]" > linkerfile.prj



%.o: %.asm
	echo "$@" >> linkerfile.prj
	$(AS) -o $?  $@

$(APP):  linkfile $(GFX) $(OBJS) $(GFX)
	$(LD) -vr linkerfile.prj  $@

clean:
	rm -vf $(APP) *.prj *.o
