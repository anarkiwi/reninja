; engine.asm  -  The Last Ninja / WEMUSIC player engine
; Resident at $B000 after the relocator copies it there.
; Assembled inside  !pseudopc $B000 { !source "engine.asm" }  by lastninja.asm,
; so labels carry their run-time ($Bxxx) addresses but bytes land at file $2063.
; Code is symbolic; embedded tables are emitted as !byte (byte-exact).

; ---- equates (names resolve to their exact addresses; bytes unchanged) ----
SID_FREQ_LO    = $D400
SID_FREQ_HI    = $D401
SID_PW_LO      = $D402
SID_PW_HI      = $D403
SID_CTRL       = $D404
SID_AD         = $D405
SID_SR         = $D406
SID_FCUT_LO    = $D415
SID_FCUT_HI    = $D416
SID_RESON      = $D417
SID_VOL        = $D418
freqtab_hi     = $B500
freqtab_lo     = $B55F
v_freq_hi      = $B5EE
v_freq_lo      = $B5F4
v_freq2_hi     = $B5F1
v_freq2_lo     = $B5F7
v_pw_hi        = $B5FA
v_pw_lo        = $B600
v_pw2_hi       = $B5FD
v_pw2_lo       = $B603
v_ctrl         = $B606
v_ctrl2        = $B609
v_oscsel       = $B60C
v_oscsel_ctr   = $B60F
v_tempo        = $B612
v_eff          = $B615
v_finetune     = $B654
v_ad           = $B5E8
v_sr           = $B5EB
cur_voice      = $B5D9
cur_voice2     = $B5DA
cmd_lo         = $B5E2
cmd_hi         = $B5E3
inst_ptr       = $B5DC

engine_init_vec:
    JMP  player_init
engine_play_vec:
    JMP  player_play
; per-voice arpeggio / wavetable streams
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B006
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $22, $00, $22, $00, $22, $00, $22, $E0   ; $B016
    !byte $32, $11, $2D, $11, $00, $00, $15, $11, $15, $11, $13, $11, $15, $11, $6B, $11   ; $B026
    !byte $64, $11, $13, $11, $15, $11, $18, $11, $15, $11, $18, $21, $1A, $11, $18, $11   ; $B036
    !byte $15, $11, $13, $11, $00, $00, $13, $11, $13, $11, $11, $11, $13, $11, $6D, $11   ; $B046
    !byte $68, $11, $11, $11, $13, $11, $18, $11, $15, $11, $18, $21, $1A, $11, $18, $11   ; $B056
    !byte $15, $11, $13, $11, $00, $00, $61, $20, $5F, $10, $61, $20, $5F, $10, $EB, $20   ; $B066
    !byte $07, $15, $FF, $B3, $AD, $80, $00, $00, $A1, $21, $18, $12, $DF, $11, $A1, $21   ; $B076
    !byte $18, $22, $A1, $21, $18, $12, $DF, $11, $A1, $21, $18, $22, $00, $00, $DF, $21   ; $B086
    !byte $16, $12, $DD, $11, $DF, $21, $16, $22, $DF, $21, $16, $12, $DD, $11, $DF, $21   ; $B096
    !byte $16, $22, $00, $00, $6B, $20, $66, $20, $A4, $20, $63, $10, $A4, $20, $66, $10   ; $B0A6
    !byte $63, $20, $61, $10, $5F, $10, $5C, $10, $5F, $10, $DF, $40, $07, $23, $FF, $E8   ; $B0B6
    !byte $61, $C0, $00, $00, $A8, $12, $A6, $12, $A8, $22, $A6, $22, $9F, $22, $A1, $22   ; $B0C6
    !byte $A6, $22, $A3, $12, $A1, $12, $9F, $12, $9C, $12, $A1, $12, $9F, $12, $A1, $22   ; $B0D6
    !byte $A3, $22, $9C, $22, $A1, $22, $A6, $22, $A3, $12, $A1, $12, $9F, $12, $9C, $12   ; $B0E6
    !byte $00, $00, $AD, $12, $AB, $12, $AD, $22, $AB, $22, $A4, $22, $A6, $22, $AB, $22   ; $B0F6
    !byte $A8, $12, $A6, $12, $A4, $12, $A1, $12, $A6, $12, $A4, $12, $A6, $22, $A8, $22   ; $B106
    !byte $A1, $22, $A6, $22, $AB, $22, $A8, $12, $A6, $12, $A4, $12, $A1, $12, $00, $00   ; $B116
    !byte $D5, $E2, $D3, $22, $D1, $E2, $D3, $22, $00, $00, $74, $12, $72, $12, $74, $22   ; $B126
    !byte $72, $22, $6B, $22, $6D, $22, $72, $22, $6F, $12, $6D, $12, $6B, $12, $68, $12   ; $B136
    !byte $6D, $12, $6B, $12, $6D, $22, $6F, $22, $68, $22, $6D, $22, $72, $22, $6F, $12   ; $B146
    !byte $6D, $12, $6B, $12, $68, $12, $00, $00, $61, $C0, $E6, $40, $14, $11, $00, $CD   ; $B156
    !byte $DF, $A0, $24, $18, $FF, $DE, $A8, $10, $AB, $20, $66, $10, $E8, $E0, $14, $18   ; $B166
    !byte $00, $33, $DF, $40, $0C, $19, $FE, $ED, $EB, $E0, $24, $18, $00, $3C, $5F, $20   ; $B176
    !byte $A1, $20, $9F, $10, $A1, $20, $5F, $10, $DF, $A0, $04, $0D, $FD, $DB, $00, $00   ; $B186
    !byte $72, $20, $70, $10, $6B, $20, $69, $10, $E4, $80, $0C, $14, $00, $98, $9F, $20   ; $B196
    !byte $DF, $00, $14, $48, $FF, $F4, $DF, $00, $14, $48, $FF, $F4, $00, $00, $61, $C0   ; $B1A6
    !byte $DF, $40, $18, $14, $FF, $D7, $61, $C0, $DF, $40, $10, $14, $FF, $91, $A6, $C0   ; $B1B6
    !byte $DF, $40, $08, $10, $FF, $CD, $61, $00   ; $B1C6
