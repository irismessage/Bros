import sys
import numpy as np
import scipy.io.wavfile
import scipy.signal


# hehe ratte
SAMPLE_RAT = 3000
# SAMPLE_RAT = int(sys.argv[1])
SQUARE_FREQ = 196.7
Samples = list[int]


def mine() -> Samples:
    path = 'datamined/BROS.SND'
    print(path)
    with open(path, 'rb') as file:
        data = file.read()
    samples = []
    for b in data:
        samples.append((b>>4)&0x0F)
        samples.append(b&0x0F)
    return samples


def process_samples(samples: Samples) -> np.ndarray:
    s_array = np.array(samples, dtype=np.int8)
    # 4 bit to 8 bit
    s_array = np.power(s_array, 2)
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.square.html
    s_count = len(s_array)
    s_seconds = s_count // SAMPLE_RAT
    t = np.linspace(0, s_seconds, s_count, endpoint=False)
    sqwv = scipy.signal.square(2 * np.pi * SQUARE_FREQ * t)
    sqwv = sqwv.astype(np.int8)
    s_array = np.multiply(s_array, sqwv)
    return s_array


def save_wav(s_array: np.ndarray, filename: str):
    print(filename)
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.io.wavfile.write.html#scipy.io.wavfile.write
    scipy.io.wavfile.write(filename, SAMPLE_RAT, s_array)


def main():
    samples = mine()
    s_array = process_samples(samples)
    save_wav(s_array, 'music/BROS.SND.wav')


if __name__ == '__main__':
    main()
