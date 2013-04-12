Scoreboard = {}
Scoreboard.__index = Scoreboard

function Scoreboard.create()
	local score = {
		score = 0,
		multiplier = 1
	}
	setmetatable(score, Scoreboard)
	return score
end

function Scoreboard:add(points)
	self.score = self.score + self.multiplier * points
end

function Scoreboard:draw(x, y)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Score: " .. tostring(self.score), x, y)
end
