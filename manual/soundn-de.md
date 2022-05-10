SOUND'N'SAMPLER ist ein Entwicklungs-paket, bestehend aus einem speziellen HIGHSPEED-Analog/Digital-Wandler & 'ner Menge Software. Sie koennen damit MUSIK, SPRACHE & GERAEUSCHE digitalisieren, dann modifizieren, editieren, verdrehen, Speed & AMP variieren, ... , und dann natuerlich in Ihre Programme einbinden (auch in BASIC !). Alles kein Problem !
DEMO => START druecken ...

# \*\*\*SOUND'N'SAMPLER - (C) 1987 Ralf David \*\*\*  ANLEITUNG :

(Anderungen vorbehalten !)

Benotigt wird :

- ATARI XL/XE mit 64k (oder mehr)
- Diskdrive
- Monitor (Fernseher) mit Tonausgabe
- Tonquelle (zB. Kassetenrecorder)
- Oberspielkabel (Parallelkabel)

Optional :
- Tapedeck/Tonbandgerat und gutes Mikrofon


Bevor es mit harter Theorie losgeht, etwas Praxis :

1. Floppy & Computer ausschalten
2. SOUND'N'SAMPLER Modul in Port 1 (sonst lauft nix)
3. Floppy einschalten, Diskette einiegen, Hebei schliessen
4. Computer einschalten
    - der DIGITAL-DATA-EDITOR wird gebootet
    - der Hauptbildschirn erscheint
5. Drucken Sie jelzt auf "L" ("LOAD" leuchtet in Menu auf) und tipped Sie "DEMO.SND" & RETURN
    - ein Demofile wird geladen
6. Drucken Sie "O" fur "OUTPUT"
    Sir horen die Demo
7. Dann OPTION und noch einmal "O"
8. CONTROL+"R", dann "O"
    - die Musik wird ruckwarts gespielt
9. Drucken Sie wieder CONTROL+"R", dann OPTION (SSS-MODE nub "OFF" sein), und 10 mal auf "<", dann "O"
10. 20 mal auf ">" und wieder "D"
11. Nehmen Sie die Disk aus dem Laufwerk und experimentieren Sie ...

## DIGITAL-DATA-EDITOR :

Der Screen :

Titel & Copyright

(B) Amplitudenanzeige & Bildschirnmodus

    Speichermodell mit Pointern (Zeiger)

(E) Direkte Wiedergabe & Pointerposition Aktuelle Arbeitsgeschwindigkeit

    Menu

Zeile fur Text-I/O (zB. Filename)


Der Balken (C) in der Mitte des Bildschirms stellt den zur Vrefugung tehenden Soundspeicher dar. Ganz links ist die logische Position $00, ganz rechts die logische Position $D0F
. Physikalisch ist das der Speicherbereich von $2700 bis £D000 und von $D000 bis $FFFF. Durch diese interne Unrechnung hat der User einen leicht zu uberschauenden und einfach zu bear beitenden Soundspeicher.

    $FFFF     -     $2700     -     $0800    =    $D0FF
    RAMTOP          definierte      Hardware I/O  freier
                    Grenze                        Speicher

Da nur die 3 hochstwertigen Stellen genommen werden ($DOF anstatt $DOFF), konnen alle Operationen am Soundspeicher bis auf 16 Byte genau ausgefuhrt werden, was mehr als genus ist. Auf dem Balken sind 8 Zeiger (Pointer) verteilt, von denen Nr. 1 & 8 fest auf $000 und $D0F stehen. Zeiger 2-7 kann man beliebig positionieren 2 von den 8 Zeigern (Pointern) blinken inmer. Alle noglichen Funktionen beziehen sich auf genau diesen Speicherbereich, der von den blinkenden Pointern eingeschlossen ist (zB. wird dieser Bereich abgespielt oder auf Disk gespeichert) Durch einfaches Tippen der Zeigernummer kann man die blinkenden Pointer auswahlen. Verschoben werden die Pointer mit den Kursortasten :
    "+" & "*" fur Pointer mit der niedrigeren Nummer
    "-" & "+" fur Pointer mit der hoheren Nunner
