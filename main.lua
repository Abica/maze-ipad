require "helpers"
local sprite = require "sprite"

display.setStatusBar(display.HiddenStatusBar)
local bringToFront = function(group)
  if group then
    local parent = group.parent
    parent:remove(group)
    parent:insert(group)
  end
end

local rotate = function(o, d)
  local directions = {up=1, left=2, right=3, down=4}
  o.rotation = 90 * (directions[d] - 1)
end

--local ball = display.newImage("ball.png")
---[[
local ball = sprite.newAnim {
  "magenta_1_medium.png",
  "magenta_2_medium.png",
  "magenta_3_medium.png",
  "magenta_4_medium.png",
  "magenta_5_medium.png",
  "magenta_6_medium.png",
  "magenta_7_medium.png",
  "magenta_8_medium.png",
  "magenta_8_medium.png",
  "magenta_9_medium.png",
  "magenta_10_medium.png",
  "magenta_11_medium.png",
  "magenta_12_medium.png",
}

ball:play()
ball:translate(ball.width / 2, ball.height / 2)
--]]

function table.shuffle(t)
  local n = #t
  while n > 1 do
    local k = math.random(n)
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end

  return t
end

local makeCell = function()
  return {
    up      = true,
    down    = true,
    left    = true,
    right   = true,
    path    = false,
    visited = false
  }
end

local makeVertex = function(x, y)
  return {
    x = x,
    y = y
  }
end

local intWidth = ball.width
local intHeight = ball.height
local cols = display.contentWidth / intWidth
local rows = display.contentHeight / intHeight
local cells = {}
local arrayTmpCells = {}
local walls = display.newGroup()

local emptyCells = function()
  helpers.cleanup(walls)
  for col=#cells, 1, -1 do
    for row=#cells[col], 1, -1 do
      local cell = cells[col] and cells[col][row]
      if cell then
        helpers.cleanup(cell.rect)
      end
      table.remove(cells[col], row)
    end
    table.remove(cells, col)
  end
end

