obj

  rtc : "DS1307"
  pst : "Parallax Serial Terminal"

con

  SCL      = 0             ''SDA should be connected to pin SCL + 1
  i2cAddr = %1101_0000
  
pub main | hours, minutes, month, day

  ''pst.start(9600)
  ''waitcnt(clkfreq*3 + cnt)

  ''testing
  {{repeat
    pst.clear
    hours :=  rtc.getHours
    pst.dec(hours)
    waitcnt(clkfreq*5 + cnt)}}

    ''calibration
    rtc.setTime(SCL, i2cAddr, 2, 35, 0)
    rtc.setDate(SCL, i2cAddr, 9, 5, 4, 1990)

