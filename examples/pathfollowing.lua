layer0 = canvas.new(1280, 720)

local w, h = layer0:size()

arena = {
	size = {
    width = w,
    height = h
  },
	bg = canvas.new("images/grid.png"):scale(w, h)
}

robot = {
	["location"] = {
		["x"] = math.random(w - 2*64) + 64, 
		["y"] = math.random(h - 2*64) + 64
	},
	["size"] = {
		["width"] = 48, 
		["height"] = 48
	},
	["camera"] = {
		["size"] = {
			["width"] = 32, 
			["height"] = 32
		}
	},
	["angle"] = {
		["index"] = 1,
		["count"] = 24,
	},
	["step"] = {
		["size"] = 6
	},
	["collide"] = false
}

angles_table = {}

for i=1,robot.angle.count do
	local a = (i-1)*2*math.pi/robot.angle.count

	angles_table[i] = {
		["radians"] = a,
		["degrees"] = 180*a/math.pi,
		["sin"] = math.sin(a),
		["cos"] = math.cos(a)
	}
end

function robot.walk()
	local dx = robot.step.size*angles_table[robot.angle.index].cos
	local dy = robot.step.size*angles_table[robot.angle.index].sin

	robot.location.x = robot.location.x + dx
	robot.location.y = robot.location.y + dy

	robot.collide = false

	if (robot.location.x < robot.size.width) then
		robot.collide = true
		robot.location.x = robot.size.width
	end

	if (robot.location.x > w - robot.size.width) then
		robot.collide = true
		robot.location.x = w - robot.size.width
	end

	if (robot.location.y < robot.size.height) then
		robot.collide = true
		robot.location.y = robot.size.height
	end
	
	if (robot.location.y > h - robot.size.height) then
		robot.collide = true
		robot.location.y = h - robot.size.height
	end

	robot.draw()
end

function robot.rotate(n)
	if (n == "-") then
		robot.angle.index = robot.angle.index + 1

		if (robot.angle.index > robot.angle.count) then
			robot.angle.index = 1
		end
	else 
		robot.angle.index = robot.angle.index - 1

		if (robot.angle.index < 1) then
			robot.angle.index = robot.angle.count
		end
	end
end

function robot.camera.capture()
	local degrees = math.fmod(90+angles_table[robot.angle.index].degrees, 360)
	local cw = 2*robot.camera.size.width
	local ch = 2*robot.camera.size.height

	camera = arena.bg:crop(robot.location.x - cw/2, robot.location.y - ch/2, cw, ch)
	camera = camera:scale(cw, ch)
	camera = camera:rotate(degrees)
	
	local w, h = camera:size()

	camera = camera:crop((w - cw/2)/2, (h - ch/2)/2, cw/2, ch/2)
	pixels = camera:pixels(0, 0, camera:size())

	layer0:compose(camera, arena.size.width-180, 120, 64, 64)

	grey = {}

	for i=1,#pixels,4 do
		local a = pixels[i+3]
		local r = pixels[i+2]
		local g = pixels[i+1]
		local b = pixels[i+0]
		local p = r*0.299+g*0.587+b*0.114

		if (a == 0xff and p < 0x80) then
			p = 0x00
		else
			p = 0xff
		end

		grey[#grey+1] = p
	end

	return grey
end

function robot.draw()
	local w = robot.size.width/2
	local h = robot.size.height/2
	local teta = robot.angle.count/3
	local points = {}

	for i=1,3 do
		local idx = math.fmod((i-1)*teta+robot.angle.index, robot.angle.count) + 1

		points[i] = {["x"] = w*angles_table[idx].cos, ["y"] = h*angles_table[idx].sin}
	end

	-- draw background
	layer0:compose(arena.bg, 0, 0, w, h)

	layer0:color("red")
	layer0:triangle("fill", 
		robot.location.x + points[1].x, robot.location.y + points[1].y,
		robot.location.x + points[2].x, robot.location.y + points[2].y,
		robot.location.x + points[3].x, robot.location.y + points[3].y
	)
	layer0:color("black")
	layer0:triangle("fill", 
		robot.location.x + points[1].x, robot.location.y + points[1].y,
		robot.location.x + points[2].x/2, robot.location.y + points[2].y/2,
		robot.location.x + points[3].x/2, robot.location.y + points[3].y/2
	)

	local array = {}

	grey = robot.camera.capture()

	for i=1,#grey do
		array[#array + 1] = grey[i]
		array[#array + 1] = grey[i]
		array[#array + 1] = grey[i]
		array[#array + 1] = 0xff
	end

	local buffer = canvas.new(robot.camera.size.width, robot.camera.size.height)

	-- TODO::buffer:pixels(array, 0, 0, robot.camera.size.width, robot.camera.size.height)

	layer0:color(0xa0404040)
	layer0:rect("fill", arena.size.width - 200, 50, 200, 160)
	layer0:color("white")
	layer0:text("camera", arena.size.width - 180, 60)
	
	-- sensors.camera
	layer0:compose(buffer, arena.size.width - 180, 120, 64, 64)
	layer0:rect("draw", arena.size.width - 180, 120, 64, 64)
	
	-- sensors.angle
	local degrees = math.fmod(360 - angles_table[robot.angle.index].degrees, 360)
	local tl, tr, bl, br = get_path_values()

	layer0:text("" .. tl .. ", " .. tr, arena.size.width - 96, 120)
	layer0:text("" .. bl .. ", " .. br, arena.size.width - 96, 120 + 32)
end

function random_robot()
	while true do
		if (robot.collide == true) then
			local count = math.random(5)

			for i=1,count do
				robot.rotate()
			end
		end

		robot.walk() 

		-- system.sleep(10)

		-- events.wait(); events.get()
	end
end

function get_path_values()
	local array = robot.camera.capture()

	local tl = 0
	local tr = 0
	local bl = 0
	local br = 0

	-- *----------*
	-- |XXX    XXX|
	-- |XXX    XXX|
	-- |XXX    XXX|
	-- |          |
	-- |          |
	-- |          |
	-- *----------*
	for j=1,robot.camera.size.height do
		for i=1,robot.camera.size.width do
			if (array[(j-1)*robot.camera.size.width+i] == 0x00) then
				-- top-left
				if (i < (1*robot.camera.size.width)/3 and j < (robot.camera.size.height)/2) then
					tl = tl + 1
				end

				-- top-right
				if (i > (2*robot.camera.size.width)/3 and j < (robot.camera.size.height)/2) then
					tr = tr + 1
				end
				
				-- bottom-left
				if (i < (1*robot.camera.size.width)/3 and j > (robot.camera.size.height)/2) then
					bl = bl + 1
				end

				-- bottom-right
				if (i > (2*robot.camera.size.width)/3 and j > (robot.camera.size.height)/2) then
					br = br + 1
				end
			end
		end
	end

	return tl, tr, bl, br
end

robot.draw()

local last = {
	["id"] = "", 
	["count"] = 0
}

-- limites inferior e superior
local inf = 8
local sup = 64

function render(tick)
		-- top-left, top-right, bottom-left, bottom-right
		tl, tr, bl, br = get_path_values()

		print("Path Sensor: ", tl, tr, bl, br)

		layer0:compose(arena.bg, 0, 0)

		-- angle.count = 24
		-- step.size = 6
		if (tl > tr) then
			robot.rotate("+")
		else
			robot.rotate("-")
		end

		robot.walk()

		canvas.compose(layer0, 0, 0)
end

