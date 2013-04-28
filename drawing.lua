require 'glowshapes'

Drawing = {}
Drawing.__index = Drawing

function Drawing.create()
        local drawing = {}
        setmetatable(drawing, Drawing)

	local color1 = { r = 167, g = 69, b = 255 } -- green
	local color2 = { r = 20, g = 128, b = 201 } -- red
	local color3 = { r = 13, g = 194, b = 189 } -- gray
	local color4 = { r = 255, g = 255, b = 255 } -- white
	local color5 = { r = 240, g = 52, b = 173 }

	drawing.color_background = { r = 10, g = 10, b = 10 }
	drawing.color_gamefield = color3
	drawing.color_origin = { r = 0, g = 0, b = 0 }
	drawing.color_bobbel = color1
	drawing.color_bobbel_special_activated = color4
	drawing.color_special_bobbel = color5
	drawing.color_controller = color3
	drawing.color_controller_pressed_hit = color5
	drawing.color_controller_pressed_fail = color2
	drawing.color_scoreboard = color2
	drawing.color_muted = color1
	drawing.color_special_available = color1
	drawing.color_pause = { r = 10, g = 10, b = 10 }
	drawing.color_pause_font = color1
	drawing.color_debugging = { r = 255, g = 255, b = 255 }
	drawing.color_bobbel_inside_canvas = { r = 255, g = 255, b = 255 }
	drawing.color_special_bobbel_inside_canvas = { r = 255, g = 255, b = 255 }
	drawing.color_controller_inside_canvas = { r = 255, g = 255, b = 255 }

	drawing.bobbel_line_width = 3
	drawing.special_bobbel_line_width = 3
	drawing.gamefield_line_width = 2

	drawing.bobbel_radius = 15
	drawing.gamefield_radius = 200
	drawing.track_distance = 25
	drawing.center = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2 }

	drawing.bobbel_canvas = nil
	drawing.special_bobbel_canvas = nil
	drawing.controller_canvas = nil
	drawing.glowing_canvas = nil
	drawing.glowmap_canvas = nil

	drawing.blur = nil
	drawing.bloom = nil

	drawing.font_debug = love.graphics.newFont(12)
	drawing.font_multi = love.graphics.newFont("assets/polentical_neon_bold.ttf", 100)
	drawing.font_score = love.graphics.newFont("assets/polentical_neon_bold.ttf", 50)
	drawing.font_spree = love.graphics.newFont("assets/polentical_neon_bold.ttf", 30)
	drawing.font_time = love.graphics.newFont("assets/polentical_neon_bold.ttf", 30)
	drawing.font_mute = love.graphics.newFont("assets/polentical_neon_bold_italic.ttf", 14)
	drawing.font_special_available = love.graphics.newFont("assets/polentical_neon_bold_italic.ttf", 14)
	drawing.font_pause = love.graphics.newFont("assets/polentical_neon_bold_italic.ttf", 80)

	return drawing
end

function Drawing:init()
	self:create_bobbel_canvas()
	self:create_special_bobbel_canvas()
	self:create_controller_canvas()
	self:load_shaders()

	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(self.color_background.r, self.color_background.g, self.color_background.b)
	love.graphics.setNewFont()
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

function Drawing:create_special_bobbel_canvas()
	local bmode = love.graphics.getBlendMode()

	self.special_bobbel_canvas = love.graphics.newCanvas(2 * self.bobbel_radius, 2 * self.bobbel_radius)
	love.graphics.setCanvas(self.special_bobbel_canvas)

	love.graphics.setColor(self.color_special_bobbel_inside_canvas.r, self.color_special_bobbel_inside_canvas.g, self.color_special_bobbel_inside_canvas.b)
	love.graphics.setLineWidth(self.special_bobbel_line_width)

	love.graphics.setBlendMode('premultiplied')
	glowShape('rectangle', 'line', self.special_bobbel_line_width, 5, 5, 2*(self.bobbel_radius-5), 2*(self.bobbel_radius-5))
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

function Drawing:bobbels(bobbels, special_activated)
	local bobbel_color = self.color_bobbel
	if special_activated then
		bobbel_color = self.color_bobbel_special_activated
	end
	love.graphics.setColor(bobbel_color.r, bobbel_color.g, bobbel_color.b)

	for _, bbl in ipairs(bobbels) do
		if bbl.special then
			love.graphics.setColor(self.color_special_bobbel.r, self.color_special_bobbel.g, self.color_special_bobbel.b)
			bbl:draw(self, self.special_bobbel_canvas)
			love.graphics.setColor(bobbel_color.r, bobbel_color.g, bobbel_color.b)
		else
			bbl:draw(self)
		end
	end