(wobei Pointer 1 und 8 wie erwahnt unbeweglich sind)
Druckt man gleichzeitig CONTROL, dann geht die Bewgung 16x so schnell. Die aktuelle Pointerposition kann man in Feld (E) ablesen.

Die Amplitudenanzeige (A) zeigt die aktuelle Amplitude bzw. Aussteuerung des Eingangssignals am A/D-Wandler. Wenn ein Eingangssignal anliegt, sollte man die Aussteuerung mit dem Drehknopt am A/D-Wandler so einstellen, dab die Aussteuerungsmarke im Durschschnitt auf allen 4 Positionen etwa gleichmabig oft herumspringt, wobei die mittleren 2 Positionen ruhig ein wenig vevorzugt sein konnne. Dann hat man meistens den optimalen Klang (letztendich sollte aber doch das Ohr entschiden !). Der Aleich erfolgt moglichst im DIRECT MODE, was bedeutet, dab das Eingangssignal zwar direkt ausgegeben wird, jedoch noch nich aufgenommen wird. Dazu nub bei (D) das \<D\> invers aufleuchten, sonst START drucken. Wichtig zu wissen ist, dab die Tonqualitat im DIRECT MODE naturliich nicht die Beste sein kann, weil das Programm in diesen Fall ja nicht nur fur den Sound zu sorgen hat, sondern weil "ganz nebenbei" ja noch der DIGITAL-DATA-EDITOR lauft !

SSS, das heibt SCREEN SYNCRONIZED SOUND, gibt Ihnen die Moglichkeit, den Bildschirm bei der Tonaugabe eingeschaltet zu lassen. Die entsprechende Anzeige is (B), und umgeschaltet wird mit OPTION. Aufgrund der Syncronisation kann die Aufnahme/Wiedergabe-Geschwindigkeit hier nicht ganz frei gewahlt werden. Dafur gibt es hier 5 Modi, mit denen das Wichigste Abgedeckt ist. Die Modi konnen mit SELECT beliebig gewechselt werden, wenn SSS  =  ON! ist. Die Modusnummer steht dann direkt hinter der SPEED-Anzeige bei (F). Die Modi 1-3 unterscheiden sich nur in der Wiedergabegeschwindigkeit, die Mode 4 & 5 haben die gleich Geschwindigkeit wie Modus 2, der Ton wird aber so verzerrt, dab ein "roboterartiger" Blechsound dabei herauskommt.

Die Aufnahme/Wiedergabe-Geschwindigkeit wird mit "<" und ">" verstellt. Bei (F) kann man die aktuelle Einstellung ablesen. Wie auch bei der Pointerpositionsanzeige, so erfolgt auch hier die Angabe im Hexadezimalsystem. Lassen Sie sich dadurch nicht irritieren : Eine Dezimalzahl wurde auch nicht mehr bringen, weil es hier keinen Sinn hat, den "echten" Wert zu wissen. Es reicht hier vollig aus, wenn man Hexzahlen unterscheiden kann, ug sich verschiedene Geschwindigkeiten oder Positionen merken zu konnen. Uberall, wo es auf den Wert der Zahl ankommt (ZB. Fehlermeldungen beim Disk I/O), werden naturlich dezimale Zahlen ausgegeben.

## DIE MENU-FUNKTIONEN :

**+ INPUT :** mit CONTROL+"I" anwahlen    
Vom A/D-Wandler werden mit der durh SPEED festgelegten Abtastrate (auch bei SSS) Sounddaten eingelesen und im Bereich zwischen den blinkenden Pointern abgelegt, bis der Bereich voll ist. Mit der HELP-Taste kann man die Aufnahme abbrechen. Bei (E) steht dann die Abbruchposition.

