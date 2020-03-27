display.size(640, 480)

local dw, dh = display.size()

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
  strip = 1,
  minimap = false,
  shadder = true,
  texture = true,
  fov = 45*math.pi/180
}

-- animation class
Animation = {
}

Animation.__index = Animation

--[[
-- [col, row]: animate map blocks
-- [col, -1]: animate game sprites
--]]
function Animation:createMapAnimation(col, row, index, loop, startDelay, delay, frames)
   local obj = {}
   
   setmetatable(obj, Animation)
 
   obj.animationType = "map"
   obj.startDelay = startDelay
   obj.col = col
   obj.row = row
   obj.frames = frames
   obj.index = index
   obj.loop = loop
   obj.delay = delay
   obj.running = false
   obj.counter = 0
   obj.isValid = true
   obj.begin = nil -- callback before the first animation
   obj.finish = nil -- callback after the last animation
   
   return obj
end

function Animation:createSpriteAnimation(sprite, velX, velY, index, loop, startDelay, delay, frames)
   local obj = {}
   
   setmetatable(obj, Animation)
 
   obj.animationType = "sprite"
   obj.startDelay = startDelay
   obj.sprite = sprite
   obj.velX = velX
   obj.velY = velY
   obj.frames = frames
   obj.index = index
   obj.loop = loop
   obj.delay = delay
   obj.running = false
   obj.counter = 0
   obj.isValid = true
   obj.begin = nil -- callback before the first animation
   obj.finish = nil -- callback after the last animation
   
   return obj
end

function Animation:start()
  self.running = true
end

function Animation:stop()
  self.running = false
end

