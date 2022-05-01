import sys


CART_PATH = 'cart/bros.p8'
Lines = list[str]


def process(maplines: Lines) -> str:
    processed = []
    for line in maplines:
        processed.append(line[:32])
    return ''.join(processed)


def deprocess(mapdata: str) -> Lines:
    processed = []
    for i in range(0,512,32):
        processed.append(mapdata[i:i+32])
    return processed


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
    return cart.index('__map__\n') + 3


def readmap(cart: Lines) -> Lines:
    maplines = []
    index = mapindex(cart)
    maplines = cart[index:index + 13]
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
        cart[index+i] = line + cart[index+i][32:]


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
    elif option == 'b':
        mapdata = readencoded(scrn, cart)
        maplines = deprocess(mapdata)
        writemap(maplines, cart)
    else:
        print('Wrong')
        return
    pokecart(cart)
    print('Done')


if __name__ == '__main__':
    main()
