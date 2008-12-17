#kwla-65816 -o %1.asm %1.obj
#wlalink -vr temp.prj %1.smc


AS=wla-65816
LD=wlalink

OBJS=pattern.o
APP=pattern.smc
GFX=board.inc

all: clean $(APP)

run:$(APP)
	zsnes $(APP)

linkfile:
	echo "[objects]" > linkerfile.prj


board.inc: board.pcx
	wine tools/pcx2snes.exe board.pcx -b2 -nBoard -oboard.inc



%.o: %.asm
	echo "$@" >> linkerfile.prj
	$(AS) -o $?  $@

$(APP):  linkfile $(GFX) $(OBJS) $(GFX)
	$(LD) -vr linkerfile.prj  $@

clean:
	rm -vf $(APP) *.prj *.o
