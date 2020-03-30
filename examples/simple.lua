local layer0 = canvas.new(display.size())
local layer1 = canvas.new(display.size())
local layer2 = canvas.new(display.size())

layer0:color(0, 0, 100, 0x80)
layer0:rect("fill", 0, 0, layer0:size())

layer1:color(100, 0, 0, 0x80)
layer1:rect("fill", 0, 0, layer0:size())

layer2:color(0, 100, 0, 0x80)
layer2:rect("fill", 0, 0, layer0:size())

function render(tick)
  canvas.compose(layer0, 0, 0)
  canvas.compose(layer1, 200, 200)
  canvas.compose(layer2, 50, 300)
end

