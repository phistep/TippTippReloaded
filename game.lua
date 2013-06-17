require 'bobbel'
require 'drawing'
require 'scoreboard'
require 'synth'
require 'spawner'

local game = {}

function game:init()
	self.debug = false
	self.scorescreen = require 'scorescreen'

	self.hit_offset = math.rad(5)
	self.controller_spawner_distance = math.rad(120)
	self.killer_position = math.rad(390)
	self.angular_velocity_modifier = 0.003
	self.time_between_bobbels_modifier = 0.003

	self.hit_acceleration = 0.03
	self.fail_acceleration = -2 * self.hit_acceleration
	self.max_velocity = 3 * self.hit_acceleration
	self.min_velocity = -8 * self.hit_acceleration
	self.key_forward_movement = math.rad(90)

	self.special_timesteps = 60
	self.special_spree_length = 10
	self.special_duration = 10

	self.drawing = Drawing.create()
	self.score = nil
	self.spawner = nil
	self.synth = Synth.create()

	self.keys_activate_special = { ['rshift'] = true, ['lshift'] = true }
	self.keys_back = { ' ', 'rctrl' }
	self.keys_forward = { 'w', 'i', 'up' }
	self.keys_menu = { ['q'] = true }
	self.keys_pause = { ['escape'] = true }
	self.keys_mute = { ['m'] = true }
	self.keys_debugging = { ['b'] = true }

	-- drawing settings
	self.drawing:init()
end

function game:enter(game_menu)
	self.menu = game_menu

	self.pause = false
	self.rotation_angle = 0
	self.angular_velocity = math.rad(30)
	self.time_between_beats = 60 / self.synth.bpm
	self.controller_velocity = 0

	self.special_bobbel_spawned = 0
	self.special_bobbel_hit = 0
	self.special_available = false
	self.special_activated = false
	self.special_time_activated = 0

	self.total_hits = 0
	self.total_fails = 0
	self.total_time = 0

	self.score = Scoreboard.create()
	self.spawner = Spawner.create(self.time_between_beats / 2)
	self.t_music = self.synth.music:tell()
	self.synth:toggle_music('play')

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
end

function game:leave()
	self.synth:toggle_music('stop')
end

function game:draw()
	Effects:start_glow()
	self.drawing:gamefield()

	self.drawing:rotate_gamefield(self.rotation_angle, function()
		self.drawing:bobbels(self.bobbels, self.special_activated, self:get_spawner_position(), self:get_killer_position())
		self.drawing:controller(self.controller, self:get_spawner_position(), self:get_killer_position())
		self.drawing:origin(self:get_spawner_position(), self:get_killer_position())
	end)

	self.drawing:scoreboard(self:get_score())
	self.drawing:muted(self.synth:is_muted())
	self.drawing:special_available(self.special_available)
	self.drawing:debug(self)

	if self.pause then
		self.drawing:pause()
	end
	Effects:stop_glow()
end

function game:update(dt)
	love.audio.update()
	if not self.pause then
		-- Updating time
		local new_t_music = self.synth.music:tell()
		local dt_music = new_t_music - self.t_music
		self.t_music = new_t_music
		dt = dt_music

		self.total_time = self.total_time + dt

		-- Updating gamevars
		self:update_gamespeed(dt)
		self:update_rotation(dt)

		-- Updating bobbels
		for _, bbl in pairs(self.bobbels) do
			bbl:update(self, dt, self:get_real_controller_velocity())
		end

		-- Spawning new bobbels
		self:spawn_bobbel(dt)

		-- Removing bobbels
		self:terminate_bobbel()

		-- Deactivate special if special_duration is over
		self:deactivate_special()

		-- Change controller position
		self:update_controller(dt)

		if love.keyboard.isDown(unpack(self.keys_forward)) and self.debug then
			self:change_controller_angle(dt * -self.key_forward_movement)
		end

		if love.keyboard.isDown(unpack(self.keys_back)) and self.debug then
			self:change_controller_angle(dt * self.key_forward_movement)
		end

		-- change values
		self:debugging_change_values(dt)
	end
end

function game:update_gamespeed(dt)
	local modifier = 1 - (self:get_controller_angle() - self:get_gamefield_start()) / self:get_gamefield_width() + 0.5
	self.angular_velocity = self.angular_velocity + dt * self.angular_velocity_modifier * modifier
	--self.time_between_bobbels = self.time_between_bobbels - dt * self.time_between_bobbels_modifier * modifier
end

function game:spawn_bobbel(dt)
	if self.total_time > self.synth.offset - self:get_time_spawner_to_controller() then
		self.spawner:update(dt, self.time_between_beats / 2)
		local new_tracks = self.spawner:new_bobbel_track()
		if new_tracks then
			for trackno, tdiff in pairs(new_tracks) do
				if trackno >= 0 and trackno <= 2 then
					local new_bobbel = Bobbel.create(self:get_spawner_position() + tdiff * self.angular_velocity, trackno)
					new_bobbel = self:spawn_special(new_bobbel)
					table.insert(self.bobbels, new_bobbel)
				end
			end
		end
	end
