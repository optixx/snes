.Section "sprite data" superfree
;24bit pointers to sprite tilesets + 16bit length
SpriteTilesetLUT:
	.dw SpriteTileset0
	.db :SpriteTileset0+$c0
	.dw SpriteTileset1
	.db :SpriteTileset1+$c0
	.dw SpriteTileset2
	.db :SpriteTileset2+$c0
	.dw SpriteTileset3
	.db :SpriteTileset3+$c0
	.dw SpriteTileset4
	.db :SpriteTileset4+$c0
	.dw SpriteTileset5
	.db :SpriteTileset5+$c0
	.dw SpriteTileset6
	.db :SpriteTileset6+$c0
	.dw SpriteTileset7
	.db :SpriteTileset7+$c0
	.dw SpriteTileset8
	.db :SpriteTileset8+$c0
	.dw SpriteTileset9
	.db :SpriteTileset9+$c0
	.dw SpriteTileset10
	.db :SpriteTileset10+$c0
	.dw SpriteTileset11
	.db :SpriteTileset11+$c0
	.dw SpriteTileset12
	.db :SpriteTileset12+$c0
	.dw SpriteTileset13
	.db :SpriteTileset13+$c0
	.dw SpriteTileset14
	.db :SpriteTileset14+$c0
	.dw SpriteTileset15
	.db :SpriteTileset15+$c0
	.dw SpriteTileset16
	.db :SpriteTileset16+$c0
	.dw SpriteTileset17
	.db :SpriteTileset17+$c0
	.dw SpriteTileset18
	.db :SpriteTileset18+$c0	
	.dw SpriteTileset19
	.db :SpriteTileset19+$c0
	.dw SpriteTileset20
	.db :SpriteTileset20+$c0
	.dw SpriteTileset21
	.db :SpriteTileset21+$c0
	.dw SpriteTileset22
	.db :SpriteTileset22+$c0
	.dw SpriteTileset23
	.db :SpriteTileset23+$c0
	.dw SpriteTileset24
	.db :SpriteTileset24+$c0
	.dw SpriteTileset25
	.db :SpriteTileset25+$c0
	.dw SpriteTileset26
	.db :SpriteTileset26+$c0
	.dw SpriteTileset27
	.db :SpriteTileset27+$c0	
	.dw SpriteTileset28
	.db :SpriteTileset28+$c0
	.dw SpriteTileset29
	.db :SpriteTileset29+$c0
	.dw SpriteTileset30
	.db :SpriteTileset30+$c0
	.dw SpriteTileset31
	.db :SpriteTileset31+$c0
	.dw SpriteTileset32
	.db :SpriteTileset32+$c0
	.dw SpriteTileset33
	.db :SpriteTileset33+$c0
	.dw SpriteTileset34
	.db :SpriteTileset34+$c0
	.dw SpriteTileset35
	.db :SpriteTileset35+$c0
	.dw SpriteTileset36
	.db :SpriteTileset36+$c0
	.dw SpriteTileset37
	.db :SpriteTileset37+$c0	
	.dw SpriteTileset38
	.db :SpriteTileset38+$c0
	.dw SpriteTileset39
	.db :SpriteTileset39+$c0
	.dw SpriteTileset40
	.db :SpriteTileset40+$c0
	.dw SpriteTileset41
	.db :SpriteTileset41+$c0
	.dw SpriteTileset42
	.db :SpriteTileset42+$c0
	.dw SpriteTileset43
	.db :SpriteTileset43+$c0
	.dw SpriteTileset44
	.db :SpriteTileset44+$c0
	.dw SpriteTileset45
	.db :SpriteTileset45+$c0
	.dw SpriteTileset46
	.db :SpriteTileset46+$c0
	.dw SpriteTileset47
	.db :SpriteTileset47+$c0	
	.dw SpriteTileset48
	.db :SpriteTileset48+$c0
	.dw SpriteTileset49
	.db :SpriteTileset49+$c0
	.dw SpriteTileset50
	.db :SpriteTileset50+$c0
	.dw SpriteTileset51
	.db :SpriteTileset51+$c0
	.dw SpriteTileset52
	.db :SpriteTileset52+$c0
	.dw SpriteTileset53
	.db :SpriteTileset53+$c0		
	.dw SpriteTileset54
	.db :SpriteTileset54+$c0	
	.dw SpriteTileset55
	.db :SpriteTileset55+$c0
	.dw SpriteTileset56
	.db :SpriteTileset56+$c0
	.dw SpriteTileset57
	.db :SpriteTileset57+$c0
	.dw SpriteTileset58
	.db :SpriteTileset58+$c0
	.dw SpriteTileset59
	.db :SpriteTileset59+$c0
	.dw SpriteTileset60
	.db :SpriteTileset60+$c0	
	.dw SpriteTileset61
	.db :SpriteTileset61+$c0
	.dw SpriteTileset62
	.db :SpriteTileset62+$c0
	.dw SpriteTileset63
	.db :SpriteTileset63+$c0
			
