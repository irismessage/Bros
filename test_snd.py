import numpy as np
import scipy.io.wavfile
import scipy.signal


# hehe ratte
# (target output sample rate)
SAMPLE_RAT = 5512
# frequency of POKEY square wave
SQUARE_FREQ = 196.7
# length of 6502 cpu cycle in seconds
CYCLE = 560e-9
# sound n sampler args
# F0 F1 F2 F3
# AMPLITUDE = [0x0, 0x1, 0x2, 0x3]
AMPLITUDE = [0x2, 0x1, 0x0, 0x3]
SYNCRES = 1
# length of a sample in seconds
# todo figure out exact equation from XOUT.SRC
SAMPLE_SECONDS = (80 + 200 * SYNCRES) * CYCLE

Samples = list[int]

def mine() -> Samples:
    path = 'datamined/BROS.SND'
    print(path)
    print('reading..')
    with open(path, 'rb') as file:
        data = file.read()
    print(len(data), 'bytes')

    print('amplifying..')
    samples = []
    for b in data:
        for i in range(4):
            half_nibble = (b >> 2*i) & 0b00000011
            amplified = AMPLITUDE[half_nibble]
            samples.append(amplified)
    print(len(samples), 'samples')

    return samples


def process_samples(samples: Samples) -> np.ndarray:
    s_array = np.array(samples)

    # superimpose square wave to emulate POKEY
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.square.html
    print('superimposing square wave..')
    s_count = len(s_array)
    snd_seconds = s_count * SAMPLE_SECONDS
    t = np.linspace(0, snd_seconds, num=s_count, endpoint=False)
    sqwv = scipy.signal.square(2 * np.pi * SQUARE_FREQ * t)
    sqwv = sqwv.astype(np.int8)
    s_array = np.multiply(s_array, sqwv, dtype=np.int8)

    print('interpolating..')
    # stretch to desired sample rate
    samples_needed = int(snd_seconds * SAMPLE_RAT)
    x = np.linspace(0, snd_seconds, num=samples_needed)
    s_array = np.interp(x, t, s_array)

    return s_array


def save_wav(s_array: np.ndarray, filename: str):
    print('saving..')
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.io.wavfile.write.html#scipy.io.wavfile.write
    scipy.io.wavfile.write(filename, SAMPLE_RAT, s_array)
    print(filename)


def main():
    samples = mine()
    s_array = process_samples(samples)
    save_wav(s_array, 'music/BROS.SND.wav')


if __name__ == '__main__':
    main()
