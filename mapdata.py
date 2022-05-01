def process(mapdata: list[str]) -> str:
    processed = []
    for l in mapdata:
        processed.append(l[:32])
    return ''.join(processed)


def deprocess(mapdata: str) -> list[str]:
    processed = []
    for i in range(0,512,32):
        processed.append(mapdata[i:i+32])
    return processed


def seekto(text: str):
    file = open('cart/bros.p8', encoding='utf-8')
    while True:
        line = file.readline()
        if line == text + '\n' or not line:
            break
    return file


def seektoscrn(file, scrn: int):
    for i in range(scrn):
        line = file.readline()
        if line == '}\n':
            break


def writeencoded(mapdata: list[str], scrn: int):
    file  = seekto('screens = {')
    seektoscrn(file, scrn)


def readmap() -> list[str]:
    maplines = []
    file = seekto('__map__')
    for i in range(16):
        maplines.append(file.readline())
    file.close()
    return maplines
        

def main():
    result = process(readmap())
    result = f'\t"{result}",\n'
    print(result)
    pyperclip.copy(result)


if __name__ == '__main__':
    main()
