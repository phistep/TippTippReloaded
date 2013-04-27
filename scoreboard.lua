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

function Scoreboard:count_hit(game, bbl)
	local spree = self.spree
	local multiplier = self.multiplier
	local accuracy_multiplier = 1 - math.abs(game.controller[1].angle - bbl.angle) / game.hit_offset + 0.5
	local progress_multiplier = 1 - math.deg(game.controller[1].angle) / 360 + 0.5
	local delta_score = math.floor(10 * multiplier * accuracy_multiplier * progress_multiplier + 0.5)
	self.score = self.score + delta_score
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

function Scoreboard:get_score()
	return self.score
end

function Scoreboard:get_multiplier()
	return self.multiplier
end

function Scoreboard:get_spree()
	return self.spree
end

function Scoreboard:get_max_spree()
	return self.max_spree
end
