--!strict
--!optimize 2
--!native

-- DEPRECATED NOTICE --
-- There are better alternatives.

-- Version: 0.4.1

local module = {}

module.isString = function(candidate: string): boolean
	return type(candidate) == "string"
end

module.isNumber = function(candidate: number, allowSpecial: boolean?): boolean
	if type(candidate) ~= "number" then
		return false
	end
	
	-- nan (not a number) has a property where the boolean expression: `nan == nan` returns false.
	-- inf (math.huge) has strange properties, so it is also considered special.
	if not allowSpecial and (candidate ~= candidate or math.abs(candidate) == math.huge) then
		return false
	end
	
	return true
end

module.isBoolean = function(candidate: boolean | nil, exclude_nil: boolean?): boolean
	if not exclude_nil and type(candidate) == "nil" then
		return true
	end
	
	return type(candidate) == "boolean"
end

module.isTable = function(candidate: {[any]: any}): boolean
	return type(candidate) == "table"
end

module.isArray = function(candidate: {[number]: any}, ignore_PrerequisiteChecks: boolean?): boolean
	if not ignore_PrerequisiteChecks and type(candidate) ~= "table" then
		return false
	end
	
	local lastKey = nil
	
	while true do
		local key, _ = next(candidate, lastKey)
		
		if lastKey and key and key ~= lastKey + 1 then
			return false
			
		elseif not key then
			return true
			
		end
		
		lastKey = key
	end
	
	return true
end

module.isDictionary = function(candidate: {[any]: any}, ignore_PrerequisiteChecks: boolean?): boolean
	if not ignore_PrerequisiteChecks and type(candidate) ~= "table" then
		return false
	end
	
	-- There is nothing else to check for a dictionary, since they are key-value
	-- pairs instead of indexed values (array). Each key is also unique, setting
	-- to a value for a key results in overwriting.
	-- Therefore, there is nothing else to check, unlike .isArray()
	
	return true
end

module.isInstance = function(candidate: Instance, classname: string?): boolean
	if typeof(candidate) ~= "Instance" then
		return false
	end
	
	if type(classname) == "string" and candidate.ClassName ~= classname then
		return false
	end
	
	return true
end

return module
