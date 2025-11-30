--!strict
--!optimize 2
--!native

-- TODO: [VERSION 1.2.0] Add support for `nan` and `inf`.

-- Version: 1.1.3


-- ** TYPE DEFINITIONS ** --

type AnyNumber = ComplexNumber | RawComplexNumber | number
type ComplexOnly = ComplexNumber | number
type RawComplexOnly = RawComplexNumber | number
type ObjectOnly = ComplexNumber | RawComplexNumber

type raw_tostring_representation = "general" | "rectangular" | "polar" | "euler"
type index_table = ComplexNumber_Method & ComplexNumber_RawMethod

type ObjectTypes = "ComplexNumber" | "RawComplexNumber" | "ObjectOnly" | "number"

type ComplexNumber_Method = {
	clone: (self: ComplexNumber) -> ComplexNumber,
	magnitude: (self: ComplexNumber) -> number,
	argument: (self: ComplexNumber) -> number,
	conjugate: (self: ComplexNumber) -> ComplexNumber,
	polar: (self: ComplexNumber) -> (number, number),
}
type ComplexNumber_RawMethod = {
	raw_unm: (self: ObjectOnly) -> boolean,
	raw_add: (self: ObjectOnly, ...AnyNumber) -> boolean,
	raw_sub: (self: ObjectOnly, ...AnyNumber) -> boolean,
	raw_mul: (self: ObjectOnly, ...AnyNumber) -> boolean,
	raw_div: (self: ObjectOnly, ...AnyNumber) -> boolean,
	raw_idiv: (self: ObjectOnly, ...AnyNumber) -> boolean,
	raw_mod: () -> nil,
	raw_pow: (self: ObjectOnly, ...AnyNumber) -> boolean,
	
	raw_eq: (self: ObjectOnly, ...ObjectOnly) -> boolean,
	raw_lt: (self: ObjectOnly, ...ObjectOnly) -> boolean,
	raw_le: (self: ObjectOnly, ...ObjectOnly) -> boolean,
	raw_gt: (self: ObjectOnly, ...ObjectOnly) -> boolean,
	raw_ge: (self: ObjectOnly, ...ObjectOnly) -> boolean,
	
	raw_clone: (self: ObjectOnly) -> RawComplexNumber,
	raw_magnitude: (self: ObjectOnly) -> number,
	raw_argument: (self: ObjectOnly) -> number,
	raw_conjugate: (self: ObjectOnly) -> boolean,
	
	raw_tostring: (self: ObjectOnly, representation: raw_tostring_representation) -> string,
}
type ComplexNumber_Meta = {
	__index: index_table,
	__newindex: () -> nil,
	__metatable: "ComplexNumber",
	
	__unm: (self: ComplexNumber) -> ComplexNumber,
	__add: (a: AnyNumber, b: AnyNumber) -> ComplexNumber,
	__sub: (a: AnyNumber, b: AnyNumber) -> ComplexNumber,
	__mul: (a: AnyNumber, b: AnyNumber) -> ComplexNumber,
	__div: (a: AnyNumber, b: AnyNumber) -> ComplexNumber,
	__idiv: (a: AnyNumber, b: AnyNumber) -> ComplexNumber,
	__mod: () -> nil,
	__pow: (a: AnyNumber, b: AnyNumber) -> ComplexNumber,
	
	__eq: (a: ComplexNumber, b: ComplexNumber) -> boolean,
	__lt: (a: ComplexNumber, b: ComplexNumber) -> boolean,
	__le: (a: ComplexNumber, b: ComplexNumber) -> boolean,
	
	__len: (self: ComplexNumber) -> number,
	__tostring: (self: ComplexNumber) -> string
}

export type RawComplexNumber = {
	real: number,
	complex: number
}
export type ComplexNumber = setmetatable<RawComplexNumber, ComplexNumber_Meta>

export type Module = {
	newRaw: (real: number, complex: number) -> RawComplexNumber,
	new: (real: number, complex: number) -> ComplexNumber,
	
	real_unit: () -> ComplexNumber,
	complex_unit: () -> ComplexNumber,
	
	fromRaw: (raw: RawComplexNumber) -> ComplexNumber,
	fromPolar: (magnitude: number, argument: number) -> ComplexNumber,
	
	cis: (theta: number) -> ComplexNumber
}