end

function Drawing:controller(controller)
	for _, cont in ipairs(controller) do
		if cont.hit then
			love.graphics.setColor(self.color_controller_pressed_hit.r ,self.color_controller_pressed_hit.g ,self.color_controller_pressed_hit.b)
		elseif cont.fail then
			love.graphics.setColor(self.color_controller_pressed_fail.r ,self.color_controller_pressed_fail.g ,self.color_controller_pressed_fail.b)
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

function Drawing:scoreboard(score, multiplier, spree, max_spree, time)
	local x = 10
	local y = 10

	love.graphics.setColor(self.color_scoreboard.r, self.color_scoreboard.g, self.color_scoreboard.b)
	--love.graphics.print("Best Spree: " .. tostring(max_spree), x, y+60)

	-- multiplier
	local inner_circle_radius = self.gamefield_radius - 2*self.track_distance
	love.graphics.setFont(self.font_multi)
	love.graphics.printf(multiplier.."x", love.graphics.getWidth()/2 - inner_circle_radius, love.graphics.getHeight()/2 - 60, 2*inner_circle_radius, "center")

	-- score
	local score_margin = 10
	love.graphics.setFont(self.font_score)
	love.graphics.printf(score, score_margin, 20, love.graphics.getWidth() - 2*score_margin, "center")

	-- spree
	love.graphics.setFont(self.font_spree)
	love.graphics.printf(spree, score_margin, love.graphics.getHeight()/2 - self.gamefield_radius, 260, "right")

	-- time
	local timestring = string.format("%02d:%02d", time / 60, time % 60)
	love.graphics.setFont(self.font_time)
	love.graphics.printf(timestring, 530, love.graphics.getHeight()/2 - self.gamefield_radius, 260, "left")
end

function Drawing:muted(muted)
	if muted then
		love.graphics.setColor(self.color_muted.r, self.color_muted.g, self.color_muted.b)
		love.graphics.setFont(self.font_mute)
		love.graphics.print("muted, [M] to unmute", 10, 10)
	end
end

function Drawing:special_available(available)
	if available then
		love.graphics.setColor(self.color_special_available.r, self.color_special_available.g, self.color_special_available.b)
		love.graphics.setFont(self.font_special_available)
		love.graphics.print("use [SHIFT] to activate special multiplier", 10, 30)
	end
end

function Drawing:pause()
	love.graphics.setColor(self.color_pause.r, self.color_pause.g, self.color_pause.b, 200)
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	local xoffset = 10
	--local yoffset = self.pause_font:getLineHeight()
	local yoffset = 50
	love.graphics.setFont(self.font_pause)
	love.graphics.setColor(self.color_pause_font.r, self.color_pause_font.g, self.color_pause_font.b, 255)
	love.graphics.printf("Pause", xoffset, self.center.y - yoffset, love.graphics.getWidth() - 2 * xoffset, 'center')
	love.graphics.setNewFont()
end

function Drawing:debug(game)
	if game.debug then
		local xcoord = self.center.x + self.gamefield_radius / 2
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
		love.graphics.setFont(self.font_debug)
		love.graphics.printf(
		"[+] [-] FPS: "..tostring(love.timer.getFPS())..

		"\n[3] [E] hit_offset: "..tostring(math.deg(game.hit_offset))..

		"\n\n[4] [R] angular_velocity: "..tostring(math.deg(game.angular_velocity))..
		"\n[5] [T] angular_velocity_modifier: "..tostring(game.angular_velocity_modifier)..

		"\n\n[6] [Y] time_between_bobbels: "..tostring(game.time_between_bobbels)..
		"\n[7] [U] time_between_bobbels_modifier: "..tostring(game.time_between_bobbels_modifier)..


		"\n\n[8] [I] controller_velocity: "..tostring(game.controller_velocity)..

		"\n\n[9] [O] hit_acceleration: "..tostring(game.hit_acceleration)..
		"\n[0] [P] fail_acceleration: "..tostring(game.fail_acceleration)..
		"\n[ - ]  [  max_velocity: "..tostring(game.max_velocity)..
		"\n[=]  ]  min_velocity: "..tostring(game.min_velocity)
		, xcoord, ycoord, boxwidth, 'left')
	end
end
