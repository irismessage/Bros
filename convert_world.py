import struct
import sys

import mapdata


SPRITES_P8 = {
    # entities
    1: "bg",
    2: "bro_idle",
    16: "spiker",
    17: "fguy",
    19: "👀",
    21: "mothralite",
    23: "plant",
    # flr tiles
    32: "cobble_full",
    33: "cobble_R",
    34: "cobble_L",
    35: "brick_full",
    36: "brick_R",
    37: "brick_L",
    38: "fragile_full",
    39: "fragile_R",
    40: "fragile_L",
    41: "gangway",
    # pipes
    48: "pipe_tL",
    49: "pipe_tR",
    50: "pipe_bL",
    51: "pipe_bR",
    52: "pipe_tL9",
    53: "pipe_tR9",
    54: "pipe_bL9",
    55: "pipe_bR9",
    # tiles with items
    27: "block_empty",
    42: "block_coin",
    44: "block_shroom",
    46: "block_wep",
    43: "brick_coin",
    45: "brick_shroom",
    47: "brick_wep",
    58: "coin",
}
SPRITES_P8_R = {v: k for k,v in SPRITES_P8.items()}

SPRITES_AT = {
    0X0000: "bg",
    0XA1A2: "fguy",
    0X6D6E: "pipe_tL",
    0X6F70: "pipe_tR",
    0X7172: "pipe_bL",
    0X7374: "pipe_bR",
    0X6364: "brick_full",
    0X6768: "block_empty",
    0X696A: "block_coin",
    0X6966: "block_shroom",
    0X6162: "cobble_full",
    0X6B6C: "coin",
}


def mine(world_file_num: str) -> bytes:
    world_path = f'datamined/WORLD{world_file_num}.DAT'
    with open(world_path, 'rb') as file:
        world_bytes = file.read()
    return world_bytes


def split_screens(level: bytes) -> list[bytes]:
    screens = [level[:16]]
    for i in range(16, 2216, 440):
        screens.append(level[i:i+440])
    return screens


def dat_to_pico(screen_bytes: bytes) -> mapdata.Lines:
    maplines = []
    tiles = struct.iter_unpack('>H', screen_bytes)
    i = 0
    for y in range(11):
        l = []
        for x in range(20):
            p8spr = SPRITES_P8_R[SPRITES_AT[tiles[i]]]
            l.append('{:02x}'.format(p8spr))
            i += 1
        maplines.append(''.join(l))

    return maplines


def main():
    screen = int(sys.argv[1])
    screen, world = divmod(screen, 8)
    screen, stage = divmod(screen, 4)

    world_bytes = mine(f'{world}{stage}')
    screens_bytes = split_screens(world_bytes)
    maplines = dat_to_pico(screens_bytes[screen])

    cart = mapdata.peekcart()
    mapdata.writemap(maplines, cart)
    mapdata.pokecart(cart)


if __name__ == '__main__':
    main()

