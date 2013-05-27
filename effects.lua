Effects = {}
Effects.__index = Effects

function Effects:glowShape(type, style, linewidth, ...)
	-- if type is 'line' the style is the linewidth
	if type == 'line' then
		local lwidth = style
		self:linedShape(lwidth, type, linewidth, ...)
	elseif style == 'line' then
		self:linedShape(linewidth, type, ...)
	elseif type == 'rectangle' then
		-- linewidth is the x coordinate
		self:rectangle(linewidth, ...)
	elseif type == 'circle' then
		-- linewidth is the x coordinate
		self:circle(linewidth, ...)
	elseif type == 'arc' then
		-- linewidth is the x coordinate
		self:arc(linewidth, ...)
	end
end

function Effects:linedShape(lwidth, type, ...)
	local r, g, b, a = love.graphics.getColor()
	--local lwidth = love.graphics.getLineWidth()

	love.graphics.setColor(r, g, b, 20)

	for i = lwidth + 6, lwidth + 1, -1 do
		if i == lwidth + 1 then
			i = lwidth
			love.graphics.setColor(r, g, b, a)
		end

		love.graphics.setLineWidth(i)

		if type == "line" then
			love.graphics[type](...)
		else
			love.graphics[type]("line", ...)
		end
	end
	love.graphics.setColor(r, g, b, a)
end

function Effects:rectangle(x, y, width, height)
	local r, g, b, a = love.graphics.getColor()

	love.graphics.setColor(r, g, b, 20)

	for i = 6, 1, -1 do
		if i == 1 then
			i = 0
			love.graphics.setColor(r, g, b, a)
		end

		love.graphics.rectangle('fill', x - i, y - i, width + 2*i, height + 2*i)
	end
	love.graphics.setColor(r, g, b, a)
end

function Effects:circle(x, y, radius, segments)
	local r, g, b, a = love.graphics.getColor()

	love.graphics.setColor(r, g, b, 20)

	for i = radius + 6, radius + 1, -1 do
		if i == radius + 1 then
			i = radius
			love.graphics.setColor(r, g, b, a)
		end

		love.graphics.circle('fill', x, y, i, segments)
	end
	love.graphics.setColor(r, g, b, a)
end

function Effects:arc(x, y, radius, angle1, angle2, segments)
	local r, g, b, a = love.graphics.getColor()

	love.graphics.setColor(r, g, b, 20)

	for i=6, 1, -1 do
		if i == 1 then
			i = 0
			love.graphics.setColor(r, g, b, a)
		end

		love.graphics.arc("fill", x, y, radius + i, angle1 - math.rad(i), angle2 + math.rad(i), segments)
	end
	love.graphics.setColor(r, g, b, a)
end

function Effects:drawArc(x, y, r, angle1, angle2, segments)
	segments = segments or r
	local i = angle1
	local j = 0
	local step = 2 * math.pi / segments

	while i < angle2 do
		j = angle2 - i < step and angle2 or i + step
		love.graphics.line(x + (math.cos(i) * r), y - (math.sin(i) * r), x + (math.cos(j) * r), y - (math.sin(j) * r))
		i = j
	end
end

return Effects
