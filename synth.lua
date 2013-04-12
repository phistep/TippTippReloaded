Synth = {}
Synth.__index = Synth

local len = 0.3
local rate = 44100
local bits = 16
local channel = 1

function Synth.create()
	local synth = {}
	setmetatable(synth, Synth)

	local soundData = love.sound.newSoundData(len * rate, rate, bits, channel)
	local amplitude = 1.0
	local osc = Oscillator(get_frequency(1), saw)
	local osc2 = Oscillator(get_frequency(4), saw)
	local osc3 = Oscillator(get_frequency(8), saw)

	for i = 1, len * rate do
		local sample = amplitude * (osc() + osc2() + osc3()) / 3
		soundData:setSample(i, sample)
	end

	synth.source = love.audio.newSource(soundData)

	return synth
end

function Synth:play()
	love.audio.play(self.source)
end

function Oscillator(freq, f)
	local phase = 0
	return function()
		phase = phase + 2 * math.pi/rate
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
