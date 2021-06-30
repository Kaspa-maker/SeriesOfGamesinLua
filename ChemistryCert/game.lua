-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local composer = require("composer")
local scene = composer.newScene()
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

local level = {5,1,25,100}

local myMoves = {}
local moves
local timeRemaining
local timeRemainingTimer
local levelOver = false


local movesText = display.newText("", 20, 20, native.systemFont, 20)
local moveCount = 0
local timeRemainingText = display.newText("", display.contentWidth - 20, 20, native.systemFont, 20)
local undoText = display.newText("Undo", display.contentWidth - 300, 20, native.systemFont, 20)
local hintText = display.newText("Hint", display.contentWidth - 225, 20, native.systemFont, 20)
local resetText = display.newText("Reset", display.contentWidth - 150, 20, native.systemFont, 20)
local solveText = display.newText("Solve", display.contentWidth - 375, 20, native.systemFont, 20)


--[[local function computeScore()
  --compute a measure of hoe close to a sorted solution we are
  --this should always be increasing as we move towards solution
  
  local total = 0
  for each tube
    c = number of solved drops in tube
    total += 2^c
    
    return total
end--]]


--[[local solve(event)


  solution = {}
  
  local function dfs(depth, maxDepth)
    indent = ""; for k = 1, depth do indent = indent = indent.."\t"end
    
    if depth>maxDepth then
      return computeScore()
    end
    
    
    
    for each possible fromTube
      if fromTube is valid
        for each possible toTube
          if toTube is valid
            --make move
            --compute score recurssively
            --undo move
            --recore move that gave best score
          end
        end
      end
    end
  
  move = = {from = 1, to = 1, score = -1}
  
    
    for kFrom = 1, #tubes do
      local fromTube = tubes[kFrom]
      local drop = fromTube.drops[#fromTube.drops]
      if not isEmpty(fromTube) and not isSolved(fromTube) then
        for kTo = 1, #tubes do
          local toTube = tubes[kTo]
          if kFrom ~= kTo and isFull(toTube) and (drop.color = top color in toTube if toTube has drops) then
            --possible move, compute it value
            
            addDrop(removeDrop(fromTube), toTube)
            
            print(indent, kFrom, kTo, "...")
            score = dfs(depth + 1, maxDepth)
            print(indent, kFrom, kTo, score)
            
            addDrop(removeDrop(toTube), fromTube)
            
            if score>move.score then
              move = {from = kFrom, to = kTo, score = score}
            end
          end
        end
      else
        print(indent, kForm, ("solved" and isSolved()) or "empty")
      end
      
      if depth == 1 then 
        --output more
    end
    
    print(indent)
  end
  
  dfs(1, 3)
end--]]











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
    if isEmpty(tube) then return true end
    if isFull(tube) then 
      local firstDrop = tube.drops[1].color
      for i = 2, FULL, 1 do
        if firstDrop ~= tube.drops[i].color then return false end
      end
      return true
    end
    return false
end

local function isAllSolved()
    -- Are all tubes complete (or empty)
    for k, v in pairs(tubes) do
      if not isSolved(v) then return false end
    end
    return true
end 




local function addDrop(drop, tube, start, undo)
    local drops = tube.drops
    local x = tube.x
    local y = tube.y + tube.height/2 - 30 - #drops * 40
    
    
    transition.moveTo(drop,{x=x, y=y, time = 100})
    transition.moveTo(drop, {x=x, y=drop.y,time=100})
    transition.moveTo(drop, {x=x, y=y,time=100, delay=100})
   
    table.insert(drops, drop)
    
    if start ~= true and undo == false then
        newMove = {}
        newMove.type = "add"
        newMove.drop = drop
        newMove.tube = tube
        table.insert(myMoves, newMove)
    end
    
end

local function updateMoves(moveMode)
  
  if moveMode == "do" then
    moveCount = moveCount + 1
  elseif moveMode == "undo" then
    moveCount = moveCount - 0.5
  elseif moveMode == "reset" then
    moveCount = 0
  end
  movesText.text = "Move: " .. moveCount
end


local function removeDrop(tube, start, undo) 

    local drops = tube.drops
    
    if #drops == 0 then return nil end
    
    local drop = drops[#drops]
    table.remove(drops)
    drop.y = tube.y - tube.height/2 - 30

    if start ~= true and undo == false then
      removeMove = {}
      removeMove.type = "remove"
      removeMove.drop = drop
      removeMove.tube = tube
      table.insert(myMoves, removeMove)
    end
    return drop

end 


local function isValidMove(drop,tube)
  if isFull(tube) then return false end
  if isEmpty(tube) then return true end
  
  local drops = tube.drops
  return drops[#drops].color == drop.color
end


local function moveDrop( event ) 
  local tube = event.target

  if selectedDrop == nil and not isEmpty(tube) then
    selectedDrop = removeDrop(tube, false, false)
  elseif not isFull(tube) then
    local drops = tube.drops
    if isEmpty(tube) then
      addDrop(selectedDrop, tube, true, false)
      updateMoves("do")
      currentMove = {}
      currentMove.type = "add"
      currentMove.drop = selectedDrop
      currentMove.tube = tube
      currentMove.animate = true
      selectedDrop = nil
      table.insert(myMoves, currentMove)
    elseif not isEmpty(tube) then
      local colorA = drops[#drops].color
      local colorB = selectedDrop.color
      if colorA == colorB then
        addDrop(selectedDrop, tube, true, false)
        
        updateMoves("do")
        currentMove = {}
        currentMove.type = "add"
        currentMove.drop = selectedDrop
        currentMove.tube = tube
        currentMove.animate = true
        selectedDrop = nil
        table.insert(myMoves, currentMove)
        --table.insert(myMoves, moves)
      else
        print("wrong tube")
      end
    end
  end
  
  
  --table.insert(myMoves, moves.from)
  
  print()
  return true 
end

local function undoMove()
  lastMove = myMoves[#myMoves]
  
  for k,v in pairs(myMoves) do
    print(k..": "..v.type)
  end
  
  if lastMove.type ~= nil then 
    if lastMove.type == "remove" then
      addDrop(lastMove.drop, lastMove.tube, false, true)
      table.remove(myMoves)
      selectedDrop = nil
      print("undid remove")
      updateMoves("undo") 
      
    elseif lastMove.type == "add" then
      removeDrop(lastMove.tube, false, true)
      table.remove(myMoves)
      selectedDrop = lastMove.drop
      
      print("undid add")
      updateMoves("undo") 
    end
  end
  
  print("number of moves: " .. #myMoves)
end



local function updateTimeRemaining()
  timeRemaining = timeRemaining - 1
  
  timeRemainingText.text = "Time: " .. timeRemaining
end

function disposeGame()
    for k, v in pairs(tubes) do
        if not isEmpty(v) then
            for l, b in pairs(v.drops) do
                display.remove(b);
            end
        end
        v:removeEventListener("tap",moveDrop);
        display.remove(v);
    end
    
    updateMoves("reset")
    timer.cancel(timeRemainingTimer);
    tubes = {}
end

local function startLevel(level)
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
          
          addDrop(drop, tube, true, false)
          
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
    --
    
    timeRemaining = duration + 1
    updateTimeRemaining()
    updateMoves()
    
    timeRemainingTimer = timer.performWithDelay(1000, updateTimeRemaining, duration)
end

local function goToReset(event)
    disposeGame()
    startLevel(level)
end

function scene: create(event)
    local sceneGroup = self.view
    local background = display.newImageRect(sceneGroup, "assets/background.jpg", 800, 1400)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end

resetText:addEventListener("tap", goToReset)
undoText:addEventListener("touch", undoMove)
--[[hintText:addEventListener("tap", hint)

solveText:addEventListener("tap", solve)
scene:addEventListener( "show", scene )
scene:addEventListener( "create", scene )]]--
startLevel(level)

return scene