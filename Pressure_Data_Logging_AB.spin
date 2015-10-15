{
  Program controls Velostat pressure sensor and TMP36 temperature sensor,
  manages the data and writes it to a microSD card along with a time stamp
  as read by a DS1307 Real Time Clock.
  
  **This is the Propeller Activity Board version, there is also a
  Propeller ASC/ASC+ version due to the different ADC chips**
  
  -------------------------------------------------------------------------
  Matheus Barbosa
  Oklahoma State University
  Department of Electrical and Computer Engineering
  02-13-2015
}

con

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


  ''microSD card pins
  DO  = 22
  CLK = 23
  DI  = 24
  CS  = 25

  ''Real Time Clock
  SCL      = 0             ''SDA should be connected to pin SCL + 1
  i2cAddr = %1101_0000

  ''TMP36
  tmpSensorPin = 0                    ''TMP36 sensor AD pin

  ''ADC pins
  adcCS  = 21
  adcDO  = 19
  adcDI  = 18
  adcCLK = 20

  ''Velostat Pressure Sensor
  cds1Pin = 1                         ''Cadmium Sulfide light sensor 1 AD pin
  cds2Pin = 2

  ''Other
  signalLedPin     = 26             ''onboard LED to signal exiting loop later on in the program
  samplingInterval = 300            ''data sampling interval in seconds

var

  word initialADReading            ''holds inital ADC reading
  long stack[40] 
    
obj

  sd  : "fsrw"
  sck : "Clock"
  rtc : "DS1307"
  adc : "ADC124S021"
  exp : "Experimental_Functions"
  led : "LED Control"
  
pub main | cog

  cog := cognew(runLed, @stack)                     ''led symbolizes that program is running
  adc.start(adcCS, adcCLK, adcDI, adcDO)            ''start adc driver
  sd.mount_explicit(DO, CLK, DI, CS)                ''mount microSD card
  sd.popen(string("data.docx"), "w")                ''create file
  initialADReading := adc.read(tmpSensorPin)        ''get initial ADC reading
  sd.pclose                                         ''close file
  led.start(signalLedPin)                           ''set signal LED pin direction to output
  
  repeat 
    rtc.getTime(SCL, i2cAddr)                       ''get data from rtc
    rtc.getDate(SCL, i2cAddr)
    sd.popen(string("data.docx"), "a")              ''open file to append
    sd.pputs(exp.toStr(rtc.getMonths))              ''date
    sd.pputc("/")
    sd.pputs(exp.toStr(rtc.getDays))
    sd.pputc(" ")
    sd.pputs(exp.toStr(rtc.getHours))               ''hour
    sd.pputc(":")
    sd.pputs(exp.toStr(rtc.getMinutes))             ''minute
    sd.pputc(" ")
    sd.pputs(string("Temperature: "))
    sd.pputs(exp.toStr(getTemp))                    ''temperature
    sd.pputs(string("F "))
    sd.pputs(string("Pressure: "))
    sd.pputs(exp.toStr(getPressure(cds1Pin)))       ''pressure 1
    sd.pputs(string("Pa "))
    ''sd.pputs(exp.toStr(getPressure(cds2Pin)))       ''pressure 2
    ''sd.pputs(string("Pa"))                          
    sd.pputc(%0000_1010)                            ''new line (ascii encoded)
    led.blinkTimes(200, 150, 3)
    sd.pclose                                       ''close file
    sck.pauseSec(240)                  ''pause
      ''sck.pauseMSec(1000)                             ''for debugging
    
  sd.pclose                                         ''close file, unmount microSD and stop signal flashing LED
  sd.unmount
  cogstop(cog)
  led.blinkTimes(200, 150, 4)                       ''flash P26 LED to signal exiting program 
  
pri getTemp | milliVolts, celsius       ''converts adc reading to temperature

  milliVolts := ((adc.read(tmpSensorPin)*3300)/2703)
  celsius := ((milliVolts-500)/10)
  return (((celsius*9)/5)+32)

pri getPressure(pin)      ''converts adc reading to pressure

  return((((adc.read(pin)-initialADReading)*13)/10) + 750)

pri runLed      ''blinks LED to signal that program is runnning

  dira[15] := 1

  repeat
    outa[15] := 1
    sck.pauseMSec(300)
    outa[15] := 0
    sck.pauseMSec(300)
       