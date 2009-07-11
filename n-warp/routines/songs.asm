.Section "SongLUT" superfree
PtPlayerSongPointertable:
		.dw Song0
		.db (:Song0+BaseAdress>>16)
		.dw Song1
		.db (:Song1+BaseAdress>>16)
		.dw Song2
		.db (:Song2+BaseAdress>>16)
		.dw Song3
		.db (:Song3+BaseAdress>>16)
		.dw Song4
		.db (:Song4+BaseAdress>>16)						

.ends	

.Section "song 0" superfree
Song0:
	.dw (Song0End-Song0)
	; .incbin "data/songs/maf_atomanic_4_hi.bin"
	.incbin "data/songs/maf - atomaniac en rab.bin"
Song0End:
.ends

.Section "song 1" superfree
Song1:

	.dw (Song1End-Song1)
	; .incbin "data/songs/maf_atomanic_4_hi.bin"
	.incbin "data/songs/maf_atomanic_menu_hi.bin"
Song1End:
.ends

.Section "song 2" superfree
Song2:
	.dw (Song2End-Song2)
	 .incbin "data/songs/maf_atomanic_4_hi.bin"
Song2End:	
.ends

.Section "song 3" superfree
Song3:
	.dw (Song3End-Song3)
	 .incbin "data/songs/titlehit.bin"
Song3End:
.ends

.Section "song 4" superfree
Song4:
	.dw (Song4End-Song4)
	.incbin "data/songs/maf_atomanic_3_hi.bin"
Song4End:	
.ends