; instrument data records (base for ($FC),Y reads)
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B1CE
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B1DE
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $AC   ; $B1EE
    !byte $0B, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B1FE
    !byte $00, $00, $00, $00, $00, $00, $00, $02, $20, $00, $04, $04, $00, $60, $00, $60   ; $B20E
    !byte $00, $00, $00, $08, $00, $10, $00, $10, $41, $40, $00, $00, $01, $00, $AC, $20   ; $B21E
    !byte $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B22E
    !byte $00, $00, $00, $00, $00, $00, $02, $00, $00, $04, $04, $00, $60, $00, $60, $00   ; $B23E
    !byte $00, $00, $FF, $00, $00, $00, $10, $41, $40, $00, $00, $00, $00, $AC, $2B, $30   ; $B24E
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00   ; $B25E
    !byte $00, $00, $00, $00, $00, $02, $00, $00, $00, $00, $00, $00, $FF, $91, $08, $00   ; $B26E
    !byte $00, $08, $00, $10, $00, $10, $41, $40, $00, $00, $09, $00, $09, $00, $00, $00   ; $B27E
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $01, $04, $00   ; $B28E
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08   ; $B29E
    !byte $08, $00, $40, $00, $40, $41, $00, $00, $00, $28, $00, $09, $00, $00, $01, $01   ; $B2AE
    !byte $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B2BE
    !byte $00, $17, $00, $02, $00, $00, $04, $03, $01, $00, $01, $00, $00, $00, $00, $00   ; $B2CE
    !byte $00, $00, $00, $00, $15, $00, $00, $00, $02, $00, $09, $00, $00, $01, $03, $02   ; $B2DE
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $04, $00, $00, $00   ; $B2EE
    !byte $41, $00, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00   ; $B2FE
    !byte $00, $04, $00, $41, $00, $01, $00, $0F, $00, $09, $00, $00, $01, $04, $02, $00   ; $B30E
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $04, $00, $00, $00, $41   ; $B31E
    !byte $00, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00   ; $B32E
    !byte $04, $00, $41, $00, $01, $00, $0F, $00, $08, $00, $00, $01, $00, $04, $00, $00   ; $B33E
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $81, $00   ; $B34E
    !byte $02, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00   ; $B35E
    !byte $00, $11, $00, $01, $00, $00, $00, $09, $00, $00, $01, $05, $02, $00, $00, $00   ; $B36E
    !byte $00, $00, $00, $00, $00, $00, $FF, $00, $00, $04, $00, $00, $00, $41, $00, $02   ; $B37E
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $04, $00   ; $B38E
    !byte $41, $00, $01, $00, $0F, $00, $09, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B39E
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00   ; $B3AE
    !byte $24, $04, $04, $00, $70, $00, $70, $00, $00, $10, $10, $00, $80, $00, $10, $41   ; $B3BE
    !byte $00, $00, $00, $0F, $00, $AB, $CC, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B3CE
    !byte $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B3DE
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $00, $00, $20   ; $B3EE
; sequence / pattern pointer tables
    !byte $41, $40, $00, $00, $B4, $B1, $B4, $B1, $B4, $B1, $6C, $B0, $6C, $B0, $6C, $B0   ; $B3FC
    !byte $6C, $B0, $AA, $B0, $AA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0   ; $B40C
    !byte $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0, $CA, $B0   ; $B41C
    !byte $CA, $B0, $30, $B1, $30, $B1, $30, $B1, $30, $B1, $CA, $B0, $CA, $B0, $30, $B1   ; $B42C
    !byte $30, $B1, $30, $B1, $30, $B1, $30, $B1, $30, $B1, $30, $B1, $30, $B1, $00, $00   ; $B43C
    !byte $00, $00, $B4, $B1, $B4, $B1, $B4, $B1, $7E, $B0, $7E, $B0, $7E, $B0, $7E, $B0   ; $B44C
    !byte $94, $B0, $7E, $B0, $94, $B0, $7E, $B0, $B4, $B1, $B4, $B1, $F8, $B0, $F8, $B0   ; $B45C
    !byte $F8, $B0, $F8, $B0, $00, $BD, $00, $BD, $F8, $B0, $F8, $B0, $B4, $B1, $B4, $B1   ; $B46C
    !byte $F8, $B0, $F8, $B0, $5E, $B1, $96, $B1, $5E, $B1, $96, $B1, $00, $00, $00, $00   ; $B47C
    !byte $00, $00, $00, $00, $1E, $B0, $2C, $B0, $2C, $B0, $4C, $B0, $2C, $B0, $2C, $B0   ; $B48C
    !byte $2C, $B0, $4C, $B0, $2C, $B0, $2C, $B0, $2C, $B0, $4C, $B0, $2C, $B0, $4C, $B0   ; $B49C
    !byte $2C, $B0, $4C, $B0, $2C, $B0, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1   ; $B4AC
    !byte $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1   ; $B4BC
    !byte $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1   ; $B4CC
    !byte $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $B1, $26, $00, $26, $B1   ; $B4DC
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B4EC
    !byte $00, $00, $00, $00   ; $B4FC
