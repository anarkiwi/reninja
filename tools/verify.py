#!/usr/bin/env python3
"""Byte-for-byte compare our rebuilt .sid against the reference fetched from HVSC.
Exits non-zero (and prints the first differing offset) on any mismatch.
"""
import sys

def verify(ours="build/lastninja.sid", ref="build/Last_Ninja.sid"):
    a = open(ours, "rb").read()
    b = open(ref, "rb").read()
    if a == b:
        print(f"OK: {ours} == {ref} ({len(a)} bytes, identical)")
        return 0
    print(f"MISMATCH: lengths ours={len(a)} ref={len(b)}", file=sys.stderr)
    n = min(len(a), len(b))
    for i in range(n):
        if a[i] != b[i]:
            ctx_a = a[max(0, i-4):i+5].hex()
            ctx_b = b[max(0, i-4):i+5].hex()
            # offset within the C64 image ($2000-based) if past the 126-byte preamble
            note = f" (image ${0x2000 + (i-126):04X})" if i >= 126 else " (header)"
            print(f"first diff at file offset {i} (0x{i:x}){note}:", file=sys.stderr)
            print(f"  ours: ...{ctx_a}", file=sys.stderr)
            print(f"  ref:  ...{ctx_b}", file=sys.stderr)
            break
    else:
        print(f"common prefix matches; length differs at {n}", file=sys.stderr)
    return 1

if __name__ == "__main__":
    a = sys.argv[1:]
    raise SystemExit(verify(a[0] if len(a) > 0 else "build/lastninja.sid",
                            a[1] if len(a) > 1 else "build/Last_Ninja.sid"))
