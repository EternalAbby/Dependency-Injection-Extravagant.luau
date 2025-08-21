--!strict

local TypeCheck = require("../TypeCheck/TypeCheck")

local module = {}

-- This type is used for the `.FindFirstInstance()` function.
type FFI_StackElement = {
	["Instance"]: Instance,
	["Start"]: number,
	["End"]: number
}

--[[
Function: Gets the "depth" of <root>. This is not cached.
A "depth" is defined to be a layer into an Instance.
The total "depth" of an instance is how deep <root> is from the Datamodel "game".
Returns the "depth".
]]
module.GetHierarchyDepth = function(root: Instance): number
	assert(TypeCheck.isInstance(root), `Failed to compute \`.GetHierarchyDepth()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	
	root = root :: Instance
	
	local res = 0
	
	while root.Parent do
		res += 1
		root = root.Parent
	end
	
	return res
end

--[[
Function: Gets the full directory path of <root>, except it is returned as an array. This is not cached.
In Luau, arrays are 1-indexed, so the first element of the returned array, <root>, is at index 1.
Every subsequent ancestor is at the next index. Stops at the service provider, before the Datamodel "game".
Returns the string array.
]]
module.GetFullNameAsStringArray = function(root: Instance): {string}
	assert(TypeCheck.isInstance(root), `Failed to compute \`.GetFullNameAsStringArray()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	
	root = root :: Instance
	
	local res: {string} = {}
	
	while root.Parent do
		table.insert(res, root.Name)
		root = root.Parent
	end
	
	return res
end

--[[
Function: Gets the full directory path of <root>, except it is returned as an Instance array. This is not cached.
In Luau, arrays are 1-indexed, so the first element of the returned array, <root>, is at index 1.
Every subsequent ancestor is at the next index. Stops at the service provider, before the Datamodel "game".
Returns the instances array.
]]
module.GetFullNameAsInstancesArray = function(root: Instance): {Instance}
	assert(TypeCheck.isInstance(root), `Failed to compute \`.GetFullNameAsInstancesArray()\` function. Expected <Instance> type for <root> (arg #1), got <{typeof(root)}>.`)
	
	root = root :: Instance
	
	local res: {Instance} = {}
	
	while root.Parent do
		table.insert(res, root)
		root = root.Parent
	end
	
	return res
end

