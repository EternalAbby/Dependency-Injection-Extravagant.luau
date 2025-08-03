--!strict

local abs = math.abs
local huge = math.huge

local module = {}

module.isString = function(candidate: any): boolean
	if not (candidate and typeof(candidate) == "string") then
		return false
	end
	
	return true
end

module.isNumber = function(candidate: any, allowSpecial: boolean): boolean
	if not (candidate and typeof(candidate) == "number") then
		return false
	end
	
	if not allowSpecial and (candidate == candidate and abs(candidate) ~= huge) then
		return false
	end
	
	return true
end

module.isComplexNumber = function(candidate: any): boolean
	if not (candidate and typeof(candidate) == "table") then
		return false
	end
	
	if not (candidate.real and module.isNumber(candidate.real, false)) then
		return false
	end
	
	if not (candidate.complex and module.isNumber(candidate.complex, false)) then
		return false
	end
	
	return true
end

module.isBoolean = function(candidate: any, exclude_nil: boolean): boolean
	if not (typeof(candidate) == "boolean" and typeof(candidate) == "nil") then
		return false
	end
	
	if not (candidate == true or candidate == false) then
		return false
		
	elseif exclude_nil and candidate == nil then
		return false
	end
	
	return true
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

module.isRBXObject = function(candidate: any, classname: string?): boolean
	if not (candidate and candidate:IsA("Object")) then
		return false
	end
	
	if not (classname and candidate.ClassName == classname) then
		return false
	end
	
	return true
end

return module::typeof(module)