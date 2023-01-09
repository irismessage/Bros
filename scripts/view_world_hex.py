#!/usr/bin/env python3

from sys import argv
from _common import mine
from convert_world import WORLD_WIDTH, WORLD_HEIGHT


# 2215b per world
# 15b palette
# 2200b map
# 440b per screen


# offset is colour palette
world_bytes = mine(f'datamined/WORLD{argv[1]}.DAT', offset=15)


i = 0
for screen in range(1, 6):
    print('screen', screen)
    for y in range(WORLD_HEIGHT):
        for x in range(WORLD_WIDTH):
            print(
                '{:02x}{:02x}'.format(*world_bytes[i:i+2]).upper(),
                end=' '
            )
            i += 2
        print()
