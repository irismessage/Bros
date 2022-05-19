import numpy as np
import scipy.io.wavfile
import scipy.signal


# hehe ratte
# (target output sample rate)
SAMPLE_RAT = 5512
# frequency of POKEY square wave
SQUARE_FREQ = 196.7
# lines on a PAL display
SCAN_LINES = 312
H_SCAN_RATE = 15.55655e3
LINE_SECONDS = 1 / H_SCAN_RATE
# sound n sampler args
# 0,1,3,8,16 correspond to SSS MODES 1 to 5
SYNCRES = 0
# F0 F1 F2 F3
AMPLITUDE = [0x0, 0x4, 0x8, 0xC]
START = 0
END = 3100



# altirra breakpoint $7a5f, history search PHA

# BONK
# param count
# 09
# params
# 0001    SSS
# 0000    SYNCRES
# 0001    SPEED
# 0000    F0
# 0004    F1
# 0008    F2
# 000C    F3
# 00A0    START
# A110    END
# usr adr
# 2121

# DIE
# param count
# 09
# params
# 0001    same
# 0000
# 0001
# 0000
# 0004
# 0008
# 000C
# A3D1    START
# A910    END
# usr adr
# 2121

# KILL
# --
# A111    START
# A1F0    END
# --

# COIN
# --
# A000    START
# A110    END
# --


def mine() -> bytes:
    path = 'datamined/BROS.SND'
    print(path)
    print('reading..')
    with open(path, 'rb') as file:
        data = file.read()
    print(len(data), 'bytes')

    return data


def process_samples(data: bytes) -> np.ndarray:
    print('clipping..')
    data = data[START:END]
    print(len(data), 'bytes')

    # separate each bytes into a 2-bit sample
    # and apply amplification table
    print('amplifying..')
    samples = []
    for b in data:
        for i in range(4):
            half_nibble = (b >> 2*i) & 0b00000011
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

    # superimpose square wave to emulate POKEY
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.square.html
    print('superimposing square wave..')
    s_count = len(s_array)
    snd_seconds = s_count * LINE_SECONDS
    t = np.linspace(0, snd_seconds, num=s_count, endpoint=False)
    sqwv = scipy.signal.square(2 * np.pi * SQUARE_FREQ * t)
    s_array = np.multiply(s_array, sqwv)

    # stretch to desired sample rate
    print('interpolating..')
    samples_needed = int(snd_seconds * SAMPLE_RAT)
    x = np.linspace(0, snd_seconds, num=samples_needed)
    s_array = np.interp(x, t, s_array)
    s_array = s_array.round()
    # convert to 16 bit
    s_array = np.multiply(s_array, 2048)
    s_array = s_array.astype(np.int16)

    return s_array


def save_wav(s_array: np.ndarray, filename: str):
    print('saving..')
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.io.wavfile.write.html#scipy.io.wavfile.write
    scipy.io.wavfile.write(filename, SAMPLE_RAT, s_array)
    print(filename)


def main():
    data = mine()
    s_array = process_samples(data)
    save_wav(s_array, 'music/BROS.SND.wav')


if __name__ == '__main__':
    main()
