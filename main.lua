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
local controler = {Bobbel.create(1.5*math.pi, 0), Bobbel.create(1.5*math.pi, 1), Bobbel.create(1.5*math.pi, 2)}

function love.load()
	-- create global bobbel canvas
	state.bobbel_canvas = love.graphics.newCanvas(2 * state.bobbel_radius, 2 * state.bobbel_radius)
	love.graphics.setCanvas(state.bobbel_canvas)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(3)
	love.graphics.circle("line", state.bobbel_radius, state.bobbel_radius, state.bobbel_radius-5, 20)

	for _, cont in ipairs(controler) do
		cont.pressed = false
	end
	controler[1].key = 'd'
	controler[2].key = 's'
	controler[3].key = 'a'

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

	for _, cont in ipairs(controler) do
		if cont.pressed then
			love.graphics.setColor(255, 0, 0)
		else
			love.graphics.setColor(255, 255, 255)
		end
		cont:draw(state)
	end

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function love.update(dt)
	state.total_time = state.total_time + dt
	if state.total_time >= state.time_between_bobbels then
		table.insert(bobbels, Bobbel.create(0, math.random(0, 2)))
	end
	state.total_time = state.total_time % state.time_between_bobbels

	for _, bbl in pairs(bobbels) do
		bbl:update(state, dt)
	end
end

function love.keypressed(key)
	for _, cont in ipairs(controler) do
		if cont.key == key then
			cont.pressed = true
		end
	end
end

function love.keyreleased(key)
	for _, cont in ipairs(controler) do
		if cont.key == key then
			cont.pressed = false
		end
	end
end
