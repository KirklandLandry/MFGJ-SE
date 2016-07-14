function AABBvsTileMapCoords(a, x1,y1,x2,y2)
	-- Exit with no intersection if found separated along an axis
	if(a.maxVec.x < x1 or a.minVec.x > x2) then return false end
	-- tile collider y is the bottom 30% of a sprite (70% of the sprite offset from the minvec.y) 
	-- this gives the appearance of 3D viewing as it let's you overlap vertically
	if(a.maxVec.y < y1 or a:getTileColliderY() > y2) then return false end
	-- No separating axis found, therefore there is at least one overlapping axis
	return true
end

function AABBvsAABB(a, b)
	-- Exit with no intersection if found separated along an axis
	if(a.maxVec.x < b.minVec.x or a.minVec.x > b.maxVec.x) then return false end
	-- tile collider y is the bottom 30% of a sprite (70% of the sprite offset from the minvec.y) 
	-- this gives the appearance of 3D viewing as it let's you overlap vertically
	if(a.maxVec.y < b.minVec.y or a.minVec.y > b.maxVec.y) then return false end
	-- No separating axis found, therefore there is at least one overlapping axis
	return true
end

-- returns the corrections to keep it on the screen.
-- should pretty much just be used for enemies since the player can go off the edge (to switch screens)
function AABBvsScreenEdge(a)
	local result = Vector:new(0,0)
	
	if a.minVec.x < 0 then result.x = -a.minVec.x
	elseif a.maxVec.x > baseScreenWidth then result.x = -(a.maxVec.x - baseScreenWidth) end 
	
	if a.minVec.y < 0 then result.y = -a.minVec.y
	elseif a.maxVec.y > baseScreenHeight then result.y = -(a.maxVec.y - baseScreenHeight) end 
		
	return result
end



--[[function correctAABBvsAABB(a,b)	
	
	local result = Vector:new(0,0)
	
	-- a is to the left of b 
	if a.maxVec.x > b.minVec.x and a.minVec.x < b.minVec.x then 
		result.x = a.maxVec.x - b.minVec.x 
	-- a is to the right of b 
	elseif a.minVec.x < b.maxVec.x and a.maxVec.x > b.maxVec.x then 
		result.x = a.minVec.x - b.maxVec.x
	end	
	
	-- a is below b 
	if a.maxVec.y > b.minVec.y and a.minVec.y < b.minVec.y then 
		result.y = a.maxVec.y - b.minVec.y
	-- a is above b 
	elseif a.minVec.y < b.maxVec.y and a.maxVec.y > b.maxVec.y then 
		result.y = a.minVec.y - b.maxVec.y
	end	
	print(result.x, result.y)
	return result 
end]]
