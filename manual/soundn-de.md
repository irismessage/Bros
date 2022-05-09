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
2. SOUND'N'SAMPLER MOdul in Port 1 (sonst lauft nix)
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
