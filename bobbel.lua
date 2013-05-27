Bobbel = {}
Bobbel.__index = Bobbel

function Bobbel.create(angle, track, consistent)
	local bbl = {}
	setmetatable(bbl, Bobbel)
	bbl.angle = angle
	bbl.track = track
	bbl.consistent = consistent
	return bbl
end

function Bobbel:draw(state, bobbel_canvas, spawner_postion, killer_position)
	bobbel_canvas = bobbel_canvas or state.bobbel_canvas
	spawner_postion = spawner_postion or 0
	killer_position = killer_position or math.rad(360)
	local r, g, b, a = love.graphics.getColor()

	if not self.consistent then
		local angle = self.angle
		local limit = math.rad(15)

		if angle >= killer_position - limit then
			angle = math.abs(killer_position - angle) + spawner_postion
		end
		if angle - spawner_postion <= limit then
			local alpha = a * math.pow((angle - spawner_postion) / limit, 2)
			love.graphics.setColor(r, g, b, alpha)
		end
	end

	love.graphics.draw(
		bobbel_canvas,
		state.center.x, state.center.y,
		self.angle, 1, 1,
		state.bobbel_radius,
		-(state.gamefield_radius - self.track * state.track_distance - state.bobbel_radius)
	)
	love.graphics.setColor(r, g, b, a)
end

function Bobbel:update(state, dt, controller_velocity)
	controller_velocity = controller_velocity or 0
	self.angle = self.angle + (state.angular_velocity - controller_velocity) * dt
end
