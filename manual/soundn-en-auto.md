SOUND'N'SAMPLER is a development package consisting of a special HIGH-SPEED analog/digital converter & lots of software. You can use it to digitize MUSIC, SPEECH & NOISES, then modify, edit, twist, vary speed & AMP, ... , and then of course integrate them into your programs (also in BASIC!). No problem !
DEMO => press START ...

SOUND'N'SAMPLER is a development package consisting of a special HIGH-SPEED analog/digital converter & lots of software. You can use it to digitize MUSIC, SPEECH & NOISES, then modify, edit, twist, vary speed & AMP, ... , and then of course integrate them into your programs (also in BASIC!). No problem !
DEMO => press START ...

# \*\*\*SOUND'N'SAMPLER - (C) 1987 Ralf David \*\*\* INSTRUCTIONS :

(Subject to change!)

What is needed:

- ATARI XL/XE with 64k (or more)
- disk drive
- Monitor (TV) with sound output
- Sound source (e.g. cassette recorder)
- Upper play cable (parallel cable)

Options :
- Tape deck/tape recorder and good microphone


Before we start with hard theory, some practice:

1. Turn off floppy & computer
2. SOUND'N'SAMPLER MOdule in Port 1 (otherwise nothing works)
3. Switch on floppy, insert floppy disk, close hebei
4. Turn on the computer
    - the DIGITAL-DATA-EDITOR is booted
    - the main screen appears
5. Now press "L" ("LOAD" lights up in menu) and type "DEMO.SND" & RETURN
    - a demo file is loaded
6. Press "O" for "OUTPUT"
    Sir listen to the demo
7. Then OPTION and again "O"
8. CONTROL+"R", then "O"
    - the music is played backwards
9. Press CONTROL+"R" again, then OPTION (SSS-MODE nub be "OFF"), and 10 times "<", then "O"
10. 20 times on ">" and again "D"
11. Take the disc out of the drive and experiment...

## DIGITAL DATA EDITOR :

The screen :

Title & Copyright

(B) Amplitude display & screen mode

    Memory model with pointers (pointers)

(E) Direct playback & pointer position Current working speed

    Menu

Line for text I/O (e.g. filename)


The bar (C) in the middle of the screen represents the available sound memory. The leftmost logical position is $00, the rightmost logical position is $D0F
. Physically, this is the memory range from $2700 to £D000 and from $D000 to $FFFF. This internal calculation gives the user a sound memory that is easy to survey and edit.

    $FFFF - $2700 - $0800 = $D0FF
    RAMTOP defined hardware I/O more freely
                    limit storage

Since only the 3 most significant digits are used ($DOF instead of $DOFF), all operations on the sound memory can be carried out with an accuracy of 16 bytes, which is more than enjoyable. 8 pointers are distributed on the bar, of which no. 1 & 8 are fixed at $000 and $D0F. Pointers 2-7 can be positioned as desired. 2 of the 8 pointers (pointers) are always flashing. All other functions refer to exactly this memory area, which is enclosed by the flashing pointers (e.g. this area is played back or saved on disk) You can select the flashing pointers by simply typing on the pointer number. The pointers are moved with the cursor keys:
    "+" & "*" for lower numbered pointers
    "-" & "+" for higher nun pointers
(whereas pointer 1 and 8 are immobile as mentioned)
If you press CONTROL at the same time, the movement is 16x as fast. The current pointer position can be read in field (E).

The amplitude display (A) shows the current amplitude or level of the input signal at the A/D converter. If an input signal is present, you should set the level with the rotary knob on the A/D converter in such a way that the level mark on average jumps around equally often in all 4 positions, whereby the middle 2 positions can be a little preferred. Then you usually have the best sound (in the end, however, the ear should decide!). If possible, the recording takes place in DIRECT MODE, which means that the input signal is output directly, but is not yet recorded. To do this, the \<D\> in (D) must light up inversely, otherwise press START. It is important to know that the sound quality in DIRECT MODE can of course not be the best, because in this case the program not only has to take care of the sound, but also because the DIGITAL-DATA-EDITOR is still running "by the way"!

