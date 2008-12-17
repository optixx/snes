#wla-65816 -o %1.asm %1.obj
#wlalink -vr temp.prj %1.smc


AS=wla-65816
LD=wlalink

OBJS=vram2.o
APP=vram2.smc
GFX=tiles.inc

all: clean $(APP)

run:
	zsnes $(APP)

linkfile:
	echo "[objects]" > linkerfile.prj


tiles.inc: tiles.pcx
	wine tools/pcx2snes.exe tiles.pcx -b2 -nTiles -otiles.inc


%.o: %.asm
	echo "$@" >> linkerfile.prj
	$(AS) -o $?  $@

$(APP):  linkfile $(GFX) $(OBJS) $(GFX)
	$(LD) -vr linkerfile.prj  $@

clean:
	rm -vf $(APP) *.prj *.o
