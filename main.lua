Data = require'data'
Joystick = require'joystick'
Player = require'player'
Screen = require'screen'

dofile("world0.dat")

global_player0 = Player:new{
  drawable = love.graphics.newImage("pixmaps/char01.png"),
  quad = love.graphics.newQuad(16, 0, 16, 16, 48, 64),
  x = 64, y = 64, room = 116
}

global_screen0 = Screen:new()

global_room0 = Data.rooms0[global_player0.room]
global_background = Data.screens[global_room0]
global_screen0:set(global_room0)

function love.update(dt)
  local speed = 100
  local f = {[0] = 0, 16, 32, 16}
  local x = f[math.floor( love.timer.getTime() * 10 % 4 )]
  if Joystick.up then
    global_player0:move(0, -speed*dt)
    global_player0.quad:setViewport(x, 48, 16, 16)
  elseif Joystick.down then
    global_player0:move(0, speed*dt)
    global_player0.quad:setViewport(x, 0, 16, 16)
  end
  if Joystick.left then
    global_player0:move(-speed*dt, 0)
    global_player0.quad:setViewport(x, 16, 16, 16)
  elseif Joystick.right then
    global_player0:move(speed*dt, 0)
    global_player0.quad:setViewport(x, 32, 16, 16)
  end
  global_screen0:bind(global_player0)
  if global_player0.x < 16 then
    global_player0.room = global_player0.room - 1
    global_room0 = Data.rooms0[global_player0.room]
    global_background = Data.screens[global_room0]
    global_screen0:set(global_room0)
    global_player0.x = 272
  elseif global_player0.x > 288 then
    global_player0.room = global_player0.room + 1
    global_room0 = Data.rooms0[global_player0.room]
    global_background = Data.screens[global_room0]
    global_screen0:set(global_room0)
    global_player0.x = 32
  elseif global_player0.y < 48 then
    global_player0.room = global_player0.room - 16
    global_room0 = Data.rooms0[global_player0.room]
    global_background = Data.screens[global_room0]
    global_screen0:set(global_room0)
    global_player0.y = 192
  elseif global_player0.y > 208 then
    global_player0.room = global_player0.room + 16
    global_room0 = Data.rooms0[global_player0.room]
    global_background = Data.screens[global_room0]
    global_screen0:set(global_room0)
    global_player0.y = 64
  end
end

function love.draw()
--  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(global_background)
  love.graphics.draw(
    global_player0.drawable,
    global_player0.quad,
    global_player0.x, global_player0.y
  )
  love.graphics.point(global_player0.x, global_player0.y)
--  love.graphics.setColor(0, 0, 0, 127)
--  love.graphics.rectangle('fill', 0, 32, 320, 208)
end
