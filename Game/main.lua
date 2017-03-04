local composer = require( "composer" )
 --require("mobdebug").start()
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )
 
 -- Reserve channel 1 for background music
audio.reserveChannels( 1 ) -- game
audio.reserveChannels( 2 ) -- menu
audio.reserveChannels( 3 ) -- highscores

-- Reduce the overall volume of the channel
audio.setVolume( 0.3, { channel=1 } )
audio.setVolume( 0.5, { channel=2 } )
audio.setVolume( 0.5, { channel=3 } )

-- Go to the menu screen
composer.gotoScene( "src.menu" )