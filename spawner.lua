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
		spawner.linear,
		spawner.saw,
		spawner.triangle,
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

-- ? ? ?
-- ? ? ?
-- ? ? ?
function Spawner:random()
	local max_loops = 10
	local t = self.time - self.last_new_function
	local gap = self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= max_loops then
		return nil, true
	elseif t >= limit then
		self.last_bobbel = t
		randnum = math.random(0, 3)
		if randnum ~= 3 then
			return randnum
		end
	end
end

-- | O |
-- | O |
-- | O |
function Spawner:linear(track)
	local max_loops = 10
	local t = self.time - self.last_new_function
	local gap = 0.5 * self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= max_loops then
		return nil, true
	elseif t >= limit then
		self.last_bobbel = t

		track = track or math.floor(self.last_new_function % 3)
		return track
	end
end

-- O | |
-- | O |
-- | | O
--
-- max loops: 3*n
function Spawner:saw()
	local max_loops = 12
	local t = self.time - self.last_new_function
	local gap = 0.5 * self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= max_loops then
		return nil, true
	elseif t >= limit then
		self.last_bobbel = t

		local track = loops % 4
		if track ~= 3 then
			local orientation = math.floor(self.last_new_function % 2)
			if orientation == 0 then
				return track
			else
				return 2 - track
			end
		end
	end
end

-- O | |
-- | O |
-- | | O
-- | O |
-- O | |
--
-- max loops: 4*n + 1
function Spawner:triangle()
	local max_loops = 9
	local t = self.time - self.last_new_function
	local gap = self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= max_loops then
		return nil, true
	elseif t >= limit then
		self.last_bobbel = t

		local orientation = math.floor(self.last_new_function % 2)
		if orientation == 0 then
			return math.abs((loops % 4 - 2))
		else
			return 2 - math.abs((loops % 4 - 2))
		end
	end
end
