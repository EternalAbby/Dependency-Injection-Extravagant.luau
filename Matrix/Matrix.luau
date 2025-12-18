--!strict
--!optimize 2
--!native

-- TODO: [VERSION 1.1.0] Implement row operations for `StaticMatrix` objects.
-- TODO: [VERSION 1.1.0] Implement special operations that are valid for Square Matrix for `StaticMatrix` objects.
-- TODO: [VERSION 1.1.0] Add function descriptions.
-- TODO: [VERSION 1.1.0] [?] Update Wiki.

-- TODO: [VERSION 1.2.0] Allow object interactions.
-- TODO: [VERSION 1.2.0] Implement operations on `Tensor`.
-- TODO: [VERSION 1.2.0] Implement logical matrix, aka (0,1)-matrix, used in boolean algebra.
-- TODO: [VERSION 1.2.0] [?] Implement data compression via serialize/deserialize functions.


-- INTERNAL VARIABLE --

local matrix_index: Matrix_Method = {} :: Matrix_Method
local matrix_meta: Matrix_Meta = {} :: Matrix_Meta

local static_index: StaticMatrix_Method = {} :: StaticMatrix_Method
local static_meta: StaticMatrix_Meta = {} :: StaticMatrix_Meta

local tensor_index: Tensor_Method = {} :: Tensor_Method
local tensor_meta: Tensor_Meta = {} :: Tensor_Meta


-- TYPE DEFINITION --

type SizeProperty = {[number]: number}
type FillParameter = number | {number}

type Matrix_EntriesProperty = {[number]: {number}}
type Matrix_FillParameter = number | Matrix_EntriesProperty

type Matrix_Method = {
	add_row: (self: Matrix, m: number, fill: FillParameter?, clamped: boolean?) -> nil,
	clr_row: (self: Matrix, m: number, clamped: boolean?) -> {number},
	add_col: (self: Matrix, n: number, fill: FillParameter?, clamped: boolean?) -> nil,
	clr_col: (self: Matrix, n: number, clamped: boolean?) -> {number},
	
	row_add: (self: Matrix, at: number, with: number) -> nil,
	row_mul: (self: Matrix, at: number, with: number) -> nil,
	row_switch: (self: Matrix, at: number, with: number) -> nil,
	
	sq_diagonal: (self: Matrix) -> Matrix,
	sq_lower_triangular: (self: Matrix) -> Matrix,
	sq_upper_triangular: (self: Matrix) -> Matrix,
	
	transpose: (self: Matrix) -> Matrix,
	
	get_size: (self: Matrix) -> SizeProperty,
	set_size: (self: Matrix, m: number, n: number, fill: number?) -> nil,
	
	get_entry: (self: Matrix, m: number, n: number) -> number,
	set_entry: (self: Matrix, value: number, m: number, n: number) -> nil
}
type Matrix_Meta = {
	__index: Matrix_Method,
	__metatable: "Matrix",
	
	__add: (a: Matrix, b: Matrix) -> Matrix,
	__sub: (a: Matrix, b: Matrix) -> Matrix,
	__mul: (a: Matrix | number, b: Matrix | number) -> Matrix
}
export type Matrix = setmetatable<{
	entries: Matrix_EntriesProperty,
	size: SizeProperty
}, Matrix_Meta>


type StaticMatrix_EntriesProperty = {[number]: number}
type StaticMatrix_FillParameter = number | StaticMatrix_EntriesProperty

type StaticMatrix_Method = {
	transpose: (self: StaticMatrix) -> StaticMatrix,
	
	get_size: (self: StaticMatrix) -> SizeProperty,
	
	get_entry: (self: StaticMatrix, m: number, n: number) -> number,
	set_entry: (self: StaticMatrix, value: number, m: number, n: number) -> nil
}
type StaticMatrix_Meta = {
	__index: StaticMatrix_Method,
	__metatable: "Static",
	
	__add: (a: StaticMatrix, b: StaticMatrix) -> StaticMatrix,
	__sub: (a: StaticMatrix, b: StaticMatrix) -> StaticMatrix,
	__mul: (a: StaticMatrix | number, b: StaticMatrix | number) -> StaticMatrix
}
export type StaticMatrix = setmetatable<{
	entries: StaticMatrix_EntriesProperty,
	size: SizeProperty
}, StaticMatrix_Meta>


type Tensor_EntriesProperty = {Tensor_EntriesProperty | number}
type Tensor_FillParameter = number | Tensor_EntriesProperty

