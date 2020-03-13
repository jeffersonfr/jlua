local size = canvas.size()

local description = {
	"Nossa equipe de amigos da natureza fez uma pesquisa global acerca de dos problemas sociais	existentes no nosso planeta e agora precisamos da ajuda de todos para conserta-los.",

	"Você irá nos ajudar a cuidar do nosso planeta. Em cada etapa iremos resolver um tipo de problema. Nessa primeira etapa iremos trabalhar para resolver os problemas de RECICLAGEM de LIXO.",

	"Para isso, precisamos que você entenda todo o processo de reciclagem, desde o armazenamento de lixo residencial até os grandes centros de reciclagem de lixo, bem como os problemas sociais que ocasionam acumulo de lixo em locais indevidos ou mesmo grandes concentrações de lixo parado.",

	"A sua primeira tarefa será identificar o que é lixo e o que não é lixo. Utilize as teclas direcionais para colocar o objeto no lugar certo. Cuidado para não errar muito ...\n\no planeta confia em você :)"
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

dofile("fadeout.lua")
dofile("level-01.lua")
