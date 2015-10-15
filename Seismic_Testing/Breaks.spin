con

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  
  ''microSD card pins
  DO  = 22
  CLK = 23
  DI  = 24
  CS  = 25

  adcCS  = 21
  adcDO  = 19
  adcDI  = 18
  adcCLK = 20

obj

  adc : "ADC124S021"
  exp : "Experimental_Functions"
  sd  : "EXP_FSRW"

pub main | val, init, i, f

  dira[26] := 1
  adc.start(adcCS, adcCLK, adcDI, adcDO)            ''start adc driver
  sd.mount_explicit(DO, CLK, DI, CS)                ''mount microSD card
  sd.popen(string("breaks.docx"), "w")                ''create file
  waitcnt((clkfreq * 3) + cnt)
  init := adc.read(0)
  sd.pclose                                         ''close file
  waitcnt((clkfreq * 10) + cnt)
  i := 0
  
  repeat
    i++
    val := adc.read(0) - init         
    if val < 0
      val := 0
    f := 191 * val
    sd.popen(string("breaks.docx"), "a")              ''open file to append
    sd.pputs(exp.toStr(i))
    sd.pputs(string(". Lbs force =   "))
    sd.pputs(exp.toStr(f))
    sd.pputs(string("  ADC =   "))
    sd.pputs(exp.toStr(val))
    sd.pputc(%0000_1010)                            ''new line (ascii encoded)
    outa[26] := 1
    sd.pclose
    waitcnt(clkfreq/2 + cnt)
    outa[26] := 0
      