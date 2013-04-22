Synth = {}
Synth.__index = Synth

function Synth.create()
	local synth = {}
	setmetatable(synth, Synth)

	synth.len = 0.3
	synth.rate = 44100
	synth.bits = 16
	synth.channel = 1

	synth.mute = false
	synth.sources = {
		synth:createSource(1),
		synth:createSource(4),
		synth:createSource(7),
	}

	return synth
end

function Synth:play(track)
	if not self.mute then
		love.audio.play(self.sources[track + 1])
	end
end

function Synth:createSource(n)
	local soundData = love.sound.newSoundData(self.len * self.rate, self.rate, self.bits, self.channel)
	local amplitude = 1.0
	local osc = self:oscillator(get_frequency(n), saw)
	local osc2 = self:oscillator(get_frequency(n + 3), saw)
	local osc3 = self:oscillator(get_frequency(n + 7), saw)

	for i = 1, self.len * self.rate do
		local sample = amplitude * (osc() + osc2() + osc3()) / 3
		soundData:setSample(i, sample)
	end

	return love.audio.newSource(soundData)
end

function Synth:is_muted()
	return self.mute
end

function Synth:toggle_mute(new_mute)
	self.mute = new_mute or not self.mute
end

function Synth:oscillator(freq, f)
	local phase = 0
	return function()
		phase = phase + 2 * math.pi/self.rate
		if phase >= 2 * math.pi then
			phase = phase - 2 * math.pi
		end
		return f(freq * phase)
	end
end

function rect(x)
	if x % (2 * math.pi) < math.pi then
		return 1
	else
		return -1
	end
end

function saw(x)
	return (x % (2 * math.pi)) / (2 * math.pi)
end

function get_frequency(n)
	return 440 * math.pow(2, (n - 22)/12)
end
