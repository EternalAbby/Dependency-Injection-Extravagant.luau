--!strict

local tostring_signs = {"-", "+", "+"}

local module = {}


-- ** TYPE DEFINITIONS ** --

export type RawComplexNumber = {
	["real"]: number,
	["complex"]: number
}

export type ComplexNumber = setmetatable<{
	["real"]: number,
	["complex"]: number
}, typeof(module)>

type AnyNumber = ComplexNumber | RawComplexNumber | number
type ComplexOnly = ComplexNumber | number
type RawComplexOnly = RawComplexNumber | number
type ObjectOnly = ComplexNumber | RawComplexNumber

-- ** INTERNAL FUNCTIONS ** --

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

local function isRawComplexNumber(candidate: RawComplexNumber): boolean
	if typeof(candidate) ~= "table" then
		return false
	end
	
	if not isNumber(candidate.real) or not isNumber(candidate.complex) then
		return false
	end
	
	return true
end

local function isComplexNumber(candidate: ComplexNumber): boolean
	if typeof(candidate) ~= "table" then
		return false
	end
	
	if getmetatable(candidate)::string ~= "ComplexNumber" then
		return false
	end
	
	if not isNumber(candidate.real) or not isNumber(candidate.complex) then
		return false
	end
	
	return true
end

local function ThrowTypeError(func_name: string, func_type: string, expected_type: string, arg_name: string, arg_idx: number, arg_val: any): nil
	error(`--------------------\n\
	Error: Failed to perform \`{func_name}\` {func_type}.\n\
	Reason: A type error occurred when running the function.\n\
	Expected: <{expected_type}> type for \`{arg_name}\` (arg #{arg_idx}).\n\
	Cause: Received <{typeof(arg_val)}> type.\n\
	--------------------`
)
end

local function ThrowDivisionBy0Error(func_name: string, func_type: string, arg_name: string, arg_idx: number): nil
	error(`--------------------\n\
	Error: Failed to perform \`{func_name}\` {func_type}.\n\
	Reason: Attempted to perform division by 0.\n\
	Expected: Non-zero complex number for \`{arg_name}\` (arg #{arg_idx}).\n\
	Cause: Argument is equal to 0.\n\
	--------------------`
)
end

local function ThrowUndefinedLimitError(func_name: string, func_type: string, arg_name: string, arg_idx: number)
	error(`--------------------\n\
	Error: Failed to perform \`{func_name}\` {func_type}.\n\
	Reason: Undefined limit for purely imaginary exponent.\n\
	Expected: Non-purely imaginary complex number for \`{arg_name}\` (arg #{arg_idx}).\n\
	Cause: Argument only has complex component.\n\
	--------------------`
)
end

-- Computes the complex addition of `a` and `b` and returns the resulting real and complex components.
local function Complex_Addition(a_real: number, a_complex: number, b_real: number, b_complex: number): (number, number)
	return a_real + b_real,
		a_complex + b_complex
end

-- Computes the complex subtraction of `a` and `b` and returns the resulting real and complex components.
local function Complex_Subtraction(a_real: number, a_complex: number, b_real: number, b_complex: number): (number, number)
	return a_real - b_real,
		a_complex - b_complex
end

-- Computes the complex multiplication of `a` and `b` and returns the resulting real and complex components.
local function Complex_Multiplication(a_real: number, a_complex: number, b_real: number, b_complex: number): (number, number)
	return a_real * b_real - a_complex * b_complex,
		a_real * b_complex + a_complex * b_real
end

-- Computes the complex division of `a` and `b` and returns the resulting real and complex components.
local function Complex_Division(a_real: number, a_complex: number, b_real: number, b_complex: number): (number, number)
	--assert(b_real ~= 0 and b_complex ~= 0, "error division by 0")
	
	local real_numerator = a_real * b_real + a_complex * b_complex
	local complex_numerator = a_complex * b_real - a_real * b_complex
	local denominator = b_real ^ 2 + b_complex ^ 2
	
	return real_numerator / denominator,
		complex_numerator / denominator
end