; NOTE FREQUENCY table - high bytes (freqtab_hi)
    !byte $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02   ; $B500
    !byte $02, $02, $03, $03, $03, $03, $03, $04, $04, $04, $04, $05, $05, $05, $06, $06   ; $B510
    !byte $06, $07, $07, $08, $08, $09, $09, $0A, $0A, $0B, $0C, $0C, $0D, $0E, $0F, $10   ; $B520
    !byte $11, $12, $13, $14, $15, $16, $18, $19, $1B, $1C, $1E, $20, $22, $24, $26, $28   ; $B530
    !byte $2B, $2D, $30, $33, $36, $39, $3D, $40, $44, $48, $4C, $51, $56, $5B, $60, $66   ; $B540
    !byte $6C, $73, $7A, $81, $89, $91, $99, $A3, $AC, $B7, $C1, $CD, $D9, $E6, $F4   ; $B550
; NOTE FREQUENCY table - low bytes (freqtab_lo)
    !byte $00, $00, $00, $00, $00, $6E, $84, $9B, $B3, $CD, $E9, $06, $25, $45, $68, $8C   ; $B55F
    !byte $B3, $DC, $08, $36, $67, $9B, $D2, $0C, $49, $8B, $D0, $19, $67, $B9, $10, $6C   ; $B56F
    !byte $CE, $35, $A3, $17, $93, $15, $9F, $3C, $CD, $72, $20, $D8, $9C, $6B, $46, $2F   ; $B57F
    !byte $25, $2A, $3F, $64, $9A, $E3, $3F, $B1, $38, $D6, $8D, $5E, $4B, $55, $7E, $C8   ; $B58F
    !byte $34, $C6, $7F, $61, $6F, $AC, $7E, $BC, $95, $A9, $FC, $A1, $69, $8C, $FE, $C2   ; $B59F
    !byte $DF, $58, $34, $78, $2B, $53, $F7, $1F, $D2, $19, $FC, $85, $BD, $B0, $67, $00   ; $B5AF
    !byte $01, $02, $03, $04, $05, $06, $07   ; $B5BF
; misc small lookup tables (durations, vibrato deltas)
    !byte $08, $0A, $0C, $0E, $10, $12, $14, $16, $18, $20, $30, $40, $80, $C0, $FF, $FF   ; $B5C6
