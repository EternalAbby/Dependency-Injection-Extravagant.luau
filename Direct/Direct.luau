--!strict

-- Version: 1.2.0

type Cache_Result = {
	[any]: any
}

type Cache = {
	[Instance]: {
		["results"]: {[string]: Cache_Result},
		["connections"]: {RBXScriptConnection}
	}
}

local cache: Cache = {}

local function isString(candidate: string)
	return typeof(candidate) == "string"
end

local function isNumber(candidate: number): boolean
	if typeof(candidate) ~= "number" then
		return false
	end
	
	if candidate ~= candidate or math.abs(candidate) == math.huge then
		return false
	end
	
	return true
end

local function isInstance(candidate: Instance, classname: string?): boolean
	if typeof(candidate) ~= "Instance" then
		return false
	end
	
	if typeof(classname) == "string" and candidate.ClassName ~= classname then
		return false
	end
	
	return true
end

local function KillCachedResult(key: any)
	for _, connection in cache[key]["connections"] do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	cache[key] = nil
end

local function PopulateCache(key: any, func: string, cache_idx: any, cache_result: any, ...: RBXScriptConnection)
	if not cache[key] then
		cache[key] = {
			["results"] = {
				[func] = {[cache_idx] = cache_result}
			},
			
			["connections"] = {
				key.AncestryChanged:Once(function()
					KillCachedResult(key)
				end),
				
				key.Destroying:Once(function()
					KillCachedResult(key)
				end)
			}
		}
		
	else
		cache[key]["results"][func] = {
			[cache_idx] = cache_result
		}
	end
	
	for _, connection in {...} do
		table.insert(cache[key]["connections"], connection)
	end
end

local function SearchCache(key: any, func: string, cache_idx: any): any?
	if cache[key] and cache[key]["results"][func] and cache[key]["results"][func][cache_idx] then
		return cache[key]["results"][func][cache_idx]
	end
	
	return nil
end

local module = {}

--[[
	Function: Clears the cache.
	Returns a boolean to determine whether there were any cached results.
	
	EXPERIMENTAL: THIS FUNCTION IS PART OF AN EXPERIMENTAL FEATURE. THERE MAY BE
	CHANGES TO THIS FUNCTIONS IN THE FUTURE.
]]
module.ClearCache = function(): boolean
	local flag = false
	for key, _ in cache do
		KillCachedResult(key)
		flag = true
	end
	return flag
end

--[[
	Function: Prints the cache.
	
	EXPERIMENTAL: THIS FUNCTION IS PART OF AN EXPERIMENTAL FEATURE. THERE MAY BE
	CHANGES TO THIS FUNCTIONS IN THE FUTURE.
]]
module.PrintCache = function(): nil
	print(cache)
	return nil
end

-- Function: Gets the "depth" of <root>.
module.GetHierarchyDepth = function(root: Instance, allow_cache: boolean?): number
	assert(isInstance(root), `Failed to compute \`.GetHierarchyDepth()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	
	if allow_cache then
		local cached = SearchCache(root, "GetHierarchyDepth", root)
		if cached then
			return cached
		end
	end
	
	local res = 0
	while root.Parent do
		res += 1
		root = root.Parent
	end
	
	if allow_cache then
		PopulateCache(root, "GetHierarchyDepth", root, res)
	end
	return res
end

-- Function: Gets the full directory path of <root>, except it is returned as an array.
module.GetFullNameAsStringArray = function(root: Instance, allow_cache: boolean?): {string}
	assert(isInstance(root), `Failed to compute \`.GetFullNameAsStringArray()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	
	if allow_cache then
		local cached = SearchCache(root, "GetFullNameAsStringArray", root)
		if cached then
			return cached
		end
	end
	
	local res: {string} = {}
	while root.Parent do
		table.insert(res, root.Name)
		root = root.Parent
	end
	
	if allow_cache then
		PopulateCache(root, "GetFullNameAsStringArray", root, res)
	end
	return res
end

-- Function: Gets the full directory path of <root>, except it is returned as an Instance array.
module.GetFullNameAsInstancesArray = function(root: Instance, allow_cache: boolean?): {Instance}
	assert(isInstance(root), `Failed to compute \`.GetFullNameAsInstancesArray()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	
	if allow_cache then
		local cached = SearchCache(root, "GetFullNameAsInstancesArray", root)
		if cached then
			return cached
		end
	end
	
	local res: {Instance} = {}
	while root.Parent do
		table.insert(res, root)
		root = root.Parent
	end
	
	if allow_cache then
		PopulateCache(root, "GetFullNameAsInstancesArray", root, res)
	end
	return res
end

--[[
	Function: Attempt to find the first instance that satisfies <name>.
	This function uses built-in `:GetDescendants()` on the service part of the string.
]]
module.FindFirstInstance_GD = function(name: string | {string}, allow_cache: boolean?): Instance?
	local is_str = isString(name::string)
	local is_tbl = typeof(name) == "table"
	
	assert(is_str or is_tbl, `Failed to compute \`.FindFirstInstance_GD()\` function. Expected <string> or <\{string}> type for <name> (arg #1), got <{typeof(name)}>.`)
	
	local service
	if is_tbl then
		name = name :: {string}
		if rawlen(name) == 1 then
			local target = game:FindService(rawget(name, 1)::string)
			if allow_cache then
				PopulateCache(name, "FindFirstInstance_GD", name, target)
			end
			return target
		end
		
		service = game:FindService(rawget(name, rawlen(name))::string)
		
		local new = ""
		for idx = rawlen(name), 1, -1 do
			new ..= rawget(name, idx) :: string
		end
		name = new
		
	else
		name = name :: string
		service = game:FindService(name:split(".")[1])
	end
	name = name :: string
	
	if allow_cache then
		local cached = SearchCache(name, "FindFirstInstance_GD", name)
		if cached then
			return cached
		end
	end
	
	for _, instance in service:GetDescendants() do
		if instance:GetFullName() == name then
			if allow_cache then
				PopulateCache(name, "FindFirstInstance_GD", name, instance,
					instance.AncestryChanged:Once(function()
						KillCachedResult(name)
					end),
					
					instance.Destroying:Once(function()
						KillCachedResult(name)
					end)
				)
			end
			return instance
		end
	end
	
	return nil
