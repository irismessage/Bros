#!/usr/bin/env python3

from sys import argv

import mapdata
from convert_world import convert_world


def main():
    start = int(argv[1])
    try:
        stop = int(argv[2])
    except IndexError:
        stop = mapdata.LEVEL_COUNT

    if not (1 <= start < stop <= mapdata.LEVEL_COUNT):
        raise ValueError(
            f'Range must be between 1 and {mapdata.LEVEL_COUNT}'
        )

    try:
        for i in range(start, stop+1):
            print('Screen', i)
            mapdata.mapdata(mapdata.COMMAND_LOAD, i)
            input('Press enter to save and continue\n')
            mapdata.mapdata(mapdata.COMMAND_SAVE, i)
            print('\n')
    except KeyboardInterrupt:
        print('\n^C')
        print(i)


if __name__ == '__main__':
    main()
