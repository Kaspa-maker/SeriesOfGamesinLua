local mylib = require("mylib")

local Projectile = {}

local scale = 0.7

function Projectile.new(kwargs)
  kwargs.name = kwargs.name or "projectile"
  kwargs.type = kwargs.type or "green"
  local config = mylib.getConfig(kwargs)
  
  local self = display.newImageRect(mylib.getImageName(kwargs.name), kwargs.size * config.scale, kwargs.size * config.scale)
  self.x = kwargs.x
  self.y = kwargs.y
  
  self.size = kwargs.size
  
  self.name = kwargs.name
  self.type = kwargs.type
  
  physics.addBody(self, {isSensor = true, box = {halfWidth = 4, halfHeight = self.size/2}})
  return self
end

return Projectile