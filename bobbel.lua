bobbel = {}
bobbel.__index = bobbel


function bobbel.create(angle, track)
   local bbl = {}
   setmetatable(bbl, bobbel)
   bbl.angle = angle
   bbl.track = track
   return bbl
end