#!/usr/bin/env python3
# Authoring tool: regenerate the byte-exact ACME source from a reference .sid.
# Writes src/engine.asm + src/musicdata.asm. (Emits text only; assembles nothing.)
#
# Usage:  python3 tools/regen.py [path/to/Last_Ninja.sid]
#         (defaults to build/Last_Ninja.sid; run tools/fetch_sid.py first)
import struct, os, sys
ROOT=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SID=sys.argv[1] if len(sys.argv)>1 else os.path.join(ROOT,"build","Last_Ninja.sid")
OUT=os.path.join(ROOT,"src")
os.makedirs(OUT, exist_ok=True)

# ---- opcode table (op -> (mnem, mode)) ----
T={}
def o(op,m,mode): T[op]=(m,mode)
o(0xA9,"LDA","imm");o(0xA5,"LDA","zp");o(0xB5,"LDA","zpx");o(0xAD,"LDA","abs");o(0xBD,"LDA","abx");o(0xB9,"LDA","aby");o(0xA1,"LDA","izx");o(0xB1,"LDA","izy")
o(0xA2,"LDX","imm");o(0xA6,"LDX","zp");o(0xB6,"LDX","zpy");o(0xAE,"LDX","abs");o(0xBE,"LDX","aby")
o(0xA0,"LDY","imm");o(0xA4,"LDY","zp");o(0xB4,"LDY","zpx");o(0xAC,"LDY","abs");o(0xBC,"LDY","abx")
o(0x85,"STA","zp");o(0x95,"STA","zpx");o(0x8D,"STA","abs");o(0x9D,"STA","abx");o(0x99,"STA","aby");o(0x81,"STA","izx");o(0x91,"STA","izy")
o(0x86,"STX","zp");o(0x96,"STX","zpy");o(0x8E,"STX","abs")
o(0x84,"STY","zp");o(0x94,"STY","zpx");o(0x8C,"STY","abs")
o(0xAA,"TAX","imp");o(0xA8,"TAY","imp");o(0xBA,"TSX","imp");o(0x8A,"TXA","imp");o(0x9A,"TXS","imp");o(0x98,"TYA","imp")
o(0x48,"PHA","imp");o(0x68,"PLA","imp");o(0x08,"PHP","imp");o(0x28,"PLP","imp")
o(0x29,"AND","imm");o(0x25,"AND","zp");o(0x35,"AND","zpx");o(0x2D,"AND","abs");o(0x3D,"AND","abx");o(0x39,"AND","aby");o(0x21,"AND","izx");o(0x31,"AND","izy")
o(0x09,"ORA","imm");o(0x05,"ORA","zp");o(0x15,"ORA","zpx");o(0x0D,"ORA","abs");o(0x1D,"ORA","abx");o(0x19,"ORA","aby");o(0x01,"ORA","izx");o(0x11,"ORA","izy")
o(0x49,"EOR","imm");o(0x45,"EOR","zp");o(0x55,"EOR","zpx");o(0x4D,"EOR","abs");o(0x5D,"EOR","abx");o(0x59,"EOR","aby");o(0x41,"EOR","izx");o(0x51,"EOR","izy")
o(0x24,"BIT","zp");o(0x2C,"BIT","abs")
o(0x69,"ADC","imm");o(0x65,"ADC","zp");o(0x75,"ADC","zpx");o(0x6D,"ADC","abs");o(0x7D,"ADC","abx");o(0x79,"ADC","aby");o(0x61,"ADC","izx");o(0x71,"ADC","izy")
o(0xE9,"SBC","imm");o(0xE5,"SBC","zp");o(0xF5,"SBC","zpx");o(0xED,"SBC","abs");o(0xFD,"SBC","abx");o(0xF9,"SBC","aby");o(0xE1,"SBC","izx");o(0xF1,"SBC","izy")
o(0xC9,"CMP","imm");o(0xC5,"CMP","zp");o(0xD5,"CMP","zpx");o(0xCD,"CMP","abs");o(0xDD,"CMP","abx");o(0xD9,"CMP","aby");o(0xC1,"CMP","izx");o(0xD1,"CMP","izy")
o(0xE0,"CPX","imm");o(0xE4,"CPX","zp");o(0xEC,"CPX","abs")
o(0xC0,"CPY","imm");o(0xC4,"CPY","zp");o(0xCC,"CPY","abs")
o(0xE6,"INC","zp");o(0xF6,"INC","zpx");o(0xEE,"INC","abs");o(0xFE,"INC","abx")
o(0xC6,"DEC","zp");o(0xD6,"DEC","zpx");o(0xCE,"DEC","abs");o(0xDE,"DEC","abx")
o(0xE8,"INX","imp");o(0xC8,"INY","imp");o(0xCA,"DEX","imp");o(0x88,"DEY","imp")
o(0x0A,"ASL","acc");o(0x06,"ASL","zp");o(0x16,"ASL","zpx");o(0x0E,"ASL","abs");o(0x1E,"ASL","abx")
o(0x4A,"LSR","acc");o(0x46,"LSR","zp");o(0x56,"LSR","zpx");o(0x4E,"LSR","abs");o(0x5E,"LSR","abx")
o(0x2A,"ROL","acc");o(0x26,"ROL","zp");o(0x36,"ROL","zpx");o(0x2E,"ROL","abs");o(0x3E,"ROL","abx")
o(0x6A,"ROR","acc");o(0x66,"ROR","zp");o(0x76,"ROR","zpx");o(0x6E,"ROR","abs");o(0x7E,"ROR","abx")
o(0x4C,"JMP","abs");o(0x6C,"JMP","ind");o(0x20,"JSR","abs");o(0x60,"RTS","imp");o(0x40,"RTI","imp")
o(0x90,"BCC","rel");o(0xB0,"BCS","rel");o(0xF0,"BEQ","rel");o(0xD0,"BNE","rel");o(0x30,"BMI","rel");o(0x10,"BPL","rel");o(0x50,"BVC","rel");o(0x70,"BVS","rel")
o(0x18,"CLC","imp");o(0x38,"SEC","imp");o(0x58,"CLI","imp");o(0x78,"SEI","imp");o(0xD8,"CLD","imp");o(0xF8,"SED","imp");o(0xB8,"CLV","imp")
o(0xEA,"NOP","imp");o(0x00,"BRK","imp")
SIZE={"imp":1,"acc":1,"imm":2,"zp":2,"zpx":2,"zpy":2,"izx":2,"izy":2,"abs":3,"abx":3,"aby":3,"ind":3,"rel":2}

