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


function AABBvsAABBDetectionAndResolution(a, b)	
	local result = {normal = Vector:new(0,0), penetration = 0}

	-- remember to measure from the centre to make it work properly 
	-- it'll look like it works if the widths are the same, but diff width will throw everything off
	local n = Vector:new((b.minVec.x + b.width/2) - (a.minVec.x + a.width/2), (b.minVec.y + b.height/2) - (a.minVec.y + a.height/2))
						
	local aExtentX = a.width / 2 
	local bExtentX =  b.width  / 2 
	local xOverlap = aExtentX + bExtentX - math.abs(n.x)
	-- SAT test on x
	if xOverlap > 0 then 
		local aExtentY = a.height / 2 
		local bExtentY =  b.height  / 2 
		local yOverlap = aExtentY + bExtentY - math.abs(n.y)		
		-- SAT test on y
		if yOverlap > 0 then 
			-- which is the axis of least penetration
			if xOverlap < yOverlap then 
				if n.x < 0 then 
					result.normal.x = 1  
					result.normal.y =  0
				else
					result.normal.x = -1 
					result.normal.y = 0 
				end
				result.penetration = xOverlap
				return result 
			else 
				if n.y < 0 then 
					result.normal.x =  0
					result.normal.y = 1
				else
					result.normal.x = 0
					result.normal.y = -1
				end
				result.penetration = yOverlap

				return result 
			end
		end
	end
	return nil 
end



-- this isn't fully tested and the getTileColliderY presents a problem
-- it's fine for vertical movement but left right will cause a gap
-- might need multiple n's, need to think it through
function AABBvsTileDetectionAndResolution(a, bx,by,bw,bh)
	local result = {normal = Vector:new(0,0), penetration = 0}

	-- remember to measure from the centre to make it work properly 
	-- it'll look like it works if the widths are the same, but diff width will throw everything off
	local n = Vector:new((bx + bw/2) - (a.minVec.x + a.width/2), (by + bh/2) - (a:getTileColliderY() + a.height/2))
						
	local aExtentX = a.width / 2 
	local bExtentX = bw / 2 
	local xOverlap = aExtentX + bExtentX - math.abs(n.x)
	-- SAT test on x
	if xOverlap > 0 then 
		local aExtentY = a.height / 2 
		local bExtentY = bh / 2 
		local yOverlap = aExtentY + bExtentY - math.abs(n.y)		
		-- SAT test on y
		if yOverlap > 0 then 
			-- which is the axis of least penetration
			if xOverlap < yOverlap then 
				if n.x < 0 then 
					result.normal.x = 1  
					result.normal.y =  0
				else
					result.normal.x = -1 
					result.normal.y = 0 
				end
				result.penetration = xOverlap
				return result 
			else 
				if n.y < 0 then 
					result.normal.x =  0
					result.normal.y = 1
				else
					result.normal.x = 0
					result.normal.y = -1
				end
				result.penetration = yOverlap

				return result 
			end
		end
	end
	return nil 
end

