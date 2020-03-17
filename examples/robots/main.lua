package.path = package.path .. ";?.lua"

layer0 = canvas.new(1280, 720)

screen_width, screen_height = layer0:size()

local safe = {
	["left"] = 32,
	["top"] = 32,
	["right"] = 32,
	["bottom"] = 32,
}

background = canvas.new("images/background.jpg")
sprites = canvas.new("images/sprites.png")

local w, h = sprites:size()
local iw = w/8
local ih = h/4
local radial_radius = 250
local linear_radius = radial_radius*10
local linear_range = 18

function GetImageList(image, cols, rows, offset, length)
	local w, h = image:size()
	local iw = w/cols
	local ih = h/rows

	t = {
		["frames"] = {},
		["size"] = {
			["width"] = iw, 
			["height"] = ih
		}
	}
	
	for i=offset,offset+length do
		local x = math.floor(math.fmod(i-1, w/iw))
		local y = math.floor((i-1)*iw/w)
		local img = image:crop(x*iw, y*ih, iw, ih)
		
		t.frames[#t.frames+1] = img
	end

	return t
end

tank = GetImageList(sprites, 8, 4, 1, 7)
rocket = sprites:crop(4*iw, 1*ih, iw, ih)
bullet = sprites:crop(5*iw, 1*ih, iw, ih)
cannon = sprites:crop(0*iw, 1*ih, iw, ih)
explosion = GetImageList(sprites, 8, 4, 10, 3)

sounds = {}

-- libav media player
--[[
player = nil;

function play_sound(id)
	if (player ~= nil) then
		if (player:status() == "stop" or player:status() == "finish") then
			player:stop()

			player = nil
		else
			return
		end
	end

	player = media.create("sounds/" .. id .. ".mp3")

	if (player ~= nil) then
		player:play()
	end
end
]]

function play_sound(id)
  --[[
	local max = 32

	if (#sounds < max) then
		player = media.create("sounds/" .. id .. ".wav")

		if (player ~= nil) then
			player:play()

			sounds[#sounds+1] = {
				["id"] = id,
				["player"] = player
			}
		end
	else
		-- INFO:: verify if exists any player with same id in idle state
		for i=1,#sounds do
			local sound = sounds[i]

			if (sound.id == id and (sound.player:status() == "stop" or sound.player:status() == "finish")) then
				sound.player:play()

				return
			end
		end

		-- INFO:: if not, remove the first player of the list and create another one
		for i=1,#sounds do
			local sound = sounds[i].player

			if (sound:status() == "stop" or sound:status() == "finish") then
				sound:stop()
		
				player = media.create("sounds/" .. id .. ".wav")

				if (player ~= nil) then
					player:play()

					sounds[i] = {
						["id"] = id,
						["player"] = player
					}

					break
				end
			end
		end
	end
  ]]
end

-- ambient_sound = media.create("sounds/background_sound.wav")

-- ambient_sound:play()

----------------------------------------------------------------------
-- Arena
----------------------------------------------------------------------
Arena = class(
	function(c, name)
		-- init
		if (name == nil) then
			name = "unamed"
		end

		c._name = name
		c._robots = {
		}
		c._objects = {
		}
		c._frames = 25
		c._cycles = 1000
	end
)

function Arena:name()
	return self._name
end

function Arena:add(robot)
	if (robot == nil) then
		return
	end

	while (true) do
		-- INFO:: get a random and free position in arena
		local x = math.random(screen_width-iw-safe.left-safe.right)
		local y = math.random(screen_height-ih-safe.top-safe.bottom)

		robot._location = {
			["x"] = x, 
			["y"] = y
		}
	
		if (#self._robots == 0) then
			break
		end

		if (self:collision_detect(-1, {
			["x"] = x,
			["y"] = y,
			["width"] = iw,
			["height"] = ih
		}) == false) then
			break
		end
	end

	robot._angle = math.random(360)
	robot._cannon = 0
	
	robot:arena(self)
	
	self._robots[#self._robots+1] = robot
end

function Arena:remove(robot)
	for i=#self._robots,1,-1 do
		if (robot == self._robots[i]) then
			table.remove(self._robots, i)

			break
		end
	end
end

function Arena:clear()
	self._robots = {}
end

function Arena:robots()
	return self._robots
end

function Arena:collision_detect(index, rect)
	local x1 = rect.x
	local y1 = rect.y
	local w1 = rect.width
	local h1 = rect.height

	for i=1,#self._robots do
		local robot = self._robots[i]

		if (i ~= index and robot:health() > 0) then
			local x2 = robot._location.x
			local y2 = robot._location.y
			local w2 = iw
			local h2 = ih

			-- INFO:: detect using circles
			local cr1 = w1/2
			local cx1 = x1+cr1
			local cy1 = y1+cr1
			local cr2 = w2/2;
			local cx2 = x2+cr2;
			local cy2 = y2+cr2;
			local dx = cx2-cx1;
			local dy = cy2-cy1;
			local cr3 = cr1+cr2;

			if ((dx*dx) + (dy*dy) < cr3*cr3) then
				return true, robot
			end

			--[[
			-- INFO:: detect using squares
			if (
				(x1+w1) > x2 and 
				x1 < (x2+w2) and 
				y1 < (y2+h2) and 
				(y1+h1) > y2) then

				return true, robot
			end
			]]
		end
	end

	return false, nil
end

function angle_between(angle, arc0, arc1)
	local n = (360 + (angle % 360)) % 360;
	local a = (360 + (arc0 % 360)) % 360;
	local b = (360 + (arc1 % 360)) % 360;

	a = (360000 + a) % 360;
	b = (360000 + b) % 360;

	if (a < b) then
		return a <= n and n <= b
	end

	return a <= n or n <= b
end

function Arena:robots_detect(ref, radius, angle, range)
	local tx = ref._location.x+iw/2
	local ty = ref._location.y+ih/2

	local enemies = {}

	for i=1,#self._robots do
		robot = self._robots[i]

		if (ref ~= robot) then
			local x = (robot._location.x+iw/2) - tx
			local y = (robot._location.y+ih/2) - ty
			local rad = math.atan(y/x)
			local degrees = ((180.0*rad)/math.pi)

			if (x > 0.0) then
				degrees = degrees + 180.0
			end

			--[[
			for i=1,#self._robots do
				local robot = self._robots[i]

				if (robot:health() > 0) then
					self._robots[i]:draw()
				end
			end
			]]

			local turn = math.fmod((180.0-degrees)-(ref._angle+90.0), 360.0)

			if (turn > 180.0) then
				turn = turn - 360.0
			elseif (turn < -180.0) then
				turn = turn + 360.0
			end

			local distance = math.sqrt(y*y+x*x)

			if (distance <= radius) then
				local flag = true

				if (angle ~= nil and range ~= nil) then
					flag = angle_between(turn, angle-range, angle+range)
				end

				if (flag == true) then
					enemies[#enemies+1] = {
						["angle"] = turn,
						["distance"] = distance
					}
				end
			end
		end
	end

	if (#enemies == 0) then
		return nil
	end

	return enemies
end

function Arena:post(event)
	local robot = event.robot
	local action = event.action
	local index = -1

	for i=1,#self._robots do
		if (self._robots[i] == event.robot) then
			index = i;

			break;
		end
	end

	if (action.name == "move") then
		local steps = action.params.steps*10
		local x = robot._location.x - steps*math.sin((robot._angle*math.pi)/180.0)
		local y = robot._location.y - steps*math.cos((robot._angle*math.pi)/180.0)

		-- INFO:: verify collision
		local collision, target = self:collision_detect(index, {
			["x"] = x,
			["y"] = y,
			["width"] = iw,
			["height"] = ih
		})

		if (collision == false) then
			if (x < safe.left or y < safe.top or (x+iw) > (screen_width-safe.left) or (y+ih) > (screen_height-safe.top)) then
				-- INFO:: avoid damage colliding with walls
				collision = false -- true
			else
				robot._location.x = x
				robot._location.y = y
			end
		end

		-- INFO:: add a range of [0..10]% of damage in case of collision
		if (collision == true) then
			-- play_sound("collision")

			robot._health = robot._health*(1.0 - math.random(10)/1000.0)

			if (robot._health <= 1) then
				robot._health = 0;
			end

			if (robot._health <= 0) then
				self._objects[#self._objects+1] = {
					["name"] = "explosion",
					["x"] = robot._location.x,
					["y"] = robot._location.y,
					["index"] = 0
				}
			end

			if (target ~= nil) then
				target._health = target._health*(1.0-math.random(10)/1000.0)

				if (target._health <= 0) then
					target._health = 0
				end

				if (target._health <= 0) then
					self._objects[#self._objects+1] = {
						["name"] = "explosion",
						["x"] = target._location.x,
						["y"] = target._location.y,
						["index"] = 0
					}
				end
			end
		end

		return {
			["collision"] = collision
		}
	elseif (action.name == "fire") then
		if (action.params.mode == "cannon") then
			self._objects[#self._objects+1] = {
				["name"] = "rocket",
				["x"] = robot._location.x-32*math.sin(((robot._angle+robot._cannon)*math.pi)/180.0),
				["y"] = robot._location.y-32*math.cos(((robot._angle+robot._cannon)*math.pi)/180.0),
				["angle"] = robot._angle+robot._cannon,
				["index"] = index,
				["step"] = 32
			}
		elseif (action.params.mode == "gun") then
			self._objects[#self._objects+1] = {
				["name"] = "bullet",
				["x"] = robot._location.x-32*math.sin(((robot._angle+robot._cannon)*math.pi)/180.0),
				["y"] = robot._location.y-32*math.cos(((robot._angle+robot._cannon)*math.pi)/180.0),
				["angle"] = robot._angle+robot._cannon,
				["index"] = index,
				["step"] = 48
			}
		elseif (action.params.mode == "grenade") then
		end
	elseif (action.name == "scan") then
		self._objects[#self._objects+1] = {
			["name"] = "scan",
			["x"] = robot._location.x,
			["y"] = robot._location.y,
			["mode"] = action.params.mode,
			["angle"] = action.params.angle,
			["index"] = index,
		}

		enemies = nil

		if (action.params.mode == "radial") then
			enemies = self:robots_detect(robot, radial_radius, nil, nil)
		elseif (action.params.mode == "linear") then
			enemies = self:robots_detect(robot, linear_radius, action.params.angle, linear_range)
		end

		--[[ should mark all tanks found, but the distances are wrong
		if (enemies ~= nil) then
		for i=1,#enemies do
		local enemy = enemies[i]
		local radians = (math.pi*(robot._angle+enemy.angle-90.0))/180.0

		self._objects[#self._objects+1] = {
		["name"] = "found",
		["x"] = robot._location.x+iw/2,
		["y"] = robot._location.y+ih/2,
		["x1"] = math.floor(robot._location.x+iw/2-enemy.distance*math.cos(radians)),
		["y1"] = math.floor(robot._location.y+ih/2+enemy.distance*math.sin(radians))
		}
		end
		end
		--]]

		return enemies
	elseif (action.name == "turn") then
		local angle = action.params.angle

		robot._angle = robot._angle + angle

		if (robot._angle < 0) then
			robot._angle = robot._angle + 360
		end

		robot._angle = math.fmod(robot._angle, 360)
	elseif (action.name == "cannon") then
		local angle = action.params.angle

		robot._cannon = robot._cannon + angle

		if (robot._cannon < -60) then
			robot._cannon = -60
		elseif (robot._cannon > 60) then
			robot._cannon = 60
		end
	end
end

function Arena:background()
	layer0:compose(background, 0, 0, screen_width, screen_height)

	-- draw safe area
	layer0:color("yellow")
	layer0:rect("draw", safe.left, safe.top, screen_width-safe.left-safe.right, screen_height-safe.top-safe.bottom)
end

local threads = {}

local uptime = 0 -- TODO:: system.uptime()
local count = 0
local cycles = 0

function Arena:reset()
	for i=1,#self._robots do
		threads[#threads+1] = {
			["main"] = coroutine.create(function()
					self._robots[i]:main()
					end),
			["robot"] = self._robots[i]
		}
	end
end

function Arena:start()
	local discards = {}

	if (#threads <= 1) then
		return
	end

	for i=1,#threads do
		local thread = threads[i]

		if (coroutine.resume(thread.main) == true) then
			-- get command from thread and update the robot location
		else
			local trace = debug.traceback(thread.main)

			if (#trace > 16) then
				print(trace)
			end
		end

		if (thread.robot:health() <= 0) then
			discards[#discards+1] = i
		end
	end
	
	for i=#discards,1,-1 do
		table.remove(threads, discards[i])
		table.remove(self._robots, discards[i])
	end

	self.background()

	for i=1,#self._robots do
		local robot = self._robots[i]

		if (robot:health() > 0) then
			self._robots[i]:draw()
		end
	end
		
	discards = {}

	for i=1,#self._objects do
		local o = self._objects[i]

		if (o.name == "rocket") then
			local rotate_rocket = rocket:rotate(o.angle)

			layer0:compose(rotate_rocket, o.x, o.y)

			o.x = o.x - o.step*math.sin((o.angle*math.pi)/180.0)
			o.y = o.y - o.step*math.cos((o.angle*math.pi)/180.0)

			if (o.x < 0 or o.y < 0 or o.x > screen_width or o.y > screen_height) then
				discards[#discards+1] = i
			end

			-- INFO:: verify collision
			local collision, target = self:collision_detect(o.index, {
				["x"] = o.x+iw/2-4,
				["y"] = o.y+ih/2-4,
				["width"] = 8,
				["height"] = 8
			})

			if (collision == true) then
				play_sound("explosion")

				target._health = target._health - 5

				self._objects[#self._objects+1] = {
					["name"] = "explosion",
					["x"] = o.x,
					["y"] = o.y,
					["index"] = 0
				}

				discards[#discards+1] = i
			end
		elseif (o.name == "bullet") then
			layer0:compose(bullet, o.x, o.y)

			o.x = o.x - o.step*math.sin((o.angle*math.pi)/180.0)
			o.y = o.y - o.step*math.cos((o.angle*math.pi)/180.0)

			if (o.x < 0 or o.y < 0 or o.x > screen_width or o.y > screen_height) then
				discards[#discards+1] = i
			end

			-- INFO:: verify collision
			local collision, target = self:collision_detect(o.index, {
				["x"] = o.x+iw/2-2,
				["y"] = o.y+ih/2-2,
				["width"] = 4,
				["height"] = 4
			})

			if (collision == true) then
				play_sound("gun-fire")

				target._health = target._health - 1

				self._objects[#self._objects+1] = {
					["name"] = "impact",
					["x"] = o.x,
					["y"] = o.y,
					["index"] = 0
				}

				discards[#discards+1] = i
			end
		elseif (o.name == "found") then
			layer0:color(0x80f00000)
			-- layer0:oval("fill", o.x1, o.y1, iw/2)
				
			-- discards[#discards+1] = i
			layer0:linesize(10)
			layer0:line(o.x, o.y, o.x1, o.y1)
			layer0:linesize(1)
		elseif (o.name == "scan") then
			layer0:color(0x40f0f0f0)

			if (o.mode == "linear") then
				local x = o.x+iw/2
				local y = o.y+ih/2

				o.angle = o.angle + 180

				local rad0 = (o.angle*math.pi)/180.0+math.pi/2.0
				local rad1 = (linear_range*math.pi)/180.0

				layer0:polygon("draw:close", 
					x, y,
					0, 0,
					math.sin(rad0-rad1)*linear_radius, math.cos(rad0-rad1)*linear_radius,
					math.sin(rad0+rad1)*linear_radius, math.cos(rad0+rad1)*linear_radius
				)
				
				-- layer0:oval("draw", x, y, linear_radius, linear_radius, o.angle-linear_range, o.angle+linear_range)
				-- layer0:line(x, y, x+math.sin(rad0-rad1)*linear_radius, y+math.cos(rad0-rad1)*linear_radius)
				-- layer0:line(x, y, x+math.sin(rad0+rad1)*linear_radius, y+math.cos(rad0+rad1)*linear_radius)
			elseif (o.mode == "radial") then
				layer0:oval("draw", o.x+iw/2, o.y+ih/2, radial_radius)
			end

			discards[#discards+1] = i
		elseif (o.name == "impact") then
			layer0:compose(explosion.frames[1], o.x, o.y)

			discards[#discards+1] = i
		elseif (o.name == "explosion") then
			layer0:compose(explosion.frames[o.index+1], o.x, o.y)

			o.index = math.fmod(o.index + 1, #explosion.frames);

			if (o.index == 0) then
				discards[#discards+1] = i
			end
		end
	end

	for i=#discards,1,-1 do
		table.remove(self._objects, discards[i])
	end

	-- CHANGE:: frame rate
	local framerate = 1.0/self._frames
	local totaltime = (1000 * count) * framerate
	local currenttime = 0 -- TODO:: system.uptime()-uptime

	if (totaltime > currenttime) then
		-- TODO:: system.sleep(math.floor(totaltime-currenttime))
	else
		-- INFO:: reset parameters to avoid weird changes of time
		-- TODO:: uptime = system.uptime()
		count = 0
		
		-- TODO:: system.sleep(math.floor(framerate*1000))
	end

	count = count + 1
	cycles = cycles + 1

	if (cycles >= self._cycles) then
		return
	end
end

function Arena:result()
	local win = nil

	for i=1,#self._robots do
		local robot = self._robots[i]

		if (robot:health() > 0) then
			win = robot;
		end
	end

	if (win == nil) then
		self.background()

		layer0:color("white")
		layer0:text("No victory", safe.left, safe.top)
	else
		for i=1,2*360,20 do
			self.background()

			local rotate_tank = tank.frames[1]:rotate(win._angle+i)
			local rotate_cannon = cannon:rotate(win._angle+win._cannon+i)

			layer0:compose(rotate_tank, win._location.x, win._location.y)
			layer0:compose(rotate_cannon, win._location.x, win._location.y)

			layer0:color("white")
			layer0:text(win:name(), win._location.x, win._location.y-36)
		end
	end
end

function Arena:__tostring()
	return "Arena " .. name()
end

----------------------------------------------------------------------
-- Robot
----------------------------------------------------------------------
Robot = class(
	function(c, name)
		-- init
		if (name == nil) then
			name = "unamed"
		end

		c._name = name
		c._health = 100.0
		c._energy = 100.0
		c._arena = nil
		c._angle = 0
		c._weapon = "cannon"
		c._cannon = 0
		c._location = {
			["x"] = 0,
			["y"] = 0
		}
		c._collide = false

		-- tank params
		c._tank_index = 0
	end
)

function Robot:name()
	return self._name
end

function Robot:health()
	return self._health
end

function Robot:energy()
	return self._energy
end

function Robot:arena(a)
	if (a == nil) then
		return self._arena
	end

	self._arena = a
end

function Robot:turn(degrees)
	local step = 4.0

	if (degrees == nil) then
		return self._angle
	end

	local signal = 1.0

	if (degrees < 0.0) then
		signal = -1.0
		degrees = -degrees
	end

	local n = math.floor(degrees/step)
	local diff = 0.0

	diff = math.fmod(degrees, step)

	for i=1,n do
		self._tank_index = math.fmod(self._tank_index + 1, #tank.frames)

		self._arena:post({
			["robot"] = self,
			["action"] = {
				["name"] = "turn",
				["params"] = {
					["angle"] = step*signal
				}
			}
		})
				
		-- verify collide from arena 

		coroutine.yield()
	end

	if (diff > 0.0) then
		self._tank_index = math.fmod(self._tank_index + 1, #tank.frames)

		self._arena:post({
			["robot"] = self,
			["action"] = {
				["name"] = "turn",
				["params"] = {
					["angle"] = diff*signal
				}
			}
		})
				
		-- verify collide from arena 

		coroutine.yield()
	end

	return false
end

function Robot:cannon(degrees)
	local step = 6.0

	if (degrees == nil) then
		return self._cannon
	end

	local signal = 1.0

	degrees = degrees - self._cannon

	if (degrees < 0.0) then
		signal = -1.0
		degrees = -degrees
	end

	local n = math.floor(degrees/step)
	local diff = 0.0

	diff = math.fmod(degrees, step)

	for i=1,n do
		self._arena:post({
			["robot"] = self,
			["action"] = {
				["name"] = "cannon",
				["params"] = {
					["angle"] = step*signal
				}
			}
		})
		
		coroutine.yield()
	end
	
	if (diff > 0.0) then
		self._arena:post({
			["robot"] = self,
			["action"] = {
				["name"] = "cannon",
				["params"] = {
					["angle"] = diff*signal
				}
			}
		})
		
		coroutine.yield()
	end

	return false
end

function Robot:scan(mode, degrees) -- mode::[<radial>, <linear, degrees>]
	if (mode == "linear") then
		if (degrees == nil) then
			degrees = 0
		end

		degrees = math.fmod(degrees, 360.0)

		if (degrees < 0) then
			degrees = 360 + degrees
		end

		degrees = self._angle + degrees - 90
	else
		mode = "radial"
	end

	local robots = self._arena:post({
		["robot"] = self,
		["action"] = {
			["name"] = "scan",
			["params"] = {
				["mode"] = mode,
				["angle"] = degrees
			}
		}
	})
	
	coroutine.yield()
	
	return robots
end

function Robot:weapon(mode)
	if (mode == "cannon") then
		self._weapon = mode
	elseif (mode == "gun") then
		self._weapon = mode
	elseif (mode == "grenade") then
		self._weapon = mode
	end
end

function Robot:fire()
	if (self._weapon == "cannon") then
		local request_energy = 30

		-- INFO:: uses 30 percent of energy
		if (self._energy < request_energy) then
			return false
		end

		play_sound("cannon-fire2")

		self._energy = self._energy - request_energy

		self._arena:post({
			["robot"] = self,
			["action"] = {
				["name"] = "fire",
				["params"] = {
					["mode"] = "cannon"
				}
			}
		})

		-- INFO:: after the fire, the cannon was pushed one step backwards and wait a few turns
		self:move(-1)

		return true
	elseif (self._weapon == "gun") then
		local request_energy = 5

		-- INFO:: uses 30 percent of energy
		if (self._energy < request_energy) then
			return false
		end

		play_sound("gun-fire")

		self._energy = self._energy - request_energy

		self._arena:post({
			["robot"] = self,
			["action"] = {
				["name"] = "fire",
				["params"] = {
					["mode"] = "gun"
				}
			}
		})

		return true
	elseif (self._weapon == "grenade") then
	end

	return false
end

function Robot:move(steps)
	if (steps == nil) then
		steps = 0;
	end

	local signal = 1

	if (steps < 0) then
		signal = -1
		steps = -steps
	end

	local n = steps

	self._collide = false

	for i=1,n do
		self._tank_index = math.fmod(self._tank_index + 1, #tank.frames)

		local result = self._arena:post({
			["robot"] = self,
			["action"] = {
				["name"] = "move",
				["params"] = {
					["steps"] = signal
				}
			}
		})
		
		if (result ~= nil) then
			self._collide = result.collision
		end

		coroutine.yield()
	end

	return false
end

function Robot:collide()
	return self._collide
end

function Robot:draw()
	local rotate_tank = tank.frames[self._tank_index+1]:rotate(self._angle)
	local rotate_cannon = cannon:rotate(self._angle+self._cannon)

	-- INFO:: draw tank square (debug only)
	layer0:color("blue")
	-- layer0:rect("fill", self._location.x, self._location.y, iw, ih)

	layer0:compose(rotate_tank, self._location.x, self._location.y)
	layer0:compose(rotate_cannon, self._location.x, self._location.y)

	-- INFO:: draw name of robot
	layer0:color("white")
	layer0:text(self:name(), self._location.x, self._location.y-36)

	-- INFO:: draw health and energy
	local size = 12

  if (self._health > 50) then
  	layer0:color("green")
  elseif (self._health > 20) then
  	layer0:color("yellow")
  else
  	layer0:color("red")
  end

	layer0:rect("fill", self._location.x, self._location.y+ih+1*size, math.floor((iw*self._health)/100.0), size)
  
 	layer0:color(self._energy + 100, self._energy + 100, self._energy + 0)

	layer0:rect("fill", self._location.x, self._location.y+ih+3*size, math.floor((iw*self._energy)/100.0), size)

	self._energy = self._energy + 1
	
	if (self._energy > 100) then
		self._energy = 100
	end
end

function Robot:__tostring()
	return "Robot " .. name()
end

function Robot:main()
end

----------------------------------------------------------------------
-- Test
----------------------------------------------------------------------
arena = Arena("Test Arena")

dofile('bunny-robot.lua')
dofile('bunny-robot.lua')
dofile('bunny-robot.lua')
dofile('bunny-robot.lua')
dofile('kamikaze-robot.lua')
dofile('target-robot.lua')

arena:reset()

function render(tick)
	arena:start()

	canvas.compose(layer0, 0, 0, display.size())
end

-- arena:result()
