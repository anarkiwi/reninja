#!/usr/bin/env python3
"""Wrap the assembled C64 payload (build/lastninja.bin) with the PSID header
to reproduce the full .sid file.

  full .sid = 124-byte PSID v2 header
            + 2-byte load address ($2000, little-endian)
            + the assembled $2000..$AAA3 image

The header is the exact PSID v2 header of the reference file (metadata only:
title/author/year, init=$2003, play=$2000, 11 songs, start song 3).
"""
import os, sys

# Exact 124-byte PSID v2 header of the reference file (verbatim hex dump).
# Fields: magic=PSID ver=2 dataoff=$7c load=$0000 init=$2003 play=$2000
#         songs=11 start=3 speed=0  name="The Last Ninja"
#         author="Ben Daglish & Anthony Lees"  released="1987 System 3"
#         flags=$0014 startPage=$04 pageLength=$1c
HEADER_HEX = "505349440002007c000020032000000b000300000000546865204c617374204e696e6a6100000000000000000000000000000000000042656e204461676c697368202620416e74686f6e79204c656573000000000000313938372053797374656d2033000000000000000000000000000000000000000014041c0000"
LOAD_WORD = bytes([0x00, 0x20])  # $2000 little-endian (PSID load field is 0 => embedded here)

def build(bin_path="build/lastninja.bin", out="build/lastninja.sid"):
    header = bytes.fromhex(HEADER_HEX)
    assert len(header) == 124, f"header is {len(header)} bytes, expected 124"
    with open(bin_path, "rb") as f:
        image = f.read()
    data = header + LOAD_WORD + image
    with open(out, "wb") as f:
        f.write(data)
    print(f"wrote {out} ({len(data)} bytes) = 124 header + 2 load + {len(image)} image")
    return out

if __name__ == "__main__":
    a = sys.argv[1:]
    build(a[0] if len(a) > 0 else "build/lastninja.bin",
          a[1] if len(a) > 1 else "build/lastninja.sid")
