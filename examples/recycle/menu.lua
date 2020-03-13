local size = canvas.size()
local msize = menu:size()

local angle = 0
local mw = 1280
local mh = 480
local mx = (size.width-mw)/2
local my = (size.height-mh)/2
local step = 32
local count = 6
local index = 0

events.clear()

while (true) do
	canvas.color("white")
	canvas.clear()

	canvas.compose(menu:rotate("crop", angle), (size.width-msize.width)/2, (size.height-msize.height)/2)

	canvas.color(0xa0000000)
	canvas.rect("fill", mx+count*step, my+count*step, mw-2*count*step, mh-2*count*step)

	if (count > 0) then
		count = count - 1
	else
		canvas.color(0xa080f080)
		canvas.rect("fill", mx+step, my+index*(64+64)+48, mw-2*step, 64+64)

		canvas.color("white")
		canvas.font("font", font["menu.items"])
		canvas.text("Novo Jogo", mx, my+0*(64+64)+72, mw, 96, "center")
		canvas.text("Informações", mx, my+1*(64+64)+72, mw, 96, "center")
		canvas.text("Sair", mx, my+2*(64+64)+72, mw, 96, "center")

		local e = events.get()

		if (e ~= nil and e.type ~= "release") then
			print("event:: [" .. e.code .. ", " .. e.symbol .. "] " .. e.type)

			if (e.symbol == "enter") then
				if (index == 0) then
					break
				elseif (index == 1) then
					dofile("fadeout.lua")
					dofile("about.lua")
					dofile("fadeout.lua")
				elseif (index == 2) then
					break
				end
			elseif (e.symbol == "up") then
				index = index - 1
			elseif (e.symbol == "down") then
				index = index + 1
			end

			if (index < 0) then
				index = 3-1
			end

			if (index >= 3) then
				index = 0
			end
		end
	end

	canvas.sync()

	angle = angle + 10

	delay(time["animation"])

	collectgarbage("collect")
end

dofile("fadeout.lua")

if (index == 0) then
	dofile("introduction.lua")
end
