// engine.asm  -  The Last Ninja / WEMUSIC player engine
// Resident at $B000 after the relocator copies it there.
// Assembled inside  .pseudopc $B000 { .import source "engine.asm" }  by
// lastninja.asm, so labels carry their run-time ($Bxxx) addresses while the
// bytes land at file $2063. Code is symbolic; tables are .byte (byte-exact).

// ---- equates (names resolve to their exact addresses; bytes unchanged) ----
.label SID_FREQ_LO    = $D400
.label SID_FREQ_HI    = $D401
.label SID_PW_LO      = $D402
.label SID_PW_HI      = $D403
.label SID_CTRL       = $D404
.label SID_AD         = $D405
.label SID_SR         = $D406
.label SID_FCUT_LO    = $D415
.label SID_FCUT_HI    = $D416
.label SID_RESON      = $D417
.label SID_VOL        = $D418
.label freqtab_hi     = $B500
.label freqtab_lo     = $B55F
.label v_freq_hi      = $B5EE
.label v_freq_lo      = $B5F4
.label v_freq2_hi     = $B5F1
.label v_freq2_lo     = $B5F7
.label v_pw_hi        = $B5FA
.label v_pw_lo        = $B600
.label v_pw2_hi       = $B5FD
.label v_pw2_lo       = $B603
.label v_ctrl         = $B606
.label v_ctrl2        = $B609
.label v_oscsel       = $B60C
.label v_oscsel_ctr   = $B60F
.label v_tempo        = $B612
.label v_eff          = $B615
.label v_finetune     = $B654
.label v_ad           = $B5E8
.label v_sr           = $B5EB
.label cur_voice      = $B5D9
.label cur_voice2     = $B5DA
.label cmd_lo         = $B5E2
.label cmd_hi         = $B5E3
.label inst_ptr       = $B5DC

engine_init_vec:
    jmp  player_init
engine_play_vec:
    jmp  player_play
// per-voice arpeggio / wavetable streams
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B006
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $22, $00, $22, $00, $22, $00, $22, $E0   // $B016
    .byte $32, $11, $2D, $11, $00, $00, $15, $11, $15, $11, $13, $11, $15, $11, $6B, $11   // $B026
    .byte $64, $11, $13, $11, $15, $11, $18, $11, $15, $11, $18, $21, $1A, $11, $18, $11   // $B036
    .byte $15, $11, $13, $11, $00, $00, $13, $11, $13, $11, $11, $11, $13, $11, $6D, $11   // $B046
    .byte $68, $11, $11, $11, $13, $11, $18, $11, $15, $11, $18, $21, $1A, $11, $18, $11   // $B056
    .byte $15, $11, $13, $11, $00, $00, $61, $20, $5F, $10, $61, $20, $5F, $10, $EB, $20   // $B066
    .byte $07, $15, $FF, $B3, $AD, $80, $00, $00, $A1, $21, $18, $12, $DF, $11, $A1, $21   // $B076
    .byte $18, $22, $A1, $21, $18, $12, $DF, $11, $A1, $21, $18, $22, $00, $00, $DF, $21   // $B086
    .byte $16, $12, $DD, $11, $DF, $21, $16, $22, $DF, $21, $16, $12, $DD, $11, $DF, $21   // $B096
    .byte $16, $22, $00, $00, $6B, $20, $66, $20, $A4, $20, $63, $10, $A4, $20, $66, $10   // $B0A6
    .byte $63, $20, $61, $10, $5F, $10, $5C, $10, $5F, $10, $DF, $40, $07, $23, $FF, $E8   // $B0B6
    .byte $61, $C0, $00, $00, $A8, $12, $A6, $12, $A8, $22, $A6, $22, $9F, $22, $A1, $22   // $B0C6
    .byte $A6, $22, $A3, $12, $A1, $12, $9F, $12, $9C, $12, $A1, $12, $9F, $12, $A1, $22   // $B0D6
    .byte $A3, $22, $9C, $22, $A1, $22, $A6, $22, $A3, $12, $A1, $12, $9F, $12, $9C, $12   // $B0E6
    .byte $00, $00, $AD, $12, $AB, $12, $AD, $22, $AB, $22, $A4, $22, $A6, $22, $AB, $22   // $B0F6
    .byte $A8, $12, $A6, $12, $A4, $12, $A1, $12, $A6, $12, $A4, $12, $A6, $22, $A8, $22   // $B106
    .byte $A1, $22, $A6, $22, $AB, $22, $A8, $12, $A6, $12, $A4, $12, $A1, $12, $00, $00   // $B116
    .byte $D5, $E2, $D3, $22, $D1, $E2, $D3, $22, $00, $00, $74, $12, $72, $12, $74, $22   // $B126
    .byte $72, $22, $6B, $22, $6D, $22, $72, $22, $6F, $12, $6D, $12, $6B, $12, $68, $12   // $B136
    .byte $6D, $12, $6B, $12, $6D, $22, $6F, $22, $68, $22, $6D, $22, $72, $22, $6F, $12   // $B146
    .byte $6D, $12, $6B, $12, $68, $12, $00, $00, $61, $C0, $E6, $40, $14, $11, $00, $CD   // $B156
    .byte $DF, $A0, $24, $18, $FF, $DE, $A8, $10, $AB, $20, $66, $10, $E8, $E0, $14, $18   // $B166
    .byte $00, $33, $DF, $40, $0C, $19, $FE, $ED, $EB, $E0, $24, $18, $00, $3C, $5F, $20   // $B176
    .byte $A1, $20, $9F, $10, $A1, $20, $5F, $10, $DF, $A0, $04, $0D, $FD, $DB, $00, $00   // $B186
    .byte $72, $20, $70, $10, $6B, $20, $69, $10, $E4, $80, $0C, $14, $00, $98, $9F, $20   // $B196
    .byte $DF, $00, $14, $48, $FF, $F4, $DF, $00, $14, $48, $FF, $F4, $00, $00, $61, $C0   // $B1A6
    .byte $DF, $40, $18, $14, $FF, $D7, $61, $C0, $DF, $40, $10, $14, $FF, $91, $A6, $C0   // $B1B6
    .byte $DF, $40, $08, $10, $FF, $CD, $61, $00   // $B1C6
