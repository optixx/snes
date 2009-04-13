; Dieses Programm zeigt einen Text auf dem Bildschirm an, der über den     ; Bildschirm scrollt und sich dabei dreht. Der Text wird endlos angezeigt, ; wiederholt sich also.

.include "header.inc"			
.include "init.asm"	; Einbindung der Initialisierungsdateien

VBlank:
  	RTI		; Definition, die laut "Header.inc" gebraucht  ; wird

.bank 0
.section "MainCode"	; Der Code des Programms befindet sich in der  ; Speicherbank 0 des ROM

; Die Startroutine schreibt einige Initialisierungen, um die Textanzeige zu ; ermöglichen. Dann werden einige Unterprogramme aufgerufen, die den RAM   ; entsprechend vorbereiten und die Buchstaben und Farben kopieren.
; Gleichzeitig werden verschiedene Zähler definiert, die für die           ; Textanzeige benötigt werden. Zuletzt wird eine Endlosschleife gestartet, ; die die Textanzeige am laufen hält.
Start:  
	Snes_Init	; Aufruf der Initialisierung des Emulators
	rep     #$10	; X, Y-Register auf 16 Bite Breite
	sep     #$20	; Akkumulator auf 8 Bit Breite
	lda	#$00			
	sta	$2105	; Setze Bildschirm auf Modus 0, 8*8 Bit Tiles
	lda	#$75	
	sta	$2107	; Hintergrund 1 Init-Einstellungen
	lda	#$00
	sta	$210b	; Hintergrund 1 Tile Init-Einstellungen
	lda	#$01				
	sta	$212c	; Hintergrund 1 aktiviert
	stz	$1000	; Startwert der Tile-Initialisierung
	stz	$1001	; Speichervariable für Tile-Initialisierung
	jsr	Copy_Gfx	; Funktion zum kopieren der Grafikdaten in RAM
	jsr	Copy_colors	; Funktion zum kopieren der Farbdaten in den   ; Farb-RAM
	jsr	Make_tiles	; Leeren des Screens und Tile-Initialisierung
	jsr	Clear_ram	; Leeren des VRAM

	ldx	#$0000
	stx	$1002	; Counter für die Zeilen eines zu zeichnenden  ; Buchtaben
	ldx	#$0000
	stx	$1004	; Counter für Buchstaben, die zu zeichnen sind

	ldx	#$0000
	stx	$1006	; Grafik-Offset eines Buchstaben. Gibt die     ; Position der entsprechenden Grafik im VRAM an

	ldx	#$0000
	stx	$1008	; Hier wird der Text-Offset für die Flex-      ; Funktion gespeichert

	ldx	#$0000
	stx	$100a	; Der aktuelle Offset der SINE-Werte 
	
	ldx	#$0000
	stx	$100c	; Speicherwert für den SINE-Offset
	
	ldx	#$0000
	stx	$100e	; Speicherwert für den SINE-Offset

	ldx	#$0000
	stx	$1010	; Scrollposition innerhalb eines Buchstaben.

	ldx	#$0000
	stx	$1012	; Scrollposition in Buchstaben im Text
	
	lda	#$00
	sta	$10
	lda	#$80			
	sta	$11			
	lda	#$7e		
	sta	$12	; Speichert den Wert 7e8000h in 10-12h, so dass ; mit [$10] $7e8000 adressiert werden kann

	lda	#$0f
	sta	$2100	; Bildschirm an, höchste Helligkeit
Waitloop:
	jsr	WaitVb	; Starte die WaitVb-Routine, um sicher zu sein, ; das neue Daten gesendet werden können
	jsr	Routines	; Starte die Berechnung und Übertragung neuer  ; Daten
	bra	Waitloop	; Springe wieder zu Waitloop, um den Prozess   ; erneut zu starten

; Routines ist eine Sammelfunktion, in der der DMA-Prozess vom Speicher in ; den VRAM angestossen wird. Weiterhin werden hier die Funktionen, die für ; die Anzeige des Textes benötigt werden, aufgerufen.
Routines:
	rep	#$10	; Setze X,Y-Register auf 16 Bit
	sep	#$20	; Setze Akku auf 8 Bit

