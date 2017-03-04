
local composer = require( "composer" )
require("src.ship")
require("src.asteroid")
require("src.laser")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )


-- Initialize variables
local score = 0
local destroyAsteroid = 0

local asteroidsTable = {}

local myship
local gameLoopTimer
local livesText
local scoreText
local destroyAsteroidText

local backGroup
local mainGroup
local uiGroup

local explosionSound
explosionSound = audio.loadSound( "res/audio/explosion.mp3" )

local musicTrack
musicTrack = audio.loadStream( "res/audio/80s-Space-Game_Looping.mp3")


local function updateText()
  livesText.text = "Lives: " .. myship.lives
  scoreText.text = "Score: " .. score
  destroyAsteroidText.text = "Asteroid: " .. destroyAsteroid
end


local function createAsteroid()

  local newAsteroid
  local maxNumber = 200
  local whichAsteroid = math.random( maxNumber )
  if(whichAsteroid <= maxNumber*(1/2))
  then newAsteroid = Asteroid:new(nil,1,60,90,mainGroup,"asteroid")
  elseif (whichAsteroid <= maxNumber*(3/4))
  then newAsteroid = Asteroid:new(nil,2,60,90,mainGroup,"asteroid")
  elseif (whichAsteroid <= maxNumber*(19/20)) 
  then newAsteroid = Asteroid:new(nil,3,60,90,mainGroup,"asteroid")
  else newAsteroid = Asteroid:new(nil,4,60,90,mainGroup,"asteroid")
  end
  table.insert( asteroidsTable, newAsteroid )
  local whereFrom = math.random( 4 )
  local heightRand = display.contentHeight * 0.9

  if ( whereFrom == 1 ) then
    -- From the left
    newAsteroid.display.x = -60
    newAsteroid.display.y = math.random( heightRand )
    newAsteroid.display:setLinearVelocity( math.random( 60,150 ), math.random( -50,100 ) )
  elseif ( whereFrom == 2 ) then
    -- From the top
    newAsteroid.display.x = math.random( display.contentWidth )
    newAsteroid.display.y = -60
    newAsteroid.display:setLinearVelocity( math.random( -60,60 ), math.random( 80,150 ) )
  elseif ( whereFrom == 3 ) then
    -- From the right
    newAsteroid.display.x = display.contentWidth + 60
    newAsteroid.display.y = math.random( heightRand )
    newAsteroid.display:setLinearVelocity( math.random( -150,-60 ), math.random( -50,100 ) )
  elseif ( whereFrom == 4 ) then
    -- From the down
    newAsteroid.display.x = math.random( display.contentWidth )
    newAsteroid.display.y = display.contentHeight + 60
    newAsteroid.display:setLinearVelocity( math.random( -60,60 ), math.random( -150,-80 ) )
  end

  newAsteroid.display:applyTorque( math.random( -6,6 ) )
end




local function dragShip( event )

  local ship = event.target
  local phase = event.phase

  if ( "began" == phase ) then
    -- Set touch focus on the ship
    display.currentStage:setFocus( ship )
    -- Store initial offset position
    ship.touchOffsetX = event.x - ship.x
    ship.touchOffsetY = event.y - ship.y

  elseif ( "moved" == phase ) then
    -- Move the ship to the new touch position
    ship.x = event.x - ship.touchOffsetX
    ship.y = event.y - ship.touchOffsetY
  elseif ( "ended" == phase or "cancelled" == phase ) then
    -- Release touch focus on the ship
    display.currentStage:setFocus( nil )
  end

  return true  -- Prevents touch propagation to underlying objects
end


local function gameLoop()

  -- Create new asteroid
  createAsteroid()

  -- Remove asteroids which have drifted off screen
  for i = #asteroidsTable, 1, -1 do
    local thisAsteroid = asteroidsTable[i]

    if ( thisAsteroid.display.x < -100 or
      thisAsteroid.display.x > display.contentWidth + 100 or
      thisAsteroid.display.y < -100 or
      thisAsteroid.display.y > display.contentHeight + 100 )
    then
      display.remove( thisAsteroid )
      table.remove( asteroidsTable, i )
    end
  end
end


local function restoreShip()

  myship.display.isBodyActive = false
  myship.display:setLinearVelocity( 0, 0 )
  myship.display.x = display.contentCenterX
  myship.display.y = display.contentHeight - 100

  -- Fade in the ship
  transition.to( myship.display, { alpha=1, time=4000,
      onComplete = function()
        myship.display.isBodyActive = true
        myship.died = false
        myship:setDisplay("live")
      end
      } )