// instrument data records (base for ($FC),Y reads)
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B1CE
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B1DE
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $AC   // $B1EE
    .byte $0B, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B1FE
    .byte $00, $00, $00, $00, $00, $00, $00, $02, $20, $00, $04, $04, $00, $60, $00, $60   // $B20E
    .byte $00, $00, $00, $08, $00, $10, $00, $10, $41, $40, $00, $00, $01, $00, $AC, $20   // $B21E
    .byte $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B22E
    .byte $00, $00, $00, $00, $00, $00, $02, $00, $00, $04, $04, $00, $60, $00, $60, $00   // $B23E
    .byte $00, $00, $FF, $00, $00, $00, $10, $41, $40, $00, $00, $00, $00, $AC, $2B, $30   // $B24E
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00   // $B25E
    .byte $00, $00, $00, $00, $00, $02, $00, $00, $00, $00, $00, $00, $FF, $91, $08, $00   // $B26E
    .byte $00, $08, $00, $10, $00, $10, $41, $40, $00, $00, $09, $00, $09, $00, $00, $00   // $B27E
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $01, $04, $00   // $B28E
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08   // $B29E
    .byte $08, $00, $40, $00, $40, $41, $00, $00, $00, $28, $00, $09, $00, $00, $01, $01   // $B2AE
    .byte $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B2BE
    .byte $00, $17, $00, $02, $00, $00, $04, $03, $01, $00, $01, $00, $00, $00, $00, $00   // $B2CE
    .byte $00, $00, $00, $00, $15, $00, $00, $00, $02, $00, $09, $00, $00, $01, $03, $02   // $B2DE
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $04, $00, $00, $00   // $B2EE
    .byte $41, $00, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00   // $B2FE
    .byte $00, $04, $00, $41, $00, $01, $00, $0F, $00, $09, $00, $00, $01, $04, $02, $00   // $B30E
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $04, $00, $00, $00, $41   // $B31E
    .byte $00, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00   // $B32E
    .byte $04, $00, $41, $00, $01, $00, $0F, $00, $08, $00, $00, $01, $00, $04, $00, $00   // $B33E
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $81, $00   // $B34E
    .byte $02, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00   // $B35E
    .byte $00, $11, $00, $01, $00, $00, $00, $09, $00, $00, $01, $05, $02, $00, $00, $00   // $B36E
    .byte $00, $00, $00, $00, $00, $00, $FF, $00, $00, $04, $00, $00, $00, $41, $00, $02   // $B37E
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $04, $00   // $B38E
    .byte $41, $00, $01, $00, $0F, $00, $09, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B39E
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00   // $B3AE
    .byte $24, $04, $04, $00, $70, $00, $70, $00, $00, $10, $10, $00, $80, $00, $10, $41   // $B3BE
    .byte $00, $00, $00, $0F, $00, $AB, $CC, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B3CE
    .byte $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B3DE
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $00, $00, $20   // $B3EE
// sequence / pattern pointer tables
    .byte $41, $40, $00, $00, $B4, $B1, $B4, $B1, $B4, $B1, $6C, $B0, $6C, $B0, $6C, $B0   // $B3FC
    .byte $6C, $B0, $AA, $B0, $AA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0   // $B40C
    .byte $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0   // $B41C
    .byte $CA, $B0, $30, $B1, $30, $B1, $30, $B1, $30, $B1, $CA, $B0, $CA, $B0, $30, $B1   // $B42C
    .byte $30, $B1, $30, $B1, $30, $B1, $30, $B1, $30, $B1, $30, $B1, $30, $B1, $00, $00   // $B43C
    .byte $00, $00, $B4, $B1, $B4, $B1, $B4, $B1, $7E, $B0, $7E, $B0, $7E, $B0, $7E, $B0   // $B44C
    .byte $94, $B0, $7E, $B0, $94, $B0, $7E, $B0, $B4, $B1, $B4, $B1, $F8, $B0, $F8, $B0   // $B45C
    .byte $F8, $B0, $F8, $B0, $00, $BD, $00, $BD, $F8, $B0, $F8, $B0, $B4, $B1, $B4, $B1   // $B46C
    .byte $F8, $B0, $F8, $B0, $5E, $B1, $96, $B1, $5E, $B1, $96, $B1, $00, $00, $00, $00   // $B47C
    .byte $00, $00, $00, $00, $1E, $B0, $2C, $B0, $2C, $B0, $4C, $B0, $2C, $B0, $2C, $B0   // $B48C
    .byte $2C, $B0, $4C, $B0, $2C, $B0, $2C, $B0, $2C, $B0, $4C, $B0, $2C, $B0, $4C, $B0   // $B49C
    .byte $2C, $B0, $4C, $B0, $2C, $B0, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1   // $B4AC
    .byte $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1   // $B4BC
    .byte $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1   // $B4CC
    .byte $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $00, $26, $B1   // $B4DC
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B4EC
    .byte $00, $00, $00, $00   // $B4FC
