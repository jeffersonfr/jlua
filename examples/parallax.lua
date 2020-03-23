display.size(720, 480)

local dw, dh = display.size()

local sprite0 = canvas.new("images/parallax.png")

local sw, sh = sprite0:size()

local angle = 180
local fov = 60

local sliceStrip = sw/360

function parallax()
  local startAngle = angle - fov/2
  local angleStrip = fov/dw

  for i=0,dw do
    local angle = math.fmod(startAngle + i*angleStrip, 360)

    if angle < 0 then
      angle = angle + 360
    end

    canvas.compose(sprite0, angle*sliceStrip, 0, sliceStrip, sh, i, 0, 1, dh)
  end

  angle = math.fmod(angle + 1, 360)
end

function render(tick)
  parallax()
end