function Animation:update(tick)
  if self.running == false or self.isValid == false then
    return
  end

  self.counter = self.counter + tick

  if self.startDelay >= 0 and self.counter < self.startDelay then
    return
  end

  if self.startDelay >= 0 then
    self.counter = self.counter - self.startDelay
    self.startDelay = -1

    if self.begin ~= nil then
      self:begin()
    end
  end

  if self.counter >= self.delay then
    if self.animationType == "sprite" then
      self.sprite.id = self.frames[self.index + 1]
      
      local x = self.sprite.x + self.velX
      local y = self.sprite.y + self.velY

      if x < 0 or y < 0 or x > w2 or y > h2 then
        if self.finish ~= nil then
          self:finish()
        end

        self:invalidate()
      end
      
      self.sprite.x = x
      self.sprite.y = y
    elseif self.animationType == "map" then
      local flag = map.grid[self.row][self.col] & 0xf000
    
      map.grid[self.row][self.col] = self.frames[self.index + 1] | flag -- update map.grid
    else
      return
    end

    self.counter = self.counter - self.delay
    self.index = math.fmod(self.index + 1, #self.frames)

    if self.index == 0 then
      if self.loop == false then
        self.running = false
      end

      if self.finish ~= nil then
        self:finish()
      end
    end
  end
end

function Animation:invalidate()
  self.isValid = false
end

function createOpenCloseDoorAnimation(ix, iy) -- animation to open and close doors when action button is pressed
  local openDoor = Animation:createMapAnimation(ix, iy, 0, false, 0.0, 0.5, {0x0310, 0x0311, 0x0312, 0x0313})

  openDoor.begin = function(self)
    map.grid[self.row][self.col] = (0x0fff & map.grid[self.row][self.col]) | 0x0000 -- remove clip from door
  end

  openDoor.finish = function(self)
    self:invalidate()

    map.grid[self.row][self.col] = (0x0fff & map.grid[self.row][self.col]) | 0x1000 -- add clip to door

    local closeDoor = Animation:createMapAnimation(self.col, self.row, 0, false, 4.0, 0.5, {0x0313, 0x0312, 0x0311, 0x0310})

    closeDoor.begin = function(self)
      map.grid[self.row][self.col] = (0x0fff & map.grid[self.row][self.col]) | 0x0000 -- remove clip from door
    end

    closeDoor.finish = function(self)
      self:invalidate()

      map.grid[self.row][self.col] = (0x0fff & map.grid[self.row][self.col]) | 0x2000 -- add action to door
    end

    closeDoor:start()

    map.animations[#map.animations + 1] = closeDoor
  end

  openDoor:start()

  map.animations[#map.animations + 1] = openDoor
end

function createGhostAnimation(x, y) -- ghost animation
  local entity = {x = x, y = y, percentH = 0.75, position = -1, id = 0x0320}

  entity.animation = Animation:createSpriteAnimation(entity, 0, 0, 0, true, 0.0, 0.1, {0x0320, 0x0321, 0x0322, 0x0323})

  map.sprites[#map.sprites + 1] = entity
  
  entity.animation:start()
end

function createFireballAnimation() -- fireball animation ()
  local entity = {x = game.x, y = game.y, percentH = 0.75, position = -1, id = 0x0330}
  local vx, vy = math.cos(game.radians), math.sin(game.radians)

  entity.animation = Animation:createSpriteAnimation(entity, vx*map.block, vy*map.block, 0, true, 0.0, 0.1, {0x0330})

  map.sprites[#map.sprites + 1] = entity

  entity.animation:start()
end

--[[
--  Blocks range
--    [0x1000, 0x0100[: floor
--    [0x0100, 0x0200[: ceiling
--    [0x0200, 0x0300[: solid walls
--    [0x0300, 0x0400[: transparent walls
--    [0x0400, 0x0500[: parallax
--
--  Blocks flags
--    0x000000: solid
--    0x010000: clipping
--    0x020000: action
--]]

map.canvas2d = canvas.new(#map.grid[1]*map.block, #map.grid*map.block)
map.canvas3d = canvas.new(display.size())

w2, h2 = map.canvas2d:size()
w3, h3 = map.canvas3d:size()

local metal_door = canvas.new("images/door-01.png")
local ghost = canvas.new("images/ghost.png")

map.textures = {
  [0x0200] = canvas.new("images/wall.png"),
  [0x0201] = canvas.new("images/wood.png"),
  [0x0202] = canvas.new("images/greystone.png"),
  
  [0x0300] = canvas.new("images/wall-hole.png"),
  [0x0301] = canvas.new("images/wood-hole.png"),
  [0x0302] = canvas.new("images/greystone-hole.png"),
  
  [0x0310] = metal_door:crop(0*32, 0, 32, 32), -- open/close door
  [0x0311] = metal_door:crop(1*32, 0, 32, 32),
  [0x0312] = metal_door:crop(2*32, 0, 32, 32),
  [0x0313] = metal_door:crop(3*32, 0, 32, 32),
  
  [0x0320] = ghost:crop(0*32, 0, 32, 32), -- ghost
  [0x0321] = ghost:crop(1*32, 0, 32, 32),
  [0x0322] = ghost:crop(2*32, 0, 32, 32),
  [0x0323] = ghost:crop(3*32, 0, 32, 32),
  
  [0x0330] = canvas.new("images/fireball.png"),

  [0x0400] = canvas.new("images/parallax.png")
}

map.animations = {
}

map.sprites = {
}

game = {
  x = w2/2, 
  y = h2/2,
  radians = 0.0,
  walkSpeed = 64.0,
  rotationSpeed = math.pi/2,
  fieldOfView = math.pi/4
}

game.rays = { -- rays.transparent = {}: transparent walls until the solid block
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

  for i=0,w3,map.strip do
    local angle = radians + i*map.fov/w3

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

    local correction = math.cos(-map.fov/2 + i*map.fov/w3) -- correct fish-eye effect

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
  local fov0 = map.fov*180/math.pi
  local angle = math.fmod(self.radians*180/math.pi, 360)
  local startAngle = angle - fov0/2
  local angleStrip = fov0/w3
  local texture = map.textures[0x0400]

  for i=0,w3,map.strip do
    local angle = math.fmod(startAngle + i*angleStrip, 360)

    if angle < 0 then
      angle = angle + 360
    end

    map.canvas3d:compose(texture, angle*sliceStrip, 0, 1, sh, i, 0, map.strip, h3/2)
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

  map.canvas2d:color("white")

  for i=1,#map.sprites do
    local enemy = map.sprites[i]

    map.canvas2d:compose(map.textures[enemy.id], enemy.x, enemy.y, map.block, map.block)
  end
end

game.render3d = function(self)
  local distProjPlane = (w3/2)/math.tan(map.fov/2)

  for i=1,#game.rays do
		local ray = game.rays[i]
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
      map.canvas3d:compose(map.textures[ray.id], slice, 0, 1, th, i*map.strip, h3/2 - wallH/2, map.strip, wallH)
    else
      map.canvas3d:color("white")

      if ray.dir == 1 then
        map.canvas3d:color("grey")
      end

      map.canvas3d:rect("fill", i*map.strip, h3/2 - wallH/2, map.strip, wallH)
    end

    --[[
    -- casting floor
    local radians = math.fmod(game.radians, 2*math.pi) - map.fov/2.0
    local playerH = 32
    local rayangle = radians + i*map.fov/w3

    for row=h3/2 + wallH,h3,map.strip do
      local distance = (playerH/(row - h3/2))*distProjPlane
      local x = math.floor(distance*math.cos(rayangle) + game.x)
      local y = math.floor(distance*math.sin(rayangle) + game.y)

      -- local tile = map.textures[map.grid[x >> 6 + 1][y >> 6 + 1] ]
      local tile = map.textures[0x0200]

      map.canvas3d:pixels(i, row, tile:pixels(x & 31, y & 31))
    end
    ]]
  end
  
  -- there is a problem of z-index when render a transparent wall over a sprite, or vice-versa
  self:renderTransparent()
  
  if map.shadder == true then
    game:shadder()
  end
  
  self:renderSprites()
end

game.renderSprites = function(self)
  local distProjPlane = (w3/2)/math.tan(map.fov/2)

  table.sort(map.sprites, function (a, b)
    local dax = (a.x - game.x)
    local day = (a.y - game.y)
    local da = dax*dax + day*day

    local dbx = (b.x - game.x)
    local dby = (b.y - game.y)
    local db = dbx*dbx + dby*dby

    if da > db then
      return true
    end

    return false
  end)

  for i=1,#map.sprites do
    local enemy = map.sprites[i]
    local texture = map.textures[enemy.id]
    local iw, ih = texture:size()
    local angle = math.atan2(enemy.y - game.y, enemy.x - game.x)
    local interAngle = math.fmod(angle - game.radians, 2*math.pi)

    if interAngle > math.pi then
      interAngle = interAngle - 2*math.pi
    end

    if interAngle < -math.pi then
      interAngle = interAngle + 2*math.pi
    end

    local raySprite = nil

    if interAngle > -map.fov/2 and interAngle < map.fov/2 then
      local distance = math.sqrt((enemy.x - game.x)*(enemy.x - game.x) + (enemy.y - game.y)*(enemy.y - game.y))

      raySprite = {x = enemy.x, y = enemy.y, angle = interAngle, distance = distance}
    end

    if raySprite ~= nil then -- process the sprite inside the field of view
      local wallH = h3
      
      if raySprite.distance ~= 0 then
        wallH = (map.block/raySprite.distance)*distProjPlane
      end

      if wallH < 8 then
        wallH = 8
      end

      local spriteH = enemy.percentH*wallH -- the height of sprites is 75% of wall height
      local spriteW = spriteH -- *(map.block/map.block) -- the sprites has the same width and height
      local spriteX = math.floor(w3*(raySprite.angle + map.fov/2)/map.fov) -- center of the image
      local spriteY = h3/2 - wallH/2 + (wallH - spriteH) -- put the sprite on the floor

      if enemy.position == -1 then -- put sprite on floor (default)
      elseif enemy.position == 0 then -- put sprite on center
        spriteY = h3/2 - wallH/2 + (wallH - spriteH)/2 -- put the sprite on the floor
      else -- put sprite on ceiling
        spriteY = h3/2 - wallH/2 -- put the sprite on the floor
      end

      -- render each slice of sprite, if distance is less than the distance of wall
      local startX = math.floor(spriteX - spriteW/2)
      local endX = math.floor(spriteX + spriteW/2)
      local spriteStrip = map.strip*iw/spriteW
      local spriteSlice = 0

      for i=startX,endX,map.strip do
        spriteSlice = spriteSlice + spriteStrip
          
        if i > 0 and i < w3 then
          local rayWall = game.rays[math.floor(i/map.strip) + 1]
          local distance = raySprite.distance/math.cos(interAngle)

          if distance < rayWall.distance then
            map.canvas3d:compose(map.textures[enemy.id], spriteSlice, 0, 1, ih, i, spriteY, map.strip, spriteH)
          end
        end
      end
    end
  end
end

game.renderTransparent = function(self)
  local distProjPlane = (w3/2)/math.tan(map.fov/2)

  for i=1,#game.rays do
		local ray = game.rays[i]

    if ray.transparent ~= nil then
      if ray.transparent.distance <= ray.distance then
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
          map.canvas3d:compose(map.textures[ray.transparent.id], slice, 0, 1, th, i*map.strip, h3/2 - wallH/2, map.strip, wallH)
        else
          map.canvas3d:color(0xff, 0xff, 0xff, 0xa0)

          if ray.dir == 1 then
            map.canvas3d:color(0x80, 0x80, 0x80, 0xa0)
          end

          map.canvas3d:rect("fill", i*map.strip, h3/2 - wallH/2, map.strip, wallH)
        end
      end
    end
  end
end

game.shadder = function(self)
  local distProjPlane = (w3/2)/math.tan(map.fov/2)
  local randomLight = math.random(40, 60)/10
  local sparseLight = 0xff

  -- consider only the nearest wall, could cause some issues like when texture is disabled
  for i=1,#game.rays do
		local ray = game.rays[i]
		local distance = ray.distance

		if ray.transparent ~= nil and ray.transparent.distance < ray.distance then
    	distance = ray.transparent.distance
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
    map.canvas3d:rect("fill", i*map.strip, h3/2 - wallH/2, map.strip, wallH)

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

    if (event.key("space").state == "pressed") then
      local distance = 1.5
      local ix = math.floor((game.x + math.cos(game.radians)*map.block*distance)/map.block) + 1
      local iy = math.floor((game.y + math.sin(game.radians)*map.block*distance)/map.block) + 1
      local flag = map.grid[iy][ix] & 0x2000

      if flag ~= 0x2000 then
        return
      end

      createOpenCloseDoorAnimation(ix, iy)
    end
    
    if (event.key("ctrl").state == "pressed") then
      createFireballAnimation()
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

	game:castRays()
  game:render2d()
  game:parallax()
  game:render3d()

  canvas.compose(map.canvas3d, 0, 0)

  if map.minimap == true then
    canvas.compose(map.canvas2d, 0, 0, w2/2, h2/2)
  end

  -- process animations from map.animations
  local invalidList = {}

  for i=1,#map.animations do
    map.animations[i]:update(tick)

    if map.animations[i].isValid == false then
      invalidList[#invalidList + 1] = i
    end
  end

  for i=1,#invalidList do
    table.remove(map.animations, invalidList[i])
  end
  
  -- process animations from map.sprites
  local invalidList = {}

  for i=1,#map.sprites do
    local animation = map.sprites[i].animation

    if animation ~= nil then
      animation:update(tick)

      if animation.isValid == false then
        invalidList[#invalidList + 1] = i
      end
    end
  end

  for i=1,#invalidList do
    table.remove(map.sprites, invalidList[i])
  end
  
  input(tick)
end

createGhostAnimation(150, 100)
createGhostAnimation(150, 150)

--[[ FIX::
-- - shadder not trepassing transparent walls
-- - sprites are rendered over transparent walls (always)
--]]

print([[
  jRayCaster v0.0.1a

  l,h -> low/high resolution
  m -> on/off minimap
  s -> on/off shadder
  t -> on/off texture
  left, right, up, down -> movements
]])

