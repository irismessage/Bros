import sys
import numpy as np
import scipy.io.wavfile
import scipy.signal


# hehe ratte
SAMPLE_RAT = 3000
# SAMPLE_RAT = int(sys.argv[1])
SQUARE_FREQ = 196.7
Samples = list[int]


def mine() -> tuple[int, Samples]:
    path = 'datamined/BROS.SND'
    print(path)
    with open(path, 'rb') as file:
        speed = file.read(1)
        data = file.read()
    samples = []
    for b in data:
        samples.append((b>>4)&0x0F)
        samples.append(b&0x0F)
    return speed, samples


def process_samples(speed: int, samples: Samples) -> np.ndarray:
    s_array = np.array(samples, dtype=np.int16)
    # 4 bit sample to 16 bit PCM
    s_array = np.multiply(s_array, 1024, dtype=np.int16)
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.square.html
    s_count = len(s_array)
    s_seconds = s_count // SAMPLE_RAT
    t = np.linspace(0, s_seconds, s_count, endpoint=False)
    sqwv = scipy.signal.square(2 * np.pi * SQUARE_FREQ * t)
    sqwv = sqwv.astype(int)
    s_array = np.multiply(s_array, sqwv, dtype=np.int16)
    print(s_array[:100])
    return s_array


def save_wav(s_array: np.ndarray, filename: str):
    print(filename)
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.io.wavfile.write.html#scipy.io.wavfile.write
    scipy.io.wavfile.write(filename, SAMPLE_RAT, s_array)


def main():
    speed, samples = mine()
    s_array = process_samples(speed, samples)
    save_wav(s_array, 'music/BROS.SND.wav')


if __name__ == '__main__':
    main()
