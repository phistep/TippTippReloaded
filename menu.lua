require 'menugame'
local game = require 'game'

local menu = {}

function menu:init()
	self.title_font = love.graphics.newFont(30)
	self.body_font = love.graphics.newFont(14)

	local xgame = love.graphics.getWidth()
	local ygame = love.graphics.getHeight() / 2 + 30
	local startgame = math.rad(0)
	local stopgame = math.rad(180)
	local rgame = nil --150
	self.menugame = Menugame.create(xgame, ygame, startgame, stopgame, rgame)
end

function menu:draw()
	self.menugame:draw()

	love.graphics.setColor(255, 255, 255)

	love.graphics.setFont(self.title_font)
	love.graphics.print("Tipp Tipp Reloaded", 50, 25)

	love.graphics.setFont(self.body_font)
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

function menu:update(dt)
	self.menugame:update(dt)
end

function menu:keypressed(key)
	if key == "escape" then
		love.event.push('quit')
	else
		Gamestate.switch(game, self)
	end
end

return menu
