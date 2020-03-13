layer0 = canvas.new()

local square_size = 50
local board_size = 17
local locX = 1
local locY = 1
local finish = false

local iboard = {
	"bbbbbbbbbbbbbbbbb",
	"broobboooooooooob",
	"bbboooobbbobbbbob",
	"boobobbobooboooob",
	"bboboboobobbobbbb",
	"bboooooboobooboob",
	"boobboboobboboobb",
	"bobooobobooobooob",
	"booobboobobbbbbob",
	"bbbobooboobooooob",
	"booobooboobbbobbb",
	"bobboboobooobooob",
	"bobooobobbboobbob",
	"bobobobooooboooob",
	"bobobobbbbobobbbb",
	"booobobGoooboooob",
	"bbbbbbbbbbbbbbbbb"
}

function redraw()
	local size = square_size/3

	for i=1,#iboard do
		for j=1,#iboard do
			local dx = j*square_size + square_size/2
			local dy = i*square_size + square_size/2

			if (i==locX and j==locY) then
				layer0:color("red")
				layer0:arc('fill', dx, dy, size)
			elseif (iboard[i]:sub(j, j) == 'G') then
				layer0:color("blue")
				layer0:arc('fill', dx, dy, size)
			elseif (iboard[i]:sub(j, j) == 'r') then
				layer0:color("red")
				layer0:arc('fill', dx, dy, size)
			elseif (iboard[i]:sub(j, j) == 'y') then
				layer0:color("green")
				layer0:arc('fill', dx, dy, size)
			elseif (iboard[i]:sub(j, j) == 'b') then
				layer0:color("black")
				layer0:rect('fill', j*square_size,i*square_size,square_size,square_size)
			else
				layer0:color("white")
				layer0:rect('fill', j*square_size,i*square_size,square_size,square_size)
			end
		end
	end
end

function isGoal(x, y)
	if (iboard[x]:sub(y, y) == 'G') then
		return true;
	end

	return false;
end

function setVisited(x, y)
	iboard[x] = iboard[x]:sub(1, y-1) .. 'y' .. iboard[x]:sub(y+1)
	locX = x;
	locY = y;
end

function isWall(x, y)
	if (iboard[x]:sub(y, y) == 'b') then
		return true;
	end

	return false;
end

function isVisited(x, y)
	if (iboard[x]:sub(y, y) == 'y') then
		return true;
	end

	return false;
end

function moveFrom(x, y) 
	if (finish == true) then
		return;
	end

	if (isWall(x,y)) then
		return;
	end

	if (isVisited(x,y)) then
		return;
	end

	if (isGoal(x,y)) then
		finish = true;
	end

	if (finish == false) then
		setVisited(x,y);
		redraw()

		--system.sleep(100);

		moveFrom(x-1,y);
		moveFrom(x+1,y);
		moveFrom(x,y-1);
		moveFrom(x,y+1);
	end
end

moveFrom(2,2)
