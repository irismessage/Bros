# BROS (WIP)

BROS is a 1990 video game for the Atari 800 XL.

This is a remake of the game in PICO-8, complete with custom font, accurate datamined music, etc.

- Try on the bbs https://www.lexaloffle.com/bbs/?tid=47563
- Music on youtube https://youtu.be/oAwkf06aJ-Q
- Hollow https://youtu.be/QSFgMCD7zUU

## Play the original
Download the ROM from Bros.atr. The best emulator is Altirra. It's only for windows but it works fine on wine too (I put it [on the aur](https://aur.archlinux.org/packages/altirra) - `yay -S altirra`).

See sources.md for more emulators and firmware roms if you want them.

## History
BROS is a 1990 video game for the Atari 800 XL. It was developed by a one-person team, Yoda Zhang, called Kemal Ezcan at the time. He ran a company called KE-SOFT, and made an Atari 800 magazine called ZONG, released on floppy disks with demo programs and games, and in limited print. The company has a small wikipedia article on the German language wikipedia, and you can find archives of the magazine online. All relevant links in sources.md.

The game was made for the Atari 800XL home computer, the most popular of the Atari 8-bit computer family. The game also ran on the Atari XE, the cross-compatible and more games-oriented counterpart to the 800XL. The 800XL was ultimately most popular in East Germany and the Soviet Bloc. Toowards the end of its lifespan, most programs, games, and demos were made in Europe. KE-SOFT was based in Frankfurt. The sound sampler used was made near Dortmund. 

For a date point of reference, the 800XL was released in 1983, the same year as the NES, and about one year after the more similar BBC Micro, Commodore 64 and ZX Spectrum. Speaking of the NES, the original Mario Bros came out in 1983 as well. There is a "port" of the official mario that came out for Atari 8-bit, but it's a different game, more like donkey kong kinda.

BROS was released on floppy disk as a two-game bundle with a cool looking platformer with procedural generation called TOBOT.

The iconic sounds were made with an incredibly bitcrushed sound sampler - either recorded with a microphone or ripped from a tape. They're literally 2-bit.

## Files
- sources.md -- useful links to more information, emulators, ROMs, etc.
- Bros.atr -- original game ROM
- convert_musik.py -- python script to convert the datamined .DAT files into SPN music notes
- convert_world.py -- load levels from world files into cart
- convert_snd.py -- wip python script to convert datamind .SND file into usable format
- mapdata.py -- python script to move levels between PICO-8 map block, and text encoded format
- view_world_hex.py -- used to view the world files in correct heigh, useful for datamining

## Folders
- cart/ -- PICO-8 cartridge.
- datamined/ -- files datamined from the original game
- manual/ -- images, transcription, and translation of the original game manual. German to english translation courtesy of Wbubbler
- scripts/ -- python scripts used for datamining and development
- soundn-sampler/ -- files related to the sampler used to make the sfx in the game. UNGH

## Datamining details
Individual files can be extracted from Bros.atr with tool like Altirra or the HTML image explorer.

AUTORUN.CTB is Compiled Turbo BASIC loaded by AUTORUN.SYS. Sadly I don't believe a Turbo BASIC decompiler exists, and making one is beyond my knowledge at the moment.

BROS.SND contains audio from a microphone, sampled using the 1980s German Sound'n'Sampler by Ralf David. The sound is 2bit at ~7778Hz (half the vertical scan rate of the Atari 800). Each byte is made up of four samples, big-endian in reverse order. You can see a demo decoder which converts to WAV in test_snd.py. This info was gained from soundn-sampler/XOUT.SRC.asm.    
The offsets of each sfx can be found by setting a breakpoint in Altirra at $7a5f, where the play routine is. Enable CPU history and activate a sound in the game. Then, in the history tab, search for the PHA operation. This will reveal the arguments, in the A register.

BROS?.CHR contain the typeface, I believe. I manually recreated it (as well as the sprites, which don't seem to have their own file, so must be contained somewhere in AUTORUN.CTB) and you can find it in cart/spritesheet.png.

MUSIK?.DAT are a stream of bytes, where each byte is a pitch number used in the SOUND statement in Atari BASIC. A 00 means one note of silence. convert_musik.py converts them into music notes using the values from the Atari BASIC manual. The music notes need to be arranged appropriately, as I have done in cart/bros.p8.

WORLD??.DAT contain the levels. Each file starts with 16 bytes for the colour palette, and then contains five levels, each 20 horizontal x 11 vertical. Each tile is two bytes and you can find them in convert_world.py.

## License
Usually I put my stuff under GPL/CC BY-NC-SA, but public domain seems more in the spirit of things since the original game is in public domain, and PICO-8 with splore and stuff doesn't really handle licenses.

The public domain declaration in LICENSE covers everything except the directory soundn-sampler/ which is copyrighted I believe.
