; Dieses Programm spielt eine vorher definierte Sounddatei ab.
; Die Daten der Sounddatei werden dabei so behandelt, wie sie ein SNES auch ; behandeln würde.
 
.include "Header.inc"
.include "Snes_Init.asm"	; Einbindung der Initialisierungsdateien
 
.define BG1MoveH $7E1A25
.define BG1MoveV $7E1A26
.define BG2MoveH $7E1A27
.define BG2MoveV $7E1A28
.define BG3MoveH $7E1A29
.define BG3MoveV $7E1A2A	; Einige Definitionen von Werten, die laut     ; "Snes_Init.asm" gebraucht werden
 
VBlank:
   	rti	; Definition, die laut "Header.inc" gebraucht  ; wird
    
.define AUDIO_R0 $2140	; Definition der vier Soundports, die für die 
.define AUDIO_R1 $2141	; Kommunikation der SNES-CPU mit der Sound-CPU 
.define AUDIO_R2 $2142	; benötigt werden. Diese Ports sind über 
.define AUDIO_R3 $2143	; Speicherstellen im SNES-RAM abgebildet, die  ; auch von der Sound-CPU, allerdings mit       ; anderen Adressen, angesprochenwerden können. ; Sie Dienen als Ports in beide Richtungen.
 
.define XY_8BIT $10
.define A_8BIT  $20	; Einige Definitionen von Werten, die im       ; Weiteren gebraucht werden
 
.define musicSourceAddr $00fd
; Speicherplatz, der später für die            ; Kopiervorgänge benötigt wird. 
; Hier wird die Quelladresse der Musik           ; gespeichert und hochgezählt.

.define spcFile "OTTest.spc"	; Der Name der Musik-Quelldatei
.define spcFreeAddr $ffa0	; Adresse im RAM des Soundchips, bei der später ; die Init-Routine gespeichert wird
								
; Speicherbank für die erste Hälfte der Daten der Musik-Quelldatei. 
; Im Zuge der Definition werden die Daten gleich aus der Musikdatei in den ; simulierten ROM geschrieben.
.bank 1
.section "musicData1"
spcMemory1: .incbin spcFile skip $00100 read $8000 
		; Kopiervorgang von Datei zu ROM
.ends

; Speicherbank für die zweite Hälfte der Daten der Musik-Quelldatei. 
; Im Zuge der Definition werden die Daten gleich aus der Musikdatei in den ; simulierten ROM geschrieben.								
.bank 2
.section "musicData2"
spcMemory2: .incbin spcFile skip $08100 read $8000
		; Kopiervorgang von Datei zu ROM
.ends
								
; Speicherbank für den Programmcode auf der SNES-CPU
.bank 0
.section "MainCode"
								
dspData:  .incbin spcFile skip $10100 read $0080
; DSP-Daten der Musik-Quelldatei, werden direkt ; in die "MainCode"-Sektion des ROM geschrieben
 audioPC:  .incbin spcFile skip $00025 read $0002
 audioA:   .incbin spcFile skip $00027 read $0001
 audioX:   .incbin spcFile skip $00028 read $0001
 audioY:   .incbin spcFile skip $00029 read $0001
 audioPSW: .incbin spcFile skip $0002a read $0001
 audioSP:  .incbin spcFile skip $0002b read $0001
; Headerinformationen der Musik-Quelldatei,    ; werden direkt in die "MainCode"-Sektion des  ; ROM geschrieben
 
; Hauptprogramm
; Hier wird eine Subroutine aufgerufen, die sich um die Musik kümmert.     ; Danach wird der Hintergrund gefärbt und eine Endlosschleife gestartet.
Start:
	Snes_Init	; Aufruf der Initialisierung des Emulators
     jsr LoadSPC	; Aufruf des Musik-Unterprogramms
     
     ; Färben des Hintergrundes
     sep     #$20	; Akku auf 8 Bit Breite setzen
     lda     #%10000000	; Helligkeit wird auf 0% gesetzt
     sta     $2100
     lda     #%11100000	; Untere 8 Bit der Hintergrundfarbe laden (Hier ; grün)
     sta     $2122
     lda     #%00000000	; Obere 8 Bit der Hintergrundfarbe laden (Hier ; grün)
     sta     $2122
     lda     #%00001111	; Helligkeit wieder auf 100% setzen, damit die ; Farbe angezeigt wird
     sta     $2100
 
Forever:
     jmp Forever	; Endlosschleife
 
