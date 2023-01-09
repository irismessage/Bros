#!/usr/bin/env python3

from sys import argv
from itertools import repeat

import p8scii


# background sprite
BG = 1
# sprites to compress
COMPRESS = (
    BG,
)

COMMAND_SAVE = 'save'
COMMAND_LOAD = 'load'
CART_PATH = 'cart/bros.p8'
# rows to skip at the top
OFFSET = 2
# size of the relevant map section
ROWS = 13
COLUMNS = 16
# length of the hex string in the cart __map__ block
WIDTH = 2 * COLUMNS
LEVEL_COUNT = 160

Mapdata = str
Hex = str
Lines = list[Hex]


def compress(mapdata: Hex) -> Mapdata:
    """Convert map from a string of 2-digit hex to a compressed pico-8 string literal."""
    mapdata_bytes = bytearray.fromhex(mapdata)
    compressed = bytearray()

    i = 0
    while i < len(mapdata_bytes):
        tile = mapdata_bytes[i]
        if tile in COMPRESS:
            run = 0
            while (
                mapdata_bytes[i] == tile
                and i < len(mapdata_bytes)
                and run < 255
            ):
                i += 1
                run += 1
            compressed.append(tile)
            compressed.append(run)
        else:
            compressed.append(tile)
            i += 1


    mapdata = p8scii.decode(compressed)
    return mapdata


def decompress(mapdata: Mapdata) -> Hex:
    """Convert map from a compressed pico-8 string literal to a string of 2-digit hex."""
    mapdata_bytes = p8scii.encode(mapdata)
    decompressed = bytearray()

    i = 0
    while i < len(mapdata_bytes):
        tile = mapdata_bytes[i]
        if  tile in COMPRESS:
            i += 1
            repeats = mapdata_bytes[i]
            decompressed.extend(repeat(tile, repeats))
        else:
            decompressed.append(tile)
        i += 1

    mapdata_hex = decompressed.hex()
    return mapdata_hex


def process(maplines: Lines) -> Hex:
    """Take a list of rows in p8 cart format and join them into a single string."""
    processed_lines = []
    for line in maplines:
        processed_lines.append(line[:WIDTH])
    processed_uncompressed = ''.join(processed_lines)
    processed = compress(processed_uncompressed)
    return processed


def deprocess(mapdata: Hex) -> Lines:
    """Split a single string map into a list of rows"""
    mapdata_decompressed = decompress(mapdata)
    deprocessed = []
    for i in range(0,ROWS*WIDTH,WIDTH):
        deprocessed.append(mapdata_decompressed[i:i+WIDTH])
    return deprocessed


def peekcart() -> Lines:
    """Return lines from p8 file"""
    with open(CART_PATH, encoding='utf-8') as file:
        cart = file.readlines()
    return cart


def pokecart(cart: Lines):
    """Write lines to p8 file"""
    with open(CART_PATH, 'w', encoding='utf-8', newline='\n') as file:
        file.writelines(cart)


def screensindex(cart: Lines):
    """Get start index of encoded screens in cart"""
    index = cart.index('screens = {\n')
    return index


def mapindex(cart: Lines):
    """Get line index of the start of the map data"""
    return cart.index('__map__\n') + OFFSET + 1


def readmap(cart: Lines) -> Lines:
    """Return lines of map from cart"""
    maplines = []
    index = mapindex(cart)
    maplines = cart[index:index + ROWS]
    return maplines


def writeencoded(mapdata: Mapdata, scrn: int, cart: Lines):
    """Write encoded map data to the lua block of the cart lines"""
    index = screensindex(cart)
    cart[index + scrn] = f'\t"{mapdata}",\n'


def readencoded(scrn: int, cart: Lines) -> Mapdata:
    """Get encoded map data of screen at index scrn from cart lines"""
    index = screensindex(cart)
    screen = cart[index + scrn]
    screen = screen.removeprefix('\t"')
    screen = screen.removesuffix('",\n')
    return screen


def writemap(maplines: Lines, cart: Lines, offset: int = 0):
    """Insert map lines into cart lines"""
    index = mapindex(cart)
    width = len(maplines[0])
    for i, line in enumerate(maplines):
        li = index + i + offset
        cart[li] = line + cart[li][width:]


def reload_all():
    """Load all encoded screen data then write it back"""
    # for when I change the codec
    cart = peekcart()
    for i in range(1,LEVEL_COUNT+1):
        mapdata = readencoded(i, cart)
        if mapdata == '\n':
            # not all levels converted yet
            break
        maplines = deprocess(mapdata)
        mapdata = process(maplines)
        writeencoded(mapdata, i, cart)
    pokecart(cart)


def mapdata(option: str, scrn: int):
    cart = peekcart()
    if option == COMMAND_SAVE:
        maplines = readmap(cart)
        mapdata = process(maplines)
        writeencoded(mapdata, scrn, cart)
        print(f'Saved map to screens[{scrn}]')
    elif option == COMMAND_LOAD:
        mapdata = readencoded(scrn, cart)
        maplines = deprocess(mapdata)
        writemap(maplines, cart)
        print(f'Loaded map from screens[{scrn}]')
    else:
        print('Wrong')
        return
    pokecart(cart)


def main():
    try:
        option = argv[1]
        scrn = argv[2]
    except IndexError:
        option = input(
            'choose an option\n'
            f'{COMMAND_SAVE}: map to encoded, '
            f'{COMMAND_LOAD}: encoded to map\n'
        )
        scrn = input(f'Screen number (1 to {LEVEL_COUNT})\n')
    scrn = int(scrn)
    if not (1 <= scrn <= LEVEL_COUNT):
        raise ValueError('Bad scrn')

    mapdata(option, scrn)


if __name__ == '__main__':
    main()
