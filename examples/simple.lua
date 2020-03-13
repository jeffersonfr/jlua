local c0 = canvas.new()
c0:color("red")
c0:rect("fill", 10, 10, 10, 10)

c1 = c0:scale(400, 400)
c1:color("blue")
c1:rect("fill", 0, 0, c1:size())

c0:compose(c1, 50, 50)