-- Computes the complex exponentiation of `a` and `b` and returns the resulting real and complex components.
local function Complex_Exponentiation(a_real: number, a_complex: number, b_real: number, b_complex: number): (number, number)
	-- Simple case: complex ^ 0
	if b_real == 0 and b_complex == 0 then
		return 1, 0
	end
	
	-- Simple case: 0 ^ number
	if a_real == 0 and a_complex == 0 then
		
		-- Case: 0 ^ (purely-complex)
		-- if b_real == 0 and b_complex ~= 0 then
		-- 	error("error purely complex")
		-- end
		-- Case: 0 ^ +real
		if b_real > 0 then
			return 0, 0
		end
		-- Case: 0 ^ -real
		-- if b_real < 0 then
		-- 	error("error negative real")
		-- end
		
	-- Simple case: real ^ real
	elseif a_complex == 0 and b_complex then
		return a_real ^ b_real, 0
	end
	
	-- Main case: complex ^ complex
	local base_dot_product = a_real ^ 2 + a_complex ^ 2
	local base_argument = math.atan2(a_complex, a_real)
	
	local term_1 = base_dot_product ^ (b_real / 2)
	local term_2 = math.exp(-b_complex * base_argument)
	local term_12 = term_1 * term_2
	
	local term_3_arg = b_real * base_argument + b_complex * math.log(base_dot_product) / 2
	local term_3_real = math.cos(term_3_arg)
	local term_3_complex = math.sin(term_3_arg)
	
	return term_12 * term_3_real,
		term_12 * term_3_complex
end


-- ** CONSTRUCTORS ** --

--[[
Constructor: Creates a new `RawComplexNumber` object from `real`, and `complex`.
This expression is valid for both the general form, and the rectangular form.
]]
module.newRaw = function(real: number, complex: number): RawComplexNumber
	assert(isNumber(real))
	assert(isNumber(complex))
	return {
		["real"] = real,
		["complex"] = complex
	}
end

--[[
Constructor: Creates a new `ComplexNumber` object from `real`, and `complex`.
This expression is valid for both the general form, and the rectangular form.
]]
module.new = function(real: number, complex: number): ComplexNumber
	assert(isNumber(real), `Failed to construct a new <ComplexNumber> object in \`.new()\` constructor. Expected <number> primitive type for <real> (arg #1), got <{typeof(real)}>.`)
	assert(isNumber(complex), `Failed to construct a new <ComplexNumber> object in \`.new()\` constructor. Expected <number> primitive type for <complex> (arg #2), got <{typeof(complex)}>.`)
	
	local new = module.newRaw(real, complex)
	return setmetatable(new, module)
end

local complexUnit = module.new(0, 1)

--[[
Constructor: Creates a new `ComplexNumber` object that is equivalent to (1 + 0𝒊).
This constructor essentially creates and returns a unit for the real component.
]]
module.real_unit = function(): ComplexNumber
	return setmetatable({
		["real"] = 1,
		["complex"] = 0
	}, module)
end

--[[
Constructor: Creates a new `ComplexNumber` object that is equivalent to (0 + 1𝒊).
This constructor essentially creates and returns the imaginary unit.
]]
module.complex_unit = function(): ComplexNumber
	return setmetatable({
		["real"] = 0,
		["complex"] = 1
	}, module)
end

--[[
Constructor: Creates a new `ComplexNumber` object from a valid `RawComplexNumber` type. Refer to Documentation for more details about this type.
This expression is valid for both the general form, and the rectangular form.
]]
module.fromRaw = function(raw: RawComplexNumber): ComplexNumber
	assert(isRawComplexNumber(raw), `Failed to construct a new <ComplexNumber> object in \`.fromRaw()\` constructor. Expected <RawComplexNumber> type for <raw> (arg #1), got <{typeof(raw)}>.`)
	
	local new = module.newRaw(raw.real, raw.complex)
	return setmetatable(new, module)
end

