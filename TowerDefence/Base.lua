local mylib = require("mylib")

local Base = {}

function Base.new(kwargs)
  kwargs.name = kwargs.name or "base"
  kwargs.type = kwargs.type or "orange"
  kwargs.level = kwargs.level or 1
  local config = mylib.getConfig(kwargs)
  
  local scale = 0.8
  local self = display.newImageRect(mylib.getImageName(kwargs), kwargs.size * scale, kwargs.size * scale)
  self.x = kwargs.x
  self.y = kwargs.y
  self.row = kwargs.row
  self.col = kwargs.collectgarbage
  self.size = kwargs.size
  
  return self
end

return Base