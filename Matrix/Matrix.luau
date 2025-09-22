--!strict

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

-- This function is from the TypeCheck module.
local function isString(candidate: string): boolean
	return typeof(candidate) == "string"
end

-- This function is from the TypeCheck module.
local function isNumber(candidate: number): boolean
	if typeof(candidate) ~= "number" then
		return false
	end
	
	if candidate ~= candidate or math.abs(candidate) == math.huge then
		return false
	end
	
	return true
end

local function isMatrix(candidate: Matrix): boolean
	if getmetatable(candidate)::string ~= "Matrix" then
		return false
	end
	
	if typeof(candidate._size) ~= "table" or #candidate._size ~= 2 then
		return false
	end
	
	if typeof(candidate._entries) ~= "table" then
		return false
	end
	
	local m, n = candidate._size[1], candidate._size[2]
	
	if not isNumber(m) or not isNumber(n) then
		return false
	end
	
	local totalSize = 0
	for i = 1, m do
		if typeof(candidate._entries[i]) ~= "table" then
			return false
		end
		
		for j = 1, n do
			if not isNumber(candidate._entries[i][j]) then
				return false
			end
			
			totalSize += 1
		end
	end
	
	return totalSize == m * n
end

local function _isSquareMatrix(candidate: Matrix): boolean
	if getmetatable(candidate)::string ~= "Matrix" then
		return false
	end
	
	if typeof(candidate._size) ~= "table" or #candidate._size ~= 2 then
		return false
	end
	
	if typeof(candidate._entries) ~= "table" then
		return false
	end
	
	local m, n = candidate._size[1], candidate._size[2]
	
	if not isNumber(m) or not isNumber(n) then
		return false
	end
	
	if m ~= n then
		return false
	end
	
	local totalSize = 0
	for i = 1, m do
		if typeof(candidate._entries[i]) ~= "table" then
			return false
		end
		
		for j = 1, n do
			if not isNumber(candidate._entries[i][j]) then
				return false
			end
			
			totalSize += 1
		end
	end
	
	return totalSize == m * n
end

local function isStaticMatrix(candidate: StaticMatrix): boolean
	if getmetatable(candidate) ~= "StaticMatrix" then
		return false
	end
	
	if typeof(candidate._size) ~= "table" or #candidate._size ~= 2 then
		return false
	end
	
	if typeof(candidate._entries) ~= "table" then
		return false
	end
	
	local m, n = candidate._size[1], candidate._size[2]
	
	if not isNumber(m) or not isNumber(n) then
		return false
	end
	
	local total_size = m * n
	
	if #candidate._entries ~= total_size then
		return false
	end
	
	for i = 1, total_size do
		if not isNumber(candidate._entries[i]) then
			return false
		end
	end
	
	return true
end

local function isDynamicMatrix(candidate: DynamicMatrix): boolean
	if getmetatable(candidate) ~= "DynamicMatrix" then
		return false
	end
	
	-- TODO: Implement this check function.
	-- Checks if _size exists and only includes numbers as elements (check this during looping through the _entries).
	-- Checks if _entries exists:
		-- Only includes numbers for the last layer.
		-- Only includes tables of tables/numbers for other layers.
	-- Checks if it correctly identified the last layer using the length of _size table.
	
	if typeof(candidate._size) ~= "table" then
		return false
	end
	
	if typeof(candidate._entries) ~= "table" then
		return false
	end
	
	return true
end


-- ** CONSTRUCTORS ** --

module.new = function(name: "Matrix" | "StaticMatrix" | "DynamicMatrix", fill: number, ...: number): (Matrix | StaticMatrix | DynamicMatrix)?
	assert(isString(name))
	
	local axes = {...}
	
	fill = if isNumber(fill::number) or name == "DynamicMatrix" then fill::number else 0
	
	if name == "Matrix" then
		local m, n = axes[1], axes[2]
		
		assert(isNumber(m))
		assert(isNumber(n))
		
		local new_row = table.create(n, fill)
		local new_entries = table.create(m, new_row)
		
		local res = {}
		res._entries = new_entries
		res._size = {m, n}
		return setmetatable(res, matrix) :: Matrix
		
	elseif name == "StaticMatrix" then
		local m, n = axes[1], axes[2]
		
		assert(isNumber(m))
		assert(isNumber(n))
		
		local res = {}
		res._entries = table.create(m * n, fill)
		res._size = {m, n}
		return setmetatable(res, static) :: StaticMatrix
		
	elseif name == "DynamicMatrix" then
		local entry: {} | number = fill
		
		for idx = #axes, 1, -1 do
			assert(isNumber(axes[idx]))
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

matrix.addrow = function(self: Matrix, m: number, fill: number, ignore_OOB: boolean?): boolean
	assert(isMatrix(self))
	assert(isNumber(m))
	
	fill = if isNumber(fill) then fill else 0
	
	local size_m, size_n = self._size[1], self._size[2]
	local idx = 0
	if ignore_OOB then
		idx = math.clamp(m, 1, size_m + 1)
		
	else
		assert(1 <= m and m <= size_m + 1)
		idx = m
	end
	
	table.insert(self._entries, idx, table.create(size_n, fill))
	self._size[1] += 1
	return true