;16bit pointers to sprite palettes + 16bit length
SpritePaletteLUT:	
	.dw SpritePalette0-SpritePaletteLUT
	.dw (SpritePalette0End-SpritePalette0)
	.dw SpritePalette1-SpritePaletteLUT
	.dw (SpritePalette1End-SpritePalette1)
	.dw SpritePalette2-SpritePaletteLUT
	.dw (SpritePalette2End-SpritePalette2)
	.dw SpritePalette3-SpritePaletteLUT
	.dw (SpritePalette3End-SpritePalette3)
	.dw SpritePalette4-SpritePaletteLUT
	.dw (SpritePalette4End-SpritePalette4)
	.dw SpritePalette5-SpritePaletteLUT
	.dw (SpritePalette5End-SpritePalette5)
	.dw SpritePalette6-SpritePaletteLUT
	.dw (SpritePalette6End-SpritePalette6)
	.dw SpritePalette7-SpritePaletteLUT
	.dw (SpritePalette7End-SpritePalette7)
	.dw SpritePalette8-SpritePaletteLUT
	.dw (SpritePalette8End-SpritePalette8)
	.dw SpritePalette9-SpritePaletteLUT
	.dw (SpritePalette9End-SpritePalette9)
	.dw SpritePalette10-SpritePaletteLUT
	.dw (SpritePalette10End-SpritePalette10)
	.dw SpritePalette11-SpritePaletteLUT
	.dw (SpritePalette11End-SpritePalette11)
	.dw SpritePalette12-SpritePaletteLUT
	.dw (SpritePalette12End-SpritePalette12)	
	.dw SpritePalette13-SpritePaletteLUT
	.dw (SpritePalette13End-SpritePalette13)
	.dw SpritePalette14-SpritePaletteLUT
	.dw (SpritePalette14End-SpritePalette14)
	.dw SpritePalette15-SpritePaletteLUT
	.dw (SpritePalette15End-SpritePalette15)
	.dw SpritePalette16-SpritePaletteLUT
	.dw (SpritePalette16End-SpritePalette16)	
	.dw SpritePalette17-SpritePaletteLUT
	.dw (SpritePalette17End-SpritePalette17)
	.dw SpritePalette18-SpritePaletteLUT
	.dw (SpritePalette18End-SpritePalette18)
	.dw SpritePalette19-SpritePaletteLUT
	.dw (SpritePalette19End-SpritePalette19)
	.dw SpritePalette20-SpritePaletteLUT
	.dw (SpritePalette20End-SpritePalette20)
	.dw SpritePalette21-SpritePaletteLUT
	.dw (SpritePalette21End-SpritePalette21)			
		
SpritePalette0:
	.incbin "data/walkingdown.clr" READ 32
SpritePalette0End:
SpritePalette1:
	.incbin "data/male2.clr" READ 32
SpritePalette1End:
SpritePalette2:
	.incbin "data/male3.clr" READ 32
SpritePalette2End:
SpritePalette3:
	.incbin "data/male4.clr" READ 32
SpritePalette3End:

SpritePalette4:
	.incbin "data/male5.clr" READ 32
SpritePalette4End:

SpritePalette5:
	.incbin "data/male6.clr" READ 32
SpritePalette5End:
SpritePalette6:
	.incbin "data/male7.clr" READ 32
SpritePalette6End:
SpritePalette7:
	.incbin "data/male8.clr" READ 32
SpritePalette7End:
SpritePalette8:
	.incbin "data/mond.clr" READ 32
SpritePalette8End:
SpritePalette9:
	.incbin "data/mond_corona.clr" READ 32

SpritePalette9End:


SpritePalette10:
	.incbin "data/nightchar1.clr" READ 32
SpritePalette10End:

SpritePalette11:
	.incbin "data/nightchar2.clr" READ 32
SpritePalette11End:

SpritePalette12:
	.incbin "data/nightchar3.clr" READ 32
