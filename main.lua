Joystick = require'joystick'
Player = require'player'
Screen = require'screen'

global_player0 = Player:new{
  drawable = love.graphics.newImage("pixmaps/char01.png"),
  quad = love.graphics.newQuad(16, 0, 16, 16, 256, 256),
  x = 64, y = 64
}

global_screen0 = Screen:new()

global_background = love.graphics.newImage("pixmaps/room07.png")
global_screen0:set(07)

function love.update(dt)
  local speed = 100
  if Joystick.up then
    global_player0:move(0, -speed*dt)
  elseif Joystick.down then
    global_player0:move(0, speed*dt)
  end
  if Joystick.left then
    global_player0:move(-speed*dt, 0)
  elseif Joystick.right then
    global_player0:move(speed*dt, 0)
  end
  global_screen0:bind(global_player0)
  global_player0:clamp{left=22, top=56, right=280, bottom=200}
end

function love.draw()
  love.graphics.draw(global_background)
  love.graphics.draw(
    global_player0.drawable,
    global_player0.quad,
    global_player0.x, global_player0.y
  )
  love.graphics.point(global_player0.x, global_player0.y)
end