local resetCells = function()
  for col=1, cols do
    table.insert(cells, {})
    for row=1, rows do
      local cell = makeCell()
      cell.col = col
      cell.row = row

      cell.width = intWidth
      cell.height = intHeight

      cell.x = (col - 1) * intWidth
      cell.y = (row - 1) * intHeight
      table.insert(cells[#cells], cell)
    end
  end

  --cells[1][1].up = false
  --cells[1][1].left = false
  cells[1][1].start = true
  ball.col = 1
  ball.row = 1

 -- cells[cols][rows].right = false
--  cells[cols][rows].down = false
  cells[cols][rows].stop = true
end

local connect = function(cellA, cellB)
  if cellA.col < cellB.col then
    cellA.right = false
    cellB.left = false
  elseif cellA.col > cellB.col then
    cellA.left = false
    cellB.right = false
  elseif cellA.row < cellB.row then
    cellA.down = false
    cellB.up = false
  elseif cellA.row > cellB.row then
    cellA.up = false
    cellB.down = false
  end
end

local neighborsOf = function(cell)
  local neighbors = {}
  local col = cell.col
  local row = cell.row

  if col + 1 <= cols and not cells[col + 1][row].visited then
    table.insert(neighbors, cells[col + 1][row])
  end

  if col - 1 >= 1 and not cells[col - 1][row].visited then
    table.insert(neighbors, cells[col - 1][row])
  end

  if row + 1 <= rows and not cells[col][row + 1].visited then
    table.insert(neighbors, cells[col][row + 1])
  end

  if row - 1 >= 1 and not cells[col][row - 1].visited then
    table.insert(neighbors, cells[col][row - 1])
  end

  return neighbors
end

local carve

carve = function(cell)
  cell.visited = true
  local neighbors = neighborsOf(cell)
  table.shuffle(neighbors)

  for i, neighbor in ipairs(neighbors) do
    if neighbor and not neighbor.visited then
      table.insert(arrayTmpCells, cell)
      connect(neighbor, cell)
    else
      table.remove(arrayTmpCells)
      local neighbor = arrayTmpCells[#arrayTmpCells]
    end

    if #arrayTmpCells < 1 or not neighbor then
      return false
    else
      carve(neighbor)
    end
  end
end

local drawWall = function(x1, y1, x2, y2)
  local wall = display.newLine(x1, y1, x2, y2)

--  wall:append( 105,-35, 43,16, 65,90, 0,45, -65,90, -43,15, -105,-35, -27,-35, 0,-110 )

  -- default color and width (can be modified later)
  wall:setColor(math.random(255), math.random(255), math.random(255), 255 )
  wall:setColor(255, 50, 50, 255)
  wall:setColor(0, 255, 200, 255)
  wall.width = 1

  walls:insert(wall)
  return wall
end

local drawWalls = function(cell)
  if cell.up then
    drawWall(cell.x, cell.y, cell.x + cell.width, cell.y)
  end

  if cell.right then
    drawWall(cell.x + cell.width, cell.y, cell.x + cell.width, cell.y + cell.height)
  end

  if cell.left then
    drawWall(cell.x, cell.y, cell.x, cell.y + cell.height)
  end

  if cell.down then
    drawWall(cell.x, cell.y + cell.height, cell.x + cell.width, cell.y + cell.height)
  end
end

local drawCells = function()
  for col=1, cols do
    for row=1, rows do
      local cell = cells[col][row]
      cell.rect = display.newRect(cell.x, cell.y, cell.width, cell.height)
      if cell.stop then
        cell.rect:setFillColor(0, 0, 255, 100)
      elseif cell.start then
        cell.rect:setFillColor(0, 255, 0, 100)
      else
        --local rect = display.newRect(cell.x, cell.y, cell.width, cell.height)
        --rect:setFillColor(math.random(255), math.random(255), math.random(255), 30 )
        --rect:setFillColor(0, 0, 0)
      end
      drawWalls(cell)
    end
  end
end

local newGame = function()
  resetCells()
  carve(cells[math.random(cols)][math.random(rows)])
  drawCells()
  bringToFront(ball)
end

newGame()

local inBounds = function(x, y)
  return x > ball.width / 2 and
         y > ball.height / 2 and
         x < display.contentWidth - ball.width / 2 and
         y < display.contentHeight - ball.height / 2
end

local ballHeaded = function(x, y, xInstant, yInstant)
  local vertical = math.abs(xInstant) < math.abs(yInstant)
  --local vertical = math.abs(x) < math.abs(y)
  print("xInstant = ", xInstant)
  print("yInstant = ", yInstant)

  print("x = ", x)
  print("y = ", y)
  if vertical then
    if yInstant < 0 then
      return "down"
    else
      return "up"
    end
  else
    if xInstant < 0 then
      return "left"
    else
      return "right"
    end
  end
end

local hitWall = function(direction, cell)
  return cell[direction]
end

local directionBlocked = function(direction, x, y, cell)
  return not inBounds(x, y) or hitWall(direction, cell)
end

local directionTransform = {
  up = {x=0, y=-1},
  down = {x=0, y=1},
  left = {x=-1, y=0},
  right = {x=1, y=0},
}

Runtime:addEventListener("accelerometer", function(event)
  local x = event.xGravity * ball.width
  local y = -event.yGravity * ball.height
  if event.isShake then
    emptyCells()
    newGame()
  else
    local cell = cells[ball.col] and cells[ball.col][ball.row]
    if cell then
      local direction = ballHeaded(x, y, event.xInstant, event.yInstant)
      if not hitWall(direction, cell) then --and not directionBlocked(direction, ball.x + x, ball.y + y, cell) then

        local transform = directionTransform[direction]
        local nextCell = cells[ball.col + transform.x] and cells[ball.col + transform.x][ball.row + transform.y]
        if nextCell then
          if cell.path then
            cell.rect:setFillColor(224, 0, 0, 100)
          else
            cell.rect:setFillColor(255, 255, 224, 100)
            cell.path = true
          end

          ball.col = nextCell.col
          ball.row = nextCell.row

          rotate(ball, direction)
          ball.x = nextCell.x + ball.width / 2
          ball.y = nextCell.y + ball.height / 2
        end
        if nextCell.stop then
         emptyCells()
         newGame()
        end
      end
    end
  end
end)