--[[
Function: Attempts to find the first instance that satisfy <name>. This is not cached.
<name> can either be in the format from `Instance:GetFullName()` (built-in), or from `module.GetFullNameAsInstancesArray()` (module)
Return the first instance to satisfy <name>. If failed, returns `nil`.
]]
module.FindFirstInstance = function(name: string | {string}): Instance?
	-- FIXME: Although this function has been made into an iterative solution, it still performs slower than its recursive counterpart.
	-- The bottleneck may be caused from the stack filling operations (specifically, the for loop inside of the main while loop).
	-- Additionally, these are the only main differences between the iterative solution, and the recursive one;
	--		1. Iterative loops over every children of the "current_root".
	--		2. Iterative creates a new data dictionary for each child.
	--		3. Iterative adds those data to the "stack".
	-- Out of all of these differences, 1. may be impacting the most for average time complexity, which is necessary to optimize,
	-- as the recursive solution does not have to go through every children before going to the next depth, so performance are lost
	-- when there are too many children.
	
	local isString = TypeCheck.isString(name::string)
	local isArray = TypeCheck.isArray(name::{string})
	
	assert(isString or isArray)
	
	if isString then
		name = string.split(name::string, ".")
	end
	
	name = name :: {string}
	
	if #name == 1 then
		return game:FindService(name[1])
	end
	
	local dp: {{string}} = {}
	dp[1] = {name[1]}
	
	local stack: {FFI_StackElement} = {{
		["Instance"] = game:FindService(name[1]),
		["Start"] = 2,
		["End"] = 2
	}}
	
	while #stack > 0 do
		local current = stack[#stack]
		table.remove(stack)
		
		local current_root = current["Instance"]
		local current_children = current_root:GetChildren()
		local current_start = current["Start"]
		local current_end = current["End"]
		
		local current_tofind = nil
		if not dp[current_start] then
			dp[current_start] = {}
			dp[current_start][current_start] = name[current_start]
		end
		
		if not dp[current_start][current_end] then
			dp[current_start][current_end] = dp[current_start][current_end - 1] .. "." .. name[current_end]
		end
		current_tofind = dp[current_start][current_end]		
		
		if #current_children == 0 or current["End"] == #name then
			if current_root.Name == current_tofind then
				return current_root
			end
		end
		
		local found = false
		
		-- FIXME: This loop may be the bottleneck of the iterative solution
		-- for slower performance than the recursive solution.
		for _, child in current_children do
			if child.Name == current_tofind then
				if current["End"] == #name then
					return child
				end
				
				local data = {
					["Instance"] = child,
					["Start"] = current["End"] + 1,
					["End"] = current["End"] + 1
				}
				
				table.insert(stack, data)
				found = true
			end
		end
		
		if not found and current["End"] < #name then
			current["End"] += 1
			table.insert(stack, current)
		end
	end
	
	return nil
end

--[[
Function: Attempts to find the first descendant that satisfy the parameters. This is not cached.
<root> is the starting instance.
<target> is the target value to search for by the function.
<depth> is the offset from the found descendant.
<mode> is what behavior type the function should perform when searching for the descendant. By default, the "default" option is used, which is similar to `Instance:FindFirstChild(..., true)` (built-in).
]]
module.FindFirstDescendant = function(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?): Instance?
	assert(TypeCheck.isInstance(root))
	assert(TypeCheck.isString(target))
	
	local found = nil
	
	-- Custom iterative solution implementation of `:FindFirstDescendantOfClass()`.
	if mode == "class" then
		local stack: {Instance} = root:GetChildren()
		
		while #stack > 0 do
			if mode == "class" and stack[#stack].ClassName == target then
				found = stack[#stack]
				break
			end
			
			local cur_root = assert(table.remove(stack)) -- bleh
			local children = cur_root:GetChildren()
			
			table.move(children, 1, #children, #stack, stack)
		end
		
	elseif mode == "inherit" then
		found = root:FindFirstChildWhichIsA(target, true)
		
	else
		found = root:FindFirstChild(target, true)
	end
	
	if not found then
		return nil
	end
	
	depth = depth :: number
	
	if TypeCheck.isNumber(depth, false) then
		if depth > 0 then
			for _ = 1, depth do
				found = found.Parent
			end
		end
	end
	
	return found
end

--[[
Function: Attempts to find the first ancestor that satisfy the parameters. This is not cached.
<root> is the starting instance.
<target> is the target value to search for by the function.
<depth> is the offset from the found ancestor.
<mode> is what behavior type the function should perform when searching for the ancestor. By default, the "default" option is used, which is similar to `Instance:FindFirstAncestor(...)` (built-in).
]]
module.FindFirstAncestor = function(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?): Instance?
	assert(TypeCheck.isInstance(root))
	assert(TypeCheck.isString(target))
	
	local found = nil
	
	if mode == "class" then
		found = root:FindFirstAncestorOfClass(target)
		
	elseif mode == "inherit" then
		found = root:FindFirstAncestorWhichIsA(target)
		
	else
		found = root:FindFirstAncestor(target)
	end
	
	if not found then
		return nil
	end
	
	depth = depth :: number
	
	if TypeCheck.isNumber(depth, false) then
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
	
	return found
end

--[[
Function: Verify if <root> is the ancestor of <target>.
<root> is the starting instance.
<target> is the suspecting ancestor of <root>.
<depth> is the offset from the found ancestor. By default, this behavior is not activated, and does not return the 2nd value. <depth> of 0 returns <root>.
Returns a boolean to determine whether <root> is the ancestor of <target>, and an Instance that the offset from the <target>, if <depth> is provided.
]]
module.IsAncestorOf = function(root: Instance, target: Instance, depth: number?): (boolean, Instance?)
	assert(TypeCheck.isInstance(root), `Failed to compute \`.IsAncestorOf()\` function. Expected <Instance> type for <root>, got <{typeof(root)}>.`)
	assert(TypeCheck.isInstance(target), `Failed to compute \`.IsAncestorOf()\` function. Expected <Instance> type for <target>, got <{typeof(target)}>.`)
	
	if root:IsAncestorOf(target) then
		if depth and TypeCheck.isNumber(depth, false) then
			if depth == 0 then
				return true, target
				
			elseif depth > 0 then
				for _ = 1, depth do
					target = target.Parent :: Instance
				end
				
				return true, target
			end
		end
		
		return true, nil
	end
	
	return false, nil
end

--[[
Function: Verify if <root> is the descendant of <target>.
<root> is the starting instance.
<target> is the suspecting descendant of <root>.
<depth> is the offset from the found descendant. By default, this behavior is not activated, and does not return the 2nd value. <depth> of 0 returns <root>.
Returns a boolean to determine whether <root> is the descendant of <target>, and an Instance that the offset from the <target>, if <depth> is provided.
]]
module.IsDescendantOf = function(root: Instance, target: Instance, depth: number?): (boolean, Instance?)
	assert(TypeCheck.isInstance(root), `Failed to compute \`.IsDescendantOf()\` function. Expected <Instance> type for <root>, got <{typeof(root)}>.`)
	assert(TypeCheck.isInstance(target), `Failed to compute \`.IsDescendantOf()\` function. Expected <Instance> type for <target>, got <{typeof(target)}>.`)
	
	if root:IsDescendantOf(target) then
		if depth and TypeCheck.isNumber(depth, false) then
			if depth == 0 then
				return true, target
				
			elseif depth > 0 then
				for _ = 1, depth do
					target = target.Parent :: Instance
				end
				return true, target
				
			elseif depth < 0 then
				-- Explanation: Find `iter` in the equation `target_depth - depth = root_depth - iter`.
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
				return true, root
			end
		end
		
		return true, nil
	end
	
	return false, nil
end

return module
