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

path = f'datamined/MUSIK{sys.argv[1]}.DAT'
print(path)
with open(path, 'rb') as file:
    file.seek(48)
    data = file.read()


def closest(target_pitch):
    closest = 255
    result = ''
    for pitch, note in notes.items():
        diff = abs(pitch - target_pitch)
        if abs(pitch - target_pitch) <= closest:
            closest = diff
            result = note
    return result


def packconverted(conv):
    prefix = '01100000'
    instrument = 3
    volume = 3
    effect = 0


def unpack(sfx: str):
    sfx_bin = f'{int(sfx, 16):b}'
    for i in range(0, 640, 20):
        note = sfx_bin[i:i+8]
        frequency = int(note[1:4], 2)
        octave = int(note[4:8], 2)
        print(frequency, octave)


converted = [closest(num) for num in data]


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
    # printconv()
    unpack(
            '0c3100d3100e3100f310103101131012310133101431015310163101731018310193101a3101b3101c3101d3101e3101f310203102131022310233100000000000000000000000000000000000000000'
    )