end

local function endGame()
  composer.setVariable( "finalScore", score )
  composer.removeScene( "src.highscores" )
  composer.gotoScene( "src.highscores", { time=800, effect="crossFade" } )
end

local function tap()
  if(myship.fire == 0)
  then myship:fireLaser()
  elseif (myship.fire == 1)
  then myship:fireLaserCross()
  end
end

local function onCollision( event )

  if ( event.phase == "began" ) then

    local obj1 = event.object1
    local obj2 = event.object2

    if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
      ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
    then

      -- Which object has asteroid
      local asteroid
      if(obj1.myName == "asteroid") then asteroid = obj1
      else asteroid = obj2
      end

      -- Increase score by asteroid type
      if(asteroid.sequence == "1" )
      then score = score + (myship.laser * 50)
      elseif(asteroid.sequence == "2")
      then score = score + (myship.laser * 75)
      elseif(asteroid.sequence == "3")
      then score = score + (myship.laser * 100)
      elseif( asteroid.sequence == "4")
      then myship.fire = 1 - myship.fire
      end
      scoreText.text = "Score: " .. score
      print("$$ "..obj1.myName.." AND "..obj2.myName)
      -- Change laser ;p (update destroyAsteroid)
      destroyAsteroid = destroyAsteroid + 1
      if(destroyAsteroid % 10 == 0)
      then myship.laser = 2
      elseif (destroyAsteroid % 10 == 3)
      then myship.laser = 1
      end
      destroyAsteroidText.text = "Asteroid: " .. destroyAsteroid

      -- Remove both the laser and asteroid
      display.remove( obj1 )
      display.remove( obj2 )

      -- Play explosion sound!
      audio.play( explosionSound )
      for i = #asteroidsTable, 1, -1 do
        if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
          table.remove( asteroidsTable, i )
          break
        end
      end

    elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
      ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
    then
      if ( myship.died == false ) then
        myship.died = true

        -- Play explosion sound!
        audio.play( explosionSound )
        -- Update lives
        myship.lives = myship.lives - 1
        livesText.text = "Lives: " .. myship.lives

        if ( myship.lives == 0 ) then
          display.remove( myship.display )
          timer.performWithDelay( 2000, endGame )
        else
          myship.display.alpha = 0
          myship:setDisplay("died")
          timer.performWithDelay( 1000, restoreShip )
        end
      end
    end
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  physics.pause()  -- Temporarily pause the physics engine
  -- Set up display groups
  backGroup = display.newGroup()  -- Display group for the background image
  sceneGroup:insert( backGroup )  -- Insert into the scene's view group

  mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
  sceneGroup:insert( mainGroup )  -- Insert into the scene's view group

  uiGroup = display.newGroup()    -- Display group for UI objects like the score
  sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

  -- Load the background
  local background = display.newImageRect( backGroup, "res/graphic/background.png", 800, 1400 )
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  -- Load ship from another class
  myship = Ship:new(nil,0,3,false,display.contentCenterX,display.contentHeight-100,mainGroup,"ship")

  -- Display lives and score
  livesText = display.newText( uiGroup, "Lives: " .. myship.lives, 150, 80, native.systemFont, 36 )
  scoreText = display.newText( uiGroup, "Score: " .. score, 300, 80, native.systemFont, 36 )
  destroyAsteroidText = display.newText ( uiGroup, "Asteroid: " .. destroyAsteroid, 550, 80, native.systemFont, 36 )

  -- Add listenery
  myship.display:addEventListener( "tap", tap )
  myship.display:addEventListener( "touch", dragShip )

end


-- show()
function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)

  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen
    physics.start()
    Runtime:addEventListener( "collision", onCollision )
    gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
    -- Start the music!
    audio.play( musicTrack, { channel=1, loops=-1 } )
  end
end


-- hide()
function scene:hide( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    timer.cancel( gameLoopTimer )

  elseif ( phase == "did" ) then
    -- Code here runs immediately after the scene goes entirely off screen
    Runtime:removeEventListener( "collision", onCollision )
    physics.pause()
    -- Stop the music!
    audio.stop( 1 )
  end
end


-- destroy()
function scene:destroy( event )

  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view

  -- Dispose audio!
  audio.dispose( explosionSound )
  audio.dispose( fireSound )
  audio.dispose( musicTrack )

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