**OUTPUT :** MIT "O" anwahlen    
Der Bereich zwischen den blinkenden Pointern wird mit der durch SPEED oder durch den SSS-MODE bestimmten Geschwindigkeit abgespielt. Mit HELP kann gestoppt werden. Bei (E) steht dann die Abbruchposition.

**POINTER :** mit "P" anwahlen    
Nachdem "P" gedruckt wurde, und POINTER invers autleuchtet, mud eine Zahll von 2 bis 7 gedruckt werden, um einen Pointer zu bestimmen. Jede andere Taste beendet POINTER ! Mit "+" & "*" (&CONTROL) kann man den Pointer jetzt verschieben. Die aktuelle Position steht bei (E). Mit RETURN wird beendet.

**DUPLICATE :** mit "D" answahlen    
Wenn "D" gedruckt wurde, wird bei (H) nach dem Zielpointer gefragt. Hier mub dann einfach eine Zahl von 1 bis 7 eingegeben werden. Es wird dann der Bereich zwichen den blinkenden Pointern auf den    
Bereich hinter den Zielpointer kopiert:

blinken  Ziel  Ende

(2 4)(5 ?)  kopiert

Die Endposition des Zielbereiches (?) steht bei (E).

**SAVE :** mit "S" anwahlen    
Speichert den Bereich zwischen den beiden blinkenden Pointern auf Disk. Bei (C) wird nach der Filespec gefragt. Solange man im Texteingabemodus befindet, kann man mit ESC abbrechen. Nach ein Fehler gehts nach Druck einer beliebigen Taste weiter.

**LOAD :** mit "L" anwahlen    
Ladt ein anzugebendes File in den Bereich zwischen den blinkenden Pointer UND DARUBER HINAUS, wenn das File langer ist. Wenn das File kurzer ist, erscheint ERROR 136. Dieses ist jedoch kein echter ERROR, sondern nur die Information, dab das Fileende (EOF) erreicht wurde ! Also keine Panik !

**CHAIN :** mit "C" anwahlen    
Hangt an ein bestehendes File den Bereich zwischen den blinkenden Pointern an. Sonst wie SAVE.

DISK-I/O!    
Sie werden bemerken, dab die I/O-Routine etwas langsam zu sein scheint. Das hat seinen guten Grund, und labt sich wegen des knappen Speichers (Sound Data geht vor !) nicht beheben. (Falls Sie jedoch das 1050 TURBO Modul haben, sollten Sie Turbodrive nach PAGE 6 (extra freigehalten!) booten und eine NORMAL-formatierte Disk benutzen. Die 70000 Baud gleichen dann die langsame CIO wieder aus !)

**AMP-CTRL :** mit "A" anwahlen    
Der A/D-Wandler lost auf 4 Spannungspegel auf. Er liefert jedoch nicht etwa 0.1 Volt ... , sondern immer nur die Zahlen 0 bis 3. Zum Abspielen konnen Sie jetzt jeder vom A/D-Wandler gelieferten Spannungsstufe eine Spannung von 0 bis 15 (nicht Volt!) zuweisen. Dadurch haben Sie die Linearitat und die Lautstarke der Wiedergabe in der Hand. Nach Aktivierung der Funktion wird die aktuell gultige Spannugsfunktion angezeigt, und gefragt, ob eine anderung erwunscht ist. Nach "Y" fur YES kann die neue Funktion eingegeben werden.

Syntax :  hexzahl(0-F),hexzahl(0-F),hexzahl(0-F),hexzahl(0-F) RETURN

Fur eine lineare Wiedergabe muben es Werte in auf oder absteigender Reihenfoige mit gleichen Abstanded sein. Je grober die Abstande, desto lauter :

leise: 0,1,2,3 est zB. gleich 5,6,7,8
  .    0,2,4,6     =          C,A,8,6
  .    0,3,6,9
  .    0,4,8,C
laut : 0,5,A,F

Simulation eines 1 BIT A/D-Wandler :
       0,0,7,7

**+REVERSE :** mit CONTROL+"R" anwahlen    
Dreht den Bereich zwischen den beiden blinkenden Pointern so um, dab das Stuck bei der Wierdergabe ruckwarts gespielt wird.

