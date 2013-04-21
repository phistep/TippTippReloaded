require 'bobbel'
require 'scoreboard'
require 'synth'

local game = {
	debug = true,
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
	glowing_canvas = nil,
	glowmap_canvas = nil,
	blur = nil,
	bloom_effect = nil,
}

function game:init()

	-- create global bobbel canvas
	self.bobbel_canvas = love.graphics.newCanvas(2 * self.bobbel_radius, 2 * self.bobbel_radius)
	love.graphics.setCanvas(self.bobbel_canvas)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(3)
	--love.graphics.circle("line", self.bobbel_radius, self.bobbel_radius, self.bobbel_radius-5, 20)
	love.graphics.setBlendMode('premultiplied')
	glowShape('circle', self.bobbel_radius, self.bobbel_radius, self.bobbel_radius-5, 20)
	love.graphics.setBlendMode('alpha')

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

	-- glow stuff
	self.glowing_canvas = love.graphics.newCanvas()
	self.glowmap_canvas = love.graphics.newCanvas(0.5 * love.graphics.getWidth(), 0.5 * love.graphics.getHeight())
	self.blur = love.graphics.newPixelEffect("blur.glsl")
	self.bloom_effect = love.graphics.newPixelEffect("bloom.glsl")
end

function game:enter(game_menu)
	self.menu = game_menu
end

function game:draw()
	self.glowing_canvas:clear()
	love.graphics.setCanvas(self.glowing_canvas)

	love.graphics.setColor(100, 100, 100)
	love.graphics.setLineWidth(2)
	glowShape('circle', self.center.x, self.center.y, self.field_radius)
	glowShape('circle', self.center.x, self.center.y, self.field_radius - self.track_distance)
	glowShape('circle', self.center.x, self.center.y, self.field_radius - 2*self.track_distance)

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

	for i=20, 5, -0.5 do
		if i == 5 then
			love.graphics.setColor(10, 10, 10, 255)
		else
			love.graphics.setColor(10, 10, 10, 255/5)
		end
		love.graphics.arc("fill", self.center.x, self.center.y, self.field_radius*1.25 + i, math.rad(90-i), math.rad(90+i), 100)
	end

	love.graphics.setCanvas(self.glowmap_canvas)
	love.graphics.setPixelEffect(self.blur)
	love.graphics.setBlendMode('premultiplied')
	self.blur:send("blurMultiplyVec", {1.0, 0.0});
	love.graphics.draw(self.glowing_canvas, 0, 0, 0, 0.5, 0.5)
	love.graphics.setBlendMode('alpha')
	self.blur:send("blurMultiplyVec", {0.0, 1.0});
	love.graphics.draw(self.glowmap_canvas)
	love.graphics.setCanvas()
	love.graphics.setPixelEffect(self.bloom_effect)
	self.bloom_effect:send("glowmap", self.glowmap_canvas);
	love.graphics.draw(self.glowing_canvas)
	love.graphics.setPixelEffect()

	self.score:draw(10, 30)
	love.graphics.setColor(50, 255, 23)
	if self.mute then
		love.graphics.print("muted, [M] to unmute", 10, 70)
	end
	self:debugging_output()
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

	-- change values
	self:debugging_change_values(dt)
end

function game:update_gamespeed(dt)
	local modifier = (360 - math.deg(self.controller[1].angle)) / 360 + 0.5
	self.angular_velocity = self.angular_velocity + dt * self.angular_velocity_modifier * modifier
	self.time_between_bobbels = self.time_between_bobbels - dt * self.time_between_bobbels_modifier * modifier
end

function game:spawn_bobbel(dt)
	self.total_time = self.total_time + dt
	if self.total_time >= self.time_between_bobbels then
		local randnum = math.random(0, 3)
		if randnum ~= 3 then
			table.insert(self.bobbels, Bobbel.create(0, math.random(0, 2)))
		end
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
	if key == "b" then
		self.debug = not self.debug
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

function game:debugging_output()
	if self.debug then
		local xcoord = self.center.x + self.field_radius
		xcoord = xcoord - 80
		love.graphics.print("[+] [-] FPS: "..tostring(love.timer.getFPS()), xcoord, 10)

		love.graphics.print("[3] [E] hit_offset: "..tostring(math.deg(self.hit_offset)), xcoord, 40)
		love.graphics.print("[4] [R] angular_velocity: "..tostring(math.deg(self.angular_velocity)), xcoord, 70)
		love.graphics.print("[5] [T] angular_velocity_modifier: "..tostring(self.angular_velocity_modifier), xcoord, 90)
		xcoord = xcoord + 40
		love.graphics.print("[6] [Y] time_between_bobbels: "..tostring(self.time_between_bobbels), xcoord, 120)
		love.graphics.print("[7] [U] time_between_bobbels_modifier: "..tostring(self.time_between_bobbels_modifier), xcoord, 140)

		xcoord = xcoord + 60
		love.graphics.print("[8] [I] controller_velocity: "..tostring(self.controller_velocity), xcoord, 190)
		love.graphics.print("[9] [O] hit_acceleration: "..tostring(self.hit_acceleration), xcoord, 220)
		love.graphics.print("[0] [P] fail_acceleration: "..tostring(self.fail_acceleration), xcoord, 240)
		love.graphics.print("[ - ]  [  max_velocity: "..tostring(self.max_velocity), xcoord, 260)
		love.graphics.print("[=]  ]  min_velocity: "..tostring(self.min_velocity), xcoord, 280)
	end
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

function glowShape(type, ...)
	local r, g, b, a = love.graphics.getColor()
	local lwidth = love.graphics.getLineWidth()

	love.graphics.setColor(r, g, b, 20)

	for i = lwidth + 6, lwidth + 1, -1 do
		if i == lwidth + 1 then
			i = lwidth
			love.graphics.setColor(r, g, b, 255)
		end

		love.graphics.setLineWidth(i)

		if type == "line" then
			love.graphics[type](...)
		else
			love.graphics[type]("line", ...)
		end
	end
	love.graphics.setColor(r, g, b, a)
end

return game
