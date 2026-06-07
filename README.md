# reninja — The Last Ninja (C64) music player, reassembled

A **byte-exact, reassemblable** disassembly of the Commodore 64 music player for
**The Last Ninja** (1987, System 3) — music by **Ben Daglish & Anthony Lees**,
driven by the **WEMUSIC** engine (Ben Daglish / Tony Crowther).

Assembling `src/lastninja.asm` with [Kick Assembler](http://theweb.dk/KickAssembler/)
reproduces the C64 payload of the original `.sid` exactly; `tools/build_sid.py`
adds the PSID header to recreate the whole file. CI fetches the reference from
[HVSC](https://www.hvsc.c64.org/) and proves the rebuild is **identical to the
last byte**.

> The original `.sid` is **not** stored here (it's copyrighted). It is fetched
> at test time as a fixture only.

## What's interesting about this player

The SID loads at `$2000` but the engine runs at `$B000`. The code at `$2000` is
a small **relocator**: `init` takes the subtune number, looks it up in a pointer
table, copies that subtune's 4 KB block up to `$B000` (banking BASIC/KERNAL out),
and calls the engine. The engine itself is a clean 3-voice driver:

- per-voice **note/pattern stream** with `$0000` end-markers that loop via a
  restart pointer (`fetch_note`);
- four near-identical **add/subtract sweep engines** for vibrato, a detuned
  second oscillator, and two pulse-width sweeps;
- note→frequency via dual lookup tables (`freqtab_hi` / `freqtab_lo`);
- a tight **SID output** loop writing all three voices (`$D400` stride 7), with
  voice 3 also driving the filter/volume register.

See [`docs/engine_annotated.txt`](docs/engine_annotated.txt) for a heavily
commented walkthrough, and [`src/engine.asm`](src/engine.asm) for the symbolic,
buildable source.

## Layout of the `$2000` image

| range         | contents                                   | file              |
|---------------|--------------------------------------------|-------------------|
| `$2000-$204C` | relocator / banking stub (symbolic)        | `src/lastninja.asm` |
| `$204D-$2062` | 11-entry subtune source-pointer table      | `src/lastninja.asm` |
| `$2063-$2D4B` | WEMUSIC engine (assembled at `$B000`)       | `src/engine.asm`    |
| `$2D4B-$AAA3` | song data + the other subtune blocks       | `src/musicdata.asm` |

## Build & verify

Requires Java + [Kick Assembler](http://theweb.dk/KickAssembler/) and Python 3.
Point `KICKASS_JAR` at `KickAss.jar` (or set `KICKASS` to a wrapper command).

```sh
export KICKASS_JAR=/path/to/KickAss.jar
make verify        # assemble, fetch reference, byte-compare
make test          # same, via pytest
```

Individual steps:

```sh
make prg           # java -jar KickAss.jar src/lastninja.asm -o build/lastninja.prg
make sid           # wrap with the PSID header  -> build/lastninja.sid
make fetch         # download the reference     -> build/Last_Ninja.sid
```

## Regenerating the data sections

`src/engine.asm` and `src/musicdata.asm` were produced from the reference `.sid`
by `tools/regen.py` (a disassembler/emitter — it only writes text, it doesn't
assemble). To reproduce them:

```sh
make fetch
python3 tools/regen.py build/Last_Ninja.sid
```

## CI

`.github/workflows/ci.yml` installs Java + Kick Assembler, fetches the reference
from HVSC, assembles, and runs the round-trip test on every push/PR. Dependabot
keeps the GitHub Actions and pip dependencies current.

## Credits & licensing

- Music & player: **Ben Daglish** and **Anthony Lees**, © 1987 System 3.
- This repository is a disassembly for preservation and study. The player code
  and music data are the work of their original authors; the annotations, build
  tooling, and tests here are provided for educational use.
