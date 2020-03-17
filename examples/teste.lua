local fov = 60*math.pi/180
local strip = 1

local map = {
  grid = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1},
    {1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  },
  block = 16,
}

map.canvas2d = canvas.new(rawlen(map.grid[1])*map.block, rawlen(map.grid)*map.block)
map.canvas3d = canvas.new(640, 480)

display.size(map.canvas3d:size())

map.texture = canvas.new("images/wall.png")
map.texture_transparent = canvas.new("images/wall-transparent.png")

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

local x, y = map.canvas2d:size()

local player = {
  x = x/2, 
  y = y/2,
  radians = 0.0,
  walkSpeed = 128.0,
  rotationSpeed = math.pi,
  fieldOfView = math.pi/4
}

player.findHorizontalIntersections = function(self, angle, up, left)
  
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

  local x, y, w, h = 0, 0, map.canvas2d:size()
  local steps = math.floor(math.max(w, h)/map.block)

  for i=0,steps do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x < 0 or x > w or y < 0 or y > h then
      return x, y
    end

    local ix, iy = math.floor(x/map.block) + 1, math.floor(y/map.block) + 1

    if (up == false and map.grid[iy][ix] == 1) or (up == true and map.grid[iy - 1][ix] == 1) then
      return x, y
    end
  end

  return x, y
end

player.findVerticalIntersections = function(self, angle, up, left)
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

  local x, y, w, h = 0, 0, map.canvas2d:size()
  local steps = math.floor(math.max(w, h)/map.block)

  for i=0,100 do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x < 0 or x > w or y < 0 or y > h then
      return x, y
    end

    local ix, iy = math.floor(x/map.block) + 1, math.floor(y/map.block) + 1

    if (left == false and map.grid[iy][ix] == 1) or (left == true and map.grid[iy][ix - 1] == 1) then
      return x, y
    end
  end

  return x, y
end

player.render = function(self)
  map.canvas2d:color("green")
  map.canvas2d:arc("fill", self.x, self.y, 16)
  map.canvas2d:color("white")
  map.canvas2d:arc("fill", self.x + math.cos(self.radians)*16, self.y + math.sin(self.radians)*16, 4)

  local radians = math.fmod(player.radians, 2*math.pi) - fov/2.0
  local w, h = map.canvas3d:size()

  local randomLight = (math.random()%10)/10

  for i=0,w,strip do
    local angle = radians + i*fov/w

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

    -- find horizontal intersection
    local hx, hy = self:findHorizontalIntersections(angle, up, left)
    local vx, vy = self:findVerticalIntersections(angle, up, left)

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

    dist = dist*math.cos(-fov/2 + i*fov/w)

    local distProjPlane = (w/2)/math.tan(fov/2)
    local wallH = (map.block/dist)*distProjPlane

    if wallH < 8 then
      wallH = 8
    end

    local tw, th = map.texture:size()
    local slice = (x%map.block)*(tw/map.block)
    
    if dir == 1 then
      slice = (y%map.block)*(th/map.block)
    end

    map.canvas3d:compose(map.texture, slice, 0, 1, th, i, h/2 - wallH, strip, 2*wallH)

    -- add some dark shadder
    local shadder = (4 + 4*randomLight)*dist/math.max(w, h)

    if shadder > 1.0 then
      shadder = 1.0
    end

    map.canvas3d:color(0, 0, 0, shadder * 0xff)
    map.canvas3d:rect("fill", i, h/2 - wallH, strip, 2*wallH)

    -- add some fog
    --[[
    map.canvas3d:color(0x60, 0x60, 0x60, 0xa0)
    map.canvas3d:rect("fill", i, 0, strip, h)
    ]]

    --[[
    -- print wall without texture
    if dir == 1 then
      map.canvas3d:color(0, 0, 0, 0x80)
      map.canvas3d:rect("fill", i, h/2 - wallH, strip, 2*wallH)
    end

    map.canvas3d:color("white")

    if dir == 1 then
      map.canvas3d:color("grey")
    end

    map.canvas3d:rect("fill", i, h/2 - wallH, strip, 2*wallH)
    ]]
  end
end

function configure()
  local w2, h2 = map.canvas2d:size()
  local scale = 0.5

  canvas.compose(map.canvas3d, 0, 0)
  canvas.compose(map.canvas2d, 0, 0, w2*scale, h2*scale)
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
  input(tick)

  map.canvas2d:clear()
  map.canvas3d:clear()

  map:render()
  player:render()

  configure()
end
