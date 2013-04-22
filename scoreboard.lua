Scoreboard = {}
Scoreboard.__index = Scoreboard

function Scoreboard.create()
	local score = {}
	setmetatable(score, Scoreboard)

	score.score = 0
	score.multiplier = 1
	score.spree = 0

	return score
end

function Scoreboard:count_hit()
	local spree = self.spree
	local multiplier = self.multiplier
	self.score = self.score + multiplier
	spree = spree + 1
	if spree >= 5 and multiplier <= 16  then
		spree = 0
		multiplier = multiplier * 2
	end
	self.spree = spree
	self.multiplier = multiplier
end

function Scoreboard:count_miss()
	self.multiplier = 1
end

function Scoreboard:draw(x, y)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Score: " .. tostring(self.score), x, y)
	love.graphics.print("Multiplier: " .. tostring(self.multiplier) .. "x", x, y + 20)
end
