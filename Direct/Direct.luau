--!strict

-- this module helps with the directory path of instances
-- extends functionality from the original built-in functions
-- not recommended to use over the usual built-in unless functionalities are needed

local TypeCheck = require("../TypeCheck./TypeCheck")

local module = {}

module.GetHierarchy = function(root: Instance): number
	assert(root)
	
	local res = 0
	
	while root.Parent do
		res += 1
		root = root.Parent
	end
	
	return res
end

module.GetFullName = function(root: Instance, property: string?): {any}
	assert(root)
	
	local res = {}
	
	if property then
		while root.Parent do
			table.insert(res, root[property])
			root = root.Parent
		end
		
		return res
		
	else
		while root.Parent do
			table.insert(res, root)
			root = root.Parent
		end
		
		return res
	end
end

module.FindFirstAncestor = function(root: Instance, ancestor: string): (boolean, number?)
	assert(root)
	assert(ancestor)
	
	local directoryPath = module.GetFullName(root, "Name")
	local depth = table.find(directoryPath, ancestor)
	
	if depth then
		return true, depth
	end
	
	return false, nil
end

module.FindFirstInstanceByFullName = function()
	
end

module.FindFirstInstanceByFullNameString = function(name: string): Instance?
	local split = string.split(name, ".")
	local currentRoot = game:FindService(split[1])
	local currentChild = split[2]
	local idx = 2
	
	while idx <= #split do
		local child = currentRoot:FindFirstChild(currentChild)
		
		if child then
			currentRoot = child
			currentChild = split[idx + 1]
			
		elseif idx + 1 <= #split then
			currentChild ..= "." .. split[idx + 1]
		end
		
		idx += 1
	end
	
	return if not currentChild then currentRoot else nil
end

module.IsDescendentOf = function(root: Instance, ancestor: Instance, depth: number?): (boolean, Instance?)
	assert(root, `Parameter <root> (arg #1) is not provided.`)
	assert(ancestor, `Parameter <ancestor> (arg #2) is not provided.`)
	
	if root:IsDescendantOf(ancestor) then
		if depth and TypeCheck.isNumber(depth) then
			local root_directory = module.GetFullName(root)
			local ancestor_depth = module.GetHierarchy(ancestor)
			
			local idx = ancestor_depth + depth + 1
			
			return true, root_directory[idx]
		else
			return true, nil
		end
	end
	
	return false, nil
end

return module