--!strict

local module = {}

-- This type is taken from the ComplexNumber module.
type RawComplexNumber = {
	["real"]: number,
	["complex"]: number
}

-- This type is taken from the ComplexNumber module.
type ComplexNumber = setmetatable<{
	["real"]: number,
	["complex"]: number
}, {__metatable: "ComplexNumber"}>

-- This type is taken from the Matrix module.
type Matrix = {}

-- This type is taken from the Matrix module.
type DynamicMatrix = {}

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

-- This function is used in the ComplexNumber module.
module.isRawComplexNumber = function(candidate: RawComplexNumber): boolean
	if typeof(candidate) ~= "table" then
		return false
	end
	
	if not module.isNumber(candidate.real, false) then
		return false
	end
	
	if not module.isNumber(candidate.complex, false) then
		return false
	end
	
	return true
end

-- This function is used in the ComplexNumber module.
module.isComplexNumber = function(candidate: ComplexNumber): boolean
	if typeof(candidate) ~= "table" then
		return false
	end
	
	if getmetatable(candidate) ~= "ComplexNumber" then
		return false
	end
	
	if not module.isNumber(candidate.real, false) then
		return false
	end
	
	if not module.isNumber(candidate.complex, false) then
		return false
	end
	
	return true
end

-- This function is used in the Matrix module.
module.isMatrix = function(candidate: Matrix): boolean
	-- TBA
	return false
end

-- This function is used in the Matrix module.
module.isSquaredMatrix = function(candidate: Matrix): boolean
	-- TBA
	return false
end

-- This function is used in the Matrix module.
module.isDynamicMatrix = function(candidate: DynamicMatrix): boolean
	-- TBA
	return false
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
