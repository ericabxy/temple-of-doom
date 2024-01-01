local screen = {
  doors = {}
}

function screen:bind(arg)
  if arg.x < 32 then
    if arg.y < 120 or arg.y > 136 or not self.west then
      arg.x = 32
    end
  elseif arg.x > 272 then
    if arg.y < 120 or arg.y > 136 or not self.east then
      arg.x = 272
    end
  end
  if arg.y < 64 then
    if arg.x < 144 or arg.x > 160 or not self.north then
      arg.y = 64
    end
  elseif arg.y > 192 then
    if arg.x < 144 or arg.x > 160 or not self.south then
      arg.y = 192
    end
  end
end

function screen:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function screen:set(n)
  if n % 2 > 0 then
    self.north = true
  else
    self.north = false
  end
  if n % 4 > 1 then
    self.east = true
  else
    self.east = false
  end
  if n % 8 > 3 then
    self.south = true
  else
    self.south = false
  end
  if n % 16 > 7 then
    self.west = true
  else
    self.west = false
  end
end

return screen
