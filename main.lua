Gamestate = require 'hump.gamestate'

local menu = require 'menu'

function love.load()
	love.graphics.setCaption("TippTippReloaded")
	Gamestate.registerEvents()
	Gamestate.switch(menu)
end