SpritePalette12End:

SpritePalette13:
	.incbin "data/nightchar4.clr" READ 32
SpritePalette13End:

SpritePalette14:
	.incbin "data/nightchar5.clr" READ 32
SpritePalette14End:

SpritePalette15:
	.incbin "data/daisakusen.clr" READ 32
SpritePalette15End:

SpritePalette16:
	.incbin "data/explode.clr" READ 32
SpritePalette16End:

SpritePalette17:
	.incbin "data/gra.clr" READ 32
SpritePalette17End:

SpritePalette18:
	.incbin "data/g.clr" READ 32
SpritePalette18End:

SpritePalette19:
	.incbin "data/winmark.clr" READ 32
SpritePalette19End:

SpritePalette20:
	.incbin "data/nwarpsmall.clr" READ 32
SpritePalette20End:

SpritePalette21:
	.incbin "data/8x8test.clr" READ 32
SpritePalette21End:

.ends



.Section "spritetileset 0" superfree
SpriteTileset0:
	.incbin "data/walkingdown.pic"
.ends

.Section "spritetileset 1" superfree
SpriteTileset1:
	.incbin "data/walkingup.pic"
.ends

.Section "spritetileset 2" superfree
SpriteTileset2:
	.incbin "data/walkingleft.pic"
.ends

.Section "spritetileset 3" superfree
SpriteTileset3:
	.incbin "data/walkingright.pic"
.ends

.Section "spritetileset 4" superfree
SpriteTileset4:
	.incbin "data/punchingdown.pic"
.ends

.Section "spritetileset 5" superfree
SpriteTileset5:
	.incbin "data/punchingup.pic"
.ends

.Section "spritetileset 6" superfree
SpriteTileset6:
	.incbin "data/punchingleft.pic"
.ends

.Section "spritetileset 7" superfree
SpriteTileset7:
	.incbin "data/punchingright.pic"	
.ends

.Section "spritetileset 8" superfree
SpriteTileset8:
	.incbin "data/fallingdown.pic"
.ends

.Section "spritetileset 9" superfree
SpriteTileset9:
	.incbin "data/fallingup.pic"
.ends

.Section "spritetileset 10" superfree
SpriteTileset10:
	.incbin "data/fallingleft.pic"
.ends

.Section "spritetileset 11" superfree
SpriteTileset11:
	.incbin "data/fallingright.pic"
.ends

.Section "spritetileset 12" superfree
SpriteTileset12:
	.incbin "data/fiercepunchdown.pic"
.ends

.Section "spritetileset 13" superfree
SpriteTileset13:
	.incbin "data/fiercepunchup.pic"
.ends

.Section "spritetileset 14" superfree
SpriteTileset14:
	.incbin "data/fiercepunchleft.pic"
.ends

.Section "spritetileset 15" superfree
SpriteTileset15:
	.incbin "data/fiercepunchright.pic"	
.ends

.Section "spritetileset 16" superfree
SpriteTileset16:
	.incbin "data/dead.pic"
.ends

.Section "spritetileset 17" superfree
SpriteTileset17:
	.incbin "data/healthmeter.pic"
.ends

.Section "spritetileset 18" superfree
SpriteTileset18:
	.incbin "data/sitting.pic"	
.ends

.Section "spritetileset 19" superfree
SpriteTileset19:
	.incbin "data/cheering.pic"
.ends

.Section "spritetileset 20" superfree
SpriteTileset20:
	.incbin "data/mond.pic"
.ends

.Section "spritetileset 21" superfree
SpriteTileset21:
	.incbin "data/mond_corona.pic"	
.ends

.Section "spritetileset 22" superfree
SpriteTileset22:
	.incbin "data/maincharbtlsteady.pic"		
.ends

.Section "spritetileset 23" superfree
SpriteTileset23:
	.incbin "data/maincharbtlsteadysmall.pic"	
.ends


.Section "spritetileset 24" superfree
SpriteTileset24:
	.incbin "data/daisakusen.pic"	
.ends

.Section "spritetileset 25" superfree
SpriteTileset25:
	.incbin "data/explode.pic"	
.ends

.Section "spritetileset 26" superfree
SpriteTileset26:
	.incbin "data/gra.pic"	
.ends

.Section "spritetileset 27" superfree
SpriteTileset27:
	.incbin "data/g.pic"	
.ends



.Section "spritetileset 28" superfree
SpriteTileset28:
	.incbin "data/male_blockdown.pic"	
