-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local widget = require("widget")
local rng = require("rng")

-- Your code here
local pieceSize = 190
local pieceDraw = pieceSize - 10
local grid = {}
local gridColCount = 4
local gridRowCount = 4
local emptyCol
local emptyRow
local newEmptyCol
local newEmptyRow
local counter = 0
local indexes = {}
local indexCount = 1
local shuffle
math.randomseed(os.time())

local function updateGrid()

    grid = {}
    indexes = {}
    for row = 1, gridRowCount do
      grid[row] = {}
      
      indexes[row] = {}
      for col = 1, gridColCount do
        grid[row][col] = col + ((row - 1) * gridColCount)
        
        indexes[row][col] = indexCount;
        indexCount = indexCount + 1
      end
    end
    
end


--x = col
--y = row
local function drawPieces()
  local index = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
  
    updateGrid()
    
    for row = 1, gridRowCount do
      for col = 1, gridColCount do
        local randomizer = math.floor(rng.random(1, #index))
        local r = index[randomizer]
        table.remove(index, r)
        if grid[row][col] ~= gridColCount * gridRowCount then
          
          rect = display.newRect((col - 0.5) * pieceSize, (row - 0) * pieceSize, pieceDraw, pieceDraw)
          rect:setFillColor(0, 0.3, 1)
          rect = indexCount + 1
          
          
          myText = display.newText(r,(col - 0.85) * pieceSize,(row - 0.35) * pieceSize, "", 32)
          
        end
      end
    end
    
    
end

local myButtonEventUp = function (event)
  for row = 1, gridRowCount do 
    for col = 1, gridColCount do
      if grid[row][col] == gridColCount * gridRowCount then
        emptyCol = col
        emptyRow = row     
      end
    end
  end
  
  if event.phase == "ended" then
    if grid[emptyRow - 1] then
      grid[emptyRow - 1][emptyCol], grid[emptyRow][emptyCol] = grid[emptyRow][emptyCol], grid[emptyRow - 1][emptyCol]
      
      rect = display.newRect((emptyCol - 0.5) * pieceSize, (emptyRow) * pieceSize, pieceDraw, pieceDraw)
      rect:setFillColor(0, 0.3, 1)
      myText = display.newText(grid[emptyRow][emptyCol],(emptyCol - 0.85) * pieceSize,(emptyRow - 0.35) * pieceSize, "", 32)
      
      rect1 = display.newRect((emptyCol - 0.5) * pieceSize, (emptyRow - 1) * pieceSize, pieceDraw, pieceDraw)
      rect1:setFillColor(0, 0, 0)
    end
  end
end

local myButtonUp = widget.newButton{
  id = "myTextButton",
  label = "DOWN",
  labelColor = { default = { 163, 25, 12 }, over = { 163, 25, 12} },
  fontSize = 50,
  left = 400,
  top = 50,
  emboss = false,
  strokeWidth = 5,
  cornerRadius = 0,
  onEvent = myButtonEventUp
}

local myButtonEventRight = function (event)
  for row = 1, gridRowCount do 
    for col = 1, gridColCount do
      if grid[row][col] == gridColCount * gridRowCount then
        emptyCol = col
        emptyRow = row     
      end
    end
  end
  
  if event.phase == "ended" then
    if grid[emptyRow][emptyCol - 1] then
    grid[emptyRow][emptyCol - 1], grid[emptyRow][emptyCol] = grid[emptyRow][emptyCol], grid[emptyRow][emptyCol - 1]
    
    rect = display.newRect((emptyCol - 0.5) * pieceSize, (emptyRow) * pieceSize, pieceDraw, pieceDraw)
    rect:setFillColor(0, 0.3, 1)
    myText = display.newText(grid[emptyRow][emptyCol],(emptyCol - 0.85) * pieceSize,(emptyRow - 0.35) * pieceSize, "", 32)
    
    rect1 = display.newRect((emptyCol - 1.5) * pieceSize, (emptyRow) * pieceSize, pieceDraw, pieceDraw)
    rect1:setFillColor(0, 0, 0)
    end
  end
end

local myButtonRight = widget.newButton{
  id = "myTextButton",
  label = "RIGHT",
  labelColor = { default = { 163, 25, 12 }, over = { 163, 25, 12} },
  fontSize = 50,
  left = 0,
  top = 50,
  emboss = false,
  strokeWidth = 5,
  cornerRadius = 0,
  onEvent = myButtonEventRight
}

local myButtonEventLeft = function (event)
  for row = 1, gridRowCount do 
    for col = 1, gridColCount do
      if grid[row][col] == gridColCount * gridRowCount then
        emptyCol = col
        emptyRow = row     
      end
    end
  end
  
  if event.phase == "ended" then
    if grid[emptyRow][emptyCol + 1] then
      
      grid[emptyRow][emptyCol + 1], grid[emptyRow][emptyCol] = grid[emptyRow][emptyCol], grid[emptyRow][emptyCol + 1]
      
      rect = display.newRect((emptyCol - 0.5) * pieceSize, (emptyRow) * pieceSize, pieceDraw, pieceDraw)
      rect:setFillColor(0, 0.3, 1)
      myText = display.newText(grid[emptyRow][emptyCol],(emptyCol - 0.85) * pieceSize,(emptyRow - 0.35) * pieceSize, "", 32)
      
      rect1 = display.newRect((emptyCol + 0.5) * pieceSize, (emptyRow) * pieceSize, pieceDraw, pieceDraw)
      rect1:setFillColor(0, 0, 0)
    end
  end
end

local myButtonLeft = widget.newButton{
  id = "myTextButton",
  label = "LEFT",
  labelColor = { default = { 163, 25, 12 }, over = { 163, 25, 12} },
  fontSize = 50,
  left = 200,
  top = 50,
  emboss = false,
  strokeWidth = 5,
  cornerRadius = 0,
  onEvent = myButtonEventLeft
}


local myButtonEventDown = function (event)
  for row = 1, gridRowCount do 
    for col = 1, gridColCount do
      if grid[row][col] == gridColCount * gridRowCount then
        emptyCol = col
        emptyRow = row     
      end
    end
  end
  
  if event.phase == "ended" then
    if grid[emptyRow + 1] then
      grid[emptyRow + 1][emptyCol], grid[emptyRow][emptyCol] = grid[emptyRow][emptyCol], grid[emptyRow + 1][emptyCol]
      
      rect = display.newRect((emptyCol - 0.5) * pieceSize, (emptyRow) * pieceSize, pieceDraw, pieceDraw)
      rect:setFillColor(0, 0.3, 1)
      myText = display.newText(grid[emptyRow][emptyCol],(emptyCol - 0.85) * pieceSize,(emptyRow - 0.35) * pieceSize, "", 32)
      
      rect1 = display.newRect((emptyCol - 0.5) * pieceSize, (emptyRow + 1) * pieceSize, pieceDraw, pieceDraw)
      rect1:setFillColor(0, 0, 0)
    end
  end
  
  
end

local myButtonDown = widget.newButton{
  id = "myTextButton",
  label = "UP",
  labelColor = { default = { 163, 25, 12 }, over = { 163, 25, 12} },
  fontSize = 50,
  left = 570,
  top = 50,
  emboss = false,
  strokeWidth = 5,
  cornerRadius = 0,
  onEvent = myButtonEventDown
}

local myButtonDisplay = widget.newButton{
  id = "myTextButton",
  label = "Press the buttons with directions to move pieces",
  labelColor = { default = { 163, 25, 12 }, over = { 163, 25, 12} },
  fontSize = 25,
  left = 100,
  top = 850,
  emboss = false,
  strokeWidth = 5,
  cornerRadius = 0,
  onEvent = myButtonEventDown
}


local function startLevel()
  drawPieces()
end


startLevel()

