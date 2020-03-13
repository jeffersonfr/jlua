local size = canvas.size()

local description = {
	"Vamos começar com a separação do lixo.",
}

local mw = 1280
local mh = 720
local mx = (size.width-mw)/2
local my = (size.height-mh)/2
local gap = 32
local index = 1

while (index <= #description) do
	canvas.compose(scenario_01, 0, 0, size.width, size.height)
	canvas.color(0xa0000000)
	canvas.rect("fill", mx, my, mw, mh)

	canvas.color("white")
	canvas.font("font", font["text.content"])
	canvas.text(description[index], mx+gap, my, mw-2*gap, mh, "center", "center")

	index = index + 1

	canvas.sync()

	delay(time["default"])
end

canvas.compose(scenario_01, 0, 0, size.width, size.height)
canvas.compose(recycle_or_organic, mx, my-128, mw, mh+240)
canvas.sync()

delay(time["default"])

while (true) do
	canvas.compose(scenario_01, 0, 0, size.width, size.height)
	canvas.compose(recycle_or_organic, mx, my-128, mw, mh+240)
	
	canvas.color(0xc0000000)
	canvas.rect("fill", mx, my, mw, mh)
	canvas.compose(fish, mx, my, mw, mh)

	canvas.sync()

	delay(time["default"])
end

dofile("fadeout.lua")
dofile("menu.lua")
