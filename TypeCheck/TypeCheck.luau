--!strict

local module = {}

-- This type is taken from the ComplexNumber module.
type RawComplexNumber = {
	["real"]: number,
	["complex"]: number
}

module.isString = function(candidate: string?): boolean
	if not candidate or typeof(candidate) ~= "string" then
		return false
	end
	
	return true
end

module.isNumber = function(candidate: number?, allowSpecial: boolean?): boolean
	if not candidate or typeof(candidate) ~= "number" then
		return false
	end
	
	-- nan (not a number) has a property where the boolean expression: `nan == nan` returns false.
	-- inf (math.huge) has strange properties, so it is also considered special.
	if not allowSpecial and (candidate ~= candidate or math.abs(candidate) == math.huge) then
		return false
	end
	
	return true
end

-- This function is used for the ComplexNumber module
module.isComplexNumber = function(candidate: RawComplexNumber?): boolean
	if not (candidate and typeof(candidate) == "table") then
		return false
	end
	
	if not candidate.real or not module.isNumber(candidate.real, false) then
		return false
	end
	
	if not candidate.complex or not module.isNumber(candidate.complex, false) then
		return false
	end
	
	return true
end

module.isBoolean = function(candidate: boolean | nil, exclude_nil: boolean?): boolean
	if typeof(candidate) ~= "boolean" and typeof(candidate) ~= "nil" then
		return false
	end
	
	if candidate == true or candidate == false then
		return true
		
	elseif not exclude_nil and candidate == nil then
		return true
	end
	
	return false
end

module.isTable = function(candidate: {[any]: any}): boolean
	if not (candidate and typeof(candidate) == "table") then
		return false
	end
	
	return true
end

module.isArray = function(candidate: {[number]: any}, ignore_PrerequsiteChecks: boolean?): boolean
	if not ignore_PrerequsiteChecks and not module.isTable(candidate) then
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

module.isDictionary = function(candidate: {[any]: any}, ignore_PrerequsiteChecks: boolean?): boolean
	if not ignore_PrerequsiteChecks and not module.isTable(candidate) then
		return false
	end
	
	-- There is nothing else to check for a dictionary, since they are key-value
	-- pairs instead of indexed values (array). Each key is also unique, setting
	-- to a value for a key results in overwriting.
	-- Therefore, there is nothing else to check, unlike .isArray()
	
	return true
end

module.isRBXObject = function(candidate: Object?, classname: string?): boolean
	if not candidate or typeof(candidate) ~= "Instance" then
		return false
	end
	
	if not candidate:IsA("Object") then
		return false
	end
	
	if classname and module.isString(classname) and candidate.ClassName ~= classname then
		return false
	end
	
	return true
end

return module::typeof(module)
