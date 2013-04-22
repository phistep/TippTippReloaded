Scoreboard = {}
Scoreboard.__index = Scoreboard

function Scoreboard.create()
	local score = {}
	setmetatable(score, Scoreboard)

	score.score = 0
	score.multiplier = 1
	score.spree = 0
	score.max_spree = 0

	return score
end

function Scoreboard:count_hit()
	local spree = self.spree
	local multiplier = self.multiplier
	self.score = self.score + multiplier
	spree = spree + 1

	if spree > self.max_spree then
		self.max_spree = spree
	end

	multiplier = math.pow(2, math.floor(spree / 5))
	if multiplier > 16 then
		multiplier = 16
	end

	self.spree = spree
	self.multiplier = multiplier
end

function Scoreboard:count_miss()
	self.multiplier = 1
	self.spree = 0
end

function Scoreboard:draw(x, y)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Score: " .. tostring(self.score), x, y)
	love.graphics.print("Multiplier: " .. tostring(self.multiplier) .. "x", x, y + 20)
	love.graphics.print("Longest Spree: " .. tostring(self.max_spree) .. "x", x, y + 40)
end
