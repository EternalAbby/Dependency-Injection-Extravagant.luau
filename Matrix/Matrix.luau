--!strict

local TypeCheck = require("../TypeCheck/TypeCheck")

local module = {}

local matrix = {}
local static = {}
local dynamic = {}

-- 2-dimension static matrix (?)
export type Matrix = setmetatable<{
	["_entries"]: {[number]: {number}},
	["_size"]: {number}
}, typeof(matrix)>

-- 2-dimension matrix, but stored as a 1-dimension array (?)
export type StaticMatrix = {
	number
}

-- N-dimension dynamic matrix (?)
-- maybe this special type shouldn't be able to use operations like normal matrix, manual read/write only)
export type DynamicMatrix = {
	DynamicMatrix | number
}

-- ** CONSTRUCTORS ** --

module.new = function(name: "Matrix" | "StaticMatrix" | "DynamicMatrix", fill: number, ...: number): (Matrix | StaticMatrix | DynamicMatrix)?
	assert(TypeCheck.isString(name))
	
	local axes = {...}
	
	if name == "Matrix" then
		local m, n = axes[1], axes[2]
		
		assert(TypeCheck.isNumber(fill, true))
		assert(TypeCheck.isNumber(m, false))
		assert(TypeCheck.isNumber(n, false))
		
		local res = {}
		res._entries = {}
		res._size = {m, n}
		
		for i = 1, m do
			res._entries[i] = {}
			for j = 1, n do
				res._entries[i][j] = 0
			end
		end
		
		return setmetatable(res, matrix) :: Matrix
		
	elseif name == "StaticMatrix" then
		local m, n = axes[1], axes[2]
		
		assert(TypeCheck.isNumber(fill, true))
		assert(TypeCheck.isNumber(m, false))
		assert(TypeCheck.isNumber(n, false))
		
		local res = table.create(m * n, fill)
		return setmetatable(res, static)
		
	elseif name == "DynamicMatrix" then
		local res = {}
		
		-- TODO: helper function
		local function helper(cur_arr: DynamicMatrix, cur_idx: number): DynamicMatrix | {number}
			if cur_idx == #axes then
				return table.create(axes[cur_idx], 0) :: {number}
			end
			
			for _ = 1, axes[cur_idx] do 
				local newAxis = {}
				helper(newAxis, cur_idx + 1)
			end
			
			return cur_arr
		end
		
		return setmetatable(helper(res, 1) :: DynamicMatrix, dynamic)
	end
		
	return nil
end



-- ** MATRIX OBJECT ** --
-- ** MATRIX - METHODS ** --
matrix.getsize = function(self: Matrix): {number}
	return self._size
end

-- ** MATRIX - METATABLE ** --

matrix.__index = matrix

matrix.__metatable = "Matrix"

matrix.__add = function(a: Matrix, b: Matrix): Matrix
	local size_a = a:getsize()
	local size_b = b:getsize()
	
	assert(#size_a == #size_b)
	
	for i, size in size_a do
		assert(size ~= size_b[i])
	end
	
	local new = {}
	new._entries = {}
	new._size = {size_a[1], size_a[2]}
	
	for i = 1, size_a[1] do
		new._entries[i] = {}
		for j  = 1, size_a[2] do
			new._entries[i][j] = a._entries[i][j] + b._entries[i][j]
		end
	end
	
	return setmetatable(new, matrix)
end

matrix.__mul = function()
	
end

matrix.__pow = function()
	
end


-- ** STATIC MATRIX OBJECT ** --
-- ** STATIC MATRIX - METATABLE ** --

static.__index = static

static.__metatable = "Static_Matrix"

static.__add = function()
	
end

-- ** DYNAMIC MATRIX OBJECT ** --
-- ** DYNAMIC MATRIX - METATABLE ** --

dynamic.__index = dynamic

dynamic.__newindex = function()
	
end

dynamic.__metatable = "Dynamic_Matrix"

return module