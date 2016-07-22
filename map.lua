
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

-- codes for collision map 
local openTile = 1 
local filledTile = 2

-- codes for visual map / tilemap 
local topTile = 1
local bottomTile = 2
local rightTile = 3
local leftTile = 4
local topLeftTile = 5
local topRightTile = 6
local bottomLeftTile = 7
local bottomRightTile = 8
local floorTile = 9
local stairTile = 0
local fillTile = "a"
local allBorder = "b"
local upLeftDown = "c"
local upRightDown = "d"
local leftDownRight = "e"
local leftUpRight = "f"
local upDown = "g"
local leftRight = "h"

--[[function generateTileMap(mapObject)
	local result = {base = {}, enemies = {}}
	
	for i=1,4 do 
		result.enemies[i] = SimpleEnemy:new(math.random(32,90),math.random(32,90),globalTileSize,globalTileSize)
	end
	
	for y = 1, tilesDisplayHeight do 
		result.collisionMap[y] = {}
		for x = 1, tilesDisplayWidth do 
			if y == 1 or y == tilesDisplayHeight or x == 1 or x == tilesDisplayWidth then 
				result.collisionMap[y][x] = filledTile
			else 
				result.collisionMap[y][x] = openTile
			end
		end
	end
	
	if mapObject.up then 
		result.collisionMap[1][5] = openTile 
		result.collisionMap[1][6] = openTile
	end 
	if mapObject.down then 
		result.collisionMap[tilesDisplayHeight][5] = openTile 
		result.collisionMap[tilesDisplayHeight][6] = openTile
	end 
	if mapObject.left then 
		result.collisionMap[5][1] = openTile 
	end 
	if mapObject.right then 
		result.collisionMap[5][tilesDisplayWidth] = openTile
	end
	
	return result
end ]]



