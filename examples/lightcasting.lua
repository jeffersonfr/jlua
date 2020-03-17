local fov = 60*math.pi/180
local strip = 12

local map = {
  grid = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  },
  block = 32,
}

map.canvas = canvas.new(rawlen(map.grid[1])*map.block, rawlen(map.grid)*map.block)

map.render = function(self)
  map.canvas:clear()
  map.canvas:color("white")

  for j=1,rawlen(map.grid) do
    for i=1,rawlen(map.grid[j]) do
      map.canvas:rect("draw", (i - 1)*map.block, (j - 1)*map.block, map.block, map.block)

      if map.grid[j][i] == 1 then
        map.canvas:rect("fill", (i - 1)*map.block, (j - 1)*map.block, map.block, map.block)
      end
    end
  end
end

local x, y = map.canvas:size()

local player = {
  x = x/2, 
  y = y/2,
  radians = 0.0,
  walkSpeed = 128.0,
  rotationSpeed = math.pi,
  fieldOfView = math.pi/4
}

player.findHorizontalIntersections = function(self, angle, up, left)
  local xintersect, yintersect, xstep, ystep

  if (up == true) then
    yintersect = map.block*math.floor((player.y)/map.block)
    ystep = -map.block
  else
    yintersect = map.block*math.floor((player.y + 32)/map.block)
    ystep = map.block
  end

  xintersect = player.x - (player.y - yintersect)/math.tan(angle)
  xstep = ystep/math.tan(angle)

  for i=0,100 do
    local x = math.floor((xintersect + i*xstep)/map.block)
    local y = math.floor((yintersect + i*ystep)/map.block)

    if x < 0 or y < 0 or x >= rawlen(map.grid[1]) or y >= rawlen(map.grid) then
      return 9999, 9999
    end

    if map.grid[y + 1][x + 1] == 1 or (up == true and map.grid[y + 0][x + 1] == 1) then
      return xintersect + i*xstep, yintersect + i*ystep
    end
  end

  return 9999, 9999
end

player.findVerticalIntersections = function(self, angle, up, left)
  local xintersect, yintersect, xstep, ystep

  if (left == true) then
    xintersect = map.block*math.floor((player.x)/map.block)
    xstep = -map.block
  else
    xintersect = map.block*math.floor((player.x + 32)/map.block)
    xstep = map.block
  end

  yintersect = player.x - (player.x - xintersect)*math.tan(angle)
  ystep = xstep*math.tan(angle)

  for i=0,100 do
    local x = math.floor((xintersect + i*xstep)/map.block)
    local y = math.floor((yintersect + i*ystep)/map.block)

    if x < 0 or y < 0 or x >= rawlen(map.grid[1]) or y >= rawlen(map.grid) then
      return 9999, 9999
    end

    if map.grid[y + 1][x + 1] == 1 or (left == true and map.grid[y + 1][x + 0] == 1) then
      return xintersect + i*xstep, yintersect + i*ystep
    end
  end

  return 9999, 9999
end

player.render = function(self)
  map.canvas:color("green")
  map.canvas:arc("fill", self.x, self.y, 16)
  map.canvas:color("white")
  map.canvas:arc("fill", self.x + math.cos(self.radians)*16, self.y + math.sin(self.radians)*16, 4)

  local angle = player.radians - fov/2.0

  for i=0,360,strip do
    angle = math.fmod(angle + fov*strip/360.0, 2*math.pi)

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

    --[[
    hx = math.floor(hx/map.block)*map.block
    hy = math.floor(hy/map.block)*map.block
    vx = math.floor(vx/map.block)*map.block
    vy = math.floor(vy/map.block)*map.block
    ]]

    local distH = (player.x - hx)*(player.x - hx) + (player.y - hy)*(player.y - hy)
    local distV = (player.x - vx)*(player.x - vx) + (player.y - vy)*(player.y - vy)

    if (distH < distV) then
      map.canvas:color("blue")
      map.canvas:line(player.x, player.y, hx, hy)
    else
      map.canvas:color("red")
      map.canvas:line(player.x, player.y, vx, vy)
    end

    -- find vertical intersection
  end
end

function configure()
  local w, h = display.size()

  canvas.compose(map.canvas, 0, 0) --, canvas.size())
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

  map.canvas:clear()

  map:render()
  player:render()

  configure()
end
