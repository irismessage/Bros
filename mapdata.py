import json
import sys


BG = 1
CART_PATH = 'cart/bros.p8'
OFFSET = 2
ROWS = 13
WIDTH = 32
Lines = list[str]


def get_p8scii() -> Lines:
    with open('p8scii.json', encoding='utf-8') as file:
        p8scii = json.load(file)
    return p8scii


P8SCII = get_p8scii()


def p8scii_encode(text: str) -> bytearray:
    i = 0
    binary = bytearray()
    while i < len(text) - 1:
        longest_match = ''
        llm = 0
        for c in P8SCII:
            lc = len(c)
            if text[i:i+lc] == c:
                if llm < lc:
                    llm = lc
                    longest_match = c
        binary.append(P8SCII.index(longest_match))
        i += llm
    return binary


def p8scii_decode(binary: bytearray) -> str:
    text = ''.join(P8SCII[b] for b in binary)
    return text


def compress(mapdata: str) -> str:
    mapdata_bytes = bytearray.fromhex(mapdata)
    length = 0
    for i in range(len(mapdata_bytes) - 1, -1, -1):
        mb = mapdata_bytes[i]
        if (length and mb != BG) or length == 255:
            mapdata_bytes[i+1:i+length+1] = [BG, length]
            length = 0
            continue
        if mb == BG:
            length += 1
    mapdata_bytes[i:i+length] = [BG, length]
    mapdata = p8scii_decode(mapdata_bytes)
    return mapdata


def decompress(mapdata: str) -> str:
    mapdata_bytes = p8scii_encode(mapdata)
    for i in range(len(mapdata_bytes) - 1, -1, -1):
        if mapdata_bytes[i] == BG:
            repeats = mapdata_bytes[i+1]
            mapdata_bytes[i:i+2] = [BG] * repeats
    mapdata = mapdata_bytes.hex()
    return mapdata


def process(maplines: Lines) -> str:
    processed_lines = []
    for line in maplines:
        processed_lines.append(line[:WIDTH])
    processed_uncompressed = ''.join(processed_lines)
    processed = compress(processed_uncompressed)
    return processed


def deprocess(mapdata: str) -> Lines:
    mapdata_decompressed = decompress(mapdata)
    deprocessed = []
    for i in range(0,ROWS*WIDTH,WIDTH):
        deprocessed.append(mapdata_decompressed[i:i+WIDTH])
    return deprocessed


def peekcart() -> Lines:
    with open(CART_PATH, encoding='utf-8') as file:
        cart = file.readlines()
    return cart


def pokecart(cart: Lines):
    with open(CART_PATH, 'w', encoding='utf-8', newline='\n') as file:
        file.writelines(cart)


def screensindex(cart: Lines):
    index = cart.index('screens = {\n')
    indexend = cart.index('}\n', index)
    lenscreens = indexend - index - 1
    return index, indexend, lenscreens


def mapindex(cart: Lines):
    return cart.index('__map__\n') + OFFSET + 1


def readmap(cart: Lines) -> Lines:
    maplines = []
    index = mapindex(cart)
    maplines = cart[index:index + ROWS]
    return maplines


def writeencoded(mapdata: str, scrn: int, cart: Lines):
    index, indexend, lenscreens = screensindex(cart)
    mapdata = f'\t"{mapdata}",\n'
    if lenscreens < scrn:
        cart.insert(indexend, mapdata)
    else:
        cart[index + scrn] = mapdata


def readencoded(scrn: int, cart: Lines) -> str:
    index, indexend, lenscreens = screensindex(cart)
    if lenscreens < scrn:
        raise IndexError(f'Screen index out of range: {scrn}')
    else:
        screen = cart[index + scrn]
        screen = screen.removeprefix('\t"').removesuffix('",')
        return screen


def writemap(maplines: Lines, cart: Lines):
    index = mapindex(cart)
    for i, line in enumerate(maplines):
        cart[index+i] = line + cart[index+i][WIDTH:]


def reload_all():
    # for when I change the codec
    cart = peekcart()
    for i in range(1,121):
        mapdata = readencoded(i, cart)
        maplines = deprocess(mapdata)
        mapdata = process(maplines)
        writeencoded(mapdata, i, cart)
    pokecart(cart)


def main():
    try:
        option = sys.argv[1]
        scrn = sys.argv[2]
    except IndexError:
        option = input('a: map to encoded, b: encoded to map\n')
        scrn = input('Screen number (1 to 81)\n')
    scrn = int(scrn)

    cart = peekcart()
    if option == 'a':
        maplines = readmap(cart)
        mapdata = process(maplines)
        writeencoded(mapdata, scrn, cart)
        print(f'Saved map to screen {scrn}')
    elif option == 'b':
        mapdata = readencoded(scrn, cart)
        maplines = deprocess(mapdata)
        writemap(maplines, cart)
        print(f'Loaded map from screen {scrn}')
    else:
        print('Wrong')
        return
    pokecart(cart)


if __name__ == '__main__':
    main()
