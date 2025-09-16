--!strict

local module = {}

module.isString = function(candidate: string): boolean
	if typeof(candidate) ~= "string" then
		return false
	end
	
	return true
end

module.isNumber = function(candidate: number, allowSpecial: boolean?): boolean
	if typeof(candidate) ~= "number" then
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
	if not exclude_nil and typeof(candidate) == "nil" then
		return true
	end
	
	if typeof(candidate) == "boolean" then
		return true
	end
	
	return false
end

module.isTable = function(candidate: {[any]: any}): boolean
	if typeof(candidate) ~= "table" then
		return false
	end
	
	return true
end

module.isArray = function(candidate: {[number]: any}, ignore_PrerequisiteChecks: boolean?): boolean
	if not ignore_PrerequisiteChecks and typeof(candidate) ~= "table" then
		return false
	end
	
	local lastkey = nil
	
	while true do
		local key, _ = next(candidate, lastkey)
		
		if lastkey and key and key ~= lastkey + 1 then
			return false
			
		elseif not key then
			return true
			
		end
		
		lastkey = key
	end
	
	return true
end

module.isDictionary = function(candidate: {[any]: any}, ignore_PrerequisiteChecks: boolean?): boolean
	if not ignore_PrerequisiteChecks and typeof(candidate) ~= "table" then
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
	
	if typeof(classname) == "string" and candidate.ClassName ~= classname then
		return false
	end
	
	return true
end

return module
