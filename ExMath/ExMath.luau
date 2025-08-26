--!strict

local module = {}
module.e = 2.718281828459045
module.tau = 6.283185307179586
module.golden_ratio_positive = 1.618033988749895
module.golden_ratio_negative = -0.6180339887498949

module.factorial = function(n: number): number
	local res = 1
	for k = 2, n do
		res *= k
	end
	return res
end

module.fibonacci_sequence = function(n: number): number
	local a, b = 0, 1
	
	for _ = 1, n do
		a, b = b, a + b
	end
	
	return a
end

return module