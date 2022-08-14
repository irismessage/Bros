"""Convert the music files to midi.

Requires mido https://github.com/mido/mido/#installing
https://mido.readthedocs.io/en/latest/midi_files.html
"""

import convert_musik
from _common import mine

import mido


SPN_TABLE = tuple(convert_musik.NOTES.values())
# first note in table is C3
# C3 is midi 48
SPN_TABLE_MIDI_OFFSET = 48


def ataribas_to_midi_note(ataribas_note: int) -> int:
    spn_note = convert_musik.closest(ataribas_note)
    spn_table_index = SPN_TABLE.index(spn_note)
    midi_note = spn_table_index + SPN_TABLE_MIDI_OFFSET
    return midi_note


def convert(data: bytes) -> mido.MidiFile:
    mid = mido.MidiFile()
    track_back = mido.MidiTrack()
    track_front = mido.MidiTrack()
    mid.tracks.append(track_back)
    mid.tracks.append(track_front)

    dur = 100

    # todo fill tracks
    for num in data:
        if num == 0:
            track_front.append(mido.Message('note_off', time=dur))
            continue

        midi_note = ataribas_to_midi_note(num)
        track_front.extend(
            [
                mido.Message('note_on', note=midi_note, time=dur),
                mido.Message('note_off', note=midi_note)
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
