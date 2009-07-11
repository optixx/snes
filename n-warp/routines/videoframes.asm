.Section "VideofilesTBL" superfree
VideoLUT:
	.dw Video0
	.dw Video1
	.dw Video2
	
Video0:
	.db 21		;total number of frames in video
	.db %11			;video framerate
	.incbin "data/video/introvideo1.clr" READ 32
	
Video0FramePointerLUT:

	
	.dw Video0Frame1&$ffff
	.db (:Video0Frame1+BaseAdress>>16)
	.dw Video0Frame1Eof-Video0Frame1

	.dw Video0Frame2&$ffff
	.db (:Video0Frame2+BaseAdress>>16)
	.dw Video0Frame2Eof-Video0Frame2
	
	.dw Video0Frame3&$ffff
	.db (:Video0Frame3+BaseAdress>>16)
	.dw Video0Frame3Eof-Video0Frame3

	.dw Video0Frame4&$ffff
	.db (:Video0Frame4+BaseAdress>>16)
	.dw Video0Frame4Eof-Video0Frame4

	.dw Video0Frame5&$ffff
	.db (:Video0Frame5+BaseAdress>>16)
	.dw Video0Frame5Eof-Video0Frame5

	.dw Video0Frame6&$ffff
	.db (:Video0Frame6+BaseAdress>>16)
	.dw Video0Frame6Eof-Video0Frame6

	.dw Video0Frame7&$ffff
	.db (:Video0Frame7+BaseAdress>>16)
	.dw Video0Frame7Eof-Video0Frame7

	.dw Video0Frame8&$ffff
	.db (:Video0Frame8+BaseAdress>>16)
	.dw Video0Frame8Eof-Video0Frame8

	.dw Video0Frame9&$ffff
	.db (:Video0Frame9+BaseAdress>>16)
	.dw Video0Frame9Eof-Video0Frame9

	.dw Video0Frame10&$ffff
	.db (:Video0Frame10+BaseAdress>>16)
	.dw Video0Frame10Eof-Video0Frame10

	.dw Video0Frame11&$ffff
	.db (:Video0Frame11+BaseAdress>>16)
	.dw Video0Frame11Eof-Video0Frame11

	.dw Video0Frame12&$ffff
	.db (:Video0Frame12+BaseAdress>>16)
	.dw Video0Frame12Eof-Video0Frame12

	.dw Video0Frame13&$ffff
	.db (:Video0Frame13+BaseAdress>>16)
	.dw Video0Frame13Eof-Video0Frame13

	.dw Video0Frame14&$ffff
	.db (:Video0Frame14+BaseAdress>>16)
	.dw Video0Frame14Eof-Video0Frame14

	.dw Video0Frame15&$ffff
	.db (:Video0Frame15+BaseAdress>>16)
	.dw Video0Frame15Eof-Video0Frame15

	.dw Video0Frame16&$ffff
	.db (:Video0Frame16+BaseAdress>>16)
	.dw Video0Frame16Eof-Video0Frame16

	.dw Video0Frame17&$ffff
	.db (:Video0Frame17+BaseAdress>>16)
	.dw Video0Frame17Eof-Video0Frame17

	.dw Video0Frame18&$ffff
	.db (:Video0Frame18+BaseAdress>>16)
	.dw Video0Frame18Eof-Video0Frame18

	.dw Video0Frame19&$ffff
	.db (:Video0Frame19+BaseAdress>>16)
	.dw Video0Frame19Eof-Video0Frame19
	
	.dw Video0Frame20&$ffff
	.db (:Video0Frame20+BaseAdress>>16)
	.dw Video0Frame20Eof-Video0Frame20

	.dw Video0Frame21&$ffff
	.db (:Video0Frame21+BaseAdress>>16)
	.dw Video0Frame21Eof-Video0Frame21

	.dw Video0Frame22&$ffff
	.db (:Video0Frame22+BaseAdress>>16)
	.dw Video0Frame22Eof-Video0Frame22		
	
	
Video1:
	.db 11		;total number of frames in video
	.db 1		;video framerate (number of frames to wait before uploading new frame)
	.incbin "data/video/creditspal.clr" READ 32
	