end

matrix.clrrow = function(self: Matrix, m: number, ignore_OOB: boolean?): {number}
	assert(isMatrix(self))
	assert(isNumber(m))
	
	local size_m = self._size[1]
	local idx = 0
	if ignore_OOB then
		idx = math.clamp(m, 1, size_m)
		
	else
		assert(1 <= m and m <= size_m)
		idx = m
	end
	
	self._size[1] -= 1
	return table.remove(self._entries, idx) :: any
end

matrix.addcol = function(self: Matrix, n: number, fill: number, ignore_OOB: boolean?): boolean
	assert(isMatrix(self))
	assert(isNumber(n))
	
	fill = if isNumber(fill) then fill else 0
	
	local size_m, size_n = self._size[1], self._size[2]
	local idx = 0
	if ignore_OOB then
		idx = math.clamp(n, 1, size_n)
		
	else
		assert(1 <= n and n <= size_n + 1)
		idx = n
	end
	
	for i = 1, size_m do
		table.insert(self._entries[i], idx, fill)
	end
	
	self._size[2] += 1
	return true
end

matrix.clrcol = function(self: Matrix, n: number, ignore_OOB: boolean?): {number}
	assert(isMatrix(self))
	assert(isNumber(n))
	
	local size_m, size_n = self._size[1], self._size[2]
	local idx = 0
	if ignore_OOB then
		idx = math.clamp(n, 1, size_n)
		
	else
		assert(1 <= n and n <= size_n + 1)
		idx = n
	end
	
	local ret = {}
	for i = 1, size_m do
		local element = table.remove(self._entries[i], idx) :: number
		table.insert(ret, element)
	end
	
	return ret
end

matrix.getsize = function(self: Matrix): {number}
	assert(isMatrix(self))
	
	return self._size
end

