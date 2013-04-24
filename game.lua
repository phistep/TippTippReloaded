require 'bobbel'
require 'drawing'
require 'scoreboard'
require 'synth'
require 'spawner'

local game = {}

function game:init()
	self.debug = true
	self.pause = false

	self.hit_offset = math.rad(5)
	self.angular_velocity = math.rad(30)
	self.angular_velocity_modifier = 0.003
	self.time_between_bobbels = 0.9
	self.time_between_bobbels_modifier = 0.003

	self.controller_velocity = 0
	self.hit_acceleration = 0.02
	self.fail_acceleration = -2 * self.hit_acceleration
	self.max_velocity = 3 * self.hit_acceleration
	self.min_velocity = -8 * self.hit_acceleration
	self.key_forward_movement = math.rad(90)

	self.drawing = Drawing.create()
	self.score = Scoreboard.create()
	self.spawner = Spawner.create(self.time_between_bobbels)
	self.synth = Synth.create()

	self.bobbels = {}
	self.controller = {}

	-- create controller bobbels
	for i = 1, 3 do
		self.controller[i] = Bobbel.create(math.rad(270), i-1)
		self.controller[i].pressed = false
	end
	self.controller[1].keys = { d = true, l = true, right = true }
	self.controller[2].keys = { s = true, k = true, down = true }
	self.controller[3].keys = { a = true, j = true, left = true }

	self.keys_back = { ' ', 'rctrl' }
	self.keys_forward = { 'w', 'i', 'up' }

	-- drawing settings
	self.drawing:init()
end

function game:enter(game_menu)
	self.menu = game_menu
end

function game:draw()
	self.drawing:let_glow(function()
		self.drawing:gamefield()

		self.drawing:bobbels(self.bobbels)
		self.drawing:controller(self.controller)
		self.drawing:origin()

		self.drawing:scoreboard(self.score:get_score(), self.score:get_multiplier(), self.score:get_spree(), self.score:get_max_spree())
		self.drawing:muted(self.synth:is_muted())
		self.drawing:debug(self)

		if self.pause then
			self.drawing:pause()
		end
	end)
end

function game:update(dt)
	if not self.pause then
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

		if love.keyboard.isDown(unpack(self.keys_forward)) and self.debug then
			self:change_controller_angle(dt * -self.key_forward_movement)
		end

		if love.keyboard.isDown(unpack(self.keys_back)) then
			self:change_controller_angle(dt * self.key_forward_movement)
		end

		-- change values
		self:debugging_change_values(dt)
	end
end

function game:update_gamespeed(dt)
	local modifier = (360 - math.deg(self.controller[1].angle)) / 360 + 0.5
	self.angular_velocity = self.angular_velocity + dt * self.angular_velocity_modifier * modifier
	self.time_between_bobbels = self.time_between_bobbels - dt * self.time_between_bobbels_modifier * modifier
end

function game:spawn_bobbel(dt)
	self.spawner:update(dt, self.time_between_bobbels)
	local new_tracks = self.spawner:new_bobbel_track()
	if new_tracks then
		for _, trackno in ipairs(new_tracks) do
			if trackno >= 0 and trackno <= 2 then
				local new_bobbel = Bobbel.create(0, trackno)
				table.insert(self.bobbels, new_bobbel)
			end
		end
	end
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
	if not self.pause then
		for _, cont in ipairs(self.controller) do
			if cont.keys[key] then
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
	end

	if key == "escape" then
		Gamestate.switch(self.menu)
	end
	if key == "m" then
		self.synth:toggle_mute()
	end
	if key == "n" then
		self.pause = not self.pause
	end
	if key == "b" then
		self.debug = not self.debug
	end
end

function game:keyreleased(key)
	for _, cont in ipairs(self.controller) do
		if cont.keys[key] then
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
	for _, hbbl in ipairs(hit_bbl) do
		self.score:count_hit()
		self:remove_by_values(hbbl.angle, hbbl.track)
		self.synth:play(hbbl.track)
	end
	self:set_controller_velocity(self.controller_velocity + self.hit_acceleration)
end

function game:fail()
	self.score:count_miss()
	self:set_controller_velocity(self.controller_velocity + self.fail_acceleration)
end

function game:debugging_change_values(dt)
	if self.debug then
		-- hit_offset
		if love.keyboard.isDown('3') then
			self.hit_offset = self.hit_offset + dt * math.rad(0.5)
		end
		if love.keyboard.isDown('e') then
			self.hit_offset = self.hit_offset - dt * math.rad(0.5)
		end

		-- angular_velocity
		if love.keyboard.isDown('4') then
			self.angular_velocity = self.angular_velocity + dt * 1
		end
		if love.keyboard.isDown('r') then
			self.angular_velocity = self.angular_velocity - dt * 1
		end

		-- angular_velocity_modifier
		if love.keyboard.isDown('5') then
			self.angular_velocity_modifier = self.angular_velocity_modifier + dt * 0.001
		end
		if love.keyboard.isDown('t') then
			self.angular_velocity_modifier = self.angular_velocity_modifier - dt * 0.001
		end

		-- time_between_bobbels
		if love.keyboard.isDown('6') then
			self.time_between_bobbels = self.time_between_bobbels + dt * 0.1
		end
		if love.keyboard.isDown('y') then
			self.time_between_bobbels = self.time_between_bobbels - dt * 0.1
		end

		-- time_between_bobbels_modifier
		if love.keyboard.isDown('7') then
			self.time_between_bobbels_modifier = self.time_between_bobbels_modifier + dt * 0.003
		end
		if love.keyboard.isDown('u') then
			self.time_between_bobbels_modifier = self.time_between_bobbels_modifier - dt * 0.003
		end

		-- controller_velocity
		if love.keyboard.isDown('8') then
			self.controller_velocity = self.controller_velocity + dt * 0.01
		end
		if love.keyboard.isDown('i') then
			self.controller_velocity = self.controller_velocity - dt * 0.01
		end

		-- hit_acceleration
		if love.keyboard.isDown('9') then
			self.hit_acceleration = self.hit_acceleration + dt * 0.01
		end
		if love.keyboard.isDown('o') then
			self.hit_acceleration = self.hit_acceleration - dt * 0.01
		end

		-- fail_acceleration
		if love.keyboard.isDown('0') then
			self.fail_acceleration = self.fail_acceleration + dt * 0.01
		end
		if love.keyboard.isDown('p') then
			self.fail_acceleration = self.fail_acceleration - dt * 0.01
		end

		-- max_velocity
		if love.keyboard.isDown('-') then
			self.max_velocity = self.max_velocity + dt * 0.01
		end
		if love.keyboard.isDown('[') then
			self.max_velocity = self.max_velocity - dt * 0.01
		end

		-- min_velocity
		if love.keyboard.isDown('=') then
			self.min_velocity = self.min_velocity + dt * 0.01
		end
		if love.keyboard.isDown(']') then
			self.min_velocity = self.min_velocity - dt * 0.01
		end
	end
end

return game
