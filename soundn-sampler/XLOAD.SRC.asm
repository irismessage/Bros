010000           .OPT NO LIST
010100           ;
010200           ;  >>> SOUND'N'SAMPLER <<<
010300           ;  >>>   DATA LOADER   <<<
010400           ;
010500           ; ERR=USR(MC,FNAMEADR,DEST)
010600           ;
010700           *= 20000            ; $4e20
010800           ;
010900           SECBUFF = 1024
011000           ERR = 212
011100           LEN = 214           ; HOW MANY LEFT
011200           LAST = 216          ; BYTES IN SEC
011300           BYTE = 217          ; ACTUAL BYTE
011400           FN.ADR = 218        ; FNAME ADR
011500           WORK.ADR = 220
011600           ;
011700           ;
011800           ; *** GET USR PARAMETER ***
011900           ;
012000           PLA                 ; => STACK READY
012100           ;
012200           LDA #0
012300           STA 213             ; ERRORINIT
012400           ;
012500           PLA                 ; FILENAME ADR
012600           STA FN.ADR+1
012700           PLA
012800           STA FN.ADR
012900           ;
013000           PLA                 ; DESTINATION ADR
013100           CMP #$D0
013200           BCC OK.D0           ; ON HARDWARE IO ?
013300           ADC #$07
013400 OK.D0     CMP #$1E            ; BAD DEST ADR ?
013500           BCS DESTOK
013600           PLA
013700           LDA #255
013800           STA 212
013900           RTS
014000 DESTOK    STA WORK.ADR+1
014100           PLA
014200           STA WORK.ADR
014300           ;
014400           ; *** OPEN FILE ***
014500           ;
014600           LDA #1              ; DRIVE-NUMBER
014700           STA 769             ; todo check these - might be decoding error
014800           LDA #               ;'R READ
014900           STA 770
015000           LDA #               ; <SECBUFF BUFFER
015100           STA 772
015200           LDA # >SECBUFF
015300           STA 773
015400           LDA #               ; <361 DIR.SECTOR
015500           STA 778
015600           LDA #               ; >361
015700           STA 779
015800           ;
015900           ;
016000 MAIN.DIR.LOOP
016100           ;
016200           JSR $E453           ; DISK HANDLER
016300           LDY 771
016400           BMI DERROR
016500           ;
016600           LDX #0              ; FILESPEC.POINTER
016700           DIR.LOOP
016800           LDA SECBUFF,X       ; EXISTS FILE ?
016900           CMP #'C
017000           BEQ NEXT.TST
017100           CMP #'
017200           BEQ NEXT.TST
017300           ;
017400 CMPF      TXA                 ; CMP FILENAMES
017500           PHA
017600           LDY #255
017700 TST.LP
017800           INX
017900           INY
018000           LDA SECBUFF+4,X
018100           CMP (FN.ADR),Y
018200           BEQ TST.LP
018300           CPY #8
018400           BCS FILE.FOUND
018500           PLA
018600           TAX
018700           ; PREPARE NEXT CHECK
018800 NEXT.TST
018900           TXA
019000           CLC
019100           ADC #16
019200           TAX
019300           ;
019400           CPX #128
019500           BCC DIR.LOOP
019600           ;
019700           INC 778             ; NEXT SECTOR
019800           LDA 778
019900           CMP #113            ; OVER 3 SECTORS
020000           BCC MAIN.DIR.LOOP
020100           ;
020200 NO.FILE   LDY #170
020300 DERROR    STY 212
020400           LDA #64
020500           STA $D40E
020600           RTS
020700           ;
020800           ;
020900 FILE.FOUND
021000           PLA
021100           TAX
021200           LDA SECBUFF+1,X
021300           STA LEN
021400           LDA SECBUFF+2,X
021500           STA LEN+1
021600           LDA SECBUFF+3,X
021700           STA 778
021800           LDA SECBUFF+4,X
021900           STA 779
022000           ;
022100           LDA #125
022200           STA LAST
022300           STA BYTE
022400           LDA #0
022500           STA $D40E
022600           ;
022700           ; *** LOAD FILE ***
022800           ;
022900 INPUT.LOOP
023000           ;
023100           INC BYTE            ; NO MORE BYTES
023200           LDA BYTE            ; IN SECTOR ???
023300           CMP LAST
023400           BCC GET.IT
023500           ;
023600           LDA LEN             ; FINISHED ???
023700           ORA LEN+1           ; THEN EOF
023800           BEQ END
023900           ;
024000           LDA #0              ; RESET BYTE
024100           STA BYTE
024200           LDA LEN             ; DECR LEN
024300           BNE D.OK
024400           DEC LEN+1
024500 D.OK      DEC LEN
024600           ;
024700           JSR $E453           ; DISK HANDLER
024800           LDY 771
024900           BMI DERROR
025000           ;
025100           LDA SECBUFF+125    ; NEXT SECTOR
025200           AND #3
025300           STA 779
025400           LDA SECBUFF+126
025500           STA 778
025600           LDA SECBUFF+127     ; LAST BYTE
025700           STA LAST
025800           ;
025900 GET.IT                        ; cmon
026000           ;
026100           SEI
026200           LDA #$FE
026300           STA $D301
026400           LDY #0
026500           LDX BYTE
026600           LDA SECBUFF,X
026700           STA (WORK.ADR),Y
026800           LDA #$FD            ; BASIC & OS ON
026900           STA $D301
027000           CLI
027100           ;
027200           INC WORK.ADR        ; INCR WORK.ADR
027300           BNE INPUT.LOOP
027400           INC WORK.ADR+1
027500           LDA WORK.ADR+1
027600           BEQ END
027700           CMP #$D0
027800           BNE INPUT.LOOP
027900           ADC #$07
028000           STA WORK.ADR+1
028100           BCC INPUT.LOOP
028200           ;
028300           ;
028400 END       LDY #1
028500           STY 212
028600           LDA #64
028700           STA $D40E
028800           RTS
028900           ;
029000           ;
