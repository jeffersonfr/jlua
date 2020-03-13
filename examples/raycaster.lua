layer0 = canvas.new()

local w, h = layer0:size()

config = {
	width = w, -- width of window
	height = h, -- height of window
	fov = 60, -- field of view (degrees)
	sliver_width = 6, -- thickness of each wall sliver (pixels)
	ray_resolution = 0.02, -- lower number = higher resolution = more accurate = more CPU
	wall_zoom = 600, -- how much to zoom the walls, play with to see results
	player_speed = 0.2, -- how fast the player moves forward
	player_turn = 8, -- how fast the player turns
	fish_eye = true -- should the engine remove the "fish eye" side effect?
}

-- don't change this stuff
config.sliver_width = math.floor(config.sliver_width + 0.5)
config.slivers_per_screen = math.ceil(config.width / config.sliver_width)
config.ang_per_sliver = config.fov / config.slivers_per_screen
config.cy = math.floor(config.height / 2)

map = {
	width = 11, -- width of map
	height = 11, -- height of map
	start = {2.5, 2.5}, -- x, y cell to start in
	startang = 90, -- what direction to face in

	-- map data... 1-9 are colored walls, 0 is no wall
	{1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},
	{3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4},
	{4, 0, 0, 0, 0, 0, 7, 8, 7, 0, 3},
	{3, 0, 5, 0, 0, 0, 8, 9, 8, 0, 4},
	{4, 0, 6, 0, 0, 0, 7, 0, 7, 0, 3},
	{3, 0, 5, 0, 0, 0, 8, 0, 8, 0, 4},
	{4, 0, 6, 5, 6, 0, 7, 0, 7, 0, 3},
	{3, 0, 0, 0, 0, 0, 8, 0, 0, 0, 4},
	{4, 0, 6, 0, 3, 0, 7, 8, 7, 0, 3},
	{3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4},
	{1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},
}

player = {
	x = map.start[1],
	y = map.start[2],
	ang = map.startang,
}

function printf(...) 
	io.write(string.format(unpack(arg))) 
end

-- gets the wall color of the map, with bounds checking
function get_map(x, y)
	x = math.floor(x)
	y = math.floor(y)
	if (x < 1 or y < 1 or x > map.width or y > map.height) then
		return 1
	end
	return map[y][x]
end

-- casts a ray starting at (x, y), pointing at ang direction...
-- returns the distance the ray travelled until it hit a wall, and the wall's color
function cast_ray(x, y, ang)
	local dist = 0
	local col = 1
	local dx = math.cos(ang * math.pi / 180) * config.ray_resolution
	local dy = math.sin(ang * math.pi / 180) * config.ray_resolution
	repeat
		x = x + dx -- travel
		y = y + dy
		dist = dist + config.ray_resolution -- track distance travelled
		col = get_map(x, y)
		if (col ~= 0) then -- is map location still blank?
			break -- no? so we hit a wall... stop casting
		end
	until (false)
	-- return the distance travelled, and the color of the wall that finally stopped our ray
	return dist, col
end

function redraw()
	local sx = 0
	local ang = player.ang - (config.fov / 2)
	local ray_len
	local col
	local height
	local start_wall

	-- start from the left side, and cast a ray for each sliver
	for s = 0, config.slivers_per_screen do
		-- cast the ray
		ray_len, col = cast_ray(player.x, player.y, ang)
		if (not config.fish_eye) then
			-- remove the fish eye side effect
			ray_len = ray_len * math.cos((player.ang - ang) * math.pi / 180)
		end
		-- calculate height of wall
		height = math.floor(config.wall_zoom / ray_len)
		start_wall = math.floor(config.cy - height / 2)
		-- clip wall to screen
		if (start_wall < 0) then
			height = height + start_wall
			start_wall = 0
		else
			-- wall isn't too high, so draw sky
			layer0:color(200, 200, 255, 255)--config.sky_color)
			layer0:rect("fill", sx, 0, config.sliver_width, start_wall)
		end
		if (start_wall + height > config.height) then
			height = config.height - start_wall
		else
			-- wall isn't too long, so draw floor
			layer0:color(63, 63, 0, 255)--config.floor_color)
			layer0:rect("fill", sx, start_wall + height, config.sliver_width, config.height - start_wall - height)
		end
		
		-- draw the wall
		if (col == 1) then
			layer0:color(0, 0, 255, 255)
		elseif (col == 2) then
			layer0:color(0, 255, 0, 255)
		elseif (col == 3) then
			layer0:color(0, 255, 255, 255)
		elseif (col == 4) then
			layer0:color(255, 0, 0, 255)
		elseif (col == 5) then
			layer0:color(255, 0, 255, 255)
		elseif (col == 6) then
			layer0:color(255, 255, 0, 255)
		elseif (col == 7) then
			layer0:color(255, 255, 255, 255)
		elseif (col == 8) then
			layer0:color(0, 0, 0, 255)
		end

		layer0:rect("fill", sx, start_wall, config.sliver_width, height)
		-- increase our sliver position
		sx = sx + config.sliver_width
		-- increase our sliver angle
		ang = ang + config.ang_per_sliver
	end
end

while (true) do
	redraw()

	--system.sleep(10)

	-- events
	if (input_enable == false) then
		return
	end

	local e = events.get()

	if (e ~= nil) then
		print("event:: [" .. e.code .. ", " .. e.symbol .. "] " .. e.type)

		local ox = player.x
		local oy = player.y

		if (e.symbol == "up") then
			-- move player forward
			player.x = player.x + math.cos(player.ang * math.pi / 180) * config.player_speed
			player.y = player.y + math.sin(player.ang * math.pi / 180) * config.player_speed
		elseif (e.symbol == "down") then
			-- move player backwards
			player.x = player.x - math.cos(player.ang * math.pi / 180) * config.player_speed
			player.y = player.y - math.sin(player.ang * math.pi / 180) * config.player_speed
		elseif (e.symbol == "right") then
			player.ang = (player.ang + config.player_turn) % 360
		elseif (e.symbol == "left") then
			player.ang = (player.ang + 360 - config.player_turn) % 360
		end

		-- clip the player to the walls
		if (get_map(player.x, player.y) ~= 0) then
			player.x = ox
			player.y = oy
		end
	end
end

