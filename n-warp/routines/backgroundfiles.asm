
.Section "BackgroundfileLUT" superfree	
UploadBackgroundFileLUT:
	.dw BackgroundFile0 & $ffff
	.db (:BackgroundFile0 + BaseAdress>>16)
	.dw BackgroundFile1 & $ffff
	.db (:BackgroundFile1 + BaseAdress>>16)
	.dw BackgroundFile2 & $ffff
	.db (:BackgroundFile2 + BaseAdress>>16)
	.dw BackgroundFile3 & $ffff
	.db (:BackgroundFile3 + BaseAdress>>16)		
	.dw BackgroundFile4 & $ffff
	.db (:BackgroundFile4 + BaseAdress>>16)			
	.dw BackgroundFile5 & $ffff
	.db (:BackgroundFile5 + BaseAdress>>16)	
	.dw BackgroundFile6 & $ffff
	.db (:BackgroundFile6 + BaseAdress>>16)	
	.dw BackgroundFile7 & $ffff
	.db (:BackgroundFile7 + BaseAdress>>16)	
	.dw BackgroundFile8 & $ffff
	.db (:BackgroundFile8 + BaseAdress>>16)
	.dw BackgroundFile9 & $ffff
	.db (:BackgroundFile9 + BaseAdress>>16)
	.dw BackgroundFile10 & $ffff
	.db (:BackgroundFile10 + BaseAdress>>16)
.ends

.Section "background file 0" superfree
;battlefile 0 sky	
BackgroundFile0:
	.dw BackgroundFile0Tiles-BackgroundFile0
	.dw BackgroundFile0Tilemap-BackgroundFile0
	.dw BackgroundFile0Palette-BackgroundFile0
	.dw BackgroundFile0EOF-BackgroundFile0
BackgroundFile0Tiles:
	.incbin "data/battle_sky.pic"
BackgroundFile0Tilemap:
	.incbin "data/battle_sky.map"
BackgroundFile0Palette:
	.incbin "data/battle_sky.clr" READ 32		;only get a single 16color palette
BackgroundFile0EOF:
.ends

.Section "background file 1" superfree
;battlefile 0 scroll	
BackgroundFile1:
	.dw BackgroundFile1Tiles-BackgroundFile1
	.dw BackgroundFile1Tilemap-BackgroundFile1
	.dw BackgroundFile1Palette-BackgroundFile1
	.dw BackgroundFile1EOF-BackgroundFile1
BackgroundFile1Tiles:
	.incbin "data/nwarphaus3d.pic"
BackgroundFile1Tilemap:
	.incbin "data/nwarphaus3d.map"
BackgroundFile1Palette:
	.incbin "data/nwarphaus3d.clr" READ 192		;96 colors
BackgroundFile1EOF:
.ends



.Section "background file 2" superfree
;title nwarp logo	
BackgroundFile2:
	.dw BackgroundFile2Tiles-BackgroundFile2
	.dw BackgroundFile2Tilemap-BackgroundFile2
	.dw BackgroundFile2Palette-BackgroundFile2
	.dw BackgroundFile2EOF-BackgroundFile2
BackgroundFile2Tiles:
	.incbin "data/nwarp.pic"
BackgroundFile2Tilemap:
	.incbin "data/nwarp.map"
BackgroundFile2Palette:
	.incbin "data/nwarp.clr" READ 32		;only get a single 16color palette
BackgroundFile2EOF:
.ends

.Section "background file 3" superfree
;title background
BackgroundFile3:
	.dw BackgroundFile3Tiles-BackgroundFile3
	.dw BackgroundFile3Tilemap-BackgroundFile3
	.dw BackgroundFile3Palette-BackgroundFile3
	.dw BackgroundFile3EOF-BackgroundFile3
BackgroundFile3Tiles:
	.incbin "data/titlebg.pic"
BackgroundFile3Tilemap:
	.incbin "data/titlebg.map"
BackgroundFile3Palette:
	.incbin "data/titlebg.clr" READ 224		;96 colors
BackgroundFile3EOF:
.ends

