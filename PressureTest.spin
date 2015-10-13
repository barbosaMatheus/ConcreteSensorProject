obj

  adc : "ADC124S021"
  pst : "Parallax Serial Terminal"

con

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  adcCS  = 21
  adcDO  = 19
  adcDI  = 18
  adcCLK = 20
  
  cds1Pin = 1
  cds2Pin = 2 

pub main | initialADReading, p1

  pst.start(9600)
  adc.start(adcCS, adcCLK, adcDI, adcDO)       ''start adc driver
  initialADReading := adc.read(cds1Pin)        ''get initial ADC reading
  waitcnt(clkfreq*3 + cnt)
  
  repeat
    pst.clear
    p1 := getPressure(cds1Pin, initialADReading)
    pst.dec(p1)
    waitcnt(clkfreq/3 + cnt)


pri getPressure(pin, initialReading)      ''converts adc reading to pressure

  return((((adc.read(pin)-initialReading)*13)/100))