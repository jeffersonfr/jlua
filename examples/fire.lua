local w, h = display.size()

screen0 = {}

palette0 = {
  0xff070707, 0xff1f0707, 0xff2f0f07, 0xff470f07,
  0xff571707, 0xff671f07, 0xff771f07, 0xff8f2707,
  0xff9f2f07, 0xffaf3f07, 0xffbf4707, 0xffc74707,
  0xffdf4f07, 0xffdf5707, 0xffdf5707, 0xffd75f07,
  0xffd75f07, 0xffd7670f, 0xffcf6f0f, 0xffcf770f,
  0xffcf7f0f, 0xffcf8717, 0xffc78717, 0xffc78f17,
  0xffc7971f, 0xffbf9f1f, 0xffbf9f1f, 0xffbfa727,
  0xffbfa727, 0xffbfaf2f, 0xffb7af2f, 0xffb7b72f,
  0xffb7b737, 0xffcfcf6f, 0xffdfdf9f, 0xffefefc7,
  0xffffffff
};


for j=1,64 do
  local line = {}

  for i=1,128 do
    line[i] = 0
  end

  screen0[j] = line
end

local line = {}

for i=1,#screen0[1] do
  line[i] = 36
end

screen0[#screen0+1] = line

layer0 = canvas.new(#screen0[1], #screen0)

function render(tick)
  for j=1,#screen0-1 do
    for i=1,#screen0[1] do
      screen0[j][i] = screen0[j+1][i] - math.floor(math.random()*4)

      if screen0[j][i] < 0 then
        screen0[j][i] = 0
      end
    end
  end

  for j=1,#screen0-1 do
    for i=1,#screen0[1] do
      layer0:pixels(i, j, palette0[screen0[j][i] + 1])
    end
  end

	canvas.compose(layer0, 0, 0, display.size())
end