# ---- load fixture ----
d=open(SID,"rb").read()
assert d[:4]==b'PSID'
body=d[0x7c:]
base=body[0]|body[1]<<8           # $2000
image=body[2:]                    # $2000..$AAA3
END=base+len(image)               # $AAA3
mem=bytearray(65536); mem[base:base+len(image)]=image
# relocate subtune 0 block to $B000 (engine image)
src0=mem[0x204D]|mem[0x204E]<<8    # $2063
mem[0xB000:0xB000+0x1000]=mem[src0:src0+0x1000]

PB,PE=0xB000,0xBCE8               # engine symbolic region (== file $2063..$2D4B)
# ---- recursive descent over engine ----
visited=set(); starts=[0xB000,0xB003]; q=list(starts)
while q:
    pc=q.pop()
    while PB<=pc<PE:
        if pc in visited: break
        visited.add(pc); op=mem[pc]
        if op not in T: break
        mn,mode=T[op]; sz=SIZE[mode]
        if mode=="abs" and mn in("JMP","JSR"):
            t=mem[pc+1]|mem[pc+2]<<8
            if PB<=t<PE: q.append(t)
        elif mode=="rel":
            t=(pc+2+((mem[pc+1]^0x80)-0x80))&0xffff
            if PB<=t<PE: q.append(t)
        nxt=pc+sz
        if mn in("JMP","RTS","RTI","BRK"): break
        pc=nxt
starts_set=set(visited)

# referenced targets -> need labels
refs=set()
for pc in visited:
    op=mem[pc]; mn,mode=T[op]
    if mode=="abs" and mn in("JMP","JSR"):
        refs.add(mem[pc+1]|mem[pc+2]<<8)
    elif mode=="rel":
        refs.add((pc+2+((mem[pc+1]^0x80)-0x80))&0xffff)

# ---- named labels & equates ----
NAMED={0xB000:"engine_init_vec",0xB003:"engine_play_vec",0xB666:"player_init",
0xB6B6:"player_play",0xB6C4:"voice_loop",0xB713:"freq_sweep_1",0xB799:"freq_sweep_2",
0xB829:"pw_sweep_1",0xB8AF:"pw_sweep_2",0xB937:"fetch_note",0xB949:"read_stream",
0xB952:"decode_cmd",0xB96A:"read_loopptr",0xB973:"note_on",0xBB5C:"sid_output",
0xBB60:"out_voice",0xBBD1:"next_voice"}
def lbl(a):
    if a in NAMED: return NAMED[a]
    return "L%04X"%a