.Section "background file 4" superfree
;gra logo background
BackgroundFile4:
	.dw BackgroundFile4Tiles-BackgroundFile4
	.dw BackgroundFile4Tilemap-BackgroundFile4
	.dw BackgroundFile4Palette-BackgroundFile4
	.dw BackgroundFile4EOF-BackgroundFile4
BackgroundFile4Tiles:
	.incbin "data/grabg.pic"
BackgroundFile4Tilemap:
	.incbin "data/grabg.map"
BackgroundFile4Palette:
	.incbin "data/grabg.clr" READ 32
BackgroundFile4EOF:
.ends

.Section "background file 5" superfree
;3d video bg
BackgroundFile5:
	.dw BackgroundFile5Tiles-BackgroundFile5
	.dw BackgroundFile5Tilemap-BackgroundFile5
	.dw BackgroundFile5Palette-BackgroundFile5
	.dw BackgroundFile5EOF-BackgroundFile5
BackgroundFile5Tiles:
	.incbin "data/3dsky.pic"
BackgroundFile5Tilemap:
	.incbin "data/3dsky.map"
BackgroundFile5Palette:
	.incbin "data/3dsky.clr" READ 512
BackgroundFile5EOF:
.ends

.Section "background file 6" superfree
;player select text
BackgroundFile6:
	.dw BackgroundFile6Tiles-BackgroundFile6
	.dw BackgroundFile6Tilemap-BackgroundFile6
	.dw BackgroundFile6Palette-BackgroundFile6
	.dw BackgroundFile6EOF-BackgroundFile6
BackgroundFile6Tiles:
	.incbin "data/waitingfor.pic"
BackgroundFile6Tilemap:
	.incbin "data/waitingfor.map"
BackgroundFile6Palette:
	.incbin "data/waitingfor.clr" READ 32
BackgroundFile6EOF:
.ends

.Section "background file 7" superfree
;player select text
BackgroundFile7:
	.dw BackgroundFile7Tiles-BackgroundFile7
	.dw BackgroundFile7Tilemap-BackgroundFile7
	.dw BackgroundFile7Palette-BackgroundFile7
	.dw BackgroundFile7EOF-BackgroundFile7
BackgroundFile7Tiles:
	.incbin "data/getready.pic"
BackgroundFile7Tilemap:
	.incbin "data/getready.map"
BackgroundFile7Palette:
	.incbin "data/getready.clr" READ 32
BackgroundFile7EOF:
.ends

.Section "background file 8" superfree
;player select text
BackgroundFile8:
	.dw BackgroundFile8Tiles-BackgroundFile8
	.dw BackgroundFile8Tilemap-BackgroundFile8
	.dw BackgroundFile8Palette-BackgroundFile8
	.dw BackgroundFile8EOF-BackgroundFile8
BackgroundFile8Tiles:
	.incbin "data/endofmatch.pic"
BackgroundFile8Tilemap:
	.incbin "data/endofmatch.map"
BackgroundFile8Palette:
	.incbin "data/endofmatch.clr" READ 32
BackgroundFile8EOF:
.ends

.Section "background file 9" superfree
;player select text
BackgroundFile9:
	.dw BackgroundFile9Tiles-BackgroundFile9
	.dw BackgroundFile9Tilemap-BackgroundFile9
	.dw BackgroundFile9Palette-BackgroundFile9
	.dw BackgroundFile9EOF-BackgroundFile9
BackgroundFile9Tiles:
	.incbin "data/preparefor.pic"
BackgroundFile9Tilemap:
	.incbin "data/preparefor.map"
BackgroundFile9Palette:
	.incbin "data/preparefor.clr" READ 32
BackgroundFile9EOF:
.ends

.Section "background file 10" superfree
;credits video background
BackgroundFile10:
	.dw BackgroundFile10Tiles-BackgroundFile10
	.dw BackgroundFile10Tilemap-BackgroundFile10
	.dw BackgroundFile10Palette-BackgroundFile10
	.dw BackgroundFile10EOF-BackgroundFile10
BackgroundFile10Tiles:
	.incbin "data/creditsbg.pic"
BackgroundFile10Tilemap:
	.incbin "data/creditsbg.map"
BackgroundFile10Palette:
	.incbin "data/creditsbg.clr" READ 512
BackgroundFile10EOF:
.ends