.ends
.Section "spritetileset 29" superfree
SpriteTileset29:
	.incbin "data/male_blockup.pic"	
.ends
.Section "spritetileset 30" superfree
SpriteTileset30:
	.incbin "data/male_blockleft.pic"	
.ends
.Section "spritetileset 31" superfree
SpriteTileset31:
	.incbin "data/male_blockright.pic"	
.ends


.Section "spritetileset 32" superfree
SpriteTileset32:
	.incbin "data/male_evade_down.pic"	
.ends
.Section "spritetileset 33" superfree
SpriteTileset33:
	.incbin "data/male_evade_up.pic"	
.ends
.Section "spritetileset 34" superfree
SpriteTileset34:
	.incbin "data/male_evade_left.pic"	
.ends
.Section "spritetileset 35" superfree
SpriteTileset35:
	.incbin "data/male_evade_right.pic"	
.ends


.Section "spritetileset 36" superfree
SpriteTileset36:
	.incbin "data/male_punch1down.pic"	
.ends
.Section "spritetileset 37" superfree
SpriteTileset37:
	.incbin "data/male_punch1up.pic"	
.ends
.Section "spritetileset 38" superfree
SpriteTileset38:
	.incbin "data/male_punch1left.pic"	
.ends
.Section "spritetileset 39" superfree
SpriteTileset39:
	.incbin "data/male_punch1right.pic"	
.ends

.Section "spritetileset 40" superfree
SpriteTileset40:
	.incbin "data/male_punch2down.pic"	
.ends
.Section "spritetileset 41" superfree
SpriteTileset41:
	.incbin "data/male_punch2up.pic"	
.ends
.Section "spritetileset 42" superfree
SpriteTileset42:
	.incbin "data/male_punch2left.pic"	
.ends
.Section "spritetileset 43" superfree
SpriteTileset43:
	.incbin "data/male_punch2right.pic"	
.ends

.Section "spritetileset 44" superfree
SpriteTileset44:
	.incbin "data/male_kick1down.pic"	
.ends
.Section "spritetileset 45" superfree
SpriteTileset45:
	.incbin "data/male_kick1up.pic"	
.ends
.Section "spritetileset 46" superfree
SpriteTileset46:
	.incbin "data/male_kick1left.pic"	
.ends
.Section "spritetileset 47" superfree
SpriteTileset47:
	.incbin "data/male_kick1right.pic"	
.ends

.Section "spritetileset 48" superfree
SpriteTileset48:
	.incbin "data/male_kick2down.pic"	
.ends
.Section "spritetileset 49" superfree
SpriteTileset49:
	.incbin "data/male_kick2up.pic"	
.ends
.Section "spritetileset 50" superfree
SpriteTileset50:
	.incbin "data/male_kick2left.pic"	
.ends
.Section "spritetileset 51" superfree
SpriteTileset51:
	.incbin "data/male_kick2right.pic"	
.ends

.Section "spritetileset 52" superfree
SpriteTileset52:
	.incbin "data/male_stundown.pic"	
.ends
.Section "spritetileset 53" superfree
SpriteTileset53:
	.incbin "data/male_stunup.pic"	
.ends
.Section "spritetileset 54" superfree
SpriteTileset54:
	.incbin "data/male_stunleft.pic"	
.ends
.Section "spritetileset 55" superfree
SpriteTileset55:
	.incbin "data/male_stunright.pic"	
.ends

.Section "spritetileset 56" superfree
SpriteTileset56:
	.incbin "data/male_blocksuccessdown.pic"	
.ends
.Section "spritetileset 57" superfree
SpriteTileset57:
	.incbin "data/male_blocksuccessup.pic"	
.ends
.Section "spritetileset 58" superfree
SpriteTileset58:
	.incbin "data/male_blocksuccessleft.pic"	
.ends
.Section "spritetileset 59" superfree
SpriteTileset59:
	.incbin "data/male_blocksuccessright.pic"	
.ends
.Section "spritetileset 60" superfree
SpriteTileset60:
	.incbin "data/winmark.pic"	
.ends
.Section "spritetileset 61" superfree
SpriteTileset61:
	.incbin "data/nwarpsmall.pic"	
.ends
.Section "spritetileset 62" superfree
SpriteTileset62:
	.incbin "data/8x8particle.pic"	
.ends
.Section "spritetileset 63" superfree
SpriteTileset63:
	.incbin "data/cpuusage.pic"	
.ends

