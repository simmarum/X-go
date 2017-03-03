-- Asteroid
Asteroid = {image_number=0,image =nil, display = nil}


local options = {
  width = 102,
  height =  97,
  numFrames = 3,
  sheetContentWidth=102, 
  sheetContentHeight=291
}

local sequenceData = {
  {name="1", start = 1, count = 1},
  {name="2", start = 2, count = 1},
  {name="3", start = 3, count = 1}
}

function Asteroid:new (o,image_number,x,y,group,name)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.image_number = image_number
  self.image = graphics.newImageSheet("asteroid.png",options)
  self.display = display.newSprite(group,self.image, sequenceData)
  self.display.x = x
  self.display.y = y
  local outline = graphics.newOutline(2,self.image,image_number)
  physics.addBody (self.display,"dynamic", {outline=outline, bounce=0.85})
  self.display.myName = name
  self.display:setSequence(image_number)
  return o
end

function Asteroid:setDisplay (value)
  self.display:setSequence(value)
end

