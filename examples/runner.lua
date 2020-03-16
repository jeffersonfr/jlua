layer0 = canvas.new(1280, 720)

local w, h = layer0:size()

local START = 20
local END = w - 20*2
local SIZE = 64
local WIN = false

local tab = {
	{x=0, i=math.random(4), color=0xffa00000},
	{x=0, i=math.random(4), color=0xff00a000},
	{x=0, i=math.random(4), color=0xffa0a000},
	{x=0, i=math.random(4), color=0xff0000a0}
}

local back = canvas.new("images/olimpiadas.png")
local winner = canvas.new("images/winner.png")

layer0:compose(back, 0, 0, w, h)

local runner = canvas.new("images/runner.png")

rw, rh = runner:size()

rw = rw/9
rh = rh/1

-- layer0:translate(0, 320)

function render(tick)
	if (WIN == false) then
		for j=1,4,1 do
			layer0:color(tab[j].color)
			layer0:rect("fill", START, (SIZE+8)*j, END, SIZE)

			layer0:color(0xc0, 0xc0, 0xc0, 0xff)
			layer0:rect("fill", w - SIZE - 80, (SIZE+8)*j, 10, SIZE)
			layer0:rect("fill", w - SIZE - 60, (SIZE+8)*j, 10, SIZE)
			layer0:rect("fill", w - SIZE-40, (SIZE+8)*j, 10, SIZE)

			local index = math.floor(tab[j].i) % 9

			layer0:compose(runner, index*rw, 0, rw, rh, tab[j].x+20, (SIZE+8)*j, SIZE, SIZE)

			local random = math.random(64)
			
			tab[j].x = tab[j].x + random*tick
			tab[j].i = tab[j].i + tick*(random/8 + 8)

			if ((tab[j].x+SIZE) >= (w - SIZE - 20)) then
				if (WIN == false) then
					layer0:compose(winner, tab[j].x, (SIZE + 8)*j)

					WIN = true
				end
			end
		end
	end

	canvas.compose(layer0, 0, 0, canvas.size())
end