type Tensor_Method = {
	get_size: (self: StaticMatrix) -> SizeProperty,
	
	get_entry: (self: StaticMatrix, m: number, n: number) -> number,
	set_entry: (self: StaticMatrix, value: number, m: number, n: number) -> nil
}
type Tensor_Meta = {
	__index: Tensor_Method,
	__metatable: "Tensor"
}
export type Tensor = setmetatable<{
	entries: Tensor_EntriesProperty,
	size: SizeProperty
}, Tensor_Meta>

type Module = {
	newMatrix: (fill: Matrix_FillParameter, m: number, n: number) -> Matrix,
	newStaticMatrix: (fill: StaticMatrix_FillParameter, m: number, n: number) -> StaticMatrix,
	newTensor: (fill: Tensor_FillParameter, ...number) -> Tensor,
	
	identityMatrix: (n: number) -> Matrix,
	identityStaticMatrix: (n: number) -> StaticMatrix
}


-- HELPER FUNCTION --

local function isNumber(candidate: number)
	return type(candidate) == "number" and math.isfinite(candidate)
end

-- A very loose surface check for `Matrix` objects. Only checks for data type of object and properties and the metatable. Does not check further into the `.entries` property.
local function isPossibleMatrix(candidate: Matrix): boolean
	return type(candidate) == "table" and getmetatable(candidate) == "Matrix" and type(candidate.entries) == "table" and type(candidate.size) == "table"
end

-- A very loose surface check for `StaticMatrix` objects. Only checks for data type of object and properties and the metatable. Does not check further into the `.entries` property.
local function isPossibleStaticMatrix(candidate: StaticMatrix): boolean
	return type(candidate) == "table" and getmetatable(candidate) == "StaticMatrix" and type(candidate.entries) == "table" and type(candidate.size) == "table"
end

-- A very loose surface check for a candidate object represented as a square matrix.
local function isPossibleSquareMatrix(candidate: Matrix | StaticMatrix): boolean
	return candidate.size[1] == candidate.size[2]
		and #candidate.entries == candidate.size[1]
end

local function ThrowTypeError(expected_type: string, arg_name: string, arg_idx: number, arg_val: any): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(3, "n")}\`.\
		Reason: A type error occurred when running the function.\
		Expected: <{expected_type}> type for \`{arg_name}\` (arg #{arg_idx}).\
		Cause: Received <{typeof(arg_val)}> type.\
		--------------------`
	)
end

local function ThrowOutOfBoundError(arg_name: string, arg_idx: number, arg_val: any): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(3, "n")}\`.\
		Reason: Attempted to access an index out of bound.\
		Expected: Clamped enabled. Index {arg_val} is out of bound for \`{arg_name}\` (arg #{arg_idx}).\
		Cause: Possible logic error leading to accessing out of bound.\
		--------------------`
	)
end

local function ThrowInvalidSizeError(): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(3, "n")}\`.\
		Reason: Attempted to perform operation with incorrect matrix size.\
		Expected: Correct matrix size. Please revise logic.\
		Cause: Incorrect matrix size. Possible logic error.\
		--------------------`
	)
end

local function ThrowRowMulByZeroError(): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(3, "n")}\`.\
		Reason: Attempted to perform row multiplication with zero.\
		Expected: Cannot perform row multiplication with zero. Please revise logic.\
		Cause: Incorrect \`with\` argument. Possible logic error.\
		--------------------`
	)
end

local function InBoundary(candidate: number, minimum: number, maximum: number): boolean
	return minimum <= candidate and candidate <= maximum
end

local function Check(expression: boolean, err_func: (...any) -> nil, ...: any): nil
	if expression then
		err_func(...)
	end
	return nil
end


-- MATRIX METHOD --

matrix_index.add_row = function(self: Matrix, m: number, fill: FillParameter?, clamped: boolean?): nil
	local size_m, size_n = self.size[1], self.size[2]
	local idx = 0
	
	if clamped then
		idx = math.clamp(m, 1, size_m + 1)
		
	else
		Check(InBoundary(m, 1, size_m + 1), ThrowOutOfBoundError, "m", 1, m)
		idx = m
	end
	
	if type(fill) == "table" then
		local new = table.create(size_n, 0)
		for i, _ in ipairs(new) do
			local val = rawget(fill, i)
			new[i] = if isNumber(val::number) then val else 0
		end
		
		table.insert(self.entries, idx, new)
		
	else
		fill = if isNumber(fill::number) then fill else 0
		table.insert(self.entries, idx, table.create(size_n, fill))
	end
	
	self.size[1] += 1
	return nil
