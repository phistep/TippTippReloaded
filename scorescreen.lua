local scorescreen = {}

function scorescreen:init()
	self.body_font = love.graphics.newFont("assets/polentical_neon_bold.ttf", 28)
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
	love.graphics.setFont(self.body_font)
	love.graphics.print('Le Scores: '..self.score, love.graphics.getWidth()/2, love.graphics.getHeight()/2)
end

function scorescreen:keypressed(key)
	if key == "escape" then
		love.event.push('quit')
	else
		Gamestate.switch(self.menu)
	end
end

return scorescreen
