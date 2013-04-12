Bobbel = {}
Bobbel.__index = Bobbel


function Bobbel.create(angle, track)
	local bbl = {}
	setmetatable(bbl, Bobbel)
	bbl.angle = angle
	bbl.track = track
	return bbl
end
