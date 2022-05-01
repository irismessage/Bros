import sys


PICO_8_OFFSET = -2


# 1, 2, 4 are 42 bars
# 3 is 38 bars
# musik PICO-8 index
# 1     00
# 2     11
# 3     22
# 4     32
# end   43
# new:
# mus start end
# 1.0 00 04.5
# 1.5 05 11.0
# 2.0 12 16.5
# 2.5 17 22.0
# 3.0 22 26.0
# 3.5 26 31.5
# 4.0 32 36.5
# 4.5 37 42.0

# level 00
# main3 11
# main4 21


thing = """\
243 C 3
230 C# 3
217 D 3
204 D# 3
193 E 3
182 F 3
173 F# 3
162 G 3
153 G# 3
144 A 3
136 A# 3
128 B 3
121 C 4
114 C# 4
108 D 4
102 D# 4
96 E 4
91 F 4
85 F# 4
81 G 4
76 G# 4
72 A 4
68 A# 4
64 B 4
60 C 5
57 C# 5
53 D 5
50 D# 5
47 E 5
45 F 5
42 F# 5
40 G 5
37 G# 5
35 A 5
33 A# 5
31 B 5
29 C 6
"""

noteslist = [l.split() for l in thing.splitlines()]
for note in noteslist:
    note[0] = int(note[0])
    note[2] = int(note[2]) + PICO_8_OFFSET

notes = {}
for pitch, note, octave in noteslist:
    unpadded = note + str(octave)
    padded = unpadded.ljust(3)
    notes[pitch] = padded

#print(notes)


def closest(target_pitch):
    if target_pitch == 00:
        # indicates pause
        return '00 '
    closest = float('inf')
    result = ''
    for pitch, note in notes.items():
        diff = abs(pitch - target_pitch)
        if abs(pitch - target_pitch) <= closest:
            closest = diff
            result = note
    return result


# 11000011000100000000
# ------note
#       ---instrument
#          ---volume
#             ---effect
#                -----octave


def packconverted(conv):
    prefix = '01100000'
    instrument = 3
    volume = 3
    effect = 0


def unpack(sfx: str):
    sfx_bin = f'{int(sfx, 16):b}'
    for i in range(0, 640, 20):
        note = sfx_bin[i:i+20]
        frequency = int(note[0:6], 2)
        octave = int(note[15:20], 2)
        print(frequency, octave)


def musik_number():
    try:
        musik = sys.argv[1]
    except IndexError:
        musik = input('Musik number (1 to 4): ')
    return musik


def mine():
    path = f'datamined/MUSIK{musik_number()}.DAT'
    print(path)
    with open(path, 'rb') as file:
        file.seek(48)
        data = file.read()
    converted = [closest(num) for num in data]
    return converted


def printconv(conv):
    bars = [conv[i:i+8] for i in range(0, len(conv), 8)]
    print(len(bars))
    print("Press enter for each bar")
    try:
        for i, bar in enumerate(bars):
            input()
            print(' '.join(bar), end='')
            if (i + 1) % 4 == 0:
                print()
    except KeyboardInterrupt:
        print('\n^C', end='')


if __name__ == '__main__':
    printconv(mine())
    # unpack(
    #         '0c3100d3100e3100f310103101131012310133101431015310163101731018310193101a3101b3101c3101d3101e3101f310203102131022310233100000000000000000000000000000000000000000'
    # )
# 011000000c3100d3100e3100f310103101131012310133101431015310163101731018310193101a3101b3101c3101d3101e3101f310203102131022310233100000000000000000000000000000000000000000
# 00010001000000000000000000000000110000110001000000001101001100010000000011100011000100000000111100110001000000010000001100010000000100010011000100000001001000110001000000010011001100010000000101000011000100000001010100110001000000010110001100010000000101110011000100000001100000110001000000011001001100010000000110100011000100000001101100110001000000011100001100010000000111010011000100000001111000110001000000011111001100010000001000000011000100000010000100110001000000100010001100010000001000110011000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000