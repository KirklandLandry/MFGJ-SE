
-- load pause menu ...
-- have a state for which menu to draw
-- 

-- this is what should be used, but for cheap and easy I'll just draw straight images for now 
local bottomBarTileSetImage = nil 

local bottomBarTileImage = love.graphics.newImage("assets/tilesets/uiTestTile.png")
bottomBarTileImage:setFilter("nearest", "nearest")


local tilesDisplayWidth = nil
local tilesDisplayHeight = nil
local tileSize = nil

local heartContainerTilesetImage = nil 
local heartContainerTilesetBatch = nil

-- the total heart container count 
local currentHeartContainerCount = nil 
local currentHealthCount = nil 

function loadHeartContainerTilebatch(playerHeartContainers, playerHealth)

	currentHeartContainerCount = playerHeartContainers
	currentHealthCount = playerHealth
	
	heartContainerTilesetImage = love.graphics.newImage("assets/tilesets/heartTileset.png")
	heartContainerTilesetImage:setFilter("nearest", "nearest")
	
	heartContainerTilesetQuads = {}
	heartContainerTilesetQuads[1] = love.graphics.newQuad(0,0,8, 8, heartContainerTilesetImage:getWidth(), heartContainerTilesetImage:getHeight())
	heartContainerTilesetQuads[2] = love.graphics.newQuad(8*1,0,8, 8, heartContainerTilesetImage:getWidth(), heartContainerTilesetImage:getHeight())
	heartContainerTilesetQuads[3] = love.graphics.newQuad(8*2,0,8, 8, heartContainerTilesetImage:getWidth(), heartContainerTilesetImage:getHeight())
	heartContainerTilesetQuads[4] = love.graphics.newQuad(8*3,0,8, 8, heartContainerTilesetImage:getWidth(), heartContainerTilesetImage:getHeight())
	heartContainerTilesetQuads[5] = love.graphics.newQuad(8*4,0,8, 8, heartContainerTilesetImage:getWidth(), heartContainerTilesetImage:getHeight())
	
	heartContainerTilesetBatch = love.graphics.newSpriteBatch(heartContainerTilesetImage, currentHeartContainerCount)
	updateHeartContainerTilebatch()
end


function loadUi(tDisplayWidth, tDisplayHeight, tSize, playerHeartContainers, playerHealth)
	assert(tDisplayHeight ~= nil and tDisplayWidth ~= nil and tSize ~= nil)
	tilesDisplayWidth = tDisplayWidth
	tilesDisplayHeight = tDisplayHeight
	tileSize = tSize
	
	loadHeartContainerTilebatch(playerHeartContainers, playerHealth)
end

function updateUi(dt , playerHeartContainers, playerHealth)
	if currentHeartContainerCount ~= playerHeartContainers or currentHealthCount ~= playerHealth then 
		currentHeartContainerCount = playerHeartContainers
		currentHealthCount = playerHealth
		updateHeartContainerTilebatch()
	end 
end

function drawUi()
	drawBottomBarMenu()
end


function drawBottomBarMenu()
	for x=0,tilesDisplayWidth do 
		love.graphics.draw(bottomBarTileImage, x * tileSize, tilesDisplayHeight * tileSize)
	end 		
	love.graphics.draw(heartContainerTilesetBatch, 0, 0)
end 


function updateHeartContainerTilebatch()
	heartContainerTilesetBatch:clear()
	local y = 0 
	local heartIndex = 1
	for x=0,currentHeartContainerCount do
		if math.floor(currentHealthCount) == x then 
			local decimal
			if math.floor(currentHealthCount) == 0 then decimal = currentHealthCount else 
				decimal = currentHealthCount%x
			end 
			if decimal == 0 then 
				heartIndex = 5
			elseif decimal == 0.25 then 
				heartIndex = 4
			elseif decimal == 0.50 then 
				heartIndex = 3			
			elseif decimal == 0.75 then 
				heartIndex = 2
			end 		
		elseif x > currentHealthCount then  
			heartIndex = 5
		else 
			heartIndex = 1 
		end
		heartContainerTilesetBatch:add(heartContainerTilesetQuads[heartIndex], (tileSize * 6) + 8 * x  - (y*8), (tilesDisplayHeight * tileSize)+ y)
		if x>=7 then y = 8 end 
	end
	heartContainerTilesetBatch:flush()
end

