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