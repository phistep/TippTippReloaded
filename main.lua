require 'bobbel'
require 'state'

local bobbels = {}

function love.load()
	-- create global bobbel canvas
	state.bobbel_canvas = love.graphics.newCanvas(2 * state.bobbel_radius, 2 * state.bobbel_radius)
	love.graphics.setCanvas(state.bobbel_canvas)
	love.graphics.setColor(10, 255, 0)
	love.graphics.circle("fill", state.bobbel_radius, state.bobbel_radius, state.bobbel_radius-2)

	for i=0, 9 do
		table.insert(bobbels, Bobbel.create((180 + i * 20) / 180 * math.pi, i % 3))
	end

	-- window settings
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(10, 10, 10)
	love.graphics.setLineStyle("smooth")
end


function love.draw()
	love.graphics.setCanvas()

	love.graphics.setColor(255, 20, 0)
	love.graphics.circle("line", state.center.x, state.center.y, state.field_radius)
	love.graphics.circle("line", state.center.x, state.center.y, state.field_radius - state.track_distance)
	love.graphics.circle("line", state.center.x, state.center.y, state.field_radius - 2*state.track_distance)

	love.graphics.setColor(255, 255, 255)
	for _, bbl in pairs(bobbels) do
		love.graphics.draw(
			state.bobbel_canvas,
			state.center.x, state.center.y,
			bbl.angle, 1, 1,
			state.bobbel_radius,
			-(state.field_radius - bbl.track * state.track_distance - state.bobbel_radius)
		)
	end

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function love.update(dt)
	for _, bbl in pairs(bobbels) do
		bbl.angle = bbl.angle + state.angular_velocity * dt
	end
end
