local w, h = display.size()

local radar = canvas.new(128, 128)
local rx, ry = radar:size()

radar:color(0x80000000)
radar:arc("fill", rx/2, ry/2, rx/2, ry/2)

local bg = canvas.new("images/map.jpg")

local angle = 0.0

function render_radar(tick)
  local fade = math.floor(math.random()*16) + 8

  angle = math.fmod(angle + tick*math.pi/2, 2*math.pi)

  for j=0,128-1 do
    for i=0,128-1 do
      local pixel = radar:pixels(i, j)

      if ((pixel & 0xff000000) ~= 0) then
        pixel = math.floor(pixel * 0.98) & 0xff000000 | pixel & 0x00ffffff
      end

      radar:pixels(i, j, pixel)
    end
  end

  radar:color("green")
  radar:arc("fill", rx/2, ry/2, rx/2, ry/2, angle, angle + 0.1)
  radar:color("grey");
  radar:arc("draw", rx/2, ry/2, rx/2, ry/2)
	
  canvas.compose(radar, 1280 - rx - 64, 64)
end

function render_map(tick)
  canvas.compose(bg, 0, 0, w, h)
end

function render(tick)
  render_map(tick)
  render_radar(tick)
end