// NOTE FREQUENCY table - high bytes (freqtab_hi)
    .byte $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02   // $B500
    .byte $02, $02, $03, $03, $03, $03, $03, $04, $04, $04, $04, $05, $05, $05, $06, $06   // $B510
    .byte $06, $07, $07, $08, $08, $09, $09, $0A, $0A, $0B, $0C, $0C, $0D, $0E, $0F, $10   // $B520
    .byte $11, $12, $13, $14, $15, $16, $18, $19, $1B, $1C, $1E, $20, $22, $24, $26, $28   // $B530
    .byte $2B, $2D, $30, $33, $36, $39, $3D, $40, $44, $48, $4C, $51, $56, $5B, $60, $66   // $B540
    .byte $6C, $73, $7A, $81, $89, $91, $99, $A3, $AC, $B7, $C1, $CD, $D9, $E6, $F4   // $B550
// NOTE FREQUENCY table - low bytes (freqtab_lo)
    .byte $00, $00, $00, $00, $00, $6E, $84, $9B, $B3, $CD, $E9, $06, $25, $45, $68, $8C   // $B55F
    .byte $B3, $DC, $08, $36, $67, $9B, $D2, $0C, $49, $8B, $D0, $19, $67, $B9, $10, $6C   // $B56F
    .byte $CE, $35, $A3, $17, $93, $15, $9F, $3C, $CD, $72, $20, $D8, $9C, $6B, $46, $2F   // $B57F
    .byte $25, $2A, $3F, $64, $9A, $E3, $3F, $B1, $38, $D6, $8D, $5E, $4B, $55, $7E, $C8   // $B58F
    .byte $34, $C6, $7F, $61, $6F, $AC, $7E, $BC, $95, $A9, $FC, $A1, $69, $8C, $FE, $C2   // $B59F
    .byte $DF, $58, $34, $78, $2B, $53, $F7, $1F, $D2, $19, $FC, $85, $BD, $B0, $67, $00   // $B5AF
    .byte $01, $02, $03, $04, $05, $06, $07   // $B5BF