Video1FramePointerLUT:


	.dw Video1Frame2&$ffff
	.db (:Video1Frame2+BaseAdress>>16)
	.dw Video1Frame2Eof-Video1Frame2


	.dw Video1Frame4&$ffff
	.db (:Video1Frame4+BaseAdress>>16)
	.dw Video1Frame4Eof-Video1Frame4

	.dw Video1Frame4&$ffff
	.db (:Video1Frame4+BaseAdress>>16)
	.dw Video1Frame4Eof-Video1Frame4
	
	.dw Video1Frame3&$ffff
	.db (:Video1Frame3+BaseAdress>>16)
	.dw Video1Frame3Eof-Video1Frame3

	.dw Video1Frame3&$ffff
	.db (:Video1Frame3+BaseAdress>>16)
	.dw Video1Frame3Eof-Video1Frame3
	
	.dw Video1Frame2&$ffff
	.db (:Video1Frame2+BaseAdress>>16)
	.dw Video1Frame2Eof-Video1Frame2

	.dw Video1Frame2&$ffff
	.db (:Video1Frame2+BaseAdress>>16)
	.dw Video1Frame2Eof-Video1Frame2
	
	.dw Video1Frame1&$ffff
	.db (:Video1Frame1+BaseAdress>>16)
	.dw Video1Frame1Eof-Video1Frame1

	.dw Video1Frame1&$ffff
	.db (:Video1Frame1+BaseAdress>>16)
	.dw Video1Frame1Eof-Video1Frame1
	
	.dw Video1Frame1&$ffff
	.db (:Video1Frame1+BaseAdress>>16)
	.dw Video1Frame1Eof-Video1Frame1

	.dw Video1Frame0&$ffff
	.db (:Video1Frame0+BaseAdress>>16)
	.dw Video1Frame0Eof-Video1Frame0


Video2:
	.db 11		;total number of frames in video
	.db 1			;video framerate (number of frames to wait before uploading new frame)
	.incbin "data/video/creditspal.clr" READ 32
	
Video2FramePointerLUT:


	.dw Video2Frame2&$ffff
	.db (:Video2Frame2+BaseAdress>>16)
	.dw Video2Frame2Eof-Video2Frame2



	.dw Video2Frame4&$ffff
	.db (:Video2Frame4+BaseAdress>>16)
	.dw Video2Frame4Eof-Video2Frame4

	.dw Video2Frame4&$ffff
	.db (:Video2Frame4+BaseAdress>>16)
	.dw Video2Frame4Eof-Video2Frame4
	
	.dw Video2Frame3&$ffff
	.db (:Video2Frame3+BaseAdress>>16)
	.dw Video2Frame3Eof-Video2Frame3

	.dw Video2Frame3&$ffff
	.db (:Video2Frame3+BaseAdress>>16)
	.dw Video2Frame3Eof-Video2Frame3
	
	.dw Video2Frame2&$ffff
	.db (:Video2Frame2+BaseAdress>>16)
	.dw Video2Frame2Eof-Video2Frame2

	.dw Video2Frame2&$ffff
	.db (:Video2Frame2+BaseAdress>>16)
	.dw Video2Frame2Eof-Video2Frame2
	
	.dw Video2Frame1&$ffff
	.db (:Video2Frame1+BaseAdress>>16)
	.dw Video2Frame1Eof-Video2Frame1

	.dw Video2Frame1&$ffff
	.db (:Video2Frame1+BaseAdress>>16)
	.dw Video2Frame1Eof-Video2Frame1

	.dw Video2Frame1&$ffff
	.db (:Video2Frame1+BaseAdress>>16)
	.dw Video2Frame1Eof-Video2Frame1
		
	.dw Video2Frame0&$ffff
	.db (:Video2Frame0+BaseAdress>>16)
	.dw Video2Frame0Eof-Video2Frame0	
	

.ends


.Section "video 0 frame 1" superfree
Video0Frame1:
	.incbin "data/video/introvideo1.map" READ $800
	.incbin "data/video/introvideo1.pic"
Video0Frame1Eof:
.ends

.Section "video 0 frame 2" superfree
Video0Frame2:
	.incbin "data/video/introvideo2.map" READ $800
	.incbin "data/video/introvideo2.pic"
Video0Frame2Eof:
.ends

.Section "video 0 frame 3" superfree
Video0Frame3:
	.incbin "data/video/introvideo3.map" READ $800
	.incbin "data/video/introvideo3.pic"
Video0Frame3Eof:
.ends

.Section "video 0 frame 4" superfree
Video0Frame4:
	.incbin "data/video/introvideo4.map" READ $800
	.incbin "data/video/introvideo4.pic"
Video0Frame4Eof:
.ends

.Section "video 0 frame 5" superfree
Video0Frame5:
	.incbin "data/video/introvideo5.map" READ $800
	.incbin "data/video/introvideo5.pic"
Video0Frame5Eof:
.ends

.Section "video 0 frame 6" superfree
Video0Frame6:
	.incbin "data/video/introvideo6.map" READ $800
	.incbin "data/video/introvideo6.pic"
Video0Frame6Eof:
.ends

.Section "video 0 frame 7" superfree
Video0Frame7:
	.incbin "data/video/introvideo7.map" READ $800
	.incbin "data/video/introvideo7.pic"
Video0Frame7Eof:
.ends

.Section "video 0 frame 8" superfree
Video0Frame8:
	.incbin "data/video/introvideo8.map" READ $800
	.incbin "data/video/introvideo8.pic"
Video0Frame8Eof:
.ends

.Section "video 0 frame 9" superfree
Video0Frame9:
	.incbin "data/video/introvideo9.map" READ $800
	.incbin "data/video/introvideo9.pic"