matrix.setsize = function(self: Matrix, m: number, n: number, fill: number): boolean
	assert(isMatrix(self))
	
	fill = if isNumber(fill) then fill else 0
	
	local prev_m, prev_n = table.unpack(self._size)
	
	if m < prev_m then
		for i = m + 1, prev_m do
			self._entries[i] = nil
		end
	end
	
	for i = 1, m do
		if i > prev_m then
			local new_col = table.create(n, fill)
			local new_row = table.create(m, new_col)
			table.move(new_row, 1, #new_row, prev_m, self._entries)
			break
		else
			if n < prev_n then
				for j = n + 1, prev_n do
					self._entries[i][j] = nil
				end
				
			elseif n > prev_n then
				for j = n + 1, prev_n do
					self._entries[i][j] = fill
				end
			end
		end
	end
	
	self._size[1] = m
	self._size[2] = n
	
	return true
end

matrix.getentry = function(self: Matrix, m: number, n: number): number
	assert(isMatrix(self))
	assert(isNumber(m))
	assert(isNumber(n))
	
	return self._entries[m][n]
end

matrix.setentry = function(self: Matrix, value: number, m: number, n: number): boolean
	assert(isMatrix(self))
	assert(isNumber(value))
	assert(isNumber(m))
	assert(isNumber(n))
	
	self._entries[m][n] = value
	return true
end

matrix.transpose = function(self: Matrix): Matrix
	assert(isMatrix(self))
	
	local m, n = self._size[1], self._size[2]
	local new = {}
	new._entries = {}
	new._size = {n, m}
	
	for i = 1, m do
		new._entries[i] = {}
		for j = 1, n do
			new._entries[i][j] = self._entries[j][i]
		end
	end
	
	return setmetatable(new, matrix)
end


-- ** MATRIX - METATABLE ** --

matrix.__index = matrix

matrix.__metatable = "Matrix"

matrix.__add = function(a: Matrix, b: Matrix): Matrix
	assert(isMatrix(a))
	assert(isMatrix(b))
	
	local size_a = a._size
	local size_b = b._size
	
	assert(#size_a == #size_b)
	assert(size_a[1] == size_b[1])
	assert(size_a[2] == size_b[2])
	
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
	local isnum_A, ismatrix_A = isNumber(a::number), isMatrix(a::Matrix)
	local isnum_B, ismatrix_B = isNumber(b::number), isMatrix(b::Matrix)
	
	assert(isnum_A or ismatrix_A)
	assert(isnum_B or ismatrix_B)
	
	if isnum_A or isnum_B then
		if isnum_A then
			a, b = b, a
		end
		
		a = a :: Matrix
		b = b :: number
		
		local size_A = a._size
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
		
		local size_A = a._size
		local size_B = b._size
		
		assert(#size_A == #size_B)
		assert(size_A[2] == size_B[1])
		
		local m, p = size_A[1], size_B[2]
		
		local new = {}
		new._entries = {}
		new._size = {m, p}
		
		for i = 1, m do
			new._entries[i] = {}
			for j = 1, p do
				local res = 0
				
				for r = 1, p do
					res += a._entries[i][r] * b._entries[r][j]
				end
				new._entries[i][j] = res
			end
		end
		
		return setmetatable(new, matrix)
	end
end


-- ** STATIC MATRIX OBJECT ** --
-- ** STATIC MATRIX - METHODS ** --

static.getsize = function(self: StaticMatrix): {number}
	assert(isStaticMatrix(self))
	
	return self._size
end

static.getentry = function(self: StaticMatrix, m: number, n: number): number
	assert(isStaticMatrix(self))
	assert(isNumber(m))
	assert(isNumber(n))
	
	local size_n = self._size[2]
	local idx = size_n * (m - 1) + n
	return self._entries[idx]
end

static.setentry = function(self: StaticMatrix, value: number, m: number, n: number): boolean
	assert(isStaticMatrix(self))
	assert(isNumber(value))
	assert(isNumber(m))
	assert(isNumber(n))
	
	local size_n = self._size[2]
	local idx = size_n * (m - 1) + n
	self._entries[idx] = value
	return true
end

static.transpose = function(self: StaticMatrix): StaticMatrix
	assert(isStaticMatrix(self))
	
	local m, n = self._size[1], self._size[2]
	local new = {}
	new._entries = table.create(m * n, 0)
	new._size = {n, m}
	
	for i = 1, n do
		for j = 1, m do
			local i_j = m * (i - 1) + j
			local j_i = n * (j - 1) + i
			new._entries[i_j] = self._entries[j_i]
		end
	end
	
	return setmetatable(new, static)
end

-- ** STATIC MATRIX - METATABLE ** --

static.__index = static

static.__metatable = "StaticMatrix"

static.__add = function(a: StaticMatrix, b: StaticMatrix): StaticMatrix
	assert(isStaticMatrix(a))
	assert(isStaticMatrix(b))
	
	local size_a = a._size
	local size_b = b._size
	
	assert(#size_a == #size_b)
	assert(size_a[1] == size_b[1])
	assert(size_a[2] == size_b[2])
	
	local m, n = size_a[1], size_a[2]
	
	local new = {}
	new._entries = table.create(m * n, 0)
	new._size = {m, n}
	
	for idx = 1, m * n do
		new._entries[idx] = a._entries[idx] + b._entries[idx]
	end
	
	return setmetatable(new, static)
end

static.__sub = function(a: StaticMatrix, b: StaticMatrix): StaticMatrix
	return a + (-1)*b
end

static.__mul = function(a: StaticMatrix | number, b: StaticMatrix | number): StaticMatrix
	local isnum_A, ismatrix_A = isNumber(a::number), isStaticMatrix(a::StaticMatrix)
	local isnum_B, ismatrix_B = isNumber(b::number), isStaticMatrix(b::StaticMatrix)
	
	assert(isnum_A or ismatrix_A)
	assert(isnum_B or ismatrix_B)
	
	if isnum_A or isnum_B then
		if isnum_A then
			a, b = b, a
		end
		
		a = a :: StaticMatrix
		b = b :: number
		
		local size_A = a._size
		local m, n = size_A[1], size_A[2]
		
		local new = {}
		new._entries = table.create(m * n, 0)
		new._size = {m, n}
		
		for idx = 1, m * n do
			new._entries[idx] = a._entries[idx] * b
		end
		
		return setmetatable(new, static)
		
	else
		a = a :: StaticMatrix
		b = b :: StaticMatrix
		
		local size_A = a._size
		local size_B = b._size
		
		assert(#size_A == #size_B)
		assert(size_A[2] == size_B[1])
		
		local m, n, p = size_A[1], size_A[2], size_B[2]
		
		local new = {}
		new._entries = table.create(m * p, 0)
		new._size = {m, p}
		
		for i = 1, m * p do
			local val = 0
			local row = (i - 1) % p + 1
			local col = (i - 1) // p + 1
			
			-- TODO: test function
			for j = 1, n do
				val += a._entries[row * n + j] * b._entries[row * j + col]
			end
			
			new._entries[i] = val
		end
		
		return setmetatable(new, static)
	end
end

-- ** DYNAMIC MATRIX OBJECT ** --
-- ** DYNAMIC MATRIX - METHODS ** --

dynamic.getsize = function(self: DynamicMatrix): {number}
	assert(isDynamicMatrix(self))
	
	return self._size
end

dynamic.getentry = function(self: DynamicMatrix, ...: number): number?
	assert(isDynamicMatrix(self))
	
	local axes = {...}
	local res = self._entries[axes[1]] :: {any}
	
	if #axes ~= #self._size then
		return nil
	end
	
	for i = 2, #axes do
		assert(isNumber(axes[i]))
		res = res[axes[i]]
	end
	
	return res :: number
end

-- ** DYNAMIC MATRIX - METATABLE ** --

dynamic.__index = dynamic

dynamic.__metatable = "DynamicMatrix"

return module