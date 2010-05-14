require "helpers"
require "os"

local colors = {
  green = {0, 255, 0},
  red = {255, 0, 0},
  blue = {0, 0, 255},
  yellow = {100, 100, 100},
  green = {0, 255, 0},
  white = {255, 255, 255}
}

local walls = display.newGroup()

local mapWidth = 24
local mapHeight = 24

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

local posX = 22
local posY = 12  -- x and y start position
local dirX = -1
local dirY = 0 -- initial direction vector
local planeX = 0
local planeY = 0.66 -- the 2d raycaster version of camera plane

local time = 0 -- time of current frame
local oldTime = 0 -- time of previous frame

local raycast = function()
  for x=0, display.contentWidth do
    -- calculate ray position and direction
    local cameraX = 2 * x / display.contentWidth - 1 -- x-coordinate in camera space
    local rayPosX = posX
    local rayPosY = posY
    local rayDirX = dirX + planeX * cameraX
    local rayDirY = dirY + planeY * cameraX
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
    local lineHeight = math.abs(helpers.round(display.contentHeight / perpWallDist))

    -- calculate lowest and highest pixel to fill in current stripe
    local drawStart = -lineHeight / 2 + display.contentHeight / 2
    if (drawStart < 0) then
      drawStart = 0
    end

    local drawEnd = lineHeight / 2 + display.contentHeight / 2
    if drawEnd >= display.contentHeight then
      drawEnd = display.contentHeight - 1
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
      wall.alpha = 0.5
    end

    -- default color and width (can be modified later)
   -- wall:setColor(255, 50, 50, 255)
   -- wall:setColor(0, 255, 200, 255)
    wall.width = 1

    walls:insert(wall)
  end
  -- timing for input and FPS counter
  oldTime = time
  time = os.time()
  local frameTime = (time - oldTime) / 1000.0 -- frameTime is the time this frame has taken, in seconds
  print(1.0 / frameTime) -- FPS counter

  -- speed modifiers
  local moveSpeed = frameTime * 5.0 -- the constant value is in squares/second
  local rotSpeed = frameTime * 3.0 -- the constant value is in radians/second
end

raycast()

local frameTime = 1--math.abs(event.xInstant)
Runtime:addEventListener("accelerometer", function(event)
  helpers.cleanup(walls)
  oldTime = time
  time = event.time
  -- speed modifiers

  -- move forward if no wall in front of you
  if event.yInstant < 0 then
    local moveSpeed = frameTime * 5.0 -- the constant value is in squares/second
    local rotSpeed = frameTime * 3.0 -- the constant value is in radians/second

    if worldMap[helpers.round(posX + dirX * moveSpeed)][helpers.round(posY)] == 0 then
      posX = posX + dirX * moveSpeed
    end

    if worldMap[helpers.round(posX)][helpers.round(posY + dirY * moveSpeed)] == 0 then
      posY = posX + dirY * moveSpeed
    end
  end

  -- move backwards if no wall behind you
  if event.yInstant > 0 then
    local moveSpeed = frameTime * 5.0 -- the constant value is in squares/second

    print( helpers.round(posX - dirX * moveSpeed), helpers.round(posY))
    if worldMap[helpers.round(posX - dirX * moveSpeed)][helpers.round(posY)] == 0 then
      posX = posX - dirX * moveSpeed
    end

    if worldMap[helpers.round(posX)][helpers.round(posY - dirY * moveSpeed)] == 0 then
      posY = posX - dirY * moveSpeed
    end
  end

  -- rotate to the right
  if event.xInstant > 0 then
    local rotSpeed = frameTime * 3.0 -- the constant value is in radians/second

    -- both camera direction and camera plane must be rotated
    local oldDirX = dirX
    dirX = dirX * math.cos(-rotSpeed) - dirY * math.sin(-rotSpeed)
    dirY = oldDirX * math.sin(-rotSpeed) + dirY * math.cos(-rotSpeed)

    local oldPlaneX = planeX
    planeX = planeX * math.cos(-rotSpeed) - planeY * math.sin(-rotSpeed)
    planeY = oldPlaneX * math.sin(-rotSpeed) + planeY * math.cos(-rotSpeed)
  end

  -- rotate to the left
  if event.xInstant < 0 then
    local rotSpeed = frameTime * 3.0 -- the constant value is in radians/second

    -- both camera direction and camera plane must be rotated
    local oldDirX = dirX
    dirX = dirX * math.cos(rotSpeed) - dirY * math.sin(rotSpeed)
    dirY = oldDirX * math.sin(rotSpeed) + dirY * math.cos(rotSpeed)

    local oldPlaneX = planeX
    planeX = planeX * math.cos(rotSpeed) - planeY * math.sin(rotSpeed)
    planeY = oldPlaneX * math.sin(rotSpeed) + planeY * math.cos(rotSpeed)
  end

  raycast()
end)