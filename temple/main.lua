if love == nil then love = lutro end
function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(love.graphics.newImageFont("share/fonts/alagard_69.png", ' AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789!@#$%^&'))
    NORTH, EAST, SOUTH, WEST = 1, 2, 3, 4
    INWALL, OUTWALL = {38, 48, 266, 184}, {24, 40, 280, 200}
    LEVEL, LOCATE, CHAR, ITEMMAP = load_game(0)
    ITEMS = get_items(ITEMMAP, LOCATE)
    TILES, WALLS, ENEMS = load_room(LEVEL, LOCATE)
    OBJECTS = get_objects({ITEMS, ENEMS, {CHAR}})
    TIMER2, TIMER3 = 0, 0
end

function love.update(dt)
    TIMER2, TIMER3 = (TIMER2+dt*1000)%200, (TIMER3+dt*1000)%300
    set_player_controls()
    move_object(CHAR, dt)
    push_object_out(CHAR, WALLS)
    local direct = object_is_outside(CHAR, OUTWALL)
    if direct then
        local next, x, y = get_next_locate(LOCATE, direct)
        if next ~= LOCATE then
            LOCATE, CHAR.x, CHAR.y = next, x, y
            TILES, WALLS, ENEMS = load_room(LEVEL, LOCATE)
            ITEMS = get_items(ITEMMAP, LOCATE)
            OBJECTS = get_objects({ITEMS, ENEMS, {CHAR}})
        else
            bounce_object_in(CHAR, OUTWALL)
        end
    else
        pickup_items(LOCATE, CHAR.x, CHAR.y, ITEMMAP)
    end
    for i,enem in ipairs(ENEMS) do
        move_object(enem, dt)
        bounce_object_in(enem, INWALL)
        enem.qua:setViewport(math.floor(TIMER2/100)*16, 0, 16, 16)
    end
end

function love.draw()
    love.graphics.scale(2)
    local colors = {{0,0,127},{127,0,0},{0,127,0},{127,127,0}}
    local floor = math.floor((LOCATE-1)/6)+1
    love.graphics.setColor(colors[floor])
    love.graphics.rectangle('fill', 0, 0, 320, 240)
    love.graphics.setColor(255,255,255)
    if TILES then for i,t in ipairs(TILES) do
        if t.qua then love.graphics.draw(t.img, t.qua, t.x, t.y) end
    end end
    for i,obj in ipairs(OBJECTS) do
        love.graphics.draw(obj.img, obj.qua, math.floor(obj.x), math.floor(obj.y))
    end
    love.graphics.rectangle('line', 10, 3, 24, 8)
    love.graphics.rectangle('line', 10, 11, 24, 8)
    love.graphics.rectangle('line', 18, 3, 8, 16)
    if TIMER3 > 100 then
        local x = 4+((math.floor((LOCATE-1)%3)+1)*8)
        local y = -3+(((math.floor((LOCATE-1)/3)%2)+1)*8)
        love.graphics.rectangle('fill', x, y, 5, 5)
    end
    local floorname = {"1st Floor", "2nd Floor", "3rd Floor", "4th Floor"}
    love.graphics.print(floorname[floor], 36, 6)
end

function love.keypressed(k) if k=='escape' then love.event.quit() end end

function pickup_items(locate, x, y, list)
    for i,obj in ipairs(list) do
        if obj.locate == locate and x+8 > obj.x and x+8 < obj.x+16
        and y+8 > obj.y and y+8 < obj.y+16 then
            obj.locate, obj.x, obj.y = 0, 200+(i*18), 5
    end end
end

function get_objects(lists)
    local objects = {}
    for i,list in ipairs(lists) do
        for j,obj in ipairs(list) do
            table.insert(objects, obj)
    end end
    return objects
end

function move_object(obj, dt)
    obj.x, obj.y = obj.x+(obj.dx*dt), obj.y+(obj.dy*dt)
end

