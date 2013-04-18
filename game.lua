require 'bobbel'
require 'scoreboard'
require 'synth'

local game = {
	bobbel_radius = 15,
	field_radius = 200,
	center = { x = 300, y = 300 },
	track_distance = 25,
	total_time = 0,

	hit_offset = math.rad(5),
	angular_velocity = math.rad(30),
	angular_velocity_modifier = 0.003,
	time_between_bobbels = 0.9,
	time_between_bobbels_modifier = 0.003,

	controller_velocity = 0,
	hit_acceleration = 0.02,
	fail_acceleration = -0.04,
	max_velocity = 3 * 0.02,
	min_velocity = 8 * -0.02,
	key_forward_movement = math.rad(90),

	bobbel_canvas = nil,
	controller_canvas = nil,
	bobbels = {},
	controller = {Bobbel.create(math.rad(270), 0), Bobbel.create(math.rad(270), 1), Bobbel.create(math.rad(270), 2)},
	score = Scoreboard.create(),
	synth = nil,
	mute = false,
}

function game:init()

	-- create global bobbel canvas
	self.bobbel_canvas = love.graphics.newCanvas(2 * self.bobbel_radius, 2 * self.bobbel_radius)
	love.graphics.setCanvas(self.bobbel_canvas)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(3)
	love.graphics.circle("line", self.bobbel_radius, self.bobbel_radius, self.bobbel_radius-5, 20)

	-- create global controller canvas
	self.controller_canvas = love.graphics.newCanvas(2 * self.bobbel_radius, 2 * self.bobbel_radius)
	love.graphics.setCanvas(self.controller_canvas)
	love.graphics.setColor(255, 255, 255)
	love.graphics.circle("fill", self.bobbel_radius, self.bobbel_radius, self.bobbel_radius-4, 20)

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

	-- sound stuff
	self.synth = Synth.create()
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
		cont:draw(self, self.controller_canvas)
	end

	for i=20, 0, -1 do
		love.graphics.setColor(10, 10, 10, 255/5)
		love.graphics.arc("fill", self.center.x, self.center.y, self.field_radius*1.25, math.rad(90-i), math.rad(90+i), 100)
	end

	love.graphics.setColor(23, 200, 255)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	self.score:draw(10, 30)
	if self.mute then
		love.graphics.print("muted, [M] to unmute", 10, 70)
	end
end

function game:update(dt)
	-- Updating gamevars
	self:update_gamespeed(dt)

	-- Updating bobbels
	for _, bbl in pairs(self.bobbels) do
		bbl:update(self, dt)
	end

	-- Spawning new bobbels
	self:spawn_bobbel(dt)

	-- Removing bobbels
	self:terminate_bobbel()

	-- Change controller position
	self:update_controller(dt)

	if love.keyboard.isDown('w') then
		self:change_controller_angle(dt * -self.key_forward_movement)
	end

	if love.keyboard.isDown('c') then
		self:change_controller_angle(dt * self.key_forward_movement)
	end
end

function game:update_gamespeed(dt)
	local modifier = (360 - math.deg(self.controller[1].angle)) / 360 + 0.5
	self.angular_velocity = self.angular_velocity + dt * self.angular_velocity_modifier * modifier
	self.time_between_bobbels = self.time_between_bobbels - dt * self.time_between_bobbels_modifier * modifier
end

function game:spawn_bobbel(dt)
	self.total_time = self.total_time + dt
	if self.total_time >= self.time_between_bobbels then
		table.insert(self.bobbels, Bobbel.create(0, math.random(0, 2)))
	end
	self.total_time = self.total_time % self.time_between_bobbels
end


function game:terminate_bobbel()
	local old_bobbels = self:get_by_angle(self.bobbels, math.rad(360), math.rad(360))
	for _, bbl in pairs(old_bobbels) do
		self:remove_by_values(bbl.angle, bbl.track)
		self:fail()
	end
end

function game:update_controller(dt)
	local movement_modifier = 1
	if self.controller_velocity > 0 then
		movement_modifier = math.deg(self.controller[1].angle) / 360 + 0.5
	else
		movement_modifier = (360 - math.deg(self.controller[1].angle)) / 360 + 0.5
	end
	self:change_controller_angle(dt * -self.controller_velocity * movement_modifier)
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
				self:hit(hit_bbl)
			else
				self:fail()
			end
			cont.pressed = true
		end
	end

	if key == "escape" then
		Gamestate.switch(self.menu)
	end
	if key == "m" then
		self.mute = not self.mute
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

function game:change_controller_angle(delta_angle)
	for _, bbl in ipairs(self.controller) do
		local newangle = bbl.angle + delta_angle
		if newangle > 0 and newangle < math.rad(360) then
			bbl.angle = newangle
		else
			controller_velocity = 0
		end
	end
end

function game:set_controller_velocity(new_velocity)
	if new_velocity < self.min_velocity then
		self.controller_velocity = self.min_velocity
	elseif new_velocity <= self.max_velocity then
		self.controller_velocity = new_velocity
	else
		self.controller_velocity = self.max_velocity
	end
end

function game:hit(hit_bbl)
	self.score:count_hit()
	for _, hbbl in ipairs(hit_bbl) do
		self:remove_by_values(hbbl.angle, hbbl.track)
		if not self.mute then
			self.synth:play(hbbl.track)
		end
	end
	self:set_controller_velocity(self.controller_velocity + self.hit_acceleration)
end

function game:fail()
	self.score:count_miss()
	self:set_controller_velocity(self.controller_velocity + self.fail_acceleration)
end

return game
