; =============================================================================
;  THE LAST NINJA  -  C64 music player  (reassemblable, byte-exact source)
;  Music: Ben Daglish & Anthony Lees (1987, System 3)
;  Driver: the "WEMUSIC" engine (Ben Daglish / Tony Crowther)
;
;  Reverse-engineered from MUSICIANS/D/Daglish_Ben/Last_Ninja.sid (HVSC).
;  Assembling this file reproduces the C64 payload of that .sid byte-for-byte;
;  tools/build_sid.py wraps it with the PSID header to recreate the full file.
;  CI fetches the original from HVSC and proves the round-trip.
;
;  Build:  acme -f plain -o build/lastninja.bin src/lastninja.asm
;  (-f plain = raw bytes, no load-address header; the header is added by
;   tools/build_sid.py)
;
;  Layout of the $2000 load image:
;     $2000-$204C  relocator / banking stub      (symbolic, below)
;     $204D-$2062  subtune source-pointer table  (!word)
;     $2063-$2D4B  WEMUSIC engine                 (engine.asm, runs at $B000)
;     $2D4B-$AAA3  music data + subtune blocks    (musicdata.asm)
; =============================================================================

!cpu 6502
* = $2000

; -----------------------------------------------------------------------------
;  RELOCATOR / BANKING STUB
;  PSID entry points: play = $2000, init = $2003.
;  init() takes the subtune number in A, copies that subtune's 16-page ($1000)
;  block up to $B000, then calls the engine. play() banks RAM in and ticks it.
; -----------------------------------------------------------------------------
play:                           ; PSID play entry ($2000)
        JMP banked_play

init:                           ; PSID init entry ($2003); A = subtune number
        LDX #$35
        STX $01                 ; $01=$35: BASIC+KERNAL ROM out, I/O in
                                ;   -> RAM visible under $A000-$BFFF for the engine
        ASL                     ; A = subtune*2 (table holds 2-byte pointers)
        TAX
        LDA subtune_ptrs,X      ; source pointer for this subtune ...
        STA $FB                 ;   $FB/$FC = source
        LDA subtune_ptrs+1,X
        STA $FC
        LDA #$00
        STA $FD                 ;   $FD/$FE = dest = $B000
        LDA #$B0
        STA $FE
        LDX #$10                ; copy 16 pages = $1000 bytes
copy_page:
        LDY #$00
copy_byte:
        LDA ($FB),Y
        STA ($FD),Y
        INY
        BNE copy_byte
        INC $FC
        INC $FE
        DEX
        BNE copy_page           ; engine now resident at $B000-$BFFF
call_init:
        LDX #$28                ; X/Y = $B728 data-pointer parameter
        LDY #$B7
        JSR engine_init_vec     ; -> $B000 (engine player_init)
        LDA #$37
        STA $01                 ; restore normal banking
        RTS

banked_play:                    ; per-frame tick
        LDA #$35
        STA $01                 ; bank RAM/I/O in
        JSR engine_play_vec     ; -> $B003 (engine player_play)
        LDA $B700               ; engine "initialised" flag
        BNE play_done
        JMP call_init           ;   not yet -> run init path
play_done:
        LDA #$37
        STA $01
        RTS

; -----------------------------------------------------------------------------
;  Subtune source-pointer table ($204D). 11 entries, little-endian.
;  Entry 0 ($2063) is the engine block reproduced by engine.asm.
; -----------------------------------------------------------------------------
subtune_ptrs:
        !word $2063, $2DAB, $3AA3, $4523, $5423, $6203
        !word $6E73, $7A6B, $8663, $92C3, $9E83

!if * != $2063 { !error "stub/table size drift: ", *, " != $2063" }

; -----------------------------------------------------------------------------
;  THE ENGINE
;  Physically lives here (file $2063) but executes at $B000 after relocation,
;  so we assemble it with !pseudopc $B000 - labels get run-time addresses while
;  the bytes are emitted at the file position.
; -----------------------------------------------------------------------------
!pseudopc $B000 {
        !source "engine.asm"
}

!if * != $2D4B { !error "engine placement drift: ", *, " != $2D4B" }

; -----------------------------------------------------------------------------
;  MUSIC DATA  ($2D4B-$AAA3)
; -----------------------------------------------------------------------------
        !source "musicdata.asm"

!if * != $AAA3 { !error "final image size drift: ", *, " != $AAA3" }
