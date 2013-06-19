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
		--[[
		spawner.random,
		spawner.linear,
		spawner.saw,
		spawner.triangle,
		spawner.oscilator,
		--]]
		spawner.music,
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
	local tracks, terminated = self.active_function(self)
	if terminated then
		self.func_terminated = terminated
	end
	return tracks
end

function Spawner:to_beat(t)
	return t / self.time_between_bobbels
end

function Spawner:to_t(beat)
	return beat * self.time_between_bobbels
end

function Spawner:rnd(tracks, tdiff)
	tdiff = tdiff or 0
	if tracks == 1 then
		return { [math.random(0, 2)] = tdiff }
	elseif tracks == 2 then
		local blank_track = math.random(0, 2)
		return { [(blank_track + 1) % 3] = tdiff, [(blank_track + 2) % 3] = tdiff }
	elseif tracks == 3 then
		return { [0] = tdiff, [1] = tdiff, [2] = tdiff }
	else
		return {}
	end
end

function Spawner:music()
	local t = self.time - self.last_new_function
	local beat = math.floor(self:to_beat(self.last_bobbel))
	local limit = self:to_t(beat + 1)
	local tdiff = t - limit

	if tdiff >= 0 then
		self.last_bobbel = t
		print(math.floor(self:to_beat(t-4)))
		if beat < 16 then
			if beat == 0 then return self:rnd(1, tdiff) end

			local subbeat = beat - 0
			subbeat = subbeat % 4
			if subbeat == 0 then
				return self:rnd(2, tdiff)
			elseif subbeat == 1 then
				return {}
			elseif subbeat == 2  or subbeat == 3 then
				return self:rnd(1, tdiff)
			end
		elseif beat < 34 then
			local subbeat = beat - 16
			subbeat = subbeat % 4
			if subbeat == 1 or subbeat == 3 then
				return self:rnd(1, tdiff)
			elseif subbeat == 0 then
				return self:rnd(2, tdiff)
			end
		elseif beat < 98 then
			if beat == 36 then return {} end

			local subbeat = beat - 34
			subbeat = subbeat % 4
			if subbeat == 3 then
				return self:rnd(2, tdiff)
			elseif subbeat == 0 then
				return {}
			elseif subbeat == 2 or subbeat == 1 then
				return self:rnd(1, tdiff)
			end
		elseif beat < 130 then
			local subbeat = beat - 98
			if subbeat < 2 then
				return {}
			elseif subbeat < 4 then
				return self:rnd(1, tdiff)
			elseif subbeat < 6 then
				return {}
			elseif subbeat < 7 then
				return self:rnd(1, tdiff)
			elseif subbeat < 14 then
				--[[
				if subbeat == 8 or subbeat == 12 then
					return self:rnd(2, tdiff)
				end
				--]]
				return {}
			elseif subbeat < 15 then
				return self:rnd(1, tdiff)
			elseif subbeat < 18 then
				--[[
				if subbeat == 16 then
					return self:rnd(2, tdiff)
				end
				--]]
				return {}
			elseif subbeat < 19 then
				return self:rnd(1, tdiff)
			elseif subbeat < 20 then
				return {}
			elseif subbeat < 21 then
				return self:rnd(1, tdiff)
			elseif subbeat < 22 then
				return {}
			elseif subbeat < 23 then
				--return self:rnd(1, tdiff)
				return self:rnd(2, tdiff)
			elseif subbeat < 26 then
				--[[
				if subbeat == 24 then
					return self:rnd(2, tdiff)
				end
				--]]
				return {}
			elseif subbeat < 27 then
				return self:rnd(1, tdiff)
			elseif subbeat < 28 then
				return {}
			elseif subbeat < 29 then
				return self:rnd(1, tdiff)
			elseif subbeat < 30 then
				return {}
			elseif subbeat < 31 then
				return self:rnd(1, tdiff)
			elseif subbeat < 32 then
				--return self:rnd(2, tdiff)
				return {}
			end
		elseif beat < 162 then
			local subbeat = beat - 130
			subbeat = subbeat % 8
			if subbeat < 2 or subbeat == 7 then
				return {}
			else
				return self:rnd(1, tdiff)
			end
		end
	end
end

-- ? ? ?
-- ? ? ?
-- ? ? ?
function Spawner:random(max_loops)
	max_loops = max_loops or 10
	local t = self.time - self.last_new_function
	local gap = self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= max_loops then
		return nil, true
	end

	local tdiff = t - limit
	if tdiff >= 0 then
		self.last_bobbel = t

		local tracks = {}
		for i = 0, 2 do
			if math.random() < 0.4 then
				tracks[i] = tdiff
			end
		end
		return tracks
	end
end

-- | O |
-- | O |
-- | O |
function Spawner:linear(max_loops, track)
	max_loops = max_loops or 5
	local t = self.time - self.last_new_function
	local gap = 0.5 * self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= max_loops then
		return nil, true
	end

	local tdiff = t - limit
	if tdiff >= 0 then
		self.last_bobbel = t

		track = track or math.floor(self.last_new_function % 3)
		return { [track] = tdiff }
	end
end

-- O | |
-- | O |
-- | | O
--
-- max loops: 3*n
function Spawner:saw(max_loops, orientation)
	max_loops = max_loops or 12
	local t = self.time - self.last_new_function
	local gap = 0.5 * self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= max_loops then
		return nil, true
	end

	local tdiff = t - limit
	if tdiff >= 0 then
		self.last_bobbel = t

		local track = loops % 4
		if track ~= 3 then
			orientation = orientation or math.floor(self.last_new_function % 2)
			if orientation == 0 then
				return { [track] = tdiff }
			else
				return { [2 - track] = tdiff }
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
function Spawner:triangle(max_loops, orientation)
	max_loops = max_loops or 9
	local t = self.time - self.last_new_function
	local gap = self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= max_loops then
		return nil, true
	end

	local tdiff = t - limit
	if tdiff >= 0 then
		self.last_bobbel = t

		orientation = orientation or math.floor(self.last_new_function % 2)
		local track = math.abs((loops % 4 - 2))
		if orientation == 0 then
			return { [track] = tdiff }
		else
			return { [2 - track] = tdiff }
		end
	end
end

-- O | |
-- | O |
-- O | |
-- | O |
function Spawner:oscilator(max_loops, blank_track)
	max_loops = max_loops or 10
	local t = self.time - self.last_new_function
	local gap = self.time_between_bobbels
	local loops = math.floor(self.last_bobbel / gap)
	local limit = loops * gap + gap

	if loops >= max_loops then
		return nil, true
	end

	local tdiff = t - limit
	if tdiff >= 0 then
		self.last_bobbel = t

		blank_track = blank_track or math.floor(self.last_new_function % 3)
		local track = loops % 2 + 1
		return { [(blank_track + track) % 3] = tdiff }
	end
end
