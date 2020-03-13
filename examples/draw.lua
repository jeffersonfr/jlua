layer0 = canvas.new()

c1 = "black"
c2 = "white"
c3 = "green"
size = 16

layer0:color(c1)
layer0:pen(-size)
layer0:rect("draw", 100, 100, 400, 400)
layer0:pen(size)
layer0:rect("draw", 100, 100, 400, 400)
layer0:color(c2)
layer0:pen(1)
layer0:rect("draw", 100, 100, 400, 400)
layer0:color(c3)
layer0:rect("fill", 150, 150, 300, 300)

layer0:color(c1)
layer0:pen(-2*size)
layer0:polygon("close", 600, 100, 0, 0, 400, 0, 400, 400, 200, 200, 0, 400)
layer0:pen(2*size)
layer0:polygon("close", 600, 100, 0, 0, 400, 0, 400, 400, 200, 200, 0, 400)
layer0:color(c2)
layer0:pen(1)
layer0:polygon("close", 600, 100, 0, 0, 400, 0, 400, 400, 200, 200, 0, 400)
layer0:color(c3)
layer0:polygon("fill", 640, 140, 0, 0, 320, 0, 320, 280, 160, 120, 0, 280)

layer0:color(c1)
layer0:pen(-2*size)
layer0:polygon("draw:close", 1100, 100, 0, 0, 400, 0, 200, 400)
layer0:pen(2*size)
layer0:polygon("draw:close", 1100, 100, 0, 0, 400, 0, 200, 400)
layer0:color(c2)
layer0:pen(1)
layer0:polygon("draw:close", 1100, 100, 0, 0, 400, 0, 200, 400)
layer0:color(c3)
layer0:polygon("fill", 1100, 100, 50, 40, 350, 40, 200, 340)

layer0:color(c1)
layer0:pen(-size)
layer0:arc("draw", 300, 800, 200)
layer0:pen(size)
layer0:arc("draw", 300, 800, 200)
layer0:color(c2)
layer0:pen(1)
layer0:arc("draw", 300, 800, 200)
layer0:color(c3)
layer0:arc("fill", 300, 800, 100, 100)

layer0:color(c1)
layer0:pen(-size)
layer0:arc("draw", 800, 800, 200, 200, 0, 120)
layer0:pen(size)
layer0:arc("draw", 800, 800, 200, 200, 0, 120)
layer0:color(c2)
layer0:pen(1)
layer0:arc("draw", 800, 800, 200, 200, 0, 120)
layer0:color(c3)
layer0:arc("fill", 800, 800, 100, 100, 0, 120)

layer0:color(c1)
layer0:pen(-size)
layer0:arc("draw", 1300, 800, 200, 100)
layer0:pen(size)
layer0:arc("draw", 1300, 800, 200, 100)
layer0:color(c2)
layer0:pen(1)
layer0:arc("draw", 1300, 800, 200, 100)
layer0:color(c3)
layer0:arc("fill", 1300, 800, 100, 50)

colors = {}
ncolors = 512
sixth = math.floor(ncolors/6.0)

for i=1,ncolors do 
	if (i <= 2*sixth) then
		colors[#colors+1] = 0
	elseif (i > 2*sixth and i < 3*sixth) then
		colors[#colors+1] = (i-2*sixth)*255/sixth
	elseif (i >= 3*sixth and i <= 5*sixth) then
		colors[#colors+1] = 255
	elseif (i > 5*sixth and i < 6*sixth) then
		colors[#colors+1] = 255-(i-5*sixth)*255/sixth
	else --if (i >= 6*sixth) then
		colors[#colors+1] = 0
	end
end

for i=1,ncolors do
	r = colors[math.floor(i+2*sixth)%ncolors+1]
	g = colors[math.floor(i+4*sixth)%ncolors+1]
	b = colors[i]

	layer0:color(r, g, b)
	layer0:line(1600, 100+i, 1700, 100+i)
end

for i=0,ncolors do
	layer0:color(i/2, i/2, i/2, 0xff)
	layer0:line(1750, 100+i, 1850, 100+i)
end

