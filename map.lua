
-- should these 3 go in the game file?
local tilesDisplayWidth = nil
local tilesDisplayHeight = nil
local tileSize = nil

local currentTileMapQuads = nil
local currentTilesetImage = nil
local currentTileSetBatch = nil

local world = nil

local worldX = nil 
local worldY = nil
local prevWorldX = nil 
local prevWorldY = nil


function generateTileMap(mapObject)
	local result = {}
	for y = 1, tilesDisplayHeight do 
		result[y] = {}
		for x = 1, tilesDisplayWidth do 
			if y == 1 or y == tilesDisplayHeight or x == 1 or x == tilesDisplayWidth then 
				result[y][x] = 2
			else 
				result[y][x] = 1
			end
		end
	end
	
	if mapObject.up then 
		result[1][5] = 1 
		result[1][6] = 1
	end 
	if mapObject.down then 
		result[tilesDisplayHeight][5] = 1 
		result[tilesDisplayHeight][6] = 1
	end 
	if mapObject.left then 
		result[5][1] = 1 
	end 
	if mapObject.right then 
		result[5][tilesDisplayWidth] = 1
	end 

	return result
end 


--[[function getDirection(mapCodes, currentY, currentX)
		
	local rand = love.math.random(1,4)

	-- if a direction fails, it should go and try to get another direction iff it doesn't already have another connection
	if currentY-1 > 1 then -- up one
		return "up"
		--mapCodes[currentY][currentX].up = true 
		--mapCodes[currentY-1][currentX].down = true 
	end 
	if currentY+1 < #mapCodes then -- down one
		return "down"
		--mapCodes[currentY][currentX].down = true 
		--mapCodes[currentY+1][currentX].up = true 
	end 
	if currentX-1 > 1  then -- left one
		return "left"
		--mapCodes[currentY][currentX].left = true 
		--mapCodes[currentY][currentX-1].right = true 
	end 
	if currentX+1 < #mapCodes[currentY] then -- right one
		return "right"
		--mapCodes[currentY][currentX].right = true 
		--mapCodes[currentY][currentX+1].left = true 
	end
end]]

function generateWorld()

	-- start with a blank map. no rooms connecting
	local mapCodes = {}
	for y = 1, tilesDisplayHeight do 
		mapCodes[y] = {}
		for x = 1, tilesDisplayWidth do 
			mapCodes[y][x] = {xPos = x, yPos = y, left = false, right = false, down = false, up = false, searched = false}
		end
	end

	-- breadth first search to join each room.
	local queue = Queue:new()
	local add = {x = 1, y = 1}
	mapCodes[1][1].searched = true
	queue:enqueue(add)
	
	local counter = 0
	while not queue:isEmpty() do 
		local current = queue:dequeue()
		
		if current.y-1 > 1 then -- up one
			mapCodes[current.y][current.x].up = true 
			mapCodes[current.y-1][current.x].down = true 
		end 
		if current.y+1 < #mapCodes then -- down one
			mapCodes[current.y][current.x].down = true 
			mapCodes[current.y+1][current.x].up = true 
		end 
		if current.x-1 > 1  then -- left one
			mapCodes[current.y][current.x].left = true 
			mapCodes[current.y][current.x-1].right = true 
		end 
		if current.x+1 < #mapCodes[current.y] then -- right one
			mapCodes[current.y][current.x].right = true 
			mapCodes[current.y][current.x+1].left = true 
		end

		-- check up/down/left/right nodes
		if current.y-1 >= 1 and not mapCodes[current.y-1][current.x].searched then 
			queue:enqueue({x=current.x, y = current.y - 1})
			mapCodes[current.y-1][current.x].searched = true
		elseif current.y+1 <= #mapCodes and not mapCodes[current.y+1][current.x].searched then 
			queue:enqueue({x=current.x, y = current.y + 1})
			mapCodes[current.y+1][current.x].searched = true
		elseif current.x-1 >= 1 and not mapCodes[current.y][current.x-1].searched then 
			queue:enqueue({x=current.x - 1, y = current.y})
			mapCodes[current.y][current.x-1].searched = true
		elseif current.x+1 <= #mapCodes[current.y] and not mapCodes[current.y][current.x+1].searched then 
			queue:enqueue({x=current.x + 1, y = current.y})
			mapCodes[current.y][current.x+1].searched = true
		end
	end

	world = {}
	for y = 1, tilesDisplayHeight do 
		world[y] = {}
		for x = 1, tilesDisplayWidth do 
			world[y][x] = generateTileMap(mapCodes[y][x])
		end
	end
end