; Start der allgemeinen DMA Routine zum Kopieren der Grafikdaten in die ; Ausgabe. Start eines DMA-Prozesses, der die Daten, die angezeigt      ; werden sollen, vom RAM des SNES in den VRAM schreibt.
	lda	#$00
	sta	$4330	; initialisiere Befehlsregister des vierten    ; DMA-Controllers		
	lda	#$18
	sta	$4331	; Setze Zieladresse auf VRAM
	lda	#$00
	sta	$4332
	lda	#$80		
	sta	$4333
	lda	#$7e
	sta	$4334	; Setzt Quelladresse auf 7E8000h
	ldx	#$0800
	stx	$4335	; Anzahl der zu übertragenden Bytes auf 800h
	lda	#$00
	sta	$2115	; Setze VRAM Autoinkrement auf 0
	ldx	#$0000
	stx	$2116	; Setzt Zieladresse im VRAM auf 0h
	lda	#$08		
	sta	$420b	; Startet DMA-Übertragungsprozess mit dem      ; vierten DMA-Controller
	lda	#$80	
	sta	$2115	; Autoinkrement Adresse im Grafik-RAM um 80h

	lda	$1010	; Lade aktuellen Scrolloffset im Buchstaben
	sta	$210d	; Scrolle den Bildschirm um diesen Offset
	stz 	$210d	; Setze den Scrolloffset auf null, um flackern ; zu verhindern
	jsr	Scroll	; Die Scrollroutine setzt den Scrolloffset neu, ; so das der Text weiter scrollt. Weiterhin    ; schreibt sie die Buchstaben, die angezeigt   ; werden sollen, in den Speicher.
	jsr	Flex	; Die Flex-Routine lässt die Buchstaben in     ; einer Sinuskurve schwingen und ist           ; gleichzeitig dafür zuständig, das die         ; Buchstaben zeilenweise in den Speicherbereich ; kopiert werden, aus dem sie später die DMA-   ; Routine in den VRAM kopiert.
	rts


; Die Scrollroutine ist dazu da, den Text in den Speicher zu schreiben, der ; aktuell angezeigt werden soll. Gleichzeitig berechnet sie, welcher Text  ; angezeigt wird, wenn der Text über den Bildschirm scrollt.
Scroll:
	lda	$1010	; Lade aktuellen Scrolloffset im Buchstaben
	clc
	adc	#$01	; Erhöhe um 1
	sta	$1010	; Speichere den erhöhten Offset
	cmp	#$08	; Prüfe, ob über einen Buchstaben gescrollt    ; wurde
	bcs	scrolltexts	; Wenn ja, springe zu scrolltexts
	rts
scrolltexts:
	stz	$1010	; Setze aktuellen Scrolloffset im Buchstaben   ; auf null
	ldy	$1012	; Lade Scrolloffset im Text ins Y-Register
	ldx	#$0000	; Lade das X-Register mit null als Counter für ; den Text, der auf dem Bildschirm ausgegeben  ; wird
copyscroll:
	lda	TEXT,y	; Lade den ersten anzuzeigenden Buchstaben in  ; den Akku
	sta	$7e7000,x	; Speichere den Buchstaben im RAM an der Stelle ; 7e7000h + X
	iny		; Zähle den Counter für den Text hoch
	cpy #$0040	; Prüfe, ob der Text zuende ist (der Text hat  ; momentan 32 Zeichen)
	beq endtext	; Wenn ja, springe zu endtext
moveon:
	inx		; Zähle die Counter für die Anzeige hoch
	cpx	#$0020	; Prüfe, ob die Anzeige schon voll ist (der    ; Bildschirm ist 16 Zeichen breit)
	bne	copyscroll	; Wenn noch nicht alle Zeichen ausgegeben      ; wurden, starte die Funktion neu
	ldy	$1012	; Hole aktuellen Text-Offset
	iny		; Erhöhe ihn um 1
	cpy #$0040	; Prüfe, ob der Text zuende ist
	beq endtext2	; Wenn ja, springe zu endtext
