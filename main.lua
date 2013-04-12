require 'bobbel'

local bobbels = {}
local bobbel_radius = 10
local field_radius = 200
local center = { x = 300, y = 300 }
local angular_velocity = math.pi/4
local track_distance = 25


function love.load()
	-- create global bobbel canvas
	bobbel_canvas = love.graphics.newCanvas(2 * bobbel_radius, 2 * bobbel_radius)
	love.graphics.setCanvas(bobbel_canvas)
	love.graphics.setColor(10, 255, 0)
	love.graphics.circle("fill", bobbel_radius, bobbel_radius, bobbel_radius-2)
	
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
	love.graphics.circle("line", center.x, center.y, field_radius)
	love.graphics.circle("line", center.x, center.y, field_radius - track_distance)
	love.graphics.circle("line", center.x, center.y, field_radius - 2*track_distance)

	love.graphics.setColor(255, 255, 255)
	for _, bbl in pairs(bobbels) do
		love.graphics.draw(	bobbel_canvas,
							center.x, center.y,
							bbl.angle, 1, 1,
							bobbel_radius,
							-(field_radius - bbl.track * track_distance - bobbel_radius))
	end
	
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function love.update(dt)
	for _, bbl in pairs(bobbels) do
		bbl.angle = bbl.angle + angular_velocity * dt
	end
end