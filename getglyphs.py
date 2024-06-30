import sys
import os
import requests
import time
import pathlib
import glob

base = sys.argv[1]
fp = open(sys.argv[2], "r")
codepoints = fp.readlines()
fp.close()

dir = []
for i in codepoints:
    i = i[:-1]
    c = i.split("-")[0]
    d1 = c[:-3]
    d2 = c[:-2]
    if not base + "/" + d1 + "/" + d2 in dir:
        dir.append(base + "/" + d1 + "/" + d2)
for i in dir:
    if not os.path.exists(i):
        os.makedirs(i)

temp = pathlib.Path(base)
svg = temp.glob("**/*.svg")
svg = map(lambda i: str(i), svg)
svg = set(svg)

for i in codepoints:
    i = i[:-1]
    c = i.split("-")[0]
    d1 = c[:-3]
    d2 = c[:-2]
    print("\r", i, sep="", end="        ")
    if not base + "/" + d1 + "/" + d2 + "/" + i + ".svg" in svg:
        #if 0x2ebf0 <= int(c[1:], 16) <= 0x2ee5d or 0x2ffc <= int(c[1:], 16) <= 0x2fff or c == "u31ef":
        #    url = "https://glyphwiki.org/glyph/unstable-" + i + ".svg"
        #else:
        #    url = "https://glyphwiki.org/glyph/" + i + ".svg"
        url = "https://glyphwiki.org/glyph/" + i + ".svg"
        count = 20
        while count > 0:
            data = requests.get(url).content
            if data[0:4] == b'<svg' and len(data) > 193:
                break
            print("\nfailed to get ... retry:", i, end='')
            time.sleep(1)
            count -= 1
        if data[0:4] == b'<svg' and len(data) > 193:
            with open(base + "/" + d1 + "/" + d2 + "/" + i + ".svg" ,mode='wb') as f:
                f.write(data)
        else:
            print("\nfailed to get:", i)

print("\r", end="")