moveon2:
	sty	$1012	; Speichere den erhöhten Offset
	rts
endtext:
	ldy	#$0000	; Lade den Counter für den Text neu
	bra	moveon	
endtext2:
	ldy	#$0000	; Lade den Counter für den Text neu
	bra	moveon2	


; Die Flex-Routine lässt die Buchstaben in einer Sinuskurve schwingen und  ; ist gleichzeitig dafür zuständig, dass die Buchstaben zeilenweise in den ; Speicherbereich kopiert werden, aus dem sie später die DMA-Routine in den ; VRAM kopiert.
Flex:
	ldy	$100a	; Lese den aktuellen Absolut-SINE-Offset in Y  ; ein
	sty	$100e	; Speichere ihn, zur Verwendung für die        ; Erstellung aller Buchstaben
Flex1:
	ldy	$100e	; Lese den SINE-Offset der Zeile in Y ein
	sty	$100c	; Speichere ihn, zur Verwendung für die        ; Erstellung eines Buchstaben
	ldx	$1008	; Lese den aktuellen Text-Offset in X ein
	rep	#$30	; Setze Akku auf 16 Bit
	lda	$7e7000,x	; Lese nächsten anzuzeigenden Buchstaben
	and	#$003f	; Konvertiere das Format von ASCII zu C64-     ; Format und Lösche das High Byte
	asl 	a	; Nun wird der Wert vier mal mit 2 malgenommen 
	asl 	a	; (um 1 nach links geschoben) um seine 
	asl 	a	; Entsprechung im Charset zu finden, da jeder 
	asl 	a	; Buchstabe im Charset 16 Byte groß ist.
	sta	$1006	; Speichere den Wert
	tax			; Schreibe den Wert vom Akku ins X-Register
Flexdraw:
	ldy	$100c	; Lese den SINE-Offset für den aktuellen          ; Buchstaben in Y ein
	rep	#$30	; Setze Akku auf 16 Bit
	lda	SINE,y	; Lese SINE-daten an der Stelle y in den Akku
	and	#$00ff	; Lösche das High Byte
	tay			; Schreibe Akku ins Y-Register
	sep	#$20	; Setze Akku auf 8 Bit
	lda	$7ea000,x	; Lese das aktuelle Byte der Grafik des            ; aktuellen Buchstaben ein
	sta	[$10],y	; Speichere es an der Stelle, die der SINE-       ; Offset vorgibt. [$10] ist Speicherindirekt,  ; gespeichert wird also an der Stelle im        ; Speicher, die in der Speicherstelle 10h      ; steht.
	inx		; Hole das nächste Byte
	inc	$100c	; Erhöhe den SINE-Offset des Zeichens
	inc	$1002	; Erhöhe den Zeilencounter des aktuellen       ; Buchstaben
	lda	$1002	; Lade den Zeilencounter
	cmp	#$10	; Prüfe, ob 16 Zeilen gezeichnet wurden
	bne	Flexdraw	; Wenn nicht, springe zu Flexdraw
	
	stz	$1002	; Setze den Zeilencounter auf null
	inc	$1004	; Erhöhe den Buchstabencounter
	lda	$1004	; Lade den Buchstabencounter
	cmp	#$20	; Prüfe, ob 32 Buchstaben gezeichnet wurden
	beq	enddraw	; Wenn ja, springe zu enddraw
	rep	#$30	; Setze Akku auf 16 Bit
	lda	$10		; Lade den wert der Adresse 10h
	clc			; Lösche das Carry-Flag
	adc	#$0040	; Erhöhe die Adresse im Akku um 40h, also um    ; ein Zeichen. Jede Spalte ist 64 Byte hoch,   ; das ist aus der SINE-Tabelle ersichtlich. 64 ; dezimal sind 40h, und somit muss für die       ; nächste Spalte der Wert um 40h erhöht werden.
	sta	$10		; Speichere den Wert wieder in 10h
	sep	#$20	; Setze Akku auf 8 Bit
	
	lda	$100e	; Lade den SINE-Offset der Zeile in den Akku
	clc			; Lösche das Carry-Flag
	adc	#$fe	; Verringere den SINE-Offset um 2
	sta	$100e	; Speichere den Zeilenoffset wieder
	inc	$1008	; Erhöhe den Text-Offset um 1, um das nächste  ; Zeichen zu lesen
	bra	Flex1	; springe zu Flex1
