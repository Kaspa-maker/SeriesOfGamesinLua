local mylib = require("mylib")

local Tower = {}

function Tower.new( kwargs )    
    kwargs.name = kwargs.name or "tower"
    kwargs.type = kwargs.type or "purple"
    kwargs.level = kwargs.level or 1
    local config = mylib.getConfig(kwargs)

    local scale = .8    
    local self = display.newImageRect(mylib.getImageName(kwargs), kwargs.size * scale, kwargs.size * scale);
    self.x = kwargs.x
    self.y = kwargs.y    

    self.size = kwargs.size
    physics.addBody(self, {isSensor = true})
    self.angularDamping = 100

    self.fireDelay = config.fireDelay
    self.timeToFire = self.fireDelay

    self.name = kwargs.name
    self.type = kwargs.type
    self.level = kwargs.level

    return self

end

-- Function pickUp
-- When picked up (from ui) create the tower and run this. Make it a loop (?) and update position to mouse event. Same as enemy in main loop?

-- Function putDown
-- Stop the pickUp update loop and check if mouse on/near node. If no, just delete tower. If yes, place it on that node. More later

local eventBegan = nil
function Tower:onSwipe(event)        

    -- local col = math.floor((event.x - horOffset) / size) + 1
    -- local row = math.floor((event.y - vertOffset) / size) + 1
    -- if col < 1 or col > 4 or row < 1 or row > 4 then
    --     return
    -- end    

    if ( event.phase == "began" ) then         
        assert (eventBegan==nil, "Appear to be in the middle of a touch")        

    elseif ( event.phase == "ended" ) then 
        
        eventBegan = nil
    end    

end

return Tower