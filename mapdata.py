import sys


# background sprite
BG = 1
CART_PATH = 'cart/bros.p8'
# rows to skip at the top
OFFSET = 2
# size of the relevant map section
ROWS = 13
COLUMNS = 16
# length of the hex string in the cart __map__ block
WIDTH = 2 * COLUMNS
P8SCII = [
    r"\0", r"\*", r"\#", r"\-", r"\|", r"\+", r"\^", r"\a", r"\b", r"\t", r"\n", r"\v", r"\f", r"\r", r"\014", r"\015", "▮", "■", "□", "⁙", "⁘", "‖", "◀", "▶", "「", "」", "¥", "•", "、", "。", "゛", "゜", " ", "!", r'\"', "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", r"\\", "]", "^", "_", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", "○", "█", "▒", "🐱", "⬇️", "░", "✽", "●", "♥", "☉", "웃", "⌂", "⬅️", "😐", "♪", "🅾️", "◆", "…", "➡️", "★", "⧗", "⬆️", "ˇ", "∧", "❎", "▤", "▥", "あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま", "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "を", "ん", "っ", "ゃ", "ゅ", "ょ", "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ワ", "ヲ", "ン", "ッ", "ャ", "ュ", "ョ", "◜", "◝",
]

Lines = list[str]


def p8scii_encode(text: str) -> bytearray:
    """Convert a python string to p8scii bytes."""
    binary = bytearray()
    i = 0
    while i < len(text) - 1:
        char = text[i]
        # escape codes (weird)
        if char == '\\':
            escape3 = text[i:i+3]
            if escape3 in (r'\014', r'\015'):
                match = escape3
                i += 3
            else:
                match = text[i:i+2]
                i += 2
        else:
            match = char
            i += 1
        binary.append(P8SCII.index(match))

    return binary


def p8scii_decode(binary: bytearray) -> str:
    """Convert p8scii bytes to a python string."""
    text = ''.join(P8SCII[b] for b in binary)
    return text


def compress(mapdata: str) -> str:
    """Convert map from a string of 2-digit hex to a compressed pico-8 string literal"""
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
    """Convert map from a compressed pico-8 string literal to a string of 2-digit hex."""
    mapdata_bytes = p8scii_encode(mapdata)
    for i in range(len(mapdata_bytes) - 1, -1, -1):
        if mapdata_bytes[i] == BG:
            repeats = mapdata_bytes[i+1]
            mapdata_bytes[i:i+2] = [BG] * repeats
    mapdata = mapdata_bytes.hex()
    return mapdata


def process(maplines: Lines) -> str:
    """Take a list of rows in p8 cart format and join them into a single string"""
    processed_lines = []
    for line in maplines:
        processed_lines.append(line[:WIDTH])
    processed_uncompressed = ''.join(processed_lines)
    processed = compress(processed_uncompressed)
    return processed


def deprocess(mapdata: str) -> Lines:
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


def writeencoded(mapdata: str, scrn: int, cart: Lines):
    """Write encoded map data to the lua block of the cart lines"""
    index = screensindex(cart)
    cart[index + scrn] = f'\t"{mapdata}",\n'


def readencoded(scrn: int, cart: Lines) -> str:
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
        scrn = input('Screen number (1 to 120)\n')
    scrn = int(scrn)
    if not (1 <= scrn <= 120):
        raise ValueError('Bad scrn')


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
