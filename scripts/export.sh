#!/bin/bash
set -e
workdir="$(pwd)"
cart="$workdir"/cart/bros.p8

p8tool luamin "$cart"
cart_fmt="$workdir"/cart/bros_fmt.p8

cd "$workdir"/cart/
mkdir -p export/
cd export/
pico8 "$cart" -export bros.png
pico8 "$cart" -export bros.p8.png
pico8 "$cart" -export "-f bros.html"
pico8 "$cart" -export "-i 2 -c 12 bros.bin"

cp bros.png "$workdir"/assets/spritesheet.png
