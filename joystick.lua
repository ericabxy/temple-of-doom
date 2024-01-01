local joystick = {
}

function love.joystickpressed(n, b)
  if b == 4 then joystick.up = true
  elseif b == 5 then joystick.down = true
  elseif b == 6 then joystick.left = true
  elseif b == 7 then joystick.right = true
  end
end

function love.joystickreleased(n, b)
  if b == 4 then joystick.up = false
  elseif b == 5 then joystick.down = false
  elseif b == 6 then joystick.left = false
  elseif b == 7 then joystick.right = false
  end
end

return joystick
