config = {}

--[[
--  Blocks range
--    [0x1000, 0x0100[: floor
--    [0x0100, 0x0200[: ceiling
--    [0x0200, 0x0300[: solid walls
--    [0x0300, 0x0400[: transparent walls
--    [0x0400, 0x0500[: parallax
--
--  Blocks flags
--    0x010000: non-solid
--    0x010000: solid
--    0x020000: action
--]]
config.grid = {
  {0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200},
  {0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200, 0x1200, 0x1200, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200, 0x0100, 0x1200, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x1202, 0x1202, 0x1202, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200, 0x0300, 0x1200, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x1202, 0x0100, 0x2310, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x1202, 0x1202, 0x1202, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1201, 0x1201, 0x1201, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x1200, 0x0300, 0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0301, 0x0100, 0x1201, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x1200, 0x0100, 0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x1201, 0x1201, 0x1201, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x1200, 0x1200, 0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x1200},
  {0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200, 0x1200}
}

config.width = 640
config.height = 480
config.block = 16
config.strip = 8
config.minimap = false
config.shadder = "none" -- none, dark, fog
config.texture = true
config.floor = true
config.parallax = true
config.fov = 45*math.pi/180
config.weapon = 1
config.playerHeight = 8

config.textures = {
  [0x0100] = {
    canvas.new("images/greystone.png"),
  },

  [0x0200] = {
    canvas.new("images/wall.png"),
  },

  [0x0201] = {
    canvas.new("images/wood.png"),
  },

  [0x0202] = {
    canvas.new("images/greystone.png"),
  },
  
  [0x0300] = {
    canvas.new("images/wall-hole.png"),
  },

  [0x0301] = {
    canvas.new("images/wood-hole.png"),
  },

  [0x0302] = {
    canvas.new("images/greystone-hole.png"),
  },
  
  [0x0310] = splitTexture("images/door-01.png", 4, 1),

  [0x0320] = splitTexture("images/ghost.png", 4, 1),

  [0x0330] = splitTexture("images/fireball.png", 6, 4),
  
  [0x0340] = {
    canvas.new("images/bullet.png"),
  },

  [0x0350] = splitTexture("images/explosion.png", 4, 4),

  [0x0360] = splitTexture("images/weapon-01.png", 5, 1),
  [0x0361] = splitTexture("images/weapon-02.png", 5, 1),
  [0x0362] = splitTexture("images/weapon-03.png", 5, 1),
  [0x0363] = splitTexture("images/weapon-04.png", 5, 1),

  [0x0400] = canvas.new("images/parallax.png"),
}

config.sprites = {
}

config.canvas2d = canvas.new(#config.grid[1]*config.block, #config.grid*config.block)
config.canvas3d = canvas.new(display.size())

display.size(config.width, config.height)

dw, dh = display.size()
w2, h2 = config.canvas2d:size()
w3, h3 = config.canvas3d:size()

