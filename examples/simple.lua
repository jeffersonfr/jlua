local layer0 = canvas.new(1280, 720)

function configure()
	layer0:color("red")
	layer0:rect("fill", 10, 10, 10, 10)

	c1 = layer0:scale(400, 400)
	c1:color("blue")
	c1:rect("fill", 0, 0, c1:size())

	layer0:compose(c1, 50, 50)

	canvas.compose(layer0, 0, 0)
end

configure()

