local map = {
  grid = {
    {0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200, 0x1000, 0x0200, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200, 0x1000, 0x0200, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200, 0x1300, 0x0200, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x0202, 0x0202, 0x0202, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x0202, 0x1000, 0x2310, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x0202, 0x0202, 0x0202, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0201, 0x0201, 0x0201, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0301, 0x1000, 0x0201, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x0200, 0x1300, 0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x0201, 0x0201, 0x0201, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x0200, 0x1000, 0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x0200, 0x1000, 0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200},
  },
  block = 16,
  strip = 4,
  minimap = false,
  shadder = true,
  texture = true,
  fov = 45*math.pi/180
}

display.size(640, 480)

map.canvas2d = canvas.new(#map.grid[1]*map.block, #map.grid*map.block)

local dw, dh = display.size()
local w2, h2 = map.canvas2d:size()

local door_01 = canvas.new("images/ghost.png")

map.textures = {
  [0x0200] = canvas.new("images/wall.png"),
  [0x0201] = canvas.new("images/wood.png"),
  [0x0202] = canvas.new("images/greystone.png"),
  [0x0300] = canvas.new("images/wall-hole.png"),
  [0x0301] = canvas.new("images/wood-hole.png"),
  [0x0302] = canvas.new("images/greystone-hole.png"),
  [0x0310] = door_01:crop(0*32, 0, 32, 32), -- open/close door
  [0x0311] = door_01:crop(1*32, 0, 32, 32),
  [0x0312] = door_01:crop(2*32, 0, 32, 32),
  [0x0313] = door_01:crop(3*32, 0, 32, 32),
  [0x0400] = canvas.new("images/parallax.png")
}

map.animations = {
}

local game = {
  x = w2/2, 
  y = h2/2,
  radians = 0.0,
  walkSpeed = 128.0,
  rotationSpeed = math.pi,
  fieldOfView = math.pi/4,
	rays = {}, -- rays.transparent = {}: transparent walls until the solid block
}

game.findHorizontalIntersections = function(self, angle, up, left, correction, rangeStart, rangeEnd)
  local xintersect, yintersect, xstep, ystep = 9999, 9999, 9999, 9999

  yintersect = math.floor(game.y/map.block)*map.block
  
  if (up == false) then
    yintersect = yintersect + map.block
  end

  if angle ~= 0 then
    xintersect = game.x + (yintersect - game.y)/math.tan(angle)
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

  local x, y, w, h = 0, 0, w2, h2
  local steps = math.floor(math.max(w, h)/map.block)

  for i=0,steps do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x <= 0 or x >= w or y <= 0 or y >= h then
			return nil
    end

    local ix, iy = math.floor(x/map.block) + 1, math.floor(y/map.block) + 1
    local d = math.sqrt((game.x - x)*(game.x - x) + (game.y - y)*(game.y - y)) * correction

    -- solid walls
    if (up == false and map.grid[iy] ~= nil) then
      local id = map.grid[iy][ix] & 0x0fff
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 0, id = id}
      end
    end

    if (up == true and map.grid[iy - 1] ~= nil) then
      local id = map.grid[iy - 1][ix] & 0x0fff
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 0, id = id}
      end
    end
  end

	return nil
end

game.findVerticalIntersections = function(self, angle, up, left, correction, rangeStart, rangeEnd)
  local xintersect, yintersect, xstep, ystep = 9999, 9999, 9999, 9999

  xintersect = math.floor(game.x/map.block)*map.block
  
  if (left == false) then
    xintersect = xintersect + map.block
  end

  yintersect = game.y + (xintersect - game.x)*math.tan(angle)

  ystep = map.block*math.tan(angle)

  if left == true then
    ystep = -ystep
  end

  xstep = -map.block

  if left == false then
    xstep = -xstep
  end

  local x, y, w, h = 0, 0, w2, h2
  local steps = math.floor(math.max(w, h)/map.block)

  for i=0,steps do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x <= 0 or x >= w or y <= 0 or y >= h then
			return nil
    end

    local ix, iy = math.floor(x/map.block) + 1, math.floor(y/map.block) + 1
    local d = math.sqrt((game.x - x)*(game.x - x) + (game.y - y)*(game.y - y)) * correction

    -- solid walls
    if (left == false and map.grid[iy] ~= nil) then
      local id = map.grid[iy][ix] & 0x0fff
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 1, id = id}
      end
    end
    
    if (left == true and map.grid[iy] ~= nil) then
      local id = map.grid[iy][ix - 1] & 0x0fff
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 1, id = id}
      end
    end
  end

	return nil
