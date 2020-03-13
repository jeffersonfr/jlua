----------------------------------------------------------------------
-- Animation
----------------------------------------------------------------------
Animation = class(
	function(c)
		-- init
	end
)

function Animation:reset()
end

function Animation:draw()
	return false
end

function Animation:__tostring()
	return "Animation"
end

----------------------------------------------------------------------
-- GroupAnimation
----------------------------------------------------------------------
GroupAnimation = class(Animation, 
	--[[
	-- mode: serial or parallel.
	-- stack: if true, draw finalized animations.
	]]--
	function(c, mode, stack)
		Animation.init(c) -- must init base
		
		c._animations = {}

		c._mode = mode
		c._stack = stack
	end
)

function GroupAnimation:add(a)
	if (a == nil) then
		return
	end

	self._animations[#self._animations+1] = {
		["animation"] = a, 
		["running"] = true
	}
end

function GroupAnimation:clear()
	if (#self._animations == 0) then
		return false
	end

	while (#self._animations > 0) do
		table.remove(self._animations, 1)
	end
end

function GroupAnimation:remove(index)
	if (a == nil) then
		return
	end

	table.remove(self._animations, index)
end

function GroupAnimation:size()
	return #self._animations
end

function GroupAnimation:reset()
	if (#self._animations == 0) then
		return false
	end

	for i=1,#self._animations do
		self._animations[i].running = true
		self._animations[i].animation:reset()
	end
end

function GroupAnimation:draw()
	if (#self._animations == 0) then
		return false
	end

	if (self._mode == "serial") then
		for i=1,#self._animations do
			local a = self._animations[i]

			if (a.running == false) then
				if (self._stack == true) then
					a.animation:draw()
				end
			else
				a.running = a.animation:draw()

				return true;
			end
		end
	else
		local any = false

		for i=1,#self._animations do
			local a = self._animations[i]

			if (a.running == false) then
				if (self._stack == true) then
					a.animation:draw()
				end
			else
				a.running = a.animation:draw()

				any = true
			end
		end

		if (any == true) then
			return true
		end
	end

	return false
end

function GroupAnimation:__tostring()
	return "GroupAnimation"
end

----------------------------------------------------------------------
-- Transition
----------------------------------------------------------------------
Transition = class(Animation, 
	function(c)
		Animation.init(c) -- must init base
	end
)

function Transition:__tostring()
	return "Transition"
end

----------------------------------------------------------------------
-- StaticImageAnimation
----------------------------------------------------------------------
StaticImageAnimation = class(Animation, 
	function(c, image)
		Animation.init(c) -- must init base

		local size = image:size()

		c._image = image
		c._location = {
			["x"] = 0, 
			["y"] = 0
		}
		c._size = {
			["width"] = size.width, 
			["height"] = size.height
		}
	end
)

function StaticImageAnimation:location(x, y)
	if (x == nil or y == nil) then
		return self._location
	end

	self._location = {["x"] = x, ["y"] = y}
end

function StaticImageAnimation:size(w, h)
	if (w == nil or h == nil) then
		return self._size
	end

	self._size = {["width"] = w, ["height"] = h}
end

function StaticImageAnimation:draw()
	canvas.compose(self._image, self._location.x, self._location.y, self._size.width, self._size.height)

	return true
end

function StaticImageAnimation:__tostring()
	return "StaticImageAnimation"
end

----------------------------------------------------------------------
-- ImageList
----------------------------------------------------------------------
function GetImageList(image, cols, rows, offset, length)
	local size = image:size()
	local iw = size.width/cols
	local ih = size.height/rows

	t = {
		["frames"] = {},
		["size"] = {
			["width"] = iw, 
			["height"] = ih
		}
	}
	
	for i=offset,offset+length do
		local x = math.floor(math.fmod(i-1, size.width/iw))
		local y = math.floor((i-1)*iw/size.width)
		local img = image:crop(x*iw, y*ih, iw, ih)
		
		t.frames[#t.frames+1] = img
	end

	return t
end

----------------------------------------------------------------------
-- SequenceImageAnimation
----------------------------------------------------------------------
SequenceImageAnimation = class(Animation, 
	function(c, image, cols, rows, offset, length) -- <rows, cols, length>
		Animation.init(c) -- must init base

		local size = image:size()
		local iw = size.width/cols
		local ih = size.height/rows

		c._frames = {}

		for i=1,length do
			local x = math.fmod(i-1, size.width/iw)
			local y = math.floor((i-1)*iw/size.width)
			local img = image:crop(x*iw, y*ih, iw, ih)
			
			c._frames[#c._frames+1] = img
		end
		
		c._index = 0
		c._base = 0
		c._count = -1
		c._offset = offset
		c._length = length
		c._location = {
			["x"] = 100, 
			["y"] = 100
		}
		c._size = {
			["width"] = iw, 
			["height"] = ih
		}

		-- reset
		c.__count = -1
	end
)

function SequenceImageAnimation:reset()
	self._index = 0
	self._base = 0
	self._count = self.__count
end

-- current index of the frames
function SequenceImageAnimation:index(index)
	if (index == nil) then
		return self._index
	end

	self._index = index
end

-- define de base index and the length of the frames
function SequenceImageAnimation:frames(base, length) 
	if (index == nil and size == nil) then
		return self._base, self._length
	end

	if (length ~= nil) then
		self._length = length
	end

	self._base = base
end

-- define the number of loops
function SequenceImageAnimation:count(count)
	if (count == nil) then
		return self._count
	end

	self._count = count

	-- reset
	self.__count = count
end

function SequenceImageAnimation:location(x, y)
	if (x == nil or y == nil) then
		return self._location
	end

	self._location = {["x"] = x, ["y"] = y}
end

function SequenceImageAnimation:size(w, h)
	if (w == nil or h == nil) then
		return self._size
	end

	self._size = {["width"] = w, ["height"] = h}
end

function SequenceImageAnimation:draw()
	if (self._count == 0) then
		return false
	end

	if (self._length == (self._index+1)) then
		self._count = self._count - 1
	end

	local frame = self._frames[self._base+self._index+1]

	canvas.compose(frame, self._location.x, self._location.y, self._size.width, self._size.height)

	self._index = math.fmod(self._base+self._index+1, self._length)

	return true
end

function SequenceImageAnimation:__tostring()
	return "SequenceImageAnimation"
end

----------------------------------------------------------------------
-- SlideTransition
----------------------------------------------------------------------
SlideTransition = class(Transition,
	function(c, animation)
		Transition.init(c) -- must init base

		c._animation = animation
		c._finish = false
		c._timeout = 4000
		c._delay = 0
		c._init_time = -1
		c._initial = {
			["x"] = 0,
			["y"] = 0
		}
		c._final = {
			["x"] = 0,
			["y"] = 0
		}
	end
)

function SlideTransition:reset()
	self._finish = false
	self._init_time = -1
end

function SlideTransition:timeout(t)
	if (t == nil) then
		return self._timeout
	end

	self._timeout = t

	return self;
end

function SlideTransition:delay(t)
	if (t == nil) then
		return self._delay
	end

	self._delay = t

	return self;
end

function SlideTransition:initial(x, y)
	if (type(x) == "table") then
		y = x.height
		x = x.width
	end

	if (x == nil or y == nil) then
		return self._location
	end

	self._initial = {["x"] = x, ["y"] = y}

	return self;
end

function SlideTransition:final(x, y)
	if (type(x) == "table") then
		y = x.height
		x = x.width
	end

	if (x == nil or y == nil) then
		return self._offset
	end

	self._final = {["x"] = x, ["y"] = y}

	return self;
end

function SlideTransition:draw()
	if (self._finish == true) then
		-- return false
	end

	if (self._init_time < 0) then
		self._init_time = system.time();
	end

	local t = system.time()-self._init_time

	if (t < self._delay) then
		t = 0
	else
		t = t - self._delay
	end

	local to = self._timeout

	if (to == 0) then
		to = 1
	end

	if (t > to) then
		t = to
		self._finish = true
	end

	local w = self._final.x-self._initial.x
	local h = self._final.y-self._initial.y
	local dx = math.floor(self._initial.x+(w*t)/to)
	local dy = math.floor(self._initial.y+(h*t)/to)

	self._animation:location(dx, dy) 
	
	if (self._animation:draw() == false) then
		self._finish = true
	end

	return self._finish == false
end

function SlideTransition:__tostring()
	return "SlideTransition"
end

----------------------------------------------------------------------
-- ClipTransition
----------------------------------------------------------------------
ClipTransition = class(Transition,
	function(c, animation)
		Transition.init(c) -- must init base

		c._animation = animation
		c._finish = false
		c._timeout = 4000
		c._delay = 0
		c._init_time = -1
		c._direction = "right"
		c._mode = "in"
	end
)

function ClipTransition:reset()
	self._finish = false
	self._init_time = -1
end

function ClipTransition:timeout(t)
	if (t == nil) then
		return self._timeout
	end

	self._timeout = t

	return self;
end

function ClipTransition:delay(t)
	if (t == nil) then
		return self._delay
	end

	self._delay = t

	return self;
end

function ClipTransition:direction(d)
	if (d == nil) then
		return self._direction
	end

	self._direction = d

	return self;
end

function ClipTransition:mode(m)
	if (m == nil) then
		return self._mode
	end

	self._mode = m

	return self;
end

function ClipTransition:draw()
	if (self._finish == true) then
		-- return false
	end

	if (self._init_time < 0) then
		self._init_time = system.time();
	end

	local t = system.time()-self._init_time

	if (t < self._delay) then
		t = 0
	else
		t = t - self._delay
	end

	local to = self._timeout

	if (to == 0) then
		to = 1
	end

	if (t > to) then
		t = to
		self._finish = true
	end

	local location = self._animation:location()
	local size = self._animation:size()
	local clip = canvas.clip()
	local dw = math.floor((size.width*t)/to)
	local dh = math.floor((size.height*t)/to)

	if (self._direction == "left") then
		if (self._mode == "out") then
			canvas.clip(location.x, location.y, size.width-dw, size.height)
		else
			canvas.clip(location.x, location.y, dw, size.height)
		end
	elseif (self._direction == "right") then
		if (self._mode == "out") then
			canvas.clip(location.x+dw, location.y, size.width-dw, size.height)
		else
			canvas.clip(location.x+size.width-dw, location.y, dw, size.height)
		end
	elseif (self._direction == "top") then
		if (self._mode == "out") then
			canvas.clip(location.x, location.y, size.width, size.height-dh)
		else
			canvas.clip(location.x, location.y, size.width, dh)
		end
	elseif (self._direction == "bottom") then
		if (self._mode == "out") then
			canvas.clip(location.x, location.y+dh, size.width, size.height-dh)
		else
			canvas.clip(location.x, location.y+size.height-dh, size.width, dh)
		end
	end

	if (self._animation:draw() == false) then
		self._finish = true
	end

	canvas.clip(clip.x, clip.y, clip.width, clip.height)

	return self._finish == false
end

function ClipTransition:__tostring()
	return "ClipTransition"
end

----------------------------------------------------------------------
-- FadeTransition
----------------------------------------------------------------------
FadeTransition = class(Transition,
	function(c, method)
		Transition.init(c) -- must init base

		if (method == nil or (method ~= "out" and method ~= "in")) then
			method = "in"
		end
		
		if (method == "out") then
			c._color = 0xd0000000
		else
			c._color = 0x20000000
		end

		c._finish = false
		c._method = method -- <in, out>
		c._index = 0
		c._count = 6
		c._step = 0x20000000
	end
)

function FadeTransition:reset()
	if (self._method == "out") then
		self._color = 0xd0000000
	else
		self._color = 0x20000000
	end

	self._finish = false
	self._index = 0
end

function FadeTransition:draw()
	if (self._finish == true) then
		return false
	end

	local size = canvas.size()

	canvas.color(self._color)

	canvas.rect("fill", 0, 0, size.width, size.height)

	self._index = self._index + 1

	if (self._method == "out") then
		self._color = self._color - self._step
	else
		self._color = self._color + self._step
	end

	if (self._index >= self._count) then
		self._finish = true;
	end

	return true
end

function FadeTransition:__tostring()
	return "FadeTransition"
end

