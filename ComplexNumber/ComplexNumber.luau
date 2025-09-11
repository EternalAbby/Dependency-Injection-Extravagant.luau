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
	
	if not isNumber(candidate.real) then
		return false
	end
	
	if not isNumber(candidate.complex) then
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
	
	if not isNumber(candidate.real) then
		return false
	end
	
	if not isNumber(candidate.complex) then
		return false
	end
	
	return true
end

local function GetNumberComponentTypes(candidate: ComplexNumber | number): (boolean, boolean)
	return isNumber(candidate::number), isComplexNumber(candidate::ComplexNumber)
end

local function GNCT(candidate: AnyNumber): (boolean, boolean, boolean)
	return isNumber(candidate::number), isRawComplexNumber(candidate::RawComplexNumber), isComplexNumber(candidate::ComplexNumber)
end

-- Computes complex addition and returns the real and complex components.
local function Complex_Addition(a: AnyNumber, b: AnyNumber, err_msg_a: string, err_msg_b: string, ignore_A: boolean?, ignore_B: boolean?): (number, number)
	local isnum_A, israw_A, iscomplex_A = GNCT(a)
	local isnum_B, israw_B, iscomplex_B = GNCT(b)
	
	if not ignore_A then
		assert(isnum_A or israw_A or iscomplex_A, err_msg_a)
	end
	if not ignore_B then
		assert(isnum_B or israw_B or iscomplex_B, err_msg_b)
	end
	
	local real, complex = 0, 0
	
	if isnum_A or isnum_B then
		if isnum_A then
			a, b = b, a
		end
		
		a = a :: ObjectOnly
		b = b :: number
		
		real = a.real + b
		complex = a.complex
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		
		real = a.real + b.real
		complex = a.complex + b.complex
	end
	
	return real, complex
end

-- Computes complex subtraction and returns the real and complex components.
local function Complex_Subtraction(a: AnyNumber, b: AnyNumber, err_msg_a: string, err_msg_b: string, ignore_A: boolean?, ignore_B: boolean?): (number, number)
	local isnum_A, israw_A, iscomplex_A = GNCT(a)
	local isnum_B, israw_B, iscomplex_B = GNCT(b)
	
	if not ignore_A then
		assert(isnum_A or israw_A or iscomplex_A, err_msg_a)
	end
	if not ignore_B then
		assert(isnum_B or israw_B or iscomplex_B, err_msg_b)
	end
	
	local real, complex = 0, 0
	
	if isnum_A or isnum_B then
		if isnum_A then
			a, b = b, a
		end
		
		a = a :: ObjectOnly
		b = b :: number
		
		real = a.real - b
		complex = a.complex
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		
		real = a.real - b.real
		complex = a.complex - b.complex
	end
	
	return real, complex
end

-- Computes complex multiplication and returns the real and complex components.
local function Complex_Multiplication(a: AnyNumber, b: AnyNumber, err_msg_a: string, err_msg_b: string, ignore_A: boolean?, ignore_B: boolean?): (number, number)
	local isnum_A, israw_A, iscomplex_A = GNCT(a)
	local isnum_B, israw_B, iscomplex_B = GNCT(b)
	
	if not ignore_A then
		assert(isnum_A or israw_A or iscomplex_A, err_msg_a)
	end
	if not ignore_B then
		assert(isnum_B or israw_B or iscomplex_B, err_msg_b)
	end
	
	local real, complex = 0, 0
	
	if isnum_A or isnum_B then
		if isnum_A then
			a, b = b, a
		end
		
		a = a :: ObjectOnly
		b = b :: number
		
		real = a.real * b
		complex = a.complex * b
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		
		real = a.real * b.real - a.complex * b.complex
		complex = a.real * b.complex + a.complex * b.real
	end
	
	return real, complex
end

-- Computes complex division and returns the real and complex components.
local function Complex_Division(a: AnyNumber, b: AnyNumber, err_msg_a: string, err_msg_b: string, err_msg_div0: string, ignore_A: boolean?, ignore_B: boolean?): (number, number)
	local isnum_A, israw_A, iscomplex_A = GNCT(a)
	local isnum_B, israw_B, iscomplex_B = GNCT(b)
	
	if not ignore_A then
		assert(isnum_A or israw_A or iscomplex_A, err_msg_a)
	end
	if not ignore_B then
		assert(isnum_B or israw_B or iscomplex_B, err_msg_b)
	end
	
	local real, complex = 0, 0
	
	if isnum_A or isnum_B then
		if isnum_A then
			a, b = b, a
		end
		
		a = a :: ObjectOnly
		b = b :: number
		
		assert(b ~= 0, err_msg_div0)
		
		local real_numerator = a.real * b
		local complex_numerator = a.complex * b
		local denominator = b ^ 2
		
		real = real_numerator / denominator
		complex = complex_numerator / denominator
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		
		assert(b.real ~= 0 and b.complex ~= 0, err_msg_div0)
		
		local real_numerator = a.real * b.real + a.complex * b.complex
		local complex_numerator = a.complex * b.real - a.real * b.complex
		local denominator = b.real ^ 2 + b.complex ^ 2
		
		real = real_numerator / denominator
		complex = complex_numerator / denominator
	end
	
	return real, complex
