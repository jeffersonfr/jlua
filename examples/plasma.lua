local w, h = display.size()

local plasma = canvas.new(w/8, h/8)
local pw, ph = plasma:size()

local points = {}

for i=1,64 do
  points[#points + 1] = {
    x = math.random()*pw, 
    y = math.random()*ph
  }
end

local floor = math.floor
local random = math.random
local sqrt = math.sqrt
local max = math.min(pw, ph)

function render(tick)
  local step = 16*tick

  for i=1,#points do
    points[i].x = points[i].x + random()*step*2 - step

    if (points[i].x < 0) then
      points[i].x = 0
    end

    if (points[i].x > pw) then
      points[i].x = pw
    end

    points[i].y = points[i].y + random()*step*2 - step
    
    if (points[i].y < 0) then
      points[i].y = 0
    end

    if (points[i].y > ph) then
      points[i].y = ph
    end
  end
  
  for j=0,ph do
    for i=0,pw do
      local nearest = nil

      for k=1,#points do
        local dx = points[k].x - i
        local dy = points[k].y - j
        local d = dx*dx + dy*dy

        if (nearest == nil or d < nearest) then
          nearest = d
        end
      end

      local intensity = floor(255*sqrt(nearest)/max)

      plasma:pixels(i, j, 0xff000000 | intensity << 0x10 | intensity << 0x08 | intensity)
    end
  end
 
  canvas.compose(plasma, 0, 0, w, h)
end
