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

  yintersect = math.floor(game.y/config.block)*config.block
  
  if (up == false) then
    yintersect = yintersect + config.block
  end

  if angle ~= 0 then
    xintersect = game.x + (yintersect - game.y)/math.tan(angle)
  end

  if angle ~= 0 then
    xstep = config.block/math.tan(angle)

    if up == true then
      xstep = -xstep
    end
  end

  ystep = config.block

  if up == true then
    ystep = -ystep
  end

  local x, y, w, h = 0, 0, w2, h2
  local steps = math.floor(math.max(w, h)/config.block)

  for i=0,steps do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x <= 0 or x >= w or y <= 0 or y >= h then
			return nil
    end

    local ix, iy = math.floor(x/config.block) + 1, math.floor(y/config.block) + 1
    local d = math.sqrt((game.x - x)*(game.x - x) + (game.y - y)*(game.y - y)) * correction

    -- solid walls
    if (up == false and config.grid[iy] ~= nil) then
      local id = config.grid[iy][ix] & 0x0fff
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 0, id = id}
      end
    end

    if (up == true and config.grid[iy - 1] ~= nil) then
      local id = config.grid[iy - 1][ix] & 0x0fff
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 0, id = id}
      end
    end
  end

	return nil
end

game.findVerticalIntersections = function(self, angle, up, left, correction, rangeStart, rangeEnd)
  local xintersect, yintersect, xstep, ystep = 9999, 9999, 9999, 9999

  xintersect = math.floor(game.x/config.block)*config.block
  
  if (left == false) then
    xintersect = xintersect + config.block
  end

  yintersect = game.y + (xintersect - game.x)*math.tan(angle)

  ystep = config.block*math.tan(angle)

  if left == true then
    ystep = -ystep
  end

  xstep = -config.block

  if left == false then
    xstep = -xstep
  end

  local x, y, w, h = 0, 0, w2, h2
  local steps = math.floor(math.max(w, h)/config.block)

  for i=0,steps do
    x, y = xintersect + i*xstep, yintersect + i*ystep

    if x <= 0 or x >= w or y <= 0 or y >= h then
			return nil
    end

    local ix, iy = math.floor(x/config.block) + 1, math.floor(y/config.block) + 1
    local d = math.sqrt((game.x - x)*(game.x - x) + (game.y - y)*(game.y - y)) * correction

    -- solid walls
    if (left == false and config.grid[iy] ~= nil) then
      local id = config.grid[iy][ix] & 0x0fff
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 1, id = id}
      end
    end
    
    if (left == true and config.grid[iy] ~= nil) then
      local id = config.grid[iy][ix - 1] & 0x0fff
      
      if (id >= rangeStart and id < rangeEnd) then
        return {x = x, y = y, distance = d, dir = 1, id = id}
      end
    end
  end

	return nil
end

game.castRays = function(self)
  local radians = math.fmod(game.radians, 2*math.pi) - config.fov/2.0

	game.rays = {}

  for i=0,w3,config.strip do
    local angle = radians + i*config.fov/w3

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

    local correction = math.cos(-config.fov/2 + i*config.fov/w3) -- correct fish-eye effect

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
  local sw, sh = config.textures[0x0400]:size()
  local sliceStrip = sw/360
  local fov0 = config.fov*180/math.pi
  local angle = math.fmod(self.radians*180/math.pi, 360)
  local startAngle = angle - fov0/2
  local angleStrip = fov0/w3
  local texture = config.textures[0x0400]

  for i=0,w3,config.strip do
    local angle = math.fmod(startAngle + i*angleStrip, 360)

    if angle < 0 then
      angle = angle + 360
    end

    config.canvas3d:compose(texture, angle*sliceStrip, 0, 1, sh, i, 0, config.strip, h3/2)
  end
end

game.render2d = function(self)
  config.canvas2d:clear()

  for j=1,#config.grid do
    for i=1,#config.grid[j] do
      local id = config.grid[j][i] & 0x0fff

      -- draw floor 

      if (id >= 0x0200) then
        config.canvas2d:compose(config.textures[id], (i - 1)*config.block, (j - 1)*config.block, config.block, config.block)
      end
    end
  end
    
  for i=1,#game.rays,config.strip do
    local ray = game.rays[i]

    if (ray.dir == 0) then
      config.canvas2d:color("blue")
    else
      config.canvas2d:color("red")
    end
      
    config.canvas2d:line(game.x, game.y, ray.x, ray.y)
    
    if ray.transparent ~= nil then
      config.canvas2d:color("green")
      config.canvas2d:line(game.x, game.y, ray.transparent.x, ray.transparent.y)
    end
  end

  config.canvas2d:color("white")

  for i=1,#config.sprites do
    local enemy = config.sprites[i]

    config.canvas2d:compose(config.textures[enemy.id], enemy.x, enemy.y, config.block, config.block)
  end
end

