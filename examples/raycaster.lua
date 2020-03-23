local fov = 60*math.pi/180

--[[
--  Blocks range
--    [0x1000, 0x0100[: floor
--    [0x0100, 0x0200[: ceiling
--    [0x0200, 0x0300[: solid walls
--    [0x0300, 0x0400[: transparent walls
--    [0x0400, 0x0500[: parallax
--
--  Blocks flags
--    0x00---: solid
--    0x01---: clipping
--]]

local map = {
  grid = {
    {0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200, 0x1000, 0x0200, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200, 0x1000, 0x0200, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200, 0x1300, 0x0200, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x0202, 0x0202, 0x0202, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
    {0x0200, 0x1000, 0x0202, 0x1000, 0x1302, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0x0200},
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
  strip = 1,
  minimap = false,
  shadder = true,
  texture = true
}

display.size(640, 480)

map.canvas2d = canvas.new(#map.grid[1]*map.block, #map.grid*map.block)
map.canvas3d = canvas.new(display.size())

local w2, h2 = map.canvas2d:size()
local w3, h3 = map.canvas3d:size()

map.textures = {
  [0x0200] = canvas.new("images/wall.png"),
  [0x0201] = canvas.new("images/wood.png"),
  [0x0202] = canvas.new("images/greystone.png"),
  [0x0300] = canvas.new("images/wall-hole.png"),
  [0x0301] = canvas.new("images/wood-hole.png"),
  [0x0302] = canvas.new("images/greystone-hole.png"),
  [0x0400] = canvas.new("images/parallax.png")
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
  local radians = math.fmod(game.radians, 2*math.pi) - fov/2.0

	game.rays = {}

  for i=0,w3,map.strip do
    local angle = radians + i*fov/w3

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

    local correction = math.cos(-fov/2 + i*fov/w3) -- correct fish-eye effect

    -- find intersection for solid block
    local h = self:findHorizontalIntersections(angle, up, left, correction, 0x0200, 0x0300)
    local v = self:findVerticalIntersections(angle, up, left, correction, 0x0200, 0x0300)
    local intersection = h

    if (h == nil or (v ~= nil and v.distance < h.distance)) then
      intersection = v
    end

    -- find intersection for transparent block
    local h = self:findHorizontalIntersections(angle, up, left, correction, 0x0300, 0x0400)
    local v = self:findVerticalIntersections(angle, up, left, correction, 0x0300, 0x0400)

    intersection.transparent = h

    if (h == nil or (v ~= nil and v.distance < h.distance)) then
      intersection.transparent = v
    end

		game.rays[#game.rays + 1] = intersection
  end
end

game.parallax = function(self)
  local sw, sh = map.textures[0x0400]:size()
  local sliceStrip = sw/360
  local fov0 = fov*180/math.pi
  local angle = math.fmod(self.radians*180/math.pi, 360)
  local startAngle = angle - fov0/2
  local angleStrip = fov0/w3

  for i=0,w3,map.strip do
    local angle = math.fmod(startAngle + i*angleStrip, 360)

    if angle < 0 then
      angle = angle + 360
    end

    map.canvas3d:compose(map.textures[0x0400], angle*sliceStrip, 0, sliceStrip, sh, i, -h3/2, map.strip, h3)
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

game.render3d = function(self)
  for i=1,#game.rays do
		local ray = game.rays[i]
    local distProjPlane = (w3/2)/math.tan(fov/2)
    local wallH = (map.block/ray.distance)*distProjPlane

    if wallH < 8 then
      wallH = 8
    end

    local tw, th = map.textures[ray.id]:size()
    local slice = (ray.x%map.block)*(tw/map.block)
    
    if ray.dir == 1 then
      slice = (ray.y%map.block)*(th/map.block)
    end

    if map.texture == true then
      map.canvas3d:compose(map.textures[ray.id], slice, 0, 1, th, i*map.strip, h3/2 - wallH, map.strip, 2*wallH)
    else
      map.canvas3d:color("white")

      if ray.dir == 1 then
        map.canvas3d:color("grey")
      end

      map.canvas3d:rect("fill", i*map.strip, h3/2 - wallH, map.strip, 2*wallH)
    end
  end
  
  self:renderTransparent()
end

game.renderTransparent = function(self)
  for i=1,#game.rays do
		local ray = game.rays[i]

    if ray.transparent ~= nil then
      if ray.transparent.distance <= ray.distance then
        local distProjPlane = (w3/2)/math.tan(fov/2)
        local wallH = (map.block/ray.transparent.distance)*distProjPlane

        if wallH < 8 then
          wallH = 8
        end

        local tw, th = map.textures[ray.transparent.id]:size()
        local slice = (ray.transparent.x%map.block)*(tw/map.block)

        if ray.transparent.dir == 1 then
          slice = (ray.transparent.y%map.block)*(th/map.block)
        end

        if map.texture == true then
          map.canvas3d:compose(map.textures[ray.transparent.id], slice, 0, 1, th, i*map.strip, h3/2 - wallH, map.strip, 2*wallH)
        else
          map.canvas3d:color(0xff, 0xff, 0xff, 0xa0)

          if ray.dir == 1 then
            map.canvas3d:color(0x80, 0x80, 0x80, 0xa0)
          end

          map.canvas3d:rect("fill", i*map.strip, h3/2 - wallH, map.strip, 2*wallH)
        end
      end
    end
  end
end

game.shadder = function(self)
  local randomLight = math.random(40, 60)/10
  local sparseLight = 0xff

  -- consider only the nearest wall, could cause some issues like when texture is disabled
  for i=1,#game.rays do
		local ray = game.rays[i]
		local rayTransparent = {distance = 999999999}
    local distProjPlane = (w3/2)/math.tan(fov/2)
		local distance = ray.distance

    if ray.transparent ~= nil then
      rayTransparent = ray.transparent
    end

		if rayTransparent.distance < ray.distance then
    	distance = rayTransparent.distance
		end

    local wallH = (map.block/distance)*distProjPlane

    if wallH < 8 then
      wallH = 8
    end

    -- add some dark shadder
    local shadder = randomLight*distance/math.max(w3, h3)

    if shadder > 1.0 then
      shadder = 1.0
    end

    local light = shadder * sparseLight

    if light < 0 then
      light = 0
    end

    if light > 0xff then
      light = 0xff
    end

    map.canvas3d:color(0, 0, 0, light)
    map.canvas3d:rect("fill", i*map.strip, h3/2 - wallH, map.strip, 2*wallH)

    -- add some fog
    --[[
    map.canvas3d:color(0x60, 0x60, 0x60, 0xa0)
    map.canvas3d:rect("fill", i*map.strip, 0, map.strip, h)
    ]]
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

local inputDelayCounter = 0

function input(tick)
  local strife = 0

  if inputDelayCounter == 0 then
    if (event.key("m").state == "pressed") then
      if map.minimap == false then
        map.minimap = true
      else
        map.minimap = false
      end
    end

    if (event.key("s").state == "pressed") then
      if map.shadder == false then
        map.shadder = true
      else
        map.shadder = false
      end
    end

    if (event.key("t").state == "pressed") then
      if map.texture == false then
        map.texture = true
      else
        map.texture = false
      end
    end
  end

  if (event.key("l").state == "pressed") then
    map.strip = 8
  end

  if (event.key("h").state == "pressed") then
    map.strip = 1
  end

  if (event.key("alt").state == "pressed") then
    strife = math.pi/2
  end

  if strife == 0 then -- turn left, right
    if (event.key("left").state == "pressed") then
      game.radians = game.radians - game.rotationSpeed*tick
    end

    if (event.key("right").state == "pressed") then
      game.radians = game.radians + game.rotationSpeed*tick
    end
  else -- strife left, right
    local x, y, stepx, stepy = 
    0, 0, math.cos(game.radians - strife)*game.walkSpeed*tick, math.sin(game.radians - strife)*game.walkSpeed*tick

    if (event.key("left").state == "pressed") then
      if colide(game.x + stepx, game.y + stepy) == false then
        game.x, game.y = game.x + stepx, game.y + stepy
      end
    end

    if (event.key("right").state == "pressed") then
      if colide(game.x - stepx, game.y - stepy) == false then
        game.x, game.y = game.x - stepx, game.y - stepy
      end
    end
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

  inputDelayCounter = inputDelayCounter + tick

  if inputDelayCounter > 0.1 then -- 100ms
    inputDelayCounter = 0
  end
end

function configure()
  map.canvas3d = canvas.new(display.size())

  w3, h3 = map.canvas3d:size()
end

function render(tick)
  map.canvas3d:color("black")
  map.canvas3d:rect("fill", 0, 0, map.canvas3d:size())

  input(tick)

	game:castRays()
  game:render2d()
  game:parallax()
  game:render3d()

  if map.shadder == true then
    game:shadder()
  end

  canvas.compose(map.canvas3d, 0, 0)

  if map.minimap == true then
    canvas.compose(map.canvas2d, 0, 0, w2/2, h2/2)
  end
end

print([[
  jRayCaster v0.0.1a

  l,h -> low/high resolution
  m -> on/off minimap
  s -> on/off shadder
  t -> on/off texture
  left, right, up, down -> movements
]])