## AUFNAHMEN :

Zur Aufnahme mub der A/D-Wandler in Port 1 stecken und der Digital-Data-Editor geladen sein. Auberdem nub der A/D-Wandler Uber ein passendes Kabel mit dem Ausgang eines Kassettenrekorders, Plattenspielers etc. verbunden sein. Der DIRECT MODE solite aktiv sein (invers <\D\> bei (D), sonst START), und der Drehknopf am Wandler ganz nach links gedreht sein. Tonquelle einschalten (es mub jetzt was auf dem Draht sein !) und den Knopf langsam nach rechts (Uhrzeigersinn) drehen bis das Erwartete gut zu horen ist (lies ach zu (A)).

    WENN SIE NICHTS HOREN !!!   CHECKLISTE :
  - DIRECT MODE aktiv ?
  - Steckt Wandler richtig in Port 1 ?
  - Lauft Tonquelle ?
  - Lautstarkeregler am Monitor ok ?
  - AMPT-CTRL flackert ein wenig & etwas knacken im Lautsprecher ? Dann Knopt nach rechts drehen. - Wenn das nicht hilft, dann kommt hochstwahrscheinlich zu wenig Spannung am Modul an : andere Tonquelle und/oder anderes Kabel versuchen
  - Falsches uberspielkabel ? Es gibt 2 Typene :

    1. (Parallelkabel)      2.

    Ein Parallelkabel mub es sein !

Die eingestelle SPEED sollte zwischen $01 und $50 liegen, woei je niedriger, je besser, abe rauch umso kurzer gilt. Fur musik hat sich SSS-MODUS l bewahrt, fur Sprache kann man je nach Stimme (tief sollte sie sein) bis $50 gehen. Sehr entscheident fur die Qualitat de rder Aufnahme ist die Qualitat de rSoundvorlage !!! (zb. auf Kassette). Als Abspielgerat reicht ein einfacher Rekorder (Die Sounddemos wurden zB. mit einem kleinen billigen Monorekorder Baujahr 1975 gemacht (nicht aufgenommen!)). Die soundvorlage sollte kein allzu komplexes Frequenzspektrum haben, was bei Musik manchmal Probleme bereitet. Sprachaufnahmen sollten mit tiefen Stimmen gemacht werden, weil dann eine niedrigere Abtastrate ausreicht (SPEED grober). Auberdem sollten die Tonvorlagen bei Sprache moglichst perfekt sein (gute Dynamik, nicht ubersteuret). Fur solche Aufnahmen braucht man gute Mikrofone und eine gute Anlage. Wenn nun alles zur Zufriedenheit eingestellt ist, braucht man nur noch CONTROL+"i" drucken, und es wird digitalisiert !

## VERWENDUNG DE SOUNDFILES :

Nachdem Sie Ihr Soundfile mit "S" auf Disk gespeichert haben, konnen Sie daraus im einfachsten Fall nur eine Sounddemo machen, oder aber Sie bauen das Soundfile in eigene Programme ein :

DEMOS werden ganz einfach mit dem DMEOGENERATOR gemacht (DEMOGEN.COM laden), zu dem eigentlich keine weitere Erklarungen notig sind. Einfach B aufrufen und Parameter einstellen, eventuell mit C ein Titelbild erstellen, und mit D absaven. Alles Andere ist optional.

## EINBAU IN PROGRAMME :

Im Prinzip lauft das so ab, dab Sie in Ihren Programm am Anfang kurz eine Laderoutine anspringen, die die Sounddata schnell (Gegensatz zum DIGITAL-DATA-EDITOR, weil ohne DOS&CIO) einladt. Abgespielt werden die Sounddata (ode rTeile daraus) durch Ansprung einer Abspielroutine.

## Die Laderoutine :

