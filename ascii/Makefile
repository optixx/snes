
CC = wla-65816
CFLAGS = -o
LD = wlalink
LDFLAGS = -v 

SFILES = main.s
IFILES = 
OFILES = main.o
GFXDATA = optixx_logo.bmp

all: $(OFILES) Makefile  
	$(LD) $(LDFLAGS) linkfile result.rom
	ucon64 -chk -swc result.rom

run: clean all
	zsnes -l   result.swc


debug:
	aoss ../../tools/snes9x -d result.rom


main.o: colorlist sine gfx main.s
	$(CC) $(CFLAGS) main.s main.o

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
