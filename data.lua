local data = {
  room0 = 116,
  rooms0 = {},
  screens = {}
}

function Map(b)
  data.rooms0 = b
end

function Screens(b)
  for k, v in pairs(b) do
    data.screens[k] = love.graphics.newImage(v)
  end
end

function Setup(b)
  data.room0 = b.room
end

return data
