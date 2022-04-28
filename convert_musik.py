start = 29

"""
29
31
33
35
37
40
42
45
47
50
53
57
60
64
68
72
76
81
85
91
96
102
108
114
121
128
136
144
153
162
173
182
193
204
217
230
243
"""

thing = """\
243 C3
230 C#3
217 D3
204 D#3
193 E3
182 F3
173 F#3
162 G3
153 G#3
144 A3
136 A#3
128 B3
121 C4
114 C#4
108 D4
102 D#4
96 E4
91 F4
85 F#4
81 G4
76 G#4
72 A4
68 A#4
64 B4
60 C5
57 C#5
53 D5
50 D#5
47 E5
45 F5
42 F#5
40 G5
37 G#5
35 A5
33 A#5
31 B5
29 C6
"""

noteslist = [l.split() for l in thing.splitlines()]
notes = {int(pitch): note for pitch, note in noteslist}

#print(notes)

path = 'datamined/MUSIK1.DAT'
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
print(' '.join(converted))
