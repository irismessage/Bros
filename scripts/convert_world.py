#!/usr/bin/env python3

import struct
import sys

import mapdata
from _common import mine


WORLD_WIDTH = 20
WORLD_HEIGHT = 11
SCREENS_COUNT = 160


SPRITES_P8 = {
    # entities
    1: 'bg',
    2: 'bro',
    16: 'spikes',
    17: 'fguy',
    19: '👀',
    21: 'mothralite',
    26: 'plant_L',
    27: 'plant_R',
    # flr tiles
    32: 'cobble',
    33: 'brick',
    34: 'gangway',
    48: 'fragile',
    # udLR, up down Left Right
    # vertical pipes
    23: 'pipe_uL',
    24: 'pipe_uR',
    39: 'pipe_vL',
    40: 'pipe_vR',
    55: 'pipe_dL',
    56: 'pipe_dR',
    # horizontal pipes
    52: 'pipe_LL',
    36: 'pipe_LR',
    53: 'pipe_hL',
    37: 'pipe_hR',
    38: 'pipe_RL',
    54: 'pipe_RR',
    # tiles with items
    42: 'block_empty',
    43: 'block_coin',
    44: 'brick_coin',
    45: 'block_1up',
    46: 'brick_1up',
    59: 'coin',
}
SPRITES_P8_R = {v: k for k,v in SPRITES_P8.items()}

SPRITES_AT = {
    # entities
    0x0000: 'bg',
    0xA7A8: 'spikes',
    0xA1A2: 'fguy',
    0xA3A4: '👀',
    0xA5A6: 'mothralite',
    # todo plant halves
    0x00F5: 'plant_L',
    0xF600: 'plant_R',
    # flr tiles
    0x6162: 'cobble',
    0x6364: 'brick',
    0x0707: 'fragile',
    0x0606: 'gangway',
    # pipes
    0x7172: 'pipe_vL',
    0x7374: 'pipe_vR',
    0x6D6E: 'pipe_uL',
    0x6F70: 'pipe_uR',
    0x2C2C: 'pipe_hL',
    0x2B2B: 'pipe_hR',
    0x2E2A: 'pipe_LL',
    0x2D29: 'pipe_LR',
    0x2F2D: 'pipe_RL',
    0x302E: 'pipe_RR',
    # tiles with items
    0x6768: 'block_empty',
    # one coin
    0x696A: 'block_coin',
    # I believe this is a shroom in stages 1 and 4, wep 2 and 3.
    # needs investigation
    0x6966: 'block_1up',
    # five coins à la mario, then it becomes block_empty
    0x6365: 'brick_coin',
    0x631f: 'brick_1up',
    0x6B6C: 'coin',
}


Tiles = list[int]


def split_screens(level: bytes) -> list[bytes]:
    """Split bytes from a world file into [palette, 1, 2, 3, 4, 5]"""
    screens = [level[:15]]
    for i in range(15, 2216, 440):
        screens.append(level[i:i+440])
    return screens


def join_bytes(screen_bytes: bytes) -> Tiles:
    """Parse bytes as 16 bit."""
    tiles_tuples = struct.iter_unpack('>H', screen_bytes)
    tiles = [t[0] for t in tiles_tuples]
    return tiles


def dat_to_pico(screen_bytes: bytes) -> mapdata.Lines:
    """Convert a screen from  .DAT file into pico-8 2-byte hex strings."""
    tiles = join_bytes(screen_bytes)
    ti = 0

    maplines = []
    for y in range(WORLD_HEIGHT):
        l = []
        for x in range(WORLD_WIDTH):
            atspr = tiles[ti]
            ti += 1
            try:
                sprid = SPRITES_AT[atspr]
            except KeyError as error:
                raise KeyError(f'Missing map id {atspr:04x}') from error
            p8spr = SPRITES_P8_R[sprid]
            l.append('{:02x}'.format(p8spr))
        maplines.append(''.join(l))

    return maplines


def verify_sprite_index():
    for i in range(1, SCREENS_COUNT + 1):
        try:
            convert(i)
        except KeyError:
            print(i)
            raise


def screen_number(screen: int) -> tuple[int, int, int]:
    screen -= 1
    world, screen = divmod(screen, 20)
    stage, screen = divmod(screen, 5)
    world += 1
    stage += 1
    screen += 1
    return world, stage, screen



def convert(screen: int) -> mapdata.Lines:
    world, stage, screen = screen_number(screen)

    world_path = f'datamined/WORLD{world}{stage}.DAT'
    world_bytes = mine(world_path)
    print(f'World {world}-{stage} ({screen})')
    screens_bytes = split_screens(world_bytes)
    maplines = dat_to_pico(screens_bytes[screen])

    return maplines


def convert_world(screen: int):
    maplines = convert(screen)
    cart = mapdata.peekcart()
    mapdata.writemap(maplines, cart, offset=mapdata.OFFSET)
    mapdata.pokecart(cart)
    print('Loaded map from dat file')


def main():
    try:
        arg1 = sys.argv[1]
    except IndexError:
        screen = int(input('Scrn (1 to 120): '))
    else:
        if arg1 == 'verify':
            verify_sprite_index()
            sys.exit(0)
        screen = int(arg1)

    convert_world(screen)


if __name__ == '__main__':
    main()
