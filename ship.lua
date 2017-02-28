-- Ship
Ship = {image_number=0, lives=0,died = false, image =nil, display = nil}


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
  local outline = graphics.newOutline(2,self.image,1)
  physics.addBody (self.display, {outline=outline, isSensor = true})
  self.display.myName = name
  return o
end

function Ship:setDisplay (value)
  self.display:setSequence(value)
end

