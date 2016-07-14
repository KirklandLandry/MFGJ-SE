
-- load pause menu ...
-- have a state for which menu to draw
-- 

-- this is what should be used, but for cheap and easy I'll just draw straight images for now 
local bottomBarTileSetImage = nil 

local bottomBarTileImage = love.graphics.newImage("assets/tilesets/uiTestTile.png")
bottomBarTileImage:setFilter("nearest", "nearest")


local tilesDisplayWidth = nil
local tilesDisplayHeight = nil

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
	
	local halfTileSize = globalTileSize/2
	
	heartContainerTilesetQuads = {}
	for i=1,5 do 
		heartContainerTilesetQuads[i] = love.graphics.newQuad((i-1)*halfTileSize,0, halfTileSize, halfTileSize, 
										heartContainerTilesetImage:getWidth(), heartContainerTilesetImage:getHeight())
	end
	
	heartContainerTilesetBatch = love.graphics.newSpriteBatch(heartContainerTilesetImage, currentHeartContainerCount)
	updateHeartContainerTilebatch()
end


function loadUi(tDisplayWidth, tDisplayHeight, playerHeartContainers, playerHealth)
	assert(tDisplayHeight ~= nil and tDisplayWidth ~= nil)
	tilesDisplayWidth = tDisplayWidth
	tilesDisplayHeight = tDisplayHeight
	
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
	for x=0,tilesDisplayWidth - 1 do 
		love.graphics.draw(bottomBarTileImage, x * globalTileSize, tilesDisplayHeight * globalTileSize)
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
		heartContainerTilesetBatch:add(heartContainerTilesetQuads[heartIndex], (globalTileSize * 6) + 8 * x  - (y*8), (tilesDisplayHeight * globalTileSize)+ y)
		if x>=7 then y = 8 end 
	end
	heartContainerTilesetBatch:flush()
end

