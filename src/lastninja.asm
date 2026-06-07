// =============================================================================
//  THE LAST NINJA  -  C64 music player  (reassemblable, byte-exact source)
//  Music: Ben Daglish & Anthony Lees (1987, System 3)
//  Driver: the "WEMUSIC" engine (Ben Daglish / Tony Crowther)
//
//  Reverse-engineered from MUSICIANS/D/Daglish_Ben/Last_Ninja.sid (HVSC).
//  Assembling this with Kick Assembler reproduces the C64 payload of that .sid
//  byte-for-byte; tools/build_sid.py wraps it with the PSID header to recreate
//  the full file. CI fetches the original from HVSC and proves the round-trip.
//
//  Build:  java -jar KickAss.jar src/lastninja.asm -o build/lastninja.prg
//  (Kick Assembler emits a .prg = 2-byte load address + image, which is exactly
//   the PSID data section, so build_sid.py just prepends the 124-byte header.)
//
//  Layout of the $2000 load image:
//     $2000-$204C  relocator / banking stub      (symbolic, below)
//     $204D-$2062  subtune source-pointer table  (.word)
//     $2063-$2D4B  WEMUSIC engine                 (engine.asm, runs at $B000)
//     $2D4B-$AAA3  music data + subtune blocks    (musicdata.asm)
// =============================================================================

*=$2000

// -----------------------------------------------------------------------------
//  RELOCATOR / BANKING STUB
//  PSID entry points: play = $2000, init = $2003.
//  init() takes the subtune number in A, copies that subtune's 16-page ($1000)
//  block up to $B000, then calls the engine. play() banks RAM in and ticks it.
// -----------------------------------------------------------------------------
play:                           // PSID play entry ($2000)
        jmp banked_play

init:                           // PSID init entry ($2003); A = subtune number
        ldx #$35
        stx $01                 // $01=$35: BASIC+KERNAL ROM out, I/O in
                                //   -> RAM visible under $A000-$BFFF for the engine
        asl                     // A = subtune*2 (table holds 2-byte pointers)
        tax
        lda subtune_ptrs,x      // source pointer for this subtune ...
        sta $FB                 //   $FB/$FC = source
        lda subtune_ptrs+1,x
        sta $FC
        lda #$00
        sta $FD                 //   $FD/$FE = dest = $B000
        lda #$B0
        sta $FE
        ldx #$10                // copy 16 pages = $1000 bytes
copy_page:
        ldy #$00
copy_byte:
        lda ($FB),y
        sta ($FD),y
        iny
        bne copy_byte
        inc $FC
        inc $FE
        dex
        bne copy_page           // engine now resident at $B000-$BFFF
call_init:
        ldx #$28                // X/Y = $B728 data-pointer parameter
        ldy #$B7
        jsr engine_init_vec     // -> $B000 (engine player_init)
        lda #$37
        sta $01                 // restore normal banking
        rts

banked_play:                    // per-frame tick
        lda #$35
        sta $01                 // bank RAM/I/O in
        jsr engine_play_vec     // -> $B003 (engine player_play)
        lda $B700               // engine "initialised" flag
        bne play_done
        jmp call_init           //   not yet -> run init path
play_done:
        lda #$37
        sta $01
        rts

// -----------------------------------------------------------------------------
//  Subtune source-pointer table ($204D). 11 entries, little-endian.
//  Entry 0 ($2063) is the engine block reproduced by engine.asm.
// -----------------------------------------------------------------------------
subtune_ptrs:
        .word $2063, $2DAB, $3AA3, $4523, $5423, $6203
        .word $6E73, $7A6B, $8663, $92C3, $9E83

.errorif (* != $2063), "stub/table size drift, expected $2063"

// -----------------------------------------------------------------------------
//  THE ENGINE
//  Physically lives here (file $2063) but executes at $B000 after relocation,
//  so we assemble it with .pseudopc $B000 - labels get run-time addresses while
//  the bytes are emitted at the file position.
// -----------------------------------------------------------------------------
.pseudopc $B000 {
        .import source "engine.asm"
}

.errorif (* != $2D4B), "engine placement drift, expected $2D4B"

// -----------------------------------------------------------------------------
//  MUSIC DATA  ($2D4B-$AAA3)
// -----------------------------------------------------------------------------
        .import source "musicdata.asm"

.errorif (* != $AAA3), "final image size drift, expected $AAA3"
