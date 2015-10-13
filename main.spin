OBJ
  Keyscan: "4x4 Keypad Reader"
  text:    "Parallax Serial Terminal"

CON
  code = $06_01_02_03
  timegiven = 8
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

VAR
  word key
  byte numberofkeys
  long keybuffer
  byte flag
  byte armed
  byte timeup
  byte cogfortimer
  byte wait

  long stack[32]

  long timeremain
  long stackfortimer[32]

  byte counter
  long fullstate
PUB main
  text.start(115200)
  dira[8..14]:=%1111000
  beep
  cognew(disp,@stack)
  repeat
    wait:=0
    
    repeat
      key:=Keyscan.readkeypad
    while key<>%0001000000000000  
    keybuffer:=$0F0F0F0F
    repeat
      beep
      waitcnt(cnt+30_000_000)      
    while ina[12..14]==%111
    
    numberofkeys:=0
    cogfortimer:=cognew(timer,@stackfortimer)
    repeat  
      repeat
        flag:=0
        key:=Keyscan.readkeypad
        case key                             

          %0000000000000010:
            keybuffer.byte[numberofkeys]:=$01 
          %0000000000000100:
            keybuffer.byte[numberofkeys]:=$02 
          %0000000000001000:
            keybuffer.byte[numberofkeys]:=$03
          %0000000000100000:
            keybuffer.byte[numberofkeys]:=$04
          %0000000001000000:
            keybuffer.byte[numberofkeys]:=$05  
          %0000000010000000:
            keybuffer.byte[numberofkeys]:=$06 
          %0000001000000000:
            keybuffer.byte[numberofkeys]:=$07
          %0000010000000000:
            keybuffer.byte[numberofkeys]:=$08
          %0000100000000000:
            keybuffer.byte[numberofkeys]:=$09
          %0100000000000000:
            keybuffer.byte[numberofkeys]:=$00
          other:
            flag:=1
        if flag==0
          numberofkeys++
          waitcnt(cnt+30_000_000)
        if timeup==1
          alarm
      while flag==1 or numberofkeys<4
      text.hex(keybuffer,8)
      if code==keybuffer
        cogstop(cogfortimer)
        quit
      if code<>keybuffer and numberofkeys>=4
        beep
        numberofkeys:=0
        
                       

PUB disp
  dira[8..10]:=%111
  repeat
    if numberofkeys==0
      outa[8..10]:=%000
    elseif numberofkeys==1
      outa[8..10]:=%001
    elseif numberofkeys==2
      outa[8..10]:=%011
    elseif numberofkeys==3
      outa[8..10]:=%111

PUB check
  {{fullstate:=1
  repeat
    fullstate:=fullstate*2+1
  while counter<(TRGPINS-11)}}
  text.bin(ina[12..14],3)
  if ina[12..14]<>%111
    return(1)
  else
    return(0)

PUB alarm
  repeat
    outa[11]:=1
    waitcnt(cnt+5_000_000)
    outa[11]:=0
    waitcnt(cnt+1_000_000)

PUB timer
  timeremain:=0
  dira[11]:=1
  timeup:=0
  repeat
    outa[11]:=1
    waitcnt(cnt+3_000_000)
    outa[11]:=0
    waitcnt(cnt+72_000_000)
    timeremain++
  while timeremain<timegiven
  timeup:=1

PUB beep
  outa[11]:=1
  waitcnt(cnt+1_000_000)
  outa[11]:=0
  waitcnt(cnt+1_000_000)
