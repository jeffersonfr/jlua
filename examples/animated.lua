layer0 = canvas.new(1920, 1080)

logo = canvas.new("images/canvas.png")

count = 0.0

function render(tick) 
  local i = count*64
  local j = 64*math.sin(i/32)

  layer0:color("white")
  layer0:clear()

  layer0:color("red")
  layer0:rect("fill", i, j, 200, 200)

  layer0:color("green")
  layer0:rect("fill", 300 + i, 300 + j, 200, 200)

  layer0:color("blue")
  layer0:rect("fill", 600 + i, 600 + j, 200, 200)

  layer0:compose(logo, i + 50, 0 + j + 50, 100, 100)
  layer0:compose(logo, 300 + i + 50, 300 + j + 50, 100, 100)
  layer0:compose(logo, 600 + i + 50, 600 + j + 50, 100, 100)

  count = count + tick

	canvas.compose(layer0, 0, 0)
end
