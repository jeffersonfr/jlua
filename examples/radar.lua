local w, h = display.size()

local layer0 = canvas.new(w, h)

angle = 0.0

function render(tick)
  local step = tick*math.pi/2
  local fade = math.floor(math.random()*16) + 8

  layer0:color(fade << 24)
  layer0:rect("fill", 0, 0, w, h)
  
  layer0:color("green")
  layer0:triangle("fill", 
    w/2, h/2, 
    w/2 + 100*math.cos(angle), h/2 + 100*math.sin(angle), 
    w/2 + 100*math.cos(angle + step), h/2 + 100*math.sin(angle + step))

  layer0:color("grey");
  layer0:arc("draw", w/2, h/2, 100)

	canvas.compose(layer0, 0, 0, display.size())
  
  angle = math.fmod(angle + step, 2*math.pi)
end
