local pi = math.pi
local floor = math.floor
local sqrt = math.sqrt
local tan = math.tan
local atan2 = math.atan2
local max = math.max
local random = math.random
local cos = math.cos
local sin = math.sin

game = {
  x = w2/2, 
  y = h2/2,
  radians = 0.0,
  walkSpeed = 64.0,
  rotationSpeed = pi/2,
  fieldOfView = pi/4
}

game.rays = { -- rays.transparent = {}: transparent walls until the solid block
}

game.findHorizontalIntersections = function(self, angle, up, left, correction, rangeStart, rangeEnd)
  local xintersect, yintersect, xstep, ystep = 9999, 9999, 9999, 9999

  yintersect = floor(game.y/config.block)*config.block
  
  if (up == false) then
    yintersect = yintersect + config.block
  end

  if angle ~= 0 then
    xintersect = game.x + (yintersect - game.y)/tan(angle)
  end

  if angle ~= 0 then
    xstep = config.block/tan(angle)

    if up == true then
      xstep = -xstep
    end
  end

  ystep = config.block

  if up == true then
    ystep = -ystep
  end

  local x, y, w, h = 0, 0, w2, h2
  local steps = floor(max(w, h)/config.block)

  for i=0,steps do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x <= 0 or x >= w or y <= 0 or y >= h then
			return nil
    end

    local ix, iy = floor(x/config.block) + 1, floor(y/config.block) + 1
    local d = sqrt((game.x - x)*(game.x - x) + (game.y - y)*(game.y - y)) * correction

    -- solid walls
    if (up == false and config.grid[iy] ~= nil) then
      local id = getMapCurrentId(ix, iy, config.grid)
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 0, id = id, col = ix, row = iy}
      end
    end

    if (up == true and config.grid[iy - 1] ~= nil) then
      local id = getMapCurrentId(ix, iy - 1, config.grid)
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 0, id = id, col = ix, row = iy - 1}
      end
    end
  end

	return nil
end

game.findVerticalIntersections = function(self, angle, up, left, correction, rangeStart, rangeEnd)
  local xintersect, yintersect, xstep, ystep = 9999, 9999, 9999, 9999

  xintersect = floor(game.x/config.block)*config.block
  
  if (left == false) then
    xintersect = xintersect + config.block
  end

  yintersect = game.y + (xintersect - game.x)*tan(angle)

  ystep = config.block*tan(angle)

  if left == true then
    ystep = -ystep
  end

  xstep = -config.block

  if left == false then
    xstep = -xstep
  end

  local x, y, w, h = 0, 0, w2, h2
  local steps = floor(max(w, h)/config.block)

  for i=0,steps do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x <= 0 or x >= w or y <= 0 or y >= h then
			return nil
    end

    local ix, iy = floor(x/config.block) + 1, floor(y/config.block) + 1
    local d = sqrt((game.x - x)*(game.x - x) + (game.y - y)*(game.y - y)) * correction

    -- solid walls
    if (left == false and config.grid[iy] ~= nil) then
      local id = getMapCurrentId(ix, iy, config.grid)
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 1, id = id, col = ix, row = iy}
      end
    end
    
    if (left == true and config.grid[iy] ~= nil) then
      -- TODO:: no caso de ser uma animacao, como ficaria o bitwise ????
      local id = getMapCurrentId(ix - 1, iy, config.grid)
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 1, id = id, col = ix - 1, row = iy}
      end
    end
  end

	return nil
end