enddraw:
	lda	#$00		
	sta	$10			
	lda	#$80		
	sta	$11	; Lade den Wert 8000h in 10-11h. 12h ändert    ; sich nicht
	stz	$1008	; Setze den Text-Offset auf null zurück
	stz	$1004	; Setze den Buchstabencounter auf null zurück
	inc	$100a	
	inc	$100a	; Erhöhe den Absolut-SINE-Offset um 2
	rts


; Die WaitVb (Virtual Blank) Routine wartet, bis der Bildschirm mit neuen   ; Daten versorgt werden kann.
WaitVb:	
	lda	$4210	; Hier wird das NMI-Flag zurückgesetzt, indem  ; es gelesen wird. Dadurch wird ein NMI-Prozess ; angestossen, an dessen Ende das Flag wieder   ; gesetzt wird. Dieser Prozess ist             ; erforderlich, um die Anzeige neu schreiben zu ; können.
	bpl WaitVb	; Das NMI-Flag soll high sein. Sollte das nicht ; der Fall sein, 
			; springt bpl zu WaitVb.
	rts


; Diese Funktion leert den VRAM und schreibt das Buchstaben-Charset hinein, ; damit später die Buchstaben anhand dieses Charsets auf dem Bildschim     ; angezeigt werden können.
Copy_Gfx:
	ldx	#$0000		
Clearvr:
	stx	$2116	; Wähle VRAM-Adresse durch das X-Register
	stz	$2118		
	stz	$2119	; Lösche die Daten des VRAM an der Stelle
	inx		; Erhöhe das X-Register
	cpx	#$0000	; Prüfe, ob X wieder null erreicht hat
	bne	Clearvr	; Ist der RAM noch nicht zuende, springe zu    ; Clearvr

	ldx	#$0000	; Lade X mit null
	txy		; Kopiere null auch nach Y
Chardouble:			
	lda	Charset,y	; Lese das Y-te Byte des Charset on den Akku
	sta	$7ea000,x	; Speichere das Byte im RAM, an der Stelle     ; 7ea000h + X
	inx		; Erhöhe X um 1
	sta	$7ea000,x	; Speichere dasselbe Byte im RAM um eine Stelle ; im RAM weiter. Dadurch wird jeder Buchstabe   ; doppelt so hoch
	inx		; Erhöhe X um 1
	iny		; Erhöhe Y um 1
	cpy	#$0200	; Prüfe ob alle Bytes aller Buchstaben gelesen ; wurden
	bne	Chardouble	; Wenn noch nicht alle Bytes gelesen wurden,   ; springe zu Chardouble
	rts
	

; Diese Funktion kopiert die verwendeten Farben für Hintergrund und Schrift ; in den Farb-RAM Die Farben sind 16 Bit lang und im 0rrrrrgggggbbbbb-     ; Format gespeichert (0: nicht relevant, r: rot, g: grün, b: blau)
Copy_colors:
	stz	$2121	; Adresse 00h im Farb-RAM
	lda	#$FD	; High Byte des Hintergrundes
	sta	$2122
	lda	#$FF	; Low Byte des Hintergrundes
	sta	$2122
	lda	#$7C	; High Byte der Textfarbe
	sta	$2122
	lda	#$00	; Low Byte der Textfarbe
	sta	$2122
	rts


; Diese Funktion löscht die genutzten Hintergründe, indem sie sie mit      ; leeren Tiles füllt. Danach werden neue Tiles definiert, die später mit    ; den Werten für die Buchstaben gefüllt werden sollen.
Make_tiles:
	ldx	#$7400			
	stx	$2116	; Wähle die Adresse 7400h im VRAM aus          ; (Hintergrund 1)
			; Auf diesem Hintergrund wird d. Text angezeigt
	ldx	#$0000	; Initialisiere X als Counter
