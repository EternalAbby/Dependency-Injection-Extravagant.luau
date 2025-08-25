--!strict

local TypeCheck = require("../TypeCheck/TypeCheck")

local module = {}

local matrix = {}
local static = {}
local dynamic = {}

-- 2-dimension static matrix (?)
export type Matrix = {
	{number}
}

-- 2-dimension matrix, but stored as a 1-dimension array (?)
export type StaticMatrix = {
	number
}

-- N-dimension dynamic matrix (?)
-- maybe this special type shouldn't be able to use operations like normal matrix, manual read/write only)
export type DynamicMatrix = {
	DynamicMatrix | number
}

-- create a matrix object
module.new = function(m: number, n: number): Matrix
	assert(TypeCheck.isNumber(m, false))
	assert(TypeCheck.isNumber(n, false))
	
	local res = {}
	
	for i = 1, m do
		res[i] = {}
		for j = 1, n do
			res[i][j] = 0
		end
	end
	
	return setmetatable(res, matrix)
end

-- create a static matrix object
module.newStatic = function(m: number, n: number): StaticMatrix
	return setmetatable(table.create(m * n, 0), static)
end

-- create a dynamic matrix object
module.newDynamic = function(...: number): DynamicMatrix
	local axes = {...}
	local res = {}
	
	-- TODO: test function
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


-- ** Matrix - Metatable ** --

matrix.__index = matrix

matrix.__metatble = "Matrix"

matrix.__add = function()
	
end

matrix.__mul = function()
	
end

matrix.__pow = function()
	
end

-- ** Static Matrix - Metatable ** --

static.__index = static

static.__metatable = "Static_Matrix"

static.__add = function()
	
end


-- ** Dynamic Matrix - Metatable ** --

dynamic.__index = dynamic

dynamic.__newindex = function()
	
end

dynamic.__metatable = "Dynamic_Matrix"

return module