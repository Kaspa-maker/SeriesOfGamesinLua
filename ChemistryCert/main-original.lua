-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local rng = require("rng")

local FULL = 4  -- number of drops to full a tube

local tubes = { }
local selectedDrop

local colorsRGB = require("colorsRGB")
local colors = {
    "snow",
    "steelblue",
    "rosybrown",
    "orchid",
    "wheat",
    "thistle",
    "teal"
}

local level = {3,2,5,100}

local moves
local timeRemaining
local timeRemainingTimer
local levelOver = false

local movesText = display.newText("", 20, 20, native.systemFont, 20)
local timeRemainingText = display.newText("", display.contentWidth - 20, 20, native.systemFont, 20)
local undo = display.newText("Undo", display.contentWidth - 300, 20, native.systemFont, 20)
local hint = display.newText("Hint", display.contentWidth - 225, 20, native.systemFont, 20)
local reset = display.newText("Reset", display.contentWidth - 150, 20, native.systemFont, 20)

local function isEmpty(tube) 
    -- Empty tube = has no drops
    return #tube.drops == 0
end 

local function isFull(tube) 
    -- Full tube = has FULL drops
    return #tube.drops == FULL
end

local function isSolved(tube)
    --- complete = is full AND all drops have the same color 
end

local function isAllSolved()
    -- Are all tubes complete (or empty)
end 

local function addDrop(drop, tube, animate)
    local drops = tube.drops
    local x = tube.x
    local y = tube.y + tube.height/2 - 30 - #drops * 40
    
    if animate then
      transition.moveTo(drop,{x=x, y=y, time = 100})
      
    else
      drop.x = x
      drop.y = y
    end
    table.insert(drops, drop)
end


local function removeDrop(tube, animate) 

    local drops = tube.drops
    
    if #drops == 0 then return nil end
    
    local drop = drops[#drops]
    table.remove(drops)
    drop.y = tube.y - tube.height/2 - 30

    return drop

end 

local function isValidMove(drop,tube)
  if isFull(tube) then return false end
  if isEmpty(tube) then return true end
  
  local drops = tube.drops
  return drops[#drops].color == drop.color
end



local function moveDrop( event ) 
  
  return true -- Prevents touch propagation to underlying objects
    -- if selectedDrop is nil then 
       -- remove drop from selected tubeand save it to selectedDrop
    -- 
       -- place selectedDrop to selected tube if allowed
       -- upate moves count

    -- if game is solved
       -- stop counddown clock
end

local function updateTimeRemaining()
  timeRemaining = timeRemaining - 1
  
  timeRemainingText.text = "Time: " .. timeRemaining
end


local function startLevel(level)
    -- create level with given parameters

    -- number of colors, number of spare tubes, level difficulty and duration
    local nColors, nSwap, nDifficulty, duration = unpack(level)
    local nTubes = nColors + nSwap


    -- instaniate all of the tubes
    for k = 1, nTubes do
      tube = display.newImageRect("assets/tube.png", 70, 197)
      tube.x = display.contentCenterX + (k-0.5 - nTubes/2)*80
      tube.y = display.contentHeight - tube.height/2 - 20
      tube.drops = {}
      tube:addEventListener("tap", moveDrop)
      table.insert(tubes, tube)
      
      if k <= nColors then
        for d = 1, FULL do
          drop = display.newCircle(tube.x, tube.y, 15)
          drop.color = colors[k]
          drop:setFillColor(colorsRGB.RGB(drop.color))
          
          addDrop(drop, tube)
        end
        
      end
      
    end
    
    seq = {}
    rng.randomseed(42) 
    for k=1, 10 do table.insert( seq,rng.random(6) ) end
    print ( table.concat( seq," " ) )


    rng.randomseed(42)

    -- using nDifficulty randomise the starting position
    for k = 1, nDifficulty do 
      local fromTube = tubes[rng.random(#tubes)]
      local toTube = tubes[rng.random(#tubes)]
      
      if fromTube ~= toTube and not isEmpty(fromTube) and not isFull(toTube) then
        drop = removeDrop(fromTube)
        addDrop(drop, toTube)
      end
    end


    -- initialise game variables (moves, etc)
    display.setStatusBar(display.HiddentStatusBar)
    moves = 0
    movesText.text = "Moves: " .. moves
    
    timeRemaining = duration + 1
    updateTimeRemaining()
    
    timeRemainingTimer = timer.performWithDelay(1000, updateTimeRemaining, duration)


end

startLevel(level)