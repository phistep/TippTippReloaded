require 'bobbel'

local bobbels = {}
local bobbel_radius = 15
local field_radius = 200
local center = { x = 300, y = 300 }
local angular_velocity = math.pi/4
local track_distance = 25
local total_time = 0
local time_between_bobbels = 0.95

function love.load()
	-- create global bobbel canvas
	bobbel_canvas = love.graphics.newCanvas(2 * bobbel_radius, 2 * bobbel_radius)
	love.graphics.setCanvas(bobbel_canvas)
	love.graphics.setColor(10, 255, 0)
	love.graphics.setLineWidth(3)
	love.graphics.circle("line", bobbel_radius, bobbel_radius, bobbel_radius-5, 20)
	
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
	love.graphics.circle("line", center.x, center.y, field_radius)
	love.graphics.circle("line", center.x, center.y, field_radius - track_distance)
	love.graphics.circle("line", center.x, center.y, field_radius - 2*track_distance)

	love.graphics.setColor(255, 255, 255)
	for _, bbl in pairs(bobbels) do
		love.graphics.draw(	bobbel_canvas,
							center.x, center.y,
							bbl.angle, 1, 1,
							bobbel_radius,
							-(field_radius - bbl.track*track_distance - bobbel_radius))
	end
	
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function love.update(dt)
	total_time = total_time + dt
	if total_time >= time_between_bobbels then
		table.insert(bobbels, Bobbel.create(0, math.random(0, 2)))
	end
	total_time = total_time % time_between_bobbels
	
	for _, bbl in pairs(bobbels) do
		bbl.angle = bbl.angle + angular_velocity * dt
	end
end
