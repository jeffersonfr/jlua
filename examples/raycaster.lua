local fov = 60*math.pi/180
local strip = 1

local map = {
  grid = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, -1, 1, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 1},
    {1, 0, 1, -1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  },
  block = 16,
}

map.canvas2d = canvas.new(rawlen(map.grid[1])*map.block, rawlen(map.grid)*map.block)
map.canvas3d = canvas.new(640, 480)

local x2, y2 = map.canvas2d:size()
local x3, y3 = map.canvas3d:size()

display.size(x3, y3)

map.texture = canvas.new("images/wall.png")
map.textureTransparent = canvas.new("images/wall-transparent.png")

map.render = function(self)
  for j=1,rawlen(map.grid) do
    for i=1,rawlen(map.grid[j]) do
      map.canvas2d:color("white")
      map.canvas2d:rect("draw", (i - 1)*map.block, (j - 1)*map.block, map.block, map.block)

      if map.grid[j][i] == 1 then
        map.canvas2d:rect("fill", (i - 1)*map.block, (j - 1)*map.block, map.block, map.block)
      end
      
      if map.grid[j][i] == -1 then
        map.canvas2d:color("yellow")
        map.canvas2d:rect("fill", (i - 1)*map.block, (j - 1)*map.block, map.block, map.block)
      end
    end
  end
end

local player = {
  x = x2/2, 
  y = y2/2,
  radians = 0.0,
  walkSpeed = 128.0,
  rotationSpeed = math.pi,
  fieldOfView = math.pi/4,
	rays = {},
	raysTransparent = {}
}

player.findHorizontalIntersections = function(self, angle, up, left, solid)
  
  local xintersect, yintersect, xstep, ystep = 9999, 9999, 9999, 9999

  yintersect = math.floor(player.y/map.block)*map.block
  
  if (up == false) then
    yintersect = yintersect + map.block
  end

  if angle ~= 0 then
    xintersect = player.x + (yintersect - player.y)/math.tan(angle)
  end

  if angle ~= 0 then
    xstep = map.block/math.tan(angle)

    if up == true then
      xstep = -xstep
    end
  end

  ystep = map.block

  if up == true then
    ystep = -ystep
  end

  local x, y, w, h = 0, 0, x2, y2
  local steps = math.floor(math.max(w, h)/map.block)

  for i=0,steps do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x < 0 or x > w or y < 0 or y > h then
			if solid > 0 then
	     	return x, y
			end

			return -1, -1
    end

    local ix, iy = math.floor(x/map.block) + 1, math.floor(y/map.block) + 1

    if (up == false and map.grid[iy] ~= nil and map.grid[iy][ix] == solid) or (up == true and map.grid[iy - 1] ~= nil and  map.grid[iy - 1][ix] == solid) then
      return x, y
    end
  end

	if solid > 0 then
	  return x, y
	end

	return -1, -1
end

player.findVerticalIntersections = function(self, angle, up, left, solid)
  local xintersect, yintersect, xstep, ystep = 9999, 9999, 9999, 9999

  xintersect = math.floor(player.x/map.block)*map.block
  
  if (left == false) then
    xintersect = xintersect + map.block
  end

  yintersect = player.y + (xintersect - player.x)*math.tan(angle)

  ystep = map.block*math.tan(angle)

  if left == true then
    ystep = -ystep
  end

  xstep = -map.block

  if left == false then
    xstep = -xstep
  end

  local x, y, w, h = 0, 0, x2, y2
  local steps = math.floor(math.max(w, h)/map.block)

  for i=0,100 do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x < 0 or x > w or y < 0 or y > h then
			if solid > 0 then
	      return x, y
			end

			return -1, -1
    end

    local ix, iy = math.floor(x/map.block) + 1, math.floor(y/map.block) + 1

    if (left == false and map.grid[iy] ~= nil and map.grid[iy][ix] == solid) or (left == true and map.grid[iy][ix - 1] == solid) then
      return x, y
    end
  end

	if solid > 0 then
		return x, y
	end

	return -1, -1
end