; engine scratch + per-voice runtime state arrays
    !byte $02, $00, $2F, $02, $04, $00, $2C, $B2, $2C, $B2, $CE, $B1, $22, $00, $00, $00   ; $B5D6
    !byte $00, $00, $AC, $AC, $00, $20, $20, $00, $09, $09, $07, $26, $26, $07, $9F, $9F   ; $B5E6
    !byte $A3, $1E, $1E, $A3, $00, $00, $00, $FD, $FD, $00, $00, $00, $00, $60, $70, $00   ; $B5F6
    !byte $00, $00, $00, $41, $41, $00, $00, $00, $00, $E6, $E7, $E8, $01, $01, $01, $01   ; $B606
    !byte $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B616
    !byte $00, $04, $04, $00, $00, $00, $00, $04, $01, $00, $00, $00, $00, $00, $FF, $FF   ; $B626
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00   ; $B636
    !byte $00, $00, $00, $00, $00, $65, $66, $00, $00, $00, $00, $FF, $FF, $FF, $00, $30   ; $B646
    !byte $00, $00, $00, $00, $06, $B0, $06, $B0, $06, $B0, $00, $B4, $4E, $B4, $90, $B4   ; $B656

; --- player_init: called once per subtune ---
player_init:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    LDX  #$00
LB66E:
    LDA  $B65A,X   ; seed per-voice stream ptrs ($F0-$F5) and loop ptrs ($F6-$FB)
    STA  $F0,X
    LDA  $B660,X
    STA  $F6,X
    INX
    CPX  #$06
    BNE  LB66E
    LDA  #$01
    STA  v_eff
    STA  $B616
    STA  $B617
    LDA  #$08   ; SID master volume = 8
    STA  SID_VOL
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    LDA  #$FF
    STA  $FF   ; set engine-initialised flag ($FF)
    RTS
    !byte $EA, $EA   ; $B6B4

; --- player_play: called once per frame (50Hz) ---
player_play:
    NOP
    NOP
    NOP
    NOP
    NOP
    LDA  $FF   ; run only once initialised
    BNE  LB6C2
    JMP  LBBFC
LB6C2:
    LDX  #$00
voice_loop:
    STX  cur_voice   ; per-voice loop (X = voice 0..2)
    TXA
    ASL
    STA  cur_voice2
    TAX
    LDA  inst_ptr,X   ; load this voice's current instrument pointer into $FC/$FD
    STA  $FC
    LDA  $B5DD,X
    STA  $FD
    LDX  cur_voice
    DEC  v_tempo,X   ; tempo counter--; on wrap, advance step and fetch next note
    BNE  LB6F6
    LDA  #$06
    STA  v_tempo,X
    DEC  v_eff,X
    PHP
    LDA  v_eff,X
    AND  #$1F
    STA  v_eff,X
    PLP
    BNE  LB6F6
    JSR  fetch_note   ; counter wrapped -> fetch next note command
LB6F6:
    LDA  $B618,X
    BEQ  LB701
    DEC  $B618,X
    JMP  LB710
LB701:
    LDA  $B61E,X
    BEQ  LB70D
    CMP  #$01
    BEQ  LB710
    DEC  $B61E,X
LB70D:
    JSR  freq_sweep_1
LB710:
    JMP  LB77C

; --- freq_sweep_1: 16-bit vibrato/porta add/sub on osc1 ---
freq_sweep_1:
    LDA  $B630,X
    BNE  LB74A
    LDA  $B624,X
    BNE  LB735
LB71D:
    LDA  v_freq_lo,X
    LDY  #$0B
    CLC
    ADC  ($FC),Y
    STA  v_freq_lo,X
    LDY  #$0A
    LDA  #$00
    ADC  v_freq_hi,X
    ADC  ($FC),Y
    STA  v_freq_hi,X
    RTS
LB735:
    DEC  $B624,X
    BNE  LB71D
    LDA  $B630,X
    EOR  #$FF
    STA  $B630,X
    LDY  #$08
    LDA  ($FC),Y
    STA  $B624,X
    RTS
LB74A:
    LDA  $B62A,X
    BNE  LB767
LB74F:
    LDA  v_freq_lo,X
    LDY  #$0D
    SEC
    SBC  ($FC),Y
    STA  v_freq_lo,X
    LDA  v_freq_hi,X
    SBC  #$00
    LDY  #$0C
    SBC  ($FC),Y
    STA  v_freq_hi,X
    RTS