function bounce_object_in(obj, blk)
    if     obj.x < blk[1] then obj.x = obj.x+(blk[1]-obj.x)*2 obj.dx=-obj.dx
    elseif obj.x > blk[3] then obj.x = obj.x-(obj.x-blk[3])*2 obj.dx=-obj.dx end
    if     obj.y < blk[2] then obj.y = obj.y+(blk[2]-obj.y)*2 obj.dy=-obj.dy
    elseif obj.y > blk[4] then obj.y = obj.y-(obj.y-blk[4])*2 obj.dy=-obj.dy end
end

function get_items(list, locate)
    local items = {}
    for i,item in ipairs(list) do
        if item.locate==locate or item.locate==0 then table.insert(items, item)
    end end
    return items
end

function object_is_outside(obj, bnd)
    return point_is_outside(obj.x, obj.y, bnd[1], bnd[2], bnd[3], bnd[4])
end

function get_next_locate(locate, direct)
    local exits = {{ 0, 1, 3, 0}, { 0, 1, 3,-1}, { 0, 6, 3,-1},
                   {-3, 1, 0, 6}, {-3, 1, 0,-1}, {-3, 0, 0,-1},
                   { 0, 1, 3, 6}, { 6, 1, 3,-1}, { 0,-6, 3,-1},
                   {-3, 1, 0,-6}, {-3, 1, 0,-1}, {-3, 6, 0,-1},
                   { 0, 1, 3,-6}, {-6, 1, 3,-1}, { 0, 6, 3,-1},
                   {-3, 1, 0, 6}, {-3, 1, 6,-1}, {-3,-6, 0,-1},
                   { 0, 1, 3, 0}, { 0, 1, 3,-1}, { 0,-6, 3,-1},
                   {-3, 1, 0,-6}, {-3, 1,-6,-1}, {-3, 0, 0,-1}}
    local travel = exits[locate][direct]
    if travel and travel ~= 0 then
        local locate = (((locate-1)+travel)%#exits)+1
        local x, y = 150, 150
        if travel == 6 then
            if direct == SOUTH then x, y = 152, 184
            elseif direct == WEST then x, y = 40, 120
            elseif direct == NORTH then x, y = 152, 56
            elseif direct == EAST then x, y = 264, 120 end
        elseif travel == -6 then
            if direct == SOUTH then x, y = 136, 184
            elseif direct == WEST then x, y = 40, 104
            elseif direct == NORTH then x, y = 168, 56
            elseif direct == EAST then x, y = 264, 144 end
        else
            if direct == SOUTH then x, y = 152, 56
            elseif direct == WEST then x, y = 264, 120
            elseif direct == NORTH then x, y = 152, 184
            elseif direct == EAST then x, y = 40, 120 end
        end
        return locate, x, y
    else
        return locate
    end
end

function get_walls(index, inner, outer)
    local walls = {}
    if not index then return walls end  -- invalid arg
    if (math.floor(index/1)%2)==1 then  -- north walls
        table.insert(walls, {outer[1], outer[2], 148, 48})
        table.insert(walls, {156, outer[2], outer[3], 48})
    elseif (math.floor(index/2)%2)==1 then  -- north walls
        table.insert(walls, {outer[1], outer[2], 164, 48})
        table.insert(walls, {172, outer[2], outer[3], 48})
    else
        table.insert(walls, {outer[1], outer[2], outer[3], 48})
    end
    if (math.floor(index/4)%2)==1 then  -- east walls
        table.insert(walls, {inner[3], outer[2], outer[3], 116})
        table.insert(walls, {inner[3], 120, outer[3], outer[4]})
    elseif (math.floor(index/8)%2)==1 then  -- east walls
        table.insert(walls, {inner[3], outer[2], outer[3], 132})
        table.insert(walls, {inner[3], 136, outer[3], outer[4]})
    else
        table.insert(walls, {inner[3], outer[2], outer[3], outer[4]})
    end
    if (math.floor(index/16)%2)==1 then  -- south walls
        table.insert(walls, {outer[1], inner[4], 148, outer[4]})
        table.insert(walls, {156, inner[4], outer[3], outer[4]})
    elseif (math.floor(index/32)%2)==1 then  -- south walls
        table.insert(walls, {outer[1], inner[4], 132, outer[4]})
        table.insert(walls, {140, inner[4], outer[3], outer[4]})
    else
        table.insert(walls, {outer[1], 178, outer[3], outer[4]})
    end
    if (math.floor(index/64)%2)==1 then  -- west walls
        table.insert(walls, {outer[1], outer[2], inner[1], 116})
        table.insert(walls, {outer[1], 120, inner[1], outer[4]})
    elseif (math.floor(index/128)%2)==1 then  -- west walls
        table.insert(walls, {outer[1], outer[2], inner[1], 100})
        table.insert(walls, {outer[1], 104, inner[1], outer[4]})
    else
        table.insert(walls, {outer[1], outer[2], inner[1], outer[4]})
    end
    return walls
end

function get_next_room(locate, direct)
    local climb = k_stair(locate, direct)
    local h = 1 + (math.floor((locate-1)/6)*6)
    if climb then locate = locate + climb
    elseif direct == EAST then  locate = (((locate-h)+1)%6)+h
    elseif direct == SOUTH then locate = (((locate-h)+3)%6)+h
    elseif direct == WEST then  locate = (((locate-h)-1)%6)+h
    elseif direct == NORTH then locate = (((locate-h)-3)%6)+h end
    return locate
end

function load_room(level, locate)
    local tilemaps00 = {20,21,22}
    local tilemaps01 = { 1, 2, 9, 10,19, 6,  7, 8,15, 16, 5,12,
                        13,14, 9, 10,11,18,  1, 2,15, 16,17, 6}
    local tilemaps = level == 0 and tilemaps00 or tilemaps01
    local wallmaps00 = { 5, 69, 65}
    local wallmaps01 = { 20, 84, 84,  69, 85, 65,  84, 85, 88, 133, 69, 69,
                        148, 86, 84,  69, 85, 73,  20, 84, 88, 133,101, 65}
    local wallmaps = level == 0 and wallmaps00 or wallmaps01
    local enems00 = {}
    local enems01 = {{img = love.graphics.newImage("share/tiles/char06.png"),
                      qua = love.graphics.newQuad(0, 0, 16, 16, 48, 64),
                      x = 75, y = 75, dx = 0, dy = 100, sy = 0},
                     {img = love.graphics.newImage("share/tiles/char05.png"),
                      qua = love.graphics.newQuad(0, 0, 16, 16, 48, 64),
                      x = 200, y = 75, dx = 100, dy = 0, sy = 0},
                     {img = love.graphics.newImage("share/tiles/char06.png"),
                      qua = love.graphics.newQuad(0, 0, 16, 16, 48, 64),
                      x = 225, y = 150, dx = 0, dy = 100, sy = 0}}
    local enems = level == 0 and enems00 or enems01
    local walls = get_walls(wallmaps[locate], INWALL, OUTWALL)
    local tiles = get_tiles(tilemaps[locate])
    return tiles, walls, enems
end

function get_tiles(index)
    local maps = {
        {22,23,24,24,24,24,24,24, 6, 7, 8,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 6, 7, 8,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24,24, 6, 7, 8,24,24,24,24,24,25,26},
        {22,23,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24,25,26},
        {17,13,24,24,24,24,24,24, 6, 7, 8,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 9,14,11,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 6, 7, 8,24,24,24,24,24,24, 4,15},
        {17,13,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 9,16,11,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24, 4,15},
        {21,28,24,24,24,24,24,24, 6, 7, 8,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 6,29,18, 3,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 6, 7, 8,24,24,24,24,24,24,27,19},
        {21,28,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24, 6,20,30, 3,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24,27,19},
        {12,13,24,24,24,24,24,24, 9,10,11,24,24,24,24,24,24, 4, 5},
        {22,23,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24, 4, 5},
        {12,13,24,24,24,24,24,24, 1, 2, 3,24,24,24,24,24,24,25,26}}
    if not index or index < 1 or index > #maps then return false end
    local image = love.graphics.newImage("share/tiles/tiles00.png")
    local width, quads, tiles = image:getWidth(), {}, {}
    for x=0,width-16,16 do
        local quad = love.graphics.newQuad(x, 0, 16, 208, width, 208)
        table.insert(quads, quad)
    end
    for i,t in ipairs(maps[index]) do
        if t > 0 then
            local quad = quads[t]
            local tile = {img = image, qua = quad, x = (i*16)-8, y=24}
            table.insert(tiles, tile)
        end
    end
    return tiles
end

function push_object_out(obj, blks)
    if obj.x < INWALL[1] or obj.y < INWALL[2]
    or obj.x > INWALL[3] or obj.y > INWALL[4] then
        for i,blk in ipairs(blks) do
            local dx, dy = point_get_outside(obj.x, obj.y,
                                             blk[1], blk[2], blk[3], blk[4])
            obj.x, obj.y = obj.x + dx, obj.y + dy
    end end
end

function load_game(level)
    local locate = level > 0 and 5 or 1
    local char = {
        img = love.graphics.newImage("share/tiles/char0" .. math.random(1, 2) .. ".png"),
        qua = love.graphics.newQuad(16, 0, 16, 16, 48, 64),
        x = 100, y = 150, dx = 0, dy = 0, sy = 0}
    local image = love.graphics.newImage("share/tiles/items00.png")
    local items = {{img = image, x = 125, y = 60, locate = 11,
             qua = love.graphics.newQuad(0, 0, 16, 16, 80, 16)},
            {img = image, x = 175, y = 60, locate = 2,
             qua = love.graphics.newQuad(16, 0, 16, 16, 80, 16)},
            {img = image, x = 125, y = 120, locate = 15,
             qua = love.graphics.newQuad(32, 0, 16, 16, 80, 16)},
            {img = image, x = 175, y = 120, locate = 16,
             qua = love.graphics.newQuad(48, 0, 16, 16, 80, 16)},
            {img = image, x = 150, y = 90, locate = 20,
             qua = love.graphics.newQuad(64, 0, 16, 16, 80, 16)}}
    return level, locate, char, items
end

function set_player_controls()
    local f = math.floor(TIMER3/100)
    local dx, dy, dist = 0, 0, 75
    local getkey = {btn=love.keyboard.isDown}
    if love == lutro then getkey = {btn=lutro.input.joypad} end
    if getkey.btn('right') then    CHAR.dx =  dist CHAR.sy = 32 CHAR.qua:setViewport(f*16, CHAR.sy, 16, 16)
    elseif getkey.btn("left") then CHAR.dx = -dist CHAR.sy = 16 CHAR.qua:setViewport(f*16, CHAR.sy, 16, 16)
    else CHAR.dx = 0 end
    if getkey.btn('down') then     CHAR.dy =  dist CHAR.sy = 0  CHAR.qua:setViewport(f*16, CHAR.sy, 16, 16)
    elseif getkey.btn("up") then   CHAR.dy = -dist CHAR.sy = 48 CHAR.qua:setViewport(f*16, CHAR.sy, 16, 16)
    else CHAR.dy = 0 end
end

function point_is_outside(x, y, left, top, right, bottom)
  local direct = {}
  if x and y and left and top and right and bottom then
    if x < left then   table.insert(direct, 4) end
    if y < top then    table.insert(direct, 1) end
    if x > right then  table.insert(direct, 2) end
    if y > bottom then table.insert(direct, 3) end
  end
  return direct[1], direct[2]
end

function point_get_inside(x, y, left, top, right, bottom)
  if x and y and left and top and right and bottom then
    if x < left then x = left
    elseif y < top then y = top
    elseif x > right then x = right
    elseif y > bottom then y = bottom
    end
  end
  return x, y
end

function point_get_outside(x, y, left, top, right, bottom)
    local ax, ay, bx, by = right-x, bottom-y, x-left, y-top
    local cx, cy, fx, fy = 0, 0, 0, 0
    if ax > 0 and ay > 0 and bx > 0 and by > 0 then
        if ax < bx then cx = ax else cx = -bx end
        if ay < by then cy = ay else cy = -by end
        if math.abs(cx) < math.abs(cy) then fx = cx
        else fy = cy
    end end
    return fx, fy
end