player.castRays = function(self)
  local radians = math.fmod(player.radians, 2*math.pi) - fov/2.0

  local randomLight = (math.random()%10)/10

	player.rays = {}
	player.raysTransparent = {}

  for i=0,x3,strip do
    local angle = radians + i*fov/x3

    if angle < 0 then
      angle = angle + 2*math.pi
    end

    local up = true
    local left = false

    if angle > 0 and angle < math.pi then
      up = false
    end

    if angle > math.pi/2 and angle < 3*math.pi/2 then
      left = true
    end

    -- find horizontal intersection for solid block
    local hx, hy = self:findHorizontalIntersections(angle, up, left, 1)
    local vx, vy = self:findVerticalIntersections(angle, up, left, 1)

    local distH = math.sqrt((player.x - hx)*(player.x - hx) + (player.y - hy)*(player.y - hy))
    local distV = math.sqrt((player.x - vx)*(player.x - vx) + (player.y - vy)*(player.y - vy))

    local x, y, dist, dir = hx, hy, distH, 0

    if (distH < distV) then
      map.canvas2d:color("blue")
      map.canvas2d:line(player.x, player.y, hx, hy)
    else
      x, y, dist, dir = vx, vy, distV, 1

      map.canvas2d:color("red")
      map.canvas2d:line(player.x, player.y, vx, vy)
    end

    dist = dist*math.cos(-fov/2 + i*fov/x3)

		player.rays[#player.rays + 1] = {x = x, y = y, distance = dist, angle = angle, dir = dir}
    
		-- find horizontal intersection for transparent block
    local hx, hy = self:findHorizontalIntersections(angle, up, left, -1)
    local vx, vy = self:findVerticalIntersections(angle, up, left, -1)

    local distH = math.sqrt((player.x - hx)*(player.x - hx) + (player.y - hy)*(player.y - hy))
    local distV = math.sqrt((player.x - vx)*(player.x - vx) + (player.y - vy)*(player.y - vy))

    local x, y, dist, dir = hx, hy, distH, 0

    if (distH < distV) then
    else
      x, y, dist, dir = vx, vy, distV, 1
    end

    dist = dist*math.cos(-fov/2 + i*fov/x3)

		player.raysTransparent[#player.raysTransparent + 1] = {x = x, y = y, distance = dist, angle = angle, dir = dir}
  end
end

player.render = function(self)
  for i=1,#player.rays,strip do
		local ray = player.rays[i]
    local distProjPlane = (x3/2)/math.tan(fov/2)
    local wallH = (map.block/ray.distance)*distProjPlane

    if wallH < 8 then
      wallH = 8
    end

    local tw, th = map.texture:size()
    local slice = (ray.x%map.block)*(tw/map.block)
    
    if ray.dir == 1 then
      slice = (ray.y%map.block)*(th/map.block)
    end

    map.canvas3d:compose(map.texture, slice, 0, 1, th, i, y3/2 - wallH, strip, 2*wallH)
  end
end

player.shadder = function(self)
  local randomLight = (math.random()%10)/10

  for i=1,#player.rays,strip do
		local ray = player.rays[i]
		local rayTransparent = player.raysTransparent[i]
    local distProjPlane = (x3/2)/math.tan(fov/2)
		local distance = ray.distance

		if rayTransparent.distance < ray.distance then
    	distance = rayTransparent.distance
		end

    local wallH = (map.block/distance)*distProjPlane

    if wallH < 8 then
      wallH = 8
    end

    -- add some dark shadder
    local shadder = (4 + 4*randomLight)*distance/math.max(x3, y3)
    -- local shadder = (4 + math.pow(randomLight, .2))*ray.distance/math.max(x3, y3)

    if shadder > 1.0 then
      shadder = 1.0
    end

    map.canvas3d:color(0, 0, 0, shadder * 0xff)
    map.canvas3d:rect("fill", i, y3/2 - wallH, strip, 2*wallH)

    -- add some fog
    --[[
    map.canvas3d:color(0x60, 0x60, 0x60, 0xa0)
    map.canvas3d:rect("fill", i, 0, strip, h)
    ]]
  end
end

player.renderTransparent = function(self)
  for i=1,#player.raysTransparent,strip do
		local ray = player.rays[i]
		local rayTransparent = player.raysTransparent[i]

		if rayTransparent.distance < ray.distance and rayTransparent.x > 0 and rayTransparent.y > 0 then
			local distProjPlane = (x3/2)/math.tan(fov/2)
			local wallH = (map.block/rayTransparent.distance)*distProjPlane

			if wallH < 8 then
				wallH = 8
			end

			local tw, th = map.texture:size()
			local slice = (rayTransparent.x%map.block)*(tw/map.block)
			
			if rayTransparent.dir == 1 then
				slice = (rayTransparent.y%map.block)*(th/map.block)
			end

			map.canvas3d:compose(map.textureTransparent, slice, 0, 1, th, i, y3/2 - wallH, strip, 2*wallH)
		end
  end
end

function configure()
  local scale = 0.5

  canvas.compose(map.canvas3d, 0, 0)
  canvas.compose(map.canvas2d, 0, 0, x2*scale, y2*scale)
end

function input(tick)
	if (event.key("left").state == "pressed") then
    player.radians = player.radians - player.rotationSpeed*tick
	end

	if (event.key("right").state == "pressed") then
    player.radians = player.radians + player.rotationSpeed*tick
	end

  local x, y = 0, 0

	if (event.key("up").state == "pressed") then
    x = player.x + math.cos(player.radians)*player.walkSpeed*tick
    y = player.y + math.sin(player.radians)*player.walkSpeed*tick
	end

	if (event.key("down").state == "pressed") then
    x = player.x - math.cos(player.radians)*player.walkSpeed*tick
    y = player.y - math.sin(player.radians)*player.walkSpeed*tick
	end

  local ix, iy = math.floor(x/map.block), math.floor(y/map.block)

  -- detect collision
  if map.grid[iy + 1][ix + 1] == 0 then
    player.x, player.y = x, y
  end
end

function render(tick)
  map.canvas2d:clear()
  map.canvas3d:clear()

  map:render()

  input(tick)

	player:castRays()
  player:render()
  player:renderTransparent()
  player:shadder()

  configure()
end