SSS, which stands for SCREEN SYNCRONIZED SOUND, gives you the option of keeping the screen on while listening to the sound. The corresponding display is (B), and is toggled with tOPTION. Due to the synchronization, the recording/playback speed cannot be freely selected here. There are 5 modes here that cover the most important things. The modes can be changed at will with SELECT if SSS = ON! is. The mode number is then directly behind the SPEED display at (F). Modes 1-3 differ only in the playback speed, modes 4 & 5 have the same speed as mode 2, but the sound is distorted in such a way that a "robot-like" tin sound comes out.

The recording/playback speed is adjusted with "<" and ">". At (F) you can read the current setting. As with the pointer position display, the information is given in the hexadecimal system. Don't let this irritate you: A decimal number would no longer work either, because it makes no sense to know the "real" value here. It is sufficient here if one can distinguish between hex numbers in order to be able to remember different speeds or positions. Wherever the value of the number is important (e.g. error messages with disk I/O), decimal numbers are of course output.

## THE MENU FUNCTIONS :

**+ INPUT :** select with CONTROL+"I".
The A/D converter reads sound data at the sampling rate defined by SPEED (also with SSS) and stores it in the area between the flashing pointers until the area is full. The HELP button can be used to stop the recording. The demolition position is then at (E).

**OUTPUT :** SELECT WITH "O".
The area between the flashing pointers is played back at the speed specified by SPEED or by SSS-MODE. You can stop with HELP. The demolition position is then at (E).

**POINTER :** select with "P".
After "P" is printed and POINTER is highlighted in reverse video, a number from 2 through 7 must be printed to designate a pointer. Any other key terminates POINTER ! With "+" & "*" (&CONTROL) you can now move the pointer. The current position is at (E). With RETURN it ends.

Select **DUPLICATE :** with "D".
If "D" was printed, at (H) it asks for the destination pointer. You simply have to enter a number from 1 to 7 here. The area between the flashing pointers on the
Area copied behind the target pointer:

flash destination end

(2 4)(5 ?) copied

The end position of the target area (?) is at (E).

Select **SAVE :** with "S".
Saves the area between the two blinking pointers to disk. At (C) you are asked for the file spec. As long as you are in text input mode, you can cancel with ESC. After an error, press any key to continue.

Select **LOAD :** with "L".
Loads a specified file into the area between the blinking pointer AND BEYOND if the file is longer. If the file is shorter, ERROR 136 appears. However, this is not a real ERROR, but only the information that the end of the file (EOF) has been reached! So don't panic!

Select **CHAIN ​​:** with "C".
Appends the area between the blinking pointers to an existing file. Otherwise like SAVE.

DISK I/O!
You will notice that the I/O routine seems a bit slow. There is a good reason for this, and it cannot be remedied because of the limited memory (sound data has priority!). (However, if you have the 1050 TURBO module, you should boot Turbodrive to PAGE 6 (reserved separately!) and use a NORMAL-formatted disk. The 70000 baud then compensates for the slow CIO!)

**AMP-CTRL :** select with "A".
The A/D converter resolves to 4 voltage levels. However, it doesn't deliver 0.1 volts ... , but only the numbers 0 to 3. For playback, you can now assign a voltage from 0 to 15 (not volts!) to each voltage level supplied by the A/D converter. This puts you in control of the linearity and volume of the playback. After activating the function, the currently valid voltage function is displayed and you are asked whether a change is desired. After "Y" for YES, the new function can be entered.

Syntax : hex number(0-F),hex number(0-F),hex number(0-F),hex number(0-F) RETURN

For a linear display, the values ​​must be in ascending or descending order, equally spaced. The larger the distances, the louder :

quiet: 0,1,2,3 est eg. equals 5,6,7,8
  . 0,2,4,6 = C,A,8,6
  . 0,3,6,9
  . 0,4,8,C
loud : 0.5,A,F

Simulation of a 1 BIT A/D converter:
       0,0,7,7

**+REVERSE :** select with CONTROL+"R".
Reverses the area between the two blinking pointers so that the track is played backwards during playback.

## RECORDINGS :

