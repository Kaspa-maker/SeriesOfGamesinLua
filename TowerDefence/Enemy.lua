local mylib = require("mylib")

Enemy = {}

local mt = {__index = Enemy}

local sheetOptions = {
    width = 64,
    height = 64,
    numFrames = 10
  }
local imageSheet = graphics.newImageSheet("assets/images/enemy.png", sheetOptions)
local sequences = {
    {
      name = "default",
      start = 1,
      count = 10,
      time = 100,
      loopCounter = 0,
      loopDirection = "forward"
    },
  }


function Enemy: new (kwargs)
  kwargs.name = kwargs.name or "enemy"
  kwargs.type = kwargs.type or "white"
  local config = mylib.getConfig(kwargs)
  
  imageSheet = graphics.newImageSheet(mylib.getImageName(kwargs), sheetOptions)
  sequences[1].time = Scrappy.Random:inRange(100, 300)
  local self = display.newSprite(grid.group, imageSheet, sequences)
  self.row = kwargs.row 
  self.col = kwargs.col
  
  local pos = grid:toPosition(self)
  self.x = pos.x
  self.y = pos.y
  
  self:play()
  physics.addBody(self, {radius = 3, bounce = 0})
  self.linearDamping = 5
  
  self.name = kwargs.name
  self.type = kwargs.type
  
  return self
end


return Enemy