--[[
Constructor: Creates a new `ComplexNumber` object from `magnitude`, and `argument` (angle in radians).
This expression is valid for the polar form. After creation, the `ComplexNumber` object will be in the general form.
]]
module.fromPolar = function(magnitude: number, argument: number): ComplexNumber
	assert(isNumber(magnitude), `Failed to construct a new <ComplexNumber> object in \`.fromPolar()\` constructor. Expected <number> primitive type for <magnitude> (arg #1), got <{typeof(magnitude)}>.`)
	assert(isNumber(argument), `Failed to construct a new <ComplexNumber> object in \`.fromPolar()\` constructor. Expected <number> primitive type for <argument> (arg #2), got <{typeof(argument)}>.`)
	
	local real = magnitude * math.cos(argument)
	local complex = magnitude * math.sin(argument)
	
	local new = module.newRaw(real, complex)
	return setmetatable(new, module)
end


-- ** FUNCTIONS ** --

--[[
Function: Computes the trigonometric function `cis(theta)` with angle <theta> (in radians).
Equivalent to computing 'cos(theta) + 𝒊 sin(theta)', or Euler's formula.
]]
module.cis = function(theta: number): ComplexNumber
	assert(isNumber(theta), `Failed to compute \`.cis()\` function. Expected <number> primitive type for <theta> (arg #1), got <{typeof(theta)}>.`)
	
	local cosine = math.cos(theta)
	local sine = math.sin(theta) * complexUnit
	return cosine + sine
end


-- ** METHODS ** --

