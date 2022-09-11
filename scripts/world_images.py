# requires pillow
from PIL import Image

from _common import get_workdir
import convert_world


DIM_SPRITE = 8
DIM_SHEET = 16
LEN_SHEET = 64



def get_sprites() -> list[Image]:
    workdir = get_workdir()
    spritesheet = Image.open(workdir.joinpath('assets/spritesheet.png'))

    sprites = []
    for sprn in range(LEN_SHEET):
        left = (sprn % DIM_SHEET) * DIM_SPRITE
        upper = (sprn // DIM_SHEET) * DIM_SPRITE
        spr = spritesheet.crop((
            left,
            upper,
            left + DIM_SPRITE,
            upper + DIM_SPRITE
        ))
        sprites.append(spr)

    return sprites


def main():
    sprites = get_sprites()
    for i, spr in enumerate(sprites):
        spr.save(f'{i}.png')


if __name__ == '__main__':
    main()
