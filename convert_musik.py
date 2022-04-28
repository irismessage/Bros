import sys


PICO_8_OFFSET = -2


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


converted = [closest(num) for num in data]
bars = [converted[i:i+8] for i in range(0, len(converted), 8)]
print(len(bars))
print("Press enter for each bar")
try:
    for bar in bars:
        input()
        print(' '.join(bar), end='')
except KeyboardInterrupt:
    print('\n^C', end='')
