require 'glowshapes'

Drawing = {}
Drawing.__index = Drawing

function Drawing.create()
        local drawing = {}
        setmetatable(drawing, Drawing)

	drawing.color_background = { r = 10, g = 10, b = 10 }
	drawing.color_gamefield = { r = 100, g = 100, b = 100 }
	drawing.color_origin = { r = 0, g = 0, b = 0 }
	drawing.color_bobbel = { r = 0, g = 255, b = 0 }
	drawing.color_controller = { r = 100, g = 100, b = 100 }
	drawing.color_controller_pressed = { r = 255, g = 50, b = 0 }
	drawing.color_scoreboard = { r = 255, g = 50, b = 0 }
	drawing.color_muted = { r = 50, g = 255, b = 23 }
	drawing.color_debugging = { r = 255, g = 50, b = 23 }
	drawing.color_bobbel_inside_canvas = { r = 255, g = 255, b = 255 }
	drawing.color_controller_inside_canvas = { r = 255, g = 255, b = 255 }

	drawing.bobbel_line_width = 3
	drawing.gamefield_line_width = 2

	drawing.bobbel_radius = 15
	drawing.gamefield_radius = 200
	drawing.track_distance = 25
	drawing.center = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }

	drawing.bobbel_canvas = nil
	drawing.controller_canvas = nil
	drawing.glowing_canvas = nil
	drawing.glowmap_canvas = nil

	drawing.blur = nil
	drawing.bloom = nil

        return drawing
end

function Drawing:init()
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(self.color_background.r, self.color_background.g, self.color_background.b)

	self:create_bobbel_canvas()
	self:create_controller_canvas()
	self:load_shaders()

	love.graphics.setCanvas()
end

function Drawing:create_bobbel_canvas()
	local bmode = love.graphics.getBlendMode()

	self.bobbel_canvas = love.graphics.newCanvas(2 * self.bobbel_radius, 2 * self.bobbel_radius)
	love.graphics.setCanvas(self.bobbel_canvas)

	love.graphics.setColor(self.color_bobbel_inside_canvas.r, self.color_bobbel_inside_canvas.g, self.color_bobbel_inside_canvas.b)
	love.graphics.setLineWidth(self.bobbel_line_width)

	love.graphics.setBlendMode('premultiplied')
	glowShape('circle', 'line', self.bobbel_line_width, self.bobbel_radius, self.bobbel_radius, self.bobbel_radius-5, 20)
	love.graphics.setBlendMode(bmode)
end

function Drawing:create_controller_canvas()
	local bmode = love.graphics.getBlendMode()

	self.controller_canvas = love.graphics.newCanvas(2 * self.bobbel_radius, 2 * self.bobbel_radius)
	love.graphics.setCanvas(self.controller_canvas)

	love.graphics.setColor(self.color_controller_inside_canvas.r, self.color_controller_inside_canvas.g, self.color_controller_inside_canvas.b)

	love.graphics.setBlendMode('premultiplied')
	glowShape('circle', 'fill', self.bobbel_radius, self.bobbel_radius, self.bobbel_radius-5, 20)
	love.graphics.setBlendMode(bmode)
end

function Drawing:load_shaders()
	self.glowing_canvas = love.graphics.newCanvas()
	self.glowmap_canvas = love.graphics.newCanvas(0.5 * love.graphics.getWidth(), 0.5 * love.graphics.getHeight())
	self.blur = love.graphics.newPixelEffect("blur.glsl")
	self.bloom = love.graphics.newPixelEffect("bloom.glsl")
end

function Drawing:let_glow(content)
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

function Drawing:gamefield()
	love.graphics.setColor(self.color_gamefield.r, self.color_gamefield.g, self.color_gamefield.b)
	love.graphics.setLineWidth(self.gamefield_line_width)

	for i = 0, 2 do
		--glowShape('circle', 'line', self.gamefield_line_width, self.center.x, self.center.y, self.gamefield_radius - i * self.track_distance)
		love.graphics.circle('line', self.center.x, self.center.y, self.gamefield_radius - i * self.track_distance)
	end
