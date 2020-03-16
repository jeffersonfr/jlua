layer0 = canvas.new(1920, 1080)

local m = 120
local w, h = layer0:size()
local cell_width = w/m
local cell_height = h/m
local cell = {}
 
function evolve(cell)
	local m = #cell
	local cell2 = {}
	for i = 1, m do
		cell2[i] = {}
		for j = 1, m do
			cell2[i][j] = cell[i][j]
		end
	end

	for i = 1, m do
		for j = 1, m do
			local count

			if cell2[i][j] == 0 then 
				count = 0 
			else 
				count = -1 
			end

			for x = -1, 1 do
				for y = -1, 1 do
					if i+x >= 1 and 
						i+x <= m and 
						j+y >= 1 and 
						j+y <= m and cell2[i+x][j+y] == 1 then 

						count = count + 1 
					end
				end
			end

			if count < 2 or count > 3 then 
				cell[i][j] = 0 
			end

			if count == 3 then 
				cell[i][j] = 1 
			end
		end
	end

	return cell
end    

function birth(i,j)
	layer0:rect('fill', (i-1) * cell_width, (j-1) * cell_height, cell_width, cell_height)
end

function refresh()
	-- draw board
	layer0:color("white")
	layer0:rect('fill', 0, 0, layer0:size())
	layer0:color("black")

	for i=1,m do
		local px = (i-1)*cell_width
		local py = (i-1)*cell_height

		layer0:line(px, 0, px, h);
		layer0:line(0, py, w, py);
	end

	-- draw life
	for i=1,m do
		for j=1,m do
			if cell[i][j] == 1 then 
				birth(i,j)
			end
		end
	end    

	cell = evolve(cell)
end

layer0:color('white')
layer0:rect('fill', 0, 0, w, h)

for i = 1, m do
	cell[i] = {}
	for j = 1, m do
		cell[i][j] = 0
	end
end

for j=1,m do
	cell[j][m/2] = 1
end

function render(tick)
	refresh()

	canvas.compose(layer0, 0, 0, canvas.size())
end
