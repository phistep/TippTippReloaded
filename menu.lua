local game = require 'game'

local menu = {}

function menu:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Press any key to continue…", 100, 100)
end

function menu:keypressed()
	Gamestate.switch(game)
end

return menu