Video0Frame9Eof:
.ends

.Section "video 0 frame 10" superfree
Video0Frame10:
	.incbin "data/video/introvideo10.map" READ $800
	.incbin "data/video/introvideo10.pic"
Video0Frame10Eof:
.ends

.Section "video 0 frame 11" superfree
Video0Frame11:
	.incbin "data/video/introvideo11.map" READ $800
	.incbin "data/video/introvideo11.pic"
Video0Frame11Eof:
.ends

.Section "video 0 frame 12" superfree
Video0Frame12:
	.incbin "data/video/introvideo12.map" READ $800
	.incbin "data/video/introvideo12.pic"
Video0Frame12Eof:
.ends

.Section "video 0 frame 13" superfree
Video0Frame13:
	.incbin "data/video/introvideo13.map" READ $800
	.incbin "data/video/introvideo13.pic"
Video0Frame13Eof:
.ends

.Section "video 0 frame 14" superfree
Video0Frame14:
	.incbin "data/video/introvideo14.map" READ $800
	.incbin "data/video/introvideo14.pic"
Video0Frame14Eof:
.ends

.Section "video 0 frame 15" superfree
Video0Frame15:
	.incbin "data/video/introvideo15.map" READ $800
	.incbin "data/video/introvideo15.pic"
Video0Frame15Eof:
.ends

.Section "video 0 frame 16" superfree
Video0Frame16:
	.incbin "data/video/introvideo16.map" READ $800
	.incbin "data/video/introvideo16.pic"
Video0Frame16Eof:
.ends

.Section "video 0 frame 17" superfree
Video0Frame17:
	.incbin "data/video/introvideo17.map" READ $800
	.incbin "data/video/introvideo17.pic"
Video0Frame17Eof:
.ends

.Section "video 0 frame 18" superfree
Video0Frame18:
	.incbin "data/video/introvideo18.map" READ $800
	.incbin "data/video/introvideo18.pic"
Video0Frame18Eof:
.ends

.Section "video 0 frame 19" superfree
Video0Frame19:
	.incbin "data/video/introvideo19.map" READ $800
	.incbin "data/video/introvideo19.pic"
Video0Frame19Eof:
.ends

.Section "video 0 frame 20" superfree
Video0Frame20:
	.incbin "data/video/introvideo20.map" READ $800
	.incbin "data/video/introvideo20.pic"
Video0Frame20Eof:
.ends

.Section "video 0 frame 21" superfree
Video0Frame21:
	.incbin "data/video/introvideo21.map" READ $800
	.incbin "data/video/introvideo21.pic"
Video0Frame21Eof:
.ends

.Section "video 0 frame 22" superfree
Video0Frame22:
	.incbin "data/video/introvideo22.map" READ $800
	.incbin "data/video/introvideo22.pic"
Video0Frame22Eof:
.ends




.Section "video 1 frame 0" superfree
Video1Frame0:
	.incbin "data/video/leanleft0.map" READ $800
	.incbin "data/video/leanleft0.pic"
Video1Frame0Eof:
.ends
.Section "video 1 frame 1" superfree
Video1Frame1:
	.incbin "data/video/leanleft1.map" READ $800
	.incbin "data/video/leanleft1.pic"
Video1Frame1Eof:
.ends
.Section "video 1 frame 2" superfree
Video1Frame2:
	.incbin "data/video/leanleft2.map" READ $800
	.incbin "data/video/leanleft2.pic"
Video1Frame2Eof:
.ends
.Section "video 1 frame 3" superfree
Video1Frame3:
	.incbin "data/video/leanleft3.map" READ $800
	.incbin "data/video/leanleft3.pic"
Video1Frame3Eof:
.ends
.Section "video 1 frame 4" superfree
Video1Frame4:
	.incbin "data/video/leanleft4.map" READ $800
	.incbin "data/video/leanleft4.pic"
Video1Frame4Eof:
.ends



.Section "video 2 frame 0" superfree
Video2Frame0:
	.incbin "data/video/leanright0.map" READ $800
	.incbin "data/video/leanright0.pic"
Video2Frame0Eof:
.ends
.Section "video 2 frame 1" superfree
Video2Frame1:
	.incbin "data/video/leanright1.map" READ $800
	.incbin "data/video/leanright1.pic"
Video2Frame1Eof:
.ends
.Section "video 2 frame 2" superfree
Video2Frame2:
	.incbin "data/video/leanright2.map" READ $800
	.incbin "data/video/leanright2.pic"
Video2Frame2Eof:
.ends
.Section "video 2 frame 3" superfree
Video2Frame3:
	.incbin "data/video/leanright3.map" READ $800
	.incbin "data/video/leanright3.pic"
Video2Frame3Eof:
.ends
.Section "video 2 frame 4" superfree
Video2Frame4:
	.incbin "data/video/leanright4.map" READ $800
	.incbin "data/video/leanright4.pic"
Video2Frame4Eof:
.ends