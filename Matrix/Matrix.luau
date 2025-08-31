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
	["_entries"]: {[number]: number},
	["_size"]: {[number]: number}
}, typeof(static)>

type RepeatingEntry = {RepeatingEntry | number}

-- This type is used to create a N-dimension matrix. Can only do manual read/write. Module built-in only helps with changing sizes.
export type DynamicMatrix = setmetatable<{
	["_entries"]: RepeatingEntry,
	["_size"]: {[number]: number}
}, typeof(dynamic)>


-- ** INTERNAL FUNCTIONS ** --

local function isMatrix(candidate: Matrix): boolean
	if getmetatable(candidate) ~= "Matrix" then
		return false
	end
	
	if #candidate._size ~= 2 then
		return false
	end
	
	local m, n = candidate._size[1], candidate._size[2]
	
	for i = 1, m do
		for j = 1, n do
			if not candidate._entries[i] or not candidate._entries[i][j] or not TypeCheck.isNumber(candidate._entries[i][j], false) then
				return false
			end
		end
	end
	
	return true
end

local function isStaticMatrix(candidate: StaticMatrix): boolean
	if getmetatable(candidate) ~= "StaticMatrix" then
		return false
	end
	
	if #candidate._size ~= 2 then
		return false
	end
	
	local m, n = candidate._size[1], candidate._size[2]
	local total_size = m * n
	
	if #candidate._entries ~= total_size then
		return false
	end
	
	for i = 1, total_size do
		if not TypeCheck.isNumber(candidate._entries[i], false) then
			return false
		end
	end
	
	return true
end

local function isDynamicMatrix(candidate: DynamicMatrix): boolean
	if getmetatable(candidate) ~= "DynamicMatrix" then
		return false
	end
	
	return true
end

local function Matrix_GetNumberComponentTypes(candidate: Matrix | number): (boolean, boolean)
	return TypeCheck.isNumber(candidate::number), isMatrix(candidate::Matrix)
end

local function Static_GetNumberComponentTypes(candidate: StaticMatrix | number): (boolean, boolean)
	return TypeCheck.isNumber(candidate::number), isStaticMatrix(candidate::StaticMatrix)
end

local function Dynamic_GetNumberComponentTypes(candidate: DynamicMatrix | number): (boolean, boolean)
	return TypeCheck.isNumber(candidate::number), isDynamicMatrix(candidate::DynamicMatrix)
end


-- ** CONSTRUCTORS ** --

module.new = function(name: "Matrix" | "StaticMatrix" | "DynamicMatrix", fill: number?, ...: number): (Matrix | StaticMatrix | DynamicMatrix)?
	assert(TypeCheck.isString(name))
	
	fill = if TypeCheck.isNumber(fill::number, false) then fill::number else 0
	
	local axes = {...}
	
	if name == "Matrix" then
		local m, n = axes[1], axes[2]
		
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
		-- TODO: redo this object type
		local m, n = axes[1], axes[2]
		
		assert(TypeCheck.isNumber(m, false))
		assert(TypeCheck.isNumber(n, false))
		
		local res = table.create(m * n, fill)
		return setmetatable(res, static) :: StaticMatrix
		
	elseif name == "DynamicMatrix" then
		local entry: {} | number = fill
		
		for idx = #axes, 1, -1 do
			assert(TypeCheck.isNumber(axes[idx], false))
			entry = table.create(axes[idx], entry)
		end
		
		local res = {}
		res._entries = entry
		res._size = axes
		return setmetatable(res, dynamic) :: DynamicMatrix
	end
	
	return nil
end


-- ** MATRIX OBJECT ** --
-- ** MATRIX - METHODS ** --
matrix.getsize = function(self: Matrix): {number}
	return self._size
end

matrix.getentry = function(self: Matrix, m: number, n: number): number
	return self._entries[m][n]
end

matrix.transpose = function(self: Matrix): Matrix
	local m, n = self._size[1], self._size[2]
	local new = module.new("Matrix", 0, n, m)::Matrix
	
	for i = 1, m do
		for j = 1, n do
			new._entries[j][i] = self._entries[i][j]
		end
	end
	
	return new
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
-- ** STATIC MATRIX - METHODS ** --

static.getsize = function(self: StaticMatrix): {number}
	return self._size
end

static.getentry = function(self: StaticMatrix, m: number, n: number): number
	local size_n = self._size[2]
	local idx = size_n * (m - 1) + n
	return self._entries[idx]
end


-- ** STATIC MATRIX - METATABLE ** --

static.__index = static

static.__metatable = "StaticMatrix"


-- ** DYNAMIC MATRIX OBJECT ** --
-- ** DYNAMIC MATRIX - METHODS ** --

dynamic.getsize = function(self: DynamicMatrix): {number}
	return self._size
end

dynamic.getentry = function(self: DynamicMatrix, ...: number): number?
	local axes = {...}
	local res = self._entries[axes[1]] :: {any}
	
	if #axes ~= #self._size then
		return nil
	end
	
	for i = 2, #axes do
		res = res[axes[i]]
	end
	
	return res :: number
end

-- ** DYNAMIC MATRIX - METATABLE ** --

dynamic.__index = dynamic

dynamic.__metatable = "DynamicMatrix"

return module