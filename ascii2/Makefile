
CC = ../../bin/wla-65816
LD = ../../bin/wlalink
UCON = ucon64
EMU = zsnes -l
SFILES = main.s
IFILES = 
OFILES = main.obj
GFXDATA = optixx_logo.bmp

all: $(OFILES) Makefile  
	$(LD) -vr linkfile main.smc
	$(UCON) -chk -swc main.smc

run: clean all
	$(EMU) main.swc


main.obj: colorlist sine gfx main.asm
	$(CC) -vo main.asm main.obj

gfx: bmp2bitplane.py optixx_logo.bmp 	

	python bmp2bitplane.py optixx_logo.bmp

sine: sinegen.py

	python sinegen.py vsine_1.s 256 96 1
	python sinegen.py vsine_2.s 256 96 1 flip
	python sinegen.py colbarsine_1.s 256 64 3


colorlist:	bmp2col.py

	python bmp2col.py	backcolors.bmp list
	python bmp2col.py	colbar_1.bmp 
	python bmp2col.py	colbar_2.bmp 
	python bmp2col.py	colbar_3.bmp 
		
	

$(OFILES): $(HFILES)


clean:
	rm -f $(OFILES) core *~ result.rom optixx_logo.s 