LB767:
    DEC  $B62A,X
    BNE  LB74F
    LDA  $B630,X
    EOR  #$FF
    STA  $B630,X
    LDY  #$09
    LDA  ($FC),Y
    STA  $B62A,X
    RTS
LB77C:
    LDA  $B636,X
    BEQ  LB787
    DEC  $B636,X
    JMP  LB796
LB787:
    LDA  $B63C,X
    BEQ  LB793
    CMP  #$01
    BEQ  LB796
    DEC  $B63C,X
LB793:
    JSR  freq_sweep_2
LB796:
    JMP  LB802

; --- freq_sweep_2: same template, osc2 frequency ---
freq_sweep_2:
    LDA  $B64E,X
    BNE  LB7D0
    LDA  $B642,X
    BNE  LB7BB
LB7A3:
    LDA  v_pw_lo,X
    LDY  #$13
    CLC
    ADC  ($FC),Y
    STA  v_pw_lo,X
    LDY  #$12
    LDA  #$00
    ADC  v_pw_hi,X
    ADC  ($FC),Y
    STA  v_pw_hi,X
    RTS
LB7BB:
    DEC  $B642,X
    BNE  LB7A3
    LDA  $B64E,X
    EOR  #$FF
    STA  $B64E,X
    LDY  #$10
    LDA  ($FC),Y
    STA  $B642,X
    RTS
LB7D0:
    LDA  $B648,X
    BNE  LB7ED
LB7D5:
    LDA  v_pw_lo,X
    LDY  #$15
    SEC
    SBC  ($FC),Y
    STA  v_pw_lo,X
    LDA  v_pw_hi,X
    SBC  #$00
    LDY  #$14
    SBC  ($FC),Y
    STA  v_pw_hi,X
    RTS
LB7ED:
    DEC  $B648,X
    BNE  LB7D5
    LDA  $B64E,X
    EOR  #$FF
    STA  $B64E,X
    LDY  #$11
    LDA  ($FC),Y
    STA  $B648
    RTS
LB802:
    LDA  $B61B,X
    BEQ  LB812
    DEC  $B61B,X
    BNE  LB80F
    JSR  LBC48
LB80F:
    JMP  LB826
LB812:
    LDA  $B621,X
    BEQ  LB823
    CMP  #$01
    BEQ  LB826
    DEC  $B621,X
    BNE  LB823
    JSR  LBCAA
LB823:
    JSR  pw_sweep_1
LB826:
    JMP  LB892

; --- pw_sweep_1: pulse-width sweep ---
pw_sweep_1:
    LDA  $B633,X
    BNE  LB860
    LDA  $B627,X
    BNE  LB84B
LB833:
    LDA  v_freq2_lo,X
    LDY  #$1E
    CLC
    ADC  ($FC),Y
    STA  v_freq2_lo,X
    LDY  #$1D
    LDA  #$00
    ADC  v_freq2_hi,X
    ADC  ($FC),Y
    STA  v_freq2_hi,X
    RTS
LB84B:
    DEC  $B627,X
    BNE  LB833
    LDA  $B633,X
    EOR  #$FF
    STA  $B633,X
    LDY  #$1B
    LDA  ($FC),Y
    STA  $B627,X
    RTS
LB860:
    LDA  $B62D,X
    BNE  LB87D
LB865:
    LDA  v_freq2_lo,X
    LDY  #$20
    SEC
    SBC  ($FC),Y
    STA  v_freq2_lo,X
    LDA  v_freq2_hi,X
    SBC  #$00
    LDY  #$1F
    SBC  ($FC),Y
    STA  v_freq2_hi,X
    RTS
LB87D:
    DEC  $B62D,X
    BNE  LB865
    LDA  $B633,X
    EOR  #$FF
    STA  $B633,X
    LDY  #$1C
    LDA  ($FC),Y
    STA  $B62D,X
    RTS
LB892:
    LDA  $B639,X
    BEQ  LB89D
    DEC  $B639,X
    JMP  LB8AC
LB89D:
    LDA  $B63F,X
    BEQ  LB8A9
    CMP  #$01
    BEQ  LB8AC
    DEC  $B63F,X
LB8A9:
    JSR  pw_sweep_2
LB8AC:
    JMP  LB918

; --- pw_sweep_2: second pulse-width sweep ---
pw_sweep_2:
    LDA  $B651,X
    BNE  LB8E6
    LDA  $B645,X
    BNE  LB8D1
