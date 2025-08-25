--!strict

local TypeCheck = require("../TypeCheck/TypeCheck")

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


-- ** INTERNAL FUNCTIONS ** --

local function CreateRawComplexNumber(real: number, complex: number): RawComplexNumber
	return {
		["real"] = real,
		["complex"] = complex
	}
end

local function GetNumberComponentTypes(candidate: ComplexNumber | number): (boolean, boolean)
	return TypeCheck.isNumber(candidate::number, false), TypeCheck.isComplexNumber(candidate::ComplexNumber)
end


-- ** CONSTRUCTORS ** --

--[[
Constructor: Creates a new <ComplexNumber> object from <real>, and <complex>.
This expression is valid for both the general form, and the rectangular form.
Both parameters must be a <number> primitive type, and they must not be either inf or nan.
]]
module.new = function(real: number, complex: number): ComplexNumber
	assert(TypeCheck.isNumber(real, false), `Failed to construct a new <ComplexNumber> object in \`.new()\` constructor. Expected <number> primitive type for <real> (arg #1), got <{typeof(real)}>.`)
	assert(TypeCheck.isNumber(complex, false), `Failed to construct a new <ComplexNumber> object in \`.new()\` constructor. Expected <number> primitive type for <complex> (arg #2), got <{typeof(complex)}>.`)
	
	local new = CreateRawComplexNumber(real, complex)
	return setmetatable(new, module)
end

local complexUnit = module.new(0, 1)

--[[
Constructor: Creates a new <ComplexNumber> object from a valid <RawComplexNumber> type. Refer to Documentation for more details.
This expression is valid for both the general form, and the rectangular form.
Both keys must be a <number> primitive type, and they must not be either inf or nan.
]]
module.fromRaw = function(raw: RawComplexNumber): ComplexNumber
	assert(TypeCheck.isRawComplexNumber(raw), `Failed to construct a new <ComplexNumber> object in \`.fromRaw()\` constructor. Expected <RawComplexNumber> type for <raw> (arg #1), got <{typeof(raw)}>.`)
	
	local new = CreateRawComplexNumber(raw.real, raw.complex)
	return setmetatable(new, module)
end

--[[
Constructor: Creates a new <ComplexNumber> object from <magnitude>, and <argument> (in radians).
This expression is valid for the polar form. After creation, the <ComplexNumber> object will be in the general form.
Both parameters must be a <number> primitive type, and they must not be either inf or nan.
]]
module.fromPolar = function(magnitude: number, argument: number): ComplexNumber
	assert(TypeCheck.isNumber(magnitude, false), `Failed to construct a new <ComplexNumber> object in \`.fromPolar()\` constructor. Expected <number> primitive type for <magnitude> (arg #1), got <{typeof(magnitude)}>.`)
	assert(TypeCheck.isNumber(argument, false), `Failed to construct a new <ComplexNumber> object in \`.fromPolar()\` constructor. Expected <number> primitive type for <argument> (arg #2), got <{typeof(argument)}>.`)
	
	local real = magnitude * math.cos(argument)
	local complex = magnitude * math.sin(argument)
	
	local new = CreateRawComplexNumber(real, complex)
	return setmetatable(new, module)
end

-- ** FUNCTIONS ** --

--[[
Function: Computes the trigonometric function `cis(theta)` with angle <theta> (in radians).
Equivalent to computing 'cos(theta) + 𝒊 sin(theta)', or Euler's formula.
]]
module.cis = function(theta: number): ComplexNumber
	assert(TypeCheck.isNumber(theta, false), `Failed to compute \`.cis()\` function. Expected <number> primitive type for <theta> (arg #1), got <{typeof(theta)}>.`)
	
	local cosine = math.cos(theta)
	local sine = math.sin(theta) * complexUnit
	return cosine + sine
end

--[[
compute the fast fourier transform
idk if it's possible to do
]]
module.fft = function()
	-- TBA
end

-- ** METHODS ** --