function loadMap(tSize, scaledScreenWidth, scaledScreenHeight)
	worldX = 1 
	worldY = 1
	prevWorldX = worldX
	prevWorldY = worldY
	
	tileSize = tSize 
	tilesDisplayWidth = math.floor(scaledScreenWidth/tileSize)
	tilesDisplayHeight = math.floor(scaledScreenHeight/tileSize) - 1 -- minus 1 to make room for the bottom ui bar
	
	generateWorld()
	assert(#world == tilesDisplayHeight and #world[1] == tilesDisplayWidth, "world not initialized properly")
	
	loadTilebatch()
end

function getTilesDisplayWidth()
	return tilesDisplayWidth
end

function getTilesDisplayHeight()
	return tilesDisplayHeight
end


-- fix this up a bit. moving right or down draws the player completely into the next tilemap 
-- while left and up draws the player barely. 
-- this is because it's only taking into account x,y (the top right of the box) and ignoring the width/height 
-- no technical problems with this, just an aesthetic / consistency problem to address later

function checkIfMovedToNextTileMap(box, playerMapX, playerMapY)	
	local result = Vector:new(0,0)
	
	-- first check if they moved to a different tilemap on the world map
	if playerMapX < 1 and worldX -1 > 0 then 
		result.x = tilesDisplayWidth * tileSize
		worldX = worldX - 1 
	elseif playerMapX > tilesDisplayWidth and worldX + 1 <= #world[worldY] then 
		result.x = (-tilesDisplayWidth * tileSize)
		worldX = worldX + 1
	end	
	if playerMapY < 1 and worldY -1 > 0 then 
		result.y = tilesDisplayHeight * tileSize
		worldY = worldY - 1
	elseif playerMapY > tilesDisplayHeight and worldY + 1 <= #world then 
		result.y = -tilesDisplayHeight * tileSize
		worldY = worldY + 1
	end
	
	return (result)
end

function checkTileMapCollision(box, playerMapX, playerMapY)
	local yMin, yMax, xMin, xMax
	if playerMapX <= 1 then 
		xMin = 1 
	elseif playerMapX >= tilesDisplayWidth then 
		xMin = tilesDisplayWidth - 2 
	else 
		xMin = playerMapX - 1 
	end
	
	if playerMapY <= 1 then 
		yMin = 1
	elseif playerMapY >= tilesDisplayHeight then 
		yMin = tilesDisplayHeight - 2 
	else 
		yMin = playerMapY - 1 
	end
	
		
	-- now check for collisions with the tiles on the tilemap
	-- checks a 3x3 space centred around the player
	local currentWorldTileMap = world[worldY][worldX]
	for y = yMin, yMin + 2 do 
		for x = xMin, xMin + 2 do 
			if currentWorldTileMap[y][x] == 2 then		
				if AABBvsTileMapCoords(box, (x-1)*tileSize,(y-1)*tileSize,((x-1)*tileSize)+tileSize,((y-1)*tileSize)+tileSize) then 					
					-- if we're here there's been a collision. need to figure out on which axis and resolve
					return true
				end
			end
		end	
	end	
	return false
end

function AABBvsTileMapCoords(a, x1,y1,x2,y2)
  -- Exit with no intersection if found separated along an axis
  if(a.maxVec.x < x1 or a.minVec.x > x2) then return false end
  -- tile collider y is the bottom 30% of a sprite (70% of the sprite offset from the minvec.y) 
  -- this gives the appearance of 3D viewing as it let's you overlap vertically
  if(a.maxVec.y < y1 or a:getTileColliderY() > y2) then return false end
  -- No separating axis found, therefore there is at least one overlapping axis
  return true
end

function getTileSize()
	return tileSize
end

function updateMap()

	if getKeyPress("a") then worldX = worldX - 1 end 
	if getKeyPress("d") then worldX = worldX + 1 end 
	if getKeyPress("w") then worldY = worldY - 1 end 
	if getKeyPress("s") then worldY = worldY + 1 end 

	if worldX < 1 then worldX = 1 end 
	if worldY < 1 then worldY = 1 end 
	if worldX > tilesDisplayWidth then worldX = tilesDisplayWidth end 
	if worldY > tilesDisplayHeight then worldY = tilesDisplayHeight end 

	if prevWorldX ~= worldX or prevWorldY ~= worldY then 
		print(worldX, worldY)
		prevWorldX = worldX 
		prevWorldY = worldY
		updateTileSetBatch(world[worldY][worldX])
	end
end

function loadTilebatch()
	-- tilebatch stuff starts here
	currentTilesetImage = love.graphics.newImage("assets/tilesets/testTileSet2.png")
	currentTilesetImage:setFilter("nearest", "nearest")
	
	currentTileMapQuads = {}
	currentTileMapQuads[1] = love.graphics.newQuad(0,0,tileSize, tileSize, currentTilesetImage:getWidth(), currentTilesetImage:getHeight())
	currentTileMapQuads[2] = love.graphics.newQuad(tileSize,0,tileSize, tileSize, currentTilesetImage:getWidth(), currentTilesetImage:getHeight())
	
	currentTileSetBatch = love.graphics.newSpriteBatch(currentTilesetImage, tilesDisplayWidth * tilesDisplayHeight)
	updateTileSetBatch(world[worldY][worldX])
end

function updateTileSetBatch(tileMapToDraw)
	currentTileSetBatch:clear()
	for y=1,tilesDisplayHeight do
		for x=1, tilesDisplayWidth do 
			currentTileSetBatch:add(currentTileMapQuads[tileMapToDraw[y][x]], (x-1) * tileSize, (y-1) * tileSize)
		end
	end
	currentTileSetBatch:flush()
end

function drawTileSetBatch()
	love.graphics.draw(currentTileSetBatch, 0, 0)
end
