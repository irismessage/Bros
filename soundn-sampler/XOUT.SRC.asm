010000           .OPT NO LIST
010100           ;
010200           ;   >>> SOUND'N'SAMPLER <<<
010300           ;   >>>  DEMO PLAYER    <<<
010400           ;   (C)(P) 1986  RALF DAVID
010500           ;           - 17.11 -
010600           ;
010700           ; X=USR(ADR,SSS,SYNCRES,SPEED,
010800           ;       F0,F1,F2,F3,START,END)
010900           ;
011000           *= 20000
011100           ;
011200           ;
011300           SSS.MODE = 212
011400           SYNCRES = 213
011500           SPEED = 214
011600           FUNCTION.TAB = 215 ; 216/6/8
011700           START.ADR = 219
011800           END.ADR = 221
011900           WORK.ADR = 223
012000           BYTE = 224
012100           ;
012200           ;
012300           ; PARAMETER
012400           ;
012500           PLA                 ; => STACK OK
012600           ;
012700           PLA
012800           PLA
012900           STA SSS.MODE
013000           PLA
013100           PLA
013200           STA SYNCRES
013300           PLA
013400           PLA
013500           STA SPEED
013600           PLA
013700           PLA
013800           ORA #16
013900           STA FUNCTION.TAB
014000           PLA
014100           PLA
014200           ORA #16
014300           STA FUNCTION.TAB+1
014400           PLA
014500           PLA
014600           ORA #16
014700           STA FUNCTION.TAB+2
014800           PLA
014900           PLA
015000           ORA #16
015100           STA FUNCTION.TAB+3
015200           PLA
015300           CMP #$D0
015400           BCC STOKD0
015500           ADC #$07
015600 STOKD0    CMP #$1E
015700           BCC MEMERR
015800 STOK      STA START.ADR+1
015900           PLA
016000           STA START.ADR
016100           PLA
016200           CMP #$D0
016300           BCC EDOKD0
016400           ADC #$07
016500 EDOKD0    CMP #$1E
016600           BCS EDOK
016700           PHA
016800           PHA
016900 MEMERR    PLA
017000           PLA
017100           PLA
017200           PLA
017300           PLA
017400           PLA
017500           PLA
017600           LDA #0
017700           STA 213
017800           LDA #255
017900           STA 212
018000           RTS
018100 EDOK      STA END.ADR+1
018200           PLA
018300           STA END.ADR
018400           ;
018500           ; OUTPUT SELECTION
018600           ;
018700 OUTPUT
018800           ;
018900           LDA #0              ; NO INTERRUPTS
019000           STA $D40E
019100           SEI
019200           LDA #$FE NO ROM
019300           STA $D301
019400           ;
019500           LDA SSS.MODE        ; MODE SELECT
019600           BNE SYNCOUT
019700           ;
019800           ; OUTPUT
019900           ;
020000           LDA #0              ; SCREEN OFF
020100           STA 54272
020200           LDY #1
020300 DAC.LOOP
020400           DEY                 ; BIT COUNTER
020500           BNE PLAY
020600           ;
020700           LDA (START.ADR),Y   ; GET DATA
020800           STA BYTE
020900           LDY #4              ; BIT COUNTER
021000           ;
021100 SINC      INC START.ADR       ; NEXT BYTE
021200           BNE SCMP
021300           INC START.ADR+1
021400           LDA START.ADR+1
021500           CMP #$D0
021600           BNE SCMP
021700           ADC #$07            ; and CARRY(+1)
021800           STA START.ADR+1
021900 SCMP      LDA START.ADR+1     ; END ???
022000           CMP END.ADR+1
022100           BCC PLAY
022200           LDA START.ADR
022300           CMP END.ADR
022400           BCC PLAY
022500 SEND      BCS DAC.END         ; Y => ...
022600           ;
022700 PLAY      LDA                 ; BYTE CALCULATE
022800           ROL A               ; RIGHT BITS
022900           ROL A
023000           ROL A
023100           AND #3
023200           TAX
023300           LDA FUNCTION.TAB,X  ; RIGHT
023400           STA 53761           ; LOUDNESS
023500           LDA BYTE            ; PREPARE NEXT BITS
023600           ASL A
023700           ASL A
023800           STA BYTE
023900           ;
024000           LDX SPEED           ; SPEED LOOP
024100           DX2 DEX
024200           BNE DX2
024300           ;
024400           CLC                 ; => JMP DAC.LOOP
024500           BCC DAC.LOOP
024600           ;
024700           ;
024800           ; SYNCOUT
024900 SYNCOUT
025000           ;
025100           ;
025200           LDY #1
025300           ; WAIT FOR RIGHT SCANLINE
025400 YADC.LOOP
025500           LDA $D40B
025600           CMP WORK.ADR
025700           BEQ YADC.LOOP
025800           TAX
025900           ;
026000           CMP #255            ; AN INTERRUPT ?
026100           BEQ SERVICE.MCP
026200           ;
026300 SYNC      AND SYNCRES         ; RIGHT SYNC ?
026400           BNE YADC.LOOP
026500           STX WORK.ADR
026600           ;
026700 YPLAY     LDA BYTE            ; CALCULATE BITS
026800           ROL A
026900           ROL A
027000           ROL A
027100           AND #3
027200           TAX
027300           LDA FUNCTION.TAB,X
027400           STA 53761
027500           LDA BYTE
027600           ASL A
027700           ASL A
027800           STA BYTE
027900           ;
028000           DEY
028100           BNE YADC.LOOP
028200           ;
028300           LDA (START.ADR),Y
028400           STA BYTE
028500           LDY #4
028600           ;
028700 YINC      INC START.ADR       ; NEXT BYTE
028800           BNE YCMP
028900           INC START.ADR+1
029000           LDA START.ADR+1
029100           CMP #$D0
029200           BNE YCMP
029300           ADC #$07            ; and CARRY(+1)
029400           STA START.ADR+1
029500           ;
029600 YCMP      LDA START.ADR+1     ; ANY MORE ?
029700           CMP END.ADR+1
029800           BCC YADC.LOOP
029900           LDA START.ADR
030000           CMP END.ADR
030100           BCC YADC.LOOP
030200           ;
030300           ;
030400           ;
030500 DAC.END   LDA #$FD
030600           STA $D301
030700           CLI
030800           LDA #64
030900           STA $D40E
031000           RTS
031100           ;
031200           ;
031300           ;
031400           ; SERVICE MCP
031500           ;
031600           SERVICE.MCP
031700           ;
031800           PHA
031900           TYA
032000           PHA
032100           TXA
032200           PHA
032300           ;
032400           NOP
032500           .BYTE $EA,$EA,$EA,$EA,$EA
032600           .BYTE $EA,$EA,$EA,$EA,$EA
032700           .BYTE $EA,$EA,$EA,$EA,$EA
032800           .BYTE $EA,$EA,$EA,$EA,$EA
032900           .BYTE $EA,$EA,$EA,$EA,$EA
033000           .BYTE $EA,$EA,$EA,$EA,$EA
033100           .BYTE $EA,$EA,$EA,$EA,$EA
033200           .BYTE $EA,$EA,$EA,$EA
033300           NOP
033400           ;
033500           PLA
033600           TAX
033700           PLA
033800           TAY
033900           PLA
034000           SEC
034100           BCS SYNC
034200           ;
034300           ;
