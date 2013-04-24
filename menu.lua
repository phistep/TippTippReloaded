local game = require 'game'

local menu = {}

function menu:draw()
	love.graphics.setColor(255, 255, 255)

	love.graphics.setNewFont(30)
	love.graphics.print("Tipp Tipp Reloaded", 50, 25)

	love.graphics.setNewFont(14)
	love.graphics.printf(
[[
Hit the Böbbels™ using [A] [S] [D] (or [J] [K] [L] or [LEFT] [DOWN] [RIGHT]) and don't let them pass a whole circle!
[M] to toggle mute.
[N] to pause the game.
Press [Esc] in game to return to the menu.


Press any key to continue…
Press [Esc] to quit the game
]], 50, 100, love.graphics.getWidth() - 2 * 50)
end

function menu:keypressed(key)
	if key == "escape" then
		love.event.push('quit')
	else
		Gamestate.switch(game, self)
	end
end

return menu