end

function Drawing:bobbels(bobbels)
	love.graphics.setColor(self.color_bobbel.r, self.color_bobbel.g, self.color_bobbel.b)
	for _, bbl in ipairs(bobbels) do
		bbl:draw(self)
	end
end

function Drawing:controller(controller)
	for _, cont in ipairs(controller) do
		if cont.pressed then
			love.graphics.setColor(self.color_controller_pressed.r ,self.color_controller_pressed.g ,self.color_controller_pressed.b)
		else
			love.graphics.setColor(self.color_controller.r, self.color_controller.g, self.color_controller.b)
		end
		cont:draw(self, self.controller_canvas)
	end
end

function Drawing:origin()
	local limit = 20
	for i = limit, 0, -0.5 do
		alpha = 40 * math.pow((limit - i) / limit, 0.5)
		love.graphics.setColor(self.color_origin.r, self.color_origin.g, self.color_origin.b, alpha)
		love.graphics.arc("fill", self.center.x, self.center.y, self.gamefield_radius*1.25 + i, math.rad(90-i), math.rad(90+i), 100)
	end
end

function Drawing:scoreboard(score, multiplier, spree, max_spree)
	local x = 10
	local y = 10

	love.graphics.setColor(self.color_scoreboard.r, self.color_scoreboard.g, self.color_scoreboard.b)
	love.graphics.print("Score: " .. tostring(score), x, y)
	love.graphics.print("Multiplier: " .. tostring(multiplier), x, y+20)
	love.graphics.print("Current Spree: " .. tostring(spree), x, y+40)
	love.graphics.print("Best Spree: " .. tostring(max_spree), x, y+60)
end

function Drawing:muted(muted)
	if muted then
		love.graphics.setColor(self.color_muted.r, self.color_muted.g, self.color_muted.b)
		love.graphics.print("muted, [M] to unmute", 10, 90)
	end
end

function Drawing:debug(game)
	if game.debug then
		local xcoord = self.center.x + self.gamefield_radius / 2 + 20
		local ycoord = 10
		local boxwidth = love.graphics.getWidth() - xcoord
		local boxheight = love.graphics.getHeight() - 2 * ycoord
		local margin = 5

		love.graphics.setColor(30, 30, 30, 100)
		glowShape('rectangle', 'fill', xcoord, ycoord, boxwidth, boxheight)

		xcoord = xcoord + margin
		boxwidth = boxwidth - 2 * margin
		ycoord = ycoord + margin

		love.graphics.setColor(self.color_debugging.r, self.color_debugging.g, self.color_debugging.b)
		love.graphics.printf("[+] [-] FPS: "..tostring(love.timer.getFPS()), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 30

		love.graphics.printf("[3] [E] hit_offset: "..tostring(math.deg(game.hit_offset)), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 30
		love.graphics.printf("[4] [R] angular_velocity: "..tostring(math.deg(game.angular_velocity)), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 40
		love.graphics.printf("[5] [T] angular_velocity_modifier: "..tostring(game.angular_velocity_modifier), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 30
		love.graphics.printf("[6] [Y] time_between_bobbels: "..tostring(game.time_between_bobbels), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 40
		love.graphics.printf("[7] [U] time_between_bobbels_modifier: "..tostring(game.time_between_bobbels_modifier), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 50

		love.graphics.printf("[8] [I] controller_velocity: "..tostring(game.controller_velocity), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 30
		love.graphics.printf("[9] [O] hit_acceleration: "..tostring(game.hit_acceleration), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 20
		love.graphics.printf("[0] [P] fail_acceleration: "..tostring(game.fail_acceleration), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 20
		love.graphics.printf("[ - ]  [  max_velocity: "..tostring(game.max_velocity), xcoord, ycoord, boxwidth, 'right')
		ycoord = ycoord + 20
		love.graphics.printf("[=]  ]  min_velocity: "..tostring(game.min_velocity), xcoord, ycoord, boxwidth, 'right')
	end
end
