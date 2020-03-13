layer0 = canvas.new()

local w, h = layer0:size()

local monkey = {x = 100, y = 100, dx = 100, dy = 100 }
local banana = {x = 300, y = 300, dx = 100, dy = 100 }

local win = 0

function collide (A, B)
	local ax1, ay1 = A.x, A.y
	local ax2, ay2 = ax1+A.dx/2, ay1+A.dy/2
	local bx1, by1 = B.x, B.y
	local bx2, by2 = bx1+B.dx/2, by1+B.dy/2

	if ax1 > bx2 then
		return false
	elseif bx1 > ax2 then
		return false
	elseif ay1 > by2 then
		return false
	elseif by1 > ay2 then
		return false
	end

	return true
end

iharbour = canvas.new("images/harbour.png")
ibanana = canvas.new("images/banana.png")
imonkey = canvas.new("images/monkey.png")
iwinner = canvas.new("images/winner.png")

function redraw()
	layer0:color(0xcf, 0xcf, 0xcf, 0xff)
	layer0:rect("fill", 50, 50, 400, 400)

	layer0:compose(ibanana, banana.x, banana.y, banana.dx, banana.dy)
	layer0:compose(imonkey, monkey.x, monkey.y, monkey.dx, monkey.dy)
end

layer0:compose(iharbour, 0, 0, w, h)
redraw()
	
while (true) do
	local e = events.get()

	if (e ~= nil and e.type ~= "release") then
		print("event:: [" .. e.code .. ", " .. e.symbol .. "] " .. e.type)

		if (e.symbol == "exit") then
			break
		end

		if (win == 1) then
			return
		end

		if (e.symbol == "left") then
			monkey.x = monkey.x - 10
		elseif (e.symbol == "right") then
			monkey.x = monkey.x + 10
		elseif (e.symbol == "up") then
			monkey.y = monkey.y - 10
		elseif (e.symbol == "down") then
			monkey.y = monkey.y + 10
		end

		if (monkey.x < 100) then
			monkey.x = 100
		end

		if (monkey.x > 300) then
			monkey.x = 300
		end

		if (monkey.y < 100) then
			monkey.y = 100
		end

		if (monkey.y > 300) then
			monkey.y = 300
		end

		if collide(monkey, banana) then
			win = 1

			layer0:compose(iwinner, banana.x+banana.dx/2, banana.y+banana.dy/2)

			--system.sleep(2*1000)

			break
		end

		redraw()
	end

	events.wait() 
end

