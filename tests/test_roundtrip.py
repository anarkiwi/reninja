"""End-to-end round-trip test (runs in CI).

  1. fetch the reference Last_Ninja.sid from HVSC (not stored in the repo)
  2. assemble src/lastninja.asm with ACME -> build/lastninja.bin
  3. wrap it with the PSID header   -> build/lastninja.sid
  4. assert it is byte-for-byte identical to the reference

Requires `acme` on PATH (installed by the CI workflow).
"""
import os, shutil, subprocess, sys, pathlib
import pytest

ROOT = pathlib.Path(__file__).resolve().parents[1]
BUILD = ROOT / "build"
sys.path.insert(0, str(ROOT / "tools"))
import fetch_sid, build_sid, verify  # noqa: E402


@pytest.fixture(scope="session")
def reference_sid():
    BUILD.mkdir(exist_ok=True)
    dest = BUILD / "Last_Ninja.sid"
    fetch_sid.fetch(str(dest))
    return dest


@pytest.fixture(scope="session")
def assembled_bin():
    BUILD.mkdir(exist_ok=True)
    acme = shutil.which("acme")
    assert acme, "acme assembler not found on PATH"
    out = BUILD / "lastninja.bin"
    subprocess.run(
        [acme, "-f", "plain", "-o", str(out), str(ROOT / "src" / "lastninja.asm")],
        cwd=ROOT, check=True,
    )
    assert out.exists()
    return out


def test_image_size(assembled_bin):
    # $2000..$AAA3 inclusive of start = 35491 bytes
    assert assembled_bin.stat().st_size == 0xAAA3 - 0x2000


def test_header_is_124_bytes():
    assert len(bytes.fromhex(build_sid.HEADER_HEX)) == 124


def test_roundtrip_byte_exact(assembled_bin, reference_sid):
    out = BUILD / "lastninja.sid"
    build_sid.build(str(assembled_bin), str(out))
    rc = verify.verify(str(out), str(reference_sid))
    assert rc == 0, "rebuilt .sid does not match the HVSC reference"