; Makro zum Kopieren eines Datenblocks
; Das Makro selbst speichert die übergebenen daten an entsprechenden       ; Stellen des Speichers und ruft ein Unterprogramm auf, das den              ; Kopiervorgang übernimmt.
.macro sendMusicBlockM	; Parameter: Quellsegment, Quelladresse,          ; Zieladresse, Länge
     
    	sep     #A_8BIT	; Akku auf 8 Bit Breite setzen
	lda     #\1	; Lade Quellsegment in den Akku (\1: Erster    ; Parameter)
    	sta     musicSourceAddr + 2
; Speichere Quellsegment an der vorgesehenen   ; Speicherstelle
    	rep     #A_8BIT	; Akku auf 16 Bit Breite setzen
    	lda     #\2	; Lade Quelladresse in den Akku (\2: Zweiter    ; Parameter)
    	sta     musicSourceAddr	; Speichere Quelladresse an der vorgesehenen   ; Speicherstelle
	rep     #XY_8BIT	; X-Register und Y-Register auf 16 Bit Breite   ; setzen
   	ldx     #\3	; Speichere Zieladresse in X-Register (\3:     ; Dritter Parameter)
    	ldy     #\4	; Speichere Länge in Y-Register (\4: Vierter   ; Parameter)
    	jsr     CopyBlockToSPC	; Aufruf des Unterprogramms für den            ; Kopiervorgang
 .endm
 
; Unterprogramm, welches für das eigentliche Abspielen der Musik zuständig ; ist. Hier werden die Programme zum kopieren der Musik und zur Ausführung ; des Abspielvorgangs aufgerufen.
LoadSPC:
	jsr     CopySPCMemoryToRam	
; Subroutine, mittels der die Sounddaten aus   ; dem ROM in den RAM kopiert werden
    	stz     $4200   
    	sei	; Deaktiviert Interrupts und Controllereingaben
    	sendMusicBlockM $7f $0002 $0002 $ffbe
		; Kopiert die Daten vom RAM in den Speicher der ; Sound-CPU
	jsr     MakeSPCInitCode	; Schreibt die Initialisierungsroutine für den ; Soundchip anhand der Headerinformationen
    	sendMusicBlockM $7f $0000 spcFreeAddr $0016
; Speichert den Initcode des Soundprogramms an ; einer freien Speicherstelle im Soundchip-RAM
    	jsr     InitDSP	; Sendet die DSP-Daten der Sounddatei an die   ; Sound-CPU
	rep     #XY_8BIT	; X-Register und Y-Register auf 16 Bit Breite   ; setzen
    	ldx     #spcFreeAddr	; Lade die Speicheradresse des Initcodes der   ; Sounddatei im Soundchip-RAM in das X-Register
    	jsr     StartSPCExec	; Startet die Ausführung der Sound-Schleife
    	cli             
    	sep     #A_8BIT	; Akku auf 8 Bit
    	lda     #$80				
    	sta     $4200	; Reaktiviert interrupts und Controllereingaben
    	rts
 
; Subroutine, mittels der die Sounddaten aus dem ROM in den RAM kopiert    ; werden, vom Datenende an Rückwärts
CopySPCMemoryToRam:
	Rep     #XY_8BIT	; X,Y auf 16 Bit
	ldx.w   #$7fff	; X-Register als Counter auf Anfangswert       ; initialisieren (Rückwärts, also höchster Wert ; beginnt)
CopyLoop:
    	lda.l   spcMemory1,x	; Lade den Inhalt der ersten Speicherbank des   ; ROM an der durch das X-Register vorgegebenen ; Position in den Akku
     sta.l   $7f0000,x	; Speichere den Inhalt des Akku an die         ; Speicherstelle 7f0000 Hex plus den Inhalt des ; X-Register
     lda.l   spcMemory2,x	; Lade den Inhalt der ersten Speicherbank des   ; ROM an der durch das X-Register vorgegebenen ; Position in den Akku
     sta.l   $7f8000,x	; Speichere den Inhalt des Akku an die         ; Speicherstelle 7f8000 Hex plus den Inhalt des ; X-Register
     dex	; verringere den Wert im X-Register um 1
     bpl     CopyLoop	; Springe zu CopyLoop, wenn der Wert im X-     ; Register positiv ist (bpl: Branch if PLus)
     rts
 
; Sendet die DSP-Daten der Sounddatei an die Sound-CPU
InitDSP:
    	rep    #XY_8BIT        	; X,Y auf 16 Bit
    	ldx    #$0000	; X-Register auf 0 setzen
