-- Ship
require("src.laser")

Ship = {image_number=0, lives=0,died = false, image =nil, display = nil,laser = 2,fire = 0}

local fireSound
fireSound = audio.loadSound( "res/audio/fire.mp3" )

local velocityFire = 1.5
local options = {
  width = 96,
  height =  76,
  numFrames = 2,
  sheetContentWidth=192, 
  sheetContentHeight=76
}

local sequenceData = {
  {name="live", start = 1, count = 1},
  {name="died", start = 2, count = 1}
}

function Ship:new (o,image_number,lives,died,x,y,group,name)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.image_number = image_number
  self.lives = lives
  self.died = died
  self.image = graphics.newImageSheet("res/graphic/ship.png",options)
  self.display = display.newSprite(group,self.image, sequenceData)
  self.display.x = x
  self.display.y = y
  local outline = graphics.newOutline(2,self.image,image_number)
  physics.addBody (self.display, {outline=outline, isSensor = true})
  self.display.myName = name
  self.display:setSequence(image_number)
  return o
end

local function removeLaser (laser)
  display.remove(laser)
end

function Ship:fireLaser()
  -- Play fire sound!
  audio.play( fireSound )
  local newLaser = Laser:new(nil,self.laser,self.display.x,self.display.y,0,self.display.parent,"laser")
  newLaser.display:toBack()
  transition.to( newLaser.display, { y=-newLaser.display.height, time=self.display.y/velocityFire, onComplete=removeLaser} )
end

function Ship:fireLaserCross()
  -- Play fire sound
  audio.play(fireSound)
  -- North
  local newLaserN = Laser:new(nil,self.laser,self.display.x,self.display.y,0,self.display.parent,"laser")
  newLaserN.display:toBack()
    transition.moveTo( newLaserN.display, { y=-newLaserN.display.height, time=self.display.y/velocityFire,onComplete=removeLaser} )
  -- East
  local newLaserE = Laser:new(nil,self.laser,self.display.x,self.display.y,90,self.display.parent,"laser")
  newLaserE.display:toBack()
  newLaserE.display.rotate = 90
      transition.moveTo( newLaserE.display, { x=display.contentWidth + newLaserE.display.height, time=(display.contentWidth-self.display.x)/velocityFire, onComplete=removeLaser} )
  -- South
  local newLaserS = Laser:new(nil,self.laser,self.display.x,self.display.y,180,self.display.parent,"laser")
  newLaserS.display:toBack()
  newLaserS.display.rotate = 180
      transition.moveTo( newLaserS.display, { y=display.contentHeight + newLaserS.display.height, time=(display.contentHeight-self.display.y)/velocityFire, onComplete=removeLaser} )
  -- West
  local newLaserW = Laser:new(nil,self.laser,self.display.x,self.display.y,270,self.display.parent,"laser")
  newLaserW.display:toBack()
  newLaserW.display.rotate = 270
    transition.moveTo( newLaserW.display, { x=-newLaserW.display.height, time=self.display.x/velocityFire, onComplete=removeLaser} )
  end

  function Ship:setDisplay (value)
    self.display:setSequence(value)
  end


  function Ship:setLaser(value)
    self.laser = value
  end
