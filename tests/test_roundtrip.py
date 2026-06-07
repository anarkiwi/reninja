"""End-to-end round-trip test (runs in CI).

  1. fetch the reference Last_Ninja.sid from HVSC (not stored in the repo)
  2. assemble src/lastninja.asm with Kick Assembler -> build/lastninja.prg
  3. wrap it with the PSID header                  -> build/lastninja.sid
  4. assert it is byte-for-byte identical to the reference

Requires Java and Kick Assembler. The path to KickAss.jar is taken from the
KICKASS_JAR environment variable (set by the CI workflow).
"""
import os, shutil, subprocess, sys, pathlib
import pytest

ROOT = pathlib.Path(__file__).resolve().parents[1]
BUILD = ROOT / "build"
sys.path.insert(0, str(ROOT / "tools"))
import fetch_sid, build_sid, verify  # noqa: E402


def _kickass_cmd(src, out):
    jar = os.environ.get("KICKASS_JAR")
    if jar:
        java = shutil.which("java")
        assert java, "java not found on PATH"
        return [java, "-jar", jar, str(src), "-o", str(out)]
    # fall back to a `kickass` wrapper if one is on PATH
    wrapper = shutil.which("kickass") or shutil.which("KickAss")
    assert wrapper, "set KICKASS_JAR or put a `kickass` wrapper on PATH"
    return [wrapper, str(src), "-o", str(out)]


@pytest.fixture(scope="session")
def reference_sid():
    BUILD.mkdir(exist_ok=True)
    dest = BUILD / "Last_Ninja.sid"
    fetch_sid.fetch(str(dest))
    return dest


@pytest.fixture(scope="session")
def assembled_prg():
    BUILD.mkdir(exist_ok=True)
    out = BUILD / "lastninja.prg"
    cmd = _kickass_cmd(ROOT / "src" / "lastninja.asm", out)
    subprocess.run(cmd, cwd=ROOT, check=True)
    assert out.exists(), "Kick Assembler produced no .prg"
    return out


def test_prg_size(assembled_prg):
    # 2-byte load word + the $2000..$AAA3 image (35491 bytes)
    assert assembled_prg.stat().st_size == 2 + (0xAAA3 - 0x2000)


def test_header_is_124_bytes():
    assert len(bytes.fromhex(build_sid.HEADER_HEX)) == 124


def test_roundtrip_byte_exact(assembled_prg, reference_sid):
    out = BUILD / "lastninja.sid"
    build_sid.build(str(assembled_prg), str(out))
    rc = verify.verify(str(out), str(reference_sid))
    assert rc == 0, "rebuilt .sid does not match the HVSC reference"