For recording, the A/D converter must be plugged into port 1 and the digital data editor loaded. In addition, the A/D converter must be connected to the output of a cassette recorder, record player, etc. via a suitable cable. The DIRECT MODE should be active (inverse <\D\> at (D), otherwise START), and the knob on the converter should be turned all the way to the left. Switch on the sound source (there must be something on the wire now!) and slowly turn the knob to the right (clockwise) until you can hear what you expect (read it (A)).

    IF YOU HEAR NOTHING!!! CHECKLIST :
  - DIRECT MODE active?
  - Is the converter correctly plugged into port 1?
  - Is the sound source running?
  - Volume control on the monitor ok?
  - AMPT-CTRL flickers a little & something cracks in the speaker? Then turn the knob to the right. - If that doesn't help, then most likely there is not enough voltage at the module: try another sound source and/or another cable
  - Wrong transfer cable? There are 2 types:

    1. (parallel cable) 2.

    It must be a parallel cable!

The set SPEED should be between $01 and $50, where the lower the better, but the smoke is shorter. SSS MODE 1 has been retained for music, for speech you can go up to $50 depending on the voice (it should be deep). The quality of the sound template is very important for the quality of the recording !!! (e.g. on cassette). A simple recorder is sufficient as a playback device (the sound demos were made, for example, with a small, cheap mono recorder built in 1975 (not recorded!)). The sound template should not have an overly complex frequency spectrum, which sometimes causes problems with music. Voice recordings should be made with deep voices because a lower sampling rate is then sufficient (SPEED coarser). In addition, the sound templates for speech should be as perfect as possible (good dynamics, not overdriven). For such recordings you need good microphones and a good system. If everything is set to your satisfaction, all you have to do is press CONTROL+"i" and it will be digitized!

## USE DE SOUNDFILES :

After you have saved your sound file on disk with "S", in the simplest case you can only make a sound demo out of it, or you can integrate the sound file into your own programs:

DEMOS are easily made with the DMEOGENERATOR (load DEMOGEN.COM), which doesn't really need any further explanation. Simply call B and set parameters, possibly create a title picture with C, and save with D. Everything else is optional.

## INSTALLATION IN PROGRAMS :

In principle, this is how it works: At the beginning of your program, you briefly start a loading routine that loads the sound data quickly (in contrast to the DIGITAL-DATA-EDITOR, because it does not use DOS&CIO). The sound data (or parts of it) are played back by starting a playback routine.

## The loading routine :

"XLOAD.LST" needs 2 parameters:
- The file name: Must not contain any device information and must be 8 characters long, otherwise fill with spaces. Don't put a point!
- The extender must be 3 digits long, otherwise fill in with spaces here as well. For example: ADR("FILENAMEEXT") or ADR("DEMO SND")
- Address : where to put the data ? If you can get by with t22k, the area under the ROM should be used, e.g. Specify 40960. The hardware I/O ($D000-$D7FF) is calculated automatically. to be on the safe side, only addresses from 7680-63400 are accepted (otherwise ERROR 255).
E.g.: ERROR=USR(ADR(LD$),ADR("FILENAMEEXT"),20000)
The end of the currently loaded sound file is (directly after loading) in 220/221 :
END=PEEK(220)+256*PEEK(221)

## THE OUTPUT ROUTINES :

The sound can be output with the two routines "XOUT.LST" & "XOUT1.LST". When these routines are called, all parameters that can also be changed in the DIGITAL-DATA-EDITOR can be changed:

SSS : 0 = no SSS, 1 = SSS
SYNC : if SSS=1 -> 0,1,3,8,16 correspond to SSS MODES 1 to 5
SPEED : if SSS=0 -> playback speed (1-255)
F0-F3 : amplitude function, like AMPT-CTRL (e.g. 0,3,6,9)
START : Address where the sound data begins
END : Address up to where the data should be played

IDATA : Address where the interpreter program is located (<256 = no call)
TIME : Frequency of the interpreter call (0 = no call)

### XOUT.LST :

X=USR(ADR(0$),SSS,SYNC,SPEED,F0,F1,F2,F3,START,END)

