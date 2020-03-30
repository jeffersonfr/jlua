-- verify if x/y position intersects some entity in our map
function intersects(x, y)
  local ix, iy = math.floor(x/config.block), math.floor(y/config.block)
  local mapTexture = config.grid[iy + 1][ix + 1]

  if type(mapTexture) == "table" then
    if mapTexture.textureFlag ~= 0x0000 then
      return true
    end
  else
    if (mapTexture & 0xf000) ~= 0x0000 then
      return true
    end
  end

  return false
end

function splitTexture(path, cols, rows)
  local texture = canvas.new(path)
  local w, h = texture:size()
  local crops = {}

  w = w/cols
  h = h/rows

  for i=1,cols*rows do
    local col = (i - 1)%cols
    local row = math.floor((i - 1)/cols)

    crops[#crops + 1] = texture:crop(col*w, row*h, w, h)
  end

  return crops
end

function getMapCurrentId(col, row, mapGrid)
  local texture = mapGrid[row][col]

  if type(texture) == "table" then -- "texture" == animation
    return texture.textureId -- TODO:: melhorar isso: frames[texture:textureIndex()]
  end

  return texture & 0x0fff
end

function getMapCurrentTexture(col, row, mapGrid, textureTable)
  local texture = mapGrid[row][col]

  if type(texture) == "table" then -- has an animation
    return texture.frames[texture:textureIndex()]
  end

  local textureIndex = texture & 0x0fff
  local textureList = textureTable[textureIndex]

  if textureList == nil then
    return nil
  end

  return textureList[1]
end

function getSpriteCurrentTexture(sprite, textureTable)
  local textures = textureTable[sprite.id]

  if sprite.animations ~= nil then
    local index = 1

    for i=1,#sprite.animations do
      local animation = sprite.animations[i]

      if animation.animationType == "sprite" then
        index = animation:textureIndex()

        break
      end
    end

    return textures[index]
  end

  return textures[1]
end

function reverseList(list)
  local result = {}

  for i=#list,1,-1 do
    result[#result + 1] = list[i]
  end

  return result
end

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
  local animation = Animation:createSpriteAnimation(nil, 0, 0, 0, false, 1.0, 0.1, {1, 2, 3, 4})

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

    createProjectileAnimation(x, y, math.cos(angle)*config.block, math.sin(angle)*config.block, 0x0330)
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

-- Creates a moveable animated sprite of a fireball
function createProjectileAnimation(x, y, vx, vy, id)
  local entity = {x = x, y = y, percentH = 0.75, position = -1, id = id}

  entity.animations = {
    Animation:createSpriteAnimation(entity, vx/2, vy/2, 0, true, 0.0, 0.1, config.textures[entity.id])
  }

  entity.animations[1].callback = function(self)
    if intersects(self.sprite.x + vx/2, self.sprite.y + vy/2) then
      createExplosion(self.sprite.x, self.sprite.y)

      self:invalidate()
    end
  end

  config.sprites[#config.sprites + 1] = entity

  for i=1,#entity.animations do
    entity.animations[i]:start()
  end
end

