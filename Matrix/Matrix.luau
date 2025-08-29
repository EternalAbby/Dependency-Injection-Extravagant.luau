--!strict

local TypeCheck = require("../TypeCheck/TypeCheck")

local module = {}

local matrix = {}
local static = {}
local dynamic = {}

-- This type is used for a 2D matrix, used in math.
export type Matrix = setmetatable<{
	["_entries"]: {[number]: {number}},
	["_size"]: {[number]: number}
}, typeof(matrix)>

-- This type is used for a 2D matrix, but stored as a 1D array, and size cannot be changed.
export type StaticMatrix = setmetatable<{
	number
}, typeof(static)>

-- This type is used to create a N-dimension matrix. Can only do manual read/write. Module built-in only helps with changing sizes.
export type DynamicMatrix = setmetatable<{
	DynamicMatrix | number
}, typeof(dynamic)>


-- ** INTERNAL FUNCTIONS ** --


local function Matrix_GetNumberComponentTypes(candidate: Matrix | number): (boolean, boolean)
	return TypeCheck.isNumber(candidate::number), TypeCheck.isMatrix(candidate::Matrix)
end

local function Static_GetNumberComponentTypes(candidate: StaticMatrix | number): (boolean, boolean)
	return TypeCheck.isNumber(candidate::number), TypeCheck.isStaticMatrix(candidate::StaticMatrix)
end

local function Dynamic_GetNumberComponentTypes(candidate: DynamicMatrix | number): (boolean, boolean)
	return TypeCheck.isNumber(candidate::number), TypeCheck.isDynamicMatrix(candidate::DynamicMatrix)
end
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
				res._entries[i][j] = fill
			end
		end
		
		return setmetatable(res, matrix) :: Matrix
		
	elseif name == "StaticMatrix" then
		local m, n = axes[1], axes[2]
		
		assert(TypeCheck.isNumber(fill, true))
		assert(TypeCheck.isNumber(m, false))
		assert(TypeCheck.isNumber(n, false))
		
		local res = table.create(m * n, fill)
		return setmetatable(res, static) :: StaticMatrix
		
	elseif name == "DynamicMatrix" then
		local res = {}
		
		local function helper(cur_arr: {[number]: {} | number}, cur_idx: number): {} | number
			if cur_idx == #axes then
				return table.create(axes[cur_idx], fill)
			end
			
			for idx = 1, axes[cur_idx] do
				cur_arr[idx] = helper({}, cur_idx + 1)
			end
			
			return cur_arr
		end
		
		return setmetatable(helper(res, 1) :: {}, dynamic) :: DynamicMatrix
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

-- FIXME: This may be a bug with the Luau LSP extension. (?)
-- `TypeCheck` module uses a different type for these objects, which causes the Luau LSP to throw a false-positive type error.
-- The type error doesn't happen on Studio. Only happens because of the vsc extension.
-- This `__metatable`, along with the ones in other objects, have to be type casted so that the type error doesn't happen.
-- This code comment and type cast *may* be removed later, as it serves no purpose other than not causing the type error.
-- Possible fix: Move the type checking into this module instead.
matrix.__metatable = "Matrix" :: "Matrix"

matrix.__add = function(a: Matrix, b: Matrix): Matrix
	local size_a = a:getsize()
	local size_b = b:getsize()
	
	assert(#size_a == #size_b)
	
	for i, size in size_a do
		assert(size ~= size_b[i])
	end
	
	local m, n = size_a[1], size_a[2]
	
	local new = {}
	new._entries = {}
	new._size = {m, n}
	
	for i = 1, size_a[1] do
		new._entries[i] = {}
		for j  = 1, size_a[2] do
			new._entries[i][j] = a._entries[i][j] + b._entries[i][j]
		end
	end
	
	return setmetatable(new, matrix)
end

matrix.__sub = function(a: Matrix, b: Matrix): Matrix
	return a + (-1)*b
end

matrix.__mul = function(a: Matrix | number, b: Matrix | number): Matrix
	local isnum_A, ismatrix_A = Matrix_GetNumberComponentTypes(a)
	local isnum_B, ismatrix_B = Matrix_GetNumberComponentTypes(b)
	
	assert(isnum_A or ismatrix_A)
	assert(isnum_B or ismatrix_B)
	
	if isnum_A or isnum_B then
		if isnum_A then
			a, b = b, a
		end
		
		a = a :: Matrix
		b = b :: number
		
		local size_A = a:getsize()
		local m, n = size_A[1], size_A[2]
		
		local new = {}
		new._entries = {}
		new._size = {m, n}
		
		for i = 1, m do
			new._entries[i] = {}
			for j = 1, n do
				new._entries[i][j] = a._entries[i][j] * b
			end
		end
		
		return setmetatable(new, matrix)
		
	else
		a = a :: Matrix
		b = b :: Matrix
		
		local size_A = a:getsize()
		local size_B = b:getsize()
		
		assert(#size_A == #size_B)
		assert(size_A[2] == size_B[1])
		
		local m, n, p = size_A[1], size_A[2], size_B[3]
		
		local new = {}
		new._entries = {}
		new._size = {m, p}
		
		-- TODO: test function
		for i = 1, m do
			new._entries[i] = {}
			for j = 1, p do
				for k = 1, n do
					new._entries[i][j] = a._entries[i][k] * b._entries[k][j]
				end
			end
		end
		
		return setmetatable(new, matrix)
	end
end


-- ** STATIC MATRIX OBJECT ** --
-- ** STATIC MATRIX - METATABLE ** --

static.__index = static

static.__metatable = "StaticMatrix" :: "StaticMatrix"


-- ** DYNAMIC MATRIX OBJECT ** --
-- ** DYNAMIC MATRIX - METATABLE ** --

dynamic.__index = dynamic

dynamic.__metatable = "DynamicMatrix" :: "DynamicMatrix"

return module