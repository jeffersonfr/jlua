dofile("utils.lua")
dofile("config.lua")
dofile("config.lua")
dofile("game.lua")
dofile("animation.lua")

shootAnimation = createShootAnimation()

shootAnimation.begin = function(self)
  createProjectileAnimation(game.x, game.y, 2*math.cos(game.radians)*config.block, 2*math.sin(game.radians)*config.block, 0x0340)
end

local inputDelayCounter = 0

function input(tick)
  local strife = 0

  if event.key("1").state == "pressed" then
    config.weapon = 0
    shootAnimation.startDelay = 0.5
    shootAnimation.resetStartDelay = shootAnimation.startDelay
  elseif event.key("2").state == "pressed" then
    config.weapon = 1
    shootAnimation.startDelay = 1.0
    shootAnimation.resetStartDelay = shootAnimation.startDelay
  elseif event.key("3").state == "pressed" then
    config.weapon = 2
    shootAnimation.startDelay = 0.2
    shootAnimation.resetStartDelay = shootAnimation.startDelay
  elseif event.key("4").state == "pressed" then
    config.weapon = 3
    shootAnimation.startDelay = 0.0
    shootAnimation.resetStartDelay = shootAnimation.startDelay
  end

  if inputDelayCounter == 0 then
    if (event.key("m").state == "pressed") then
      if config.minimap == false then
        config.minimap = true
      else
        config.minimap = false
      end
    end

    if (event.key("s").state == "pressed") then
      if config.shadder == false then
        config.shadder = true
      else
        config.shadder = false
      end
    end

    if (event.key("t").state == "pressed") then
      if config.texture == false then
        config.texture = true
      else
        config.texture = false
      end
    end

    if (event.key("space").state == "pressed") then
      local distance = 1.5
      local ix = math.floor((game.x + math.cos(game.radians)*config.block*distance)/config.block) + 1
      local iy = math.floor((game.y + math.sin(game.radians)*config.block*distance)/config.block) + 1
      local texture = config.grid[iy][ix]
      local flag
      
      if type(texture) == "table" then
        flag = texture.textureFlag
      else
        flag = texture & 0xf000
      end

      if flag ~= 0x2000 then
        return
      end

      createOpenCloseDoorAnimation(ix, iy)
    end
    
    if (event.key("ctrl").state == "pressed") then
      shootAnimation:start()
    end
  end

  if (event.key("l").state == "pressed") then
    config.strip = 8
  end

  if (event.key("h").state == "pressed") then
    config.strip = 1
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
      if intersects(game.x + stepx, game.y + stepy) == false then
        game.x, game.y = game.x + stepx, game.y + stepy
      end
    end

    if (event.key("right").state == "pressed") then
      if intersects(game.x - stepx, game.y - stepy) == false then
        game.x, game.y = game.x - stepx, game.y - stepy
      end
    end
  end

  -- walk to front, back
  local x, y, stepx, stepy = 
    0, 0, math.cos(game.radians)*game.walkSpeed*tick, math.sin(game.radians)*game.walkSpeed*tick

	if (event.key("up").state == "pressed") then
    if intersects(game.x + stepx, game.y + stepy) == false then
      game.x, game.y = game.x + stepx, game.y + stepy
    elseif intersects(game.x + stepx, game.y) == false then
      game.x, game.y = game.x + stepx, game.y
    elseif intersects(game.x, game.y + stepy) == false then
      game.x, game.y = game.x, game.y + stepy
    end
	end

	if (event.key("down").state == "pressed") then
    if intersects(game.x - stepx, game.y - stepy) == false then
      game.x, game.y = game.x - stepx, game.y - stepy
    elseif intersects(game.x - stepx, game.y) == false then
      game.x, game.y = game.x - stepx, game.y
    elseif intersects(game.x, game.y - stepy) == false then
      game.x, game.y = game.x, game.y - stepy
    end
	end

  inputDelayCounter = inputDelayCounter + tick

  if inputDelayCounter > 0.1 then -- 100ms
    inputDelayCounter = 0
  end
end

function configure()
  config.canvas3d = canvas.new(display.size())

  w3, h3 = config.canvas3d:size()
end

function render(tick)
  config.canvas3d:color("black")
  config.canvas3d:rect("fill", 0, 0, config.canvas3d:size())

	game:castRays()
  game:render2d()
  game:parallax()
  game:render3d()
  game:renderPlayer()

  canvas.compose(config.canvas3d, 0, 0)

  if config.minimap == true then
    canvas.compose(config.canvas2d, 0, 0, w2/2, h2/2)
  end

  -- process config.grid.animations 
  for j=1,#config.grid do
    for i=1,#config.grid[1] do
      local animation = config.grid[j][i]

      if type(animation) == "table" then
        animation:update(tick)
      end
    end
  end

  -- process config.animations from config.sprites
  local invalidList = {}

  for i=1,#config.sprites do
    local animations = config.sprites[i].animations

    if animations ~= nil then
      for j=1,#animations do
        local animation = animations[j]

        animation:update(tick)

        if animation.isValid == false then
          invalidList[#invalidList + 1] = i
        end
      end
    end
  end

  for i=#invalidList,1,-1 do
    local animations = config.sprites[invalidList[i]].animations

    for j=1,#animations do
      animations[j]:stop()
    end

    table.remove(config.sprites, invalidList[i])
  end
  
  shootAnimation:update(tick)

  input(tick)
end

createGhostAnimation(150, 100)
createGhostAnimation(100, 100)

--[[ FIX::
-- - shadder not trepassing transparent walls
-- - config.sprites are rendered over transparent walls (always)
--]]

print([[
  jRayCaster v0.0.1a

  l,h -> low/high resolution
  m -> on/off minimap
  s -> on/off shadder
  t -> on/off texture
  left, right, up, down -> movements
]])