-- ** INTERNAL VARIABLES ** --

local index_table: index_table = {} :: index_table
local tostring_signs = {"-", "+", "+"}

local module: Module = {} :: Module
local metamethods: ComplexNumber_Meta = {} :: ComplexNumber_Meta


-- ** INTERNAL FUNCTIONS ** --

-- This is a modified version of the function in TypeCheck. Checks whether a number is valid to use with this module.
local function isNumber(candidate: number): (boolean, "" | "number")
	if type(candidate) ~= "number" then
		return false, ""
	end
	
	if candidate ~= candidate or math.abs(candidate) == math.huge then
		return false, ""
	end
	
	return true, "number"
end

-- This check function accepts both `ComplexNumber` and `RawComplexNumber` objects.
local function isModuleObject(candidate: ObjectOnly): (boolean, "" | "ObjectOnly")
	if type(candidate) ~= "table" then
		return false, ""
	end
	
	if not isNumber(candidate.real) or not isNumber(candidate.complex) then
		return false, ""
	end
	
	return true, "ObjectOnly"
end

-- This check function only accepts `RawComplexNumber` objects.
local function _isRawComplexNumber(candidate: RawComplexNumber): (boolean, "" | "RawComplexNumber")
	if type(candidate) ~= "table" then
		return false, ""
	end
	
	if getmetatable(candidate) ~= nil then
		return false, ""
	end
	
	if not isNumber(candidate.real) or not isNumber(candidate.complex) then
		return false, ""
	end
	
	return true, "RawComplexNumber"
end

-- This check function only accepts `ComplexNumber` objects, so `RawComplexNumber` objects are not allowed.
local function isComplexNumber(candidate: ComplexNumber): (boolean, "" | "ComplexNumber")
	if type(candidate) ~= "table" then
		return false, ""
	end
	
	if getmetatable(candidate)::string ~= "ComplexNumber" then
		return false, ""
	end
	
	if not isNumber(candidate.real) or not isNumber(candidate.complex) then
		return false, ""
	end
	
	return true, "ComplexNumber"
end

-- This is a wrapper function for type error handling.
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

-- This is a wrapper function for division by 0 error handling. This appears in complex division and exponentiation.
local function ThrowDivisionBy0Error(arg_name: string, arg_idx: number): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(3, "n")}\`.\
		Reason: Attempted to perform division by 0.\
		Expected: Non-zero complex number for \`{arg_name}\` (arg #{arg_idx}).\
		Cause: Argument is equal to 0.\
		--------------------`
	)
end

-- This is a wrapper function for undefined limit error handling. This only appear in complex exponentiation.
local function ThrowUndefinedLimitError(arg_name: string, arg_idx: number): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(3, "n")}\`.\
		Reason: Undefined limit for purely imaginary exponent.\
		Expected: Non-purely imaginary complex number for \`{arg_name}\` (arg #{arg_idx}).\
		Cause: Argument only has complex component.\
		--------------------`
	)
end

-- Checks the type of candidate using provided check functions from <...>. These functions are the internal check functions. Returned strings are limited by available checks.
local function AnalyzeType(candidate: AnyNumber, expected_type: string, arg_name: string, arg_idx: number, ...: (...any) -> (boolean, string)): "number" | "RawComplexNumber" | "ComplexNumber" | "ObjectOnly"
	local checks = {...}
	local typ = ""
	local flag = false
	
	for _, check_func in checks do
		flag, typ = check_func(candidate)
		
		if flag then
			break
		end
	end
	
	if not flag then
		ThrowTypeError(expected_type, arg_name, arg_idx, candidate)
	end
	
	return typ :: any
end

-- Checks an expression and throw an error message using <err_func>. This is similar to assert(), except the string is not formatted prior to call.
local function Check(expression: boolean, err_func: (...any) -> nil, ...: any): nil
	if expression then
		err_func(...)
	end
	return nil
end

