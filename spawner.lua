Spawner = {}
Spawner.__index = Spawner

function Spawner.create(time_between_bobbels)
	local spawner = {}
	setmetatable(spawner, Spawner)

	spawner.time_between_bobbels = time_between_bobbels or 1
	spawner.time = 0
	spawner.last_bobbel = 0
	spawner.last_new_function = 0
	spawner.active_function = nil
	spawner.func_terminated = false
	spawner.functions = {
		spawner.random,
      		spawner.inner_track,
		spawner.middle_track,
		spawner.outer_track,
	}

	spawner:pick_random_func()

	return spawner
end

function Spawner:pick_random_func()
	self.active_function = self.functions[math.random(1, #self.functions)]
	self.last_new_function = self.time
	self.last_bobbel = 0
	self.func_terminated = false
end
	

function Spawner:update(dt, time_between_bobbels)
	self.time = self.time + dt
	self.time_between_bobbels = time_between_bobbels or self.time_between_bobbels

	if self.func_terminated then
		self:pick_random_func()
	end

end

function Spawner:new_bobbel_track()
	local track, terminated = self.active_function(self)
	if terminated then
		self.func_terminated = terminated
	end
	return track
end

function Spawner:random()
	local t = self.time - self.last_new_function
	local gap = self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= 10 then
		return nil, true
	elseif t >= limit then
		self.last_bobbel = t
		randnum = math.random(0, 3)
		if randnum ~= 3 then
			return randnum
		end
	end
end

function Spawner:inner_track()
	local t = self.time - self.last_new_function
	local gap = 0.5 * self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= 10 then
		return nil, true
	elseif t >= limit then
		self.last_bobbel = t
		return 2
	end
end

function Spawner:middle_track()
	local t = self.time - self.last_new_function
	local gap = 0.5 * self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= 10 then
		return nil, true
	elseif t >= limit then
		self.last_bobbel = t
		return 1
	end
end

function Spawner:outer_track()
	local t = self.time - self.last_new_function
	local gap = 0.5 * self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= 10 then
		return nil, true
	elseif t >= limit then
		self.last_bobbel = t
		return 0
	end
end