"XLOAD.LST" benotigt 2 Parameter :
- Der Filename : Darf keine Deviceangabe enthalten und mub 8 Stelle lang sein, sonst mit Spaces auffullen. Keinen Punkt setzen !
- Der Extender mub 3-Stellen lang sein, sonst auch hier mi t Spaces auffullen. ZB.: ADR("FILENAMEEXT") oder ADR("DEMO    SND")
- Adresse : Wohin mit den Data ? Wenn man mi t22k auskommt, sollte der Bereich unter dem ROM genutzt werden, also zB. 40960 angeben. Der Hardware-I/O ($D000-$D7FF) wird autmatisch verrechnet. zur Sicherheit werden nur Adressen von 7680-63400 angenommen (sonst ERROR 255).    
ZB.: ERROR=USR(ADR(LD$),ADR("FILENAMEEXT"),20000)    
Das Ende des gerade geladenen Soundfiles steht (direkt nach dem Laden) in 220/221 :    
END=PEEK(220)+256*PEEK(221)

## DIE AUSGABE-ROUTINEN :

Mit den beiden Routinene "XOUT.LST" & "XOUT1.LST" Kann der Sound ausgegeben werden. Beim Aufruf dieser Routinen konnen alle Parameter neu verstellt werden, die auch im DIGITAL-DATA-EDITOR verstellt werden konnen :

SSS   : 0 = kein SSS, 1 = SSS    
SYNC  : wenn SSS=1 -> 0,1,3,8,16 entsprechem den SSS-MODI 1 bis 5    
SPEED : wenn SSS=0 -> Abspielgeschwindigkeit (1-255)    
F0-F3 : Amplitudenfunktion , wie AMPT-CTRL (zB. 0,3,6,9)    
START : Adresse, wo die Sounddata beginnen
END   : Adresse, bis wohin die Data abgespielt werden sollen

IDATA : Adresse, wo das Interpreterprogram steht (<256 = kein Aufruf)    
TIME  : Haufigkeit des Interpreteraufrus (0 = kein Aufruf)

### XOUT.LST :

X=USR(ADR(0$),SSS,SYNC,SPEED,F0,F1,F2,F3,START,END)

Es kann bbei der Soundwiedergabe regelmabig ein Maschineenprogramm aufgerufen werden :    
 0$(187,187)=CHR$(255) -> kein Aufruf
 0$(187,187)=CHR$(X) -> Aufruf bei Rasterzeile X (1-155) Das Maschinenprogramm mub an Stelle einiger de rvielen inversen "j" am Ende des 0$ stehen (oder von dort aus verzweigen (zB. JSR $0600)). Die Lange von 0$ dabei NICHT verandern !

 ### XOUT1.LST :

 X=USR(ADR(01$),SSS,SYNC,SPEED,F0,F1,F2,F3,START,END,IDATA,TIME)

 Hier gibt es jetzt den Interpreter, der wahrend der Soundausgabe regelmabig aufgerufen werden kann, um schnell mal was umzupoken. Das zweitletzte Parameter (IDATA) gibt die Adresse des speziellen Interpreterprogramms an, das letzte Parameter gibt die Haufigkeit des Aufrufs an : 1 = sehr oft , 2 bis 254 = immer seltener der Interpreter versteht 8 Befehle :

 Befehl : Code  Paramter          Funktion
--------------------------------------------
 RESET  :    0  keine             setzt Programmzahler des Interpreters
                                  auf 0 zuruck
 POKE   :   10  2Byte,1Byte       schreibt ein Byte in ZIELADResse
                ZIELADR,WERT
 ADD    :   20  2Byte,1Byte       addiert Wert zum Inhalt von ZIELADR
                ZIELADR,WERT
 ADD2   :   30  2Byte,1Byte       addiert Wert zum Inhalt von ZIELADR &
                ZIELADR,WERT      ZIELADR+1 (lo/hi-Byte)
 SUB    :   40  2Byte,1Byte       subtraniert Wert zum Inhalt von ZIELADR
                ZIELADR,WERT
 SUB2   :   50  2Byte,1Byte       subtraniert Wert zum Inhalt von ZIELADR &
                ZIELADR,WERT      ZIELADR+1 (lo/hi-Byte)
 BLOCK  :   60  2Byte,2Byte,1Byte kopiert Speicherbereich der Lange
                QUELLADR,2IELADR,LEN  LEN+1  von QUELLADR nach ZIELADR
 RETURN :  255  keine             Unterbricht Interpreter, und macht mit
                                  Soundausgabe weiter - beim nachsten
                                  Interpreteraufruf gents hier weiter

