local rng = { }

-- simple (emphesis on simple) random number generator 
-- works like math.randomseend and math.random

-- using microsoft's setting for generator
rng.a = 214013
rng.c = 2531011
rng.m = 2147483648

rng.state = 42


rng.randomseed = function(new_seed)
    rng.state = (new_seed * rng.a + rng.c) % rng.m
end


rng.rand = function()
    rng.state = (rng.a * rng.state + rng.c) % rng.m
    return rng.state % 32768
end

rng.random = function(min, max)

    -- no arguments, returns a random number in the range [0, 1). That is, zero up to but excluding 1.
    if min == nil then 
        return rng.rand() / (32768)
    end 

    -- 1 argument, returns an integer in the range [1, n]. That is from 1 up to and including n.
    if max == nil then 
        max = min
        return 1 + math.floor(max* rng.rand() / 32768)
    end 

    -- 2 arguments, returns an integer in the range [n, u]. That is from n up to and including u.
    return min + (max-min) * rng.rand() / (32768-1)

end 


return rng