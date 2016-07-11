Vector = {x = 0, y = 0}

function Vector:new(x, y)	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.x = x or 0
	o.y = y or 0
	return o
end
 
function Vector:set(x,y)
	self.x = x
	self.y = y
end 

-- the scalar dot product
function Vector:dot(v2)
	vectorAssertion(v2)
	return ((self.x * v2.x) + (self.y * v2.y))
end
function Vector:cross(v2)
	
end

function Vector:scale(s)
	self.x = self.x * s 
	self.y = self.y * s
end

-- centre of rotation (vector) and angle
function Vector:rotate(cor, angle)
	vectorAssertion(cor)
	-- translate to origin by subtracting the centre
	local tempX = self.x - cor.x
	local tempY = self.y - cor.y
	-- perform the rotation with the centre now at the origin (0,0)
	local rotatedX = (tempX * math.cos(angle)) - (tempY * math.sin(angle))
	local rotatedY = (tempX * math.sin(angle)) + (tempY * math.cos(angle))	
	-- move back into position by adding the centre back in
	self.x = rotatedX + cor.x
	self.y = rotatedY + cor.y
end

function Vector:magnitude()
	return math.sqrt((self.x * self.x)+(self.y * self.y))
end

function Vector:leftNormal()
	return Vector:new(-self.y, self.x)
end
function Vector:rightNormal()
	return Vector:new(self.y, -self.x)
end 

function Vector:scalarAdd(x, y)
	assert(x~=nil and y~=nil, "blank argument was passed")
	self.x = self.x + x
	self.y = self.y + y
end
function Vector:vectorAdd(v)
	vectorAssertion(v)
	self.x = self.x + v.x
	self.y = self.y + v.y
end

function Vector:scalarSub(x, y)
	assert(x~=nil and y~=nil, "blank argument was passed")
	self.x = self.x - x
	self.y = self.y - y
end
function Vector:vectorSub(v)
	vectorAssertion(v)
	self.x = self.x - v.x
	self.y = self.y - v.y
end

function Vector:scalarMul(x, y)
	assert(x~=nil and y~=nil, "blank argument was passed")
	self.x = self.x * x 
	self.y = self.y * y
end
function Vector:vectorMul(v)
	vectorAssertion(v)
	self.x = self.x * v.x
	self.y = self.y * v.y
end

function Vector:scalarDiv(x, y)
	assert(x~=nil and y~=nil, "blank argument was passed")
	self.x = self.x / x
	self.y = self.y / y
end
function Vector:vectorDiv(v)
	vectorAssertion(v)
	self.x = self.x / v.x
	self.y = self.y / v.y
end

-- the scalar projection of b onto a is the length of the segment AB
-- where AB is the length from the start of a to the length of AB
-- http://math.oregonstate.edu/home/programs/undergrad/CalculusQuestStudyGuides/vcalc/dotprod/dotprod.html
function Vector:projection(p)
	vectorAssertion(p)
	return self:dot(Vector:new(p.x / p:magnitude(), p.y / p:magnitude()))
end

function vectorAssertion(v)
	assert(type(v) == "table" and v.x ~= nil and v.y ~= nil , "argument is not a vector")
end