local function Complex_Addition(a: AnyNumber, b: AnyNumber, known_type_a: ObjectTypes?): (number, number, string, string)
	local type_a: ObjectTypes = if known_type_a then known_type_a else AnalyzeType(a, "AnyNumber", "a", 1, isNumber, isModuleObject)
	local type_b: ObjectTypes = AnalyzeType(b, "AnyNumber", "b", 2, isNumber, isModuleObject)
	
	local real, complex = 0, 0
	if type_a == "ObjectOnly" and type_b == "ObjectOnly" then
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		real = a.real + b.real
		complex = a.complex + b.complex
		
	elseif type_a == "ObjectOnly" and type_b == "number" then
		a = a :: ObjectOnly
		b = b :: number
		real = a.real + b
		complex = a.complex + b
		
	elseif type_a == "number" and type_b == "ObjectOnly" then
		a = a :: number
		b = b :: ObjectOnly
		real = a + b.real
		complex = a + b.complex
	end
	
	return real, complex, type_a, type_b
end

local function Complex_Subtraction(a: AnyNumber, b: AnyNumber, known_type_a: ObjectTypes?): (number, number, string, string)
	local type_a: ObjectTypes = if known_type_a then known_type_a else AnalyzeType(a, "AnyNumber", "a", 1, isNumber, isModuleObject)
	local type_b: ObjectTypes = AnalyzeType(b, "AnyNumber", "b", 2, isNumber, isModuleObject)
	
	local real, complex = 0, 0
	if type_a == "ObjectOnly" and type_b == "ObjectOnly" then
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		real = a.real - b.real
		complex = a.complex - b.complex
		
	elseif type_a == "ObjectOnly" and type_b == "number" then
		a = a :: ObjectOnly
		b = b :: number
		real = a.real - b
		complex = a.complex - b
		
	elseif type_a == "number" and type_b == "ObjectOnly" then
		a = a :: number
		b = b :: ObjectOnly
		real = a - b.real
		complex = a - b.complex
	end
	
	return real, complex, type_a, type_b
end

local function Complex_Multiplication(a: AnyNumber, b: AnyNumber, known_type_a: ObjectTypes?): (number, number, string, string)
	local type_a: ObjectTypes = if known_type_a then known_type_a else AnalyzeType(a, "AnyNumber", "a", 1, isNumber, isModuleObject)
	local type_b: ObjectTypes = AnalyzeType(b, "AnyNumber", "b", 2, isNumber, isModuleObject)
	
	local real, complex = 0, 0
	if type_a == "ObjectOnly" and type_b == "ObjectOnly" then
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		real = a.real * b.real - a.complex * b.complex
		complex = a.real * b.complex + a.complex * b.real
		
	elseif type_a == "ObjectOnly" and type_b == "number" then
		a = a :: ObjectOnly
		b = b :: number
		real = a.real - b
		complex = a.complex - b
		
	elseif type_a == "number" and type_b == "ObjectOnly" then
		a = a :: number
		b = b :: ObjectOnly
		real = a - b.real
		complex = a - b.complex
	end
	
	return real, complex, type_a, type_b
end

local function Complex_Division(a: AnyNumber, b: AnyNumber, known_type_a: ObjectTypes?, idx_b: number): (number, number, string, string)
	local type_a: ObjectTypes = if known_type_a then known_type_a else AnalyzeType(a, "AnyNumber", "a", 1, isNumber, isModuleObject)
	local type_b: ObjectTypes = AnalyzeType(b, "AnyNumber", "b", 2, isNumber, isModuleObject)
	
	local real, complex = 0, 0
	if type_a == "ObjectOnly" and type_b == "ObjectOnly" then
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		
		Check(b.real == 0 and b.complex == 0, ThrowDivisionBy0Error, if idx_b == 2 then "b" else "...", idx_b)
		
		local real_numerator = a.real * b.real + a.complex * b.complex
		local complex_numerator = a.complex * b.real - a.real * b.complex
		local denominator = b.real ^ 2 + b.complex ^ 2
		
		real = real_numerator / denominator
		complex = complex_numerator / denominator
		
	elseif type_a == "ObjectOnly" and type_b == "number" then
		a = a :: ObjectOnly
		b = b :: number
		
		Check(b == 0, ThrowDivisionBy0Error, if idx_b == 2 then "b" else "...", idx_b)
		
		local real_numerator = a.real * b
		local complex_numerator = a.complex * b
		local denominator = b ^ 2
		
		real = real_numerator / denominator
		complex = complex_numerator / denominator
		
	elseif type_a == "number" and type_b == "ObjectOnly" then
		a = a :: number
		b = b :: ObjectOnly
		
		Check(b.real == 0 and b.complex == 0, ThrowDivisionBy0Error, if idx_b == 2 then "b" else "...", idx_b)
		
		local real_numerator = a * b.real
		local complex_numerator = -a * b.complex
		local denominator = b.real ^ 2 + b.complex ^ 2
		
		real = real_numerator / denominator
		complex = complex_numerator / denominator
	end
	
	return real, complex, type_a, type_b