-- Method: Creates a new `ComplexNumber` object, whose real, and imaginary parts are copied from `self`.
module.clone = function(self: ComplexNumber): ComplexNumber
	assert(isComplexNumber(self), `Failed to perform \`:clone()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return module.new(self.real, self.complex)
end

--[[
Method: Computes the magnitude (modulus/absolute value) of `self`.
Similarly, using `#` operator on a <ComplexNumber> object returns this result.
]]
module.magnitude = function(self: ComplexNumber): number
	assert(isComplexNumber(self), `Failed to perform \`:magnitude()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

-- Method: Computes the complex argument (counter-clockwise angle from the positive real axis) of `self`.
module.argument = function(self: ComplexNumber): number
	assert(isComplexNumber(self), `Failed to perform \`:argument()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return math.atan2(self.complex, self.real)
end

-- Method: Creates a new <ComplexNumber> object that is the complex conjugate of `self`.
module.conjugate = function(self: ComplexNumber): ComplexNumber
	assert(isComplexNumber(self), `Failed to perform \`:conjugate()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return module.new(self.real, -self.complex)
end

-- Method: Returns both the magnitude, and the complex argument of `self`.
module.polar = function(self: ComplexNumber): (number, number)
	assert(isComplexNumber(self), `Failed to perform \`:polar()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	local r = self:magnitude()
	local phi = self:argument()
	return r, phi
end


-- ** RAW METHODS ** --
-- ** RAW METHODS - BASIC ARITHMETIC OPERATION ** --

-- RawMethod: Modify the components of `self` into its additive inverse.
module.raw_unm = function(self: ObjectOnly): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_unm()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	self = self :: ObjectOnly
	self.real = -self.real
	self.complex = -self.complex
	return true
end

-- RawMethod: Modify the components of `self` by performing complex addition to it for each operand.
module.raw_add = function(self: ObjectOnly, ...: AnyNumber): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_add()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local real, complex = self.real, self.complex
	for idx, complex_num in ipairs({...}) do
		local isnum, isobj = isNumber(complex_num::number), isRawComplexNumber(complex_num::ObjectOnly)
		
		if isnum then
			complex_num = complex_num :: number
			real, complex = Complex_Addition(real, complex, complex_num, 0)
			
		elseif isobj then
			complex_num = complex_num :: ObjectOnly
			real, complex = Complex_Addition(real, complex, complex_num.real, complex_num.complex)
			
		else
			ThrowTypeError(
				":raw_add()", "raw method",
				"AnyNumber", "...", idx + 1, complex_num
			)
		end
	end
	
	self.real = real
	self.complex = complex
	return true
end

-- RawMethod: Modify the components of `self` by performing complex subtraction to it for each operand.
module.raw_sub = function(self: ObjectOnly, ...: AnyNumber): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_sub()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local real, complex = self.real, self.complex
	for idx, complex_num in ipairs({...}) do
		local isnum, isobj = isNumber(complex_num::number), isRawComplexNumber(complex_num::ObjectOnly)
		
		if isnum then
			complex_num = complex_num :: number
			real, complex = Complex_Subtraction(real, complex, complex_num, 0)
			
		elseif isobj then
			complex_num = complex_num :: ObjectOnly
			real, complex = Complex_Subtraction(real, complex, complex_num.real, complex_num.complex)
			
		else
			ThrowTypeError(
				":raw_sub()", "raw method",
				"AnyNumber", "...", idx + 1, complex_num
			)
		end
	end
	
	self.real = real
	self.complex = complex
	return true
end

-- RawMethod: Modify the components of `self` by performing complex multiplication to it for each operand.
module.raw_mul = function(self: ObjectOnly, ...: AnyNumber): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_mul()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local real, complex = self.real, self.complex
	for idx, complex_num in ipairs({...}) do
		local isnum, isobj = isNumber(complex_num::number), isRawComplexNumber(complex_num::ObjectOnly)
		
		if isnum then
			complex_num = complex_num :: number
			real, complex = Complex_Multiplication(real, complex, complex_num, 0)
			
		elseif isobj then
			complex_num = complex_num :: ObjectOnly
			real, complex = Complex_Multiplication(real, complex, complex_num.real, complex_num.complex)
			
		else
			ThrowTypeError(
				":raw_mul()", "raw method",
				"AnyNumber", "...", idx + 1, complex_num
			)
		end
	end
	
	self.real = real
	self.complex = complex
	return true
end

-- RawMethod: Modify the components of `self` by performing complex division to it for each operand.
module.raw_div = function(self: ObjectOnly, ...: AnyNumber): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_div()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local real, complex = self.real, self.complex
	for idx, complex_num in ipairs({...}) do
		local isnum, isobj = isNumber(complex_num::number), isRawComplexNumber(complex_num::ObjectOnly)
		
		if isnum then
			complex_num = complex_num :: number
			
			if complex_num == 0 then
				ThrowDivisionBy0Error(
					":raw_div()", "raw method",
					"...", idx + 1
				)
			end
			
			real, complex = Complex_Division(real, complex, complex_num, 0)
			
		elseif isobj then
			complex_num = complex_num :: ObjectOnly
			
			if complex_num.real == 0 and complex_num.complex == 0 then
				ThrowDivisionBy0Error(
					":raw_div()", "raw method",
					"...", idx + 1
				)
			end
			
			real, complex = Complex_Division(real, complex, complex_num.real, complex_num.complex)
			
		else
			ThrowTypeError(
				":raw_div()", "raw method",
				"AnyNumber", "...", idx + 1, complex_num
			)
		end
	end
	
	self.real = real
	self.complex = complex
	return true
end

-- RawMethod: Modify the components of `self` by performing complex int division to it for each operand.
module.raw_idiv = function(self: ObjectOnly, ...: AnyNumber): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_idiv()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local real, complex = self.real, self.complex
	for idx, complex_num in ipairs({...}) do
		local isnum, isobj = isNumber(complex_num::number), isRawComplexNumber(complex_num::ObjectOnly)
		
		if isnum then
			complex_num = complex_num :: number
			
			if complex_num == 0 then
				ThrowDivisionBy0Error(
					":raw_idiv()", "raw method",
					"...", idx + 1
				)
			end
			
			real, complex = Complex_Division(real, complex, complex_num, 0)
			
		elseif isobj then
			complex_num = complex_num :: ObjectOnly
			
			if complex_num.real == 0 and complex_num.complex == 0 then
				ThrowDivisionBy0Error(
					":raw_idiv()", "raw method",
					"...", idx + 1
				)
			end
			
			real, complex = Complex_Division(real, complex, complex_num.real, complex_num.complex)
			
		else
			ThrowTypeError(
				":raw_idiv()", "raw method",
				"AnyNumber", "...", idx + 1, complex_num
			)
		end
		
		real, complex = math.floor(real), math.floor(complex)
	end
	
	self.real = real
	self.complex = complex
	return true
end

-- RawMethod: Throws an error.
module.raw_mod = function(): nil
	error("This is an invalid operation as of now.")
end

-- RawMethod: Modify the components of `self` by performing complex exponentiation to it for each operand.
module.raw_pow = function(self: ObjectOnly, ...: AnyNumber): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_pow()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local real, complex = self.real, self.complex
	for idx, complex_num in ipairs({...}) do
		local isnum, isobj = isNumber(complex_num::number), isRawComplexNumber(complex_num::ObjectOnly)
		
		if isnum then
			complex_num = complex_num :: number
			
			if complex_num == 0 then
				ThrowDivisionBy0Error(
					":raw_pow()", "raw method",
					"...", idx + 1
				)
			end
			
			real, complex = Complex_Exponentiation(real, complex, complex_num, 0)
			
		elseif isobj then
			complex_num = complex_num :: ObjectOnly
			
			if complex_num.real == 0 and complex_num.complex == 0 then
				ThrowDivisionBy0Error(
					":raw_pow()", "raw method",
					"...", idx + 1
				)
			end
			
			if complex_num.real == 0 and complex_num.complex ~= 0 then
				ThrowUndefinedLimitError(
					":raw_pow()", "raw method",
					"...", idx + 1
				)
			end
			
			real, complex = Complex_Exponentiation(real, complex, complex_num.real, complex_num.complex)
			
		else
			ThrowTypeError(
				":raw_pow()", "raw method",
				"AnyNumber", "...", idx + 1, complex_num
			)
		end
	end
	
	self.real = real
	self.complex = complex
	return true
end


-- ** RAW METHODS - EQUALITY COMPARISON ** --

-- RawMethod: Returns a boolean determining whether `self` is equivalent to every operands.
module.raw_eq = function(self: ObjectOnly, ...: ObjectOnly): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_eq()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		if not isRawComplexNumber(self) then
			ThrowTypeError(
				":raw_eq()", "raw method",
				"ObjectOnly", "...", idx + 1, complex_num
			)
		end
		
		local cur_magnitude = complex_num.real ^ 2 + complex_num.complex ^ 2
		
		if self_magnitude ~= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is less than every operands.
module.raw_lt = function(self: ObjectOnly, ...: ObjectOnly): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_lt()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end	
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		if not isRawComplexNumber(self) then
			ThrowTypeError(
				":raw_eq()", "raw method",
				"ObjectOnly", "...", idx + 1, complex_num
			)
		end
		
		local cur_magnitude = complex_num.real ^ 2 + complex_num.complex ^ 2
		
		if self_magnitude >= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is less than or equal to every operands.
module.raw_le = function(self: ObjectOnly, ...: ObjectOnly): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_le()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		if not isRawComplexNumber(self) then
			ThrowTypeError(
				":raw_le()", "raw method",
				"ObjectOnly", "...", idx + 1, complex_num
			)
		end
		
		local cur_magnitude = complex_num.real ^ 2 + complex_num.complex ^ 2
		
		if self_magnitude > cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is greater than every operands.
module.raw_gt = function(self: ObjectOnly, ...: ObjectOnly): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_gt()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		if not isRawComplexNumber(self) then
			ThrowTypeError(
				":raw_gt()", "raw method",
				"ObjectOnly", "...", idx + 1, complex_num
			)
		end
		
		local cur_magnitude = complex_num.real ^ 2 + complex_num.complex ^ 2
		
		-- not greater than -> less than or equal to
		if self_magnitude <= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is greater than or equal to every operands.
module.raw_ge = function(self: ObjectOnly, ...: ObjectOnly): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_ge()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		if not isRawComplexNumber(self) then
			ThrowTypeError(
				":raw_ge()", "raw method",
				"ObjectOnly", "...", idx + 1, complex_num
			)
		end
		
		local cur_magnitude = complex_num.real ^ 2 + complex_num.complex ^ 2
		
		-- not greater than or equal to -> less than
		if self_magnitude < cur_magnitude then
			return false
		end
	end
	
	return true
end


-- ** RAW METHODS - FROM METHOD ** --

-- RawMethod: Computes the magnitude (modulus/absolute value) of `self`. Accepts valid `RawComplexNumber` types.
module.raw_magnitude = function(self: ObjectOnly): number
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_magnitude()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

-- RawMethod: Computes the complex argument (counter-clockwise angle from the positive real axis) of `self`. Accepts valid `RawComplexNumber` types.
module.raw_argument = function(self: ObjectOnly): number
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_argument()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	return math.atan2(self.complex, self.real)
end

-- RawMethod: Modify `self` to its conjugate.
module.raw_conjugate = function(self: ObjectOnly): boolean
	if not isRawComplexNumber(self) then
		ThrowTypeError(
			":raw_conjugate()", "raw method",
			"ObjectOnly", "self", 1, self
		)
	end
	
	self.complex = -self.complex
	return true
end


-- ** RAW METHODS - OTHER ** --

--[[
RawMethod: Create a <string> representation formatted to display `self`, according to <representation>.
Optional <representation> can be either "general", "rectangular", "polar". By default, always displays in "general" form.
]]
module.raw_tostring = function(self: RawComplexNumber, representation: ("general" | "rectangular" | "polar" | "euler")?): string
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_tostring()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	representation = representation :: ("general" | "rectangular" | "polar" | "euler")
	
	if representation == "rectangular" then
		return `({self.real}, {self.complex})`
		
	elseif representation == "polar" then
		local magnitude = math.sqrt(self.real ^ 2 + self.complex ^ 2)
		local argument = math.atan2(self.complex, self.real)
		
		return `{magnitude} 𝐜𝐢𝐬 {argument}`
		
	elseif representation == "euler" then
		local magnitude = math.sqrt(self.real ^ 2 + self.complex ^ 2)
		local argument = math.atan2(self.complex, self.real)
		
		return `{magnitude} 𝒆^({argument}𝒊)`
	end
	
	local complex_sign = tostring_signs[math.sign(self.complex) + 2]
	local complex_number = math.abs(self.complex)
	
	return `({self.real} {complex_sign} {complex_number}𝒊)`
end


-- ** METAMETHODS ** --
-- ** METAMETHODS - INITIAL ** --

module.__index = module

module.__newindex = function(t: ComplexNumber, key: any, value: any): nil
	error(`Attempted to create a new index/key in <ComplexNumber> object.\nObject representation: {t}\nIndex/Key: {key}\nValue: {value}`)
end

module.__metatable = "ComplexNumber"


-- ** METAMETHODS - BASIC ARITHMETIC OPERATION ** --

module.__unm = function(self: ComplexNumber): ComplexNumber
	if not isComplexNumber(self) then
		ThrowTypeError(
			"__unm()", "metamethod",
			"ComplexNumber", "self", 1, self
		)
	end
	
	self.real = -self.real
	self.complex = -self.complex
	return self
end

module.__add = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local isnum_a, isobj_a = isNumber(a::number), isRawComplexNumber(a::ObjectOnly)
	local isnum_b, isobj_b = isNumber(b::number), isRawComplexNumber(b::ObjectOnly)
	
	if not (isnum_a or isobj_a) then
		ThrowTypeError(
			"__add()", "metamethod",
			"AnyNumber", "a", 1, a
		)
	end
	
	if not (isnum_b or isobj_b) then
		ThrowTypeError(
			"__add()", "metamethod",
			"AnyNumber", "b", 2, b
		)
	end
	
	local real, complex
	if isnum_a or isnum_b then
		if isnum_a then
			a, b = b, a
		end
		
		a = a :: ComplexNumber
		b = b :: number
		real, complex = Complex_Addition(a.real, a.complex, b, 0)
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		real, complex = Complex_Addition(a.real, a.complex, b.real, b.complex)
	end
	
	return module.new(real, complex)
end

module.__sub = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local isnum_a, isobj_a = isNumber(a::number), isRawComplexNumber(a::ObjectOnly)
	local isnum_b, isobj_b = isNumber(b::number), isRawComplexNumber(b::ObjectOnly)
	
	if not (isnum_a or isobj_a) then
		ThrowTypeError(
			"__sub()", "metamethod",
			"AnyNumber", "a", 1, a
		)
	end
	
	if not (isnum_b or isobj_b) then
		ThrowTypeError(
			"__sub()", "metamethod",
			"AnyNumber", "b", 2, b
		)
	end
	
	local real, complex
	if isnum_a then
		a = a :: number
		b = b :: ObjectOnly
		real, complex = Complex_Subtraction(a, 0, b.real, b.complex)
		
	elseif isnum_b then
		a = a :: ObjectOnly
		b = b :: number
		real, complex = Complex_Subtraction(a.real, a.complex, b, 0)
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		real, complex = Complex_Subtraction(a.real, a.complex, b.real, b.complex)
	end
	
	return module.new(real, complex)
end

module.__mul = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local isnum_a, isobj_a = isNumber(a::number), isRawComplexNumber(a::ObjectOnly)
	local isnum_b, isobj_b = isNumber(b::number), isRawComplexNumber(b::ObjectOnly)
	
	if not (isnum_a or isobj_a) then
		ThrowTypeError(
			"__mul()", "metamethod",
			"AnyNumber", "a", 1, a
		)
	end
	
	if not (isnum_b or isobj_b) then
		ThrowTypeError(
			"__mul()", "metamethod",
			"AnyNumber", "b", 2, b
		)
	end
	
	local real, complex
	if isnum_a or isnum_b then
		if isnum_a then
			a, b = b, a
		end
		
		a = a :: ComplexNumber
		b = b :: number
		real, complex = Complex_Multiplication(a.real, a.complex, b, 0)
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		real, complex = Complex_Multiplication(a.real, a.complex, b.real, b.complex)
	end
	
	return module.new(real, complex)
end

module.__div = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local isnum_a, isobj_a = isNumber(a::number), isRawComplexNumber(a::ObjectOnly)
	local isnum_b, isobj_b = isNumber(b::number), isRawComplexNumber(b::ObjectOnly)
	
	if not (isnum_a or isobj_a) then
		ThrowTypeError(
			"__div()", "metamethod",
			"AnyNumber", "a", 1, a
		)
	end
	
	if not (isnum_b or isobj_b) then
		ThrowTypeError(
			"__div()", "metamethod",
			"AnyNumber", "b", 2, b
		)
		
	elseif (isnum_b and b == 0) or (isobj_b and (b::ObjectOnly).real == 0 and b.complex == 0) then
		ThrowDivisionBy0Error(
			":__div()", "metamethod",
			"b", 2
		)
	end
	
	local real, complex
	if isnum_a then
		a = a :: number
		b = b :: ObjectOnly
		real, complex = Complex_Division(a, 0, b.real, b.complex)
		
	elseif isnum_b then
		a = a :: ObjectOnly
		b = b :: number
		real, complex = Complex_Division(a.real, a.complex, b, 0)
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		real, complex = Complex_Division(a.real, a.complex, b.real, b.complex)
	end
	
	return module.new(real, complex)
end

module.__idiv = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local isnum_a, isobj_a = isNumber(a::number), isRawComplexNumber(a::ObjectOnly)
	local isnum_b, isobj_b = isNumber(b::number), isRawComplexNumber(b::ObjectOnly)
	
	if not (isnum_a or isobj_a) then
		ThrowTypeError(
			"__idiv()", "metamethod",
			"AnyNumber", "a", 1, a
		)
	end
	
	if not (isnum_b or isobj_b) then
		ThrowTypeError(
			"__idiv()", "metamethod",
			"AnyNumber", "b", 2, b
		)
		
	elseif (isnum_b and b == 0) or (isobj_b and (b::ObjectOnly).real == 0 and b.complex == 0) then
		ThrowDivisionBy0Error(
			":__idiv()", "metamethod",
			"b", 2
		)
	end
	
	local real, complex
	if isnum_a then
		a = a :: number
		b = b :: ObjectOnly
		real, complex = Complex_Division(a, 0, b.real, b.complex)
		
	elseif isnum_b then
		a = a :: ObjectOnly
		b = b :: number
		real, complex = Complex_Division(a.real, a.complex, b, 0)
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		real, complex = Complex_Division(a.real, a.complex, b.real, b.complex)
	end
	
	return module.new(math.floor(real), math.floor(complex))
end

module.__mod = function(): nil
	error("This is an invalid operation as of now.")
end

module.__pow = function(a: AnyNumber, b: AnyNumber): ComplexNumber
	local isnum_a, isobj_a = isNumber(a::number), isRawComplexNumber(a::ObjectOnly)
	local isnum_b, isobj_b = isNumber(b::number), isRawComplexNumber(b::ObjectOnly)
	
	if not (isnum_a or isobj_a) then
		ThrowTypeError(
			"__pow()", "metamethod",
			"AnyNumber", "a", 1, a
		)
	end
	
	if not (isnum_b or isobj_b) then
		ThrowTypeError(
			"__pow()", "metamethod",
			"AnyNumber", "b", 2, b
		)
		
	elseif (isnum_b and b == 0) or (isobj_b and (b::ObjectOnly).real == 0 and b.complex == 0) then
		ThrowDivisionBy0Error(
			":__pow()", "metamethod",
			"b", 2
		)
		
	elseif isobj_b and (b::ObjectOnly).real == 0 and b.complex ~= 0 then 
		ThrowUndefinedLimitError(
			":__pow()", "metamethod",
			"b", 2
		)
	end
	
	local real, complex
	if isnum_a then
		a = a :: number
		b = b :: ObjectOnly
		real, complex = Complex_Exponentiation(a, 0, b.real, b.complex)
		
	elseif isnum_b then
		a = a :: ObjectOnly
		b = b :: number
		real, complex = Complex_Exponentiation(a.real, a.complex, b, 0)
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		real, complex = Complex_Exponentiation(a.real, a.complex, b.real, b.complex)
	end
	
	return module.new(real, complex)
end


-- ** METAMETHODS - EQUALITY COMPARISON ** --

module.__eq = function(a: ComplexNumber, b: ComplexNumber): boolean
	if not isComplexNumber(a) then
		ThrowTypeError(
			"__eq()", "metamethod",
			"ComplexNumber", "a", 1, a
		)
	end
	
	if not isComplexNumber(b) then
		ThrowTypeError(
			"__eq()", "metamethod",
			"ComplexNumber", "b", 2, b
		)
	end
	
	local magnitude_A = a.real ^ 2 + a.complex ^ 2
	local magnitude_B = b.real ^ 2 + b.complex ^ 2
	return magnitude_A == magnitude_B
end

module.__lt = function(a: ComplexNumber, b: ComplexNumber): boolean
	if not isComplexNumber(a) then
		ThrowTypeError(
			"__lt()", "metamethod",
			"ComplexNumber", "a", 1, a
		)
	end
	
	if not isComplexNumber(b) then
		ThrowTypeError(
			"__lt()", "metamethod",
			"ComplexNumber", "b", 2, b
		)
	end
	
	local magnitude_A = a.real ^ 2 + a.complex ^ 2
	local magnitude_B = b.real ^ 2 + b.complex ^ 2
	return magnitude_A < magnitude_B
end

module.__le = function(a: ComplexNumber, b: ComplexNumber): boolean
	if not isComplexNumber(a) then
		ThrowTypeError(
			"__le()", "metamethod",
			"ComplexNumber", "a", 1, a
		)
	end
	
	if not isComplexNumber(b) then
		ThrowTypeError(
			"__le()", "metamethod",
			"ComplexNumber", "b", 2, b
		)
	end
	
	local magnitude_A = a.real ^ 2 + a.complex ^ 2
	local magnitude_B = b.real ^ 2 + b.complex ^ 2
	return magnitude_A <= magnitude_B
end


-- ** METAMETHODS - OTHER ** --

module.__len = function(self: ComplexNumber): number
	if not isComplexNumber(self) then
		ThrowTypeError(
			"__len()", "metamethod",
			"ComplexNumber", "self", 1, self
		)
	end
	
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

module.__tostring = function(self: ComplexNumber): string
	if not isComplexNumber(self) then
		ThrowTypeError(
			"__tostring()", "metamethod",
			"ComplexNumber", "self", 1, self
		)
	end
	
	local complex_sign = tostring_signs[math.sign(self.complex) + 2]
	local complex_number = math.abs(self.complex)
	
	return `({self.real} {complex_sign} {complex_number}𝒊)`
end

return module
