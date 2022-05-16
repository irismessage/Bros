import struct
import sys

import mapdata


SPRITES_P8 = {
    # entities
    1: 'bg',
    2: 'bro_idle',
    16: 'spiker',
    17: 'fguy',
    19: '👀',
    21: 'mothralite',
    23: 'plant',
    # flr tiles
    32: 'cobble_full',
    33: 'cobble_R',
    34: 'cobble_L',
    35: 'brick_full',
    36: 'brick_R',
    37: 'brick_L',
    38: 'fragile_full',
    39: 'fragile_R',
    40: 'fragile_L',
    41: 'gangway',
    # pipes
    48: 'pipe_tL',
    49: 'pipe_tR',
    50: 'pipe_bL',
    51: 'pipe_bR',
    52: 'pipe_tL9',
    53: 'pipe_tR9',
    54: 'pipe_bL9',
    55: 'pipe_bR9',
    # tiles with items
    27: 'block_empty',
    42: 'block_coin',
    44: 'block_shroom',
    46: 'block_wep',
    43: 'brick_coin',
    45: 'brick_shroom',
    47: 'brick_wep',
    58: 'coin',
}
SPRITES_P8_R = {v: k for k,v in SPRITES_P8.items()}

SPRITES_AT = {
    # entities
    0x0000: 'bg',
    0xA1A2: 'fguy',
    # flr tiles
    0x6162: 'cobble_full',
    0x6364: 'brick_full',
    # pipes
    0x6D6E: 'pipe_tL',
    0x6F70: 'pipe_tR',
    0x7172: 'pipe_bL',
    0x7374: 'pipe_bR',
    0x2E2A: 'pipe_tL9',
    0x2D29: 'pipe_tR9',
    0x2C2C: 'pipe_bL9',
    0x2B2B: 'pipe_bR9',
    # tiles with items
    0x6768: 'block_empty',
    0x696A: 'block_coin',
    0x6966: 'block_shroom',
    0X6365: 'brick_coin',
    0x6B6C: 'coin',
}


def mine(world_file_num: str) -> bytes:
    """Return bytes from WORLD??.DAT file"""
    world_path = f'datamined/WORLD{world_file_num}.DAT'
    print(world_path)
    with open(world_path, 'rb') as file:
        world_bytes = file.read()
    return world_bytes


def split_screens(level: bytes) -> list[bytes]:
    """Split bytes from a world file into [palette, 1, 2, 3, 4, 5]"""
    screens = [level[:15]]
    for i in range(15, 2216, 440):
        screens.append(level[i:i+440])
    return screens


def dat_to_pico(screen_bytes: bytes) -> mapdata.Lines:
    """Convert a screen from  .DAT file into pick-8 2-byte hex strings"""
    maplines = []
    tiles = struct.iter_unpack('>H', screen_bytes)
    for y in range(11):
        l = []
        for x in range(20):
            atspr = next(tiles)[0]
            try:
                sprid = SPRITES_AT[atspr]
            except KeyError as error:
                raise KeyError(f'Missing map id {hex(atspr)}') from error
            p8spr = SPRITES_P8_R[sprid]
            l.append('{:02x}'.format(p8spr))
        maplines.append(''.join(l))

    return maplines


def main():
    try:
        screen = int(sys.argv[1])
    except IndexError:
        screen = int(input('Scrn (1 to 120): '))
    screen -= 1
    world, screen = divmod(screen, 20)
    stage, screen = divmod(screen, 5)
    world += 1
    stage += 1
    screen += 1

    world_bytes = mine(f'{world}{stage}')
    print('Screen', screen)
    screens_bytes = split_screens(world_bytes)
    maplines = dat_to_pico(screens_bytes[screen])

    cart = mapdata.peekcart()
    mapdata.writemap(maplines, cart, offset=1)
    mapdata.pokecart(cart)
    print('Saved to map')


if __name__ == '__main__':
    main()

