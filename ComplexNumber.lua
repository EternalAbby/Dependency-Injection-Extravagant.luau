--!strict
--[[
--------------------------------------------------------------------------------
		** DOCUMENTATION **														
	* Function descriptions are included with the function, if possible to be viewed.
																				
	* Definitions:																
	- RawComplexNumber = {														
		["real"]: number,														
		["complex"]: number														
	}																			
	- ComplexNumber = setmetatable<{											
		["real"]: number,														
		["complex"]: number														
	}, typeof(module)>															
																				
	* Constructors:																
	- .new(real: number, complex: number): ComplexNumber						
	- .fromRaw(raw: RawComplexNumber): ComplexNumber							
																				
	* Functions:																
	- .cis(theta: number): number												
																				
	* Methods:																	
	- :magnitude(): number														
	- :argument(): number														
	- :conjugate(): ComplexNumber												
	- :polar(): (number, number)												
																				
	* Metamethods:																
	** Basic arithmetic operations:												
	- .__unm() (Note: This metamethod flips both signs for the real part and imaginary part. For complex conjugate, use :conjugate().)
	- .__add()																	
	- .__sub()																	
	- .__mul()																	
	- .__div()																	
	- .__idiv()																	
	- .__mod() (Note: Attempting to use this metamethod will cause an error, because this is not implemented yet.)
	- .__pow()																	
																				
	** Equality comparisons:													
	- .__eq() (Note: This method uses magnitude to compare, same as below.)		
	- .__lt()																	
	- .__le()																	
																				
	** Other:																	
	- .__newindex (Note: Attempting to create a new index will cause an error.)	
	- .__metatable = "ComplexNumber"											
	- .__len() (Note: This metamethod is equivalent to :magnitude())			
	- .__tostring() (Note: This metamethod converts the ComplexNumber into a string to display. Format is similar to that of cmath library in Python.)
																				
--------------------------------------------------------------------------------
		** ADDITIONAL INFO **													
	Thank you for using this ComplexNumber module! This was originally made as a
	practice, not meant as production-worthy code!								
																				
	You are allowed to modify the source code of this module, and allowed to claim
	such modifications via additions/optimizations/organizations/implementations/etc.
	as your attributions. If these modifications were to be contributed to this module's
	source code, as long as they are provided with creditable source of such idea,
	or with proof that they are sufficient to this module, that is optimized, or
	performant, they may be accepted in future editions to this module.
																				
	You are not allowed to claim this specific module as yours! You are only allowed
	to modify the contents of the source code. If you would like to contribute to
	this module, please contact me.												
																				
							~ ComplexNumber module made by Abby (@0_byy) on Roblox
																				
--------------------------------------------------------------------------------
		** COMPLEX NUMBER FORMULAS **											
	Note:																		
	- These are the formulas used within this module. In some cases, they are	
	chosen by programming convention. In other cases, it might be a bug... oops.
	- Formulas are ordered by basic arithmetic operations, unless another formula
	within them is not stated before, then this formula will be ordered before it.
		+ For example, complex division formula needs complex conjugate, and the
		absolute value to compute it, therefore, those two are ordered before	
		complex division.														
																				
	* Let a = x + y??, and b = u + v?? be two complex numbers in its general form, with
	x, u be their respective real parts, and y, v be their respective imaginary part,
	with an imaginary unit defined as v(-1) = ??.									
	From these definitions, one must have the following formulas for complex numbers;
																				
	* Addition: Separately adding their real parts and complex parts.			
		a + b																	
		= (x + y??) + (u + v??)													
		= (x + u) + (y + v)??														
																				
	* Subtraction: Separately subtracting their real parts and complex parts.	
		a - b																	
		= (x + y??) - (u + v??)													
		= (x - u) + (y - v)??														
																				
	* Multiplication: Use FOIL (First-Outer-Inner-Last) on their expanded form.	
		a * b																	
		= (x + y??) * (u + v??)													
		= (x * u) + (x * v??) + (y?? * u) + (y?? * v??)								
		= (x*u - y*v) + (x*v + y*u)??			(??^2 = -1)							
																				
	* Complex conjugate: Flip the sign between the real part and the imaginary part.
		a = x + y??																
		-> a' = x - y??															
																				
	* Absolute value (Magnitude/Modulus): The distance between the point and the origin in the complex plane.
		a = x + y??																
		-> |a| = v(x^2 + y^2)		(Pythagorean theorem)						
																				
	* Division: Apply "rationalization" to the fraction.						
		a / b		(b must be a nonzero complex number, b != 0 + 0??)			
		= a*b' / |b|^2															
		= (x + y??)*(u - v??) / (u^2 + v^2)										
		= [(x*u + y*v) + (x*v - y*u)??] / (u^2 + v^2)								
		= (x*u + y*v) / (u^2 + v^2)  +  (x*v - y*u)?? / (u^2 + v^2)				
		  ---------- real ---------     ------- imaginary -------				
																				
																				
	* Euler's formula: The formula for the relationship between trig functions and complex exp function.
		exp(?? * x) = cos(x) + ?? sin(x)											
																				
	* cis(theta) trig function: Euler's formula written as a trig function.		
		cis(theta) = cos(theta) + ?? sin(theta) = exp(?? * theta)					
																				
	* Complex argument: The counterclockwise angle of the complex number from the positive real axis in the complex plane.
		a = x + y??																
		arg(a) = arg(x + y??) = atan2(y/x)										
																				
	* Polar form: The magnitude and its argument.								
		a = x + y??																
		= |a| * cis(arg(a))														
																				
		where, |a| is the absolute value of a,									
			cis(theta) is the trig function of Euler's formula,					
			and arg(a) is the complex argument of a.							
																				
	* Exponentiation: Described in the reference link below. Complex exponentiation satisfies
		a^b																		
		= (x + y??)^(u + v??)														
		= |a|^(u + v??) * cis(arg(a))^(u + v??)		(de Moivre's formula)		
		= ???		(TBA: idk how this step is done)							
		= (x^2 + y^2)^(u/2)  *  exp(-v * arg(a))  *  cis(u*arg(a) + v*ln(x^2 + y^2)/2)
		  ---- term 1 -----     ---- term 2 ----     ------------ term 3 -------------
																				
--------------------------------------------------------------------------------
		** EXTERNAL LINKS **													
	* Reference:																
	** Wikipedia:																
		https://en.wikipedia.org/wiki/Complex_number							
		https://en.wikipedia.org/wiki/Euler%27s_formula							
																				
	** Wolfram MathWorld:														
		https://mathworld.wolfram.com/ComplexArgument.html						
		https://mathworld.wolfram.com/ComplexExponentiation.html				
--------------------------------------------------------------------------------
]]

local TypeCheck = require(script.Parent.TypeCheck)

local module = {}

type RawComplexNumber = {
	["real"]: number,
	["complex"]: number
}

export type ComplexNumber = setmetatable<{
	["real"]: number,
	["complex"]: number
}, typeof(module)>


local pow_res = {math.huge, 1, 0}
local tostring_signs = {"-", "+", "+"}

local function CreateRawComplexNumber(real: number, complex: number): RawComplexNumber
	return {
		["real"] = real,
		["complex"] = complex
	}
end

local function GetNumberComponentTypes(candidate: ComplexNumber | number): (boolean, boolean)
	return TypeCheck.isNumber(candidate, true), TypeCheck.isComplexNumber(candidate)
end

module.new = function(real: number, complex: number): ComplexNumber
	assert(TypeCheck.isNumber(real, false), `Failed to construct a new ComplexNumber. Expected number type for real part (arg #1), got {typeof(real)}.`)
	assert(TypeCheck.isNumber(complex, false), `Failed to construct a new ComplexNumber. Expected number type for complex part (arg #2), got {typeof(complex)}.`)
	
	local new = CreateRawComplexNumber(real, complex)
	return setmetatable(new, module)
end

local complexUnit = module.new(0, 1)

module.fromRaw = function(raw: RawComplexNumber): ComplexNumber
	assert(TypeCheck.isComplexNumber(raw), `Failed to construct a new ComplexNumber. Expected RawComplexNumber type (arg #1), got {typeof(raw)}`)
	
	local new = CreateRawComplexNumber(raw.real, raw.complex)
	return setmetatable(new, module)
end


module.cis = function(theta: number): ComplexNumber
	assert(TypeCheck.isNumber(theta, false), `Failed to compute cis trig function. Expected number type (arg #1), got {typeof(theta)}`)
	
	local cosine = math.cos(theta)
	local sine = math.sin(theta) * complexUnit
	return cosine + sine
end


module.magnitude = function(self: ComplexNumber): number
	return math.sqrt(self.real^2 + self.complex^2)
end

module.argument = function(self: ComplexNumber): number
	return math.atan2(self.complex, self.real)
end

module.conjugate = function(self: ComplexNumber): ComplexNumber
	return module.new(self.real, -self.complex)
end

module.polar = function(self: ComplexNumber): (number, number)
	local r = self:magnitude()
	local phi = self:argument()
	return r, phi
end


module.__index = module

module.__newindex = function()
	error("TODO: better error message")
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
	
	return `({self.real} {complex_sign} {complex_number}??)`
end

return module::typeof(module)