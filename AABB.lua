AABB = {minVec = Vector:new(0,0), maxVec = Vector:new(0,0), width = 0, height = 0, shape = "AABB"}

function AABB:new(x, y, width, height)	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.minVec = Vector:new(x, y)
	o.maxVec = Vector:new(x + width, y + height)
	o.width = width
	o.height = height
	shape = "AABB"
	return o
end
 
function AABB:scalarReposition(x,y)
	self.minVec.x = x 
	self.minVec.y = y 
	self.maxVec.x = x + self.width 
	self.maxVec.y = y + self.height
end
 
function AABB:vectorMove(v)
	self.minVec:vectorAdd(v)
	self.maxVec:vectorAdd(v)
end

function AABB:scalarMove(xAdd, yAdd)
	self.minVec:scalarAdd(xAdd, yAdd) 
	self.maxVec:scalarAdd(xAdd, yAdd)
end

-- used for checking collision against the tilemap vertically.
-- used to offset the minimum y by 70% of the sprite so it'll check 
-- for collisions using the bottom 30% of the sprite
function AABB:getTileColliderY()
	return (self.minVec.y + (self.width * 0.70))
end

function AABB:drawCorners()
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", self.minVec.x, self.minVec.y, self.width, self.height)
	love.graphics.setColor(0,222,0)
	love.graphics.circle("fill", self.minVec.x, self.minVec.y, 1,32)
	love.graphics.circle("fill", self.maxVec.x, self.minVec.y, 1,32)
	love.graphics.circle("fill", self.minVec.x, self.maxVec.y, 1,32)
	love.graphics.circle("fill", self.maxVec.x, self.maxVec.y, 1,32)
	love.graphics.setColor(255,255,255)
end