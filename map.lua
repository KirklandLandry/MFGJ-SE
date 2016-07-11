local tilesDisplayWidth = nil
local tilesDisplayHeight = nil

local currentTileMapQuads = nil
local currentTilesetImage = nil
local currentTileSetBatch = nil

local world = nil


local worldX = nil 
local worldY = nil

local prevWorldX = nil 
local prevWorldY = nil

local tileSize = nil


function generateTileMap()

end 

function generateWorld()
	local map11 = {
	{2,2, 2,2, 2,2, 2,2, 2,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,1},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,2, 2,2, 2,1, 2,2, 2,2},
	}
	
	local map21 = {
	{2,2, 2,2, 2,1, 2,2, 2,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,1},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,2, 2,2, 2,2, 2,2, 2,2},
	}

	local map12 = {
	{2,2, 2,2, 2,2, 2,2, 2,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{1,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,2, 2,2, 2,1, 2,2, 2,2},
	}

	local map22 = {
	{2,2, 2,2, 2,1, 2,2, 2,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{1,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,1, 1,1, 1,1, 1,1, 1,2},
	{2,2, 2,2, 2,2, 2,2, 2,2},
	}
	
	-- indexed as [y][x]
	world = {}
	world[1] = {} 
	world[2] = {}
	world[1][1] = map11
	world[2][1] = map21
	world[1][2] = map12
	world[2][2] = map22
end


function loadMap(scaledScreenWidth, scaledScreenHeight)

	generateWorld()

	worldX = 1 
	worldY = 1
	prevWorldX = worldX
	prevWorldY = worldY
	
	tileSize = 16 
	tilesDisplayWidth = math.floor(scaledScreenWidth/tileSize)
	tilesDisplayHeight = math.floor(scaledScreenHeight/tileSize)
	
	currentTilesetImage = love.graphics.newImage("assets/tilesets/testTileSet.png")
	currentTilesetImage:setFilter("nearest", "nearest")
	
	currentTileMapQuads = {}
	currentTileMapQuads[1] = love.graphics.newQuad(0,0,tileSize, tileSize, currentTilesetImage:getWidth(), currentTilesetImage:getHeight())
	currentTileMapQuads[2] = love.graphics.newQuad(tileSize,0,tileSize, tileSize, currentTilesetImage:getWidth(), currentTilesetImage:getHeight())
	
	currentTileSetBatch = love.graphics.newSpriteBatch(currentTilesetImage, tilesDisplayWidth * tilesDisplayHeight)
	updateTileSetBatch(world[worldY][worldX])
end

function checkIfMovedToNextTileMap(playerMapX, playerMapY)	
	local result = Vector:new(0,0)
	
	-- first check if they moved to a different tilemap on the world map
	if playerMapX < 1 and worldX -1 > 0 then 
		result.x = tilesDisplayWidth * tileSize
		worldX = worldX - 1 
	elseif playerMapX > tilesDisplayWidth and worldX + 1 <= #world[worldY] then 
		result.x = -tilesDisplayWidth * tileSize
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
	if prevWorldX ~= worldX or prevWorldY ~= worldY then 
		prevWorldX = worldX 
		prevWorldY = worldY
		updateTileSetBatch(world[worldY][worldX])
	end
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
