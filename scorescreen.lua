local scorescreen = {}

function scorescreen:init()
	self.font_description = love.graphics.newFont("assets/polentical_neon_bold.ttf", 20)
	self.font_score = love.graphics.newFont("assets/polentical_neon_bold.ttf", 50)
	self.font_other = love.graphics.newFont("assets/polentical_neon_bold.ttf", 30)

	self.color_description = { r = 45, g = 45, b = 45}
	self.color_scoreboard = { r = 20, g = 128, b = 201}
end

function scorescreen:enter(previous, menu, score, multiplier, spree, max_spree, time)
	self.game = previous
	self.menu = menu
	self.score = score
	self.multiplier = multiplier
	self.spree = spree
	self.max_spree = max_spree
	self.time = time
end

function scorescreen:draw()
	love.graphics.setFont(self.font_description)
	love.graphics.setColor(self.color_description.r, self.color_description.g, self.color_description.b)
	love.graphics.printf("score:", 10, 20, love.graphics.getWidth() - 20, "center")
	love.graphics.printf("time played:", 10, 120, love.graphics.getWidth() - 20, "center")
	love.graphics.printf("best spree:", 10, 220, love.graphics.getWidth() - 20, "center")
--	love.graphics.printf("hit accuracy:", 10, 320, love.graphics.getWidth() - 20, "center")

	love.graphics.setColor(self.color_scoreboard.r, self.color_scoreboard.g, self.color_scoreboard.b)
	love.graphics.setFont(self.font_score)
	love.graphics.printf(self.score, 10, 40, love.graphics.getWidth() - 20, "center")
	love.graphics.setFont(self.font_other)
	love.graphics.printf(self.time.."s", 10, 140, love.graphics.getWidth() - 20, "center")
	love.graphics.printf(self.max_spree, 10, 240, love.graphics.getWidth() - 20, "center")
--	love.graphics.printf(self.accuracy.."%", 10, 340, love.graphics.getWidth() - 20, "center")

end

function scorescreen:keypressed(key)
	if key == "escape" then
		love.event.push('quit')
	else
		Gamestate.switch(self.menu)
	end
end

return scorescreen
