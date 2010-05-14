require "helpers"
--require "maze_generator"
require "os"


local texWidth = 64
local texHeight = 64
local screenWidth = display.contentWidth
local screenHeight = display.contentHeight

--local cells = newGame()
local worldMap = {
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
}
--[[
for x=1, #cells do
  local a = {}
  local b = {}
  local c = {}
  for y=1, #cells[x] do
    local cell = cells[x] and cells[x][y]
    local up = 0
    if cell.up then
      up = math.random(4)
    end
    table.insert(a, up)
    table.insert(a, up)
    table.insert(a, up)

    local left = 0
    if cell.left then
      left = math.random(4)
    end
    table.insert(b, left)

    table.insert(b, 0)

    local right = 0
    if cell.right then
      right = math.random(4)
    end
    table.insert(b, right)


    local down = 0
    if cell.down then
      down = math.random(4)
    end
    table.insert(c, down)
    table.insert(c, down)
    table.insert(c, down)
  end
  table.insert(worldMap, a)
  table.insert(worldMap, b)
  table.insert(worldMap, c)
end
--]]

local colors = {
  green = {0, 255, 0},
  red = {255, 0, 0},
  blue = {0, 0, 255},
  yellow = {255, 255, 100},
  green = {0, 255, 0},
  white = {255, 255, 255}
}

local game = {}

local walls = display.newGroup()
local player = {
  posX = 22,
  posY = 22,
  dirX = -1,
  dirY = 0,
}

local camera = {
  planeX = 0,
  planeY = 0.66
}

local time = 0
local previousTime = 0

local raycast = function()
  for x=0, screenWidth do
    --
    -- calculate ray position and direction
    local cameraX = 2 * x / screenWidth - 1
    local rayPosX = player.posX
    local rayPosY = player.posY
    local rayDirX = player.dirX + camera.planeX * cameraX
    local rayDirY = player.dirY + camera.planeY * cameraX

    -- which box of the map we're in
    local mapX = helpers.round(rayPosX)
    local mapY = helpers.round(rayPosY)

    -- length of ray from current position to next x or y-side
    local sideDistX
    local sideDistY

     -- length of ray from one x or y-side to next x or y-side
    local deltaDistX = math.sqrt(1 + (rayDirY * rayDirY) / (rayDirX * rayDirX))
    local deltaDistY = math.sqrt(1 + (rayDirX * rayDirX) / (rayDirY * rayDirY))
    local perpWallDist

    -- what direction to step in x or y-direction (either +1 or -1)
    local stepX
    local stepY

    local hit = 0 -- was there a wall hit?
    local side -- was a NS or a EW      p      p wall hit?

    -- calculate step and initial sideDist
    if (rayDirX < 0) then
      stepX = -1
      sideDistX = (rayPosX - mapX) * deltaDistX
    else
      stepX = 1
      sideDistX = (mapX + 1.0 - rayPosX) * deltaDistX
    end

    if (rayDirY < 0) then
      stepY = -1
      sideDistY = (rayPosY - mapY) * deltaDistY
    else
      stepY = 1
      sideDistY = (mapY + 1.0 - rayPosY) * deltaDistY
    end

    -- perform DDA
    while (hit == 0) do
      -- jump to next map square, OR in x-direction, OR in y-direction
      if (sideDistX < sideDistY) then
        sideDistX = sideDistX + deltaDistX
        mapX = mapX + stepX
        side = 0
      else
        sideDistY = sideDistY + deltaDistY
        mapY = mapY + stepY
        side = 1
      end
      -- Check if ray has hit a wall
      if (worldMap[mapX][mapY] > 0) then
        hit = 1
      end
    end
    -- Calculate distance projected on camera direction (oblique distance will give fisheye effect!)
    if side == 0 then
      perpWallDist = math.abs((mapX - rayPosX + (1 - stepX) / 2) / rayDirX)
    else
      perpWallDist = math.abs((mapY - rayPosY + (1 - stepY) / 2) / rayDirY)
    end

    -- Calculate height of line to draw on screen
    local lineHeight = math.abs(helpers.round(screenHeight / perpWallDist))

    -- calculate lowest and highest pixel to fill in current stripe
    local drawStart = -lineHeight / 2 + screenHeight / 2
    if (drawStart < 0) then
      drawStart = 0
    end

    local drawEnd = lineHeight / 2 + screenHeight / 2
    if drawEnd >= screenHeight then
      drawEnd = screenHeight - 1
    end

    -- draw the pixels of the stripe as a vertical line
    local wall = display.newLine(x, drawStart, x, drawEnd)

    -- choose wall color
    local room = worldMap[mapX][mapY]
    if room == 1 then
      wall:setColor(unpack(colors.red))
    elseif room == 2 then
      wall:setColor(unpack(colors.green))
    elseif room == 3 then
      wall:setColor(unpack(colors.blue))
    elseif room == 4 then
      wall:setColor(unpack(colors.white))
    else
      wall:setColor(unpack(colors.yellow))
    end

    -- give x and y sides different brightness
    if side == 1 then
      wall.alpha = 0.3
    end

    wall.width = 1

    walls:insert(wall)
  end