end

matrix_index.clr_row = function(self: Matrix, m: number, clamped: boolean?): {number}
	local size_m = self.size[1]
	local idx = 0
	
	if clamped then
		idx = math.clamp(m, 1, size_m)
		
	else
		Check(InBoundary(m, 1, size_m), ThrowOutOfBoundError, "m", 1, m)
		idx = m
	end
	
	self.size[1] -= 1
	return table.remove(self.entries, idx) :: {number}
end

matrix_index.add_col = function(self: Matrix, n: number, fill: FillParameter?, clamped: boolean?): nil
	local size_m, size_n = self.size[1], self.size[2]
	local idx = 0
	
	if clamped then
		idx = math.clamp(n, 1, size_n)
		
	else
		Check(InBoundary(n, 1, size_n), ThrowOutOfBoundError, "n", 1, n)
		idx = n
	end
	
	if type(fill) == "table" then
		for i = 1, size_m do
			local val = rawget(fill, i)
			table.insert(self.entries[i], idx, if isNumber(val::number) then val::number else 0)
		end
		
	else
		fill = if isNumber(fill::number) then fill else 0
		
		for i = 1, size_m do
			table.insert(self.entries[i], idx, fill::number)
		end
	end
	
	self.size[2] += 1
	return nil
end

matrix_index.clr_col = function(self: Matrix, n: number, clamped: boolean?): {number}
	local size_m, size_n = self.size[1], self.size[2]
	local idx = 0
	if clamped then
		idx = math.clamp(n, 1, size_n)
		
	else
		Check(InBoundary(n, 1, size_n), ThrowOutOfBoundError, "n", 1, n)
		idx = n
	end
	
	local ret = {}
	for i = 1, size_m do
		local element = table.remove(self.entries[i], idx) :: number
		table.insert(ret, element)
	end
	
	self.size[2] -= 1
	return ret
end

