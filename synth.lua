require "moan"

Synth = {}
Synth.__index = Synth

local trackname = 'tracks/'..'tipptipp.ogg'
local beats_per_minute = 90
local offset = 5

function Synth.create()
	local synth = {}
	setmetatable(synth, Synth)

	synth.mute_file = "mute.txt"
	if not love.filesystem.exists(synth.mute_file) then
		love.filesystem.write(synth.mute_file, "false")
	end

	if love.filesystem.read(synth.mute_file) == "true" then
		synth.mute = true
	else
		synth.mute = false
	end

	synth.sources = {
		synth:createSource("c"),
		synth:createSource("e"),
		synth:createSource("g"),
	}

	synth.music = love.audio.play(trackname, "stream", true)
	synth:toggle_music('stop')

	synth.bpm = beats_per_minute
	synth.offset = offset

	return synth
end

function Synth:play(track)
	--[[
	if not self.mute then
		love.audio.play(self.sources[track + 1])
	end
	--]]
end

function Synth:createSource(pitch)
	local len = 0.2
	local len_unit = 0.2/20
	local amp = 0.7
	local data = Moan.newSample(
		Moan.compress(Moan.envelope(
			Moan.osc.sin(Moan.pitch(pitch, 3), amp),
			Moan.env.adsr(len_unit * 6, len_unit * 4, len_unit*7, len_unit*3, amp*3.0, amp),
			Moan.env.fall(0.2, 0.05)
		)
	), len)
	return love.audio.newSource(data)
end

function Synth:is_muted()
	return self.mute
end

function Synth:toggle_mute(new_mute)
	self.mute = new_mute or not self.mute
	if self.mute then
		love.audio.setVolume(0)
	else
		love.audio.setVolume(1)
	end
	love.filesystem.write(self.mute_file, tostring(self.mute))
end

function Synth:toggle_music(new_state)
	if new_state then
		self.music[new_state](self.music)
	else
		if self.music:isPaused() or self.music:isStopped() then
			self.music:play()
		else
			self.music:pause()
		end
	end
end