end

raycast()
local fromCenter = function(obj, x, y)
  obj.x =  screenWidth / 2 + x
  obj.y =  screenHeight  / 2 + y
end

local fromTopCenter = function(obj, x, y)
  obj.x =  screenWidth / 2 + x
  obj.y =  screenHeight  + y
end

local moveForward = function(ticks)
  local frameTime = (time - previousTime) / 1000.0
  local moveSpeed = frameTime * 5.0 -- the constant value is in squares/second

  if worldMap[helpers.round(player.posX + player.dirX * moveSpeed)][helpers.round(player.posY)] == 0 then
    player.posX = player.posX + player.dirX * moveSpeed
  end

  if worldMap[helpers.round(player.posX)][helpers.round(player.posY + player.dirY * moveSpeed)] == 0 then
    player.posY = player.posX + player.dirY * moveSpeed
  end
end

local moveBackward = function()
  local frameTime = (time - previousTime) / 1000.0
  local moveSpeed = frameTime * 5.0 -- the constant value is in squares/second

  if worldMap[helpers.round(player.posX - player.dirX * moveSpeed)][helpers.round(player.posY)] == 0 then
    player.posX = player.posX - player.dirX * moveSpeed
  end

  if worldMap[helpers.round(player.posX)][helpers.round(player.posY - player.dirY * moveSpeed)] == 0 then
    player.posY = player.posX - player.dirY * moveSpeed
  end
end

local rotateCamera = function(speed)
  -- both camera direction and camera plane must be rotated
  local oldDirX = player.dirX
  player.dirX = player.dirX * math.cos(speed) - player.dirY * math.sin(speed)
  player.dirY = oldDirX * math.sin(speed) + player.dirY * math.cos(speed)

  local oldPlaneX = camera.planeX
  camera.planeX = camera.planeX * math.cos(speed) - camera.planeY * math.sin(speed)
  camera.planeY = oldPlaneX * math.sin(speed) + camera.planeY * math.cos(speed)
end


local upButton = display.newImage("up_arrow.png")
fromTopCenter(upButton, 200, -300)

local rightButton = display.newImage("right_arrow.png")
fromTopCenter(rightButton, 300, -200)

local leftButton = display.newImage("left_arrow.png")
fromTopCenter(leftButton, 100, -200)

local downButton = display.newImage("down_arrow.png")
fromTopCenter(downButton, 200, -100)

upButton:addEventListener("touch", function(event)
  if event.phase == "began" then
    game.drawingFunc = moveForward

    game.drawing = true
  elseif event.phase == "ended" then
    game.drawing = false
  end
end)

downButton:addEventListener("touch", function(event)
  if event.phase == "began" then
    game.drawingFunc = moveBackward

    game.drawing = true
  elseif event.phase == "ended" then
    game.drawing = false
  end
end)

rightButton:addEventListener("touch", function(event)
  if event.phase == "began" then
    -- rotate to the right
    game.drawingFunc = function()
      local frameTime = (time - previousTime) / 1000.0
      local speed = frameTime * 3.0
      rotateCamera(-speed)
    end

    game.drawing = true
  elseif event.phase == "ended" then
    game.drawing = false
  end
end)

leftButton:addEventListener("touch", function(event)
  if event.phase == "began" then
    -- the constant value is in radians/second
    game.drawingFunc = function()
      local frameTime = (time - previousTime) / 1000.0
      local speed = frameTime * 3.0
      rotateCamera(speed)
    end

    game.drawing = true
  elseif event.phase == "ended" then
    game.drawing = false
  end
end)


Runtime:addEventListener("enterFrame", function(event)
  if game.drawing then
    helpers.cleanup(walls)
    if game.drawingFunc then
      game.drawingFunc()
    end
    raycast()
  end
  previousTime = time
  time = event.time
end)