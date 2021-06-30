-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
require("Scrappy.maths")
require("Scrappy.random")
local Grid = require("Grid")
local Enemy = require("Enemy")
local Projectile = require("Projectile")
Scrappy.Random:seed( 42 ) 
local UI = require("UI")
local Tower = require("Tower")

physics = require("physics")
physics.start()
physics.setGravity(0,0)
--physics.setDrawMode("hybrid")

display.setStatusBar(display.HiddentStatusBar)

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

grid = Grid:new {size = 64, group = mainGroup}

grid:build { seed = 50, runs = 20, maxLength = 20}

--TMP -- add enemy
enemies = {}
for k = 1, 10 do 
  local enemy = Enemy:new {row = 1, col = Scrappy.Random:inRange(1, grid.cols - 1)}
  table.insert(enemies, enemy)
end

local towers = {}
table.insert(towers, Tower.new{size = grid.size, x = grid[6][8].x, y  = grid[6][8].y})
table.insert(towers, Tower.new{size = grid.size, x = grid[10][6].x, y  = grid[10][6].y})
local projectiles = {}

function getEventPosition(event, tol)
  tol = tol or 0.2
  local pos = {}
  
  pos.x = (event.x - grid.hoffset) / grid.size + 0.5
  pos.y = (event.y - grid.voffset) / grid.size + 0.5
  
  pos.row = math.floor(pos.y)
  pos.col = math.floor(pos.x)
  
  pos.isHorizontal = math.abs(pos.y - math.floor(pos.y + 0.5)) < tol
  pos.isVertical = math.abs(pos.x - math.floor(pos.x + 0.5)) < tol
  
  pos.isNode = pos.isHorizontal and pos.isVertical
  pos.isSide = (pos.isHorizontal ~= pos.isVertical) and (pos.isHorizontal or pos.isVertical)
  
  return pos
end



function flipBarrier(event)
  local pos = getEventPosition(event)
  
  if not pos.isSide then
    return
  end
  
  
  if pos.isVertical then
    pos.col = math.floor(pos.x + 0.5)
    if pos.col < grid.cols then
      grid[pos.row][pos.col]:flipBarrier("vertical")
    end
  else
    pos.row = math.floor(pos.y + 0.5)
    if pos.row < grid.rows then
      grid[pos.row][pos.col]:flipBarrier("horizontal")
    end
  end
  
  
end

ui = UI:new {group = uiGroup, size = grid.size}

Runtime:addEventListener("tap", flipBarrier)

local previousEvent = nil

local function getNearestEnemy(me)
  local minDistSq
  local minEnemy = nil
  
  for n = 1, #enemies do 
    local enemy = enemies[n]
    local distSq = Scrappy.Maths:distanceBetweenVectorsSquared(me, enemy) / (grid.size * grid.size)
    if minEnemy == nil or distSq < minDistSq then
      minDistSq = distSq
      minEnemy = enemy
    end
    
  end
  return minEnemy
end


function gameLoop (event)
  local dt = 0.01
  if previousEvent ~= nil then
    dt = (event.time - previousEvent.time) / 1000
  end
  dt = math.min(0.01, dt)
  
  
  --local node = grid:getNodeFromCoordinates(enemy)
  local speed = 0.01
  for key, value in pairs(enemies) do 
    local node = grid:getNodeFromCoordinates(value)
    local force = grid:getForce(value)
    value:applyLinearImpulse(speed * force.x * dt, speed * force.y * dt, value.x, value.y)
    
  end
  
  
  
  for k = 1, #towers do
    local tower = towers[k]
    local enemy = getNearestEnemy(tower)
    if enemy ~= nil then
      local angle = Scrappy.Maths:angleBetweenVectors(tower, enemy)
      tower:applyTorque(Scrappy.Maths:clamp(angle - tower.rotation, -1, 1))
      
      tower.timeToFire = tower.timeToFire - dt
      if tower.timeToFire < 0 then
        local projectile = Projectile.new{size = grid.size, x = tower.x, y = tower.y}
        physics.addBody(projectile)
        local force = Scrappy.Maths:vectorFromAngle(angle)
        projectile:rotate(angle + 180)
        local speed = 0.8
        projectile:applyLinearImpulse(speed * force.x * dt, speed * force.y * dt, projectile.x, projectile.y)
        table.insert(projectiles, projectile)
        tower.timeToFire = tower.fireDelay
      end
      
    end
    
  end
  for k = #projectiles, 1, -1 do
    local projectile = projectiles[k]
    if projectile.x < 0 or projectile.x > display.contentWidth or projectile.y < 0 or projectile.y < display.contentHeight or projectile.dead then 
      physics.removeBody(projectile)
      projectile:removeSelf()
      table.remove(projectiles, k)
      projectile = nil
    end
    
  end
  
  --previousEvent = event
end

Runtime:addEventListener("enterFrame", gameLoop)


local function dragObject(event)
  
  local target = event.target
  
  if event.phase == "began" then
    target.xMark = target.x
    target.yMark = target.y
    display.getCurrentStage():setFocus(event.target)
  elseif event.phase == "moved" then
    local x = (event.x - event.xStart) + target.xMark
    local y = (event.y - event.yStart) + target.yMark
    
    target.x, target.y = x, y
  elseif event.phase == "cancelled" then 
    target.x, target.y = target.xMark, target.yMark
    display.getCurrentStage():setFocus(nil)
    
  elseif event.phase == "ended" then
    local pos = getEventPosition(event)
    if pos.isNode then
      local node = grid[pos.row][pos.col]
      node.tower = Tower.new {size = grid.size, x = node.x, y = node.y}
      
      table.insert(towers, node.tower)
    end
    display.getCurrentStage():setFocus(nil)
    target.x, target.y = target.xMark, target.yMark
    end
  end

ui.tower:addEventListener("touch", dragObject)

for k = 1, #ui.towers do
  ui.towers[k]:addEventListener("touch", dragObject)
end

