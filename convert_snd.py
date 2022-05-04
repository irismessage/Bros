from convert_musik import closest


class SFX:
    def __init__(self, num: int = 1):
        self.volume = [0] * 40
        self.distortion = [0] * 40
        self.pitch = [0] * 40
        self.gtonh = 0
        self.modp = 0
        self.speed = 0
        self.num = num

    def __str__(self):
        return '\n'.join(str(s) for s in [
            self.volume,
            self.distortion,
            self.pitch,
            [closest(p) for p in self.pitch],
            self.gtonh,
            self.modp,
            self.speed,
            self.num,
            '',
        ])


def mine() -> bytes:
    path = 'datamined/BROS.SND'
    with open(path, 'rb') as file:
        file.seek(0)
        sndbytes = file.read()
    return sndbytes


def convert_sfx(sfxbytes: bytes, sndnum: int = 1) -> SFX:
    sfx = SFX(sndnum)
    offset = (sndnum - 1) * 83

    for i in range(40):
        entry = sfxbytes[i + offset]
        sfx.volume[i] = (entry & 0xF0) >> 4
        sfx.distortion[i] = entry & 0x0F
        sfx.pitch[i] = sfxbytes[i + 40]
    sfx.gtonh = sfxbytes[80 + offset]
    sfx.modp = sfxbytes[81 + offset]
    sfx.speed = sfxbytes[82 + offset]

    return sfx


def convert_snd(sndbytes: bytes) -> list[SFX]:
    snds_count = len(sndbytes) / 83
    print(snds_count, 'sounds')

    snds = []
    for i in range(snds_count):
        snds.append(convert_sfx(sndbytes, i))
    return snds


def main():
    sndbytes = mine()
    sfx = convert_sfx(sndbytes)
    print(sfx)


if __name__ == '__main__':
    main()