LB8B9:
    LDA  v_pw2_lo,X
    LDY  #$26
    CLC
    ADC  ($FC),Y
    STA  v_pw2_lo,X
    LDY  #$25
    LDA  #$00
    ADC  v_pw2_hi,X
    ADC  ($FC),Y
    STA  v_pw2_hi,X
    RTS
LB8D1:
    DEC  $B645,X
    BNE  LB8B9
    LDA  $B651,X
    EOR  #$FF
    STA  $B651,X
    LDY  #$23
    LDA  ($FC),Y
    STA  $B645,X
    RTS
LB8E6:
    LDA  $B64B,X
    BNE  LB903
LB8EB:
    LDA  v_pw2_lo,X
    LDY  #$28
    SEC
    SBC  ($FC),Y
    STA  v_pw2_lo,X
    LDA  v_pw2_hi,X
    SBC  #$00
    LDY  #$27
    SBC  ($FC),Y
    STA  v_pw2_hi,X
    RTS
LB903:
    DEC  $B64B,X
    BNE  LB8EB
    LDA  $B651,X
    EOR  #$FF
    STA  $B651,X
    LDY  #$24
    LDA  ($FC),Y
    STA  $B64B
    RTS
LB918:
    DEC  v_oscsel_ctr,X
    BNE  LB92C
    LDA  v_oscsel,X
    EOR  #$FF
    STA  v_oscsel,X
    LDY  #$03
    LDA  ($FC),Y
    STA  v_oscsel_ctr,X
LB92C:
    INX
    CPX  #$03
    BEQ  LB934
    JMP  voice_loop
LB934:
    JMP  sid_output

; --- fetch_note: read next 16-bit command from voice stream ---
fetch_note:
    LDX  cur_voice2
    JSR  read_stream
    STA  cmd_lo
    JSR  read_stream
    STA  cmd_hi
    JMP  decode_cmd
read_stream:
    LDA  ($F0,X)   ; read byte via ($F0,X); 16-bit ptr++
    INC  $F0,X
    BNE  LB951
    INC  $F1,X
LB951:
    RTS
decode_cmd:
    LDA  cmd_lo   ; $0000 word = END marker -> reload from loop ptr (pattern repeat)
    ORA  cmd_hi
    BNE  note_on
    LDX  cur_voice2
    JSR  read_loopptr
    STA  $F0,X
    JSR  read_loopptr
    STA  $F1,X
    JMP  fetch_note
read_loopptr:
    LDA  ($F6,X)   ; read byte via loop ptr ($F6,X); ptr++
    INC  $F6,X
    BNE  LB972
    INC  $F7,X
LB972:
    RTS

; --- note_on: decode instrument (hi bits) + note (low 6 bits) ---
note_on:
    LDX  cur_voice2
    LDA  cmd_hi
    AND  #$F8
    LSR
    LSR
    LSR
    LDX  cur_voice
    STA  v_eff,X
    LDX  cur_voice2
    LDA  cmd_lo
    AND  #$3F
    CMP  #$3F   ; note $3F = tie/hold (no retrigger)
    BNE  LB9A6
    LDX  cur_voice
    LDY  #$16
    LDA  ($FC),Y
    AND  #$FE
    STA  v_ctrl,X
    LDY  #$2A
    LDA  ($FC),Y
    STA  v_ctrl2,X
    JMP  LBB5B
LB9A6:
    LDX  cur_voice
    LDY  #$17
    LDA  ($FC),Y
    PHA
    LDA  cur_voice
    TAY
    LDA  #$00
    CPY  #$00
    BEQ  LB9BE
LB9B8:
    CLC
    ADC  #$07
    DEY
    BNE  LB9B8
LB9BE:
    TAX
    PLA
    STA  SID_CTRL,X
    LDA  cmd_lo
    LSR
    LSR
    LSR
    LSR
    LSR
    LSR
    STA  $FC
    LDA  cmd_hi
    AND  #$07
    ASL
    ASL
    ORA  $FC
    LDY  #$CE
    STY  $FC
    LDY  #$B1
    STY  $FD
    LDY  #$00
    STY  $B5D8
    LDY  #$2F
    STY  $B5D7
    LDY  #$08
LB9EB:
    LSR
    BCC  LB9FF
    PHA
    LDA  $B5D7
    CLC
    ADC  $FC
    STA  $FC
    LDA  $B5D8
    ADC  $FD
    STA  $FD
    PLA
