--!strict

local TypeCheck = require("../TypeCheck/TypeCheck")

local module = {}

-- Returns the depth of <root>. A "depth" is defined to be how deep <root> is from the DataModel <game>.
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

-- Returns an array of Instances, starting from <root> to the service ancestor of <root>.
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

-- Returns the first Instance that was found by using <name>.
module.FindFirstInstance = function(name: string | {string}): Instance?
	local isString = TypeCheck.isString(name::string)
	local isArray = TypeCheck.isArray(name::{string})
	
	assert(isString or isArray)
	
	if isString then
		name = name :: string
		
		local split = string.split(name, ".")
		
		-- using dynamic programming to compute all enumerations of split
		-- this may be a bottleneck if the instance is found on 1 path and all other enumerations are unused
		-- consider caching when iterating instead
		local dp: {{string}} = {}
		
		for i = 2, #split do
			dp[i] = {}
			dp[i][i] = split[i]
			
			for j = i + 1, #split do
				dp[i][j] = dp[i][j - 1] .. split[j]
			end
		end
		
		type stackElement = {
			["Instance"]: Instance,
			["Start"]: number,
			["End"]: number
		}
		
		local root_children = game:FindService(split[1]):GetChildren()
		local stack: {stackElement} = {}
		
		for _, child in root_children do
			table.insert(stack, {
				child,
				2,
				2
			})
		end
		
		while #stack > 0 do
			local current = stack[#stack]
			local current_root = current["Instance"]
			local current_tofind = dp[current["Start"]][current["End"]]
			
			for _, child in current_root:GetChildren() do
				if child.Name == current_tofind then
					table.insert(stack, {
						child,
						current["End"] + 1,
						current["End"] + 1
					})
				end
			end
		end
		
		-- FIXME: temp recursive solution
		--[[
		local function FindInstance(root: Instance, tofind: string, idx: number): Instance?
			if idx == #split then
				return if root.Name == tofind then root else nil
			end
			
			local children = root:GetChildren()
			local found = nil
			
			for _, child in children do
				if child.Name == tofind then
					found = FindInstance(child, split[idx + 1], idx + 1)
					
					if found then
						return found
					end
				end
			end
			
			return FindInstance(root, tofind .. "." .. split[idx + 1], idx + 1)
		end
		
		local root = game:FindService(split[1])
		return FindInstance(root, split[2], 2)
		]]
	elseif isArray then
		name = name :: {string}
		
		-- FIXME: temp recursive solution
		local function FindInstance(root: Instance, tofind: string, idx: number): Instance?
			if idx == #name then
				if root.Name == tofind then
					return root
				else
					return nil
				end
			end
			
			local children = root:GetChildren()
			local tofind_next = (name::{string})[idx + 1]
			local found = nil
			
			for _, child in children do
				if child.Name == tofind then
					found = FindInstance(child, tofind_next, idx + 1)
					
					if found then
						return found
					end
				end
			end
			
			return FindInstance(root, tofind .. "." .. tofind_next, idx + 1)
		end
		
		local root = game:FindService(name[1])
		return FindInstance(root, name[2], 2)
	end
	
	return nil
end

-- Returns the first descendant using the parameters.
module.FindFirstDescendant = function(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?): Instance?
	assert(TypeCheck.isInstance(root))
	assert(TypeCheck.isString(target))
	
	local found = nil
	
	-- Custom implementation of `:FindFirstDescendantOfClass()`.
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
	
	if depth then
		local target_directory = module.GetFullNameAsInstancesArray(found)
		local target_depth = #target_directory
		local idx = target_depth + depth + 1
		
		return target_directory[idx]
	end
	
	return found
end

-- Returns the first ancestor using the parameters.
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
	
	if depth then
		local root_directory = module.GetFullNameAsInstancesArray(root)
		local target_depth = module.GetHierarchyDepth(found)
		local idx = target_depth + depth + 1
		
		return root_directory[idx]
	end
	
	return found
end

-- Returns a boolean if it's true, and an instance if depth is specified.
module.IsAncestorOf = function(root: Instance, target: Instance, depth: number?): (boolean, Instance?)
	assert(TypeCheck.isInstance(root), `Failed to compute \`.IsAncestorOf()\` function. Expected <Instance> type for <root>, got <{typeof(root)}>.`)
	assert(TypeCheck.isInstance(target), `Failed to compute \`.IsAncestorOf()\` function. Expected <Instance> type for <target>, got <{typeof(target)}>.`)
	
	if root:IsAncestorOf(target) then
		if depth and TypeCheck.isNumber(depth) then
			local target_directory = module.GetFullNameAsInstancesArray(target)
			local target_depth = #target_directory
			local idx = target_depth + depth + 1
			
			return true, target_directory[idx]
		end
		
		return true, nil
	end
	
	return false, nil
end

-- Returns a boolean if it's true, and an instance if depth is specified.
module.IsDescendantOf = function(root: Instance, target: Instance, depth: number?): (boolean, Instance?)
	assert(TypeCheck.isInstance(root), `Failed to compute \`.IsDescendantOf()\` function. Expected <Instance> type for <root>, got <{typeof(root)}>.`)
	assert(TypeCheck.isInstance(target), `Failed to compute \`.IsDescendantOf()\` function. Expected <Instance> type for <target>, got <{typeof(target)}>.`)
	
	if root:IsDescendantOf(target) then
		if depth and TypeCheck.isNumber(depth) then
			local root_directory = module.GetFullNameAsInstancesArray(root)
			local target_depth = module.GetHierarchyDepth(target)
			local idx = target_depth + depth + 1
			
			return true, root_directory[idx]
		end
		
		return true, nil
	end
	
	return false, nil
end

return module
