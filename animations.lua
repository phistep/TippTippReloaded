Animations = {}
Animations.__index = Animations

Anim = {}
Anim.__index = Anim

local animation_types = {
	hit = {},
}

function Animations.create()
        local animations = {}
        setmetatable(animations, Animations)

	animations.active_anims = {}

	return animations
end

function Anim.create(anim_type, ...)
        local anim = {}
        setmetatable(anim, Anim)

	anim.t = 0
	anim.finished = false

	if animation_types[anim_type].init then animation_types[anim_type].init(anim, ...) end
	anim.draw = animation_types[anim_type].draw
	anim.update = animation_types[anim_type].update

	return anim
end

function Animations:add(anim_type, ...)
	local new_anim = Anim.create(anim_type, ...)
	table.insert(self.active_anims, new_anim)
end

function Animations:update(dt)
	for idxanim, anim in ipairs(self.active_anims) do
		anim:update(dt)
		if anim.finished then
			table.remove(self.active_anims, idxanim)
		end
	end
end

function Animations:draw(dt)
	for idxanim, anim in ipairs(self.active_anims) do
		anim:draw(dt)
	end
end

function animation_types.hit.init(self, bobbel, drawing)
	local r = drawing.gamefield_radius - bobbel.track * drawing.track_distance
	self.x = drawing.center.x - math.sin(bobbel.angle) * r
	self.y = drawing.center.y + math.cos(bobbel.angle) * r
	self.r0 = drawing.bobbel_radius - 4
	self.color = drawing.color_hit_animation
end

function animation_types.hit.update(self, dt)
	self.t = self.t + dt
	if self.t > 1 then
		self.finished = true
	end
end

function animation_types.hit.draw(self)
	love.graphics.setLineWidth(2)
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, 255 * (1 - self.t))
	love.graphics.circle('line', self.x, self.y, self.r0 + 10 * self.t)
end
