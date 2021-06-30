--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

application =
{
	content =
	{
		width = 768,
		height = 1024, 
		scale = "letterbox",
		fps = 60,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	},
}

game = {
  enemy = {
    types = {"white", "yellow"},
    white = {},
    yellow = {}
  },
  base = {
    types = {"orange"},
    orange = {}
  },
  projectile = {
    types = {"green", "blue", "purple"},
    green = {scale = 0.4},
    blue = {scale = 0.7},
    purple = {scale = 0.9}
  },
  tower = {
    types = {"green", "blue", "purple"},
    green = {
      {cost = 100, fireDelay = 1},
      {cost = 200, fireDelay = 1},
      {cost = 400, fireDelay = 1},
    },
    blue = {
      {cost = 200, fireDelay = 0.75},
      {cost = 400, fireDelay = 0.75},
      {cost = 800, fireDelay = 0.75},
    },
    purple = {
      {cost = 1000, fireDelay = 0.5},
      {cost = 2000, fireDelay = 0.5},
      {cost = 4000, fireDelay = 0.5},
      },
    }
  }