--!strict

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

local module = {}

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

-- Function: Gets the "depth" of <root>.
module.GetHierarchyDepth = function(root: Instance, ignore_cache: boolean?): number
	assert(isInstance(root), `Failed to compute \`.GetHierarchyDepth()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	
	if not ignore_cache then
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
	
	if not ignore_cache then
		PopulateCache(root, "GetHierarchyDepth", root, res)
	end
	return res
end

-- Function: Gets the full directory path of <root>, except it is returned as an array.
module.GetFullNameAsStringArray = function(root: Instance, ignore_cache: boolean?): {string}
	assert(isInstance(root), `Failed to compute \`.GetFullNameAsStringArray()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	
	if not ignore_cache then
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
	
	if not ignore_cache then
		PopulateCache(root, "GetFullNameAsStringArray", root, res)
	end
	return res
end

-- Function: Gets the full directory path of <root>, except it is returned as an Instance array.
module.GetFullNameAsInstancesArray = function(root: Instance, ignore_cache: boolean?): {Instance}
	assert(isInstance(root), `Failed to compute \`.GetFullNameAsInstancesArray()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	
	if not ignore_cache then
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
	
	if not ignore_cache then
		PopulateCache(root, "GetFullNameAsInstancesArray", root, res)
	end
	return res
end

-- Function: Attempts to find the first instance that satisfy <name>.
module.FindFirstInstance = function(name: string | {string}, ignore_cache: boolean?): Instance?
	local is_str = isString(name::string)
	local is_tbl = typeof(name) == "table"
	
	assert(is_str or is_tbl, `Failed to compute \`.FindFirstInstance()\` function. Expected <string> or <\{string}> type for <name> (arg #1), got <{typeof(name)}>.`)
	
	if not ignore_cache then
		local cached = SearchCache(name, "FindFirstInstance", name)
		if cached then
			return cached
		end
	end
	
	if is_str then
		name = string.split(name::string, ".")
	end
	
	name = name :: {string}
	
	if #name == 1 then
		return game:FindService(name[1])
	end
	
	local dp: {{string}} = {}
	
	-- Every 1st index, it is the Instance to search through.
	-- Every 2nd index, it is the starting dp string index to match.
	-- Every 3rd index, it is the ending dp string index to match.
	local stack: {Instance | number} = {
		game:FindService(name[1]),
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
		
		local current_tofind = dp[left_str_idx][right_str_idx]
		local found = false
		
		for _, child in current_root:GetChildren() do
			if child.Name == current_tofind then
				if right_str_idx == #name then
					if not ignore_cache then
						PopulateCache(name, "GetFullNameAsInstancesArray", name, child,
							child.AncestryChanged:Once(function()
								KillCachedResult(name)
							end),
							
							child.Destroying:Once(function()
								KillCachedResult(name)
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

-- Function: Attempts to find the first descendant that satisfy the parameters.
module.FindFirstDescendant = function(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?, ignore_cache: boolean?): Instance?
	assert(isInstance(root), `Failed to compute \`.FindFirstDescendant()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	assert(isString(target), `Failed to compute \`.FindFirstDescendant()\` function. Expected <string> type for <target> (arg #2), got <{typeof(target)}>.`)
	
	if not ignore_cache then
		local cached = SearchCache(root, "FindFirstDescendant", {target, depth, if mode then mode else "default"})
		if cached then
			return cached
		end
	end
	
	local found = nil
	
	-- Custom iterative solution implementation of `:FindFirstDescendantOfClass()`.
	if mode == "class" then
		local stack: {Instance} = root:GetChildren()
		
		while #stack > 0 do
			if stack[#stack].ClassName == target then
				found = stack[#stack]
				break
			end
			
			local cur_root = stack[#stack]
			local children = cur_root:GetChildren()
			
			table.remove(stack)
			table.move(children, 1, #children, #stack, stack)
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
	
	if not ignore_cache then
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
module.FindFirstAncestor = function(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?, ignore_cache: boolean?): Instance?
	assert(isInstance(root), `Failed to compute \`.FindFirstAncestor()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	assert(isString(target), `Failed to compute \`.FindFirstAncestor()\` function. Expected <string> type for <target> (arg #2), got <{typeof(target)}>.`)
	
	if not ignore_cache then
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
	
	if not ignore_cache then
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
module.IsAncestorOf = function(root: Instance, target: Instance, depth: number?, ignore_cache: boolean?): (boolean, Instance?)
	assert(isInstance(root), `Failed to compute \`.IsAncestorOf()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	assert(isInstance(target), `Failed to compute \`.IsAncestorOf()\` function. Expected <Instance> type for <target> (arg #2), got <{typeof(target)}>.`)
	
	if not ignore_cache then
		local cached = SearchCache(root, "IsAncestorOf", {target, depth})
		if cached then
			return table.unpack(cached::{any})
		end
	end
	
	if root:IsAncestorOf(target) then
		if isNumber(depth::number) then
			depth = depth :: number
			
			if depth == 0 then
				if not ignore_cache then
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
				
				if not ignore_cache then
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
		
		if not ignore_cache then
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
module.IsDescendantOf = function(root: Instance, target: Instance, depth: number?, ignore_cache: boolean?): (boolean, Instance?)
	assert(isInstance(root), `Failed to compute \`.IsDescendantOf()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	assert(isInstance(target), `Failed to compute \`.IsDescendantOf()\` function. Expected <Instance> type for <target> (arg #2), got <{typeof(target)}>.`)
	
	if not ignore_cache then
		local cached = SearchCache(root, "IsDescendantOf", {target, depth})
		if cached then
			return table.unpack(cached::{any})
		end
	end
	
	if root:IsDescendantOf(target) then
		if isNumber(depth::number) then
			depth = depth :: number
			
			if depth == 0 then
				if not ignore_cache then
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
				if not ignore_cache then
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
				if not ignore_cache then
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