function convertGridToTilemapWorld(maps)
	cMap = maps.collisionMap
	vMap = maps.visualMap	
	
	assert(#cMap == #vMap  and #cMap[1] == #vMap[1], "cMap and vMap not equal")
	assert(#vMap%tilesDisplayHeight == 0 and #vMap[1]%tilesDisplayWidth == 0, "map size not of the proper multiple")
	
	local mapList = {}
	
	--print("split map height: "..#map/tilesDisplayHeight.."split map width: "..#map[1]/tilesDisplayWidth)
	
	for i=1,#cMap/tilesDisplayHeight do 	
		mapList[i] = {}
		for j=1,#cMap[1]/tilesDisplayWidth do 	
			
			local currentScreen = {collisionMap = {}, visualMap = {}, enemies = {}}--, stairTile = nil} 
			
			
			for y=1,tilesDisplayHeight do
				currentScreen.collisionMap[y] = {}
				currentScreen.visualMap[y] = {}
				for x=1,tilesDisplayWidth do 
					currentScreen.collisionMap[y][x] = cMap[y + ((i-1)*tilesDisplayHeight)][x + ((j-1)*tilesDisplayWidth)]
					currentScreen.visualMap[y][x] = vMap[y + ((i-1)*tilesDisplayHeight)][x + ((j-1)*tilesDisplayWidth)]
				end
			end
			
			-- quick and dirty way to add enemies to a map. 
			-- obviously make this better later
			for i=1,4 do 
				local findingStartPosition = true 
				local safeGuard = 0 
				enemyPosition = Vector:new(0,0)
				while findingStartPosition do 
					enemyPosition = Vector:new(math.random(2,tilesDisplayWidth-1), math.random(2, tilesDisplayHeight-1))
					if currentScreen.collisionMap[enemyPosition.y][enemyPosition.x] == openTile then 
						findingStartPosition = false 
					end	
					safeGuard = safeGuard + 1 
					-- could be trying to spawn an enemy in a room of purely filled tiles, so don't loop forever on that. 
					-- No point in spawning in an unreachable area
					-- later, enemy population should be determined by room size and layout 
					if safeGuard > 20 then 
						findingStartPosition = false
					end
				end			
				currentScreen.enemies[i] = SimpleEnemy:new((enemyPosition.x-1) * globalTileSize, (enemyPosition.y-1) * globalTileSize,globalTileSize,globalTileSize)
			end
			
			
			mapList[i][j] = currentScreen
		end
	end
	return mapList
end



--[[function generateWorld()
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
end]]

local startingPosition = {worldPos = nil, tilePos = nil}
function getPlayerStartingPosition()
	return startingPosition.tilePos
end 

function generateCaveWorld()

	-- NOTE: 
	-- structurally, I think the only job of cellularAutomataCave.lua should be to generate the caves. 
	-- once that's done, this part can populate them with enemies, player start, treasure, traps(fall to prev floor,spike traps, bombs), mob rooms, etc...
	-- it should tell you the biggest rooms / the diff regions so you can choose positions from those areas 
	-- maybe also return a list of open tiles that you can random from 
	-- player spawn rule should be that it needs a square around it of empty space
	-- * * *
	-- * p *
	-- * * *

	-- TODO: 
	-- place a number of enemies relative to a rooms size
	-- if it's a really big empty space, occasionally make it a trap room you can't leave 
	-- where a treasure spawns at the end 

	local list = convertGridToTilemapWorld(newCave(10*tilesDisplayWidth, 10*tilesDisplayHeight, tilesDisplayWidth, tilesDisplayHeight))
	
	
	if world ~= nil then 
		for y = #world,1,-1  do 
			for x = #world[1],1,-1  do 
				for i=#world[y][x].enemies,1,-1  do 	
					world[y][x].enemies[i] = nil 
				end	
				world[y][x].collisionMap = nil 
				world[y][x].visualMap = nil 
				world[y][x] = nil
			end
			world[y] = nil 
		end
	end

	
	world = {}
	for y = 1, #list do 
		world[y] = {}
		for x = 1, #list[1] do 
			world[y][x] = list[y][x]
		end
	end
	
	-- just for now. this is bad.
	local findingStartPosition = true 
	local safeGuard = 0 
	while findingStartPosition do 
		startingPosition.worldPos = Vector:new(math.random(1,#world[1]),math.random(1,#world))
		startingPosition.tilePos = Vector:new(math.random(2,tilesDisplayWidth-1), math.random(2, tilesDisplayHeight-1))
		if world[startingPosition.worldPos.y][startingPosition.worldPos.x].collisionMap[startingPosition.tilePos.y][startingPosition.tilePos.x] == openTile then 
			findingStartPosition = false 
			print(startingPosition.tilePos.x, startingPosition.tilePos.y)
		end	
		safeGuard = safeGuard + 1 
		assert(safeGuard < 20, "finding a player starting position isn't working")
	end

	print("tilesDisplayWidth = "..tilesDisplayWidth, "tilesDisplayHeight = "..tilesDisplayHeight)
	print("world generated with size ("..#world[1]..", "..#world..")")
end

function loadMap(scaledScreenWidth, scaledScreenHeight)

	tilesDisplayWidth = math.floor(scaledScreenWidth/globalTileSize)
	tilesDisplayHeight = math.floor(scaledScreenHeight/globalTileSize) - 1 -- minus 1 to make room for the bottom ui bar

	--generateWorld()
	generateCaveWorld()
	--assert(#world == tilesDisplayHeight and #world[1] == tilesDisplayWidth, "world not initialized properly")

	worldX = startingPosition.worldPos.x 
	worldY = startingPosition.worldPos.y
	prevWorldX = worldX
	prevWorldY = worldY
	
	loadTilebatch()
end

function getTilesDisplayWidth()
	return tilesDisplayWidth
end

function getTilesDisplayHeight()
	return tilesDisplayHeight
end


-- 
function checkIfMovedToNextTileMap(box, playerTileXmin, playerTileYmin, playerTileXmax, playerTileYmax)	
	local result = Vector:new(0,0)
	-- first check if they moved to a different tilemap on the world map
	if playerTileXmin < 1 and worldX -1 > 0 then
		result.x = (tilesDisplayWidth * globalTileSize) - box.width
		worldX = worldX - 1 
	elseif playerTileXmax > tilesDisplayWidth and worldX + 1 <= #world[worldY] then
		result.x = (-tilesDisplayWidth * globalTileSize) + box.width
		worldX = worldX + 1
	end	
	if playerTileYmin < 1 and worldY -1 > 0 then
		result.y = (tilesDisplayHeight * globalTileSize) - box.height
		worldY = worldY - 1
	elseif playerTileYmax > tilesDisplayHeight and worldY + 1 <= #world then
		result.y = (-tilesDisplayHeight * globalTileSize) + box.height
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
	local currentWorldTileMap = world[worldY][worldX].collisionMap
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

-- change to a generic "all entities collisions check" or something
-- make it check against every other AABB except itself
function AABBvsEnemiesCollisions(playerAABB)
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
	return Vector:new(math.floor(x / globalTileSize) + 1, math.floor(y / globalTileSize) + 1)
end

function updateMap(dt, playerAttack)
	-- debug. remove later
	if getKeyPress("a") then worldX = worldX - 1 end 
	if getKeyPress("d") then worldX = worldX + 1 end 
	if getKeyPress("w") then worldY = worldY - 1 end 
	if getKeyPress("s") then worldY = worldY + 1 end 
	-- these these are here to cover for the debug step above
	if worldX < 1 then worldX = 1 end 
	if worldY < 1 then worldY = 1 end 
	if worldX > #world[1] then worldX = #world[1] end 
	if worldY > #world then worldY = #world end 
	
	-- if these fire, something's wrong. trying to go out of bounds
	assert(worldY >= 1)
	assert(worldX >= 1)
	assert(worldY <= #world)
	assert(worldX <= #world[1])
	
	
	if gameState == GameStates.scrollComplete then 
		print("map scroll complete")
		updateTileSetBatch(world[worldY][worldX].visualMap)	
	end
	
	local length = #world[prevWorldY][prevWorldX].enemies
	for i=length,1,-1  do 
		world[prevWorldY][prevWorldX].enemies[i]:update(dt)	
		if not world[prevWorldY][prevWorldX].enemies[i]:isInvincible() then 
			-- should be getting a list once the playerattack is changed to a list 
			-- of currently active player attacks
			--local playerAttack = getPlayerAttack()
			if playerAttack ~= nil then 			
				local enemyAABB = world[worldY][worldX].enemies[i]:getAABB()
				local collisionResult = AABBvsAABBDetectionAndResolution(enemyAABB, playerAttack.box)			
				if collisionResult ~= nil then 
					-- make a variant object called attack or something that's and AABB and 
					-- also contains damage and element info and stuff like that.
					world[worldY][worldX].enemies[i]:changeHealth(-playerAttack.damage, collisionResult.normal)
					world[worldY][worldX].enemies[i].invincibilityFrames = playerAttack:remainingFrames()
					
					if world[worldY][worldX].enemies[i]:getHealth() <= 0 then 
						table.remove(world[prevWorldY][prevWorldX].enemies, i)
					end
				end
			end
		end
	end
	

	if prevWorldX ~= worldX or prevWorldY ~= worldY then 
		print("\ncurrent: "..worldX..", "..worldY, "previous: "..prevWorldX..", "..prevWorldY)
		print("current room contains...\n"..#world[worldY][worldX].enemies.." enemies")
		print("map scroll started")
		
		if worldX > prevWorldX then 
			gameState = GameStates.scrollingRight
			updateTileSetBatch(world[prevWorldY][prevWorldX].visualMap, world[worldY][worldX].visualMap, Directions.right)
		elseif worldX < prevWorldX then 
			gameState = GameStates.scrollingLeft
			updateTileSetBatch(world[prevWorldY][prevWorldX].visualMap, world[worldY][worldX].visualMap, Directions.left)
		elseif worldY > prevWorldY then 
			gameState = GameStates.scrollingDown
			updateTileSetBatch(world[prevWorldY][prevWorldX].visualMap, world[worldY][worldX].visualMap, Directions.down)
		elseif worldY < prevWorldY then 
			gameState = GameStates.scrollingUp
			updateTileSetBatch(world[prevWorldY][prevWorldX].visualMap, world[worldY][worldX].visualMap, Directions.up)
		else 
			-- this should never happen
			updateTileSetBatch(world[worldY][worldX].visualMap)
		end
		
		
		prevWorldX = worldX 
		prevWorldY = worldY
	end
end



function loadTilebatch()
	if currentTilesetImage == nil then 
		-- tilebatch stuff starts here
		currentTilesetImage = love.graphics.newImage("assets/tilesets/background.png")--"assets/tilesets/testTileSet2.png")
		currentTilesetImage:setFilter("nearest", "nearest")
	end 
	
	if currentTileMapQuads == nil then 
		local tileSize = globalTileSize
		local tilesetWidth = currentTilesetImage:getWidth()
		local tilesetHeight = currentTilesetImage:getHeight()
		
		currentTileMapQuads = {}
		-- first row: up, down,left, right 
		currentTileMapQuads[topTile] 	= love.graphics.newQuad(tileSize * 0, 0, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[bottomTile] = love.graphics.newQuad(tileSize * 1, 0, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[leftTile] 	= love.graphics.newQuad(tileSize * 2, 0, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[rightTile] 	= love.graphics.newQuad(tileSize * 3, 0, tileSize, tileSize, tilesetWidth, tilesetHeight)
		-- second row: upleft, downright, upright, downleft 
		currentTileMapQuads[topLeftTile] 		= love.graphics.newQuad(tileSize * 0, tileSize * 1, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[bottomRightTile] 	= love.graphics.newQuad(tileSize * 1, tileSize * 1, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[topRightTile] 		= love.graphics.newQuad(tileSize * 2, tileSize * 1, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[bottomLeftTile] 	= love.graphics.newQuad(tileSize * 3, tileSize * 1, tileSize, tileSize, tilesetWidth, tilesetHeight)
		-- third row: upleftdown, uprightdown, leftdownright, leftupright 
		currentTileMapQuads[upLeftDown] 	= love.graphics.newQuad(tileSize * 0, tileSize * 2, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[upRightDown] 	= love.graphics.newQuad(tileSize * 1, tileSize * 2, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[leftDownRight] 	= love.graphics.newQuad(tileSize * 2, tileSize * 2, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[leftUpRight] 	= love.graphics.newQuad(tileSize * 3, tileSize * 2, tileSize, tileSize, tilesetWidth, tilesetHeight)
		-- fourth row: floor, stair, none, all 
		currentTileMapQuads[floorTile] 	= love.graphics.newQuad(tileSize * 0, tileSize * 3, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[stairTile] 	= love.graphics.newQuad(tileSize * 1, tileSize * 3, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[fillTile] 	= love.graphics.newQuad(tileSize * 2, tileSize * 3, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[allBorder] 	= love.graphics.newQuad(tileSize * 3, tileSize * 3, tileSize, tileSize, tilesetWidth, tilesetHeight)
		-- fifth row: leftRight, updown 
		currentTileMapQuads[leftRight] 	= love.graphics.newQuad(tileSize * 0, tileSize * 4, tileSize, tileSize, tilesetWidth, tilesetHeight)
		currentTileMapQuads[upDown] 	= love.graphics.newQuad(tileSize * 1, tileSize * 4, tileSize, tileSize, tilesetWidth, tilesetHeight)	
	end
	
	currentTileSetBatch = love.graphics.newSpriteBatch(currentTilesetImage, tilesDisplayWidth * tilesDisplayHeight)
	updateTileSetBatch(world[worldY][worldX].visualMap)
end

function updateTileSetBatch(tileMapToDraw, secondTileMapToDraw, secondTileMapPlacement)	
	local xOffset = 0 
	local yOffset = 0
	if secondTileMapToDraw ~= nil then 
		assert(secondTileMapPlacement ~= nil and (secondTileMapPlacement == Directions.up or secondTileMapPlacement == Directions.down or secondTileMapPlacement == Directions.left or secondTileMapPlacement == Directions.right))
		if secondTileMapPlacement == Directions.up then 
			yOffset = -baseScreenHeight + globalTileSize
		elseif secondTileMapPlacement == Directions.down then
			yOffset = baseScreenHeight - globalTileSize
		elseif secondTileMapPlacement == Directions.left then
			xOffset = -baseScreenWidth
		elseif secondTileMapPlacement == Directions.right then
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
	-- flooring eliminates screen tearing, make transition slightly jerkier. looks fine enough,
	-- actually somewhat matches the aesthetic when it's not super smooth
	love.graphics.draw(currentTileSetBatch, math.floor(screenShiftX), math.floor(screenShiftY))
end

function drawEnemies()	
	if gameState == GameStates.neutral then 
		for i=1, #world[prevWorldY][prevWorldX].enemies do 
			world[prevWorldY][prevWorldX].enemies[i]:draw()
			if DRAW_DEBUG then 
				world[prevWorldY][prevWorldX].enemies[i]:drawDebug(i)
			end
		end
	end
end

function debugDrawCollisionMap()
	for y=1,tilesDisplayHeight do
		for x=1, tilesDisplayWidth do 
			if world[worldY][worldX].collisionMap[y][x] == 2 then		
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
function debugDrawPlayerCollisionBounds(playerCoord)
	--local playerCoord = getPlayerCoord()
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
	
	local currentWorldTileMap = world[worldY][worldX].collisionMap
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
