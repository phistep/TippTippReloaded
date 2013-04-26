require "moan"

Synth = {}
Synth.__index = Synth

function Synth.create()
	local synth = {}
	setmetatable(synth, Synth)

	synth.mute = false
	synth.sources = {
		synth:createSource("c"),
		synth:createSource("e"),
		synth:createSource("g"),
	}

	return synth
end

function Synth:play(track)
	if not self.mute then
		love.audio.play(self.sources[track + 1])
	end
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
end