game.castRays = function(self)
  local radians = (game.radians % (2*pi)) - config.fov/2.0

	rays = {}

  for i=0,w3,config.strip do
    local angle = radians + i*config.fov/w3

    if angle < 0 then
      angle = angle + 2*pi
    end

    angle = (angle % (2*pi))

    local up = true
    local left = false

    if angle >= 0 and angle < pi then
      up = false
    end

    if angle > pi/2 and angle < 3*pi/2 then
      left = true
    end

    local correction = cos(-config.fov/2 + i*config.fov/w3) -- correct fish-eye effect

    -- find intersection for solid block
    local h = self:findHorizontalIntersections(angle, up, left, correction, 0x0200, 0x0300)
    local v = self:findVerticalIntersections(angle, up, left, correction, 0x0200, 0x0300)
    local intersection = h

    if (h == nil or (v ~= nil and v.distance < h.distance)) then
      intersection = v
    end

    if (intersection ~= nil) then
      -- find intersection for transparent block
      local h = self:findHorizontalIntersections(angle, up, left, correction, 0x0300, 0x0400)
      local v = self:findVerticalIntersections(angle, up, left, correction, 0x0300, 0x0400)

      intersection.transparent = h

      if (h == nil or (v ~= nil and v.distance < h.distance)) then
        intersection.transparent = v
      end
    end

    rays[#rays + 1] = intersection
  end

  game.rays = rays
end

game.parallax = function(self)
  if config.parallax == false then
    return
  end

  local texture = config.textures[0x0400]
  local sw, sh = texture:size()
  local sliceStrip = sw/360
  local fov0 = config.fov*180/pi
  local angle = ((self.radians*180/pi) % 360)
  local startAngle = angle - fov0/2
  local angleStrip = fov0/w3

  local canvas3d_compose = config.canvas3d.compose

  for i=0,w3,config.strip do
    local angle = ((startAngle + i*angleStrip) % 360)

    if angle < 0 then
      angle = angle + 360
    end

    canvas3d_compose(config.canvas3d, texture, angle*sliceStrip, 0, 1, sh, i, 0, config.strip, h3/2)
  end
end

game.render2d = function(self)
  local canvas2d = config.canvas2d

  canvas2d:clear()

  for j=1,#config.grid do
    for i=1,#config.grid[j] do
      -- draw floor 
      -- draw ceiling

      local texture = getMapCurrentTexture(j, i, config.grid, config.textures)

      if texture ~= nil then
        canvas2d:compose(texture, (i - 1)*config.block, (j - 1)*config.block, config.block, config.block)
      end
    end
  end
  
  local rays = game.rays

  for i=1,#rays,config.strip do
    local ray = rays[i]

    if (ray.dir == 0) then
      canvas2d:color("blue")
    else
      canvas2d:color("red")
    end
      
    canvas2d:line(game.x, game.y, ray.x, ray.y)
    
    if ray.transparent ~= nil then
      canvas2d:color("green")
      canvas2d:line(game.x, game.y, ray.transparent.x, ray.transparent.y)
    end
  end

  canvas2d:color("white")

  for i=1,#config.sprites do
    local enemy = config.sprites[i]
    local texture = getSpriteCurrentTexture(enemy, config.textures)

    canvas2d:compose(texture, enemy.x, enemy.y, config.block, config.block)
  end
end

game.render3d = function(self)
  local distProjPlane = (w3/2)/tan(config.fov/2)
  local radians = (game.radians % (2*pi)) - config.fov/2.0
  local randomLight = random(40, 60)/10
  local sparseLight = 0xff

  local canvas3d = config.canvas3d
  local rays = game.rays

  for i=1,#rays do
		local ray = rays[i]
    local distance = ray.distance
    local wallH = (config.block/distance)*distProjPlane

    if wallH < 8 then
      wallH = 8
    end

    local texture = getMapCurrentTexture(ray.col, ray.row, config.grid, config.textures)
    local tw, th = texture:size()
    local slice = (ray.x%config.block)*(tw/config.block)
    
    if ray.dir == 1 then
      slice = (ray.y%config.block)*(th/config.block)
    end

    if config.texture == true then
      canvas3d:compose(texture, slice, 0, 1, th, i*config.strip, h3/2 - wallH/2, config.strip, wallH)
    else
      canvas3d:color("white")

      if ray.dir == 1 then
        canvas3d:color("grey")
      end

      canvas3d:rect("fill", i*config.strip, h3/2 - wallH/2, config.strip, wallH)
    end

    if config.shadder == "dark" then
      -- add some dark shadder
      local shadder = randomLight*distance/max(w3, h3)

      if shadder > 1.0 then
        shadder = 1.0
      end

      local light = shadder * sparseLight

      canvas3d:color(0, 0, 0, light)
      canvas3d:rect("fill", i*config.strip, h3/2 - wallH/2, config.strip, wallH)
    end

    -- floor casting
    if config.floor == true and config.shadder == "none" then
      local rayangle = radians + i*config.fov/#rays
      local fovAngle = rayangle - radians - config.fov/2
      local distProjPlaneDistortion = config.playerHeight*distProjPlane/cos(fovAngle)

      local cosAngle, sinAngle = cos(rayangle), sin(rayangle)
      local tile = config.textures[0x0100][1]
      local tw, th = tile:size()

      tw, th = tw - 1, th - 1

      local pixels = {}

      for row = h3/2 + wallH/2, h3 do
        local distance = distProjPlaneDistortion/(row - h3/2)
        local x = floor(distance*cosAngle + game.x)
        local y = floor(distance*sinAngle + game.y)

        -- local tile = config.textures[config.grid[x >> 6 + 1][y >> 6 + 1] & 0x0fff][1]
        -- local tw, th = tile:size()

        local pixel = tile:pixels(x & tw, y & th)

        for k=1,config.strip do
          pixels[#pixels + 1] = pixel
        end
      end
       
      canvas3d:pixels(i*config.strip, h3/2 + wallH/2, config.strip, #pixels, pixels)
    end

    -- :: render transparent
    --  # there is a problem of z-index when render a transparent wall over a sprite, or vice-versa
    if ray.transparent ~= nil then
      if ray.transparent.distance <= ray.distance then
        local wallH = (config.block/ray.transparent.distance)*distProjPlane

        if wallH < 8 then
          wallH = 8
        end

        local texture = getMapCurrentTexture(ray.transparent.col, ray.transparent.row, config.grid, config.textures)
        local tw, th = texture:size()
        local slice = (ray.transparent.x%config.block)*(tw/config.block)

        if ray.transparent.dir == 1 then
          slice = (ray.transparent.y%config.block)*(th/config.block)
        end

        if config.texture == true then
          canvas3d:compose(texture, slice, 0, 1, th, i*config.strip, h3/2 - wallH/2, config.strip, wallH)
        else
          canvas3d:color(0xff, 0xff, 0xff, 0xa0)

          if ray.dir == 1 then
            canvas3d:color(0x80, 0x80, 0x80, 0xa0)
          end

          canvas3d:rect("fill", i*config.strip, h3/2 - wallH/2, config.strip, wallH)
        end
        
        if config.shadder == "dark" then
          -- add some dark shadder
          local shadder = randomLight*ray.transparent.distance/max(w3, h3)

          if shadder > 1.0 then
            shadder = 1.0
          end

          local light = shadder * sparseLight

          canvas3d:color(0, 0, 0, light)
          canvas3d:rect("fill", i*config.strip, h3/2 - wallH/2, config.strip, wallH)
        end
      end
    end
  end
  
  self:renderSprites()
end

game.renderSprites = function(self)
  local distProjPlane = (w3/2)/tan(config.fov/2)

  local canvas3d = config.canvas3d

  table.sort(config.sprites, function (a, b)
    local dax = (a.x - game.x)
    local day = (a.y - game.y)
    local da = dax*dax + day*day

    local dbx = (b.x - game.x)
    local dby = (b.y - game.y)
    local db = dbx*dbx + dby*dby

    return da > db
  end)

  local rays = game.rays

  for i=1,#config.sprites do
    local enemy = config.sprites[i]
    local texture = getSpriteCurrentTexture(enemy, config.textures)
    local iw, ih = texture:size()
    local angle = atan2(enemy.y - game.y, enemy.x - game.x)
    local interAngle = ((angle - game.radians) % (2*pi))

    if interAngle > pi then
      interAngle = interAngle - 2*pi
    end

    if interAngle < -pi then
      interAngle = interAngle + 2*pi
    end

    local raySprite = nil

    if interAngle > -config.fov/2 and interAngle < config.fov/2 then
      local distance = sqrt((enemy.x - game.x)*(enemy.x - game.x) + (enemy.y - game.y)*(enemy.y - game.y))

      raySprite = {x = enemy.x, y = enemy.y, angle = interAngle, distance = distance}
    end

    if raySprite ~= nil then -- process the sprite inside the field of view
      local wallH = h3
      
      if raySprite.distance ~= 0 then
        wallH = (config.block/raySprite.distance)*distProjPlane
      end

      if wallH < 8 then
        wallH = 8
      end

      local spriteH = enemy.percentH*wallH -- the height of config.sprites is 75% of wall height
      local spriteW = spriteH -- *(config.block/config.block) -- the config.sprites has the same width and height
      local spriteX = floor(w3*(raySprite.angle + config.fov/2)/config.fov) -- center of the image
      local spriteY = h3/2 - wallH/2 + (wallH - spriteH) -- put the sprite on the floor

      if enemy.position == -1 then -- put sprite on floor (default)
      elseif enemy.position == 0 then -- put sprite on center
        spriteY = h3/2 - wallH/2 + (wallH - spriteH)/2 -- put the sprite on the floor
      else -- put sprite on ceiling
        spriteY = h3/2 - wallH/2 -- put the sprite on the floor
      end

      -- render each slice of sprite, if distance is less than the distance of wall
      local startX = floor(spriteX - spriteW/2)
      local endX = floor(spriteX + spriteW/2)
      local spriteStrip = config.strip*iw/spriteW
      local spriteSlice = 0

      for i=startX,endX,config.strip do
        spriteSlice = spriteSlice + spriteStrip
          
        if i > 0 and i < w3 then
          local rayWall = rays[floor(i/config.strip) + 1]
          local distance = raySprite.distance/cos(interAngle)

          if distance < rayWall.distance + config.block then
            canvas3d:compose(texture, spriteSlice, 0, 1, ih, i, spriteY, config.strip, spriteH)
          end
        end
      end
    end
  end
end

game.renderPlayer = function(self)
  local texture = config.textures[0x0360 + config.weapon][shootAnimation:textureIndex() + 1]
  local w, h = w3/2, w3/2

  texture = texture:scale(w, h)

  config.canvas3d:compose(texture, (w3 - w)/2, h3 - h)
end

