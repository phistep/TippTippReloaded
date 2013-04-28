Scoreboard = {}
Scoreboard.__index = Scoreboard

function Scoreboard.create()
	local score = {}
	setmetatable(score, Scoreboard)

	score.multiplier_step = 5
	score.special_multiplier = 32

	score.score = 0
	score.multiplier = 1
	score.spree = 0
	score.max_spree = 0
	score.special_activated = false

	return score
end

function Scoreboard:count_hit(game, bbl)
	local spree = self.spree
	local bonus = self.multiplier

	if self.special_activated then
		bonus = self.special_multiplier
	end

	local accuracy_multiplier = 1 - math.abs(game.controller[1].angle - bbl.angle) / game.hit_offset + 0.5
	local progress_multiplier = 1 - math.deg(game.controller[1].angle) / 360 + 0.5
	local delta_score = math.floor(10 * bonus * accuracy_multiplier * progress_multiplier + 0.5)
	self.score = self.score + delta_score
	spree = spree + 1

	if spree > self.max_spree then
		self.max_spree = spree
	end

	local multiplier = math.pow(2, math.floor(spree / self.multiplier_step))
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

function Scoreboard:set_special_activated(activated)
	self.special_activated = activated
end

function Scoreboard:get_score()
	return self.score
end

function Scoreboard:get_multiplier()
	if self.special_activated then
		return self.special_multiplier
	else
		return self.multiplier
	end
end

function Scoreboard:get_spree()
	return self.spree
end

function Scoreboard:get_max_spree()
	return self.max_spree
end
