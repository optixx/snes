@echo off
PATH=C:\wla\bin
@echo ---------------------------------
@echo Cleaning....
@echo ---------------------------------
del *.obj
del demo.smc
@echo ---------------------------------
@echo Compiling:
@echo ---------------------------------
wla-65816 -ov main.asm main.obj
wla-65816 -ov spx_snes.asm spx_snes.obj
@echo ---------------------------------
@echo Linking:
@echo ---------------------------------
wlalink -rvS main.link xmsnes.smc

pause