#wla-65816 -o %1.asm %1.obj
#wlalink -vr temp.prj %1.smc


AS=wla-65816
LD=wlalink

OBJS=first.o
APP=first.smc


all: clean $(APP)

run:
	zsnes $(APP)

linkfile:
	echo "[objects]" > first.prj

%.o: %.asm
	echo "$@" >> first.prj
	$(AS) -o $?  $@

$(APP):  linkfile $(OBJS)
	$(LD) -vr first.prj  $@

clean:
	rm -vf $(APP) *.prj *.o
