--- Required libraries.

--- Localised functions.
local cos = math.cos
local sin = math.sin
local rad = math.rad
local deg = math.deg
local atan = math.atan
local atan2 = math.atan2
local max = math.max
local min = math.min
local floor = math.floor
local ceil = math.ceil
local sqrt = math.sqrt
local pi = math.pi
local pi2 = pi * 2
local abs = math.abs

-- Localised values

--- Class creation.
local library = {}

--- Gets a heading vector for an angle.
-- @param angle The angle to use, in degrees.
-- @return The heading vector.
function library:vectorFromAngle( angle )
	return { x = cos( rad( angle - 90 ) ), y = sin( rad( angle - 90 ) ) }
end

--- Gets the angle between two position vectors.
-- @param vector1 The first position.
-- @param vector2 The second position.
-- @return The angle.
function library:angleBetweenVectors( vector1, vector2 )
	local angle = deg( atan2( vector2.y - vector1.y, vector2.x - vector1.x ) ) + 90
	if angle < 0 then angle = 360 + angle end
	return angle
end

--- Gets the angle between two position vectors, limited by a turn rate.
-- @param vector1 The first position.
-- @param vector2 The second position.
-- @param current The current rotation of the object.
-- @param turnRate The max rate of the turn.
-- @return The angle.
function library:limitedAngleBetweenVectors( vector1, vector2, current, turnRate )

	local target = self:angleBetweenVectors( vector1, vector2 )

	local delta = floor( target - current )

	delta = self:normaliseAngle( delta )

	delta = self:clamp( delta, -turnRate, turnRate )

	return current + delta

end

--- Clamps a value between lowest and highest values.
-- @param value The value to clamp.
-- @param lowest The lowest the value can be.
-- @param highest The highest the value can be.
-- @return The clamped value.
function library:clamp( value, lowest, highest )
    return max( lowest, min( highest, value ) )
end

-- KM
--- Clamps a value to zero if it is below cutoff
-- @param value The value to clamp.
-- @param cutoff The lowest the value can be before be made zero

-- @return The clamped value.
function library:clampToZero( value, cutoff )
	cutoff = cutoff or 0.01
    return abs(value)>=cutoff and value or 0
end


--- Rounds a number.
-- @param number The number to round.
-- @param idp The number of decimal places to round to. Optional, defaults to 0.
-- @return The rounded number.
function library:round( number, idp )
	local mult = 10 ^ ( idp or 0 )
	return floor( number * mult + 0.5 ) / mult
end

--- Checks if a number is actually NotANumber.
-- @return True if it is, false otherwise.
function library:isNan( x )
	return x ~= x
end

--- Checks if a number is even.
-- @return True if it is, false otherwise.
function library:isEven( x )
	return x % 2 == 0
end

--- Checks if a number is odd.
-- @return True if it is, false otherwise.
function library:isOdd( x )
	return not self:isEven( x )
end

--- Gets the distance between two position vectors.
-- @param vector1 The first position.
-- @param vector2 The second position.
-- @return The distance.
function library:distanceBetweenVectors( vector1, vector2 )
	if not vector1 or not vector1.x or not vector1.y or not vector2 or not vector2.x or not vector2.y then
		return
	end
	return sqrt( self:distanceBetweenVectorsSquared( vector1, vector2 ) )
end

--- Gets the squared distance between two position vectors.
-- @param vector1 The first position.
-- @param vector2 The second position.
-- @return The distance.
function library:distanceBetweenVectorsSquared( vector1, vector2 )
	if not vector1 or not vector1.x or not vector1.y or not vector2 or not vector2.x or not vector2.y then
		return
	end
	local factor = { x = vector2.x - vector1.x, y = vector2.y - vector1.y }
	return ( factor.x * factor.x ) + ( factor.y * factor.y )
end

--- Gets the centre point between two position vectors.
-- @param vector1 The first position.
-- @param vector2 The second position.
-- @return The centre position as a table containing x and y values.
function library:centreBetweenVectors( vector1, vector2 )

    return
    {
        x = ( vector1.x + vector2.x ) * 0.5,
        y = ( vector1.y + vector2.y ) * 0.5
    }

end

