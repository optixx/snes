# 65816 stuff
AC = wla-65816
AFLAGS = -o
LD = wlalink
LDFLAGS = -vsr
SFILES  = main.asm
OFILES  = $(SFILES:.asm=.o)
ROMFILE = main.smc

# spc stuff
SPCAC = wla-spc700
SPCSFILES  = data/apu/apucode.asm
SPCOFILES  = $(SPCSFILES:.asm=.o)
SPCFILE = $(SPCSFILES:.asm=.bin)


all: spc $(OFILES) 
	$(LD) $(LDFLAGS) linkfile $(ROMFILE)

$(OFILES): $(SFILES)
	$(AC) $(AFLAGS) $(SFILES)

spc: $(SPCOFILES)
	$(LD) -vsb spclinkfile $(SPCFILE)

$(SPCOFILES): $(SPCSFILES)
	$(SPCAC) $(AFLAGS) $(SPCSFILES)

clean:
	rm -f $(ROMFILE) $(SPCFILE) core *~ *.o *.sym *.srm data/apu/*.o data/apu/*.sym