end

local function Complex_Exponentiation(a: AnyNumber, b: AnyNumber, known_type_a: ObjectTypes?, idx_b: number): (number, number, string, string)
	local type_a: ObjectTypes = if known_type_a then known_type_a::("number" | "RawComplexNumber" | "ComplexNumber") else AnalyzeType(a, "AnyNumber", "a", 1, isNumber, isModuleObject)
	local type_b: ObjectTypes = AnalyzeType(b, "AnyNumber", "b", 2, isNumber, isModuleObject)
	
	local real, complex = 0, 0
	
	if type_a == "ObjectOnly" and type_b == "ObjectOnly" then
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		
		-- Simple case: complex ^ 0
		if b.real == 0 and b.complex == 0 then
			real, complex = 1, 0
			
		-- Simple case: 0 ^ number
		elseif a.real == 0 and a.complex == 0 then
			
			-- Case: 0 ^ (purely-complex)
			Check(b.real == 0 and b.complex ~= 0, ThrowUndefinedLimitError, "b", idx_b)
			
			-- Case: 0 ^ -real
			Check(b.real < 0, ThrowUndefinedLimitError, "b", idx_b)
			
			-- Case: 0 ^ +real
			if b.real > 0 then
				real, complex = 0, 0
			end
			
		-- Simple case: real ^ real
		elseif a.complex == 0 and b.complex == 0 then
			real, complex = a.real ^ b.real, 0
			
		-- Main case: complex ^ complex
		else
			local base_dot_product = a.real ^ 2 + a.complex ^ 2
			local base_argument = math.atan2(a.complex, a.real)
			
			local term_1 = base_dot_product ^ (b.real / 2)
			local term_2 = math.exp(-b.complex * base_argument)
			local term_12 = term_1 * term_2
			
			local term_3_arg = b.real * base_argument + b.complex * math.log(base_dot_product) / 2
			local term_3_real = math.cos(term_3_arg)
			local term_3_complex = math.sin(term_3_arg)
			
			real = term_12 * term_3_real
			complex = term_12 * term_3_complex
		end
		
	elseif type_a == "ObjectOnly" and type_b == "number" then
		a = a :: ObjectOnly
		b = b :: number
		
		-- Simple case: complex ^ 0
		if b == 0 then
			real, complex = 1, 0
			
		-- Simple case: 0 ^ number
		elseif a.real == 0 and a.complex == 0 then
			
			-- Case: 0 ^ -real
			Check(b < 0, ThrowDivisionBy0Error, "b", idx_b)
			
			-- Case: 0 ^ +real
			if b > 0 then
				real, complex = 0, 0
			end
			
		-- Simple case: real ^ real
		elseif a.complex == 0 then
			real, complex = a.real ^ b, 0
			
		-- Main case: complex ^ complex
		else
			local base_dot_product = a.real ^ 2 + a.complex ^ 2
			local base_argument = math.atan2(a.complex, a.real)
			
			local term_1 = base_dot_product ^ (b / 2)
			
			local term_3_arg = b * base_argument
			local term_3_real = math.cos(term_3_arg)
			local term_3_complex = math.sin(term_3_arg)
			
			real = term_1 * term_3_real
			complex = term_1 * term_3_complex
		end
		
	elseif type_a == "number" and type_b == "ObjectOnly" then
		a = a :: number
		b = b :: ObjectOnly
		
		-- Simple case: complex ^ 0
		if b.real == 0 and b.complex == 0 then
			real, complex = 1, 0
			
		-- Simple case: 0 ^ number
		elseif a == 0 then
			
			-- Case: 0 ^ (purely-complex)
			Check(b.real == 0 and b.complex ~= 0, ThrowUndefinedLimitError, "b", idx_b)
			
			-- Case: 0 ^ -real
			Check(b.real < 0, ThrowUndefinedLimitError, "b", idx_b)
			
			-- Case: 0 ^ +real
			if b.real > 0 then
				real, complex = 0, 0
			end
			
		-- Simple case: real ^ real
		elseif b.complex == 0 then
			real, complex = a ^ b.real, 0
			
		-- Main case: complex ^ complex
		else
			local base_dot_product = a ^ 2
			
			local term_1 = base_dot_product ^ (b.real / 2)
			
			local term_3_arg = b.complex * math.log(base_dot_product) / 2
			local term_3_real = math.cos(term_3_arg)
			local term_3_complex = math.sin(term_3_arg)
			
			real = term_1 * term_3_real
			complex = term_1 * term_3_complex
		end
	end
	
	return real, complex, type_a, type_b
