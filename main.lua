display.setStatusBar(display.HiddenStatusBar)
system.setAccelerometerInterval(30)

local ball = display.newImage("ball.png")

Runtime:addEventListener("touch", function(event)
  if "began" == event.phase then
    if ball.tween then
      transition.cancel(ball.tween)
    end
   ball.tween = transition.to(ball, {time=700, x=event.x, y=event.y})
  end
end)

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
local arrayCells = {}
local arrayTmpCells = {}

local resetCells = function()
  for col=1, cols do
    table.insert(arrayCells, {})
    for row=1, rows do
      local cell = makeCell()
      cell.col = col
      cell.row = row

      cell.width = intWidth
      cell.height = intHeight

      cell.x = (col - 1) * intWidth
      cell.y = (row - 1) * intHeight
      table.insert(arrayCells[#arrayCells], cell)
    end
  end

  arrayCells[1][1].up = false
  arrayCells[1][1].left = false
  arrayCells[1][1].start = true

  arrayCells[cols][rows].right = true
  arrayCells[cols][rows].down = true
  arrayCells[cols][rows].stop = true
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

  if col + 1 <= cols and not arrayCells[col + 1][row].visited then
    table.insert(neighbors, arrayCells[col + 1][row])
  end

  if col - 1 >= 1 and not arrayCells[col - 1][row].visited then
    table.insert(neighbors, arrayCells[col - 1][row])
  end

  if row + 1 <= rows and not arrayCells[col][row + 1].visited then
    table.insert(neighbors, arrayCells[col][row + 1])
  end

  if row - 1 >= 1 and not arrayCells[col][row - 1].visited then
    table.insert(neighbors, arrayCells[col][row - 1])
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
  wall:setColor( 255, 0, 0, 255 )
  wall.width = 1

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
      local cell = arrayCells[col][row]
      drawWalls(cell)
  --    local rect = display.newRect(cell.x, cell.y, cell.width, cell.height)
 --     rect:setFillColor(255,255,255, 0)
--      rect:setStrokeColor(0,0,255)
    end
  end
end


resetCells()
carve(arrayCells[math.random(cols)][math.random(rows)])
drawCells()
