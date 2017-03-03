-- Laser
Laser = {image_number=0,image =nil, display = nil}

local options = {
  width = 14,
  height =  40,
  numFrames = 2,
  sheetContentWidth=28, 
  sheetContentHeight=40
}

local sequenceData = {
  {name="1", start = 1, count = 1},
  {name="2", start = 2, count = 1}
}

function Laser:new (o,image_number,x,y,group,name)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.image_number = image_number
  self.image = graphics.newImageSheet("laser.png",options)
  self.display = display.newSprite(group,self.image, sequenceData)
  self.display.x = x
  self.display.y = y
  local outline = graphics.newOutline(2,self.image,image_number)
  physics.addBody (self.display,"dynamic", {isSensor = true})
  self.display.myName = name
  self.display:setSequence(image_number)
  self.display.isBullet = true;
  return o
end

function Laser:setDisplay (value)
  self.display:setSequence(value)
end

