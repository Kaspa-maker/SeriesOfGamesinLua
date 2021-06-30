--- Required libraries.
local randomlua = require( "Scrappy.core.randomlua" )

-- Localised functions.
local random = math.random
local char = string.char
local randomseed = math.randomseed
local time = os.time
local pairs = pairs
local gsub = string.gsub
local format = string.format

-- Localised values

--- Class creation.
local library = {}

--- Initialises this Scrappy library.
-- @param params The params for the initialisation.
function library:init( params )

	-- Were we simply passed a seed as params?
	if params and type( params ) == "number" then

		-- If so, create some params with it
		params = { seed = params }

	end

	-- Store out the params, if any
	self._params = params or {}

	-- Create our random generator
	self._generator = mwc( 0 )

	-- Try to seed the generator
	self:seed( self._params.seed )

end

--- Sets the seed for the random number generator.
-- @param value The seed to set. Optional, defaults to os.time().
function library:seed( value )
	randomseed( value or time() )
	self._generator = mwc( value or time() )
end

--- Gets a random number within a range.
-- @param min The minimum value of the range. Optional, defaults to 0.
-- @param max The maximum value of the range.
-- @return The random value.
function library:inRange( min, max )

	if not max then
		max = min
		min = 0
	end

	return self._generator:random( min, max )

end

--- Gets a random value from a list.
-- @param list The list of values to choose from.
-- @return The randomly selected value.
function library:fromList( list )

	local count = self:_countArray( list )
	local index = self:inRange( 1, count )

	local i = 1
	for k, v in pairs( list ) do
		if i == index then
			return v, k
		end
		i = i + 1
	end

	return nil

end

--- Generates a random string.
-- @param length The desired length of the string to generate.
-- @param options Table containing options for the generation. Supported options are; 'includeSymbols', 'includeNumbers', 'includeLowercase', 'includeUppercase', 'includeSpaces', 'excludeDuplicates', 'beginWithALetter'. Table is optional, leaving it out will include everything.
-- @return The randomly generated string.
function library:string( length, options )

	if not length or length < 1 then
		return nil
	end

	local validChars = {}

	if options then

		if options.includeSymbols or options.includeSymbols == nil then

			for i = 33, 47, 1 do
				validChars[ #validChars + 1 ] = i
			end

			for i = 58, 64, 1 do
				validChars[ #validChars + 1 ] = i
			end

			for i = 123, 126, 1 do
				validChars[ #validChars + 1 ] = i
			end

		end

		if options.includeNumbers or options.includeNumbers == nil then

			for i = 48, 57, 1 do
				validChars[ #validChars + 1 ] = i
			end

		end

		if options.includeLowercase or options.includeLowercase == nil then

			for i = 97, 122, 1 do
				validChars[ #validChars + 1 ] = i
			end

		end

		if options.includeUppercase or options.includeUppercase == nil then

			for i = 65, 90, 1 do
				validChars[ #validChars + 1 ] = i
			end

		end

		if options.includeSpaces or options.includeSpaces == nil then

			validChars[ #validChars + 1 ] = 32

		end

		if options.excludeSimilar or options.excludeSimilar == nil then
			--TODO scrappy.random:string - excludeSimilar
		end

		if options.excludeAmbiguous or options.excludeAmbiguous == nil then
			--TODO scrappy.random:string - excludeAmbiguous
		end

		if options.excludeSequential or options.excludeSequential == nil then
			--TODO scrappy.random:string - excludeSequential
		end

	else

		for i = 32, 126, 1 do
			validChars[ #validChars + 1 ] = i
		end

	end

	local s = ""
	for i = 1, length, 1 do
		if validChars and #validChars > 0 then
			s = s .. char( self:fromList( validChars ) )
		end
	end

	if options then

		if options.beginWithALetter then

			local validChars = {}

			if options.includeLowercase or options.includeLowercase == nil then

				for i = 97, 122, 1 do
					validChars[ #validChars + 1 ] = i
				end

			end

			if options.includeUppercase or options.includeUppercase == nil then

				for i = 65, 90, 1 do
					validChars[ #validChars + 1 ] = i
				end

			end

			s = char( self:fromList( validChars ) ) .. s

		end

		if options.excludeDuplicates or options.excludeDuplicates == nil then

			local chars = {}
			local included = {}
			local newS = ""

			for i = 1, #s do
			    chars[ i ] = s:sub( i, i )
			end

			for k, v in ipairs( chars ) do

			   if not included[ v ] then
			      newS = newS .. v
			       included[ v ] = true
			   end

			end

			s = newS

		end

	end

	-- Safety check to make extra sure white space is gone
	if options and options.includeSpaces == false then
		s = s:gsub( "%s+", "" )
	end

	-- Return the string, making sure to remove and new lines
	return s:gsub( "[\n\r]" , "")

end

--- Flips a coin.
-- @return A true or false value.
function library:coinFlip()
	return self:inRange( 0, 1 ) == 1
end

--- Gets a random colour.
-- @param asTable Should the values be returned as a table. Optional, defaults to false.
-- @return Three values, the r, g, and b of the colour. Either on their own or in an indexed table.
function library:colour( asTable )

	local r, g, b = self:inRange( 100 ) * 0.01, self:inRange( 100 ) * 0.01, self:inRange( 100 ) * 0.01

	if asTable then
		return { r, g, b }
	else
		return r, g, b
	end

end

--- Generates a UUID. Gist from here - https://gist.github.com/jrus/3197011
-- @return The UUID.
function library:uuid()

	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

    return gsub( template, '[xy]', function ( c )
        local v = ( c == 'x' ) and self:inRange( 0, 0xf ) or self:inRange( 8, 0xb )
        return format( '%x', v )
    end )

end

--- Destroys this library.
function library:destroy()
	self._generator = nil
end

--- Counts the total number of elements in an associative array.
-- @return The total.
function library:_countArray( array )

	if array then

		local count = 0

		for _, _ in pairs( array ) do
		    count = count + 1
		end

		return count

	end

end

-- If we don't have a global Scrappy object i.e. this is the first Scrappy plugin to be included
if not Scrappy then

	-- Create one
	Scrappy = {}

end

-- If we don't have a Scrappy Leaderboards library
if not Scrappy.Random then

	-- Then store the library out
	Scrappy.Random = library

end

-- Return the new library
return library
