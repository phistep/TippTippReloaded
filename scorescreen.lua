local scorescreen = {}
local http = require("socket.http")

function scorescreen:init()
	self.font_description = love.graphics.newFont("assets/polentical_neon_bold.ttf", 20)
	self.font_score = love.graphics.newFont("assets/polentical_neon_bold.ttf", 50)
	self.font_other = love.graphics.newFont("assets/polentical_neon_bold.ttf", 30)

	self.color_description = { r = 45, g = 45, b = 45}
	self.color_scoreboard = { r = 20, g = 128, b = 201}

	self.keys_quit = { ['escape'] = true, ['q'] = true }
	self.keys_no_reaction = { ['a'] = true, ['s'] = true, ['d'] = true, ['j'] = true, ['k'] = true, ['l'] = true, ['left'] = true, ['down'] = true, ['right'] = true }
	self.keys_submit_score = { ['return'] = true}

	self.name_file = "name.txt"
	self.submit_url = "http://ps0ke.de/code/tipptippreloaded/highscores/"
	self.max_name_length = 12
	self.blink_time = 0.75
	self.cursor = "_"

	if not love.filesystem.exists(self.name_file) then
		love.filesystem.write(self.name_file, "")
	end
end

function scorescreen:enter(previous, menu, hits, fails, score, multiplier, spree, max_spree, time)
	self.game = previous
	self.menu = menu
	self.hits = hits
	self.fails = fails
	self.score = score
	self.multiplier = multiplier
	self.spree = spree
	self.max_spree = max_spree
	self.time = time

	self.timestring = string.format("%02d:%02d", self.time / 60, self.time % 60)
	self.accuracy = math.floor((self.hits / (self.hits + self.fails)) * 10000 + 0.5) / 100 -- round the percentage to 2 digits

	self.name = love.filesystem.read(self.name_file)
	self.insert_mode = false
	self.saved = false
	self.total_blink_time = 0
	self.cursor_state = ""
end

function scorescreen:update(dt)
	self.total_blink_time = self.total_blink_time + dt

	if self.total_blink_time >= self.blink_time then
		self.total_blink_time = 0
		if self.cursor_state == "" and self.name:len() < self.max_name_length and self.insert_mode then
			self.cursor_state = self.cursor
		else
			self.cursor_state = ""
		end
	end
end

function scorescreen:draw()
	Effects:start_glow()

	love.graphics.setFont(self.font_description)
	love.graphics.setColor(self.color_description.r, self.color_description.g, self.color_description.b)
	love.graphics.printf("score:", 10, 20, love.graphics.getWidth() - 20, "center")
	love.graphics.printf("time played:", 10, 120, love.graphics.getWidth() - 20, "center")
	love.graphics.printf("best spree:", 10, 220, love.graphics.getWidth() - 20, "center")
	love.graphics.printf("hit accuracy:", 10, 320, love.graphics.getWidth() - 20, "center")

	if self.insert_mode or self.saved then
		love.graphics.printf("name:", 10, 420, love.graphics.getWidth() - 20, "center")
	else
		love.graphics.printf("[Return] to submit online", 10, 420, love.graphics.getWidth() - 20, "center")
	end

	if self.saved then
		love.graphics.printf("saved!", 10, 475, love.graphics.getWidth() - 20, "center")
		love.graphics.printf("view highscores at: "..self.submit_url, 10, 525, love.graphics.getWidth() - 20, "center")
	end

	love.graphics.setColor(self.color_scoreboard.r, self.color_scoreboard.g, self.color_scoreboard.b)
	love.graphics.setFont(self.font_score)
	love.graphics.printf(self.score, 10, 40, love.graphics.getWidth() - 20, "center")
	love.graphics.setFont(self.font_other)
	love.graphics.printf(self.timestring, 10, 140, love.graphics.getWidth() - 20, "center")
	love.graphics.printf(self.max_spree, 10, 240, love.graphics.getWidth() - 20, "center")
	love.graphics.printf(self.accuracy.."%", 10, 340, love.graphics.getWidth() - 20, "center")

	if self.insert_mode or self.saved then
		love.graphics.printf(self.name..self.cursor_state, 10, 440, love.graphics.getWidth() - 20, "center")
	end

	Effects:stop_glow()
end

function scorescreen:keypressed(key)
	if self.insert_mode then
		-- if key is word character, add to string
		if key and key:len() == 1 and key:match('[%w]') and self.name:len() < self.max_name_length then
			self.name = self.name..key
		end

		-- delete last character in string
		if key == "backspace" then
			self.name = string.sub(self.name, 1, self.name:len()-1)
		end

		-- submit name + score to server on return
		if key == "return" and self.name:len() > 0 then
			love.filesystem.write(self.name_file, self.name)
			self:submit()
		end

		if key == "escape" then
			self.insert_mode = false
		end
	else
		if self.keys_quit[key] then
			love.event.push('quit')
		elseif not self.saved and self.keys_submit_score[key] then
			self.insert_mode = true
		elseif not self.keys_no_reaction[key] then
			Gamestate.switch(self.menu)
		end
	end
end

function scorescreen:submit()
	local params = ""
	params = params.."name="..self.name
	params = params.."&score="..tostring(self.score)
	params = params.."&hits="..tostring(self.hits)
	params = params.."&fails="..tostring(self.fails)
	params = params.."&spree="..tostring(self.max_spree)
	params = params.."&time="..tostring(self.time)

	response, code, header = http.request(self.submit_url, params)
	if code == 200 then
		self.insert_mode = false
		self.saved = true
	end
end

return scorescreen
