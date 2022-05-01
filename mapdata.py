import pyperclip


def process(mapdata: list[str]) -> str:
    processed = []
    for l in mapdata:
        processed.append(l[:32])
    return ''.join(processed)


def multilineinput() -> list[str]:
    lines = []
    while True:
        i = input()
        if not i:
            break
        lines.append(i)
    return lines


def readmap() -> list[str]:
    maplines = []
    with open('cart/bros.p8', encoding='utf-8') as file:
        while True:
            line = file.readline()
            if line == '__map__\n':
                break
        for i in range(16):
            maplines.append(file.readline())
    return maplines
        

def main():
    result = process(readmap())
    result = f'\t"{result}",\n'
    print(result)
    pyperclip.copy(result)


if __name__ == '__main__':
    main()
