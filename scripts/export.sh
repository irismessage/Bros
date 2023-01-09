#!/bin/bash
set -e
workdir="$(pwd)"
cart="$workdir"/cart/bros.p8

p8tool luamin "$cart"
cart_fmt="$workdir"/cart/bros_fmt.p8

cd "$workdir"/cart/
mkdir -p export/
cd export/
# spritesheet
pico8 "$cart" -export bros.png
# cart image
pico8 "$cart_fmt" -export bros.p8.png
# cart web player
pico8 "$cart_fmt" -export "-f bros.html"
# cart binaries
pico8 "$cart_fmt" -export "-i 2 -c 12 bros.bin"

cp bros.png "$workdir"/assets/spritesheet.png
