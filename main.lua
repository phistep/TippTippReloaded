require 'bobbel'

local state = {
	bobbel_radius = 15,
	field_radius = 200,
	center = { x = 300, y = 300 },
	angular_velocity = math.pi/4,
	track_distance = 25,
	total_time = 0,
	time_between_bobbels = 0.95,
	bobbel_canvas = nil
}

local bobbels = {}

function love.load()
	-- create global bobbel canvas
	state.bobbel_canvas = love.graphics.newCanvas(2 * state.bobbel_radius, 2 * state.bobbel_radius)
	love.graphics.setCanvas(state.bobbel_canvas)
	love.graphics.setColor(10, 255, 0)
	love.graphics.setLineWidth(3)
	love.graphics.circle("line", state.bobbel_radius, state.bobbel_radius, state.bobbel_radius-5, 20)

	-- window settings
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(10, 10, 10)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(1)
end


function love.draw()
	love.graphics.setCanvas()

	love.graphics.setColor(255, 20, 0)
	love.graphics.setLineWidth(2)
	love.graphics.circle("line", state.center.x, state.center.y, state.field_radius)
	love.graphics.circle("line", state.center.x, state.center.y, state.field_radius - state.track_distance)
	love.graphics.circle("line", state.center.x, state.center.y, state.field_radius - 2*state.track_distance)

	love.graphics.setColor(255, 255, 255)
	for _, bbl in pairs(bobbels) do
		bbl:draw(state)
	end

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function love.update(dt)
	-- Updating bobbels
	for _, bbl in pairs(bobbels) do
		bbl:update(state, dt)
	end

	-- Spawning new bobbels
	spawn_bobbel(state, dt, bobbels)

	-- Removing bobbels
	remove_bobbel(bobbels)
end

function spawn_bobbel(state, dt, bobbels)
	state.total_time = state.total_time + dt
	if state.total_time >= state.time_between_bobbels then
		table.insert(bobbels, Bobbel.create(0, math.random(0, 2)))
	end
	state.total_time = state.total_time % state.time_between_bobbels
end


function remove_bobbel(bobbels)
	for bblindex, bbl in pairs(bobbels) do
		if bbl.angle > 2*math.pi then
			table.remove(bobbels, bblindex)
		end
	end
end