clearscreen:
	lda	#$00		
	sta	$2118		
	lda	#$01
	sta	$2119	; Lösche den Hintergrund, indem leere Tiles     ; genutzt werden
	inx		; Erhöhe X
	cpx	#$0400	; Prüfe, ob Alle Tiles des Hintergrundes        ; geleert wurden
	bne	clearscreen	; Wenn nicht, springe zu clearscreen
	ldx	#$7800		
	stx	$2116	; Wähle die Adresse 7800h im VRAM aus          ; (Hintergrund 2). Dieser Hintergrund ist nicht ; zu sehen, ausser am rechten Rand, wenn der   ; erste Hintergrund verschoben wird.
	ldx	#$0000	; Initialisiere X als Counter
clearscreen2:
	lda	#$00
	sta	$2118		
	lda	#$01		
	sta	$2119	; Lösche den Hintergrund, indem leere Tiles    ; genutzt werden
	inx		; Erhöhe X
	cpx	#$0400	; Prüfe, ob Alle Tiles des Hintergrundes       ; geleert wurden
	bne	clearscreen2	; Wenn nicht, springe zu clearscreen2

; Dieser Teil initialisiert die Tiles, auf denen später der Text       ; dargestellt wird. Die Tiles haben einen Inhalt, der für das weitere   ; nicht relevant ist, und wie folgt aussieht:
	;    00h   08h   10h ... (32 Spalten Breite)
	;    01h   09h   11h ...
	;    02h   0Ah   12h ...
	;    03h   0Bh   13h ...
	;    04h   0Ch   14h ...
	;    05h   0Dh   15h ...
	;    06h   0Eh   16h ...
	;    07h   0Fh   17h ...
	
	ldx	#$7540		
	stx	$2116	; Wähle die Adresse 7540h im VRAM aus
	ldx	#$0000	; Initialisiere X als Spaltenzähler
drawchar:
	lda	$1000	; Lade den Wert des Zeilenzählers (Erste Zeile, ; erste Spalte) in den Akku
	sta	$1001	; Speichere den Akku zur späteren Verwendung
drawflexpattern:
	lda	$1001	; Lade das aktuelle Byte
	sta	$2118	; Schreibe es in den VRAM
	stz	$2119	; Keine Farbpalette dazu auswählen
	lda	$1001	; Lade das aktuelle Byte nochmal
	clc
	adc	#$08	; Erhöhe das Byte um 8, um die nächste Zeile zu ; erhalten. Die Zählreihenfolge ist vertikal,  ; deswegen müssen 7 Byte übersprungen werden,  ; um bei einer Spaltenhöhe von 8 Byte in       ; dieselbe Zeile der nächsten Spalte zu         ; gelangen
	sta	$1001	; Aktuelles Byte rückspeichern
	inx		; Spaltenzähler erhöhen
	cpx	#$0020	; Prüfe, ob alle 32 Spalten bearbeitet wurden
	bne	drawflexpattern
			; Wenn nicht, springe zu drawflexpattern
	ldx	#$0000	; Setze den Spaltenzähler wieder zurück
	inc	$1000	; Erhöhe den Zeilenzähler um 1
	lda	$1000	; Lade aktuelles Byte (Nächste Zeile, erste    ; Spalte)
	cmp	#$08	; Prüfe, ob alle Zeilen bearbeitet wurden
	bne	drawchar	; Wenn nicht, springe zu drawchar
	rts


; Diese Funktion löscht alle relevanten Bereiche im RAM. Der Bereich       ; 7e8000h - 7e8800h ist für die Grafikdaten des anzuzeigenden Textes,
; der Bereich 7e7000h - 7e7020h speichert die Buchstaben in Rohform.
Clear_ram:
	ldx	#$0000	; Lade X mit null