--- Checks if a point is within a given polygon.
-- @param x The X position of the point.
-- @param y The Y position of the point.
-- @param The vertices of the polygon.
-- @return True if it is, false otherwise.
function library:pointInPolygon( x, y, vertices )

	local intersects = false

	local j = #vertices
	for i = 1, #vertices, 1 do
		if (vertices[i][2] < y and vertices[j][2] >= y or vertices[j][2] < y and vertices[i][2] >= y) then
			if (vertices[i][1] + ( y - vertices[i][2] ) / (vertices[j][2] - vertices[i][2]) * (vertices[j][1] - vertices[i][1]) < x) then
				intersects = not intersects
			end
		end
		j = i
	end

	return intersects

end

--- Checks if a point is within a given rectangle.
-- @param x The X position of the point.
-- @param y The Y position of the point.
-- @param bounds The bounds of the rectangle.
-- @return True if it is, false otherwise.
function library:pointInRectangle( x, y, bounds )

	if x >= bounds.xMin and x <= bounds.xMax then
		if y >= bounds.yMin and y <= bounds.yMax then
			return true
		end
	end

end

--- Checks if a point is within a given circle.
-- @param x The X position of the point.
-- @param y The Y position of the point.
-- @param cX The X position of the circle.
-- @param cY The Y position of the circle.
-- @param radius The radius of the circle.
-- @return True if it is, false otherwise.
function library:pointInCircle( x, y, cX, cY, radius )

	return self:distanceBetweenVectorsSquared( { x = cX, y = cY }, { x = x, y = y } ) <= ( radius * radius )

end

--- Checks if two circles have collided.
-- @param vector1 The position of the first circle.
-- @param vector2 The position of the second circle.
-- @param radius1 The radius of the first circle.
-- @param radius2 The radius of the second circle.
-- @return True if they have, false otherwise.
function library:haveCirclesCollided( vector1, vector2, radius1, radius2 )

	if not vector1 or not vector2 or not radius1 or not radius2 then
		return false
	end

    local dx = vector1.x - vector2.x
    local dy = vector1.y - vector2.y

    local distance = math.sqrt( dx * dx + dy * dy )
    local size = radius1 + radius2

    return distance < size

end

--- Checks if two bounding boxes have collided.
-- @param bounds1 The contentBounds of the first box.
-- @param bounds2 The contentBounds of the second box.
-- @return True if they have, false otherwise.
function library:haveRectanglesCollided( bounds1, bounds2 )

	if not bounds1 or not bounds2 then
		return false
	end

    local left = bounds1.xMin <= bounds2.xMin and bounds1.xMax >= bounds2.xMin
    local right = bounds1.xMin >= bounds2.xMin and bounds1.xMin <= bounds2.xMax
    local up = bounds1.yMin <= bounds2.yMin and bounds1.yMax >= bounds2.yMin
    local down = bounds1.yMin >= bounds2.yMin and bounds1.yMin <= bounds2.yMax

    return ( left or right ) and ( up or down )

end

--- Checks if a circle has collded with a rectangle.
-- @param circle Table containing x, y, and radius values.
-- @param bounds The contentBounds of the rectangle.
-- @return True if they have, false otherwise.
function library:hasCircleCollidedWithRectangle( circle, bounds )

	-- Find the closest point to the circle within the rectangle
	local closestX = self:clamp( circle.x, bounds.xMin, bounds.xMax )
	local closestY = self:clamp( circle.y, bounds.yMin, bounds.yMax )

	-- Calculate the distance between the circle's center and this closest point
	local distanceX = circle.x - closestX
	local distanceY = circle.y - closestY

 	-- If the distance is less than the circle's radius, an intersection occurs
	local distanceSquared = ( distanceX * distanceX ) + ( distanceY * distanceY )

	return distanceSquared < ( circle.radius * circle.radius )

end

