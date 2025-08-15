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
	
	-- FIXME: Currently, the algorithm only searches through 1 "valid" path in either cases. If it fails, it will return `nil`.
	-- The problem arises when there are multiple instances with the same name, and only *1* has the correct result. The algorithm
	-- may miss the correct path at any given point, and falsely invalidates the solution.
	-- Solution: Implement an approach to search through all possible paths.
	if isString then
		name = name :: string
		
		local split = name.split(".")
		local currentRoot = game:FindService(split[1])
		local currentChild = split[2]
		local idx = 2
		
		while idx <= #split do
			local child = currentRoot:FindFirstChild(currentChild)
			
			if child then
				currentRoot = child
				currentChild = split[idx + 1]
				
			elseif idx + 1 <= #split then
				currentChild ..= split[idx + 1]
			end
			
			idx += 1
		end
		
		return if not currentChild then currentRoot else nil
		
	elseif isArray then
		name = name :: {string}
		
		local current = game:FindService(name[#name])
		
		for idx = #name - 1, 1, -1 do
			current = current:FindFirstChild(name[idx])
			
			if not current then
				return nil
			end
		end
		
		return current
	end
	
	return nil
end

-- Returns the first descendant using the parameters.
module.FindFirstDescendant = function(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?): Instance?
	assert(TypeCheck.isInstance(root))
	assert(TypeCheck.isString(target))
	
	local found = nil
	
	if mode == "class" then
		-- FIXME: This is a temporary solution for a custom `:FindFirstDescendantOfClass()` implementation.
		-- Because this is a recursive solution, it may cause stack overflow due to function calls.
		-- Please change to an iterative solution.
		local function FindDescendant(cur_root: Instance): Instance?
			local classname = cur_root.ClassName
			
			if classname == target then
				return cur_root
			end
			
			local children = cur_root:GetChildren()
			
			if #children > 0 then
				for _, child in children do
					local found_descendant = FindDescendant(child)
					
					if found_descendant then
						return found_descendant
					end
				end
			end
			
			return nil
		end
		
		found = FindDescendant(root)
		
	elseif mode == "inherit" then
		-- FIXME: Same as above, this is a temporary solution for a custom `:FindFirstDescendantWhichIsA()` implementation.
		-- Please change to an iterative solution.
		local function FindDescendant(cur_root: Instance): Instance?
			if cur_root:IsA(target) then
				return cur_root
			end
			
			local children = cur_root:GetChildren()
			
			if #children > 0 then
				for _, child in children do
					local found_descendant = FindDescendant(child)
					
					if found_descendant then
						return found_descendant
					end
				end
			end
			
			return nil
		end
		
		found = FindDescendant(root)
		
	else
		found = root:FindFirstDescendant(target)
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
