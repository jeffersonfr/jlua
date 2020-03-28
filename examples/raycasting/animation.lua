Animation = {
}

Animation.__index = Animation

--[[
-- [col, row]: animate map blocks
-- [col, -1]: animate game sprites
--]]
function Animation:createMapAnimation(map, col, row, index, loop, startDelay, delay, frames)
   local obj = {}
   
   setmetatable(obj, Animation)
 
   obj.animationType = "map"
   obj.startDelay = startDelay
   obj.map = map
   obj.col = col
   obj.row = row
   obj.frames = frames
   obj.index = index
   obj.loop = loop
   obj.delay = delay
   obj.running = false
   obj.counter = 0
   obj.isValid = true
   obj.begin = nil -- callback before the first animation
   obj.callback = nil -- callback for every animation
   obj.finish = nil -- callback after the last animation
   
   return obj
end

function Animation:createSpriteAnimation(sprite, velX, velY, index, loop, startDelay, delay, frames)
   local obj = {}
   
   setmetatable(obj, Animation)
 
   obj.animationType = "sprite"
   obj.startDelay = startDelay
   obj.sprite = sprite
   obj.velX = velX
   obj.velY = velY
   obj.frames = frames
   obj.index = index
   obj.loop = loop
   obj.delay = delay
   obj.running = false
   obj.counter = 0
   obj.isValid = true
   obj.begin = nil -- callback before the first animation
   obj.callback = nil -- callback for every animation
   obj.finish = nil -- callback after the last animation
   
   return obj
end

function Animation:createTimeoutAnimation(loop, startDelay, delay)
   local obj = {}
   
   setmetatable(obj, Animation)
 
   obj.animationType = "timeout"
   obj.startDelay = startDelay
   obj.loop = loop
   obj.delay = delay
   obj.running = false
   obj.counter = 0
   obj.isValid = true
   obj.begin = nil -- callback before the first animation
   obj.callback = nil -- callback for every animation
   obj.finish = nil -- callback after the last animation
   
   return obj
end

function Animation:start()
  self.running = true
end

function Animation:stop()
  self.running = false
end

--[[
--  function pointers avaiable
--  .. begin: called when the animation starts, if loop is true this function is called every start
--  .. callback: called when the delay is reached
--  .. finish: called when the animation finishes, if loop is true this function is called every finish
--]]
function Animation:update(tick)
  if self.running == false or self.isValid == false then
    return
  end

  self.counter = self.counter + tick

  if self.startDelay >= 0 and self.counter < self.startDelay then
    return
  end

  if self.startDelay >= 0 then
    self.counter = self.counter - self.startDelay
    self.startDelay = -1

    if self.begin ~= nil then
      self:begin()
    end
  end

  if self.counter >= self.delay then
    if self.callback ~= nil then
      self:callback()
    end

    if self.animationType == "sprite" then
      self.sprite.id = self.frames[self.index + 1]
      
      local x = self.sprite.x + self.velX
      local y = self.sprite.y + self.velY

      if x < 0 or y < 0 or x > w2 or y > h2 then
        if self.finish ~= nil then
          self:finish()
        end

        self:invalidate()
      end
      
      self.sprite.x = x
      self.sprite.y = y

      self.index = math.fmod(self.index + 1, #self.frames)

      if self.index == 0 then
        if self.loop == false then
          self.running = false
        end

        if self.finish ~= nil then
          self:finish()
        end
      end
    elseif self.animationType == "map" then
      local flag = config.grid[self.row][self.col] & 0xf000
    
      config.grid[self.row][self.col] = self.frames[self.index + 1] | flag -- update config.grid
      
      self.index = math.fmod(self.index + 1, #self.frames)

      if self.index == 0 then
        if self.loop == false then
          self.running = false
        end

        if self.finish ~= nil then
          self:finish()
        end
      end
    end

    self.counter = self.counter - self.delay
  end
end

function Animation:invalidate()
  self.isValid = false
end