# equates substituted into operands (addr -> symbol). Byte-exact: symbol == addr.
EQU=[
 ("SID_FREQ_LO",0xD400),("SID_FREQ_HI",0xD401),("SID_PW_LO",0xD402),("SID_PW_HI",0xD403),
 ("SID_CTRL",0xD404),("SID_AD",0xD405),("SID_SR",0xD406),("SID_FCUT_LO",0xD415),
 ("SID_FCUT_HI",0xD416),("SID_RESON",0xD417),("SID_VOL",0xD418),
 ("freqtab_hi",0xB500),("freqtab_lo",0xB55F),
 ("v_freq_hi",0xB5EE),("v_freq_lo",0xB5F4),("v_freq2_hi",0xB5F1),("v_freq2_lo",0xB5F7),
 ("v_pw_hi",0xB5FA),("v_pw_lo",0xB600),("v_pw2_hi",0xB5FD),("v_pw2_lo",0xB603),
 ("v_ctrl",0xB606),("v_ctrl2",0xB609),("v_oscsel",0xB60C),("v_oscsel_ctr",0xB60F),
 ("v_tempo",0xB612),("v_eff",0xB615),("v_finetune",0xB654),("v_ad",0xB5E8),("v_sr",0xB5EB),
 ("cur_voice",0xB5D9),("cur_voice2",0xB5DA),("cmd_lo",0xB5E2),("cmd_hi",0xB5E3),
 ("inst_ptr",0xB5DC),
]
A2S={a:s for s,a in EQU}

def operand(pc,mode):
    b=mem[pc:pc+SIZE[mode]]
    if mode in("imp","acc"): return ""
    if mode=="imm": return "#$%02X"%b[1]
    if mode=="zp":  return "$%02X"%b[1]
    if mode=="zpx": return "$%02X,X"%b[1]
    if mode=="zpy": return "$%02X,Y"%b[1]
    if mode=="izx": return "($%02X,X)"%b[1]
    if mode=="izy": return "($%02X),Y"%b[1]
    if mode=="rel": return lbl((pc+2+((b[1]^0x80)-0x80))&0xffff)
    addr=b[1]|b[2]<<8
    def nm(a,suf=""):
        if a in A2S: return A2S[a]+suf
        return "$%04X"%a+suf
    if mode=="abs":
        # code label if it is an instruction start we emit symbolically
        if addr in starts_set or addr in NAMED: return lbl(addr)
        return nm(addr)
    if mode=="abx": return nm(addr,",X")
    if mode=="aby": return nm(addr,",Y")
    if mode=="ind": return "(%s)"%nm(addr)

# ---- inline comments for key code addresses ----
CMT={
0xB666:"--- player_init: called once per subtune ---",
0xB66E:"seed per-voice stream ptrs ($F0-$F5) and loop ptrs ($F6-$FB)",
0xB688:"SID master volume = 8",
0xB6B1:"set engine-initialised flag ($FF)",
0xB6B6:"--- player_play: called once per frame (50Hz) ---",
0xB6BB:"run only once initialised",
0xB6C4:"per-voice loop (X = voice 0..2)",
0xB6CD:"load this voice's current instrument pointer into $FC/$FD",
0xB6DA:"tempo counter--; on wrap, advance step and fetch next note",
0xB6F3:"counter wrapped -> fetch next note command",
0xB713:"--- freq_sweep_1: 16-bit vibrato/porta add/sub on osc1 ---",
0xB799:"--- freq_sweep_2: same template, osc2 frequency ---",
0xB829:"--- pw_sweep_1: pulse-width sweep ---",
0xB8AF:"--- pw_sweep_2: second pulse-width sweep ---",
0xB937:"--- fetch_note: read next 16-bit command from voice stream ---",
0xB949:"read byte via ($F0,X); 16-bit ptr++",
0xB952:"$0000 word = END marker -> reload from loop ptr (pattern repeat)",
0xB96A:"read byte via loop ptr ($F6,X); ptr++",
0xB973:"--- note_on: decode instrument (hi bits) + note (low 6 bits) ---",
0xB98C:"note $3F = tie/hold (no retrigger)",
0xBB5C:"--- sid_output: write all 3 voices to the SID ($D400 stride 7) ---",
0xBBAA:"voice 3 also drives filter/volume",
0xBBD1:"advance to next SID voice register window",
}

