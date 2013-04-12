Bobbel = {}
Bobbel.__index = Bobbel

function Bobbel.create(angle, track)
	local bbl = {}
	setmetatable(bbl, Bobbel)
	bbl.angle = angle
	bbl.track = track
	return bbl
end

function Bobbel:draw()
	love.graphics.draw(
		state.bobbel_canvas,
		state.center.x, state.center.y,
		self.angle, 1, 1,
		state.bobbel_radius,
		-(state.field_radius - self.track * state.track_distance - state.bobbel_radius)
	)
end

function Bobbel:update(dt)
	self.angle = self.angle + state.angular_velocity * dt
end
