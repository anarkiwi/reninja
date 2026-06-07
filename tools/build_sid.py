#!/usr/bin/env python3
"""Wrap Kick Assembler's .prg output with the PSID header to reproduce the .sid.

Kick Assembler emits a .prg whose first two bytes are the load address ($2000,
little-endian) followed by the $2000..$AAA3 image. Because the reference PSID has
load=$0000 (i.e. the real load address is embedded as the first two data bytes),
the PSID data section IS exactly the .prg. So:

  full .sid = 124-byte PSID v2 header  +  the .prg bytes
"""
import os, sys

# Exact 124-byte PSID v2 header of the reference file (verbatim hex dump).
# Fields: magic=PSID ver=2 dataoff=$7c load=$0000 init=$2003 play=$2000
#         songs=11 start=3 speed=0  name="The Last Ninja"
#         author="Ben Daglish & Anthony Lees"  released="1987 System 3"
#         flags=$0014 startPage=$04 pageLength=$1c
HEADER_HEX = "505349440002007c000020032000000b000300000000546865204c617374204e696e6a6100000000000000000000000000000000000042656e204461676c697368202620416e74686f6e79204c656573000000000000313938372053797374656d2033000000000000000000000000000000000000000014041c0000"

def build(prg_path="build/lastninja.prg", out="build/lastninja.sid"):
    header = bytes.fromhex(HEADER_HEX)
    assert len(header) == 124, f"header is {len(header)} bytes, expected 124"
    with open(prg_path, "rb") as f:
        prg = f.read()
    # sanity: prg must start with the $2000 load word
    assert prg[:2] == bytes([0x00, 0x20]), f"unexpected .prg load word {prg[:2].hex()}"
    data = header + prg
    with open(out, "wb") as f:
        f.write(data)
    print(f"wrote {out} ({len(data)} bytes) = 124 header + {len(prg)} prg")
    return out

if __name__ == "__main__":
    a = sys.argv[1:]
    build(a[0] if len(a) > 0 else "build/lastninja.prg",
          a[1] if len(a) > 1 else "build/lastninja.sid")
