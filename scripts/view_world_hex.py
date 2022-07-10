from sys import argv
from _common import mine


# 2215b per world
# 15b palette
# 2200b map
# 440b per screen


# offset is colour palette
world_bytes = mine(f'datamined/WORLD{argv[1]}.DAT', offset=15)


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