end

-- Computes complex exponentiation and returns the real and complex components.
local function Complex_Exponentiation(a: AnyNumber, b: AnyNumber, err_msg_a: string, err_msg_b: string, err_msg_div0: string, err_msg_0_pow_cmplx: string, ignore_A: boolean?, ignore_B: boolean?): (number, number)
	-- TODO: test this function as its complexity isn't easy to perform mental calculation easily
	local isnum_A, israw_A, iscomplex_A = GNCT(a)
	local isnum_B, israw_B, iscomplex_B = GNCT(b)
	
	if not ignore_A then
		assert(isnum_A or israw_A or iscomplex_A, err_msg_a)
	end
	if not ignore_B then
		assert(isnum_B or israw_B or iscomplex_B, err_msg_b)
	end
	
	local real, complex = 0, 0
	
	if isnum_A or isnum_B then
		if isnum_A then
			a, b = b, a
		end
		
		a = a :: ObjectOnly
		b = b :: number
		
		-- Simple case: complex ^ 0
		if b == 0 then
			return 1, 0
		end
		
		-- Simple case: 0 ^ number
		if a.real == 0 and a.complex == 0 then
			
			-- Case: 0 ^ +real
			if b > 0 then
				return 0, 0
				
			-- Case: 0 ^ -real
			elseif b < 0 then
				error(err_msg_div0)
			end
			
		-- Simple case: real ^ real
		elseif a.complex == 0 then
			return a.real ^ b, 0
		end
		
		-- Main case: complex ^ real
		local base_dot_product = a.real ^ 2 + a.complex ^ 2
		local base_argument = math.atan2(a.complex, a.real)
		
		local term_1 = base_dot_product ^ (b / 2)
		local term_3_arg = b * base_argument
		local term_3_real = math.cos(term_3_arg)
		local term_3_complex = math.sin(term_3_arg)
		
		real = term_1 * term_3_real
		complex = term_1 * term_3_complex
		
	else
		a = a :: ObjectOnly
		b = b :: ObjectOnly
		
		-- Simple case: complex ^ 0
		if b.real == 0 and b.complex == 0 then
			return 1, 0
		end
		
		-- Simple case: 0 ^ number
		if a.real == 0 and a.complex == 0 then
			
			-- Case: 0 ^ (purely-complex)
			if b.real == 0 and b.complex ~= 0 then
				error(err_msg_0_pow_cmplx)
				
			-- Case: 0 ^ +real
			elseif b.real > 0 then
				return 0, 0
				
			-- Case: 0 ^ -real
			elseif b.real < 0 then
				error(err_msg_div0)
			end
			
		-- Simple case: real ^ real
		elseif a.complex == 0 and b.complex then
			return a.real ^ b.real, 0
		end
		
		-- Main case: complex ^ complex
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
	
	return real, complex
end

-- ** CONSTRUCTORS ** --

--[[
Constructor: Creates a new `RawComplexNumber` object from `real`, and `complex`.
This expression is valid for both the general form, and the rectangular form.
]]
module.newRaw = function(real: number, complex: number): RawComplexNumber
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
module.raw_unm = function(self: RawComplexNumber): boolean
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_unm()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	self.real = -self.real
	self.complex = -self.complex
	
	return true
end

