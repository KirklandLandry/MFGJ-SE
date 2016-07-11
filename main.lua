require "input"
require "vector"
require "AABB"

screenWidth = nil
screenHeight = nil


local tilesDisplayWidth = nil
local tilesDisplayHeight = nil

local currentTileMapQuads = nil
local currentTilesetImage = nil
local currentTileSetBatch = nil

local world = nil


local worldX = nil 
local worldY = nil

local scaleValue = 2


local player = {box = AABB:new(40, 40, 12, 16), vx = 0, vy = 0, }

function loadMap()



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

	worldX = 1 
	worldY = 1
	

	
	tileSize = 16 
	tilesDisplayWidth = math.floor(screenWidth/tileSize)
	tilesDisplayHeight = math.floor(screenHeight/tileSize)
	
	currentTilesetImage = love.graphics.newImage("assets/tilesets/testTileSet.png")
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


function updatePlayer(dt)
	
	local impulse = 60

	player.vx = 0
	player.vy = 0
	
	if getKeyDown("up") then 
		player.vy = -impulse * dt
	elseif  getKeyDown("down") then 
		player.vy = impulse * dt
	end	
	if getKeyDown("left") then 
		player.vx = -impulse * dt
	elseif getKeyDown("right") then 
		player.vx = impulse * dt
	end

	player.box:scalarMove(player.vx, player.vy)
	
	
	
	local playerMapX = math.floor(player.box.minVec.x / tileSize) + 1
	local playerMapY = math.floor(player.box.minVec.y / tileSize) + 1
	
	-- first check if they moved to a different tilemap on the world map
	if playerMapX < 1 and worldX -1 > 0 then 
		player.box:scalarMove(tilesDisplayWidth * tileSize, 0)
		worldX = worldX - 1 
	elseif playerMapX > tilesDisplayWidth and worldX + 1 <= #world[worldY] then 
		player.box:scalarMove(-tilesDisplayWidth * tileSize, 0)
		worldX = worldX + 1
	end	
	if playerMapY < 1 and worldY -1 > 0 then 
		player.box:scalarMove(0, tilesDisplayHeight * tileSize)
		worldY = worldY - 1
	elseif playerMapY > tilesDisplayHeight and worldY + 1 <= #world then 
		player.box:scalarMove(0, -tilesDisplayHeight * tileSize)
		worldY = worldY + 1
	end
	
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
				if AABBvsTileMapCoords(player.box, (x-1)*tileSize,(y-1)*tileSize,((x-1)*tileSize)+tileSize,((y-1)*tileSize)+tileSize) then 					
					-- if we're here there's been a collision. need to figure out on which axis and resolve
					player.box:scalarMove(-player.vx, -player.vy)
				end
			end
		end	
	end	
	
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



function drawPlayer()
	love.graphics.rectangle("fill", player.box.minVec.x, player.box.minVec.y, player.box.width, player.box.height)
end

local min_dt = 0	
local next_time = 0

function love.load(arg)
	-- for locking the framerate
	-- min_dt will be the maximum framerate value
	min_dt = 1/60	
	next_time = love.timer.getTime()
	
	love.graphics.setDefaultFilter("nearest", "nearest")

	screenWidth = love.graphics.getWidth() / scaleValue
	screenHeight = love.graphics.getHeight() / scaleValue

	initInput()

	loadMap()
end


function love.update(dt)
	-- for locking the framerate. must be the first thing in udpate.
	next_time = next_time + min_dt
	

	updateTileSetBatch(world[worldY][worldX])
	 updatePlayer(dt)
	
	
end 


function love.draw()

	love.graphics.scale(scaleValue)
	love.graphics.draw(currentTileSetBatch, 0, 0)
	drawPlayer()
	
	love.graphics.reset()
	-- print fps
	love.graphics.print(tostring(love.timer.getFPS()), 5, 5)
	-- for locking the framerate. must be the last thing in draw.
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then -- met or passed dt
		next_time = cur_time 
		return
	end 
	love.timer.sleep(next_time - cur_time) -- sleep until the next frame
end


function getSign(x)
	if x < 0 then
 		return -1
	elseif x > 0 then
		return 1
	else
		return 0
	end
end

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end
