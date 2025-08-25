--!strict

local module = {}
module.e = 2.718281828459045235360287471352
module.golden_ratio_positive = (1 + math.sqrt(5)) / 2
module.golden_ratio_negative = -1 / module.golden_ratio_positive

module.fibonacci_sequence = function(n: number): number
	local a, b = 0, 1
	
	for _ = 1, n do
		a, b = b, a + b
	end
	
	return a
end

return module