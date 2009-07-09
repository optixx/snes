#include "data.h"
#include "pad.h"
#include "PPU.h"
#include "ressource.h"

word debugMap[0x400];

void initDebugMap(void) {
	word i;
	
	for(i=0; i<0x400; i++) {
		debugMap[i] = 0x00;
	}
}

void debug(void) {
	word i,j;

	char text[25] = "PINK DEBUGGER OUTPUT V0.1";

	byte tileMapLocationBackup;
	word characterLocationBackup;

	padStatus pad1;

	// Save anything we will override
	tileMapLocationBackup = tileMapLocation[0];
	characterLocationBackup = characterLocation[0];

	// Display pink debug test screen
	VRAMLoad((word) debugFont_pic, 0x5000, 2048);
	CGRAMLoad((word) debugFont_pal, (byte) 0x00, (word) 16);

	VRAMLoad((word) debugMap, 0x4000, 0x0800);
	
	setTileMapLocation(0x4000, (byte) 0x00, (byte) 0);
	setCharacterLocation(0x5000, (byte) 0);

	*(byte*) 0x2100 = 0x0f; // enable background

	pad1 = readPad((byte) 0);

	for(i=0; i<25; i++) {
		for(j=0; j<28; j++) {
			VRAMByteWrite((byte) (text[i]-32), (word) (0x4000+i+(j*0x20)));
		}
	}

	while(!pad1.select) {
		waitForVBlank();
		pad1 = readPad((byte) 0);
	}

	// Set things back
	tileMapLocation[0] = tileMapLocationBackup;
	restoreTileMapLocation((byte) 0);
	characterLocation[0] = characterLocationBackup;
	restoreCharacterLocation((byte) 0);

	// reload palette 
	// TODO save palette before
	CGRAMLoad((word) title_pal, (byte) 0x00, (word) 256);
	*(byte*) 0x2100 = 0x0f; // enable background
}
