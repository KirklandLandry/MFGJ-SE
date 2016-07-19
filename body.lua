Body = {box = nil, vel =nil, maxHealth = nil, currentHealth = nil, facingDirection = nil, moveState = nil, bodyState = nil, recoilX = 0, recoilY = 0, recoilTimer = nil}


function Body:new(x,y,width,height, maxHealth, currentHealth, recoilTime)	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.box = AABB:new(x,y,width,height)
	o.vel = Vector:new(0,0)
	o.maxHealth = maxHealth 
	o.currentHealth = currentHealth
	o.facingDirection = Directions.up
	o.moveState = MoveStates.neutral 
	o.bodyState = BodyStates.neutral
	o.recoilX = 0
	o.recoilY = 0
	o.recoilTimer = Timer:new(recoilTime, "single")
	return o
end


function Body:checkEntityCollisions()
	local collisionInfo = AABBvsEnemiesCollisions(self.box)
	return collisionInfo
end

function Body:tilemapCollisions()
	local tileCoords = getTileCoordinate(self.box.minVec.x, self.box.minVec.y)

	-- check for collisions against the tilemap 
	-- this is very cheap, it only reverses the player's elocity on collision 
	-- this shouldn't be needed once the collision method below works properly 
	if (checkTileMapCollision(self.box, tileCoords.x, tileCoords.y)) then self.box:scalarMove(-self.vel.x, -self.vel.y) end
	
	
	-- runs twice. once for x and once for y. 
	-- this could be collapsed into one thing, do that later 
	-- also doesn't work paricularly well.
	local tilemapCorrectionInfo = checkTileMapCollision(self.box, tileCoords.x, tileCoords.y)
	if tilemapCorrectionInfo ~= nil then 
		self.box:scalarMove(tilemapCorrectionInfo.normal.x * tilemapCorrectionInfo.penetration, tilemapCorrectionInfo.normal.y * tilemapCorrectionInfo.penetration)
	end
	local tilemapCorrectionInfo = checkTileMapCollision(self.box, tileCoords.x, tileCoords.y)
	if tilemapCorrectionInfo ~= nil then 
		self.box:scalarMove(tilemapCorrectionInfo.normal.x * tilemapCorrectionInfo.penetration, tilemapCorrectionInfo.normal.y * tilemapCorrectionInfo.penetration)
	end
end