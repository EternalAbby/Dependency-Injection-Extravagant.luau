--!strict

local TypeCheck = require(script.Parent.TypeCheck)

local module = {}

export type RawComplexNumber = {
	["real"]: number,
	["complex"]: number
}

export type ComplexNumber = setmetatable<{
	["real"]: number,
	["complex"]: number
}, typeof(module)>


local pow_res = {math.huge, 1, 0} -- used for __pow()
local tostring_signs = {"-", "+", "+"} -- used for __tostring()

local function CreateRawComplexNumber(real: number, complex: number): RawComplexNumber
	return {
		["real"] = real,
		["complex"] = complex
	}
end

local function GetNumberComponentTypes(candidate: ComplexNumber | number): (boolean, boolean)
	return TypeCheck.isNumber(candidate, true), TypeCheck.isComplexNumber(candidate)
end

-- Constructor: Creates a new ComplexNumber object. Does not accept inf nor nan.
module.new = function(real: number, complex: number): ComplexNumber
	assert(TypeCheck.isNumber(real, false), `Failed to construct a new ComplexNumber. Expected number type for real part (arg #1), got {typeof(real)}.`)
	assert(TypeCheck.isNumber(complex, false), `Failed to construct a new ComplexNumber. Expected number type for complex part (arg #2), got {typeof(complex)}.`)
	
	local new = CreateRawComplexNumber(real, complex)
	return setmetatable(new, module)
end

local complexUnit = module.new(0, 1)

-- Constructor: Creates a new ComplexNumber object from a valid RawComplexNumber type.
module.fromRaw = function(raw: RawComplexNumber): ComplexNumber
	assert(TypeCheck.isComplexNumber(raw), `Failed to construct a new ComplexNumber. Expected RawComplexNumber type (arg #1), got {typeof(raw)}`)
	
	local new = CreateRawComplexNumber(raw.real, raw.complex)
	return setmetatable(new, module)
end


--[[
Function: Computes the trigonometric function cis(theta).
Equivalent to computing 'cos(theta) + 𝒊 sin(theta)', or Euler's formula.
]]
module.cis = function(theta: number): ComplexNumber
	assert(TypeCheck.isNumber(theta, false), `Failed to compute cis trig function. Expected number type (arg #1), got {typeof(theta)}`)
	
	local cosine = math.cos(theta)
	local sine = math.sin(theta) * complexUnit
	return cosine + sine
end


--[[
Method: Computes the modulus (magnitude, or absolute value) of the ComplexNumber object.
Similarly, using # operator on a ComplexNumber object returns this result.
]]
module.magnitude = function(self: ComplexNumber): number
	return math.sqrt(self.real^2 + self.complex^2)
end

-- Method: Computes the complex argument (counter-clockwise angle from the positive real axis) of the ComplexNumber object.
module.argument = function(self: ComplexNumber): number
	return math.atan2(self.complex, self.real)
end

-- Method: Creates a new ComplexNumber object that is the complex conjugate to the ComplexNumber object which this method was called on.
module.conjugate = function(self: ComplexNumber): ComplexNumber
	return module.new(self.real, -self.complex)
end

-- Method: Returns both the magnitude, and the complex argument.
module.polar = function(self: ComplexNumber): (number, number)
	local r = self:magnitude()
	local phi = self:argument()
	return r, phi
end


module.__index = module

module.__newindex = function()
	error("Attempted to create a new key/index in a ComplexNumber object.")
end

module.__metatable = "ComplexNumber"


module.__add = function(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
	local isnum_A, iscomplex_A = GetNumberComponentTypes(a)
	local isnum_B, iscomplex_B = GetNumberComponentTypes(b)
	
	assert(isnum_A or iscomplex_A)
	assert(isnum_B or iscomplex_B)
	
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
	
	assert(isnum_A or iscomplex_A)
	assert(isnum_B or iscomplex_B)
	
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
	
	assert(isnum_A or iscomplex_A)
	assert(isnum_B or iscomplex_B)
	
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
	
	assert(isnum_A or iscomplex_A)
	assert(isnum_B or iscomplex_B)
	
	if isnum_A then
		a = CreateRawComplexNumber(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = CreateRawComplexNumber(b::number, 0) :: ComplexNumber
	end
	
	a = a :: ComplexNumber
	b = b :: ComplexNumber
	
	assert(b.real ~= 0 and b.complex ~= 0, "division by zero")
	
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

module.__mod = function(a: ComplexNumber | number, b: ComplexNumber | number): nil
	error("This is an invalid operation as of now.")
end

module.__pow = function(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
	local isnum_A, iscomplex_A = GetNumberComponentTypes(a)
	local isnum_B, iscomplex_B = GetNumberComponentTypes(b)
	
	assert(isnum_A or iscomplex_A)
	assert(isnum_B or iscomplex_B)
	
	if isnum_A then
		a = CreateRawComplexNumber(a::number, 0) :: ComplexNumber
	elseif isnum_B then
		b = CreateRawComplexNumber(b::number, 0) :: ComplexNumber
	end
	
	a = a :: ComplexNumber
	b = b :: ComplexNumber
	
	-- edge case base = 0
	if a.real == 0 and a.complex == 0 then
		local sign = math.sign(b.real)
		return module.new(pow_res[sign + 2], 0)
		
	-- edge case exponent = 0
	elseif b.real == 0 and b.complex == 0 then
		return module.new(1, 0)
	end
	
	-- case (purely-real)^(purely-real)
	if a.complex == 0 and b.complex == 0 then
		return module.new(a.real^b.real, 0)
	end
	
	local base_magnitude_squared = a.real^2 + a.complex^2
	local base_argument = a:argument()
	
	local term_1 = base_magnitude_squared ^ (b.real / 2)
	local term_2 = math.exp(-b.complex * base_argument)
	local term_3 = module.cis(b.real * base_argument + b.complex * math.log(base_magnitude_squared) / 2)
	return term_1 * term_2 * term_3
end


module.__eq = function(a: ComplexNumber, b: ComplexNumber): boolean
	local magnitude_A = a:magnitude()
	local magnitude_B = b:magnitude()
	return magnitude_A == magnitude_B
end

module.__lt = function(a: ComplexNumber, b: ComplexNumber): boolean
	local magnitude_A = a:magnitude()
	local magnitude_B = b:magnitude()
	return magnitude_A < magnitude_B
end

module.__le = function(a: ComplexNumber, b: ComplexNumber): boolean
	local magnitude_A = a:magnitude()
	local magnitude_B = b:magnitude()
	return magnitude_A <= magnitude_B
end


module.__len = function(self: ComplexNumber): number
	return self:magnitude()
end

module.__unm = function(a: ComplexNumber): ComplexNumber
	a.real = a.real * -1
	a.complex = a.complex * -1
	return a
end

module.__tostring = function(self: ComplexNumber): string
	local complex_sign = tostring_signs[math.sign(self.complex) + 2]
	local complex_number = math.abs(self.complex)
	
	return `({self.real} {complex_sign} {complex_number}𝒊)`
end

return module::typeof(module)