InitLoop:
    	sep    #A_8BIT	; Akku auf 8 Bit
    	txa                    	; Kopiere den Inhalt des X-Registers in den    ; Akku (Hier: Das untere Byte von X)
    	sta    $7f0100         	; Speichere den Inhalt des Akku an die         ; Speicherstelle 7f0100 Hex
    	lda.l  dspData,x       	; Lade den Akku mit dem Wert des Bytes der DSP-; Daten, der vom X-Register angegeben wird
    	sta    $7f0101        	; Speichere den Inhalt des Akku an die         ; Speicherstelle 7f0101 Hex
    	phx                    	; Rette den Inhalt des X-Registers auf den     ; Stack
; Rufe das Block-Kopier-Makro auf, dass die Speicherstellen 7f0100 und ; 7f0101 in den RAM der Sound-CPU schreiben soll.
    	sendMusicBlockM $7f $0100 $00f2 $0002
 
    	rep    #XY_8BIT            
    	plx	; Schreibe den Inhalt von X vom Stack wieder in ; das X-Register
    	inx	; Erhöhe X um 1
   	cpx    #$0080	; Vergleiche X mit 80 Hex
    	bne    InitLoop	; Wenn X geringer, springe zu InitLoop
    	rts
								
; Schreibt die Initialisierungsroutine für den Soundchip anhand der        ; Headerinformationen
MakeSPCInitCode:
	; Es müssen folgende Daten geschrieben werden:
    	; 00-Byte nach 00.
    	; 01-Byte nach 01.
    	; Wert für s nach s.
    	; PSW-Wert auf den Stack.
    	; Wert für a nach a.
    	; Wert für x nach x.
    	; Wert für y nach y.
    	; Lade PSW-Wert vom Stack.
    	; Springe zur Position des Programm-Counters.
 
    	sep     #A_8BIT
 
    	; Push [01]-Wert auf den Stack.
    	lda.l   $7f0001
    	pha
 
    	; Push [00]-Wert auf den Stack.
    	lda.l   $7f0000
    	pha
								
    	; Schreibe Code fürs setzen des [00]-Wertes.
    	lda     #$8f	; mov dp,#imm
    	sta.l   $7f0000
   	pla
    	sta.l   $7f0001
    	lda     #$00
    	sta.l   $7f0002
 
    	; Schreibe Code fürs setzen des [01]-Wertes.
    	lda     #$8f	; mov dp,#imm
    	sta.l   $7f0003
    	pla
    	sta.l   $7f0004
    	lda     #$01
    	sta.l   $7f0005
 
    	; Schreibe Code fürs setzen des s-Wertes.
    	lda     #$cd	; mov x,#imm
    	sta.l   $7f0006
    	lda.l   audioSP
    	sta.l   $7f0007
    	lda     #$bd	; mov sp,x
    	sta.l   $7f0008
 
    	; Schreibe Code fürs pushen von PSW auf den Stack.
    	lda     #$cd	; mov x,#imm
    	sta.l   $7f0009
    	lda.l   audioPSW
    	sta.l   $7f000a
    	lda     #$4d	; push x
    	sta.l   $7f000b
 	
    	; Schreibe Code fürs setzen des Akku-Wertes.
    	lda     #$e8	; mov a,#imm
    	sta.l   $7f000c
    	lda.l   audioA
    	sta.l   $7f000d
 	
    	; Schreibe Code fürs setzen des x-Wertes.
    	lda     #$cd	; mov x,#imm
    	sta.l   $7f000e
    	lda.l   audioX
    	sta.l   $7f000f
 	
	; Schreibe Code fürs setzen des y-Wertes.
    	lda     #$8d	; mov y,#imm
    	sta.l   $7f0010
    	lda.l   audioY
    	sta.l   $7f0011
 
	; Schreibe Code fürs holen von PSW vom Stack.
    	lda     #$8e	; pop psw
    	sta.l   $7f0012
 	
	; Schreibe Code fürs springen.
    	lda     #$5f	; jmp labs
    	sta.l   $7f0013
    	rep     #A_8BIT
    	lda.l   audioPC
    	sep     #A_8BIT
    	sta.l   $7f0014
    	xba
    	sta.l   $7f0015
    	rts
 
; Unterprogramm für den Kopiervorgang
; Dieses Unterprogramm ist für die Kommunikation mit dem Soundchip und das ; Verschieben der Daten vom SNES-RAM in den Sound-RAM zuständig.
; Es verschiebt die Daten anhand der übergebenen Adressen: 
;	Die Quelladresse ist in musicSourceAddr gespeichert
;	Die Zieladresse findet sich im X-Register
;	Die Länge des zu kopierenden Blocks ist im Y-Register gespichert
CopyBlockToSPC: 
	; Warte darauf, dass die Sound-CPU bereit ist.
    	sep     #A_8BIT	; Akku auf 8 Bit
    	lda     #$aa	; Lade den Wert aa Hex in den Akku
