# BROS (WIP)

BROS is a 1990 video game for the Atari 800 XL.

This is a remake of the game in PICO-8, complete with custom font, accurate datamined music, etc.

- Try on the bbs https://www.lexaloffle.com/bbs/?tid=47563
- Music on youtube https://youtu.be/oAwkf06aJ-Q
- Hollow https://youtu.be/QSFgMCD7zUU

## Files
- sources.md -- useful links to more information, emulators, ROMs, etc.
- Bros.atr -- original game ROM
- convert-musik.py -- python script to convert the datamined .DAT files into SPN music notes
- convert_snd.py -- wip python script to convert datamind .SND file into usable format
- mapdata.py -- python script to move levels between PICO-8 map block, and text encoded format

## Folders
- cart/ -- PICO-8 cartridge.
- assets/ -- assets ripped from the original game
- datamined/ -- files datamined from the original game
- manual/ -- images, transcription, and translation of the original game manual. German to english translation courtesy of Wbubbler

## Datamining details
Individual files can be extracted from Bros.atr with tool like Altirra or the HTML image explorer.

The MUSIK*.DAT files from the game are a stream of bytes, where each byte is a pitch number used in the SOUND statement in Atari BASIC. 0 means skip a notes. convert_musik.py converts them into music notes using the values from the Atari BASIC manual. The music notes need to be arranged appropriately, as in the PICO-8 cartridge.

Datamining the BROS.SND file is a work in progress.

## License
Usually I put my stuff under GPL/CC BY-NC-SA, but public domain seems more in the spirit of things since the original game is in public domain, and PICO-8 with splore and stuff doesn't really handle licenses
