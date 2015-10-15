con

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  ''ADC pins
  adcCS  = 21
  adcDO  = 19
  adcDI  = 18
  adcCLK = 20

  ''microSD card pins
  DO  = 22
  CLK = 23
  DI  = 24
  CS  = 25

  POT1 = 1 ''potentiometer analog pins
  POT2 = 2
  SENSOR = 0 ''sensor analog pin
  LCD = 0 ''lcd digital pin
  SW1 = 1 ''switch pins
  SW2 = 2
  BAUD = 9_600

  ''prefixes
  Kkip = $4B
  Mkip = $4D
  Gkip = $47

var

  byte prefix
  
obj

  adc : "ADC124S021"
  screen : "LCD"
  exp : "Experimental_Functions"
  clc : "Clock"
  sd  : "EXP_FSRW"
  pst : "Parallax Serial Terminal"

pub main | val, f, perSec, delay, scale

  dira[LCD]~~
  ''dira[SW1..SW2]~
  ''pst.start(BAUD)
  ''adc.start(adcCS, adcCLK, adcDI, adcDO)            ''start adc driver
  ''sd.mount_explicit(DO, CLK, DI, CS)                ''mount microSD card
  screen.start( LCD,BAUD )
  
  repeat
    ''sd.popen( string( "hh.txt" ), "a" )
    ''pst.clear
    ''perSec := (adc.read(POT1)/400) + 1
    ''delay := 1_000/perSec
    ''pst.str(exp.toStr(delay))
    ''clc.pauseMSec(delay)
    val := adc.read( 1 )
    if val < 0
      val := 0
    ''scale := adc.read(POT2)
    ''pst.str(exp.toStr(scale))
    {{if (scale > 0) and (scale <= 1000)
      scale := 1
    elseif (scale > 1000) and (scale <= 2000)
      scale := 1_000
      prefix := Kkip
    elseif (scale > 2000) and (scale <= 3000)
      scale := 1_000_000
      prefix := Mkip
    else
      scale := 1_000_000_000
      prefix := Gkip}}
    f := (250 * val) ''/ scale
    screen.print( exp.toStr( val ) )''+ string(" ") + prefix )
    ''sd.pputs( exp.toStr( f ) )
    ''sd.pputs( string( " " ) )
    ''sd.pclose
    

  {{  ''No Mode
    if ina[1] == 0 and ina[2] == 0
      lcd.bprint( string( "Please select a mode" ) )
    ''READING ONLY MODE
    if ina[1] == 1 and ina[2] == 0
      lcd.bprint( exp.toStr( f ) )
      
    ''SAVING ONLY MODE
    if ina[1] == 0 and ina[2] == 1
        sd.popen( string("breaks.docx"), "a" )                ''open file
        sd.pputs( exp.toStr( f ) )
        sd.pputc(%0000_1010)                            ''new line (ascii encoded)
        sd.pclose  

    ''SAVING & READING MODE 
    if ina[1] == 1 and ina[2] == 1
        lcd.bprint( string( "Reading and Saving Mode..." ) )
        sd.popen( string("breaks.docx"), "a" )                ''create file
        lcd.bprint( exp.toStr( f ) )
        sd.pputs( exp.toStr( f ) )
        sd.pputc(%0000_1010)                            ''new line (ascii encoded)
        sd.pclose
    }}
      
      
      
           