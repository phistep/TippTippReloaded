require 'bobbel'

Menugame = {}
Menugame.__index = Menugame

function Menugame.create(x, y, r, start, stop)
	local menugame = {}
	setmetatable(menugame, Menugame)

	menugame.angular_velocity = math.rad(30)
	menugame.time_between_bobbels = 0.9

	menugame.total_time = 0
	menugame.bobbels = {}

	-- drawing settings
	menugame.color_gamefield = { r = 13, g = 194, b = 189 }
	menugame.color_bobbel = { r = 167, g = 69, b = 255 }
	menugame.color_bobbel_inside_canvas = { r = 255, g = 255, b = 255 }

	menugame.bobbel_line_width = 5
	menugame.gamefield_line_width = 3

	menugame.gamefield_radius = r or 200
	menugame.bobbel_radius = 15 / 200 * menugame.gamefield_radius
	menugame.track_distance = 50 / 200 * menugame.gamefield_radius
	menugame.center = {
		x = x or love.graphics.getWidth() / 2,
		y = y or love.graphics.getHeight() / 2
	}
	menugame.start = start - math.rad(10) or -10
	menugame.stop = stop + math.rad(10) or math.rad(360 + 10)

	menugame.bobbel_canvas = nil
	menugame.controller_canvas = nil
	menugame.glowing_canvas = nil
	menugame.glowmap_canvas = nil

	menugame.blur = nil
	menugame.bloom = nil

	menugame:create_bobbel_canvas()
	menugame:load_shaders()
	love.graphics.setCanvas()

	return menugame
end

function Menugame:draw()
	self:let_glow(function()
		self:gamefield()
		self:draw_bobbels(self.bobbels)
	end)
end

function Menugame:update(dt)
	-- Updating bobbels
	for _, bbl in pairs(self.bobbels) do
		bbl:update(self, dt)
	end

	-- Spawning new bobbels
	self:spawn_bobbel(dt)

	-- Removing bobbels
	self:terminate_bobbel()
end

function Menugame:spawn_bobbel(dt)
        self.total_time = self.total_time + dt
        if self.total_time >= self.time_between_bobbels then
                local randnum = math.random(0, 3)
                if randnum ~= 3 then
			local new_bobbel = Bobbel.create(self.start, randnum, true)
                        table.insert(self.bobbels, new_bobbel)
                end
        end
        self.total_time = self.total_time % self.time_between_bobbels
end

function Menugame:terminate_bobbel()
	local old_bobbels = self:get_by_angle(self.bobbels, self.stop, math.rad(360))
	for _, bbl in pairs(old_bobbels) do
		self:remove_by_values(bbl.angle, bbl.track)
	end
end

function Menugame:remove_by_values(angle, track)
	for bblindex, bbl in ipairs(self.bobbels) do
		if bbl.angle == angle and bbl.track == track then
			table.remove(self.bobbels, bblindex)
		end
	end
end

function Menugame:get_by_track(bobbels, track)
	local ret_bbls = {}
	for _, bbl in pairs(bobbels) do
		if bbl.track == track then
			table.insert(ret_bbls, bbl)
		end
	end
	return ret_bbls
end

function Menugame:get_by_angle(bobbels, angle, range)
	local ret_bbls = {}
	for _, bbl in pairs(bobbels) do
		if bbl.angle >= angle and bbl.angle <= angle + range then
			table.insert(ret_bbls, bbl)
		end
	end
	return ret_bbls
end

function Menugame:create_bobbel_canvas()
	local bmode = love.graphics.getBlendMode()

	self.bobbel_canvas = love.graphics.newCanvas(2 * self.bobbel_radius, 2 * self.bobbel_radius)
	love.graphics.setCanvas(self.bobbel_canvas)

	love.graphics.setColor(self.color_bobbel_inside_canvas.r, self.color_bobbel_inside_canvas.g, self.color_bobbel_inside_canvas.b)
	love.graphics.setLineWidth(self.bobbel_line_width)

	love.graphics.setBlendMode('premultiplied')
	Effects:glowShape('circle', 'line', self.bobbel_line_width, self.bobbel_radius, self.bobbel_radius, self.bobbel_radius-5, 20)
	love.graphics.setBlendMode(bmode)
end

function Menugame:load_shaders()
	self.glowing_canvas = love.graphics.newCanvas()
	self.glowmap_canvas = love.graphics.newCanvas(0.5 * love.graphics.getWidth(), 0.5 * love.graphics.getHeight())
	self.blur = love.graphics.newPixelEffect("blur.glsl")
	self.bloom = love.graphics.newPixelEffect("bloom.glsl")
end

function Menugame:let_glow(content)
	local bmode = love.graphics.getBlendMode()

	self.glowing_canvas:clear()
	love.graphics.setCanvas(self.glowing_canvas)

	content()

	love.graphics.setCanvas(self.glowmap_canvas)
	love.graphics.setPixelEffect(self.blur)
	love.graphics.setBlendMode('premultiplied')
	self.blur:send("blurMultiplyVec", {1.0, 0.0});
	love.graphics.draw(self.glowing_canvas, 0, 0, 0, 0.5, 0.5)
	love.graphics.setBlendMode('alpha')
	self.blur:send("blurMultiplyVec", {0.0, 1.0});
	love.graphics.draw(self.glowmap_canvas)
	love.graphics.setCanvas()
	love.graphics.setPixelEffect(self.bloom)
	self.bloom:send("glowmap", self.glowmap_canvas);
	love.graphics.draw(self.glowing_canvas)
	love.graphics.setPixelEffect()
	love.graphics.setBlendMode(bmode)
end

function Menugame:gamefield()
	love.graphics.setColor(self.color_gamefield.r, self.color_gamefield.g, self.color_gamefield.b)
	love.graphics.setLineWidth(self.gamefield_line_width)

	for i = 0, 2 do
		Effects:drawArc(
			self.center.x,
			self.center.y,
			self.gamefield_radius - i * self.track_distance,
			math.rad(360) - self.stop - math.rad(90),
			math.rad(360) - self.start - math.rad(90)
		)
	end
end

function Menugame:draw_bobbels(bobbels)
	love.graphics.setColor(self.color_bobbel.r, self.color_bobbel.g, self.color_bobbel.b)
	for _, bbl in ipairs(bobbels) do
		bbl:draw(self)
	end
end
