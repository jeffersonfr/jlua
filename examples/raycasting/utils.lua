-- verify if x/y position intersects some entity in our map
function intersects(x, y)
  local ix, iy = math.floor(x/config.block), math.floor(y/config.block)
  local flag = config.grid[iy + 1][ix + 1] & 0xf000

  if flag == 0x1000 then
    return false
  end

  return true
end

-- Animation to open/close door
function createOpenCloseDoorAnimation(ix, iy) -- animation to open and close doors when action button is pressed
  local openDoor = Animation:createMapAnimation(map, ix, iy, 0, false, 0.0, 0.5, {0x0310, 0x0311, 0x0312, 0x0313})

  openDoor.begin = function(self)
    config.grid[self.row][self.col] = (0x0fff & config.grid[self.row][self.col]) | 0x0000 -- remove clip from door
  end

  openDoor.finish = function(self)
    self:invalidate()

    config.grid[self.row][self.col] = (0x0fff & config.grid[self.row][self.col]) | 0x1000 -- add clip to door

    local closeDoor = Animation:createMapAnimation(self.map, self.col, self.row, 0, false, 4.0, 0.5, {0x0313, 0x0312, 0x0311, 0x0310})

    closeDoor.begin = function(self)
      config.grid[self.row][self.col] = (0x0fff & config.grid[self.row][self.col]) | 0x0000 -- remove clip from door
    end

    closeDoor.finish = function(self)
      self:invalidate()

      config.grid[self.row][self.col] = (0x0fff & config.grid[self.row][self.col]) | 0x2000 -- add action to door
    end

    closeDoor:start()

    config.animations[#config.animations + 1] = closeDoor
  end

  openDoor:start()

  config.animations[#config.animations + 1] = openDoor
end

-- Creates a animated sprite of a ghost
function createGhostAnimation(x, y) -- ghost animation
  local entity = {x = x, y = y, percentH = 0.75, position = -1, id = 0x0320}

  -- create animations to throw fireballs to player
  local fireballAnimation = Animation:createTimeoutAnimation(true, 0.0, 2.0)

  fireballAnimation.callback = function()
    local angle = math.atan2(game.y - y, game.x - x)

    createFireballAnimation(x, y, math.cos(angle)*config.block, math.sin(angle)*config.block)
  end

  entity.animations = {
    Animation:createSpriteAnimation(entity, 0, 0, 0, true, 0.0, 0.1, {0x0320, 0x0321, 0x0322, 0x0323}),
    fireballAnimation
  }

  config.sprites[#config.sprites + 1] = entity
  
  for i=1,#entity.animations do
    entity.animations[i]:start()
  end
end

-- Creates a explosion animation
function createExplosion(x, y)
  local spriteIds = {}

  for i=1,4*4 do
    spriteIds[#spriteIds + 1] = 0x0350 + i - 1
  end

  local entity = {x = x, y = y, percentH = 0.75, position = -1, id = spriteIds[1]}

  entity.animations = {
    Animation:createSpriteAnimation(entity, 0, 0, 0, false, 0.0, 0.05, spriteIds)
  }

  entity.animations[1].finish = function(self)
    self:invalidate()
  end

  config.sprites[#config.sprites + 1] = entity

  for i=1,#entity.animations do
    entity.animations[i]:start()
  end
end

-- Creates a moveable animated sprite of a fireball
function createFireballAnimation(x, y, vx, vy) -- fireball animation ()
  local spriteIds = {}

  for i=1,6*4 do
    spriteIds[#spriteIds + 1] = 0x0330 + i - 1
  end

  local entity = {x = x, y = y, percentH = 0.75, position = -1, id = spriteIds[1]}

  entity.animations = {
    Animation:createSpriteAnimation(entity, vx/2, vy/2, 0, true, 0.0, 0.1, spriteIds)
  }

  entity.animations[1].callback = function(self)
    local ix = math.floor(self.sprite.x/config.block)
    local iy = math.floor(self.sprite.y/config.block)

    if (config.grid[iy][ix] & 0xf000) == 0 then
      createExplosion(self.sprite.x, self.sprite.y)

      self:invalidate()
    end
  end

  config.sprites[#config.sprites + 1] = entity

  for i=1,#entity.animations do
    entity.animations[i]:start()
  end
end

