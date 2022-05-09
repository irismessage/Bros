import string
import sys


with open(sys.argv[1], 'rb') as file:
    contents = file.read()


# for b in contents:
#     print(f'{b:02x}', end='')


# for i in range(1, len(contents)):
#     for j in range(0, len(contents), i):
#         for b in contents[j:j+i]:
#             print(f'{b:02x}', end='')
#             print(f'{b & 0xF0:02x}', end='')
#             print(f'{(b & 0x0F) >> 4:02x}', end='')
#         print()
#     input('\n')


# for i in range(8):
#     contents = contents[i:]
#     for j in range(0, len(contents), 4):
#         for b in contents[j:j+4]:
#             print(f'{b:02x}', end='')
#         print()
#     input('\n')


hexd = string.hexdigits[:16]
colours = {}
for offset, offset2 in ((30, 0), (90, 8)):
    print(offset2)
    for i in range(8):
        colours[hexd[i+offset2]] = f'\u001b[{offset+i}m\u001b[{offset+i+10}m{hexd[i]}'
# print(colours)
# for k, v in colours.items():
#     print(k, v)
# contents_hex = []
# for b in contents:
#     for i in range(3):
#         contents_hex.append(f'{(b>>4*i)&0x03:02x}')
# contents_hex = ''.join(contents_hex)
contents_hex = ''.join(f'{b:02x}' for b in contents)
for h in contents_hex:
    print(colours[h], end='')
