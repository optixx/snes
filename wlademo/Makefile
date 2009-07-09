all:
	../../bin/wla-65816 -vo main.asm main.obj
	../../bin/wlalink -vr main.link main.smc
run:
	snes main.smc
