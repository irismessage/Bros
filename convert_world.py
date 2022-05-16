import sys


SPRITES_P8 = {
    # entities
    1: "bg",
    2: "bro_idle",
    16: "spiker",
    17: "fguy",
    19: "👀",
    21: "mothralite",
    23: "plant",
    # flr tiles
    32: "cobble_full",
    33: "cobble_R",
    34: "cobble_L",
    35: "brick_full",
    36: "brick_R",
    37: "brick_L",
    38: "fragile_full",
    39: "fragile_R",
    40: "fragile_L",
    41: "gangway",
    # pipes
    48: "pipe_tL",
    49: "pipe_tR",
    50: "pipe_bL",
    51: "pipe_bR",
    52: "pipe_tL9",
    53: "pipe_tR9",
    54: "pipe_bL9",
    55: "pipe_bR9",
    # tiles with items
    27: "block_empty",
    42: "block_coin",
    44: "block_shroom",
    46: "block_wep",
    43: "brick_coin",
    45: "brick_shroom",
    47: "brick_wep",
    58: "coin",
}
SPRITES_P8_R = {v: k for k,v in SPRITES_P8.items()}

SPRITES_AT = {
    0X0000: "bg",
    0XA1A2: "fguy",
    0X6D6E: "pipe_tL",
    0X6F70: "pipe_tR",
    0X7172: "pipe_bL",
    0X7374: "pipe_bR",
    0X6364: "brick_full",
    0X6768: "block_empty",
    0X696A: "block_coin",
    0X6966: "block_shroom",
    0X6162: "cobble_full",
    0X6B6C: "coin",
}


def mine() -> bytes:
    world_path = f'datamined/WORLD{sys.argv[1]}.DAT'
    with open(world_path, 'rb') as file:
        world_bytes = file.read()
    return world_bytes