// misc small lookup tables (durations, vibrato deltas)
    .byte $08, $0A, $0C, $0E, $10, $12, $14, $16, $18, $20, $30, $40, $80, $C0, $FF, $FF   // $B5C6
// engine scratch + per-voice runtime state arrays
    .byte $02, $00, $2F, $02, $04, $00, $2C, $B2, $2C, $B2, $CE, $B1, $22, $00, $00, $00   // $B5D6
    .byte $00, $00, $AC, $AC, $00, $20, $20, $00, $09, $09, $07, $26, $26, $07, $9F, $9F   // $B5E6
    .byte $A3, $1E, $1E, $A3, $00, $00, $00, $FD, $FD, $00, $00, $00, $00, $60, $70, $00   // $B5F6
    .byte $00, $00, $00, $41, $41, $00, $00, $00, $00, $E6, $E7, $E8, $01, $01, $01, $01   // $B606
    .byte $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B616
    .byte $00, $04, $04, $00, $00, $00, $00, $04, $01, $00, $00, $00, $00, $00, $FF, $FF   // $B626
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   // $B636
    .byte $00, $00, $00, $00, $00, $65, $66, $00, $00, $00, $00, $FF, $FF, $FF, $00, $30   // $B646
    .byte $00, $00, $00, $00, $06, $B0, $06, $B0, $06, $B0, $00, $B4, $4E, $B4, $90, $B4   // $B656

// --- player_init: called once per subtune ---
player_init:
    nop
    nop
    nop
    nop
    nop
    nop
    ldx  #$00
LB66E:
    lda  $B65A,X   // seed per-voice stream ptrs ($F0-$F5) and loop ptrs ($F6-$FB)
    sta  $F0,X
    lda  $B660,X
    sta  $F6,X
    inx
    cpx  #$06
    bne  LB66E
    lda  #$01
    sta  v_eff
    sta  $B616
    sta  $B617
    lda  #$08   // SID master volume = 8
    sta  SID_VOL
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lda  #$FF
    sta  $FF   // set engine-initialised flag ($FF)
    rts
    .byte $EA, $EA   // $B6B4

// --- player_play: called once per frame (50Hz) ---
player_play:
    nop
    nop
    nop
    nop
    nop
    lda  $FF   // run only once initialised
    bne  LB6C2
    jmp  LBBFC
LB6C2:
    ldx  #$00
voice_loop:
    stx  cur_voice   // per-voice loop (X = voice 0..2)
    txa
    asl
    sta  cur_voice2
    tax
    lda  inst_ptr,X   // load this voice's current instrument pointer into $FC/$FD
    sta  $FC
    lda  $B5DD,X
    sta  $FD
    ldx  cur_voice
    dec  v_tempo,X   // tempo counter--; on wrap, advance step and fetch next note
    bne  LB6F6
    lda  #$06
    sta  v_tempo,X
    dec  v_eff,X
    php
    lda  v_eff,X
    and  #$1F
    sta  v_eff,X
    plp
    bne  LB6F6
    jsr  fetch_note   // counter wrapped -> fetch next note command
LB6F6:
    lda  $B618,X
    beq  LB701
    dec  $B618,X
    jmp  LB710
LB701:
    lda  $B61E,X
    beq  LB70D
    cmp  #$01
    beq  LB710
    dec  $B61E,X
LB70D:
    jsr  freq_sweep_1
LB710:
    jmp  LB77C

// --- freq_sweep_1: 16-bit vibrato/porta add/sub on osc1 ---
freq_sweep_1:
    lda  $B630,X
    bne  LB74A
    lda  $B624,X
    bne  LB735
LB71D:
    lda  v_freq_lo,X
    ldy  #$0B
    clc
    adc  ($FC),Y
    sta  v_freq_lo,X
    ldy  #$0A
    lda  #$00
    adc  v_freq_hi,X
    adc  ($FC),Y
    sta  v_freq_hi,X
    rts
LB735:
    dec  $B624,X
    bne  LB71D
    lda  $B630,X
    eor  #$FF
    sta  $B630,X
    ldy  #$08
    lda  ($FC),Y
    sta  $B624,X
    rts
LB74A:
    lda  $B62A,X
    bne  LB767
