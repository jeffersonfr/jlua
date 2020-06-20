-- Animation to open/close door
function createOpenCloseDoorAnimation(ix, iy) -- animation to open and close doors when action button is pressed
  local openDoor = Animation:createMapAnimation(0x0310, 0x1000, 0, false, 0.0, 0.5, config.textures[0x0310])

  openDoor.finish = function(self)
    local closeDoor = Animation:createMapAnimation(0x0310, 0x0000, 0, false, 4.0, 0.5, reverseList(config.textures[0x0310])) 

    closeDoor.begin = function(self)
      self.textureFlag = 0x1000
    end

    closeDoor.finish = function(self)
      self.textureFlag = 0x2000
    end

    closeDoor:start()
  
    config.grid[iy][ix] = closeDoor
  end

  openDoor:start()

  config.grid[iy][ix] = openDoor
end

-- Creates a shoot animation
function createShootAnimation()
  local animation = Animation:createSpriteAnimation(nil, 0, 0, 0, false, 0.0, 0.1, {1, 2, 3, 4})

  animation.finish = function(self)
    self:reset()
  end

  return animation
end

-- Creates a animated sprite of a ghost
function createGhostAnimation(x, y) -- ghost animation
  local entity = {x = x, y = y, percentH = 0.75, position = -1, id = 0x0320}

  -- create animations to throw fireballs to player
  local fireballAnimation = Animation:createTimeoutAnimation(true, 0.0, 2.0)

  fireballAnimation.callback = function()
    local angle = math.atan2(game.y - y, game.x - x)

    createProjectileAnimation(x, y, math.cos(angle)*config.block, math.sin(angle)*config.block, 0x0330, "enemy")
  end

  entity.animations = {
    Animation:createSpriteAnimation(entity, 0, 0, 0, true, 0.0, 0.1, config.textures[entity.id]),
    fireballAnimation
  }

  config.sprites[#config.sprites + 1] = entity
  
  for i=1,#entity.animations do
    entity.animations[i]:start()
  end
end

-- Creates a explosion animation
function createExplosion(x, y)
  local entity = {x = x, y = y, percentH = 0.75, position = -1, id = 0x0350}

  entity.animations = {
    Animation:createSpriteAnimation(entity, 0, 0, 0, false, 0.0, 0.05, config.textures[entity.id])
  }

  entity.animations[1].autoInvalidate = true

  config.sprites[#config.sprites + 1] = entity

  for i=1,#entity.animations do
    entity.animations[i]:start()
  end
end

-- Creates a moveable animated sprite of a projectil
function createProjectileAnimation(x, y, vx, vy, id, from)
  local entity = {x = x, y = y, percentH = 0.75, position = -1, id = id, from = from}

  entity.animations = {
    Animation:createSpriteAnimation(entity, vx/2, vy/2, 0, true, 0.0, 0.1, config.textures[entity.id])
  }

  entity.animations[1].callback = function(self)
    local step = 0.1

    for i=0.1,1,step do
      local px, py = self.sprite.x + i*self.velX, self.sprite.y + i*self.velY

      if colide(px, py) then
        createExplosion(px - step*self.velX, py - step*self.velY)

        self:invalidate()

        break
      end

      if self.sprite.from == "player" then
        if colideSprite(self.sprite, px, py, 3) then
          createExplosion(px - step*self.velX, py - step*self.velY)

          self:invalidate()

          break
        end
      else
        if colidePlayer(px, py, 3) then
          createExplosion(px - step*self.velX, py - step*self.velY)

          self:invalidate()

          break
        end
      end
    end
  end

  config.sprites[#config.sprites + 1] = entity

  for i=1,#entity.animations do
    entity.animations[i]:start()
  end
end