LB9FF:
    ASL  $B5D7
    ROL  $B5D8
    DEY
    BNE  LB9EB
    LDX  cur_voice2
    LDA  $FC
    STA  inst_ptr,X
    LDA  $FD
    STA  $B5DD,X
    LDX  cur_voice
    LDY  #$2B
    LDA  ($FC),Y
    STA  v_pw_hi,X
    LDY  #$2C
    LDA  ($FC),Y
    STA  v_pw_lo,X
    LDY  #$2D
    LDA  ($FC),Y
    STA  v_pw2_hi,X
    LDY  #$2E
    LDA  ($FC),Y
    STA  v_pw2_lo,X
    LDY  #$05
    LDA  ($FC),Y
    TAX
    LDA  #$00
    CPX  #$00
    BEQ  LBA45
LBA3F:
    CLC
    ADC  #$0C
    DEX
    BNE  LBA3F
LBA45:
    LDX  cur_voice
    STA  v_freq_lo,X
    LDA  cmd_lo
    AND  #$3F
    PHA
    CLC
    ADC  v_freq_lo,X
    TAY
    LDA  freqtab_hi,Y
    STA  v_freq_hi,X
    LDA  freqtab_lo,Y
    STA  v_freq_lo,X
    LDY  #$18
    LDA  ($FC),Y
    TAX
    LDA  #$00
    CPX  #$00
    BEQ  LBA73
LBA6D:
    CLC
    ADC  #$0C
    DEX
    BNE  LBA6D
LBA73:
    LDX  cur_voice
    STA  v_freq2_lo,X
    LDY  #$04
    LDA  ($FC),Y
    CLC
    ADC  v_freq2_lo,X
    STA  v_freq2_lo,X
    PLA
    ADC  v_freq2_lo,X
    TAY
    LDA  freqtab_hi,Y
    STA  v_freq2_hi,X
    LDA  freqtab_lo,Y
    STA  v_freq2_lo,X
    LDX  cur_voice
    LDY  #$06
    LDA  ($FC),Y
    STA  $B618,X
    LDY  #$19
    LDA  ($FC),Y
    STA  $B61B,X
    LDY  #$07
    LDA  ($FC),Y
    STA  $B61E,X
    LDY  #$1A
    LDA  ($FC),Y
    STA  $B621,X
    LDY  #$08
    LDA  ($FC),Y
    STA  $B624,X
    LDY  #$1B
    LDA  ($FC),Y
    STA  $B627,X
    LDY  #$09
    LDA  ($FC),Y
    STA  $B62A,X
    LDY  #$1C
    LDA  ($FC),Y
    STA  $B62D,X
    LDY  #$0E
    LDA  ($FC),Y
    STA  $B636,X
    LDY  #$21
    LDA  ($FC),Y
    STA  $B639,X
    LDY  #$0F
    LDA  ($FC),Y
    STA  $B63C,X
    LDY  #$22
    LDA  ($FC),Y
    STA  $B63F,X
    LDY  #$10
    LDA  ($FC),Y
    STA  $B642,X
    LDY  #$23
    LDA  ($FC),Y
    STA  $B645,X
    LDY  #$11
    LDA  ($FC),Y
    STA  $B648,X
    STA  $B657,X
    LDY  #$24
    LDA  ($FC),Y
    STA  $B64B,X
    LDY  #$02
    LDA  #$00
    STX  $B5D6
    CPX  #$00
    BEQ  LBB1C
LBB16:
    CLC
    ADC  ($FC),Y
    DEX
    BNE  LBB16
LBB1C:
    LDX  $B5D6
    STA  v_finetune,X
    LDY  #$00
    LDA  ($FC),Y
    STA  v_ad,X
    LDY  #$01
    LDA  ($FC),Y
    STA  v_sr,X
    LDY  #$03
    LDA  ($FC),Y
    STA  v_oscsel_ctr,X
    LDY  #$16
    LDA  ($FC),Y
    STA  v_ctrl,X
    LDY  #$29
    LDA  ($FC),Y
    STA  v_ctrl2,X
    LDA  #$00
    STA  v_oscsel,X
    LDA  #$FF
    STA  $B633,X
    STA  $B651,X
    LSR  $B62D,X
    LSR  $B64B,X
    JSR  LBC2D
LBB5B:
    RTS

; --- sid_output: write all 3 voices to the SID ($D400 stride 7) ---
sid_output:
    LDA  #$00
    TAY
    TAX
