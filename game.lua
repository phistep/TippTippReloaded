require 'bobbel'
require 'scoreboard'

local game = {
	bobbel_radius = 15,
	field_radius = 200,
	center = { x = 300, y = 300 },
	angular_velocity = 65 /180*math.pi,
	track_distance = 25,
	total_time = 0,
	time_between_bobbels = 0.35,
	hit_offset = 5 /180*math.pi,
	bobbel_canvas = nil,
	bobbels = {},
	controller = {Bobbel.create(1.5*math.pi, 0), Bobbel.create(1.5*math.pi, 1), Bobbel.create(1.5*math.pi, 2)},
	score = Scoreboard.create(),
}

function game:init()

	-- create global bobbel canvas
	self.bobbel_canvas = love.graphics.newCanvas(2 * self.bobbel_radius, 2 * self.bobbel_radius)
	love.graphics.setCanvas(self.bobbel_canvas)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(3)
	love.graphics.circle("line", self.bobbel_radius, self.bobbel_radius, self.bobbel_radius-5, 20)

	-- create controller bobbels
	for _, cont in ipairs(self.controller) do
		cont.pressed = false
	end
	self.controller[1].key = 'd'
	self.controller[2].key = 's'
	self.controller[3].key = 'a'


	-- window settings
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(10, 10, 10)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(1)
end

function game:enter(game_menu)
	self.menu = game_menu
end

function game:draw()
	love.graphics.setCanvas()

	love.graphics.setColor(100, 100, 100)
	love.graphics.setLineWidth(2)
	love.graphics.circle("line", self.center.x, self.center.y, self.field_radius)
	love.graphics.circle("line", self.center.x, self.center.y, self.field_radius - self.track_distance)
	love.graphics.circle("line", self.center.x, self.center.y, self.field_radius - 2*self.track_distance)

	love.graphics.setColor(0, 255, 0)
	for _, bbl in pairs(self.bobbels) do
		bbl:draw(self)
	end

	for _, cont in ipairs(self.controller) do
		if cont.pressed then
			love.graphics.setColor(4, 215, 243)
		else
			love.graphics.setColor(100, 100, 100)
		end
		cont:draw(self)
	end

	for i=20, 0, -1 do
		love.graphics.setColor(10, 10, 10, 255/5)
		love.graphics.arc("fill", self.center.x, self.center.y, self.field_radius*1.25, (90-i)/180*math.pi, (90+i)/180*math.pi, 100)
	end

	love.graphics.setColor(23, 200, 255)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	self.score:draw(10, 30)
end

function game:update(dt)
	-- Updating bobbels
	for _, bbl in pairs(self.bobbels) do
		bbl:update(self, dt)
	end

	-- Spawning new bobbels
	self:spawn_bobbel(dt)

	-- Removing bobbels
	self:terminate_bobbel()
end

function game:spawn_bobbel(dt)
	self.total_time = self.total_time + dt
	if self.total_time >= self.time_between_bobbels then
		table.insert(self.bobbels, Bobbel.create(0, math.random(0, 2)))
	end
	self.total_time = self.total_time % self.time_between_bobbels
end


function game:terminate_bobbel()
	local old_bobbels = self:get_by_angle(self.bobbels, 2*math.pi, 2*math.pi)
	for _, bbl in pairs(old_bobbels) do
		self:remove_by_values(bbl.angle, bbl.track)
	end
end

function game:remove_by_values(angle, track)
	for bblindex, bbl in ipairs(self.bobbels) do
		if bbl.angle == angle and bbl.track == track then
			table.remove(self.bobbels, bblindex)
		end
	end
end

function game:keypressed(key)
	for _, cont in ipairs(self.controller) do
		if cont.key == key then
			local track_bbl = self:get_by_track(self.bobbels, cont.track)
			local hit_bbl = self:get_by_angle(track_bbl, cont.angle - self.hit_offset, 2*self.hit_offset)
			if #hit_bbl > 0 then
				self.score:add(1)
				for _, hbbl in ipairs(hit_bbl) do
					self:remove_by_values(hbbl.angle, hbbl.track)
				end
			end
			cont.pressed = true
		end
	end

	if key == "escape" then
		Gamestate.switch(self.menu)
	end
end

function game:keyreleased(key)
	for _, cont in ipairs(self.controller) do
		if cont.key == key then
			cont.pressed = false
		end
	end
end

function game:get_by_track(bobbels, track)
	local ret_bbls = {}
	for _, bbl in pairs(bobbels) do
		if bbl.track == track then
			table.insert(ret_bbls, bbl)
		end
	end
	return ret_bbls
end

function game:get_by_angle(bobbels, angle, range)
	local ret_bbls = {}
	for _, bbl in pairs(bobbels) do
		if bbl.angle >= angle and bbl.angle <= angle + range then
			table.insert(ret_bbls, bbl)
		end
	end
	return ret_bbls
end

return game
