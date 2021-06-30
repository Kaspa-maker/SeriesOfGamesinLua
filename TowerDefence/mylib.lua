local mylib = {}

function mylib.getImageName( obj )    
    local imageName
    if obj.level ~= nil then 
        imageName = "assets/" .. obj.name .. "-" .. obj.type .. "-" .. obj.level .. ".png"
    elseif obj.type ~= nil then 
        imageName = "assets/" .. obj.name .. "-" .. obj.type .. ".png"
    elseif obj.name ~= nil then
        imageName = "assets/" .. obj.name .. ".png"
    end

    if imageName == nil then 
        print("ERROR (getImageName): with [" .. (obj.name or "nil") .. ", " .. (obj.type or "nil") .. ", " .. (obj.level or "nil") .."]")
    end

    return imageName
end

function mylib.getConfig( obj )    
    local config
    if obj.level ~= nil then 
        config = game[obj.name][obj.type][obj.level]
    elseif obj.type ~= nil then 
        config = game[obj.name][obj.type]
    elseif obj.name ~= nil then
        config = game[obj.name]
    end

    if config == nil then 
        print("ERROR (getConfig): with [" .. (obj.name or "nil") .. ", " .. (obj.type or "nil") .. ", " .. (obj.level or "nil") .."]")
    end

    return config
end

return mylib