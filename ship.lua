-- Ship
require("laser")

Ship = {image_number=0, lives=0,died = false, image =nil, display = nil,laser = 2}

local fireSound
fireSound = audio.loadSound( "audio/fire.mp3" )

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
  self.image = graphics.newImageSheet("ship.png",options)
  self.display = display.newSprite(group,self.image, sequenceData)
  self.display.x = x
  self.display.y = y
  local outline = graphics.newOutline(2,self.image,image_number)
  physics.addBody (self.display, {outline=outline, isSensor = true})
  self.display.myName = name
  self.display:setSequence(image_number)
  return o
end

 function Ship:fireLaser()
    -- Play fire sound!
  audio.play( fireSound )
  local newLaser = Laser:new(nil,self.laser,self.display.x,self.display.y,self.display.parent,"laser")
  newLaser.display:toBack()
  print(newLaser.display.sequence .. "AND" .. self.laser)
  transition.to( newLaser.display, { y=-40, time=self.display.y/2,
      onComplete = function() display.remove( newLaser ) end
      } )

  end


function Ship:setDisplay (value)
  self.display:setSequence(value)
end


function Ship:setLaser(value)
  self.laser = value
end