-- Method: Creates a new <ComplexNumber> object, whose real, and imaginary parts are copied from <self>.
module.clone = function(self: ComplexNumber): ComplexNumber
	assert(TypeCheck.isComplexNumber(self), `Failed to perform \`:clone()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return module.new(self.real, self.complex)
end

--[[
Method: Computes the magnitude (modulus/absolute value) of <self>.
Similarly, using `#` operator on a <ComplexNumber> object returns this result.
]]
module.magnitude = function(self: ComplexNumber): number
	assert(TypeCheck.isComplexNumber(self), `Failed to perform \`:magnitude()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return math.sqrt(self.real^2 + self.complex^2)
end

-- Method: Computes the complex argument (counter-clockwise angle from the positive real axis) of <self>.
module.argument = function(self: ComplexNumber): number
	assert(TypeCheck.isComplexNumber(self), `Failed to perform \`:argument()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return math.atan2(self.complex, self.real)
end

-- Method: Creates a new <ComplexNumber> object that is the complex conjugate of <self>.
module.conjugate = function(self: ComplexNumber): ComplexNumber
	assert(TypeCheck.isComplexNumber(self), `Failed to perform \`:conjugate()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return module.new(self.real, -self.complex)
end

-- Method: Returns both the magnitude, and the complex argument of <self>.
module.polar = function(self: ComplexNumber): (number, number)
	assert(TypeCheck.isComplexNumber(self), `Failed to perform \`:polar()\` method. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	local r = self:magnitude()
	local phi = self:argument()
	return r, phi
end


-- ** RAW METHODS ** --


-- ** RAW METHODS - BASIC ARITHMETIC OPERATION ** --

-- RawMethod: Modify the components of <self> to its additive inverse.
module.raw_unm = function(self: RawComplexNumber): nil
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_unm()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	self.real = -self.real
	self.complex = -self.complex
	
	return nil
end

-- RawMethod: Modify the components of <self> by performing addition to it for each operand.
module.raw_add = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_add()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_add()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		self.real += complex_num.real
		self.complex += complex_num.complex
	end
	
	return nil
end

-- RawMethod: Modify the components of <self> by performing subtraction to it for each operand.
module.raw_sub = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_sub()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_sub()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		self.real -= complex_num.real
		self.complex -= complex_num.complex
	end
	
	return nil
end

-- RawMethod: Modify the components of <self> by performing multiplication to it for each operand.
module.raw_mul = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_mul()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_mul()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local real = self.real * complex_num.real - self.complex * complex_num.complex
		local complex = self.real * complex_num.complex + self.complex * complex_num.real
		
		self.real = real
		self.complex = complex
	end
	
	return nil
end

-- RawMethod: Modify the components of <self> by performing division to it for each operand.
module.raw_div = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_div()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_div()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
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

-- RawMethod: Modify the components of <self> by performing int division to it for each operand.
module.raw_idiv = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_idiv()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_idiv()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
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

-- RawMethod: Modify the components of <self> by performing exponentiation to it for each operand.
module.raw_pow = function(self: RawComplexNumber, ...: RawComplexNumber): nil
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_pow()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_pow()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
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

-- RawMethod: Returns a boolean determining whether <self> is equivalent to every operands.
module.raw_eq = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_eq()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = math.sqrt(self.real ^ 2 + self.complex ^ 2)
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_eq()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local cur_magnitude = math.sqrt(complex_num.real ^ 2 + complex_num.complex ^ 2)
		
		-- not equal
		if self_magnitude ~= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether <self> is less than every operands.
module.raw_lt = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_lt()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = math.sqrt(self.real ^ 2 + self.complex ^ 2)
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_lt()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local cur_magnitude = math.sqrt(complex_num.real ^ 2 + complex_num.complex ^ 2)
		
		-- not less than -> greater or equal to
		if self_magnitude >= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether <self> is less than or equal to every operands.
module.raw_le = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_le()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = math.sqrt(self.real ^ 2 + self.complex ^ 2)
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_le()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local cur_magnitude = math.sqrt(complex_num.real ^ 2 + complex_num.complex ^ 2)
		
		-- not less than or equal to -> greater than
		if self_magnitude > cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether <self> is greater than every operands.
module.raw_gt = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_gt()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = math.sqrt(self.real ^ 2 + self.complex ^ 2)
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_gt()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local cur_magnitude = math.sqrt(complex_num.real ^ 2 + complex_num.complex ^ 2)
		
		-- not greater than -> less than or equal to
		if self_magnitude <= cur_magnitude then
			return false
		end
	end
	
	return true
end

-- RawMethod: Returns a boolean determining whether <self> is greater than or equal to every operands.
module.raw_ge = function(self: RawComplexNumber, ...: RawComplexNumber): boolean
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_ge()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	local self_magnitude = math.sqrt(self.real ^ 2 + self.complex ^ 2)
	
	for idx, complex_num in ipairs({...}) do
		assert(TypeCheck.isRawComplexNumber(complex_num), `Failed to perform \`:raw_ge()\` raw method. Expected <RawComplexNumber> type for <...> (arg #{idx + 1}), got <{typeof(self)}>.`)
		
		complex_num = complex_num :: RawComplexNumber
		
		local cur_magnitude = math.sqrt(complex_num.real ^ 2 + complex_num.complex ^ 2)
		
		-- not greater than or equal to -> less than
		if self_magnitude < cur_magnitude then
			return false
		end
	end
	
	return true
end


-- ** RAW METHODS - FROM METHOD ** --

-- RawMethod: Computes the magnitude (modulus/absolute value) of <self>. Accepts valid `RawComplexNumber` types.
module.raw_magnitude = function(self: RawComplexNumber): number
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_magnitude()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

-- RawMethod: Computes the complex argument (counter-clockwise angle from the positive real axis) of <self>. Accepts valid `RawComplexNumber` types.
module.raw_argument = function(self: RawComplexNumber): number
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_argument()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return math.atan2(self.complex, self.real)
end

-- RawMethod: Modify `self` to its conjugate.
module.raw_conjugate = function(self: RawComplexNumber): nil
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_conjugate()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	self = self :: RawComplexNumber
	
	self.complex = -self.complex
	
	return nil
