local t = FadeTransition("out")

while (true) do
	if (t:draw() == false) then
		break
	end

	canvas.sync()

	delay(time["animation"])
end

