local Node = {}


local mt = { __index = Node}
PathFinding = require("PathFinding")

function Node: new (kwargs)
  local self = setmetatable(kwargs, mt)
  
  local pos = self.grid:toPosition(self, "corner")
  self.x = pos.x
  self.y = pos.y
  self.image = display.newCircle(self.grid.group, self.x, self.y, 2.5)
  self.image:setFillColor(1, 0, 0, 0.4)
  
  return self
end

function Node:debug(s)
  if s == nil then
    if self.debugText ~= nil then
      display.remove(self.debugText)
      self.debugText = nil
    end
    return
  end
  
  if self.debugText == nil then 
    self.debugText = display.newText (self.grid.group, s, self.x + 0.5 * self.grid.size, self.y + 0.5 * self.grid.size)
  end
  
  self.debugText.text = s
end


function Node:flipBarrier(direction)
  assert (direction == "vertical" or direction == "horizontal", "Unexpected direction ("..direction..")")
  
  --build barrier if currently empty
  if self[direction] == nil then 
    local wall, wallPhysics
    if direction == "vertical" then 
      wall = display.newImageRect("assets/images/vwall.png", 20, self.grid.size)
      wall.x = self.x
      wall.y = self.y + 0.5 * self.grid.size
      wallPhysics = { box = {halfWidth = 5, halfHeight = self.grid.size / 2}}
    else
      wall = display.newImageRect("assets/images/hwall.png", self.grid.size, 20)
      wall.x = self.x + 0.5 * self.grid.size
      wall.y = self.y 
      wallPhysics = { box = {halfWidth = self.grid.size / 2, halfHeight = 5}}
  end
    
    self[direction] = wall
    if PathFinding.isConnected(self.grid.base) then
      physics.addBody(wall, "static", wallPhysics)
    else
      display.remove(self[direction])
      self[direction] = nil
    end
    
    
  else
    display.remove(self[direction])
    self[direction] = nil
    PathFinding.isConnected(self.grid.base)
  end
  
end


return Node