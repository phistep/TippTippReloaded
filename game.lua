require 'bobbel'

local game = {
	bobbel_radius = 15,
	field_radius = 200,
	center = { x = 300, y = 300 },
	angular_velocity = math.pi/4,
	track_distance = 25,
	total_time = 0,
	time_between_bobbels = 0.95,
	bobbel_canvas = nil,
	bobbels = {}
}

local bobbels = {}

function game:init()
	-- create global bobbel canvas
	self.bobbel_canvas = love.graphics.newCanvas(2 * self.bobbel_radius, 2 * self.bobbel_radius)
	love.graphics.setCanvas(self.bobbel_canvas)
	love.graphics.setColor(10, 255, 0)
	love.graphics.setLineWidth(3)
	love.graphics.circle("line", self.bobbel_radius, self.bobbel_radius, self.bobbel_radius-5, 20)

	-- window settings
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(10, 10, 10)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(1)
end


function game:draw()
	love.graphics.setCanvas()

	love.graphics.setColor(255, 20, 0)
	love.graphics.setLineWidth(2)
	love.graphics.circle("line", self.center.x, self.center.y, self.field_radius)
	love.graphics.circle("line", self.center.x, self.center.y, self.field_radius - self.track_distance)
	love.graphics.circle("line", self.center.x, self.center.y, self.field_radius - 2*self.track_distance)

	love.graphics.setColor(255, 255, 255)
	for _, bbl in pairs(bobbels) do
		bbl:draw(self)
	end

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function game:update(dt)
	self.total_time = self.total_time + dt
	if self.total_time >= self.time_between_bobbels then
		table.insert(bobbels, Bobbel.create(0, math.random(0, 2)))
	end
	self.total_time = self.total_time % self.time_between_bobbels

	for _, bbl in pairs(bobbels) do
		bbl:update(self, dt)
	end
end

return game