LB74F:
    lda  v_freq_lo,X
    ldy  #$0D
    sec
    sbc  ($FC),Y
    sta  v_freq_lo,X
    lda  v_freq_hi,X
    sbc  #$00
    ldy  #$0C
    sbc  ($FC),Y
    sta  v_freq_hi,X
    rts
LB767:
    dec  $B62A,X
    bne  LB74F
    lda  $B630,X
    eor  #$FF
    sta  $B630,X
    ldy  #$09
    lda  ($FC),Y
    sta  $B62A,X
    rts
LB77C:
    lda  $B636,X
    beq  LB787
    dec  $B636,X
    jmp  LB796
LB787:
    lda  $B63C,X
    beq  LB793
    cmp  #$01
    beq  LB796
    dec  $B63C,X
LB793:
    jsr  freq_sweep_2
LB796:
    jmp  LB802

// --- freq_sweep_2: same template, osc2 frequency ---
freq_sweep_2:
    lda  $B64E,X
    bne  LB7D0
    lda  $B642,X
    bne  LB7BB
LB7A3:
    lda  v_pw_lo,X
    ldy  #$13
    clc
    adc  ($FC),Y
    sta  v_pw_lo,X
    ldy  #$12
    lda  #$00
    adc  v_pw_hi,X
    adc  ($FC),Y
    sta  v_pw_hi,X
    rts
LB7BB:
    dec  $B642,X
    bne  LB7A3
    lda  $B64E,X
    eor  #$FF
    sta  $B64E,X
    ldy  #$10
    lda  ($FC),Y
    sta  $B642,X
    rts
LB7D0:
    lda  $B648,X
    bne  LB7ED
LB7D5:
    lda  v_pw_lo,X
    ldy  #$15
    sec
    sbc  ($FC),Y
    sta  v_pw_lo,X
    lda  v_pw_hi,X
    sbc  #$00
    ldy  #$14
    sbc  ($FC),Y
    sta  v_pw_hi,X
    rts
LB7ED:
    dec  $B648,X
    bne  LB7D5
    lda  $B64E,X
    eor  #$FF
    sta  $B64E,X
    ldy  #$11
    lda  ($FC),Y
    sta  $B648
    rts
LB802:
    lda  $B61B,X
    beq  LB812
    dec  $B61B,X
    bne  LB80F
    jsr  LBC48
LB80F:
    jmp  LB826
LB812:
    lda  $B621,X
    beq  LB823
    cmp  #$01
    beq  LB826
    dec  $B621,X
    bne  LB823
    jsr  LBCAA
LB823:
    jsr  pw_sweep_1
LB826:
    jmp  LB892

// --- pw_sweep_1: pulse-width sweep ---
pw_sweep_1:
    lda  $B633,X
    bne  LB860
    lda  $B627,X
    bne  LB84B
LB833:
    lda  v_freq2_lo,X
    ldy  #$1E
    clc
    adc  ($FC),Y
    sta  v_freq2_lo,X
    ldy  #$1D
    lda  #$00
    adc  v_freq2_hi,X
    adc  ($FC),Y
    sta  v_freq2_hi,X
    rts
LB84B:
    dec  $B627,X
    bne  LB833
    lda  $B633,X
    eor  #$FF
    sta  $B633,X
    ldy  #$1B
    lda  ($FC),Y
    sta  $B627,X
    rts
LB860:
    lda  $B62D,X
    bne  LB87D
LB865:
    lda  v_freq2_lo,X
    ldy  #$20
    sec
    sbc  ($FC),Y
    sta  v_freq2_lo,X
    lda  v_freq2_hi,X
    sbc  #$00
    ldy  #$1F
    sbc  ($FC),Y
    sta  v_freq2_hi,X
    rts
LB87D:
    dec  $B62D,X
    bne  LB865
    lda  $B633,X
    eor  #$FF
    sta  $B633,X
    ldy  #$1C
    lda  ($FC),Y
    sta  $B62D,X
    rts
LB892:
    lda  $B639,X
    beq  LB89D
    dec  $B639,X
    jmp  LB8AC
LB89D:
    lda  $B63F,X
    beq  LB8A9
    cmp  #$01
    beq  LB8AC
    dec  $B63F,X
LB8A9:
    jsr  pw_sweep_2
LB8AC:
    jmp  LB918

