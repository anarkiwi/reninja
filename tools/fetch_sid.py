#!/usr/bin/env python3
"""Fetch the reference Last_Ninja.sid from HVSC (test fixture only).

The .sid is NOT stored in this repo. CI downloads it at test time to verify
that our source round-trips. Output: build/Last_Ninja.sid
"""
import os, sys, hashlib, urllib.request

MIRRORS = [
    "https://hvsc.brona.dk/HVSC/C64Music/MUSICIANS/D/Daglish_Ben/Last_Ninja.sid",
    "https://www.prg.dtu.dk/HVSC/C64Music/MUSICIANS/D/Daglish_Ben/Last_Ninja.sid",
]
# Known properties of the reference file (sanity checks, not secrets).
EXPECT_SIZE = 35617

def fetch(dest="build/Last_Ninja.sid"):
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    last_err = None
    for url in MIRRORS:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "reninja-ci"})
            data = urllib.request.urlopen(req, timeout=60).read()
            if data[:4] != b"PSID":
                raise ValueError(f"not a PSID file (got {data[:4]!r})")
            if len(data) != EXPECT_SIZE:
                raise ValueError(f"unexpected size {len(data)} != {EXPECT_SIZE}")
            with open(dest, "wb") as f:
                f.write(data)
            print(f"fetched {len(data)} bytes from {url}")
            print(f"  sha256 {hashlib.sha256(data).hexdigest()}")
            print(f"  -> {dest}")
            return dest
        except Exception as e:  # try next mirror
            last_err = e
            print(f"  mirror failed: {url}: {e}", file=sys.stderr)
    raise SystemExit(f"all mirrors failed; last error: {last_err}")

if __name__ == "__main__":
    fetch(sys.argv[1] if len(sys.argv) > 1 else "build/Last_Ninja.sid")
