import sys

# import pyautogui
# import pydirectinput
from convert_world import convert_world
from mapdata import mapdata


# def reload():
#     a = {'interval': 1}
#     handler = pydirectinput
#     pyautogui.hotkey('alt', 'tab', **a)
#     pyautogui.hotkey('ctrl', 'r', **a)
#     pyautogui.press('esc', presses=2, **a)
#     pyautogui.scroll(-1)


def main():
    start = int(sys.argv[1])
    try:
        stop = int(sys.argv[2])
    except IndexError:
        stop = 120

    try:
        for i in range(start, stop+1):
            print('Screen', i)
            convert_world(i)
            # reload()
            input('Press enter to save and contiue\n')
            mapdata('a', i)
    except KeyboardInterrupt:
        print('\n^C')
        print(i)


if __name__ == '__main__':
    main()
