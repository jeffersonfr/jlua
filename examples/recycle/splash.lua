local size = canvas.size()

canvas.compose(splash, 0, 0, size.width, size.height)
canvas.sync()

local t = SlideTransition(bird_01):initial(size.width, 120):final(-120, 120)

while (true) do
	canvas.compose(splash, 0, 0, size.width, size.height)

	if (t:draw() == false) then
		break
	end

	canvas.sync()

	delay(time["animation"])
end

dofile("fadeout.lua")