end

--[[
	Function: Attempt to find the first instance that satisfies <name>.
	This function uses an iterative solution for Depth-first Search.
]]
module.FindFirstInstance_IterDFS = function(name: string | {string}, allow_cache: boolean?): Instance?
	local is_str = isString(name::string)
	local is_tbl = typeof(name) == "table"
	
	assert(is_str or is_tbl, `Failed to compute \`.FindFirstInstance_IterDFS()\` function. Expected <string> or <\{string}> type for <name> (arg #1), got <{typeof(name)}>.`)
	
	local cache_key
	if is_str then
		if allow_cache then
			local cached = SearchCache(name, "FindFirstInstance_IterDFS", name)
			if cached then
				return cached
			end
			cache_key = name
		end
		name = string.split(name::string, ".")
		
	else
		name = name :: {string}
		local l, r = 1, rawlen(name)
		while l < r do
			local temp_l, temp_r = rawget(name, l) :: string, rawget(name, r) :: string
			
			rawset(name, l, temp_r)
			rawset(name, r, temp_l)
		end
		
		if allow_cache then
			cache_key = table.concat(name, ".")
			local cached = SearchCache(cache_key, "FindFirstInstance_IterDFS", cache_key)
			if cached then
				return cached
			end
		end
	end
	name = name :: {string}
	
	if rawlen(name) == 1 then
		return game:FindService(rawget(name, 1)::string)
	end
	
	local dp: {{string}} = {}
	
	-- Every 1st index, it is the Instance to search through.
	-- Every 2nd index, it is the starting dp string index to match.
	-- Every 3rd index, it is the ending dp string index to match.
	local stack: {Instance | number} = {
		game:FindService(rawget(name, 1)::string),
		2,
		2
	}
	
	while #stack > 0 do
		local current_root = stack[#stack - 2] :: Instance
		local left_str_idx = stack[#stack - 1] :: number
		local right_str_idx = stack[#stack] :: number
		
		table.remove(stack)
		table.remove(stack)
		table.remove(stack)
		
		if not dp[left_str_idx] then
			dp[left_str_idx] = {}
			dp[left_str_idx][left_str_idx] = name[left_str_idx]
		end
		
		if not dp[left_str_idx][right_str_idx] then
			dp[left_str_idx][right_str_idx] = dp[left_str_idx][right_str_idx - 1] .. "." .. name[right_str_idx]
		end
		
		local current_toFind = dp[left_str_idx][right_str_idx]
		local found = false
		
		for _, child in current_root:GetChildren() do
			if child.Name == current_toFind then
				if right_str_idx == #name then
					if allow_cache then
						PopulateCache(cache_key, "FindFirstInstance_IterDFS", cache_key, child,
							child.AncestryChanged:Once(function()
								KillCachedResult(cache_key)
							end),
							
							child.Destroying:Once(function()
								KillCachedResult(cache_key)
							end)
						)
					end
					return child
				end
				
				table.insert(stack, child)
				table.insert(stack, right_str_idx + 1)
				table.insert(stack, right_str_idx + 1)
				found = true
			end
		end
		
		if not found and right_str_idx < #name then
			table.insert(stack, current_root)
			table.insert(stack, left_str_idx)
			table.insert(stack, right_str_idx + 1)
		end
	end
	
	return nil
end

--[[
	Function: Attempt to find the first instance that satisfies <name>.
	This function uses a recursive solution for Depth-first Search.
]]
module.FindFirstInstance_RecurDFS = function(name: string | {string}, allow_cache: boolean?): Instance?
	local is_str = isString(name::string)
	local is_tbl = typeof(name) == "table"
	
	assert(is_str or is_tbl, `Failed to compute \`.FindFirstInstance_RecurDFS()\` function. Expected <string> or <\{string}> type for <name> (arg #1), got <{typeof(name)}>.`)
	
	local cache_key
	if is_str then
		if allow_cache then
			local cached = SearchCache(name, "FindFirstInstance_RecurDFS", name)
			if cached then
				return cached
			end
			cache_key = name
		end
		name = string.split(name::string, ".")
		
	else
		name = name :: {string}
		local l, r = 1, rawlen(name)
		while l < r do
			local temp_l, temp_r = rawget(name, l) :: string, rawget(name, r) :: string
			
			rawset(name, l, temp_r)
			rawset(name, r, temp_l)
		end
		
		if allow_cache then
			cache_key = table.concat(name, ".")
			local cached = SearchCache(cache_key, "FindFirstInstance_RecurDFS", cache_key)
			if cached then
				return cached
			end
		end
	end
	name = name :: {string}
	
	local function helper(curr_instance: Instance, curr_name: string, idx: number): Instance?
		if idx == rawlen(name) then
			if curr_instance.Name == curr_name then
				if allow_cache then
					PopulateCache(cache_key, "FindFirstInstance_RecurDFS", cache_key, curr_instance,
						curr_instance.AncestryChanged:Once(function()
							KillCachedResult(cache_key)
						end),
						
						curr_instance.Destroying:Once(function()
							KillCachedResult(cache_key)
						end)
					)
				end
				return curr_instance
			end
			
		else
			for _, instance in curr_instance:GetChildren() do
				if instance.Name == curr_name then
					local result = helper(instance, rawget(name::{string}, idx + 1)::string, idx + 1)
					
					if result then
						return result
					end
				end
			end
		end
		
		return nil
	end
	
	local service = game:FindService(rawget(name, 1)::string)
	return helper(service, rawget(name, 2)::string, 2)
end

-- Function: Attempts to find the first descendant that satisfy the parameters.
module.FindFirstDescendant = function(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?, allow_cache: boolean?): Instance?
	assert(isInstance(root), `Failed to compute \`.FindFirstDescendant()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	assert(isString(target), `Failed to compute \`.FindFirstDescendant()\` function. Expected <string> type for <target> (arg #2), got <{typeof(target)}>.`)
	
	if allow_cache then
		local cached = SearchCache(root, "FindFirstDescendant", {target, depth, if mode then mode else "default"})
		if cached then
			return cached
		end
	end
	
	local found = nil
	
	-- Custom iterative solution implementation of `:FindFirstDescendantOfClass()`.
	if mode == "class" then
		for _, instance in root:GetDescendants() do
			if instance.ClassName == target then
				found = instance
				break
			end
		end
		
	elseif mode == "inherit" then
		found = root:FindFirstChildWhichIsA(target, true)
		
	else
		mode = "default"
		found = root:FindFirstChild(target, true)
	end
	
	if not found then
		return nil
	end
	
	if isNumber(depth::number) then
		depth = depth :: number
		
		if depth > 0 then
			for _ = 1, depth do
				found = found.Parent
			end
		end
	end
	
	found = found :: Instance
	
	if allow_cache then
		PopulateCache(root, "FindFirstDescendant", {target, depth, mode}, found,
			found.AncestryChanged:Once(function()
				KillCachedResult(root)
			end),
			
			found.Destroying:Once(function()
				KillCachedResult(root)
			end)
		)
	end
	return found
end

-- Function: Attempts to find the first ancestor that satisfy the parameters.
module.FindFirstAncestor = function(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?, allow_cache: boolean?): Instance?
	assert(isInstance(root), `Failed to compute \`.FindFirstAncestor()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	assert(isString(target), `Failed to compute \`.FindFirstAncestor()\` function. Expected <string> type for <target> (arg #2), got <{typeof(target)}>.`)
	
	if allow_cache then
		local cached = SearchCache(root, "FindFirstAncestor", {target, depth, if mode then mode else "default"})
		if cached then
			return cached
		end
	end
	
	local found = nil
	
	if mode == "class" then
		found = root:FindFirstAncestorOfClass(target)
		
	elseif mode == "inherit" then
		found = root:FindFirstAncestorWhichIsA(target)
		
	else
		mode = "default"
		found = root:FindFirstAncestor(target)
	end
	
	if not found then
		return nil
	end
	
	if isNumber(depth::number) then
		depth = depth :: number
		
		if depth > 0 then
			for _ = 1, depth do
				found = found.Parent
			end
			
		elseif depth < 0 then
			-- Explanation: Find `iter` in the equation `target_depth - depth = root_depth - iter`.
			local offset = 0
			local temp = root
			while temp ~= found do
				temp = temp.Parent
				offset += 1
			end
			
			local iter = offset + depth
			if iter < 0 then
				return found
			end
			
			for _ = 1, iter do
				root = root.Parent :: Instance
			end
			return root
			
		end
	end
	
	found = found :: Instance
	
	if allow_cache then
		PopulateCache(root, "FindFirstAncestor", {target, depth, mode}, found,
			found.AncestryChanged:Once(function()
				KillCachedResult(root)
			end),
			
			found.Destroying:Once(function()
				KillCachedResult(root)
			end)
		)
	end
	
	return found
end

-- Function: Verify if <root> is the ancestor of <target>.
module.IsAncestorOf = function(root: Instance, target: Instance, depth: number?, allow_cache: boolean?): (boolean, Instance?)
	assert(isInstance(root), `Failed to compute \`.IsAncestorOf()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	assert(isInstance(target), `Failed to compute \`.IsAncestorOf()\` function. Expected <Instance> type for <target> (arg #2), got <{typeof(target)}>.`)
	
	if allow_cache then
		local cached = SearchCache(root, "IsAncestorOf", {target, depth})
		if cached then
			return table.unpack(cached::{any})
		end
	end
	
	if root:IsAncestorOf(target) then
		if isNumber(depth::number) then
			depth = depth :: number
			
			if depth == 0 then
				if allow_cache then
					PopulateCache(root, "IsAncestorOf", {target, 0}, {true, target},
						target.AncestryChanged:Once(function()
							KillCachedResult(root)
						end),
						
						target.Destroying:Once(function()
							KillCachedResult(root)
						end)
					)
				end
				return true, target
				
			elseif depth > 0 then
				for _ = 1, depth do
					target = target.Parent :: Instance
				end
				
				if allow_cache then
					PopulateCache(root, "IsAncestorOf", {target, depth}, {true, target},
						target.AncestryChanged:Once(function()
							KillCachedResult(root)
						end),
						
						target.Destroying:Once(function()
							KillCachedResult(root)
						end)
					)
				end
				
				return true, target
			end
		end
		
		if allow_cache then
			PopulateCache(root, "IsAncestorOf", {target, nil}, {true, nil},
				target.AncestryChanged:Once(function()
					KillCachedResult(root)
				end),
				
				target.Destroying:Once(function()
					KillCachedResult(root)
				end)
			)
		end
		return true, nil
	end
	
	return false, nil
end

-- Function: Verify if <root> is the descendant of <target>.
module.IsDescendantOf = function(root: Instance, target: Instance, depth: number?, allow_cache: boolean?): (boolean, Instance?)
	assert(isInstance(root), `Failed to compute \`.IsDescendantOf()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	assert(isInstance(target), `Failed to compute \`.IsDescendantOf()\` function. Expected <Instance> type for <target> (arg #2), got <{typeof(target)}>.`)
	
	if allow_cache then
		local cached = SearchCache(root, "IsDescendantOf", {target, depth})
		if cached then
			return table.unpack(cached::{any})
		end
	end
	
	if root:IsDescendantOf(target) then
		if isNumber(depth::number) then
			depth = depth :: number
			
			if depth == 0 then
				if allow_cache then
					PopulateCache(root, "IsDescendantOf", {target, 0}, {true, target},
						target.AncestryChanged:Once(function()
							KillCachedResult(root)
						end),
						
						target.Destroying:Once(function()
							KillCachedResult(root)
						end)
					)
				end
				return true, target
				
			elseif depth > 0 then
				for _ = 1, depth do
					target = target.Parent :: Instance
				end
				if allow_cache then
					PopulateCache(root, "IsDescendantOf", {target, depth}, {true, target},
						target.AncestryChanged:Once(function()
							KillCachedResult(root)
						end),
						
						target.Destroying:Once(function()
							KillCachedResult(root)
						end)
					)
				end
				return true, target
				
			elseif depth < 0 then
				-- Explanation: Find `iter` from the equation `target_depth - depth = root_depth - iter`.
				local offset = 0
				local temp = root
				while temp ~= target do
					temp = temp.Parent
					offset += 1
				end
				
				local iter = offset + depth
				if iter < 0 then
					return true, nil
				end
				
				for _ = 1, iter do
					root = root.Parent :: Instance
				end
				if allow_cache then
					PopulateCache(root, "IsDescendantOf", {target, depth}, {true, root})
				end
				return true, root
			end
		end
		
		return true, nil
	end
	
	return false, nil
end

return module
