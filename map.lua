-- should these 3 go in the game file?
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

local openTile = 1 
local filledTile = 2


function generateTileMap(mapObject)
	local result = {base = {}, enemies = {}}
	
	for i=1,4 do 
		result.enemies[i] = SimpleEnemy:new(math.random(32,90),math.random(32,90),globalTileSize,globalTileSize)
	end
	
	for y = 1, tilesDisplayHeight do 
		result.base[y] = {}
		for x = 1, tilesDisplayWidth do 
			if y == 1 or y == tilesDisplayHeight or x == 1 or x == tilesDisplayWidth then 
				result.base[y][x] = filledTile
			else 
				result.base[y][x] = openTile
			end
		end
	end
	
	if mapObject.up then 
		result.base[1][5] = openTile 
		result.base[1][6] = openTile
	end 
	if mapObject.down then 
		result.base[tilesDisplayHeight][5] = openTile 
		result.base[tilesDisplayHeight][6] = openTile
	end 
	if mapObject.left then 
		result.base[5][1] = openTile 
	end 
	if mapObject.right then 
		result.base[5][tilesDisplayWidth] = openTile
	end 

	return result
end 


function convertGridToTilemapWorld()
	
end



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
	print("tilesDisplayWidth = "..tilesDisplayWidth, "tilesDisplayHeight = "..tilesDisplayHeight)
	print("world generated with size ("..#world[1]..", "..#world..")")
end


function loadMap(scaledScreenWidth, scaledScreenHeight)
	worldX = 1 
	worldY = 1
	prevWorldX = worldX
	prevWorldY = worldY
	
	tilesDisplayWidth = math.floor(scaledScreenWidth/globalTileSize)
	tilesDisplayHeight = math.floor(scaledScreenHeight/globalTileSize) - 1 -- minus 1 to make room for the bottom ui bar
	
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
		result.x = tilesDisplayWidth * globalTileSize
		worldX = worldX - 1 
	elseif playerMapX > tilesDisplayWidth and worldX + 1 <= #world[worldY] then 
		result.x = (-tilesDisplayWidth * globalTileSize)
		worldX = worldX + 1
	end	
	if playerMapY < 1 and worldY -1 > 0 then 
		result.y = tilesDisplayHeight * globalTileSize
		worldY = worldY - 1
	elseif playerMapY > tilesDisplayHeight and worldY + 1 <= #world then 
		result.y = -tilesDisplayHeight * globalTileSize
		worldY = worldY + 1
	end
	return (result)
end

function checkTileMapCollision(box, tileX, tileY)
	local yMin, yMax, xMin, xMax
	if tileX <= 1 then 
		xMin = 1 
	elseif tileX >= tilesDisplayWidth then 
		xMin = tilesDisplayWidth - 2 
	else 
		xMin = tileX - 1 
	end
	
	if tileY <= 1 then 
		yMin = 1
	elseif tileY >= tilesDisplayHeight then 
		yMin = tilesDisplayHeight - 2 
	else 
		yMin = tileY - 1 
	end
	
	local result = nil 
	-- now check for collisions with the tiles on the tilemap
	-- checks a 3x3 space centred around the player
	local currentWorldTileMap = world[worldY][worldX].base
	for y = yMin, yMin + 2 do 
		for x = xMin, xMin + 2 do 
			if currentWorldTileMap[y][x] == 2 then		
				result = AABBvsTileDetectionAndResolution(box, (x-1)*globalTileSize,(y-1)*globalTileSize, globalTileSize, globalTileSize)
				if result ~= nil then 
					return result 
				end			
			end
		end	
	end	
	return result 
end



function playerVsEnemiesCollisions(playerAABB)
	assert(playerAABB ~= nil, "don't pass an empty arg")
	
	local result = nil 
	for i=1, #world[worldY][worldX].enemies do 	
		local enemyAABB = world[worldY][worldX].enemies[i]:getAABB()
		result = AABBvsAABBDetectionAndResolution(playerAABB, enemyAABB)	
		if result ~= nil then 
			return result 
		end 
	end
	return result
end

function getTileCoordinate(x, y)
	-- + 1 because it'll floor to 0 and tilemaps (tables in general) all start at <1,1> 
	local result = Vector:new(math.floor(x / globalTileSize) + 1, math.floor(y / globalTileSize) + 1)
	return result 
end

function updateMap(dt)
	-- debug. remove later
	if getKeyPress("a") then worldX = worldX - 1 end 
	if getKeyPress("d") then worldX = worldX + 1 end 
	if getKeyPress("w") then worldY = worldY - 1 end 
	if getKeyPress("s") then worldY = worldY + 1 end 

	if worldX < 1 then worldX = 1 end 
	if worldY < 1 then worldY = 1 end 
	if worldX > tilesDisplayWidth then worldX = tilesDisplayWidth end 
	if worldY > tilesDisplayHeight then worldY = tilesDisplayHeight end 

	if gameState == GameStates.scrollComplete then 
		print("map scroll complete")
		updateTileSetBatch(world[worldY][worldX].base)	
	end
	
	local length = #world[prevWorldY][prevWorldX].enemies
	for i=length,1,-1  do 
		world[prevWorldY][prevWorldX].enemies[i]:update(dt)
		
		local playerAttack = getPlayerAttackAABB()
		if playerAttack ~= nil then 
			
			local enemyAABB = world[worldY][worldX].enemies[i]:getAABB()
			local collisionResult = AABBvsAABBDetectionAndResolution(enemyAABB, playerAttack)	
			
			if collisionResult ~= nil then 
				table.remove(world[prevWorldY][prevWorldX].enemies, i)
			end
		end
	end
	
	
	
	
	if prevWorldX ~= worldX or prevWorldY ~= worldY then 
		print("\ncurrent: "..worldX..", "..worldY, "previous: "..prevWorldX..", "..prevWorldY)
		print("current room contains...\n"..#world[worldY][worldX].enemies.." enemies")
		print("map scroll started")
		
		if worldX > prevWorldX then 
			gameState = GameStates.scrollingRight
			updateTileSetBatch(world[prevWorldY][prevWorldX].base, world[worldY][worldX].base, directions.right)
		elseif worldX < prevWorldX then 
			gameState = GameStates.scrollingLeft
			updateTileSetBatch(world[prevWorldY][prevWorldX].base, world[worldY][worldX].base, directions.left)
		elseif worldY > prevWorldY then 
			gameState = GameStates.scrollingDown
			updateTileSetBatch(world[prevWorldY][prevWorldX].base, world[worldY][worldX].base, directions.down)
		elseif worldY < prevWorldY then 
			gameState = GameStates.scrollingUp
			updateTileSetBatch(world[prevWorldY][prevWorldX].base, world[worldY][worldX].base, directions.up)
		else 
			-- this should never happen
			updateTileSetBatch(world[worldY][worldX].base)
		end
		prevWorldX = worldX 
		prevWorldY = worldY
	end
end

function loadTilebatch()
	-- tilebatch stuff starts here
	currentTilesetImage = love.graphics.newImage("assets/tilesets/testTileSet2.png")
	currentTilesetImage:setFilter("nearest", "nearest")
	
	currentTileMapQuads = {}
	currentTileMapQuads[openTile] = love.graphics.newQuad(0,0,globalTileSize, globalTileSize, currentTilesetImage:getWidth(), currentTilesetImage:getHeight())
	currentTileMapQuads[filledTile] = love.graphics.newQuad(globalTileSize,0,globalTileSize, globalTileSize, currentTilesetImage:getWidth(), currentTilesetImage:getHeight())
	
	currentTileSetBatch = love.graphics.newSpriteBatch(currentTilesetImage, tilesDisplayWidth * tilesDisplayHeight)
	updateTileSetBatch(world[worldY][worldX].base)
end

function updateTileSetBatch(tileMapToDraw, secondTileMapToDraw, secondTileMapPlacement)	
	local xOffset = 0 
	local yOffset = 0
	if secondTileMapToDraw ~= nil then 
		assert(secondTileMapPlacement ~= nil and (secondTileMapPlacement == directions.up or secondTileMapPlacement == directions.down or secondTileMapPlacement == directions.left or secondTileMapPlacement == directions.right))
		if secondTileMapPlacement == directions.up then 
			yOffset = -baseScreenHeight + globalTileSize
		elseif secondTileMapPlacement == directions.down then
			yOffset = baseScreenHeight - globalTileSize
		elseif secondTileMapPlacement == directions.left then
			xOffset = -baseScreenWidth
		elseif secondTileMapPlacement == directions.right then
			xOffset = baseScreenWidth
		end
		-- the spritebatch will be twice as big (drawing two screens), so you need to tell it that (so *2 the size)
		currentTileSetBatch = love.graphics.newSpriteBatch(currentTilesetImage, tilesDisplayWidth * tilesDisplayHeight * 2)
	else 
		currentTileSetBatch = love.graphics.newSpriteBatch(currentTilesetImage, tilesDisplayWidth * tilesDisplayHeight)
	end	
	
	currentTileSetBatch:clear()
	for y=1,tilesDisplayHeight do
		for x=1, tilesDisplayWidth do 
			currentTileSetBatch:add(currentTileMapQuads[tileMapToDraw[y][x]], (x-1) * globalTileSize, (y-1) * globalTileSize)
			if secondTileMapToDraw ~= nil then 
				assert(secondTileMapPlacement ~= nil)	
				currentTileSetBatch:add(currentTileMapQuads[secondTileMapToDraw[y][x] ], ((x-1) * globalTileSize) + xOffset, ((y-1) * globalTileSize) + yOffset)
			end
		end
	end
end

function drawTileSetBatch(screenShiftX, screenShiftY)
	love.graphics.draw(currentTileSetBatch, screenShiftX, screenShiftY)
	
	if gameState == GameStates.neutral then 
		for i=1, #world[prevWorldY][prevWorldX].enemies do 
			world[prevWorldY][prevWorldX].enemies[i]:draw(i)
		end
	end
	
	debugDrawCollisionMap()
	debugDrawPlayerCollisionBounds()
	
end


function debugDrawCollisionMap()
	for y=1,tilesDisplayHeight do
		for x=1, tilesDisplayWidth do 
			if world[worldY][worldX].base[y][x] == 2 then		
				love.graphics.setColor(255,0,0)
			else 
				love.graphics.setColor(0,200,22)
			end
			love.graphics.rectangle("line", (x-1)*globalTileSize, (y-1)*globalTileSize, globalTileSize, globalTileSize)
			love.graphics.setColor(255,255,255)
		end
	end 
end


-- just debug to show which tiles are being checked for player collisions 
function debugDrawPlayerCollisionBounds()
	local playerCoord = getPlayerCoord()
	local tv = getTileCoordinate(playerCoord.x, playerCoord.y)
	local tileX = tv.x 
	local tileY = tv.y 
	local yMin, yMax, xMin, xMax
	if tileX <= 1 then 
		xMin = 1 
	elseif tileX >= tilesDisplayWidth then 
		xMin = tilesDisplayWidth - 2 
	else 
		xMin = tileX - 1 
	end
	
	if tileY <= 1 then 
		yMin = 1
	elseif tileY >= tilesDisplayHeight then 
		yMin = tilesDisplayHeight - 2 
	else 
		yMin = tileY - 1 
	end
	
	local currentWorldTileMap = world[worldY][worldX].base
	for y = yMin, yMin + 2 do 
		for x = xMin, xMin + 2 do 
			if currentWorldTileMap[y][x] == 2 then		
				love.graphics.setColor(120,0,255)
			else 
				love.graphics.setColor(0,0,255)
			end
			love.graphics.rectangle("line", (x-1)*globalTileSize, (y-1)*globalTileSize, globalTileSize, globalTileSize)
			love.graphics.setColor(255,255,255)
		end	
	end	
end
