from _common import mine


print(' ' * 22, *(f'{i:0>2x}' for i in range(0,15)), sep='')
for world in range(1, 8+1):
    for level in range(1, 4+1):
        path = f'datamined/WORLD{world}{level}.DAT'
        data = mine(path, echo=False)
        header = data[:15]
        header_formatted = header.hex()
        print(path, header_formatted)