WaitLoop1:
    	cmp     AUDIO_R0	; Vergleiche den Wert im Akku mit dem Wert am  ; ersten Soundport
	bne     WaitLoop1	; Sollte dieser Wert nicht anliegen, warte, bis ; er anliegt

   	stx     AUDIO_R2	; Speichere die Zieladresse im Port 3
 
    	phy	; Schreibe den Wert von Y auf den Stack
    	plx	; und lade ihn in X
 
; Start des Kopiervorganges durch senden eines Befehlscodes an die     ; Sound-CPU.
    	lda     #$01				
    	sta     AUDIO_R1	; Lade den Wert 01h in den zweiten Soundport
    	lda     #$cc
    	sta     AUDIO_R0	; Lade den Wert cch in den ersten Soundport
WaitLoop2:
	cmp     AUDIO_R0	; Vergleiche den Wert im Akku mit dem Wert am  ; ersten Soundport
    	bne     WaitLoop2	; Sollte dieser Wert nicht anliegen, warte, bis ; er anliegt

    	ldy     #$0000	; Initialisiere das Y-Register mit 0 als         ; Counter
 
CopyBlockToSPC_loop:
	Xba	; Tausche die Bytes des Akku
    	lda     [musicSourceAddr],y
; Lade den Akku mit dem y-ten zu übertragenden ; Byte
    	xba	; Tausche die Bytes des Akku, so dass das      ; Adressbyte im High Byte des Akkus liegt
	tya		; Lade den Inhalt von Y in A (das untere Byte  ; von Y)
 
   	rep     #A_8BIT	; Akku auf 16 Bit
	sta     AUDIO_R0	; Sende den Inhalt des Akku an den ersten 	    ; Soundport
    	sep     #A_8BIT	; Akku auf 8 Bit
 
WaitLoop3:
	cmp     AUDIO_R0	; Vergleiche den Wert im Akku mit dem Wert am  ; ersten Soundport
    	bne     WaitLoop3	; Sollte dieser Wert nicht anliegen, warte, bis ; er anliegt
 
    	iny	; Zähler hochzählen
    	dex	; Anzahl noch zu sendender Bytes runterzählen
    	bne     CopyBlockToSPC_loop
; Wenn noch Bytes zu senden, springe zu        ; CopyBlockToSPC_loop
 
	ldx     #$ffc9	; Lade den Wert der Startadresse der IPL ROM    ; Routine in das X-Register
    	stx     AUDIO_R2	; Sende den wert an den dritten Soundport
 
    	xba
    	lda     #0	; Lösche das High Byte des Akku
    	xba
 
    	clc
    	adc     #$2	; Stoppe den Counter
 
    	rep     #A_8BIT	; Akku auf 16 Bit
    	sta     AUDIO_R0	; Sende den Inhalt des Akku an den ersten      ; Soundport
    	sep     #A_8BIT	; Akku auf 8 Bit
 
WaitLoop4:
	cmp     AUDIO_R0	; Vergleiche den Wert im Akku mit dem Wert am  ; ersten Soundport
    	bne     WaitLoop4	; Sollte dieser Wert nicht anliegen, warte, bis ; er anliegt
    	rts

; Startet die Ausführung der Sound-Schleife
; Die Startadresse des Initcodes der Sounddatei befindet sich im X-Register
StartSPCExec:
	; Warte darauf, dass die Sound-CPU bereit ist.
    	sep     #A_8BIT	; Akku auf 8 Bit
    	lda     #$aa	; Lade den Wert aa Hex in den Akku
WaitLoop5:
	cmp     AUDIO_R0	; Vergleiche den Wert im Akku mit dem Wert am   ; ersten Soundport
    	bne     WaitLoop5	; Sollte dieser Wert nicht anliegen, warte, bis ; er anliegt
     
    	stx     AUDIO_R2	; Sende die Startadresse an den dritten        ; Soundport
 
; Start der Programmausführung durch senden eines Befehlscodes an die   ; Sound-CPU.
    	lda     #$00				
    	sta     AUDIO_R1	; Lade den Wert 00h in den zweiten Soundport
    	lda     #$cc
    	sta     AUDIO_R0	; Lade den Wert cch in den ersten Soundport
WaitLoop6:
	cmp     AUDIO_R0	; Vergleiche den Wert im Akku mit dem Wert am  ; ersten Soundport
    	bne     WaitLoop6	; Sollte dieser Wert nicht anliegen, warte, bis ; er anliegt
    	rts
 
.ends

