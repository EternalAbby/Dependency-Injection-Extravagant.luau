--!strict

local module = {}
module.e = 2.718281828459045
module.tau = 6.283185307179586
module.nan = 0/0
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

module.percentage = function(count: number, total: number): number
	return (count / total) * 100
end

module.stirling_approximation = function(n: number): number
	return math.sqrt(2 * math.pi * n) * ((n / module.e) ^ n)
end

module.triangular_number = function(n: number): number
	return n * (n + 1) / 2
end

return module