-- modify `at` using `with`
matrix_index.row_add = function(self: Matrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	
	local entries_at, entries_with = self.entries[at], self.entries[with]
	
	for col_idx = 1, rawlen(entries_at) do
		entries_at[col_idx] = entries_at[col_idx] + entries_with[col_idx]
	end
	
	return nil
end

matrix_index.row_mul = function(self: Matrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(isNumber(with), ThrowTypeError, "number", "with", 3, with)
	Check(with ~= 0, ThrowRowMulByZeroError)
	
	local entries_at = self.entries[at]
	
	for col_idx = 1, rawlen(entries_at) do
		entries_at[col_idx] *= with
	end
	
	return nil
end

matrix_index.row_switch = function(self: Matrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	
	local entries = self.entries
	
	entries[at], entries[with] = entries[with], entries[at]
	
	return nil
end

matrix_index.sq_diagonal = function(self: Matrix): Matrix
	Check(isPossibleMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = table.create(n, nil::any)
	
	for i = 1, n do
		entries[i] = table.create(n, 0)
		entries[i][i] = self.entries[i][i]
	end
	
	return setmetatable({
		entries = entries,
		size = {n, n}
	}, matrix_meta)
end

matrix_index.sq_lower_triangular = function(self: Matrix): Matrix
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = table.create(n, nil::any)
	
	for i = 1, n do
		entries[i] = table.create(n, 0)
		
		for j = 1, i do
			entries[i][j] = self.entries[i][j]
		end
	end
	
	return setmetatable({
		entries = entries,
		size = {n, n}
	}, matrix_meta)
end

matrix_index.sq_upper_triangular = function(self: Matrix): Matrix
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = table.create(n, nil::any)
	
	for i = 1, n do
		entries[i] = table.create(n, 0)
		
		for j = i, n do
			entries[i][j] = self.entries[i][j]
		end
	end
	
	return setmetatable({
		entries = entries,
		size = {n, n}
	}, matrix_meta)
end

matrix_index.transpose = function(self: Matrix): Matrix
	local m, n = self.size[1], self.size[2]
	local entries = {}
	
	for i = 1, n do
		entries[i] = {}
		for j = 1, m do
			entries[i][j] = self.entries[j][i]
		end
	end
	
	local new: Matrix = setmetatable({
		entries = entries,
		size = {n, m}
	}, matrix_meta)
	return new
end

matrix_index.get_size = function(self: Matrix): SizeProperty
	return self.size
end

matrix_index.set_size = function(self: Matrix, m: number, n: number, fill: number?): nil
	fill = if isNumber(fill::number) then fill else 0
	
	local prev_m, prev_n = table.unpack(self.size)
	
	if m < prev_m then
		for i = m + 1, prev_m do
			self.entries[i] = nil
		end
	end
	
	for i = 1, m do
		if i > prev_m then
			local new_col = table.create(n, fill)
			local new_row = table.create(m, new_col)
			table.move(new_row, 1, #new_row, prev_m, self.entries)
			break
			
		else
			if n < prev_n then
				for j = n + 1, prev_n do
					self.entries[i][j] = nil
				end
				
			elseif n > prev_n then
				for j = n + 1, prev_n do
					self.entries[i][j] = fill
				end
			end
		end
	end
	
	self.size[1] = m
	self.size[2] = n
	return nil
end

matrix_index.get_entry = function(self: Matrix, m: number, n: number): number
	return self.entries[m][n]
end

matrix_index.set_entry = function(self: Matrix, value: number, m: number, n: number): nil
	self.entries[m][n] = value
	return nil
end


-- MATRIX METATABLE --

matrix_meta.__index = matrix_index
matrix_meta.__metatable = "Matrix"

matrix_meta.__add = function(a: Matrix, b: Matrix): Matrix
	local size_A, size_B = a.size, b.size
	
	Check(#size_A == #size_B, ThrowInvalidSizeError)
	Check(size_A[1] == size_B[1], ThrowInvalidSizeError)
	Check(size_A[2] == size_B[2], ThrowInvalidSizeError)
	
	local entries = table.create(size_A[1], nil::any)
	for i = 1, size_A[1] do
		entries[i] = {}
		for j  = 1, size_A[2] do
			entries[i][j] = a.entries[i][j] + b.entries[i][j]
		end
	end
	
	return setmetatable({
		entries = entries,
		size = {size_A[1], size_A[2]}
	}, matrix_meta)
end

matrix_meta.__sub = function(a: Matrix, b: Matrix): Matrix
	local size_A, size_B = a.size, b.size
	
	Check(#size_A == #size_B, ThrowInvalidSizeError)
	Check(size_A[1] == size_B[1], ThrowInvalidSizeError)
	Check(size_A[2] == size_B[2], ThrowInvalidSizeError)
	
	local entries = table.create(size_A[1], nil::any)
	for i = 1, size_A[1] do
		entries[i] = {}
		for j  = 1, size_A[2] do
			entries[i][j] = a.entries[i][j] - b.entries[i][j]
		end
	end
	
	return setmetatable({
		entries = entries,
		size = {size_A[1], size_A[2]}
	}, matrix_meta)
end

matrix_meta.__mul = function(a: Matrix | number, b: Matrix | number): Matrix
	local is_num_A, is_matrix_A = isNumber(a::number), isPossibleMatrix(a::Matrix)
	local is_num_B, is_matrix_B = isNumber(b::number), isPossibleMatrix(b::Matrix)
	
	Check(is_num_A or is_matrix_A, ThrowTypeError, "Matrix | number", "a", 1, a)
	Check(is_num_B or is_matrix_B, ThrowTypeError, "Matrix | number", "b", 2, b)
	
	if is_num_A or is_num_B then
		if is_num_A then
			a, b = b, a
		end
		a = a :: Matrix
		b = b :: number
		
		local size_A = a.size
		local m, n = size_A[1], size_A[2]
		
		local entries = table.create(m, nil::any)
		
		for i = 1, m do
			entries[i] = {}
			for j = 1, n do
				entries[i][j] = a.entries[i][j] * b
			end
		end
		
		return setmetatable({
			entries = entries,
			size = {m, n}
		}, matrix_meta)
		
	else
		a = a :: Matrix
		b = b :: Matrix
		
		local size_A = a.size
		local size_B = b.size
		
		Check(#size_A == #size_B, ThrowInvalidSizeError)
		Check(size_A[2] == size_B[1], ThrowInvalidSizeError)
		
		local m, p = size_A[1], size_B[2]
		local entries = {}
		
		for i = 1, m do
			entries[i] = {}
			for j = 1, p do
				local res = 0
				for r = 1, p do
					res += a.entries[i][r] * b.entries[r][j]
				end
				entries[i][j] = res
			end
		end
		
		return setmetatable({
			entries = entries,
			size = {m, p}
		}, matrix_meta)
	end
end


-- STATIC METHOD --

static_index.transpose = function(self: StaticMatrix): StaticMatrix
	local m, n = self.size[1], self.size[2]
	local entries = table.create(m * n, nil::any)
	for i = 1, n do
		for j = 1, m do
			local i_j = m * (i - 1) + j
			local j_i = n * (j - 1) + i
			entries[i_j] = self.entries[j_i]
		end
	end
	
	return setmetatable({
		entries = entries,
		size = {n, m}
	}, static_meta)
end

static_index.get_size = function(self: StaticMatrix): SizeProperty
	return self.size
end

static_index.get_entry = function(self: StaticMatrix, m: number, n: number): number
	return self.entries[self.size[2] * (m - 1) + n]
end

static_index.set_entry = function(self: StaticMatrix, value: number, m: number, n: number): nil
	self.entries[self.size[2] * (m - 1) + n] = value
	return nil
end


-- STATIC METATABLE --

static_meta.__index = static_index
static_meta.__metatable = "Static"

static_meta.__add = function(a: StaticMatrix, b: StaticMatrix): StaticMatrix
	local size_A, size_B = a.size, b.size
	
	Check(#size_A == #size_B, ThrowInvalidSizeError)
	Check(size_A[1] == size_B[1], ThrowInvalidSizeError)
	Check(size_A[2] == size_B[2], ThrowInvalidSizeError)
	
	local m, n = size_A[1], size_A[2]
	local entries = table.create(m * n, nil::any)
	
	for idx = 1, m * n do
		entries[idx] = a.entries[idx] + b.entries[idx]
	end
	
	return setmetatable({
		entries = entries,
		size = {m, n}
	}, static_meta)
end

static_meta.__sub = function(a: StaticMatrix, b: StaticMatrix): StaticMatrix
	local size_A, size_B = a.size, b.size
	
	Check(#size_A == #size_B, ThrowInvalidSizeError)
	Check(size_A[1] == size_B[1], ThrowInvalidSizeError)
	Check(size_A[2] == size_B[2], ThrowInvalidSizeError)
	
	local m, n = size_A[1], size_A[2]
	local entries = table.create(m * n, nil::any)
	
	for idx = 1, m * n do
		entries[idx] = a.entries[idx] - b.entries[idx]
	end
	
	return setmetatable({
		entries = entries,
		size = {m, n}
	}, static_meta)
end

static_meta.__mul = function(a: StaticMatrix | number, b: StaticMatrix | number): StaticMatrix
	local is_num_A, is_static_A = isNumber(a::number), isPossibleStaticMatrix(a::StaticMatrix)
	local is_num_B, is_static_B = isNumber(b::number), isPossibleStaticMatrix(b::StaticMatrix)
	
	Check(is_num_A or is_static_A, ThrowTypeError, "Matrix | number", "a", 1, a)
	Check(is_num_B or is_static_B, ThrowTypeError, "Matrix | number", "b", 2, b)
	
	if is_num_A or is_num_B then
		if is_num_A then
			a, b = b, a
		end
		
		a = a :: StaticMatrix
		b = b :: number
		
		local size_A = a.size
		local m, n = size_A[1], size_A[2]
		local entries = table.create(m * n, nil::any)
		
		for idx = 1, m * n do
			entries[idx] = a.entries[idx] * b
		end
		
		return setmetatable({
			entries = entries,
			size = {m, n}
		}, static_meta)
		
	else
		a = a :: StaticMatrix
		b = b :: StaticMatrix
		
		local size_A, size_B = a.size, b.size
		
		Check(#size_A == #size_B, ThrowInvalidSizeError)
		Check(size_A[2] == size_B[1], ThrowInvalidSizeError)
		
		local m, n, p = size_A[1], size_A[2], size_B[2]
		local entries = table.create(m * p, nil::any)
		
		for i = 1, m * p do
			local val = 0
			local row = (i - 1) // p + 1
			local col = (i - 1) % p + 1
			
			for j = 1, n do
				val += a.entries[(row - 1) * n + j] * b.entries[p * (j - 1) + col]
			end
			
			entries[i] = val
		end
		
		return setmetatable({
			entries = entries,
			size = {m, p}
		}, static_meta)
	end
end


-- TENSOR METHOD --

-- TBA


-- TENSOR METATABLE --

tensor_meta.__index = tensor_index
tensor_meta.__metatable = "Tensor"


-- MODULE --

local module: Module = {
	--[[
		Constructor: Creates a new `Matrix` object.
		Provides basic arithmetic operations, row operations, and resize operations.
		Requires more memory space for time efficiency to perform resizing.
	]]
	newMatrix = function(fill: Matrix_FillParameter, m: number, n: number): Matrix
		local entries = {}
		
		if type(fill) == "table" then
			for i = 1, m do
				entries[i] = table.create(n, 0)
				
				for j = 1, n do
					local row = rawget(fill, i)
					local num = if type(row) == "table" then rawget(row, j) else 0
					num = if isNumber(num::number) then num else 0
					entries[i][j] = num
				end
			end
			
		else
			fill = if isNumber(fill::number) then fill else 0
			
			for i = 1, m do
				entries[i] = table.create(n, fill)
			end
		end
		
		local self: Matrix = setmetatable({
			entries = entries,
			size = {m, n}
		}, matrix_meta)
		return self
	end,
	
	-- Constructor: Creates a new `StaticMatrix` object.
	
	--[[
		Constructor: Creates a new `StaticMatrix` object.
		Provides basic arithmetic operations and row operations.
		Requires less memory space for no resizing.
	]]
	newStaticMatrix = function(fill: StaticMatrix_FillParameter, m: number, n: number): StaticMatrix
		local entries = {}
		
		if type(fill) == "table" then
			for i = 1, m do
				entries[i] = rawget(fill, i) or 0
			end
			
		else
			fill = if isNumber(fill::number) then fill else 0
			entries = table.create(m * n, fill)
		end
		
		local self: StaticMatrix = setmetatable({
			entries = entries,
			size = {}
		}, static_meta)
		return self
	end,
	
	--[[
		Constructor: Creates a `Tensor` object.
		As of v1.1.0, this object only serves as a shorthand to create N-dimension arrays.
		More functionalities will be added.
	]]
	newTensor = function(fill: Tensor_FillParameter, ...: number): Tensor
		local size = {...}
		
		local function helper(curr_arr: Tensor_EntriesProperty, curr_depth: number): Tensor_EntriesProperty
			if curr_depth == #size then
				return table.create(size[curr_depth], fill)
			end
			
			for idx = 1, size[curr_depth] do
				curr_arr[idx] = helper({}, curr_depth + 1)
			end
			
			return curr_arr
		end
		
		local function helper_2(curr_arr: Tensor_EntriesProperty, curr_depth: number, curr_fill: Tensor_FillParameter): Tensor_EntriesProperty
			if curr_depth == #size then
				if type(curr_fill) == "table" then
					local new = table.create(size[curr_depth], 0)
					for idx = 1, size[curr_depth] do
						local val = rawget(curr_fill, idx)
						val = if isNumber(val::number) then val else 0
						new[idx] = val :: number
					end
					return new :: Tensor_EntriesProperty
					
				else
					curr_fill = if isNumber(curr_fill::number) then curr_fill else 0
					return table.create(size[curr_depth], curr_fill) :: Tensor_EntriesProperty
				end
			end
			
			curr_fill = if type(curr_fill) == "table" then curr_fill else 0
			
			for idx = 1, size[curr_depth] do
				if type(curr_fill) == "table" then
					curr_arr[idx] = helper_2({}, curr_depth + 1, rawget(curr_fill, idx)::Tensor_FillParameter)
					
				else
					curr_arr[idx] = helper_2({}, curr_depth + 1, curr_fill)
				end
			end
			
			return curr_arr
		end
		
		if type(fill) == "table" then
			
			
			return setmetatable({
				entries = helper_2({}, 1, fill),
				size = size
			}, tensor_meta)
			
		else
			return setmetatable({
				entries = helper({}, 1),
				size = size
			}, tensor_meta)
		end
	end,
	
	--[[
		Constructor: Creates a `Matrix` object in the form of an identity matrix.
	]]
	identityMatrix = function(n: number): Matrix
		local entries = table.create(n, nil::any)
		
		for i = 1, n do
			entries[i] = table.create(n, 0)
			entries[i][i] = 1
		end
		
		return setmetatable({
			entries = entries,
			size = {n, n}
		}, matrix_meta)
	end,
	
	--[[
		Constructor: Creates a `StaticMatrix` object in the form of an identity matrix.
	]]
	identityStaticMatrix = function(n: number): StaticMatrix
		local entries = table.create(n * n, 0)
		
		for i = 1, n do
			entries[n * (i - 1) + i] = 1
		end
		
		return setmetatable({
			entries = entries,
			size = {n, n}
		}, static_meta)
	end
}

return module