Ein Programm, welches bei der Soundausgabe die Hintergrundfare laufend andert, sieht dann zB. so aus :
 ADD 255,1  ; 255 wird hier als Farbzahler genommen und um 1 erhoht
 BLOCK 255,53274,0 ; Farbzahler in Hardwarefarbregister schreiben
 RESET      ; zuruck zum Anfang

Das mub jetzt von Hand compilert werden (kein Maschinencode!)

ADD         : 20,     : Code von ADD
        255 : 255,0   : 2-lo/hi-Byte
          1 : 1,      : 1-Byte
BLOCK       : 60,     : Code von BLOCK
        255 : 255,0,  : 2-lo/hi-Byte
      53274 : 26,208, : 2-lo/hi-Byte
          0 : 0       : 1-Byte
RESET       : 0       : Code von RESET

Das Ergebnis : 20,255,0,1,60,255,0,26,208,0,0

Diese Zahlen muben irgentwo in den Speicher gepoket werden oder besser in Form von ATASCII-Zeichen in einem String untergebracht werden.


( LO/HI-Byte Aufspaltung:                    )
( Dient zur Darstellung von Zahlen, die grober als 255 sind, und somit nicht mit einem Byte darstellbar sind. Immer wenn dem Interpreter eine Adresse               )
( als Parameter ubergeben wird, mub die Adresse mit 2 Byte dargestellt werden, da Adressen hier bis 65535 gehen konnen.             )

(   Aufspaltung :                           )
(     Zahl = 53274                          )
(     high-Byte = INT ( Zahl / 256 )        )
(     low-Byte = Zahl - high-Byte * 256   )

(   Ungekehrt :                             )
(     Zahl = low-Byte + high-Byte * 256   )


Sehen Sie sich dazu "XDEMO1.LST" an : Das Interpreterprogramm wird im PGM$ abgelegt, was hier jedoch auf eine umstandliche Art geschieht. Sie konne naturlich auch die ATASCII-Zeichen vorher bestimmen ( ?";CHR$(.) ), und die Zeichen direkt in den String einsetzen ( PGM$="ABCD1234... " ).

Die Aufrufe von Maschinenprogrammen oder des Interpreters funktionieren nur, wenn der SSS-Modus eingeschaltet ist. Desweiteren wird Ihnen auffallen, dab der eingebaute Zeichensatz bei der Soundausgabe nicht "funktioniert". Das liegt daran, dab die ROMs bei der Ausgabe Absgeschaltet werden, um zu den entsprechnden RAMs Zugriff zu haben, In diesem Fall muben Sie vorher einen Zeichensatz irgendwo ins RAM schreiben, wozu Sie ein kleines Maschinenprogramm benutzen sollten. Ein entsprechend in BASIC verpackte Unterprogram ist "FONTCOPY.LST". Ein eigentlich universelles Speicherkopierprogramm, mit dem Sie auch noch andere Dinge, wie zB. vertikale Playerbewegung und Operationen an Bildspeicher, anstellen konnen.

### Noch was :

Die Software ist in keiner Weise kopiergeschutzt. De rGrund dafur ist erstens, dab Sie dadurch die Moglichkeit haben, sich Sicherheitskopien anzufertigen. Falls Sie sich den DIGITAL-DATA-EDITOR auf eine andere Disk kopieren wollen, sollten Sie wissen, dab dieser DOS 2.5 Konfiguration: DRIVE: 1, MAX OPEN: 1 File & NO VERIFY braucht ! Das ganze System ist durch das Urheberrecht geschutzt !