--- Gets the area of a polygon.
-- @param vertices The vertices of the polygon.
-- @return The area.
function library:areaOfPolygon( vertices )

	local area = self:crossProduct( vertices[ #vertices ], vertices[ 1 ] )

	for i = 1, #vertices - 1, 1 do
		area = area + self:crossProduct( vertices[ i ], vertices[ i + 1 ] )
	end

	area = area / 2

	return area

end

--- Gets the centre of a polygon.
-- @param vertices The vertices of the polygon.
-- @return The centre position, a table containing 'x' and 'y' values.
function library:centreOfPolygon( vertices )

	local p,q = vertices[ #vertices ], vertices[ 1 ]
	local det = self:crossProduct( p, q )
	local centroid = { x = ( p.x + q.x ) * det, y = ( p.y + q.y ) * det }

	for i = 1, #vertices - 1, 1 do
		p, q = vertices[ i ], vertices[ i + 1 ]
		det = self:crossProduct( p, q )
		centroid.x = centroid.x + ( p.x + q.x ) * det
		centroid.y = centroid.y + ( p.y + q.y ) * det
	end

	local area = self:areaOfPolygon( vertices )
	centroid.x = centroid.x / ( 6 * area )
	centroid.y = centroid.y / ( 6 * area )

	return centroid

end

--- Normalises a value to within 0 and 1.
-- @param value The current unnormalised value.
-- @param min The minimum the value can be.
-- @param max The maximum the value can be.
-- @return The newly normalised value.
function library:normalise( value, min, max )
	local result = ( value - min ) / ( max - min )
	if result > 1 then
		result = 1
	end
	return result
end

--- Normalises a value from one range to another so that it's within within 0 and 1.
-- @param value The current value.
-- @param minA The minimum the value can be on the first range.
-- @param maxA The maximum the value can be on the first range.
-- @param minB The minimum the value can be on the second range.
-- @param maxB The maximum the value can be on the second range.
-- @return The newly normalised value.
function library:normaliseAcrossRanges( value, minA, maxA, minB, maxB )
	return ( ( ( value - minA ) * ( maxB - minB ) ) / ( maxA - minA ) ) + minB
end

--- Normalises an angle.
-- @param angle The angle to normalise.
-- @return The newly normalised angle.
function library:normaliseAngle( angle )

    local newAngle = angle

    while newAngle <= -180 do
		newAngle = newAngle + 360
	end

    while newAngle > 180 do
		newAngle = newAngle - 360
	end

    return newAngle

end

--- Limits a rotation to a max rate.
-- @param current The current rotation.
-- @param target The target rotation.
-- @param maxRate The maximum number of degrees the rotation can go to.
-- @return The newly limited angle.
function library:limitRotation( current, target, maxRate )

	if current and target and maxRate then

		local angle = target

	    local d = current - angle

		d = self:normaliseAngle( d )

	    if d > maxRate then
	        angle = current - maxRate
	    elseif d < -maxRate then
	        angle = current + maxRate
	    end

		return angle

	end

end

--- Gets a 1d index from a 2d array.
-- @param row The row to use.
-- @param column The colume to use.
-- @param clumnCount Count of columns in the array.
-- @return The index.
function library:indexFrom2DArray( row, column, columnCount )
	return ( ( column * columnCount ) + row ) - columnCount
end

--- Gets a 2d position from a 1d array.
-- @param index The index to use.
-- @param columnCount The number of columns in the grid.
-- @return The row and column numbers.
function library:rowColumnFromIndex( index, columnCount )
	return floor( ( index - 1 ) / columnCount ) + 1, ( index - 1 ) % columnCount + 1
end

--- Calculate the dot product of two vectors.
-- @param v1 The first vector. An object containing both an 'x' and a 'y' property.
-- @param v2 The second vector. An object containing both an 'x' and a 'y' property.
-- @return The calculated dot product.
function library:dotProduct( v1, v2 )
	return v1.x * v2.x + v1.y * v2.y
end

--- Calculate the cross product of two vectors.
-- @param v1 The first vector. An object containing both an 'x' and a 'y' property.
-- @param v2 The second vector. An object containing both an 'x' and a 'y' property.
-- @return The calculated cross product.
function library:crossProduct( v1, v2 )
	return ( v1.x * v2.y ) - ( v1.y * v2.x )
end

--- Multiplies two vectors.
-- @param v1 The first vector. An object containing both an 'x' and a 'y' property.
-- @param v2 The second vector. An object containing both an 'x' and a 'y' property.
-- @return The resultant vector.
function library:vectorMultiply( v1, v2 )
	return { x = v1.x * v2.x, y = v1.y * v2.y }
end

--- Gets the magnitude of a vector.
-- @param v The vector. An object containing both an 'x' and a 'y' property.
-- @return The magnitude.
function library:vectorMagnitude( v )
	return sqrt( v.x * v.x + v.y * v.y )
end

--- Normalises a vector.
-- @param v The vector. An object containing both an 'x' and a 'y' property.
-- @return The normalised vector.
function library:vectorNormalise( v )

    local length = self:vectorMagnitude( v )

    -- Do something suitable to handle the case where the length is close to 0 here...
    return  { x = v.x / length, y = v.y / length }

end

--- Converts degrees to radians.
-- @param deg The degrees.
-- @return The converted radians.
function library:degToRad( deg )
	return ( deg * pi ) / 180
end

--- Converts radians to degrees.
-- @param rad The radians.
-- @return The converted degrees.
function library:radToDeg( rad )
	return ( rad * 180 ) / pi
end

-- Linear interpolates between two numbers.
-- @param from The first number.
-- @param to The second number.
-- @param time The time value for the interpolation.
-- @return The interpolated value.
function library:lerp( from, to, time )
	return from + ( to - from ) * time
end

-- Calculates a percentage. Yes I'm that lazy.
-- @param value The value.
-- @param total The total.
-- @return The calculated percentage.
function library:calculatePercentage( value, total )
	return ( value / total ) * 100
end

-- Rotates a point around another position.
-- @param point The point to rotate. A table containing x and y values.
-- @param angle The angle to rotate by.
-- @param origin The position to rotate around. A table containing x and y values.
-- @return The adjusted point's position.
function library:rotatePoint( point, angle, origin )

	local s = sin( angle )
	local c = cos( angle )

	-- Translate point back to origin
	point.x = point.x - origin.x
	point.y = point.y - origin.y

	-- Rotate point
	local xNew = point.x * c - point.y * s
	local yNew = point.x * s + point.y * c

	-- Translate point back
	point.x = xNew + origin.x
	point.y = yNew + origin.y

	return point

end

-- Calculates the corners of a rectangle.
-- @param rectangle The rectangle to check on. Must contain x, y, width, and height. Optionally can include rotation.
-- @return Table containing four points; topLeft, topRight, bottomLeft, and bottomRight.
function library:calculateCornersOfRectangle( rectangle )

	-- Fet the rotation of the rectangle
	local angle = rad( rectangle.rotation or 0 )

	-- Calculate the 4 corners
	local corners =
	{
		topLeft = self:rotatePoint( { x = rectangle.x - rectangle.width * 0.5, y = rectangle.y - rectangle.height * 0.5 }, angle, rectangle ),
		topRight = self:rotatePoint( { x = rectangle.x - rectangle.width * 0.5,  y = rectangle.y + rectangle.height * 0.5 }, angle, rectangle ),
		bottomLeft = self:rotatePoint( { x = rectangle.x + rectangle.width * 0.5,  y = rectangle.y - rectangle.height * 0.5 }, angle, rectangle ),
		bottomRight = self:rotatePoint( { x = rectangle.x + rectangle.width * 0.5,  y = rectangle.y + rectangle.height * 0.5 }, angle, rectangle )
	}

	-- Return them
	return corners

end

-- Calculates the x and y of an item in a 2d array from a 1d index.
-- @param index The array index.
-- @param width The width of the array.
-- @return The x and y values of the item.
function library:positionFromIndex( index, width )
	local y = index / width
	local x = index % width
	return x, y
end

-- Calculates the 1d index of an item in a 2d array.
-- @param x The x position of the time.
-- @param y The y position of the item.
-- @param width The width of the array.
-- @return The index of the item.
function library:indexFromPosition( x, y, width )
	return y * width + x
end

--- Calculates the new x and y scale for a display object so that it fits certain bounds.
-- @param object The display object to use for the scale.
-- @param width The width to fit. Optional, if left out then it will use just the height value and keep the aspect ratio the same.
-- @param width The height to fit. Optional, if left out then it will use just the width value and keep the aspect ratio the same.
-- @returns The new x and y scales.
function library:calculateScaleToFit( object, width, height )

	local xScale, yScale = 1, 1
	local newWidth, newHeight

	if width then
		xScale = width / ( object.width or object.contentWidth )
	end

	if height then
		yScale = height / ( object.height or object.contentHeight )
	end

	return xScale or yScale, yScale or xScale

end

-- If we don't have a global Scrappy object i.e. this is the first Scrappy plugin to be included
if not Scrappy then

	-- Create one
	Scrappy = {}

end

-- If we don't have a Scrappy Maths library
if not Scrappy.Maths then

	-- Then store the library out
	Scrappy.Maths = library

end

-- Return the new library
return library
