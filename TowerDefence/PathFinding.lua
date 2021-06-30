local PathFinding = {}

local debug = true

function PathFinding.search(start)
  -- reset any previous searches
  for row = 1, grid.rows do
    for col = 1, grid.cols do 
      grid[row][col].reached = false
    end
  end
  
  -- queue to store nodes reached and not processed yet
  local frontier = {}
  local startNode = grid[start.row][start.col]
  table.insert(frontier, startNode)
  startNode.reached = true
  startNode.distance = 0
  startNode.force = {x = 0, y = 0}
  
  directions = {"up", "left", "down", "right"}
  forces = {{ x = 0, y = 1}, {x = 1, y = 0}, {x = 0, y = -1}, {x = -1, y = 0}}
  while #frontier > 0 do
    local current = table.remove(frontier, 1)
    
    for k, direction in pairs(directions) do
      local neighbour = grid:getNeighbour(current, direction)
      if neighbour ~= nil and not neighbour.reached then
        neighbour.reached = true
        neighbour.from = directions[(k - 1 + 2)% 4 + 1]
        neighbour.force = forces[k]
        neighbour.distance = current.distance + 1
        neighbour:debug(neighbour.from)
        table.insert(frontier, neighbour)
        
      end
    end
    
  end
  
end

function PathFinding.isConnected(start)
  PathFinding.search (start)
  
  for row = 1, grid.rows do
    for col = 1, grid.cols do 
      if not grid[row][col].reached then 
        return false
      end
    end
  end
  return true
end

return PathFinding