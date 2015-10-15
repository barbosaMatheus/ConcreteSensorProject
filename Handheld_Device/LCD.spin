{{

  LCD Object for handheld pressure sensing device

  By: Matheus Barbosa
  09/01/2015

  Oklahoma State University
  Department of Electrical and Computer Engineering

}}

obj

  fds : "FullDuplexSerial"

con

  MODE = %1000

pub start( Tx, baud )             ''starts object using full duplex serial

  fds.start( Tx, Tx, MODE, baud )
  'print( string( "000000000000" ) )

pub stop                          ''stops object
                                  
  fds.stop

pub print( str )                  ''prints string to the lcd, including 8 char buffer
  ''fds.Str( string( "        " ) ) ''8 char buffer
  fds.Str( str )

pub bprint( str ) | len, buffer    ''prints string to screen and buffers all the way to the end of the lcd
  len := strsize( str )
  buffer := 32-len                
  ''fds.str( string( "        " ) )             ''8 char buffer
  fds.Str( str )                              ''print string

  repeat buffer
    fds.str( string( " " ) )


pub dec( num )
  fds.Str( string( " " ) ) ''8 char buffer 
  fds.dec( num )
  