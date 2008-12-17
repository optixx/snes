#wla-65816 -o %1.asm %1.obj
#wlalink -vr temp.prj %1.smc


AS=wla-65816
LD=wlalink

OBJS=nmi.o
APP=nmi.smc
GFX=

all: clean $(APP)

run:
	zsnes $(APP)

linkfile:
	echo "[objects]" > linkerfile.prj


tile.inc: tile.pcx
	wine tools/pcx2snes.exe tile.pcx -b2 -nTile -otile.inc


%.o: %.asm
	echo "$@" >> linkerfile.prj
	$(AS) -o $?  $@

$(APP):  linkfile $(GFX) $(OBJS) $(GFX)
	$(LD) -vr linkerfile.prj  $@

clean:
	rm -vf $(APP) *.prj *.o