// --- pw_sweep_2: second pulse-width sweep ---
pw_sweep_2:
    lda  $B651,X
    bne  LB8E6
    lda  $B645,X
    bne  LB8D1
LB8B9:
    lda  v_pw2_lo,X
    ldy  #$26
    clc
    adc  ($FC),Y
    sta  v_pw2_lo,X
    ldy  #$25
    lda  #$00
    adc  v_pw2_hi,X
    adc  ($FC),Y
    sta  v_pw2_hi,X
    rts
LB8D1:
    dec  $B645,X
    bne  LB8B9
    lda  $B651,X
    eor  #$FF
    sta  $B651,X
    ldy  #$23
    lda  ($FC),Y
    sta  $B645,X
    rts
LB8E6:
    lda  $B64B,X
    bne  LB903
LB8EB:
    lda  v_pw2_lo,X
    ldy  #$28
    sec
    sbc  ($FC),Y
    sta  v_pw2_lo,X
    lda  v_pw2_hi,X
    sbc  #$00
    ldy  #$27
    sbc  ($FC),Y
    sta  v_pw2_hi,X
    rts
LB903:
    dec  $B64B,X
    bne  LB8EB
    lda  $B651,X
    eor  #$FF
    sta  $B651,X
    ldy  #$24
    lda  ($FC),Y
    sta  $B64B
    rts
LB918:
    dec  v_oscsel_ctr,X
    bne  LB92C
    lda  v_oscsel,X
    eor  #$FF
    sta  v_oscsel,X
    ldy  #$03
    lda  ($FC),Y
    sta  v_oscsel_ctr,X
LB92C:
    inx
    cpx  #$03
    beq  LB934
    jmp  voice_loop
LB934:
    jmp  sid_output

// --- fetch_note: read next 16-bit command from voice stream ---
fetch_note:
    ldx  cur_voice2
    jsr  read_stream
    sta  cmd_lo
    jsr  read_stream
    sta  cmd_hi
    jmp  decode_cmd
read_stream:
    lda  ($F0,X)   // read byte via ($F0,X); 16-bit ptr++
    inc  $F0,X
    bne  LB951
    inc  $F1,X
LB951:
    rts
decode_cmd:
    lda  cmd_lo   // $0000 word = END marker -> reload from loop ptr (pattern repeat)
    ora  cmd_hi
    bne  note_on
    ldx  cur_voice2
    jsr  read_loopptr
    sta  $F0,X
    jsr  read_loopptr
    sta  $F1,X
    jmp  fetch_note
read_loopptr:
    lda  ($F6,X)   // read byte via loop ptr ($F6,X); ptr++
    inc  $F6,X
    bne  LB972
    inc  $F7,X
LB972:
    rts

// --- note_on: decode instrument (hi bits) + note (low 6 bits) ---
note_on:
    ldx  cur_voice2
    lda  cmd_hi
    and  #$F8
    lsr
    lsr
    lsr
    ldx  cur_voice
    sta  v_eff,X
    ldx  cur_voice2
    lda  cmd_lo
    and  #$3F
    cmp  #$3F   // note $3F = tie/hold (no retrigger)
    bne  LB9A6
    ldx  cur_voice
    ldy  #$16
    lda  ($FC),Y
    and  #$FE
    sta  v_ctrl,X
    ldy  #$2A
    lda  ($FC),Y
    sta  v_ctrl2,X
    jmp  LBB5B
LB9A6:
    ldx  cur_voice
    ldy  #$17
    lda  ($FC),Y
    pha
    lda  cur_voice
    tay
    lda  #$00
    cpy  #$00
    beq  LB9BE
LB9B8:
    clc
    adc  #$07
    dey
    bne  LB9B8
LB9BE:
    tax
    pla
    sta  SID_CTRL,X
    lda  cmd_lo
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta  $FC
    lda  cmd_hi
    and  #$07
    asl
    asl
    ora  $FC
    ldy  #$CE
    sty  $FC
    ldy  #$B1
    sty  $FD
    ldy  #$00
    sty  $B5D8
    ldy  #$2F
    sty  $B5D7
    ldy  #$08
LB9EB:
    lsr
    bcc  LB9FF
    pha
    lda  $B5D7
    clc
    adc  $FC
    sta  $FC
    lda  $B5D8
    adc  $FD
    sta  $FD
    pla
