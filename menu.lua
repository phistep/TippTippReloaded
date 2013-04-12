local game = require 'game'

local menu = {}

function menu:draw()
	love.graphics.setColor(255, 255, 255)

	love.graphics.setFont(love.graphics.newFont(30))
	love.graphics.print("Tipp Tipp Reloaded", 50, 25)

	love.graphics.setFont(love.graphics.newFont(14))
	love.graphics.print("Hit the Böbbels™ using [A] [S] [D] and don't let them pass a whole circle!\nPress [Esc] in game to return to the menu.", 50, 100)
	love.graphics.print("Press any key to continue…", 50, 200)
	love.graphics.print("Press [Esc] to quit the game", 50, 220)
end

function menu:keypressed(key)
	if key == "escape" then
		love.event.push('quit')
	else
		Gamestate.switch(game, self)
	end
end

return menu