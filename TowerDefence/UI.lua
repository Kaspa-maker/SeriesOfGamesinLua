local UI = {}

local Tower = require("Tower")

local mt = { __index = UI}

function UI.new(kwargs)
    local self = setmetatable(kwargs,mt);

    -- construct ui
    self.frame = display.newGroup(kwargs.group)
    self.frame.x = display.contentCenterX
    self.frame.y = display.contentHeight

    local background = display.newRoundedRect(0, 0, display.contentWidth, kwargs.size, 12);
    background.strokeWidth = 3
    background:setFillColor(.1)
    background:setStrokeColor(.5)
    
    kwargs.frame:insert(background)
    local scale = .8

    self.towers = {}
    for k = 1 , #game.tower.types do 
        local type = game.tower.types[k]
        local tower = Tower.new {size = self.size, type = type, x = 70 * k, y = 0}
        self.frame:insert(tower)
        table.insert(self.towers, tower)
    end
    
    return self
end

return UI