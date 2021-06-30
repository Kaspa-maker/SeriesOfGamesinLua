-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
rng = require("rng")

local size = 64
local rows = math.floor(display.contentHeight / size)
local cols = math.floor(display.contentWidth / size)
local voffset = (display.contentHeight - rows * size) / 2
local hoffset = (display.contentWidth - cols * size) / 2
local grid = {}
local gameOver = false
local firstTap = true
local touchDelay = 600
local eventBegin = nil


local gameSheetOption = {frames = {}}
for row = 1, 2 do 
  for col = 1, 8 do
    table.insert(gameSheetOption.frames, {x=1 + (col-1)*18, y=1 + (row - 1) * 18, width=18, height=18})
  end
end
local gameSheet = graphics.newImageSheet("assets/tiles_transparent.png", gameSheetOption)

local tiles = { covered = 1, covered_high_lighted = 2, uncovered = 3, flower = 4, flag = 5, question = 6, blank = 7, n_1 = 9, n_2 = 10, n_3 = 11, n_4 = 12, n_5 = 13, n_6 = 14, n_7 = 15, n_8 = 16 }

local directions = {}
for dy = -1, 1 do
  for dx = -1, 1 do
    if not (dy == 0 and dx == 0) then
      table.insert(directions, {dx = dx, dy = dy})
    end
  end
end


local setTile = function(row, col, level,tileName)
  
  assert(level == "lower" or level == "upper", "Unexpected value for level: ".. level)
  local cell = grid[row][col]
  
  if cell[level] ~= nil then
    display.remove(cell[level])
    cell[level] = nil
  end
  
  if tileName~= nil then
  local tile = display.newImageRect(gameSheet, tiles[tileName], size, size)
  tile.x = hoffset + (col-0.5) * size
  tile.y = voffset + (row-0.5) * size
  
  cell[level] = tile
end
  
end



local updateGrid = function()
  for row = 1, rows do
    for col = 1, cols do
      local flowerCount = 0
      for _, v in pairs(directions) do 
        if grid[row + v.dy] and grid[row + v.dy][col + v.dx] and grid[row + v.dy][col + v.dx].flower then
          flowerCount = flowerCount + 1
        end
      end
      
      grid[row][col].neighbors = flowerCount
      
      if not grid[row][col].flower then 
        if grid[row][col].neighbors > 0 then
          if grid[row][col].state == "uncovered" then
            setTile(row, col, "upper", "n_" .. grid[row][col].neighbors)
          end
        
        else
          setTile(row, col, "upper")
        end
      end
    end
  end
  
end




local resetLevel = function ()
  print("creating grid with " .. rows .. " rows and " .. cols .. " cols" )
  
  grid = {}
  for row = 1, rows do
    grid[row] = {}
    for col = 1, cols do
      grid[row][col] = {lower = nil, upper = nil, flower=false, neighbors = 0, state = nil}
      setTile(row, col, "lower","covered")
      grid[row][col].state = "covered"
    end
  end

  firstTap = true
end

resetLevel()

local function placeFlowers(firstRow, firstCol)
  local flowerCount = 0
  while flowerCount < 20 do
    local row = rng.random(rows)
    local col = rng.random(cols)
    if grid[row][col].flower == false and (firstRow ~= row or firstCol ~= col)then
      --setTile(row, col, "upper", "flower")
      grid[row][col].flower = true
      flowerCount = flowerCount + 1 
    end
  end
  
end


local function onTap(row, col)

  
  --first tap
  if firstTap then
    placeFlowers(row, col)
    updateGrid()
    firstTap = false
  end
  
  --test if flag 
  if grid[row][col].state == "flag" then 
    return
  end
  
  
  --test game over
  if grid[row][col].flower then 
    gameOver = true
    
    for r = 1, rows do
      for c = 1, cols do
        if grid[r][c].flower then
          setTile(r, c, "upper", "flower")
        end
      end
    end
    return
  end
  
  --flood fill
  local stack = {{ row=row, col=col}}
  local count = 0
  print ("flood fill")
  while #stack > 0 do 
    count = count + 1
    if count > 100 then break end
    
    local current = table.remove(stack)
    print ("...", current.row, current.col)
    
    if grid[current.row][current.col].state == "covered" then 
      grid[current.row][current.col].state = "uncovered"
      setTile(current.row, current.col, "lower", "uncovered")
      
    end
    if grid[current.row][current.col].neighbors == 0 then
      for _,v in pairs(directions) do 
        if grid[current.row + v.dy] and grid[current.row + v.dy][current.col + v.dx] then
            local cell = grid[current.row + v.dy][current.col + v.dx]
            print(" ", "...",current.col + v.dx, current.row + v.dy)
          if cell.state == "covered" and not cell.flower then 
            table.insert(stack, {row = current.row + v.dy, col = current.col + v.dx})
          end
        
        end
      end
      
    end
    
  end
  
  
  updateGrid()
end


local function nextState()
  local cell = grid[eventBegin.row][eventBegin.col]
  
  if cell.state == "covered" then
    setTile(eventBegin.row, eventBegin.col, "upper", "flag")
    cell.state = "flag"
  elseif cell.state == "flag" then
    setTile(eventBegin.row, eventBegin.col, "upper", "question")
    cell.state = "question"
  elseif cell.state == "question" then
    setTile(eventBegin.row, eventBegin.col, "upper")
    cell.state = "covered"
  else
    assert(0 , "we should not be here")
  end
  
end




local function onTouch(event)
  
  if gameOver then
    return
  end
  
  local col = math.floor( (event.x - hoffset) / size ) + 1
  local row = math.floor( (event.y - voffset) / size ) + 1
  
  if col < 1 or col > cols or row < 1 or row > rows then return end
  
  print("Event tap at row " .. row .. " and col " .. col .. " ")
  
  if(event.phase == "began") then
    print("Event begin at row " .. row .. " and col ".. col)
    assert(eventBegin == nil, "Appear to be in the middle of a touch")
    eventBegin = event
    eventBegin.row = row
    eventBegin.col = col
    
    eventBegin.callback = timer.performWithDelay(touchDelay, nextState, 0)
  elseif(event.phase == "ended") then
    print("Event ended at row " .. row .. " and col ".. col)
    
    if event.time - eventBegin.time < touchDelay and row == eventBegin.row and col == eventBegin.col then 
      onTap(row, col)
      timer.cancel(eventBegin.callback)
    end
    timer.cancel(eventBegin.callback)
    eventBegin = nil
    
  end
  
  
end

Runtime:addEventListener("touch", onTouch)