Animations = {}
Animations.__index = Animations

Anim = {}
Anim.__index = Anim

local animation_types = {
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

	if animation_types[anim_type].init then animation_types[anim_type].init(self, ...)
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
