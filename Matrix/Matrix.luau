--!strict

local TypeCheck = require("../TypeCheck/TypeCheck")

local module = {}

-- 2-dimension static matrix
export type Matrix = {
	{number}
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
	
	return res
end

-- matrix addition
module.__add = function()
	-- TBA
end

-- scalar multiplication and matrix multiplication
module.__mul = function()
	-- TBA
end

-- ??? many operations could use this
module.__pow = function()
	-- TBA
end

return module