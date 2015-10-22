con

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  ''ADC
  DIO  = 26
  CLK  = 25
  CS   = 27

  ''LCD
  BAUD = 9_600
  Tx   = 1

  ''POTENTIOMETERS
  POT_1 = 1
  POT_2 = 2

obj

  pst : "Parallax Serial Terminal"
  adc : "MCP3208"
  lcd : "LCD"
  exp : "Experimental_Functions"

var

  byte printOut
  
pub main | val, force

  ''Start drivers
  adc.start(DIO,CLK,CS,255)
  ''pst.start(BAUD)
  lcd.start(Tx,BAUD)
  
  ''print out information on a loop
  ''we check which units the user wants to use
  ''and we also check how often they want to sample
  repeat
    val := adc.in(0)
    force := ((250 * val) - 14_750) ''/ getScale(POT_1)
    if force < 0
      force := 0
    lcd.bprint(exp.toStr(force))
    waitcnt((clkfreq/getInterval(POT_1)) + cnt)

pri getScale( pin ) | val

  val := adc.in(pin)
  if (val <= 1_000)
    return 1
  elseif (val <= 2_000)
    return 1_000
  elseif (val <= 3_000)
    return 1_000_000
  else
    return 1_000_000_000

pri getInterval( pin ) | val

  val := adc.in( pin )
  return ((val / 100) + 1)
    