end

game.castRays = function(self)
  local radians = math.fmod(game.radians, 2*math.pi) - map.fov/2.0

	game.rays = {}

  for i=0,w2,map.strip do
    local angle = radians + i*map.fov/w2

    if angle < 0 then
      angle = angle + 2*math.pi
    end

    angle = math.fmod(angle, 2*math.pi)

    local up = true
    local left = false

    if angle >= 0 and angle < math.pi then
      up = false
    end

    if angle > math.pi/2 and angle < 3*math.pi/2 then
      left = true
    end

    local correction = math.cos(-map.fov/2 + i*map.fov/w2) -- correct fish-eye effect

    -- find intersection for solid block
    local h = self:findHorizontalIntersections(angle, up, left, correction, 0x0200, 0x0300)
    local v = self:findVerticalIntersections(angle, up, left, correction, 0x0200, 0x0300)
    local intersection = h

    if (h == nil or (v ~= nil and v.distance < h.distance)) then
      intersection = v
    end

		game.rays[#game.rays + 1] = intersection
  end
end

game.render2d = function(self)
  map.canvas2d:clear()

  for j=1,#map.grid do
    for i=1,#map.grid[j] do
      local id = map.grid[j][i] & 0x0fff

      -- draw floor 

      if (id >= 0x0200) then
        map.canvas2d:compose(map.textures[id], (i - 1)*map.block, (j - 1)*map.block, map.block, map.block)
      end
    end
  end
    
  for i=1,#game.rays,map.strip do
    local ray = game.rays[i]

    if (ray.dir == 0) then
      map.canvas2d:color("blue")
    else
      map.canvas2d:color("red")
    end
      
    map.canvas2d:line(game.x, game.y, ray.x, ray.y)
    
    if ray.transparent ~= nil then
      map.canvas2d:color("green")
      map.canvas2d:line(game.x, game.y, ray.transparent.x, ray.transparent.y)
    end
  end
end

function colide(x, y)
  local ix, iy = math.floor(x/map.block), math.floor(y/map.block)
  local flag = map.grid[iy + 1][ix + 1] & 0xf000

  if flag == 0x1000 then
    return false
  end

  return true
end

function input(tick)
  if (event.key("left").state == "pressed") then
    game.radians = game.radians - game.rotationSpeed*tick
  end

  if (event.key("right").state == "pressed") then
    game.radians = game.radians + game.rotationSpeed*tick
  end

  -- walk to front, back
  local x, y, stepx, stepy = 
    0, 0, math.cos(game.radians)*game.walkSpeed*tick, math.sin(game.radians)*game.walkSpeed*tick

	if (event.key("up").state == "pressed") then
    if colide(game.x + stepx, game.y + stepy) == false then
      game.x, game.y = game.x + stepx, game.y + stepy
    elseif colide(game.x + stepx, game.y) == false then
      game.x, game.y = game.x + stepx, game.y
    elseif colide(game.x, game.y + stepy) == false then
      game.x, game.y = game.x, game.y + stepy
    end
	end

	if (event.key("down").state == "pressed") then
    if colide(game.x - stepx, game.y - stepy) == false then
      game.x, game.y = game.x - stepx, game.y - stepy
    elseif colide(game.x - stepx, game.y) == false then
      game.x, game.y = game.x - stepx, game.y
    elseif colide(game.x, game.y - stepy) == false then
      game.x, game.y = game.x, game.y - stepy
    end
	end
end

function render(tick)
	game:castRays()
  game:render2d()

  canvas.compose(map.canvas2d, 0, 0, dw, dh)

  input(tick)
end

print([[
  jLightinning v0.0.1a
]])
