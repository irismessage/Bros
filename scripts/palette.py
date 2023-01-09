#!/usr/bin/env python3

RGB = tuple[int]


# https://pico-8.fandom.com/wiki/Graphics
# https://pico-8.fandom.com/wiki/Palette
palette_pico8 = {
    0: '000000',
    1: '1D2B53',
    2: '7E2553',
    3: '008751',
    4: 'AB5236',
    5: '5F574F',
    6: 'C2C3C7',
    7: 'FFF1E8',
    8: 'FF004D',
    9: 'FFA300',
    10: 'FFEC27',
    11: '00E436',
    12: '29ADFF',
    13: '83769C',
    14: 'FF77A8',
    15: 'FFCCAA',
    128: '291814',
    129: '111D35',
    130: '422136',
    131: '125359',
    132: '742F29',
    133: '49333B',
    134: 'A28879',
    135: 'F3EF7D',
    136: 'BE1250',
    137: 'FF6C24',
    138: 'A8E72E',
    139: '00B543',
    140: '065AB5',
    141: '754665',
    142: 'FF6E59',
    143: 'FF9D81',
}


dark_grey_shade = '252525'
lorange_text = 'be7917'
dorange_bricks = '813c01'
red = '73003a'
black = '000000'
dark_blue_bg = '203ecb'
light_grey = '454545'
pale_grey = '838383'
red_but_scary = '6f0a00'
kooky_violet = '4563ef'
yay_gray = '6a6a6a'

# 0 black shading, clock
# 1 light orange, text
# 2 dark orange, bricks
# 3 red, clothes, mushroom
# 4 dark blue, background
palette_orig = {
    11: (dark_grey_shade, lorange_text, dorange_bricks, red, dark_blue_bg),
    12: (dark_grey_shade, lorange_text, '005f88', red, black),
    13: 11,
    14: (light_grey, lorange_text, dorange_bricks, red, black),
    21: 11,
    22: (dark_grey_shade, lorange_text, dark_blue_bg, red, black),
    23: (dark_grey_shade, lorange_text, dark_blue_bg, red, '001daa'),
    24: (dark_grey_shade, lorange_text, yay_gray, red, black),
    31: (dark_grey_shade, lorange_text, dorange_bricks, red, '4f0014'),
    32: (dark_grey_shade, lorange_text, '007231', red, black),
    33: 31,
    34: 32,
    41: (dark_grey_shade, lorange_text, dorange_bricks, red, light_grey),
    42: (light_grey, lorange_text, '601b00', red, black),
    43: 41,
    44: (light_grey, lorange_text, dark_grey_shade, red, black),
    51: 11,
    52: (dark_grey_shade, lorange_text, dorange_bricks, red, black),
    53: 41,
    54: 52,
    61: (black, pale_grey, light_grey, red_but_scary, '000085'),
    62: (black, pale_grey, light_grey, red_but_scary, black),
    63: (black, pale_grey, dark_grey_shade, red_but_scary, '3200b8'),
    64: 41,
    71: (dark_grey_shade, 'c04feb', '902c02', red, '203ecb'),
    72: ('a6a6a6', '5d7dff', yay_gray, '8212ad', black),
    73: (dark_grey_shade, lorange_text, '5421da', '951859', kooky_violet),
    74: (light_grey, lorange_text, black, '941859', black),
    81: (light_grey, lorange_text, black, kooky_violet, red_but_scary),
    82: (light_grey, 'e39e3e', black, kooky_violet, black),
    83: (light_grey, yay_gray, black, '5e7cff', red_but_scary),
    84: (black, lorange_text, black, red, black),
}


def hexc_to_rgb(hexc: str) -> RGB:
    return (int(hexc[0:2], 16), int(hexc[2:4], 16), int(hexc[4:6], 16))


def diff_rgb(rgb1: RGB, rgb2: RGB) -> int:
    return sum(abs(rgb1[i] - rgb2[i]) for i in range(3))


def closest_pico(hexc: str) -> int:
    rgb = hexc_to_rgb(hexc)

    closest_diff = float('inf')
    closest_colour_id = None
    for pico_id, pico_hexc in palette_pico8.items():
        pico_rgb = hexc_to_rgb(pico_hexc)
        diff = diff_rgb(rgb, pico_rgb)
        if diff < closest_diff:
            closest_diff = diff
            closest_colour_id = pico_id

    return closest_colour_id


def make_pal_tables() -> list[str]:
    PICO_BASE = (0, 9, 4, 2, 12)

    pal_tables = []
    for orig_remap in palette_orig.values():
        if isinstance(orig_remap, int):
            orig_remap = palette_orig[orig_remap]

        pico_remap = [closest_pico(hexc) for hexc in orig_remap]
        table_list = []
        for i in range(5):
            # table_list.append(f'[{PICO_BASE[i]}]={pico_remap[i]}')
            table_list.append(f'{pico_remap[i]}')
        table = '\t{' + ','.join(table_list) + '},'
        pal_tables.append(table)

    return pal_tables


def main():
    tabs = make_pal_tables()
    tabs_joined = '\n'.join(tabs)
    print(tabs_joined)


if __name__ == '__main__':
    main()