clearram:
	lda	#$00	; Lade Akku mit null
	sta	$7e8000,x	; Speichere null an der Stelle 7e8000h + X
	inx		; Erhöhe X
	cpx	#$0800	; Prüfe, ob der komplette Bereich geleert wurde
	bne	clearram	; Wenn nicht, springe zu clearram

	ldx	#$0000	; Setze X wieder auf null
clearscrolltext:
	lda	#$20	; Lade den Akku mit 20h (Der Wert steht für ein ; Leerzeichen)
	sta	$7e7000,x	; Schreibe den Wert in die Speicherstelle      ; 7e7000 + X
	inx		; Erhöhe X
	cpx	#$0040	; Prüfe ob alle Werte, in denen Text           ; gespeichert wird, überschrieben wurden
	bne	clearscrolltext	; Wenn nicht, springe zu clearscrolltext
	rts


; Dies sind die Werte, die die Sinuskurve bilden, welcher der Text folgt.
SINE:
 .db  32,32,33,34,35,35,36,37,38,38,39,40,41,41,42,43,44,44,45,46
 .db  46,47,48,48,49,50,50,51,51,52,53,53,54,54,55,55,56,56,57,57
 .db  58,58,59,59,59,60,60,60,61,61,61,61,62,62,62,62,62,63,63,63
 .db  63,63,63,63,63,63,63,63,63,63,63,63,62,62,62,62,62,61,61,61
 .db  61,60,60,60,59,59,59,58,58,57,57,56,56,55,55,54,54,53,53,52
 .db  51,51,50,50,49,48,48,47,46,46,45,44,44,43,42,41,41,40,39,38
 .db  38,37,36,35,35,34,33,32,32,31,30,29,28,28,27,26,25,25,24,23
 .db  22,22,21,20,19,19,18,17,17,16,15,15,14,13,13,12,12,11,10,10
 .db   9, 9, 8, 8, 7, 7, 6, 6, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2
 .db   1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 .db   1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7
 .db   7, 8, 8, 9, 9,10,10,11,12,12,13,13,14,15,15,16,17,17,18,19
 .db  19,20,21,22,22,23,24,25,25,26,27,28,28,29,30,31


