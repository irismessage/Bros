import sys

from convert_world import convert_world
from mapdata import mapdata


def main():
    start = int(sys.argv[1])
    stop = int(sys.argv[2])

    for i in range(start, stop+1):
        print('Screen', i)
        convert_world(i)
        input('Press enter to save and contiue')
        mapdata('a', i)


if __name__ == '__main__':
    main()
