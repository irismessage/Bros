"""Convert the music files to minimal midi.

Requires mido https://github.com/mido/mido/#installing
Mido docs: https://mido.readthedocs.io/en/latest/midi_files.html

Once exported, use a midi editor like fl studio to use it.
Use the glue tool (ctrl+g in fl studio) to combine the consecutive notes.
Arrangement and tempo need to be adjusted, with the cart as a reference.
See assets/ for example
"""

import convert_musik
from _common import mine

import mido


SPN_TABLE = tuple(convert_musik.NOTES.values())
# first note in table is C3
# C3 is midi 48
SPN_TABLE_MIDI_OFFSET = 48
# placeholder midi tick value for each note.
# the same one is used for each export, and you can adjust
# the tempo in a midi editor.
TICKS = 120


def ataribas_to_midi_note(ataribas_note: int) -> int:
    spn_note = convert_musik.closest(ataribas_note)
    spn_table_index = SPN_TABLE.index(spn_note)
    midi_note = spn_table_index + SPN_TABLE_MIDI_OFFSET
    return midi_note


def convert(data: bytes) -> mido.MidiFile:
    mid = mido.MidiFile()
    track = mido.MidiTrack()
    mid.tracks.append(track)

    for num in data:
        if num == 0:
            track.append(mido.Message('note_off', time=TICKS))
            continue

        midi_note = ataribas_to_midi_note(num)
        track.extend(
            [
                mido.Message('note_on', note=midi_note),
                mido.Message('note_off', note=midi_note, time=TICKS)
            ]
        )
        pause = 0

    return mid


def main():
    for i in (1, 2, 3, 4):
        musik_path = f'datamined/MUSIK{i}.DAT'
        data = mine(musik_path, offset=48)
        mid = convert(data)
        mid.save(f'MUSIK{i}.mid')


if __name__ == '__main__':
    main()
