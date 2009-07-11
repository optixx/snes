N-Warp Daisakusen Sourcecode (c) 2009 Matthias Nagler

matt [at] dforce3000.de
http://gra.dforce3000.de


N-Warp Daisakusen was originally released on october 22th, 2008
as a freeware SNES game in precompiled form.
Now that the novelty of having an 8-player SNES game has worn off a bit, I'm releasing the sourcecode
in an attempt to help others developing software for this system.
If this sourcecode has helped you in developing your own game, please don't forget to mention me!

You won't find a complete development environment here, but this
release might be helpful if you're looking for solutions to problems
every SNES programmer has to face sooner or later, especially regarding timing.
Unlike many other homebrew efforts, this game works perfectly on real hardware.

Some of the goals I had in mind when programming this game were creating a fun little multiplayer experience
and also maximizing data throughput to the graphics and audio subsystems.
This is achieved by ending the active frame a bit early and using a FIFO queue for all DMA transfers.
The code isn't blazingly fast or particulary beautiful, but it gets the job done well enough.

Please keep in mind that this game doesn't have much in common with the way classic SNES games were programmed.
I believe it's already fairly obvious if you're just playing the game, given its high-color(for SNES, at least) backgrounds, fluid animations and
audio streaming capabilities. Also, I just love to be wasteful with ROM space and it came as a bit of a surprise that the final build used just 16Mbits.
Next one will be alot bigger, I promise. ;)


Now some words regarding the organization of the sourcecode:
In order to compile successfully, you need to have make(I'm using GNU make) and WLA DX installed and set up correctly.
I'm using Windows XP, but it should work just as well on Unix systems.
Apart from copying make and WLA DX to some folder on your HDD, you also have to set up the PATH variable on Windows to be able
to use these tools globally(Start-Control Panel-System-Advanced-Environment Variables-PATH,Edit).

Debug-mode is enabled by default (switch it off in defines.asm if you want to).
This gives you direct access to all game scenes, a special debug map and an audio and input testmenu.
There's also a special debug sprite on the left hand of the screen that indicates when the CPU
finished processing the last frame. It will vary in shape and color depending on the current scene because
its tile space and cg-ram entries are frequently used by other game objects.



Sourcecode-documentation is plentiful, but can be outdated in places, so don't take everything as gospel.
Data object formats are usually given in the program source.
There's an individual handler with its own state machine for each function block such as Audio Interface, Sprite Management, Hdma Effects, Menu Navigation etc.
I would have like to make each *.asm file into a different object, but WLA DX wouldn't let me...
Compile time is so blazingly fast that it hardly matters, anyway.



Here's what the individual assembler files contain:

program code:
-main.asm				ROM settings, all code includes, bootstrap code and CPU vectors.
-bgscrolling.asm		scrolling for both 2d and pseudo-3d backgrounds. Only used in the intro
-collisiondetection.asm	obj2bg and obj2obj collision detection
-dmafifo				unlike most other games, DMA transfers are stored in a FIFO buffer and transmitted as blanking time permits. This means high data throughput per frame, but can also lead to latency problems. Wait until DMA queue is empty if you rely in data being uploaded instantly.
-eventroutines.asm		Main statemachine. Every scene in the game runs off here, usually with an individual init and a play routine.
-gfxvrammisc.asm		misc graphic functions. SetBGMode is a handy function to set up different screen modes quickly and efficiently.
-hdmahandler.asm		controls hdma effects
-hdmasubroutines.asm	each hdma effect can have its own subroutine, this is where these go
-irq.asm				IRQ handler. Multiple IRQ routines can be selected. This game only makes use of a single one, it processes the DMA FIFO buffer and starts on scanline 200.
-joypadread.asm			has different modes for reading joypads. This game uses 8 controllers, but there's also a faster single joypad reader available in case the former is too slow.
-levelloader.asm		loads background maps for intro and levels
-memoryclear.asm		several helpful routines that clear and set wram and transfer data from rom to wram using dma
-menusystem.asm			menuloader that's only used in debugmenu
-menusubroutines.asm	routines that get called when you select options in the debugmenu
-oammanager.asm			sprite and object manager. objects have subroutines, an abundance of options and even a little scripting system that makes animating them easier.
-oamsubroutines.asm		functions specific to each object. The complete player gameplay code is in here
-printstring.asm		ancient, god-awful text printer. used in debugmenu only
-randomnumbergen.asm	generates pseudo-random number each frame base on a simple algorithm + joypad data
-spcinterface.asm		Spc700 interface. Uploads songs, streams and sets audio options. spc communication uses a command queue.
-videoplayer.asm		plays a series of 16-color pictures. Used in intro and credits

-apucode.asm			Spc700 handler. Plays Pro-Tracker Modfiles(almost perfectly, given the SNES' limitations. Finetune is unsupported because the pitch tables would take up too much space), Sound effects and streams audio. Also reports back useful information such as current position in song, channel volume etc.

-variables.asm			all variables and buffers used in the game, neatly stored in one place
-defines.asm			contains all static defines

DMA Channels are used as follows:

Channel:		Purpose:
0				DMA rom2wram via register $2180, normal memory transfer
1				Hdma channel reserved exclusively for audio streaming to the SPC700 ports at $2140-$2143
2-7				Hdma channels for graphical effects




Got any questions left? Just ask away!