end


-- ** RAW METHODS - OTHER ** --

--[[
RawMethod: Create a <string> representation formatted to display <self>, according to <representation>.
Optional <representation> can be either "general", "rectangular", "polar". By default, always displays in "general" form.
]]
module.raw_tostring = function(self: RawComplexNumber, representation: ("general" | "rectangular" | "polar" | "euler")?): string
	assert(TypeCheck.isRawComplexNumber(self), `Failed to perform \`:raw_tostring()\` raw method. Expected <RawComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
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


-- ** METAMETHOD - INITIAL ** --

module.__index = module

module.__newindex = function(t: ComplexNumber, key: any, value: any): nil
	error(`Attempted to create a new index/key in <ComplexNumber> object.\nObject representation: {t} | Index/Key: {key} | Value: {value}`)
end

module.__metatable = "ComplexNumber"


-- ** METAMETHOD - BASIC ARITHMETIC OPERATION ** --

module.__unm = function(self: ComplexNumber): ComplexNumber
	assert(TypeCheck.isComplexNumber(self), `Failed to perform \`__unm()\` metamethod. Expected <ComplexNumber> type, or <number> primitive type for <a> (arg #1), got <{typeof(self)}>.`)
	
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
		a = CreateRawComplexNumber(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = CreateRawComplexNumber(b::number, 0) :: ComplexNumber
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
		a = CreateRawComplexNumber(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = CreateRawComplexNumber(b::number, 0) :: ComplexNumber
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
		a = CreateRawComplexNumber(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = CreateRawComplexNumber(b::number, 0) :: ComplexNumber
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
		a = CreateRawComplexNumber(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = CreateRawComplexNumber(b::number, 0) :: ComplexNumber
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
		a = CreateRawComplexNumber(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = CreateRawComplexNumber(b::number, 0) :: ComplexNumber
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
	local base_magnitude_squared = a.real^2 + a.complex^2
	local base_argument = a:argument()
	
	local term_1 = base_magnitude_squared ^ (b.real / 2)
	local term_2 = math.exp(-b.complex * base_argument)
	local term_3 = module.cis(b.real * base_argument + b.complex * math.log(base_magnitude_squared) / 2)
	return term_1 * term_2 * term_3
end


-- ** METAMETHOD - EQUALITY COMPARISON ** --

module.__eq = function(a: ComplexNumber, b: ComplexNumber): boolean
	assert(TypeCheck.isComplexNumber(a), `Failed to perform \`__le()\` metamethod. Expected <ComplexNumber> type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(TypeCheck.isComplexNumber(b), `Failed to perform \`__le()\` metamethod. Expected <ComplexNumber> type for <b> (arg #2), got <{typeof(b)}>.`)
	
	local magnitude_A = math.sqrt(a.real ^ 2 + a.complex ^ 2)
	local magnitude_B = math.sqrt(b.real ^ 2 + b.complex ^ 2)
	return magnitude_A == magnitude_B
end

module.__lt = function(a: ComplexNumber, b: ComplexNumber): boolean
	assert(TypeCheck.isComplexNumber(a), `Failed to perform \`__le()\` metamethod. Expected <ComplexNumber> type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(TypeCheck.isComplexNumber(b), `Failed to perform \`__le()\` metamethod. Expected <ComplexNumber> type for <b> (arg #2), got <{typeof(b)}>.`)
	
	local magnitude_A = math.sqrt(a.real ^ 2 + a.complex ^ 2)
	local magnitude_B = math.sqrt(b.real ^ 2 + b.complex ^ 2)
	return magnitude_A < magnitude_B
end

module.__le = function(a: ComplexNumber, b: ComplexNumber): boolean
	assert(TypeCheck.isComplexNumber(a), `Failed to perform \`__le()\` metamethod. Expected <ComplexNumber> type for <a> (arg #1), got <{typeof(a)}>.`)
	assert(TypeCheck.isComplexNumber(b), `Failed to perform \`__le()\` metamethod. Expected <ComplexNumber> type for <b> (arg #2), got <{typeof(b)}>.`)
	
	local magnitude_A = math.sqrt(a.real ^ 2 + a.complex ^ 2)
	local magnitude_B = math.sqrt(b.real ^ 2 + b.complex ^ 2)
	return magnitude_A <= magnitude_B
end


-- ** METAMETHOD - OTHER ** --

module.__len = function(self: ComplexNumber): number
	assert(TypeCheck.isComplexNumber(self), `Failed to perform \`__len()\` metamethod. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	return math.sqrt(self.real ^ 2 + self.complex ^ 2)
end

module.__tostring = function(self: ComplexNumber): string
	assert(TypeCheck.isComplexNumber(self), `Failed to perform \`__tostring()\` metamethod. Expected <ComplexNumber> type for <self> (arg #1), got <{typeof(self)}>.`)
	
	local complex_sign = tostring_signs[math.sign(self.complex) + 2]
	local complex_number = math.abs(self.complex)
	
	return `({self.real} {complex_sign} {complex_number}𝒊)`
end

return module::typeof(module)