out_voice:
    LDA  v_ad,X
    STA  SID_AD,Y
    LDA  v_sr,X
    STA  SID_SR,Y
    LDA  v_oscsel,X
    BEQ  LBB98
    LDA  v_freq_lo,X
    CLC
    ADC  v_finetune,X
    STA  SID_FREQ_LO,Y
    LDA  #$00
    ADC  v_freq_hi,X
    STA  SID_FREQ_HI,Y
    LDA  v_pw_hi,X
    STA  SID_PW_HI,Y
    LDA  v_pw_lo,X
    STA  SID_PW_LO,Y
    LDA  v_ctrl,X
    STA  SID_CTRL,Y
    JMP  next_voice
LBB98:
    LDA  v_freq2_lo,X
    CLC
    ADC  v_finetune,X
    STA  SID_FREQ_LO,Y
    LDA  #$00
    ADC  v_freq2_hi,X
    STA  SID_FREQ_HI,Y
    CPX  #$02   ; voice 3 also drives filter/volume
    BNE  LBBBF
    LDA  $B657,X
    AND  #$01
    BNE  LBC02
    LDA  #$F0
    STA  SID_RESON
    LDA  #$08
    STA  SID_VOL
LBBBF:
    LDA  v_pw2_hi,X
    STA  SID_PW_HI,Y
    LDA  v_pw2_lo,X
    STA  SID_PW_LO,Y
    LDA  v_ctrl2,X
    STA  SID_CTRL,Y
next_voice:
    INX   ; advance to next SID voice register window
    TYA
    CLC
    ADC  #$07
    TAY
    CPY  #$15
    BNE  out_voice
    LDA  $FA
    CMP  #$EE
    BNE  LBBFC
    LDA  #$01
    STA  v_eff
    STA  $B616
    STA  $B617
    STA  v_tempo
    LDA  #$02
    STA  $B613
    LDA  #$03
    STA  $B614
    JSR  player_init
LBBFC:
    RTS
    !byte $EA, $EA, $EA, $EA, $EA   ; $BBFD
LBC02:
    LDA  #$F4
    STA  SID_RESON
    LDA  #$18
    STA  SID_VOL
    LDA  v_pw_lo,X
    STA  SID_FCUT_LO
    LDA  v_pw_hi,X
    STA  SID_FCUT_HI
    JMP  LBBBF
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $D7, $91, $00, $FF, $FF, $00, $FF   ; $BC1B
    !byte $FF, $00   ; $BC2B
LBC2D:
    TXA
    PHA
    LDX  cur_voice
    LDA  $B648,X
    AND  #$02
    BEQ  LBC45
    LDX  cur_voice2
    JSR  read_stream
    LDX  cur_voice
    STA  $B61B,X
LBC45:
    PLA
    TAX
    RTS
LBC48:
    TXA
    PHA
    LDX  cur_voice
    LDA  $B648,X
    AND  #$02
    BEQ  LBCA7
    LDY  #$1E
    LDA  ($FC),Y
    STA  $BC1B,X
    LDY  #$1D
    LDA  ($FC),Y
    STA  $BC1E,X
    LDA  $B627,X
    STA  $BC21,X
    LDY  #$20
    LDA  ($FC),Y
    STA  $BC24,X
    LDY  #$1F
    LDA  ($FC),Y
    STA  $BC27,X
    LDY  $B62D,X
    STA  $BC2A,X
    LDX  cur_voice2
    JSR  read_stream
    PHA
    JSR  read_stream
    PHA
    JSR  read_stream
    LDX  cur_voice
    LDY  #$20
    STA  ($FC),Y
    PLA
    LDY  #$1F
    STA  ($FC),Y
    PLA
    STA  $B62D,X
    LDA  #$00
    STA  $B627,X
    LDY  #$1E
    STA  ($FC),Y
    LDY  #$1D
    STA  ($FC),Y
LBCA7:
    PLA
    TAX
    RTS
LBCAA:
    TXA
    PHA
    LDA  $B648,X
    AND  #$02
    BEQ  LBCE5
    LDA  $BC1B,X
    LDY  #$1E
    STA  ($FC),Y
    LDA  $BC1E,X
    LDY  #$1D
    STA  ($FC),Y
    LDA  $BC24,X
    LDY  #$20
    STA  ($FC),Y
    LDA  $BC27,X
    LDY  #$1F
    STA  ($FC),Y
    LDA  $BC21,X
    STA  $B627,X
    LDA  $BC2A,X
    STA  $B62D,X
    LDA  #$FF
    STA  $B621,X
    LDA  #$00
    STA  $B61B,X
LBCE5:
    PLA
    TAX
    RTS

; engine region must be exactly $B000..$BCE8
!if * != $BCE8 { !error "engine.asm size drift: ", *, " != $BCE8" }
