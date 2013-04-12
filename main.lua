Gamestate = require 'hump.gamestate'

local game = require 'game'

function love.load()
	Gamestate.registerEvents()
	Gamestate.switch(game)
end
