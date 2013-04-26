require 'menugame'
local game = require 'game'

local menu = {}

function menu:init()
	self.title_font = love.graphics.newFont("assets/polentical_neon_bold.ttf", 70)
	self.subtitle_font = love.graphics.newFont("assets/polentical_neon_bold_italic.ttf", 40)
	self.body_font = love.graphics.newFont("assets/polentical_neon_bold.ttf", 16)
	self.credits_font = love.graphics.newFont(8)

	local xgame = love.graphics.getWidth()
	local ygame = love.graphics.getHeight() / 2
	local startgame = math.rad(0)
	local stopgame = math.rad(180)
	local rgame = 280
	self.menugame = Menugame.create(xgame, ygame, startgame, stopgame, rgame)
end

function menu:draw()
	self.menugame:draw()

	love.graphics.setColor(255, 255, 255)

	love.graphics.setFont(self.title_font)
	love.graphics.print("TippTipp", 20, 0)

	love.graphics.setFont(self.subtitle_font)
	love.graphics.print("Reloaded", 215, 65)

	love.graphics.setFont(self.body_font)
	love.graphics.printf(
[[
Hit the Böbbels™ using

[A] [S] [D] or
[J] [K] [L] or
[LEFT] [DOWN] [RIGHT]

Don't let them pass a whole circle!

[M] to toggle mute.
[N] to pause the game.
[B] to toggle debug information.
Press [Esc] in game to return to the menu.


Press any key to continue…
Press [Esc] to quit the game
]], 40, 140, love.graphics.getWidth() - 2 * 50)

	love.graphics.setFont(self.credits_font)
	love.graphics.print("Font: 'Polentical Neon' by Jayvee D. Enaguas (Grand Chaos), CC-BY-SA", 5, love.graphics.getHeight()-10)

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