LB9FF:
    asl  $B5D7
    rol  $B5D8
    dey
    bne  LB9EB
    ldx  cur_voice2
    lda  $FC
    sta  inst_ptr,X
    lda  $FD
    sta  $B5DD,X
    ldx  cur_voice
    ldy  #$2B
    lda  ($FC),Y
    sta  v_pw_hi,X
    ldy  #$2C
    lda  ($FC),Y
    sta  v_pw_lo,X
    ldy  #$2D
    lda  ($FC),Y
    sta  v_pw2_hi,X
    ldy  #$2E
    lda  ($FC),Y
    sta  v_pw2_lo,X
    ldy  #$05
    lda  ($FC),Y
    tax
    lda  #$00
    cpx  #$00
    beq  LBA45
LBA3F:
    clc
    adc  #$0C
    dex
    bne  LBA3F
LBA45:
    ldx  cur_voice
    sta  v_freq_lo,X
    lda  cmd_lo
    and  #$3F
    pha
    clc
    adc  v_freq_lo,X
    tay
    lda  freqtab_hi,Y
    sta  v_freq_hi,X
    lda  freqtab_lo,Y
    sta  v_freq_lo,X
    ldy  #$18
    lda  ($FC),Y
    tax
    lda  #$00
    cpx  #$00
    beq  LBA73
LBA6D:
    clc
    adc  #$0C
    dex
    bne  LBA6D
LBA73:
    ldx  cur_voice
    sta  v_freq2_lo,X
    ldy  #$04
    lda  ($FC),Y
    clc
    adc  v_freq2_lo,X
    sta  v_freq2_lo,X
    pla
    adc  v_freq2_lo,X
    tay
    lda  freqtab_hi,Y
    sta  v_freq2_hi,X
    lda  freqtab_lo,Y
    sta  v_freq2_lo,X
    ldx  cur_voice
    ldy  #$06
    lda  ($FC),Y
    sta  $B618,X
    ldy  #$19
    lda  ($FC),Y
    sta  $B61B,X
    ldy  #$07
    lda  ($FC),Y
    sta  $B61E,X
    ldy  #$1A
    lda  ($FC),Y
    sta  $B621,X
    ldy  #$08
    lda  ($FC),Y
    sta  $B624,X
    ldy  #$1B
    lda  ($FC),Y
    sta  $B627,X
    ldy  #$09
    lda  ($FC),Y
    sta  $B62A,X
    ldy  #$1C
    lda  ($FC),Y
    sta  $B62D,X
    ldy  #$0E
    lda  ($FC),Y
    sta  $B636,X
    ldy  #$21
    lda  ($FC),Y
    sta  $B639,X
    ldy  #$0F
    lda  ($FC),Y
    sta  $B63C,X
    ldy  #$22
    lda  ($FC),Y
    sta  $B63F,X
    ldy  #$10
    lda  ($FC),Y
    sta  $B642,X
    ldy  #$23
    lda  ($FC),Y
    sta  $B645,X
    ldy  #$11
    lda  ($FC),Y
    sta  $B648,X
    sta  $B657,X
    ldy  #$24
    lda  ($FC),Y
    sta  $B64B,X
    ldy  #$02
    lda  #$00
    stx  $B5D6
    cpx  #$00
    beq  LBB1C
LBB16:
    clc
    adc  ($FC),Y
    dex
    bne  LBB16
LBB1C:
    ldx  $B5D6
    sta  v_finetune,X
    ldy  #$00
    lda  ($FC),Y
    sta  v_ad,X
    ldy  #$01
    lda  ($FC),Y
    sta  v_sr,X
    ldy  #$03
    lda  ($FC),Y
    sta  v_oscsel_ctr,X
    ldy  #$16
    lda  ($FC),Y
    sta  v_ctrl,X
    ldy  #$29
    lda  ($FC),Y
    sta  v_ctrl2,X
    lda  #$00
    sta  v_oscsel,X
    lda  #$FF
    sta  $B633,X
    sta  $B651,X
    lsr  $B62D,X
    lsr  $B64B,X
    jsr  LBC2D
LBB5B:
    rts

// --- sid_output: write all 3 voices to the SID ($D400 stride 7) ---
sid_output:
    lda  #$00
    tay
    tax