end

function game:spawn_special(bbl)
	if self.special_bobbel_spawned == 0 and self.total_time % self.special_timesteps < 1 and self.total_time >= self.special_timesteps then
		self.special_bobbel_spawned = 1
		self.special_bobbel_hit = 0
		bbl.special = self.special_bobbel_spawned
	elseif self.special_bobbel_spawned == self.special_spree_length then
		self.special_bobbel_spawned = 0
	elseif self.special_bobbel_spawned > 0 then
		self.special_bobbel_spawned = self.special_bobbel_spawned + 1
		bbl.special = self.special_bobbel_spawned
	end
	return bbl
end

function game:terminate_bobbel()
	local old_bobbels = self:get_by_angle(self.bobbels, self:get_gamefield_end(), math.rad(360))
	for _, bbl in pairs(old_bobbels) do
		self:remove_by_values(bbl.angle, bbl.track)
		self:fail(bbl)
	end
end

function game:update_rotation(dt)
	--self.rotation_angle = self.rotation_angle + dt * 2 * self:get_real_controller_velocity()
	self.rotation_angle = self.rotation_angle + dt * 2 * self.controller_velocity
end

function game:update_controller(dt)
	self:change_controller_angle(dt * -self:get_real_controller_velocity())
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
					cont.hit = true
				else
					self:fail()
					cont.fail = true
				end
			end
		end
	end

	if self.keys_activate_special[key] and self.special_available then
		self:activate_special()
	end
	if self.keys_menu[key] then
		Gamestate.switch(self.menu)
	end
	if self.keys_pause[key] then
		self.pause = not self.pause
		self.synth:toggle_music()
	end
	if self.keys_mute[key] then
		self.synth:toggle_mute()
	end
	if self.keys_debugging[key] then
		self.debug = not self.debug
	end
	if key == 'x' then
		self.synth:toggle_music()
	end
end

function game:keyreleased(key)
	for _, cont in ipairs(self.controller) do
		if cont.keys[key] then
			cont.hit = false
			cont.fail = false
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

function game:get_controller_angle()
	return self.controller[1].angle
end

function game:get_real_controller_velocity()
	local movement_modifier = (self:get_controller_angle() - self:get_gamefield_start()) / self:get_gamefield_width()
	if self.controller_velocity < 0 then
		movement_modifier = 1 - movement_modifier + 0.2
	end
	return self.controller_velocity * movement_modifier
end

function game:get_spawner_position()
	return self.controller[1].angle - self.controller_spawner_distance
end

function game:get_killer_position()
	return self.killer_position
end

function game:get_gamefield_width()
	return math.rad(360) - self.controller_spawner_distance
end

function game:get_gamefield_start()
	return self.killer_position % math.rad(360) + self.controller_spawner_distance
end

function game:get_gamefield_end()
	return self.killer_position
end

function game:get_time_spawner_to_controller()
	return self.controller_spawner_distance / self.angular_velocity
end

function game:change_controller_angle(delta_angle)
	for _, bbl in ipairs(self.controller) do
		local newangle = bbl.angle + delta_angle
		if newangle > self:get_gamefield_end() then
			self:lost()
		elseif newangle > self:get_gamefield_start() then
			bbl.angle = newangle
		else
			self:set_controller_velocity(0)
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
		if hbbl.special then self:hit_special(hbbl) end
		self.score:count_hit(self, hbbl)
		self:remove_by_values(hbbl.angle, hbbl.track)
		self.synth:play(hbbl.track)
		self.total_hits = self.total_hits + 1
	end
	self:set_controller_velocity(self.controller_velocity + self.hit_acceleration)
end

function game:hit_special(hit_bbl)
	self.special_bobbel_hit = self.special_bobbel_hit + 1

	if self.special_bobbel_hit == self.special_spree_length then
		self.special_available = true
	end
end

function game:fail(fail_bbl)
	if not (fail_bbl and not fail_bbl.special) then
		self.special_bobbel_hit = 0
	end
	if fail_bbl then
		self.total_fails = self.total_fails + 1
	end
	self.score:count_miss()
	self:set_controller_velocity(self.controller_velocity + self.fail_acceleration)
end

function game:lost()
	if not self.debug then
		Gamestate.switch(self.scorescreen, self.menu, self.total_hits, self.total_fails, self:get_score())
	end
end

function game:activate_special()
	self.special_activated = true
	self.special_time_activated = self.total_time
	self.score:set_special_activated(true)
	self.special_available = false
end

function game:deactivate_special()
	if self.special_activated and self.total_time - self.special_time_activated > self.special_duration then
		self.special_activated = false
		self.score:set_special_activated(false)
	end
end

function game:get_score()
	return self.score:get_score(), self.score:get_multiplier(), self.score:get_spree(), self.score:get_max_spree(), self.total_time
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