end

local function Complex_Magnitude_Compare(a: AnyNumber, idx_a: number): number
	local type_a = AnalyzeType(a, "AnyNumber", "a", idx_a, isNumber, isModuleObject)
	
	if type_a == "number" then
		a = a :: number
		return math.abs(a)
	else
		a = a :: ObjectOnly
		return a.real ^ 2 + a.complex ^ 2
	end
end


-- ** CONSTRUCTORS ** --

-- Constructor: Creates a new `RawComplexNumber` object from `real`, and `complex`.
module.newRaw = function(real: number, complex: number): RawComplexNumber
	AnalyzeType(real, "number", "real", 1, isNumber)
	AnalyzeType(complex, "number", "complex", 2, isNumber)
	return {
		real = real,
		complex = complex
	}
end

-- Constructor: Creates a new `ComplexNumber` object from `real`, and `complex`.
module.new = function(real: number, complex: number): ComplexNumber
	AnalyzeType(real, "number", "real", 1, isNumber)
	AnalyzeType(complex, "number", "complex", 2, isNumber)
	return setmetatable({
		real = real,
		complex = complex
	}, metamethods)
end

--[[
	Constructor: Creates a new `ComplexNumber` object that is equivalent to (1 + 0i).
	Essentially creates a unit on the real component.
]]
module.real_unit = function(): ComplexNumber
	return setmetatable({
		real = 1,
		complex = 0
	}, metamethods)
end

--[[
	Constructor: Creates a new `ComplexNumber` object that is equivalent to (0 + 1i).
	Essentially creates the imaginary unit.
]]
module.complex_unit = function(): ComplexNumber
	return setmetatable({
		real = 0,
		complex = 1
	}, metamethods)
end

-- Constructor: Creates a new `ComplexNumber` object from a valid `RawComplexNumber` type.
module.fromRaw = function(raw: RawComplexNumber): ComplexNumber
	AnalyzeType(raw, "RawComplexNumber", "raw", 1, isModuleObject)
	return setmetatable({
		real = raw.real,
		complex = raw.complex
	}, metamethods)
end

--[[
	Constructor: Creates a new `ComplexNumber` object from `magnitude`, and `argument` (angle in radians).
	After creation, the `ComplexNumber` object will be in the general form.
]]
module.fromPolar = function(magnitude: number, argument: number): ComplexNumber
	AnalyzeType(magnitude, "number", "magnitude", 1, isNumber)
	AnalyzeType(argument, "number", "argument", 2, isNumber)
	return setmetatable({
		real = magnitude * math.cos(argument),
		complex = magnitude * math.sin(argument)
	}, metamethods)
end


-- ** FUNCTIONS ** --

--[[
	Function: Computes the trigonometric function `cis(theta)` with angle <theta> (in radians).
	Equivalent to computing 'cos(theta) + i sin(theta)', or Euler's formula.
]]
module.cis = function(theta: number): ComplexNumber
	AnalyzeType(theta, "number", "theta", 1, isNumber)
	return setmetatable({
		real = math.cos(theta),
		complex = math.sin(theta)
	}, metamethods)
end


-- ** METHODS ** --

-- Method: Creates a new `ComplexNumber` object, whose real, and imaginary parts are taken from `self`.
index_table.clone = function(self: ComplexNumber): ComplexNumber
	AnalyzeType(self, "ComplexNumber", "self", 1, isComplexNumber)
	return setmetatable({
		real = self.real,
		complex = self.complex
	}, metamethods)
end

--[[
	Method: Computes the magnitude (modulus/absolute value) of `self`.
	Similarly, using `#` operator on a `ComplexNumber` object returns this result.
]]
index_table.magnitude = function(self: ComplexNumber): number
	AnalyzeType(self, "ComplexNumber", "self", 1, isComplexNumber)
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

