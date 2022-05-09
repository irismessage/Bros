import numpy as np
import scipy.io.wavfile
import scipy.signal


# hehe ratte
SAMPLE_RAT = 1000
SQUARE_FREQ = 196.7
Samples = list[int]


def mine() -> Samples:
    with open('datamined/BROS.SND', 'rb') as file:
        data = file.read()
    samples = []
    for b in data:
        samples.append((b>>4)&0x0F)
        samples.append(b&0x0F)
    return samples


def process_samples(samples: Samples) -> np.ndarray:
    s_array = np.array(samples, dtype=np.int8)
    # 4 bit to 8 bit
    np.multiply(s_array, 2)
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.square.html
    t = np.linspace(0, 1, len(s_array), endpoint=False)
    sqwv = scipy.signal.square(2 * np.pi * SQUARE_FREQ * t)
    np.multiply(s_array, sqwv)
    return s_array


def save_wav(s_array: np.ndarray, filename: str):
    scipy.io.wavfile.write(filename, SAMPLE_RAT, s_array)


def main():
    samples = mine()
    s_array = process_samples(samples)
    save_wav(s_array, 'tools/BROS.SND.wav')


if __name__ == '__main__':
    main()
