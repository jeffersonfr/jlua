local w, h = display.size()

local plasma = canvas.new(w, h)
local pw, ph = plasma:size()

local ft = plasma:font()

function clear()
  plasma:clear()
end

function draw_earth(tick)
  local label = "earth"
  local tx, ty = ft:extends(label)

  plasma:color("white")
  plasma:arc("fill", pw/2, ph/2, 32)
  plasma:text(label, (pw - tx)/2, ph/2 + 48)
end

local angle = 0.0

function draw_moon(tick)
  local label = "moon"
  local tx, ty = ft:extends(label)
  local radix = 196

  angle = angle + tick

  local x, y = pw/2 + radix*math.cos(angle), ph/2 + radix*math.sin(angle)

  plasma:color("grey")
  plasma:arc("fill", x, y, 6)
  plasma:color("white")
  plasma:text(label, x - tx/2, y + 16)
end

function render(tick)
  clear()

  draw_earth(tick)
  draw_moon(tick)

  canvas.compose(plasma, 0, 0, w, h)
end
