--!strict
--!optimize 2
--!native

-- TODO: [VERSION 1.1.0] Update Wiki.

-- TODO: [VERSION 1.2.0] Change internal variables to follow the new module structure.
-- TODO: [VERSION 1.2.0] Change internal error message displaying functions to return a closure. Function inlining may be profited.
-- TODO: [VERSION 1.2.0] Implement different variants of matrix multiplication.
-- TODO: [VERSION 1.2.0] `Vector` type. A special object type of `Matrix`. Different from `vector` data type.
-- TODO: [VERSION 1.2.0] Adjugate matrix.
-- TODO: [VERSION 1.2.0] Orthogonal matrix.
-- TODO: [VERSION 1.2.0] Allow object interactions.
-- TODO: [VERSION 1.2.0] Implement operations on `Tensor`.
-- TODO: [VERSION 1.2.0] Implement logical matrix, aka (0,1)-matrix, used in boolean algebra.
-- TODO: [VERSION 1.2.0] Improve matrix determinant operation to reduce floating-point errors.
-- TODO: [VERSION 1.2.0] Improve matrix determinant operation by using Tri-diagonal matrix algorithm (Thomas's algorithm) for speedup in special case.
-- TODO: [VERSION 1.2.0] [?] Implement Gaussian Elimination as a standalone method.
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
	row_sub: (self: Matrix, at: number, with: number) -> nil,
	row_mul: (self: Matrix, at: number, with: number) -> nil,
	row_fma: (self: Matrix, at: number, with: number, times: number) -> nil,
	row_switch: (self: Matrix, at: number, with: number) -> nil,
	
	sq_diagonal: (self: Matrix) -> Matrix,
	sq_lower_triangular: (self: Matrix) -> Matrix,
	sq_upper_triangular: (self: Matrix) -> Matrix,
	
	trace: (self: Matrix) -> number,
	determinant: (self: Matrix) -> number,
	
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
	row_add: (self: StaticMatrix, at: number, with: number) -> nil,
	row_sub: (self: StaticMatrix, at: number, with: number) -> nil,
	row_mul: (self: StaticMatrix, at: number, with: number) -> nil,
	row_fma: (self: StaticMatrix, at: number, with: number, times: number) -> nil,
	row_switch: (self: StaticMatrix, at: number, with: number) -> nil,
	
	sq_diagonal: (self: StaticMatrix) -> StaticMatrix,
	sq_lower_triangular: (self: StaticMatrix) -> StaticMatrix,
	sq_upper_triangular: (self: StaticMatrix) -> StaticMatrix,
	
	trace: (self: StaticMatrix) -> number,
	determinant: (self: StaticMatrix) -> number,
	
	transpose: (self: StaticMatrix) -> StaticMatrix,
	
	get_size: (self: StaticMatrix) -> SizeProperty,
	
	get_entry: (self: StaticMatrix, m: number, n: number) -> number,
	set_entry: (self: StaticMatrix, value: number, m: number, n: number) -> nil
}
type StaticMatrix_Meta = {
	__index: StaticMatrix_Method,
	__metatable: "StaticMatrix",
	
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

-- A very loose surface check for `Matrix` objects.
local function isPossibleMatrix(candidate: Matrix): boolean
	return type(candidate) == "table" and getmetatable(candidate) == "Matrix" and type(candidate.entries) == "table" and type(candidate.size) == "table"
end

-- A very loose surface check for `StaticMatrix` objects.
local function isPossibleStaticMatrix(candidate: StaticMatrix): boolean
	return type(candidate) == "table" and getmetatable(candidate) == "StaticMatrix" and type(candidate.entries) == "table" and type(candidate.size) == "table"
end

-- A very loose surface check for a candidate object represented as a square matrix.
local function isPossibleSquareMatrix(candidate: Matrix | StaticMatrix): boolean
	return candidate.size[1] == candidate.size[2] and #candidate.entries == candidate.size[1]
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

local function Matrix_EntriesDeepCopy(candidate: Matrix): Matrix_EntriesProperty
	local entries, size = candidate.entries, candidate.size
	local m, n = size[1], size[2]
	local result = table.create(m, nil::any)
	
	for i = 1, m do
		result[i] = table.move(entries[i], 1, n, 1, {})
	end
	
	return result
end

local function Static_EntriesDeepCopy(candidate: StaticMatrix): StaticMatrix_EntriesProperty
	return table.clone(candidate.entries)
end

-- MATRIX METHOD --

--[[
	Method: Inserts a row into `self` at row `m`.
	Default `fill` is set to 0.
	Default `clamped` is set to false.
]]
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

--[[
	Method: Deletes a row into `self` at row `m`.
]]
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

--[[
	Method: Inserts a column into `self` at column `n`.
	Default `fill` is set to 0.
	Default `clamped` is set to false.
]]
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

--[[
	Method: Deletes a column into `self` at column `n`.
]]
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

--[[
	Method: Perform row *addition* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
]]
matrix_index.row_add = function(self: Matrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	
	local entries_at, entries_with = self.entries[at], self.entries[with]
	
	for col_idx = 1, size[2] do
		entries_at[col_idx] += entries_with[col_idx]
	end
	
	return nil
end

--[[
	Method: Perform row *subtraction* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
	
	This method is not part of the original elementary row operations.
	It is created for convenience.
]]
matrix_index.row_sub = function(self: Matrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	
	local entries_at, entries_with = self.entries[at], self.entries[with]
	
	for col_idx = 1, size[2] do
		entries_at[col_idx] -= entries_with[col_idx]
	end
	
	return nil
end

--[[
	Method: Perform row *multiplication* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
]]
matrix_index.row_mul = function(self: Matrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(isNumber(with), ThrowTypeError, "number", "with", 3, with)
	Check(with ~= 0, ThrowRowMulByZeroError)
	
	local entries_at = self.entries[at]
	
	for col_idx = 1, size[2] do
		entries_at[col_idx] *= with
	end
	
	return nil
end

--[[
	Method: Perform row *fused multiply-add* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
	
	This method is not part of the original elementary row operations.
	It is created for convenience.
	
	This method does not perform any rounding internally in the source code.
]]
matrix_index.row_fma = function(self: Matrix, at: number, with: number, times: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(isNumber(with), ThrowTypeError, "number", "with", 3, with)
	Check(isNumber(times), ThrowTypeError, "number", "times", 4, times)
	Check(times ~= 0, ThrowRowMulByZeroError)
	
	local entries_at, entries_with = self.entries[at], self.entries[with]
	
	for col_idx = 1, size[2] do
		entries_at[col_idx] += entries_with[col_idx] * times
	end
	
	return nil
end

--[[
	Method: Perform row *switch* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
]]
matrix_index.row_switch = function(self: Matrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	
	local entries = self.entries
	
	entries[at], entries[with] = entries[with], entries[at]
	
	return nil
end

--[[
	Method: Computes the diagonal matrix of `self`, given that `self` is a square matrix.
	Returns a new `Matrix` object as the result.
]]
matrix_index.sq_diagonal = function(self: Matrix): Matrix
	Check(isPossibleMatrix(self), ThrowTypeError, "Matrix", "self", 1, self)
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

--[[
	Method: Computes the lower triangular matrix of `self`, given that `self` is a square matrix.
	Returns a new `Matrix` object as the result.
]]
matrix_index.sq_lower_triangular = function(self: Matrix): Matrix
	Check(isPossibleMatrix(self), ThrowTypeError, "Matrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = table.create(n, nil::any)
	
	for i = 1, n do
		entries[i] = table.move(self.entries[i], 1, i, 1, table.create(n, 0))
	end
	
	return setmetatable({
		entries = entries,
		size = {n, n}
	}, matrix_meta)
end

--[[
	Method: Computes the upper triangular matrix of `self`, given that `self` is a square matrix.
	Returns a new `Matrix` object as the result.
]]
matrix_index.sq_upper_triangular = function(self: Matrix): Matrix
	Check(isPossibleMatrix(self), ThrowTypeError, "Matrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = table.create(n, nil::any)
	
	for i = 1, n do
		entries[i] = table.move(self.entries[i], i, n, i, table.create(n, 0))
	end
	
	return setmetatable({
		entries = entries,
		size = {n, n}
	}, matrix_meta)
end

--[[
	Method: Computes the trace of `self`, given that `self` is a square matrix.
	Returns a number as the result.
]]
matrix_index.trace = function(self: Matrix): number
	Check(isPossibleMatrix(self), ThrowTypeError, "Matrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = self.entries
	
	local res = 0
	for i = 1, n do
		res += entries[i][i]
	end
	return res
end

--[[
	Method: Computes the determinant of `self`, given that `self` is a square matrix.
	Returns a number as the result.
]]
matrix_index.determinant = function(self: Matrix): number
	Check(isPossibleMatrix(self), ThrowTypeError, "Matrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	
	if n == 1 then
		return self.entries[1][1]
		
	elseif n == 2 then
		local entries = self.entries
		return    entries[1][1] * entries[2][2]
				- entries[1][2] * entries[2][1]
		
	elseif n == 3 then
		local entries = self.entries
		return    entries[1][1] * entries[2][2] * entries[3][3]
				+ entries[1][2] * entries[2][3] * entries[3][1]
				+ entries[1][3] * entries[2][1] * entries[3][2]
				- entries[1][3] * entries[2][2] * entries[3][1]
				- entries[1][2] * entries[2][1] * entries[3][3]
				- entries[1][1] * entries[2][3] * entries[3][2]
		
	else
		--[[
			Solving the following matrix involves both interchange and early return.
			Though, early return happens at the final row, but this still describes
			the purpose of it.
			
			entries = {
				{5, 5, 4, 5},
				{0, 0, 8, 1},
				{8, 1, 2, 1},
				{0, 0, 8, 1}
			}
		]]
		
		local entries = Matrix_EntriesDeepCopy(self)
		
		for col = 1, n do
			local pivot = entries[col][col]
			local pivot_row = col
			
			-- Attempt to find non-zero pivot at the column index.
			while pivot_row < n and pivot == 0 do
				pivot_row += 1
				pivot = entries[pivot_row][col]
			end
			
			-- If there is no non-zero pivot, can early return as the result will be 0.
			if pivot == 0 then
				return 0
			end
			
			-- If pivot is at a different row than the starting row.
			-- No if statement needed.
			entries[pivot_row], entries[col] = entries[col], entries[pivot_row]
			
			-- Eliminate pivot of other rows.
			for row = col + 1, n do
				local curr_pivot = entries[row][col]
				local coefficient = curr_pivot / pivot
				
				for j = col, n do
					entries[row][j] -= entries[pivot_row][j] * coefficient
				end
			end
		end
		
		-- Calculate the product on the diagonal.
		local diag = 1
		for i = 1, n do
			diag *= entries[i][i]
		end
		return diag
	end
end

--[[
	Method: Computes the transpose matrix of `self`.
	Returns a new `Matrix` object as the result.
]]
matrix_index.transpose = function(self: Matrix): Matrix
	local m, n = self.size[1], self.size[2]
	local entries = table.create(n, nil::any)
	
	for i = 1, n do
		entries[i] = table.create(m, nil::any)
		for j = 1, m do
			entries[i][j] = self.entries[j][i]
		end
	end
	
	return setmetatable({
		entries = entries,
		size = {n, m}
	}, matrix_meta)
end

-- Method: Returns the `size` property of `self`.
matrix_index.get_size = function(self: Matrix): SizeProperty
	return self.size
end

--[[
	Method: Sets the size of `self` to have `m` rows and `n` columns.
	Default `fill` is set to 0. No secondary `fill` parameter behavior option.
]]
matrix_index.set_size = function(self: Matrix, m: number, n: number, fill: number?): nil
	fill = if isNumber(fill::number) then fill else 0
	
	local prev_m, prev_n = self.size[1], self.size[2]
	
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

-- Method: Returns the `entry` value at row `m`, column `n` of `self`.
matrix_index.get_entry = function(self: Matrix, m: number, n: number): number
	return self.entries[m][n]
end

-- Method: Sets the `entry` value at row `m`, column `n` of `self`.
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

--[[
	Method: Perform row *addition* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
]]
static_index.row_add = function(self: StaticMatrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	
	local n = size[2]
	local entries = self.entries
	
	for col_idx = 1, n do
		entries[n * (at - 1) + col_idx] += entries[n * (with - 1) + col_idx]
	end
	
	return nil
end

--[[
	Method: Perform row *subtraction* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
	
	This method is not part of the original elementary row operations.
	It is created for convenience.
]]
static_index.row_sub = function(self: StaticMatrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	
	local n = size[2]
	local entries = self.entries
	
	for col_idx = 1, n do
		entries[n * (at - 1) + col_idx] -= entries[n * (with - 1) + col_idx]
	end
	
	return nil
end

--[[
	Method: Perform row *multiplication* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
]]
static_index.row_mul = function(self: StaticMatrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	Check(with ~= 0, ThrowRowMulByZeroError)
	
	local n = size[2]
	local entries = self.entries
	
	for col_idx = 1, n do
		entries[n * (at - 1) + col_idx] *= with
	end
	
	return nil
end

--[[
	Method: Perform row *fused multiply-add* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
	
	This method is not part of the original elementary row operations.
	It is created for convenience.
	
	This method does not perform any rounding internally in the source code.
]]
static_index.row_fma = function(self: StaticMatrix, at: number, with: number, times: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	Check(isNumber(times), ThrowTypeError, "number", "times", 4, times)
	Check(times ~= 0, ThrowRowMulByZeroError)
	
	local n = size[2]
	local entries = self.entries
	
	for col_idx = 1, n do
		entries[n * (at - 1) + col_idx] += entries[n * (with - 1) + col_idx] * times
	end
	
	return nil
end

--[[
	Method: Perform row *switch* operation at row index `at` with row index `with`.
	Syntax can be understood as: "Perform operation at <row index> with <row index>."
]]
static_index.row_switch = function(self: StaticMatrix, at: number, with: number): nil
	local size = self.size
	
	Check(InBoundary(at, 1, size[1]), ThrowOutOfBoundError, "at", 2, at)
	Check(InBoundary(with, 1, size[1]), ThrowOutOfBoundError, "with", 3, with)
	
	local n = size[2]
	local entries = self.entries
	
	for col_idx = 1, n do
		entries[n * (at - 1) + col_idx], entries[n * (with - 1) + col_idx] = entries[n * (with - 1) + col_idx], entries[n * (at - 1) + col_idx]
	end
	
	return nil
end

--[[
	Method: Computes the diagonal matrix of `self`, given that `self` is a square matrix.
	Returns a new `StaticMatrix` object as the result.
]]
static_index.sq_diagonal = function(self: StaticMatrix): StaticMatrix
	Check(isPossibleStaticMatrix(self), ThrowTypeError, "StaticMatrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = table.create(n * n, 0)
	
	for i = 1, n do
		entries[n * (i - 1) + i] = self.entries[n * (i - 1) + i]
	end
	
	return setmetatable({
		entries = entries,
		size = table.freeze({n, n})
	}, static_meta)
end

--[[
	Method: Computes the lower triangular matrix of `self`, given that `self` is a square matrix.
	Returns a new `StaticMatrix` object as the result.
]]
static_index.sq_lower_triangular = function(self: StaticMatrix): StaticMatrix
	Check(isPossibleStaticMatrix(self), ThrowTypeError, "StaticMatrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = table.create(n * n, 0)
	
	for i = 1, n do
		for j = 1, i do
			entries[n * (i - 1) + j] = self.entries[n * (i - 1) + j]
		end
	end
	
	return setmetatable({
		entries = entries,
		size = table.freeze({n, n})
	}, static_meta)
end

--[[
	Method: Computes the upper triangular matrix of `self`, given that `self` is a square matrix.
	Returns a new `StaticMatrix` object as the result.
]]
static_index.sq_upper_triangular = function(self: StaticMatrix): StaticMatrix
	Check(isPossibleStaticMatrix(self), ThrowTypeError, "StaticMatrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = table.create(n * n, 0)
	
	for i = 1, n do
		for j = i, n do
			entries[n * (i - 1) + j] = self.entries[n * (i - 1) + j]
		end
	end
	
	return setmetatable({
		entries = entries,
		size = table.freeze({n, n})
	}, static_meta)
end

--[[
	Method: Computes the trace of `self`, given that `self` is a square matrix.
	Returns a number as the result.
]]
static_index.trace = function(self: StaticMatrix): number
	Check(isPossibleStaticMatrix(self), ThrowTypeError, "StaticMatrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	local entries = self.entries
	local res = 0
	
	for i = 1, n do
		res += entries[n * (i - 1) + i]
	end
	
	return res
end

--[[
	Method: Computes the determinant of `self`, given that `self` is a square matrix.
	Returns a number as the result.
]]
static_index.determinant = function(self: StaticMatrix): number
	Check(isPossibleStaticMatrix(self), ThrowTypeError, "StaticMatrix", "self", 1, self)
	Check(isPossibleSquareMatrix(self), ThrowTypeError, "SquareMatrix", "self", 1, self)
	
	local n = self.size[1]
	
	if n == 1 then
		return self.entries[1]
		
	elseif n == 2 then
		local entries = self.entries
		return    entries[1] * entries[4]
				- entries[2] * entries[3]
		
	elseif n == 3 then
		local entries = self.entries
		return    entries[1] * entries[5] * entries[9]
				+ entries[2] * entries[6] * entries[7]
				+ entries[3] * entries[4] * entries[8]
				- entries[3] * entries[5] * entries[7]
				- entries[2] * entries[4] * entries[9]
				- entries[1] * entries[6] * entries[8]
		
	else
		local entries = Static_EntriesDeepCopy(self)
		
		for col = 1, n do
			local pivot = entries[n * (col - 1) + col]
			local pivot_row = col
			
			while pivot_row < n and pivot == 0 do
				pivot_row += 1
				pivot = entries[n * (pivot_row - 1) + col]
			end
			
			if pivot == 0 then
				return 0
			end
			
			entries[pivot_row], entries[col] = entries[col], entries[pivot_row]
			
			for row = col + 1, n do
				local curr_pivot = entries[n * (row - 1) + col]
				local coefficient = curr_pivot / pivot
				
				for j = col, n do
					entries[n * (row - 1) + j] -= entries[n * (pivot_row - 1) + j] * coefficient
				end
			end
		end
		
		local diag = 1
		for i = 1, n do
			diag *= entries[n * (i - 1) + i]
		end
		return diag
	end
end

--[[
	Method: Computes the transpose matrix of `self`.
	Returns a new `StaticMatrix` object as the result.
]]
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

-- Method: Returns the `size` property of `self`.
static_index.get_size = function(self: StaticMatrix): SizeProperty
	return self.size
end

-- Method: Returns the `entry` value at row `m`, column `n` of `self`.
static_index.get_entry = function(self: StaticMatrix, m: number, n: number): number
	return self.entries[self.size[2] * (m - 1) + n]
end

-- Method: Sets the `entry` value at row `m`, column `n` of `self`.
static_index.set_entry = function(self: StaticMatrix, value: number, m: number, n: number): nil
	self.entries[self.size[2] * (m - 1) + n] = value
	return nil
end


-- STATIC METATABLE --

static_meta.__index = static_index
static_meta.__metatable = "StaticMatrix"

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
			size = table.freeze({m, n})
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
		Constructor: Creates a `Matrix` object in the form of an n-by-n identity matrix.
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
		Constructor: Creates a `StaticMatrix` object in the form of an n-by-n identity matrix.
	]]
	identityStaticMatrix = function(n: number): StaticMatrix
		local entries = table.create(n * n, 0)
		
		for i = 1, n do
			entries[n * (i - 1) + i] = 1
		end
		
		return setmetatable({
			entries = entries,
			size = table.freeze({n, n})
		}, static_meta)
	end
}

return module