-- Method: Computes the complex argument (counter-clockwise angle from the positive real axis) of `self`.
index_table.argument = function(self: ComplexNumber): number
	AnalyzeType(self, "ComplexNumber", "self", 1, isComplexNumber)
	return math.atan2(self.complex, self.real)
end

-- Method: Creates a new `ComplexNumber` object that is the complex conjugate of `self`.
index_table.conjugate = function(self: ComplexNumber): ComplexNumber
	AnalyzeType(self, "ComplexNumber", "self", 1, isComplexNumber)
	return module.new(self.real, -self.complex)
end

-- Method: Returns both the magnitude, and the complex argument of `self`.
index_table.polar = function(self: ComplexNumber): (number, number)
	AnalyzeType(self, "ComplexNumber", "self", 1, isComplexNumber)
	return math.sqrt(self.real ^ 2 + self.complex ^ 2),
		math.atan2(self.complex, self.real)
end


-- ** RAW METHODS ** --
-- ** RAW METHODS - BASIC ARITHMETIC OPERATION ** --

-- RawMethod: Modify the components of `self` into its additive inverse.
index_table.raw_unm = function(self: ObjectOnly): boolean
	AnalyzeType(self, "ObjectOnly", "self", 1, isModuleObject)
	self = self :: ObjectOnly
	self.real = -self.real
	self.complex = -self.complex
	return true
end

-- RawMethod: Modify the components of `self` by performing complex addition to it for each operand.
index_table.raw_add = function(self: ObjectOnly, ...: AnyNumber): boolean
	local type_a = AnalyzeType(self, "ObjectOnly", "self", 1, isModuleObject)
	
	for _, complex_num in ipairs({...}) do
		local real, complex = Complex_Addition(self, complex_num, type_a)
		self.real = real
		self.complex = complex
	end
	return true
end

-- RawMethod: Modify the components of `self` by performing complex subtraction to it for each operand.
index_table.raw_sub = function(self: ObjectOnly, ...: AnyNumber): boolean
	local type_a = AnalyzeType(self, "ObjectOnly", "self", 1, isModuleObject)
	
	for _, complex_num in ipairs({...}) do
		local real, complex = Complex_Subtraction(self, complex_num, type_a)
		self.real = real
		self.complex = complex
	end
	return true
end

-- RawMethod: Modify the components of `self` by performing complex multiplication to it for each operand.
index_table.raw_mul = function(self: ObjectOnly, ...: AnyNumber): boolean
	local type_a = AnalyzeType(self, "ObjectOnly", "self", 1, isModuleObject)
	
	for _, complex_num in ipairs({...}) do
		local real, complex = Complex_Multiplication(self, complex_num, type_a)
		self.real = real
		self.complex = complex
	end
	return true
end

-- RawMethod: Modify the components of `self` by performing complex division to it for each operand.
index_table.raw_div = function(self: ObjectOnly, ...: AnyNumber): boolean
	local type_a = AnalyzeType(self, "ObjectOnly", "self", 1, isModuleObject)
	
	for idx, complex_num in ipairs({...}) do
		local real, complex = Complex_Division(self, complex_num, type_a, idx + 1)
		self.real = real
		self.complex = complex
	end
	return true
end

-- RawMethod: Modify the components of `self` by performing complex int division to it for each operand.
index_table.raw_idiv = function(self: ObjectOnly, ...: AnyNumber): boolean
	local type_a = AnalyzeType(self, "ObjectOnly", "self", 1, isModuleObject)
	
	for idx, complex_num in ipairs({...}) do
		local real, complex = Complex_Division(self, complex_num, type_a, idx + 1)
		self.real = math.floor(real)
		self.complex = math.floor(complex)
	end
	return true
end

-- RawMethod: Currently, this raw method does not work. Attempting to call this raw method will throw an error.
index_table.raw_mod = function(): nil
	error("This is an invalid operation as of now.")
end

-- RawMethod: Modify the components of `self` by performing complex exponentiation to it for each operand.
index_table.raw_pow = function(self: ObjectOnly, ...: AnyNumber): boolean
	local type_a = AnalyzeType(self, "ObjectOnly", "self", 1, isModuleObject)
	
	for idx, complex_num in ipairs({...}) do
		local real, complex = Complex_Exponentiation(self, complex_num, type_a, idx + 1)
		self.real = real
		self.complex = complex
	end
	return true