# ---- emit engine.asm ----
L=[]
L.append("; engine.asm  -  The Last Ninja / WEMUSIC player engine")
L.append("; Resident at $B000 after the relocator copies it there.")
L.append("; Assembled inside  !pseudopc $B000 { !source \"engine.asm\" }  by lastninja.asm,")
L.append("; so labels carry their run-time ($Bxxx) addresses but bytes land at file $2063.")
L.append("; Code is symbolic; embedded tables are emitted as !byte (byte-exact).")
L.append("")
L.append("; ---- equates (names resolve to their exact addresses; bytes unchanged) ----")
for s,a in EQU: L.append("%-14s = $%04X"%(s,a))
L.append("")

def emit_data(lo,hi,banner=None):
    if banner: L.append("; %s"%banner)
    a=lo
    while a<hi:
        chunk=mem[a:min(a+16,hi)]
        L.append("    !byte "+", ".join("$%02X"%x for x in chunk)+"   ; $%04X"%a)
        a+=16

pc=PB
# data tables before code (with banners at known spots)
DATA_BANNERS={0xB006:"per-voice arpeggio / wavetable streams",
0xB1CE:"instrument data records (base for ($FC),Y reads)",
0xB3FC:"sequence / pattern pointer tables",
0xB500:"NOTE FREQUENCY table - high bytes (freqtab_hi)",
0xB55F:"NOTE FREQUENCY table - low bytes (freqtab_lo)",
0xB5C6:"misc small lookup tables (durations, vibrato deltas)",
0xB5D6:"engine scratch + per-voice runtime state arrays"}
while pc<PE:
    if pc in visited:
        op=mem[pc]; mn,mode=T[op]; sz=SIZE[mode]
        if pc in NAMED or pc in refs:
            if pc in CMT and CMT[pc].startswith("---"):
                L.append(""); L.append("; "+CMT[pc])
            L.append("%s:"%lbl(pc))
        opr=operand(pc,mode)
        c=CMT.get(pc,"")
        if c and not c.startswith("---"): c="   ; "+c
        elif c.startswith("---"): c=""
        L.append(("    %-4s %-14s"%(mn,opr)).rstrip()+c)
        pc+=sz
    else:
        nxt=min([a for a in sorted(visited) if a>pc], default=PE)
        # split data run on banner boundaries
        a=pc
        while a<nxt:
            seg_end=nxt
            for ba in sorted(DATA_BANNERS):
                if a<ba<nxt: seg_end=ba; break
            emit_data(a,seg_end,DATA_BANNERS.get(a))
            a=seg_end
        pc=nxt
L.append("")
L.append("; engine region must be exactly $B000..$BCE8")
L.append('!if * != $BCE8 { !error "engine.asm size drift: ", *, " != $BCE8" }')
open(os.path.join(OUT,"engine.asm"),"w").write("\n".join(L)+"\n")

# ---- emit musicdata.asm (file $2D4B..$AAA3) ----
M=[]
M.append("; musicdata.asm  -  music data blob, file $2D4B..$AAA3")
M.append("; This is the song data + the other subtunes' relocatable blocks")
M.append("; (the 11 subtune windows overlap; the relocator copies a $1000-byte")
M.append("; window per subtune to $B000). Emitted byte-exact as data.")
M.append("; Subtune source pointers (from the table at $204D):")
ptrs=[mem[0x204D+2*i]|mem[0x204E+2*i]<<8 for i in range(11)]
M.append("; "+", ".join("s%d=$%04X"%(i,p) for i,p in enumerate(ptrs)))
M.append("")
lo=0x2D4B
a=lo
while a<END:
    chunk=mem[a:min(a+16,END)]
    M.append("    !byte "+", ".join("$%02X"%x for x in chunk)+"   ; $%04X"%a)
    a+=16
M.append("")
M.append('!if * != $AAA3 { !error "musicdata end drift: ", *, " != $AAA3" }')
open(os.path.join(OUT,"musicdata.asm"),"w").write("\n".join(M)+"\n")

print("engine.asm code-insns:",len(visited),"region $%04X-$%04X"%(PB,PE))
print("musicdata bytes:",END-lo,"($%04X-$%04X)"%(lo,END))
print("wrote",OUT)
