import p8scii
from _common import get_workdir


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


def mine() -> bytes:
    workdir = get_workdir()
    path = workdir / 'datamined/BROS.SND'
    # commented out so you can use `python convert_snd.py | xclip -i`
    # print(path)
    with open(path, 'rb') as file:
        data = file.read()

    return data

def convert_pico(data: bytes) -> list[str]:
    converted = []
    for name, adrs in OFFSETS.items():
        start = adrs[0] - LOAD_LOCATION
        end = adrs[1] - LOAD_LOCATION
        data_p8scii = p8scii.decode(data[start:end])
        converted.append(f'\t{name}="{data_p8scii}",\n')
    return converted


def main():
    data = mine()
    converted = convert_pico(data)
    print(''.join(converted))


if __name__ == '__main__':
    main()