end


-- ** RAW METHODS - EQUALITY COMPARISON ** --

-- RawMethod: Returns a boolean determining whether `self` is equivalent to every operands.
index_table.raw_eq = function(self: ObjectOnly, ...: ObjectOnly): boolean
	Check(isModuleObject(self), ThrowTypeError, "ObjectOnly", "self", 1, self)
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		local cur_magnitude = Complex_Magnitude_Compare(complex_num, idx + 1)
		
		if self_magnitude ~= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is less than every operands.
index_table.raw_lt = function(self: ObjectOnly, ...: ObjectOnly): boolean
	Check(isModuleObject(self), ThrowTypeError, "ObjectOnly", "self", 1, self)
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		local cur_magnitude = Complex_Magnitude_Compare(complex_num, idx + 1)
		
		if self_magnitude >= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is less than or equal to every operands.
index_table.raw_le = function(self: ObjectOnly, ...: ObjectOnly): boolean
	Check(isModuleObject(self), ThrowTypeError, "ObjectOnly", "self", 1, self)
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		local cur_magnitude = Complex_Magnitude_Compare(complex_num, idx + 1)
		
		if self_magnitude > cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is greater than every operands.
index_table.raw_gt = function(self: ObjectOnly, ...: ObjectOnly): boolean
	Check(isModuleObject(self), ThrowTypeError, "ObjectOnly", "self", 1, self)
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		local cur_magnitude = Complex_Magnitude_Compare(complex_num, idx + 1)
		
		-- not greater than -> less than or equal to
		if self_magnitude <= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is greater than or equal to every operands.
index_table.raw_ge = function(self: ObjectOnly, ...: ObjectOnly): boolean
	Check(isModuleObject(self), ThrowTypeError, "ObjectOnly", "self", 1, self)
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		local cur_magnitude = Complex_Magnitude_Compare(complex_num, idx + 1)
		
		-- not greater than or equal to -> less than
		if self_magnitude < cur_magnitude then
			return false
		end
	end
	
	return true
end


-- ** RAW METHODS - FROM METHOD ** --

index_table.raw_clone = function(self: ObjectOnly): RawComplexNumber
	Check(isModuleObject(self), ThrowTypeError, "ObjectOnly", "self", 1, self)
	return {
		real = self.real,
		complex = self.complex
	}
end

-- RawMethod: Computes the magnitude (modulus/absolute value) of `self`. Accepts valid `RawComplexNumber` types.
index_table.raw_magnitude = function(self: ObjectOnly): number
	Check(isModuleObject(self), ThrowTypeError, "ObjectOnly", "self", 1, self)
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

-- RawMethod: Computes the complex argument (counter-clockwise angle from the positive real axis) of `self`. Accepts valid `RawComplexNumber` types.
index_table.raw_argument = function(self: ObjectOnly): number
	Check(isModuleObject(self), ThrowTypeError, "ObjectOnly", "self", 1, self)
	return math.atan2(self.complex, self.real)
end

-- RawMethod: Modify `self` to its conjugate.
index_table.raw_conjugate = function(self: ObjectOnly): boolean
	Check(isModuleObject(self), ThrowTypeError, "ObjectOnly", "self", 1, self)
	self.complex = -self.complex
	return true
end


-- ** RAW METHODS - OTHER ** --