-- RawMethod: Modify the components of `self` by performing complex addition to it for each operand.
module.raw_add = function(self: RawComplexNumber, ...: RawComplexNumber | number): boolean
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_add()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		local isnum, israwcomplex = isNumber(complex_num::number), isRawComplexNumber(complex_num::RawComplexNumber)
		
		assert(isnum or israwcomplex, `Failed to perform \`:raw_add()\` raw method. Expected <number> primitive type or <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		if isnum then
			complex_num = complex_num :: number
			
			self.real += complex_num
			
		elseif israwcomplex then
			complex_num = complex_num :: RawComplexNumber
			
			self.real += complex_num.real
			self.complex += complex_num.complex
		end
	end
	
	return true
end

-- RawMethod: Modify the components of `self` by performing complex subtraction to it for each operand.
module.raw_sub = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_sub()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_sub()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		self.real -= complex_num.real
		self.complex -= complex_num.complex
	end
	
	return nil
end

-- RawMethod: Modify the components of `self` by performing complex multiplication to it for each operand.
module.raw_mul = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_mul()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_mul()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local real = self.real * complex_num.real - self.complex * complex_num.complex
		local complex = self.real * complex_num.complex + self.complex * complex_num.real
		
		self.real = real
		self.complex = complex
	end
	
	return nil
end

-- RawMethod: Modify the components of `self` by performing complex division to it for each operand.
module.raw_div = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_div()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_div()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		assert(complex_num.real ~= 0 and complex_num.complex ~= 0, `Attempted to perform division by zero. (arg #{idx + 1})`)
		
		local real_numerator = self.real * complex_num.real + self.complex * complex_num.complex
		local complex_numerator = self.complex * complex_num.real - self.real * complex_num.complex
		local denominator = complex_num.real^2 + complex_num.complex^2
		
		local real = real_numerator / denominator
		local complex = complex_numerator / denominator
		
		self.real = real
		self.complex = complex
	end
	
	return nil
end

-- RawMethod: Modify the components of `self` by performing complex int division to it for each operand.
module.raw_idiv = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_idiv()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_idiv()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		assert(complex_num.real ~= 0 and complex_num.complex ~= 0, "Attempted to perform division by zero.")
		
		local real_numerator = self.real * complex_num.real + self.complex * complex_num.complex
		local complex_numerator = self.complex * complex_num.real - self.real * complex_num.complex
		local denominator = complex_num.real^2 + complex_num.complex^2
		
		local real = real_numerator / denominator
		local complex = complex_numerator / denominator
		
		self.real = math.floor(real)
		self.complex = math.floor(complex)
	end
	
	return nil
end

-- RawMethod: Throws an error.
module.raw_mod = function(): nil
	error("This is an invalid operation as of now.")
end

-- RawMethod: Modify the components of `self` by performing complex exponentiation to it for each operand.
module.raw_pow = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_pow()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_pow()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		-- edge case: 0 ^ complex
		if self.real == 0 and self.complex == 0 then
			
			-- case: 0 ^ 0
			if complex_num.real == 0 and complex_num.complex == 0 then
				self.real = 1
				self.complex = 0
				
			-- case: 0 ^ (purely-complex)
			elseif complex_num.real == 0 and complex_num.complex ~= 0 then
				error(`Undefined limit behavior for purely imaginary exponent.`)
				
			-- case: 0 ^ +real
			elseif complex_num.real > 0 then
				self.real = 0
				self.complex = 0
				
			-- case: 0 ^ -real
			elseif complex_num.real < 0 then
				error(`Attempted to perform division by zero.`)
			end
			
		-- simple case: complex ^ 0
		elseif complex_num.real == 0 and complex_num.complex == 0 then
			self.real = 1
			self.complex = 0
			
		-- simple case: real ^ real
		elseif self.complex == 0 and complex_num.complex == 0 then
			self.real = self.real ^ complex_num.real
			
		end
		
		-- main case: complex ^ complex
		local base_magnitude_squared = self.real^2 + self.complex^2
		local base_argument = math.atan2(self.complex, self.real)
		
		local term_1 = base_magnitude_squared ^ (complex_num.real / 2)
		local term_2 = math.exp(-complex_num.complex * base_argument)
		local term_3 = module.cis(complex_num.real * base_argument + complex_num.complex * math.log(base_magnitude_squared) / 2)
		
		local res = term_1 * term_2 * term_3
		
		self.real = res.real
		self.complex = res.complex
	end
	
	return nil
end


-- ** RAW METHODS - EQUALITY COMPARISON ** --

-- RawMethod: Returns a boolean determining whether `self` is equivalent to every operands.
module.raw_eq = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_eq()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_eq()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local cur_magnitude = complex_num.real ^ 2 + complex_num.complex ^ 2
		
		-- not equal
		if self_magnitude ~= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is less than every operands.
module.raw_lt = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_lt()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_lt()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local cur_magnitude = complex_num.real ^ 2 + complex_num.complex ^ 2
		
		-- not less than -> greater or equal to
		if self_magnitude >= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is less than or equal to every operands.
module.raw_le = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_le()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_le()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local cur_magnitude = complex_num.real ^ 2 + complex_num.complex ^ 2
		
		-- not less than or equal to -> greater than
		if self_magnitude > cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is greater than every operands.
module.raw_gt = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_gt()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_gt()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local cur_magnitude = complex_num.real ^ 2 + complex_num.complex ^ 2
		
		-- not greater than -> less than or equal to
		if self_magnitude <= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether `self` is greater than or equal to every operands.
module.raw_ge = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_ge()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = self.real ^ 2 + self.complex ^ 2
	
	for idx, complex_num in ipairs({...}) do
		assert(isRawComplexNumber(complex_num), `Failed to perform \`:raw_ge()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
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
module.raw_magnitude = function(self: RawComplexNumber): number
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_magnitude()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

-- RawMethod: Computes the complex argument (counter-clockwise angle from the positive real axis) of `self`. Accepts valid `RawComplexNumber` types.
module.raw_argument = function(self: RawComplexNumber): number
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_argument()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return math.atan2(self.complex, self.real)
end

-- RawMethod: Modify `self` to its conjugate.
module.raw_conjugate = function(self: RawComplexNumber): nil
	assert(isRawComplexNumber(self), `Failed to perform \`:raw_conjugate()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	self.complex = -self.complex
	
	return nil
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
	assert(isComplexNumber(self), `Failed to perform \`__unm()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <a> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: ComplexNumber
	
	self.real = -self.real
	self.complex = -self.complex
	
	return self
end

module.__add = function(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
	local isnum_A, iscomplex_A = GetNumberComponentTypes(a)
	local isnum_B, iscomplex_B = GetNumberComponentTypes(b)
	
	assert(isnum_A or iscomplex_A, `Failed to perform \`__add()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(isnum_B or iscomplex_B, `Failed to perform \`__add()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <b> (arg #2), got <{typeof(b)}>.`)
	
	if isnum_A then
		a = module.newRaw(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = module.newRaw(b::number, 0) :: ComplexNumber
	end
	
	a = a :: ComplexNumber
	b = b :: ComplexNumber
	
	local real = a.real + b.real
	local complex = a.complex + b.complex
	
	local new = module.new(real, complex)
	return new
end

module.__sub = function(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
	local isnum_A, iscomplex_A = GetNumberComponentTypes(a)
	local isnum_B, iscomplex_B = GetNumberComponentTypes(b)
	
	assert(isnum_A or iscomplex_A, `Failed to perform \`__sub()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(isnum_B or iscomplex_B, `Failed to perform \`__sub()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <b> (arg #2), got <{typeof(b)}>.`)
	
	if isnum_A then
		a = module.newRaw(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = module.newRaw(b::number, 0) :: ComplexNumber
	end
	
	a = a :: ComplexNumber
	b = b :: ComplexNumber
	
	local real = a.real - b.real
	local complex = b.real - b.complex
	
	local new = module.new(real, complex)
	return new
end

module.__mul = function(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
	local isnum_A, iscomplex_A = GetNumberComponentTypes(a)
	local isnum_B, iscomplex_B = GetNumberComponentTypes(b)
	
	assert(isnum_A or iscomplex_A, `Failed to perform \`__mul()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(isnum_B or iscomplex_B, `Failed to perform \`__mul()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <b> (arg #2), got <{typeof(b)}>.`)
	
	if isnum_A then
		a = module.newRaw(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = module.newRaw(b::number, 0) :: ComplexNumber
	end
	
	a = a :: ComplexNumber
	b = b :: ComplexNumber
	
	local real = a.real * b.real - a.complex * b.complex
	local complex = a.real * b.complex + a.complex * b.real
	
	local new = module.new(real, complex)
	return new
end

module.__div = function(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
	local isnum_A, iscomplex_A = GetNumberComponentTypes(a)
	local isnum_B, iscomplex_B = GetNumberComponentTypes(b)
	
	assert(isnum_A or iscomplex_A, `Failed to perform \`__div()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(isnum_B or iscomplex_B, `Failed to perform \`__div()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <b> (arg #2), got <{typeof(b)}>.`)
	
	if isnum_A then
		a = module.newRaw(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = module.newRaw(b::number, 0) :: ComplexNumber
	end
	
	a = a :: ComplexNumber
	b = b :: ComplexNumber
	
	assert(b.real ~= 0 and b.complex ~= 0, `Failed to perform \`__div()\` metamethod. Attempted to perform division by zero. Expected non-zero complex number for <b> (arg #2).`)
	
	local real_numerator = a.real * b.real + a.complex * b.complex
	local complex_numerator = a.complex * b.real - a.real * b.complex
	local denominator = b.real^2 + b.complex^2
	
	local real = real_numerator / denominator
	local complex = complex_numerator / denominator
	
	local new = module.new(real, complex)
	return new
end

module.__idiv = function(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
	a = a :: ComplexNumber
	b = b :: ComplexNumber
	
	local res = a / b
	res.real = math.floor(res.real)
	res.complex = math.floor(res.complex)
	return res
end

module.__mod = function(): nil
	error("This is an invalid operation as of now.")
end

module.__pow = function(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
	local isnum_A, iscomplex_A = GetNumberComponentTypes(a)
	local isnum_B, iscomplex_B = GetNumberComponentTypes(b)
	
	assert(isnum_A or iscomplex_A, `Failed to perform \`__pow()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(isnum_B or iscomplex_B, `Failed to perform \`__pow()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <b> (arg #2), got <{typeof(b)}>.`)
	
	if isnum_A then
		a = module.newRaw(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = module.newRaw(b::number, 0) :: ComplexNumber
	end
	
	a = a :: ComplexNumber
	b = b :: ComplexNumber
	
	-- edge case: 0 ^ complex
	if a.real == 0 and a.complex == 0 then
		
		-- case: 0 ^ 0
		if b.real == 0 and b.complex == 0 then
			return module.new(1, 0)
			
		-- case: 0 ^ (purely-complex)
		elseif b.real == 0 and b.complex ~= 0 then
			error(`Undefined limit behavior for purely imaginary exponent.`)
			
		-- case: 0 ^ +real
		elseif b.real > 0 then
			return module.new(0, 0)
			
		-- case: 0 ^ -real
		elseif b.real < 0 then
			error(`Attempted to perform division by zero.`)
		end
		
	-- simple case: complex ^ 0
	elseif b.real == 0 and b.complex == 0 then
		return module.new(1, 0)
		
	-- simple case: real ^ real
	elseif a.complex == 0 and b.complex == 0 then
		return module.new(a.real ^ b.real, 0)
	end
	
	-- main case: complex ^ complex
	local base_dot_product = a.real ^ 2 + a.complex ^ 2
	local base_argument = math.atan2(a.complex, a.real)
	
	local term_1 = base_dot_product ^ (b.real / 2)
	local term_2 = math.exp(-b.complex * base_argument)
	local term_3 = module.cis(b.real * base_argument + b.complex * math.log(base_dot_product) / 2)
	return term_1 * term_2 * term_3
end


-- ** METAMETHODS - EQUALITY COMPARISON ** --

module.__eq = function(a: ComplexNumber, b: ComplexNumber): boolean
	assert(isComplexNumber(a), `Failed to perform \`__eq()\` metamethod. Expected <ComplexNumber> type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(isComplexNumber(b), `Failed to perform \`__eq()\` metamethod. Expected <ComplexNumber> type for <b> (arg #2), got <{typeof(b)}>.`)
	
	local magnitude_A = a.real ^ 2 + a.complex ^ 2
	local magnitude_B = b.real ^ 2 + b.complex ^ 2
	return magnitude_A == magnitude_B
end

module.__lt = function(a: ComplexNumber, b: ComplexNumber): boolean
	assert(isComplexNumber(a), `Failed to perform \`__lt()\` metamethod. Expected <ComplexNumber> type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(isComplexNumber(b), `Failed to perform \`__lt()\` metamethod. Expected <ComplexNumber> type for <b> (arg #2), got <{typeof(b)}>.`)
	
	local magnitude_A = a.real ^ 2 + a.complex ^ 2
	local magnitude_B = b.real ^ 2 + b.complex ^ 2
	return magnitude_A < magnitude_B
end

module.__le = function(a: ComplexNumber, b: ComplexNumber): boolean
	assert(isComplexNumber(a), `Failed to perform \`__le()\` metamethod. Expected <ComplexNumber> type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(isComplexNumber(b), `Failed to perform \`__le()\` metamethod. Expected <ComplexNumber> type for <b> (arg #2), got <{typeof(b)}>.`)
	
	local magnitude_A = a.real ^ 2 + a.complex ^ 2
	local magnitude_B = b.real ^ 2 + b.complex ^ 2
	return magnitude_A <= magnitude_B
end


-- ** METAMETHODS - OTHER ** --

module.__len = function(self: ComplexNumber): number
	assert(isComplexNumber(self), `Failed to perform \`__len()\` metamethod. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

module.__tostring = function(self: ComplexNumber): string
	assert(isComplexNumber(self), `Failed to perform \`__tostring()\` metamethod. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	local complex_sign = tostring_signs[math.sign(self.complex) + 2]
	local complex_number = math.abs(self.complex)
	
	return `({self.real} {complex_sign} {complex_number}𝒊)`
end

return module
