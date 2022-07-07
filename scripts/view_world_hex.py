from sys import argv
from _common import get_workdir


# 2215b per world
# 15b palette
# 2200b map
# 440b per screen


filename = f'datamined/WORLD{argv[1]}.DAT'
workdir = get_workdir()
path = workdir / filename
with open(path, 'rb') as file:
    file.seek(15)  # skip colour palette
    world_bytes = file.read()


i = 0
for screen in range(1, 6):
    print('screen', screen)
    for y in range(11):
        for x in range(20):
            print(
                '{:02x}{:02x}'.format(*world_bytes[i:i+2]).upper(),
                end=' '
            )
            i += 2
        print()
