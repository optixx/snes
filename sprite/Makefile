#wla-65816 -o %1.asm %1.obj
#wlalink -vr temp.prj %1.smc


AS=wla-65816
LD=wlalink

OBJS=sprite.o
APP=sprite.smc
GFX=biker.pic

all: clean $(APP)

run:$(APP)
	zsnes $(APP)

linkfile:
	echo "[objects]" > linkerfile.prj


biker.pic: biker.pcx
	wine tools/Pcx2Snes -s32 -c16 -o16 -n biker



%.o: %.asm
	echo "$@" >> linkerfile.prj
	$(AS) -o $?  $@

$(APP):  linkfile $(GFX) $(OBJS) $(GFX)
	$(LD) -vr linkerfile.prj  $@

clean:
	rm -vf $(APP) *.prj *.o
