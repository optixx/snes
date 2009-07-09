PREFIX=/home/david/Devel/arch/snes/devkit-linux
OPTIMIZE=1

BINDIR=$(PREFIX)/bin
AS=$(BINDIR)/wla-65816
LD=$(BINDIR)/wlalink
CC=$(BINDIR)/816-tcc
COPT=$(BINDIR)/816-opt
#EMU=$(BINDIR)/snes9x
EMU=zsnes

LIBDIR=$(PREFIX)/lib

ASMOBJ = data.obj graph_asm.obj str.obj
COBJ = sine.obj input.obj init.obj graph.obj

all: sine.smc
	$(EMU) sine.smc || xset r on

sine.smc: $(ASMOBJ) $(COBJ)
	$(LD) -dvSo $(ASMOBJ) $(COBJ) sine.smc

%.s: %.c
ifeq ($(OPTIMIZE),1)
	$(CC) -I. -o $@.pre -c $<
	$(COPT) $@.pre $@
	rm $@.pre
else
	$(CC) -I. -o $@ -c $<
endif

%.obj: %.s
	$(AS) -ivo $< $@
%.obj: %.asm
	$(AS) -ivo $< $@

clean:
	rm -f sine.smc sine.sym $(ASMOBJ) $(COBJ) *.s *.pre