game.render3d = function(self)
  local distProjPlane = (w3/2)/math.tan(config.fov/2)

  for i=1,#game.rays do
		local ray = game.rays[i]
    local wallH = (config.block/ray.distance)*distProjPlane

    if wallH < 8 then
      wallH = 8
    end

    local tw, th = config.textures[ray.id]:size()
    local slice = (ray.x%config.block)*(tw/config.block)
    
    if ray.dir == 1 then
      slice = (ray.y%config.block)*(th/config.block)
    end

    if config.texture == true then
      config.canvas3d:compose(config.textures[ray.id], slice, 0, 1, th, i*config.strip, h3/2 - wallH/2, config.strip, wallH)
    else
      config.canvas3d:color("white")

      if ray.dir == 1 then
        config.canvas3d:color("grey")
      end

      config.canvas3d:rect("fill", i*config.strip, h3/2 - wallH/2, config.strip, wallH)
    end

    --[[
    -- casting floor
    local radians = math.fmod(game.radians, 2*math.pi) - config.fov/2.0
    local playerH = 32
    local rayangle = radians + i*config.fov/w3

    for row=h3/2 + wallH,h3,config.strip do
      local distance = (playerH/(row - h3/2))*distProjPlane
      local x = math.floor(distance*math.cos(rayangle) + game.x)
      local y = math.floor(distance*math.sin(rayangle) + game.y)

      -- local tile = config.textures[config.grid[x >> 6 + 1][y >> 6 + 1] ]
      local tile = config.textures[0x0200]

      config.canvas3d:pixels(i, row, tile:pixels(x & 31, y & 31))
    end
    ]]
  end
  
  -- there is a problem of z-index when render a transparent wall over a sprite, or vice-versa
  self:renderTransparent()
  
  if config.shadder == true then
    game:shadder()
  end
  
  self:renderSprites()
end

game.renderSprites = function(self)
  local distProjPlane = (w3/2)/math.tan(config.fov/2)

  table.sort(config.sprites, function (a, b)
    local dax = (a.x - game.x)
    local day = (a.y - game.y)
    local da = dax*dax + day*day

    local dbx = (b.x - game.x)
    local dby = (b.y - game.y)
    local db = dbx*dbx + dby*dby

    return da > db
  end)

  for i=1,#config.sprites do
    local enemy = config.sprites[i]
    local texture = config.textures[enemy.id]
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

    if interAngle > -config.fov/2 and interAngle < config.fov/2 then
      local distance = math.sqrt((enemy.x - game.x)*(enemy.x - game.x) + (enemy.y - game.y)*(enemy.y - game.y))

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
      local spriteX = math.floor(w3*(raySprite.angle + config.fov/2)/config.fov) -- center of the image
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
      local spriteStrip = config.strip*iw/spriteW
      local spriteSlice = 0

      for i=startX,endX,config.strip do
        spriteSlice = spriteSlice + spriteStrip
          
        if i > 0 and i < w3 then
          local rayWall = game.rays[math.floor(i/config.strip) + 1]
          local distance = raySprite.distance/math.cos(interAngle)

          if distance < rayWall.distance then
            config.canvas3d:compose(config.textures[enemy.id], spriteSlice, 0, 1, ih, i, spriteY, config.strip, spriteH)
          end
        end
      end
    end
  end
end

game.renderTransparent = function(self)
  local distProjPlane = (w3/2)/math.tan(config.fov/2)

  for i=1,#game.rays do
		local ray = game.rays[i]

    if ray.transparent ~= nil then
      if ray.transparent.distance <= ray.distance then
        local wallH = (config.block/ray.transparent.distance)*distProjPlane

        if wallH < 8 then
          wallH = 8
        end

        local tw, th = config.textures[ray.transparent.id]:size()
        local slice = (ray.transparent.x%config.block)*(tw/config.block)

        if ray.transparent.dir == 1 then
          slice = (ray.transparent.y%config.block)*(th/config.block)
        end

        if config.texture == true then
          config.canvas3d:compose(config.textures[ray.transparent.id], slice, 0, 1, th, i*config.strip, h3/2 - wallH/2, config.strip, wallH)
        else
          config.canvas3d:color(0xff, 0xff, 0xff, 0xa0)

          if ray.dir == 1 then
            config.canvas3d:color(0x80, 0x80, 0x80, 0xa0)
          end

          config.canvas3d:rect("fill", i*config.strip, h3/2 - wallH/2, config.strip, wallH)
        end
      end
    end
  end
end

game.shadder = function(self)
  local distProjPlane = (w3/2)/math.tan(config.fov/2)
  local randomLight = math.random(40, 60)/10
  local sparseLight = 0xff

  -- consider only the nearest wall, could cause some issues like when texture is disabled
  for i=1,#game.rays do
		local ray = game.rays[i]
		local distance = ray.distance

		if ray.transparent ~= nil and ray.transparent.distance < ray.distance then
    	distance = ray.transparent.distance
		end

    local wallH = (config.block/distance)*distProjPlane

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

    config.canvas3d:color(0, 0, 0, light)
    config.canvas3d:rect("fill", i*config.strip, h3/2 - wallH/2, config.strip, wallH)

    -- add some fog
    --[[
    config.canvas3d:color(0x60, 0x60, 0x60, 0xa0)
    config.canvas3d:rect("fill", i*config.strip, 0, config.strip, h)
    ]]
  end
end

