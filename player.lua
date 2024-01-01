local player = {
  x = 0,
  y = 0
}

function player:clamp(arg)
  if self.x < arg.left then
    self.x = arg.left
  elseif self.x > arg.right then
    self.x = arg.right
  end
  if self.y < arg.top then
    self.y = arg.top
  elseif self.y > arg.bottom then
    self.y = arg.bottom
  end
end

function player:move(x, y)
  self.x = self.x + x
  self.y = self.y + y
end

function player:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function player:wrap(arg)
  if self.x < arg.left then
    self.x = arg.right
  elseif self.x > arg.right then
    self.x = arg.left
  end
  if self.y < arg.top then
    self.y = arg.bottom
  elseif self.y > arg.bottom then
    self.y = arg.top
  end
end

return player