; Dies sind die Buchstaben, die später auf dem Bildschirm angezeigt werden. 
; Das Charset wurde mit dem Cyber Font-Editor V1.4 erstellt, das aber      ; leider nicht kostenlos zu bekommen ist.
Charset:
;==========================================================================
; Cyber Font-Editor V1.4  Rel. by Frantic (c) 1991-1992 Sanity Productions 
;==========================================================================
	.db	$0	
	.db	$3c,$42,$99,$a1,$a1,$99,$42,$00	;' '
	.db	$3e,$60,$c6,$fe,$c6,$c6,$66,$00	;'!'
	.db	$fc,$06,$ce,$fc,$c6,$ce,$fc,$00	;'"'
	.db	$3e,$60,$c0,$c0,$c0,$c6,$7c,$00	;'#'
	.db	$fc,$06,$c6,$c6,$cc,$dc,$f0,$00	;'$'
	.db	$fe,$00,$c0,$f8,$c0,$e6,$7c,$00	;'%'
	.db	$fe,$00,$c0,$f8,$c0,$c0,$60,$00	;'&'
	.db	$7c,$e6,$c0,$ce,$c6,$ce,$7c,$00	;'''
	.db	$c6,$06,$c6,$fe,$c6,$c6,$66,$00	;'('
	.db	$fc,$00,$30,$30,$30,$30,$7c,$00	;')'
	.db	$7e,$00,$18,$18,$98,$d8,$70,$00	;'*'
	.db	$c6,$0c,$d8,$f0,$d8,$cc,$46,$00	;'+'
	.db	$c0,$00,$c0,$c0,$c0,$d8,$f6,$00	;','
	.db	$26,$70,$fe,$d6,$d6,$c6,$66,$00	;'-'
	.db	$66,$e0,$f6,$fe,$ce,$c6,$66,$00	;'.'
	.db	$7c,$e6,$c6,$c6,$c6,$ce,$7c,$00	;'/'
	.db	$fc,$06,$c6,$fc,$c0,$c0,$60,$00	;'0'
	.db	$7c,$e6,$c6,$c6,$c6,$ce,$76,$00	;'1'
	.db	$fc,$06,$c6,$fc,$d8,$cc,$66,$00	;'2'
	.db	$7c,$e6,$c0,$7c,$06,$ce,$7c,$00	;'3'
	.db	$fc,$00,$30,$30,$30,$30,$18,$00	;'4'
	.db	$c6,$c0,$c6,$c6,$c6,$6e,$3e,$00	;'5'
	.db	$c6,$c0,$c6,$c6,$66,$36,$1c,$00	;'6'
	.db	$66,$c0,$c6,$d6,$fe,$76,$32,$00	;'7'
	.db	$66,$e0,$7c,$18,$7c,$ee,$66,$00	;'8'
	.db	$c6,$c0,$c6,$6c,$38,$38,$38,$00	;'9'
	.db	$7e,$46,$0c,$18,$30,$66,$7c,$00	;':'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;';'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'<'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'='
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'>'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'?'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'@'
	.db	$18,$18,$18,$18,$18,$00,$0c,$00	;'A'
	.db	$6c,$6c,$36,$00,$00,$00,$00,$00	;'B'
	.db	$00,$6c,$fe,$6c,$6c,$fe,$6c,$00	;'C'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'D'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'E'
	.db	$00,$00,$00,$00,$00,$00,$00,$00	;'F'
	.db	$0c,$0c,$18,$00,$00,$00,$00,$00	;'G'
	.db	$30,$60,$60,$c0,$60,$60,$30,$00	;'H'
	.db	$18,$0c,$0c,$06,$0c,$0c,$18,$00	;'I'
	.db	$10,$54,$38,$fe,$38,$54,$10,$00	;'J'
	.db	$00,$10,$10,$7c,$10,$10,$00,$00	;'K'
	.db	$00,$00,$00,$00,$00,$18,$30,$00	;'L'
	.db	$00,$00,$00,$7c,$00,$00,$00,$00	;'M'
	.db	$00,$00,$00,$00,$00,$30,$30,$00	;'N'
	.db	$00,$06,$0c,$18,$30,$60,$c0,$00	;'O'
	.db	$7c,$e6,$c6,$c6,$c6,$ce,$7c,$00	;'P'
	.db	$70,$c0,$30,$30,$30,$30,$38,$00	;'Q'
	.db	$3c,$60,$06,$1c,$30,$66,$7c,$00	;'R'
	.db	$fc,$00,$06,$3c,$06,$c6,$7c,$00	;'S'
	.db	$1c,$20,$6c,$cc,$fe,$0c,$0e,$00	;'T'
	.db	$fe,$00,$c0,$fc,$06,$ce,$7c,$00	;'U'
	.db	$3c,$66,$c0,$fc,$c6,$ce,$7c,$00	;'V'
	.db	$7e,$00,$06,$06,$0c,$0c,$0c,$00	;'W'
	.db	$7c,$e0,$c6,$7c,$c6,$ce,$7c,$00	;'X'
	.db	$7c,$e0,$c6,$7e,$06,$ce,$7c,$00	;'Y'
	.db	$00,$00,$00,$18,$00,$18,$00,$00	;'Z'
	.db	$00,$00,$00,$18,$00,$18,$30,$00	;'['
	.db	$18,$30,$70,$e0,$70,$30,$18,$00	;'\'
	.db	$00,$00,$3c,$00,$3c,$00,$00,$00	;']'
	.db	$30,$18,$1c,$0e,$1c,$18,$30,$00	;'^'
	.db	$7c,$c6,$66,$0c,$18,$00,$18,$00	;'_'

; Dieser Text wird auf dem Bildschirm angezeigt. Es kann jeder beliebige   ; Text angezeigt werden, solange die Zeichen im Charset vorhanden sind, und ; die Länge in der Scrollfumktion entsprechend eingetragen ist.
TEXT:
	.db	"   DIES IST EIN SCROLLENDER TEXT"
	.db 	". UND DAS TOLLSTE IST, ER DREHT "
	
.ends
