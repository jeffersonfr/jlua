function reverseList(list)
  local result = {}

  for i=#list,1,-1 do
    result[#result + 1] = list[i]
  end

  return result
end

function colide(x, y)
  local ix, iy = math.floor(x/config.block), math.floor(y/config.block)
  local mapTexture = config.grid[iy + 1]
  
  if mapTexture == nil then
    return true
  end
  
  mapTexture = mapTexture[ix + 1]

  if mapTexture == nil then
    return true
  end

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

function colideSprite(from, x, y, radius)
  for i=1,#config.sprites do
    local sprite = config.sprites[i]

    if sprite ~= from then
      local distance = math.sqrt((sprite.x - x)*(sprite.x - x) + (sprite.y - y)*(sprite.y - y))

      if distance <= radius then
        return true
      end
    end
  end

  return false
end

function colidePlayer(x, y, radius)
  local distance = math.sqrt((game.x - x)*(game.x - x) + (game.y - y)*(game.y - y))

  if distance <= radius then
    return true
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

