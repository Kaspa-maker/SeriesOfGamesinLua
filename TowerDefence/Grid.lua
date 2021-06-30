local Base = require("Base")
local Node = require("Node")

local Grid = {}

colors = {
  grid_line = {0.6, 0.6, 0.6, 0.3}
}

local mt = { __index = Grid}



function Grid: new (kwargs)
  local self = setmetatable(kwargs, mt)
  
  --layout grid
  self.rows = math.floor(display.contentHeight/self.size)
  self.cols = math.floor(display.contentWidth/self.size)
  self.hoffset = (display.contentWidth - self.size * self.cols) / 2
  self.voffset = (display.contentHeight - self.size * self.rows) / 2
  
  --traceout lines
  for row = 0, self.rows do
    local line = display.newLine(self.group, 0, self.voffset + (row + 0.5) * self.size, display.contentWidth, self.voffset + (row + 0.5) * self.size)
    line:setStrokeColor(unpack(colors.grid_line))
  end
  for col = 0, self.cols do
    local line = display.newLine(self.group, self.hoffset + (col + 0.5) * self.size, 0, self.hoffset + (col + 0.5) * self.size, display.contentHeight)
    line:setStrokeColor(unpack(colors.grid_line))
  end
  
  --create 2D grid of nodes
  for row = 1, self.rows do
    self[row] = {}
    for col = 1, self.cols do
      self[row][col] = Node:new {row = row, col = col, grid = self}
    end
  end
  return self
end



function Grid:toPosition (obj, mode)
  local offset = mode == "corner" and 0.5 * self.size or 0
  return {x = self.hoffset + self.size * obj.col - offset, y = self.voffset + self.size * obj.row - offset}
end

function Grid:getNodeFromCoordinates (obj)
  local row = math.floor ((obj.y - self.voffset) / self.size + 0.5)
  local col = math.floor ((obj.x - self.hoffset) / self.size + 0.5)
  
  return self[row][col]
end

function Grid:getForce (obj)
  local row = math.floor ((obj.y - self.voffset) / self.size + 0.5)
  local col = math.floor ((obj.x - self.hoffset) / self.size + 0.5)
  
  if self[row]~= nil and self[row][col] ~= nil then
    return self[row][col].force
  else
    local x = col < 1 and 1 or (col > self.cols and -1 or 0)
    local y = row < 1 and 1 or (row > self.rows and -1 or 0)
    return {x = x, y = y}
  end
  
  if force.x == 0 and force.y == 0 then return force end
  
  local angle = Scrappy.Maths:angleBetweenVectorsTrue({x = 1, y = 0}, force)
  angle = angle + Scrappy.Random:inRange(-45, 45)
  local nforce = Scrappy.Maths:vectorFromAngle(angle)
  return nforce
  
end


function Grid:getNeighbour (node, direction)
  local row, col = node.row, node.col
  if direction == "up" and row > 1 and self[row][col].horizontal == nil then
    return self[row - 1][col]
  end
  if direction == "down" and row < self.rows and self[row + 1][col].horizontal == nil then
    return self[row + 1][col]
  end
  if direction == "left" and col > 1 and self[row][col].vertical == nil then
    return self[row][col - 1]
  end
  if direction == "right" and col < self.cols and self[row][col + 1].vertical == nil then
    return self[row][col + 1]
  end
  
  return nil
end

function Grid:build(kwargs)
  Scrappy.Random:seed(kwargs.seed ~= nil and kwargs.seed or os.time())
  
  --TMP -- add base
  local row = Scrappy.Random:inRange(math.floor(0.5 * self.rows), self.rows - 3)
  local col = Scrappy.Random:inRange(math.floor(0.2 * self.cols), math.floor(0.8 * self.cols))
  local pos = self.toPosition({row = row, col = col})
  
  local base = Base.new{x = pos.x, y = pos.y, size = self.size, row = row, col = col, level = 1}
  
  base.node = self[row][col]
  
  self.base = base.node
  --local base = display.newImageRect(self.group, "assets/images/base.png", self.size, self.size)
  --base.row = Scrappy.Random:inRange(math.floor(0.5 * self.rows), self.rows - 3)
  --base.col = Scrappy.Random:inRange(math.floor(0.2 * self.cols), math.floor(0.8 * self.cols))
  --base.pos = self:toPosition(base)
  --base.x = base.pos.x
  --base.y = base.pos.y
  --base.node = self[base.row][base.col]
  --self.base = base
  
  --generate random chains of barriers
  for run = 1, kwargs.runs do
    
    --random start position, direction and length
    local row = Scrappy.Random:inRange(2, self.rows - 2)
    local col = Scrappy.Random:inRange(2, self.cols - 2)
    local direction = Scrappy.Random:inRange(2, col - 2) < self.rows and "vertical" or "horizontal"
    
    local length = Scrappy.Random:inRange(1, kwargs.maxLength)
    
    --build chain
    for l = 1, length do 
      self[row][col]:flipBarrier(direction)
      
      if direction == "vertical" then
        row = row + 1
      else
        col = col + 1
      end
      
      --consider and change direction
      if Scrappy.Random:inRange(1,100) > 10 then 
        direction = Scrappy.Random:coinFlip() and "vertical" or "horizontal"
      end
      
      --stop chain at edge of grid
      if row > self.rows - 2 or col > self.cols - 2 then
        break
      end
      
      
    end
  end
end

return Grid