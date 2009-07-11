.Section "AudiostreamLUT" superfree				
StreamSetLut:
	.dw TestFrame1				;3byte pointer to first streamframe set
	.db (:TestFrame1+BaseAdress>>16)
	.dw 600
	.dw TestFrame2				;3byte pointer to first streamframe set
	.db (:TestFrame2+BaseAdress>>16)
	.dw 500	
	.dw TestFrame3				;3byte pointer to first streamframe set
	.db (:TestFrame3+BaseAdress>>16)
	.dw 500		
	.dw TestFrame4				;3byte pointer to first streamframe set
	.db (:TestFrame4+BaseAdress>>16)
	.dw 640	

	.dw TestFrame5				;3byte pointer to first streamframe set
	.db (:TestFrame5+BaseAdress>>16)
	.dw 300	
	.dw TestFrame6				;3byte pointer to first streamframe set
	.db (:TestFrame6+BaseAdress>>16)
	.dw 300	
	.dw TestFrame7				;3byte pointer to first streamframe set
	.db (:TestFrame7+BaseAdress>>16)
	.dw 300	
	.dw TestFrame8				;3byte pointer to first streamframe set
	.db (:TestFrame8+BaseAdress>>16)
	.dw 300
	.dw TestFrame9				;3byte pointer to first streamframe set
	.db (:TestFrame9+BaseAdress>>16)
	.dw 200	
.ends

.bank 1 slot 0
.section "stream data test"

				;16 bit number of streamframe samples

TestFrame1:
	.incbin "data/stream/mixdown_playerselect.brr" read $fff0
	
	
.ends

.bank 2 slot 0
.section "stream data testfdsbfdb jaja"

				;16 bit number of streamframe samples

	.incbin "data/stream/mixdown_playerselect.brr" skip $fff0 read $41c0
	
	
.ends

.bank 3 slot 0
.section "stream data test2"
TestFrame2:
	.incbin "data/stream/mixdown_commence.brr"

.ends

.bank 4 slot 0
.section "stream data test3"
TestFrame3:
	.incbin "data/stream/mixdown_gameover.brr"
	
.ends

.bank 5 slot 0
.section "stream data test4"

TestFrame4:

	.incbin "data/stream/mixdown_intro.brr" read $fff0
.ends
.bank 6 slot 0
.section "stream data test5"
	.incbin "data/stream/mixdown_intro.brr" skip $fff0 read $5405

.ends

.bank 7 slot 0
.section "stream data test6"
TestFrame5:
	.incbin "data/stream/mixdown_nextround_andheregoes.brr"
.ends

.bank 8 slot 0
.section "stream data test7"
TestFrame6:
	.incbin "data/stream/mixdown_nextround_dontrelax.brr"
.ends

.bank 9 slot 0
.section "stream data test8"
TestFrame7:
	.incbin "data/stream/mixdown_nextround_giveityourbest.brr"
;		.incbin "data/stream/mixdown_nextround_wedonthave.brr"
.ends

.bank 10 slot 0
.section "stream data test9"
TestFrame8:
	.incbin "data/stream/mixdown_nextround_wedonthave.brr"
.ends

.bank 11 slot 0
.section "stream data test10"
TestFrame9:
	.incbin "data/stream/gralogo.brr"
.ends
