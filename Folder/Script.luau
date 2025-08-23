--!strict

-- Placeholder module.
local module = {}

-- Generate the nth fibonacci number.
module.Template = function(n: number): number
	local a, b = 0, 1
	
	while n > 0 do
		a, b = b, a + b
	end
	
	return a
end

return module