A machine program can be called up regularly during sound playback:
 0$(187,187)=CHR$(255) -> no call
 0$(187,187)=CHR$(X) -> call at raster line X (1-155) The machine program must be at the end of the 0$ instead of some of the many inverse "j" (or branch from there (e.g. JSR $0600)). DO NOT change the length of $0!

 ### XOUT1.LST :

 X=USR(ADR(01$),SSS,SYNC,SPEED,F0,F1,F2,F3,START,END,IDATA,TIME)

 Here there is now the interpreter, which can be called up regularly during the sound output in order to quickly change something. The second to last parameter (IDATA) indicates the address of the special interpreter program, the last parameter indicates the frequency of the call: 1 = very often, 2 to 254 = less and less the interpreter understands 8 commands:

 Command : code parameter function
----------------------------------------------------------
 RESET : 0 none sets the program number of the interpreter
                                  back to 0
 POKE : 10 2Byte,1Byte writes a byte in TARGET ADDRESS
                DESTINATION ADDRESS,VALUE
 ADD : 20 2 bytes, 1 byte adds value to the content of DESTINATION ADDRESS
                DESTINATION ADDRESS,VALUE
 ADD2 : 30 2 bytes, 1 byte adds value to the content of ZIELADR &
                ZIELADR,VALUE ZIELADR+1 (lo/hi byte)
 SUB : 40 2 bytes, 1 byte subtracts value from the content of DESTINATION ADDRESS,VALUE
 SUB2 : 50 2 bytes, 1 byte subtracts value from content of DESTINATION ADDRESS &
                ZIELADR,VALUE ZIELADR+1 (lo/hi byte)
 BLOCK : 60 2Byte,2Byte,1Byte copies memory area of ​​length
                SOURCEADR,2IELADR,LEN LEN+1 from SOURCEADR to DESTINATIONADR
 RETURN : 255 none Interrupts interpreter and joins in
                                  Sound output further - at the next
                                  Interpreter call gents here

A program that constantly changes the background color during sound output then sees e.g. like this :
 ADD255.1 ; 255 is taken here as the color number and increased by 1
 BLOCK 255.53274.0 ; Write color counter to hardware color register
 RESET ; Back to top

This must now be compiled by hand (no machine code!)

ADD : 20, : Code of ADD
        255 : 255.0 : 2-lo/hi bytes
          1:1, :1 byte
BLOCK : 60, : code of BLOCK
        255 : 255.0, : 2-lo/hi bytes
      53274 : 26,208, : 2-lo/hi bytes
          0:0:1 byte
RESET : 0 : code of RESET

The result : 20,255,0,1,60,255,0,26,208,0,0

These numbers have to be poked into memory somewhere, or better put in a string in the form of ATASCII characters.


( LO/HI byte splitting: )
( Used to represent numbers that are larger than 255 and therefore cannot be represented with one byte. Whenever the interpreter receives an address )
( is passed as a parameter, the address must be represented with 2 bytes, since addresses can go up to 65535 here. )

( Splitting : )
( number = 53274 )
( high byte = INT ( number / 256 ) )
( low byte = number - high byte * 256 )

( reverse : )
( number = low byte + high byte * 256 )


Take a look at "XDEMO1.LST" : The interpreter program is stored in PGM$, but this is done in a cumbersome way here. Of course, you can also specify the ATASCII characters beforehand ( ?;CHR$(.) ), and insert the characters directly into the string ( PGM$="ABCD1234... " ).

The calls of machine programs or the interpreter only work if the SSS mode is switched on. You will also notice that the built-in character set does not "work" in the sound output. This is because the ROMs are switched off on release in order to have access to the corresponding RAMs. In this case you must first write a character set somewhere in RAM, which you should use a small machine program to do. A subprogram packaged accordingly in BASIC is "FONTCOPY.LST". A really universal memory copy program, with which you can also do other things, such as. vertical player movement and operations on frame buffers.

### Something else :

The software is in no way copy-protected. The reason for this is, firstly, that it gives you the opportunity to make backup copies. If you want to copy the DIGITAL-DATA-EDITOR to another disc, you should know that this DOS 2.5 configuration requires: DRIVE: 1, MAX OPEN: 1 file & NO VERIFY! The whole system is protected by copyright!
