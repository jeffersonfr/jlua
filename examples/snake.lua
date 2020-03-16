layer0 = canvas.new(720, 480)

local w, h = layer0:size()

local input_enable = true

local dx = 1
local dy = 0

local size = 8
local device_w = w/2
local device_h = h/2

local snake = {
	direction = "right",
	tail = {
		{x = size, y = size},
		{x = size, y = size},
		{x = size, y = size},
		{x = size, y = size},
		{x = size, y = size},
		{x = size, y = size},
		{x = size, y = size},
		{x = size, y = size},
		{x = size, y = size},
		{x = size, y = size}
	}
}

local board = {
	x = 0,
	y = 0,
	w = device_w/size,
	h = device_h/size,
	food = {
		x = -1, 
		y = -1, 
		visible = false
	}
}

function printf(...) 
	io.write(string.format(unpack(arg))) 
end

-- layer0:translate(board.x, board.y)

function render(tick)
	layer0:color(0x10, 0x10, 0x10, 0xff)
	layer0:rect("fill", 0, 0, board.w*size, board.h*size)
	layer0:color(0xff, 0x00, 0x00, 0xff)

	-- atualiza o movimento
	if (dx ~= 0 or dy ~= 0) then
		for i=#snake.tail,2,-1 do
			snake.tail[i].x = snake.tail[i-1].x
			snake.tail[i].y = snake.tail[i-1].y
		end
		
		snake.tail[1].x = snake.tail[1].x + dx
		snake.tail[1].y = snake.tail[1].y + dy
	end

	-- desenha 
	for i=1,#snake.tail do
		layer0:color(0x00, (0xf0/#snake.tail)*(#snake.tail-i), 0xf0, 0xff)
		layer0:rect("fill", snake.tail[i].x*size, snake.tail[i].y*size, size, size)
	end

	-- verifica se bateu na parede
	if (snake.tail[1].x < 0 or snake.tail[1].x >= board.w or snake.tail[1].y < 0 or snake.tail[1].y >= board.h) then
		input_enable = false

    return
	end

	-- verifica se bateu em tail
	local flag = false

	for i=2,#snake.tail do
		if (snake.tail[1].x == snake.tail[i].x and snake.tail[1].y == snake.tail[i].y) then
			flag = true

      return
		end
	end

	if (flag == true) then
		input_enable = false

    return
	end

	-- verifica se capturou a fruta e aumenta 5 unidades no tamanho da cobrinha
	if (snake.tail[1].x == board.food.x and snake.tail[1].y == board.food.y) then
		board.food.visible = false

		local ox = snake.tail[#snake.tail].x
		local oy = snake.tail[#snake.tail].y

		for i=0,5 do
			-- snake.tail[#snake.tail+1] = {x = snake.tail[#snake.tail].x, y = snake.tail[#snake.tail].y}
			snake.tail[#snake.tail+1] = {x = ox, y = oy}
		end
	end

	-- desenha uma fruta no caminho
	if (board.food.visible == false) then
		while (true) do
			board.food.x = math.random(board.w-10) + 5
			board.food.y = math.random(board.h-10) + 5

			-- evita que seja desenhado sobre tail
			local flag = false

			for i=1,#snake.tail do
				if (board.food.x == snake.tail[i].x and board.food.y == snake.tail[i].y) then
					flag = true

					break
				end
			end

			if (flag == false) then
				break
			end
		end

		board.food.visible = true
	else
		layer0:color(0xf0, 0x00, 0x00, 0xff)
		layer0:rect("fill", board.food.x*size, board.food.y*size, size, size)
	end

	if (event.key("left").state == "pressed") then
		dx = -1
		dy = 0
	end

	if (event.key("right").state == "pressed") then
		dx = 1
		dy = 0
	end

	if (event.key("up").state == "pressed") then
		dx = 0
		dy = -1
	end

	if (event.key("down").state == "pressed") then
		dx = 0
		dy = 1
	end

	canvas.compose(layer0, 0, 0)
end