out_voice:
    lda  v_ad,X
    sta  SID_AD,Y
    lda  v_sr,X
    sta  SID_SR,Y
    lda  v_oscsel,X
    beq  LBB98
    lda  v_freq_lo,X
    clc
    adc  v_finetune,X
    sta  SID_FREQ_LO,Y
    lda  #$00
    adc  v_freq_hi,X
    sta  SID_FREQ_HI,Y
    lda  v_pw_hi,X
    sta  SID_PW_HI,Y
    lda  v_pw_lo,X
    sta  SID_PW_LO,Y
    lda  v_ctrl,X
    sta  SID_CTRL,Y
    jmp  next_voice
LBB98:
    lda  v_freq2_lo,X
    clc
    adc  v_finetune,X
    sta  SID_FREQ_LO,Y
    lda  #$00
    adc  v_freq2_hi,X
    sta  SID_FREQ_HI,Y
    cpx  #$02   // voice 3 also drives filter/volume
    bne  LBBBF
    lda  $B657,X
    and  #$01
    bne  LBC02
    lda  #$F0
    sta  SID_RESON
    lda  #$08
    sta  SID_VOL
LBBBF:
    lda  v_pw2_hi,X
    sta  SID_PW_HI,Y
    lda  v_pw2_lo,X
    sta  SID_PW_LO,Y
    lda  v_ctrl2,X
    sta  SID_CTRL,Y
next_voice:
    inx   // advance to next SID voice register window
    tya
    clc
    adc  #$07
    tay
    cpy  #$15
    bne  out_voice
    lda  $FA
    cmp  #$EE
    bne  LBBFC
    lda  #$01
    sta  v_eff
    sta  $B616
    sta  $B617
    sta  v_tempo
    lda  #$02
    sta  $B613
    lda  #$03
    sta  $B614
    jsr  player_init
LBBFC:
    rts
    .byte $EA, $EA, $EA, $EA, $EA   // $BBFD
LBC02:
    lda  #$F4
    sta  SID_RESON
    lda  #$18
    sta  SID_VOL
    lda  v_pw_lo,X
    sta  SID_FCUT_LO
    lda  v_pw_hi,X
    sta  SID_FCUT_HI
    jmp  LBBBF
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $D7, $91, $00, $FF, $FF, $00, $FF   // $BC1B
    .byte $FF, $00   // $BC2B
LBC2D:
    txa
    pha
    ldx  cur_voice
    lda  $B648,X
    and  #$02
    beq  LBC45
    ldx  cur_voice2
    jsr  read_stream
    ldx  cur_voice
    sta  $B61B,X
LBC45:
    pla
    tax
    rts
LBC48:
    txa
    pha
    ldx  cur_voice
    lda  $B648,X
    and  #$02
    beq  LBCA7
    ldy  #$1E
    lda  ($FC),Y
    sta  $BC1B,X
    ldy  #$1D
    lda  ($FC),Y
    sta  $BC1E,X
    lda  $B627,X
    sta  $BC21,X
    ldy  #$20
    lda  ($FC),Y
    sta  $BC24,X
    ldy  #$1F
    lda  ($FC),Y
    sta  $BC27,X
    ldy  $B62D,X
    sta  $BC2A,X
    ldx  cur_voice2
    jsr  read_stream
    pha
    jsr  read_stream
    pha
    jsr  read_stream
    ldx  cur_voice
    ldy  #$20
    sta  ($FC),Y
    pla
    ldy  #$1F
    sta  ($FC),Y
    pla
    sta  $B62D,X
    lda  #$00
    sta  $B627,X
    ldy  #$1E
    sta  ($FC),Y
    ldy  #$1D
    sta  ($FC),Y
LBCA7:
    pla
    tax
    rts
LBCAA:
    txa
    pha
    lda  $B648,X
    and  #$02
    beq  LBCE5
    lda  $BC1B,X
    ldy  #$1E
    sta  ($FC),Y
    lda  $BC1E,X
    ldy  #$1D
    sta  ($FC),Y
    lda  $BC24,X
    ldy  #$20
    sta  ($FC),Y
    lda  $BC27,X
    ldy  #$1F
    sta  ($FC),Y
    lda  $BC21,X
    sta  $B627,X
    lda  $BC2A,X
    sta  $B62D,X
    lda  #$FF
    sta  $B621,X
    lda  #$00
    sta  $B61B,X
LBCE5:
    pla
    tax
    rts

// engine region must be exactly $B000..$BCE8
.errorif (* != $BCE8), "engine.asm size drift, expected $BCE8"
