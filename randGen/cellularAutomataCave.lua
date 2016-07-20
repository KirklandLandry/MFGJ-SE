
local chanceToStartAlive = 0
local deathLimit = 3 
local birthLimit = 4
local numberOfSimulationSteps = 9

local empty = 1
local filled = 2
	
-- TODO:
-- be able to pass in the codes (empty, filled, treasure, etc...)
-- flood fill to remove any filled pieces <= 2
-- flood fill to remove and regions <= n (n==12 is the most common smallest region, but that's still viable (perfect spot to hide treasure). maybe remove < 6 or < 8)
-- ensure all regions are joined
-- treasure needs to go on an edge 

	
function newCave(width, height, tilesDisplayWidth, tilesDisplayHeight, _chanceToStartAlive)
	assert(width%tilesDisplayWidth==0 and height%tilesDisplayHeight==0, "need to pass in a height such that: width%tilesDisplayWidth==0 and height%tilesDisplayHeight==0")

	chanceToStartAlive = _chanceToStartAlive or 0.35
	
	local map = fillRandomly(width, height, true)
	
	for i=1,numberOfSimulationSteps do 
		map = doSimulationStep(map, tilesDisplayWidth, tilesDisplayHeight)
	end
	
	local vMap = generateVisualMap(map)
	
	printMap(visualMap, tilesDisplayWidth, tilesDisplayHeight, true)
	return {collisionMap = map, visualMap = vMap} 
end

function printMap(map, tilesDisplayWidth, tilesDisplayHeight, printAsGrid)
	for y=1,#map do 	
		local line = ""
		for x=1,#map[1] do 
			if map[y][x] == empty then 
				line = line.."*"
			elseif map[y][x] ~= filled then 
				line = line..map[y][x]
			else
				line = line.."0"
			end
			if x%tilesDisplayWidth == 0 and printAsGrid then 
				line = line.." " 
			end
		end
		print(line)
		if y%tilesDisplayHeight == 0 and printAsGrid then 
			print()
		end
	end
end

function fillRandomly(width, height, giveBorder)
	local map = {}
	for y=1,height do 
		map[y] = {}
		for x=1,width do 
			if giveBorder and x == 1 or y == 1 or x == width or y == height then 
				map[y][x] = filled
			else 
				if math.random(0,100)*0.01  < chanceToStartAlive then 
					map[y][x] = filled
				else 
					map[y][x] = empty
				end			
			end
		end
	end
	return map
end

function doSimulationStep(map, tilesDisplayWidth, tilesDisplayHeight)
	local xModCounter = 0
	local yModCounter = 0
	
	local result = copyMap(map)
	for y=1,#result do 	
		if y%tilesDisplayHeight == 0 then 
			yModCounter = yModCounter + 1
		end
		for x=1,#result[1] do 		
			local nbs = countAliveNeighbours(map, x, y, #map[1], #map)
			if map[y][x] == filled then 
				if nbs < deathLimit then 
					result[y][x] = empty
				else 
					result[y][x] = filled
				end
			else 
				if nbs > birthLimit then 
					result[y][x] = filled
				else 
					result[y][x] = empty
				end
			end
			
			
			-- this part check if the tile that would be on the next or previous screen is filled 
			-- if then fills the one that would be on the current screen 
			-- this makes it so that you should never try to scroll to the next screen and be met with a filled tile out of nowhere 
			-- makes it easier to navigate 
			
			-- need an in game map drawing function to easily see borders between areas
			
			-- should also fill in single space gaps since those are also hard to navigate 
			-- yeah, going down into a single tile space just pushes you back to the last tilemap. need to check for that
			-- there's 2 options for handling that. 
			-- 1) if a tile doesn't have n unfilled neighbours and is on an edge, fill it 
			-- 2) if a tile doesn't have n unfilled neighbours and is on an edge, check how many. 
			--    if it has less than m, fill it in. if it has > m, expand the area around it.
			
			-- still not perfect.

			if x%tilesDisplayWidth == 0 and x < #result[1] and result[y][x+1] == filled then 
				result[y][x] = filled
			end	
			if x == (xModCounter*tilesDisplayWidth)+1 and x>1 and result[y][x-1] == filled then 
				result[y][x] = filled
			end
			if x%tilesDisplayWidth == 0 then 
				xModCounter = xModCounter + 1 
			end
			
			-- had this one fail to fill in a spot, I think 
			-- works 90% of the time, something must be missing
			if y%tilesDisplayHeight == 0 and y < #result and result[y+1][x] == filled then 
				result[y][x] = filled
			end
			

			if y == (yModCounter*tilesDisplayHeight)+1 and y>1 and result[y-1][x] == filled then 
				result[y][x] = filled
			end 
			
		end
		xModCounter = 0
	end
	
	
	return result 
end

function copyMap(map)
	local newMap = {}
	for y=1,#map do 
		newMap[y] = {}
		for x=1,#map[1] do 
			newMap[y][x] = map[y][x]
		end
	end
	return newMap
end

function countAliveNeighbours(map, x, y, width, height)
	local count = 0
	for i=-1,1 do 
		for j=-1,1 do 
			local neighbourX = x + j
			local neighbourY = y + i 
			if i == 0 and j == 0 then 
				-- ignore the centre
			elseif
				neighbourX < 1 or neighbourY < 1 or neighbourX > width or neighbourY > height then -- went off the edge of the map
				count = count + 1 
			elseif map[neighbourY][neighbourX] == filled then 
				count = count + 1 
			end
		end
	end
	return count 
end


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


function generateVisualMap(map)

	local result = copyMap(map)

	local up = false 
	local down = false 
	local left = false 
	local right = false 
	
	for y=1,#map do 	
		for x=1,#map[1] do 	
			
			up = false 
			down = false 
			left = false 
			right = false 
			
			if map[y][x] == filled then 
				
				if x < #map[1] and map[y][x+1] == empty then 
					right = true 
				end	
				if x>1 and map[y][x-1] == empty then 
					left = true 
				end
				
				if y < #map and map[y+1][x] == empty then 
					down = true 
				end
				if y>1 and map[y-1][x] == empty then 
					up = true 
				end 
				
				-- 14 edge cases 
				-- stair tile 
				
				-- no edges 
				if up and down and left and right then 
					result[y][x] = allBorder
				
				-- all edges 
				elseif not up and not down and not left and not right then 
					result[y][x] = fillTile 
				
				-- 3 edges 
				elseif not up and down and left and right then 
					result[y][x] = leftDownRight
				elseif up and not down and left and right then 
					result[y][x] = leftUpRight
				elseif up and down and not left and right then 
					result[y][x] = upRightDown
				elseif up and down and left and not right then 
					result[y][x] = upLeftDown
				
				-- 2 edges 
				elseif not up and not down and left and right then 
					result[y][x] = leftRight
				elseif up and down and not left and not right then 
					result[y][x] = upDown
				elseif up and not down and left and not right then 
					result[y][x] = topLeftTile
				elseif up and not down and not left and right then 
					result[y][x] = topRightTile
				elseif not up and down and left and not right then 
					result[y][x] = bottomLeftTile
				elseif not up and down and not left and right then 
					result[y][x] = bottomRightTile
					
				-- 1 edge 
				elseif up and not down and not left and not right then 
					result[y][x] = topTile
				elseif not up and down and not left and not right then 
					result[y][x] = bottomTile
				elseif not up and not down and left and not right then 
					result[y][x] = leftTile
				elseif not up and not down and not left and right then 
					result[y][x] = rightTile
				end
			end 
		end 
	end
	return result
end





