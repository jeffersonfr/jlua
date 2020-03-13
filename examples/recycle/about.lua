local size = canvas.size()
local msize = menu:size()

local mw = 1600
local mh = 720
local mx = (size.width-mw)/2
local my = (size.height-mh)/2
local gap = 32

local description = [[
	Aplicativo desenvolvido para aprimoramento do ensino infantil sobre os temas sociais, ecologia, tecnologia, lógica e programação de forma lúdica e animada para crianças em desenvolvimento.
]]

canvas.color("white")
canvas.clear()

canvas.compose(menu, (size.width-msize.width)/2, (size.height-msize.height)/2)

canvas.color(0xa0000000)
canvas.font("font", font["text.title"])
canvas.rect("fill", mx, my, mw, mh)
canvas.color("white")
canvas.font("font", font["text.content"])
canvas.text("SOBRE", mx, my+16, mw, mh, "center")
canvas.text(description, mx+gap, my+192, mw-2*gap, mh, "center")

canvas.sync()

delay(time["default"])

