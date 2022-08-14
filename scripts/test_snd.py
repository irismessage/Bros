"""Convert SND files to wav, for testing sample rate etc.

Requires scipy (I recommend conda).
"""


import scipy.io.wavfile
import scipy.signal
import numpy as np

import mapdata
from convert_snd import mine


# hehe ratte
# (target output sample rate)
SAMPLE_RAT = 5512
# lines on a PAL display
SCAN_LINES = 312
H_SCAN_RATE = 15.55655e3
LINE_SECONDS = 1 / H_SCAN_RATE
# length of a sample in seconds
SAMPLE_SECONDS = 2 * LINE_SECONDS
# sound n sampler args
# 0,1,3,8,16 correspond to SSS MODES 1 to 5
SYNCRES = 0
# F0 F1 F2 F3
AMPLITUDE = [0x0, 0x4, 0x8, 0xC]
START = 0
END = 3100
# location BROS.SND is loaded into memory
# offset
LOAD_LOCATION = 0xA000


OFFSETS = {
    'coin': (0xA000, 0xA110),
    'kill': (0xA111, 0xA1F0),
    'bonk': (0xA1F1, 0xA3D0),
    'dies': (0xA3D1, 0xA910),
    'brks': (0xA911, 0xAAD0),
    'eats': (0xAAD1, 0xAC40),
}


def process_samples(data: bytes) -> np.ndarray:
    # separate each bytes into a 2-bit sample
    # and apply amplification table
    print('amplifying..')
    samples = []
    for b in data:
        for i in range(6, -1, -2):
            half_nibble = (b >> i) & 0b00000011
            amplified = AMPLITUDE[half_nibble]
            samples.append(amplified)
    print(len(samples), 'samples')

    # screen syncronised sound
    print('screen syncronising..')
    synced = []
    vcount = 0
    i = 0
    while i < len(samples):
        synced.append(samples[i])
        vcount += 1
        if vcount > 0x9B:
                vcount = 0
        if (vcount & SYNCRES) == 0:
            i += 1
    print(len(synced), 'syncronised')

    # convert to array
    s_array = np.array(synced)
    s_count = len(s_array)

    # stretch to desired sample rate
    print('interpolating..')
    snd_seconds = s_count * SAMPLE_SECONDS
    samples_needed = int(snd_seconds * SAMPLE_RAT)
    x = np.linspace(0, snd_seconds, num=samples_needed)
    t = np.linspace(0, snd_seconds, num=s_count, endpoint=False)
    s_array = np.interp(x, t, s_array)
    s_array = s_array.round()
    # convert to 16 bit
    # s_array = np.multiply(s_array, 2048)
    s_array = s_array.astype(np.int16)

    return s_array


def save_wav(s_array: np.ndarray, filename: str):
    print('saving..')
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.io.wavfile.write.html#scipy.io.wavfile.write
    scipy.io.wavfile.write(filename, SAMPLE_RAT, s_array)
    print(filename)


def convert_wav(data: bytes):
    s_array = process_samples(data)
    save_wav(s_array, 'music/BROS.SND.wav')


def main():
    data = mine()
    convert_wav(data)


if __name__ == '__main__':
    main()
