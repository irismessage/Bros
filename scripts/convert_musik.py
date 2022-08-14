from sys import argv
from _common import mine


# PICO-8 bumps the octave by this amount
PICO_8_OFFSET = -2
# ataribas note octave
# parsed by parse_notes for usage
SPN_TABLE_STR = """\
243 C  3
230 C# 3
217 D  3
204 D# 3
193 E  3
182 F  3
173 F# 3
162 G  3
153 G# 3
144 A  3
136 A# 3
128 B  3
121 C  4
114 C# 4
108 D  4
102 D# 4
96  E  4
91  F  4
85  F# 4
81  G  4
76  G# 4
72  A  4
68  A# 4
64  B  4
60  C  5
57  C# 5
53  D  5
50  D# 5
47  E  5
45  F  5
42  F# 5
40  G  5
37  G# 5
35  A  5
33  A# 5
31  B  5
29  C  6
"""


def parse_notes(notes_table: str) -> dict[int, str]:
    noteslist = [l.split() for l in notes_table.splitlines()]
    for note in noteslist:
        note[0] = int(note[0])
        note[2] = int(note[2]) + PICO_8_OFFSET

    notes = {}
    for pitch, note, octave in noteslist:
        unpadded = note + str(octave)
        padded = unpadded.ljust(3)
        notes[pitch] = padded

    return notes


NOTES = parse_notes(SPN_TABLE_STR)


def closest(target_pitch: int, notes: dict[int, str] = NOTES) -> str:
    """Return the closest SPN note to the Atari BASIC pitch value"""
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


def arg_musik_number() -> str:
    """Get number from args or stdin"""
    try:
        musik = argv[1]
    except IndexError:
        musik = input('Musik number (1 to 4): ')
    return musik


def printconv(conv: list[str]):
    """Print a list of notes sorted into bars for readability."""
    bars = [conv[i:i+8] for i in range(0, len(conv), 8)]
    print(len(bars), 'bars')
    print("Press enter for each bar")
    try:
        for i, bar in enumerate(bars):
            input()
            print(' '.join(bar), end='')
            if (i + 1) % 4 == 0:
                print()
    except KeyboardInterrupt:
        print('\n^C', end='')


def main():
    musik_path = f'datamined/MUSIK{arg_musik_number()}.DAT'
    data = mine(musik_path, offset=48)
    converted = [closest(num) for num in data]
    printconv(converted)


if __name__ == '__main__':
    main()