--[[
	RawMethod: Create a <string> representation formatted to display `self`, according to <representation>.
	Optional <representation> can be either "general", "rectangular", "polar". By default, always displays in "general" form.
]]
index_table.raw_tostring = function(self: ObjectOnly, representation: ("general" | "rectangular" | "polar" | "euler")?): string
	assert(isModuleObject(self), `Failed to perform \`:raw_tostring()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: ObjectOnly
	representation = representation :: ("general" | "rectangular" | "polar" | "euler")
	
	if representation == "rectangular" then
		return `({self.real}, {self.complex})`
		
	elseif representation == "polar" then
		local magnitude = math.sqrt(self.real ^ 2 + self.complex ^ 2)
		local argument = math.atan2(self.complex, self.real)
		
		return `{magnitude} cis {argument}`
		
	elseif representation == "euler" then
		local magnitude = math.sqrt(self.real ^ 2 + self.complex ^ 2)
		local argument = math.atan2(self.complex, self.real)
		
		return `{magnitude} e^({argument}i)`
	end
	
	local complex_sign = tostring_signs[math.sign(self.complex) + 2]
	local complex_number = math.abs(self.complex)
	
	return `({self.real} {complex_sign} {complex_number}i)`
end


-- ** METAMETHODS ** --
-- ** METAMETHODS - INITIAL ** --

metamethods.__index = index_table

metamethods.__newindex = function(t: ComplexNumber, key: any, value: any): nil
	error(`Attempted to create a new index/key in <ComplexNumber> object.\nObject representation: {t}\nIndex/Key: {key}\nValue: {value}`)
end

metamethods.__metatable = "ComplexNumber"


-- ** METAMETHODS - BASIC ARITHMETIC OPERATION ** --

metamethods.__unm = function(self: ComplexNumber): ComplexNumber
	Check(isComplexNumber(self), ThrowTypeError, "ComplexNumber", "self", 1, self)
	self.real, self.complex = -self.real, -self.complex
	return self
end

metamethods.__add = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local real, complex = Complex_Addition(a, b)
	return setmetatable({
		real = real,
		complex = complex
	}, metamethods)
end

metamethods.__sub = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local real, complex = Complex_Subtraction(a, b)
	return setmetatable({
		real = real,
		complex = complex
	}, metamethods)
end

metamethods.__mul = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local real, complex = Complex_Multiplication(a, b)
	return setmetatable({
		real = real,
		complex = complex
	}, metamethods)
end

metamethods.__div = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local real, complex = Complex_Division(a, b, nil, 2)
	return setmetatable({
		real = real,
		complex = complex
	}, metamethods)
end

metamethods.__idiv = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local real, complex = Complex_Division(a, b, nil, 2)
	return setmetatable({
		real = math.floor(real),
		complex = math.floor(complex)
	}, metamethods)
end

metamethods.__mod = function(): nil
	error("This is an invalid operation as of now.")
end

metamethods.__pow = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local real, complex = Complex_Exponentiation(a, b, nil, 2)
	return setmetatable({
		real = math.floor(real),
		complex = math.floor(complex)
	}, metamethods)
end


-- ** METAMETHODS - EQUALITY COMPARISON ** --

metamethods.__eq = function(a: ComplexNumber, b: ComplexNumber): boolean
	Check(isComplexNumber(a), ThrowTypeError, "ComplexNumber", "a", 1, a)
	Check(isComplexNumber(b), ThrowTypeError, "ComplexNumber", "b", 2, b)
	
	local magnitude_A = a.real ^ 2 + a.complex ^ 2
	local magnitude_B = b.real ^ 2 + b.complex ^ 2
	return magnitude_A == magnitude_B
end

metamethods.__lt = function(a: ComplexNumber, b: ComplexNumber): boolean
	Check(isComplexNumber(a), ThrowTypeError, "ComplexNumber", "a", 1, a)
	Check(isComplexNumber(b), ThrowTypeError, "ComplexNumber", "b", 2, b)
	
	local magnitude_A = a.real ^ 2 + a.complex ^ 2
	local magnitude_B = b.real ^ 2 + b.complex ^ 2
	return magnitude_A < magnitude_B
end

metamethods.__le = function(a: ComplexNumber, b: ComplexNumber): boolean
	Check(isComplexNumber(a), ThrowTypeError, "ComplexNumber", "a", 1, a)
	Check(isComplexNumber(b), ThrowTypeError, "ComplexNumber", "b", 2, b)
	
	local magnitude_A = a.real ^ 2 + a.complex ^ 2
	local magnitude_B = b.real ^ 2 + b.complex ^ 2
	return magnitude_A <= magnitude_B
end


-- ** METAMETHODS - OTHER ** --

metamethods.__len = function(self: ComplexNumber): number
	Check(isComplexNumber(self), ThrowTypeError, "ComplexNumber", "self", 1, self)
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

metamethods.__tostring = function(self: ComplexNumber): string
	Check(isComplexNumber(self), ThrowTypeError, "ComplexNumber", "self", 1, self)
	
	local complex_sign = tostring_signs[math.sign(self.complex) + 2]
	local complex_number = math.abs(self.complex)
	return `({self.real} {complex_sign} {complex_number}i)`
end

return module
