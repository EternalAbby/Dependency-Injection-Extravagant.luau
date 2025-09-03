--!strict

local module = {}

type TimerId = string | number

export type Timer = setmetatable<{
	_duration: number,
	_startTime: number,
	_stopTime: number,
	_pauseTime: number,
	_isActive: boolean,
	_id: TimerId
}, typeof(module)>

local storage: {[TimerId]: Timer} = {}

-- This function is from the TypeCheck module.
local function isString(candidate: string): boolean
	if typeof(candidate) ~= "string" then
		return false
	end
	
	return true
end

-- This function is from the TypeCheck module.
local function isNumber(candidate: number, allowSpecial: boolean?): boolean
	if typeof(candidate) ~= "number" then
		return false
	end
	
	if not allowSpecial and (candidate ~= candidate or math.abs(candidate) == math.huge) then
		return false
	end
	
	return true
end

module.new = function(duration: number, id: TimerId): Timer
	assert(isNumber(duration))
	assert(isNumber(id::number, true) or isString(id::string))
	
	local new = {}
	new._duration = duration
	new._startTime = -1
	new._stopTime = -1
	new._pauseTime = -1
	new._id = id
	new._isActive = false
	
	storage[id] = setmetatable(new, module)
	return storage[id]
end

module.destroy = function(id: TimerId): boolean
	assert(isNumber(id::number, true) or isString(id::string))
	if storage[id] then
		storage[id] = nil
		return true
	end
	return false
end

module.getTimer = function(id: TimerId): Timer
	assert(isNumber(id::number, true) or isString(id::string))
	return storage[id]
end

module.hasTimer = function(id: TimerId): boolean
	assert(isNumber(id::number, true) or isString(id::string))
	return storage[id] ~= nil
end

module.isTimer = function(candidate: Timer): boolean
	return candidate and storage[candidate._id] and storage[candidate._id] == candidate
end

module.Start = function(self: Timer): boolean
	local start = os.clock()
	
	assert(module.isTimer(self))
	
	if self._isActive then
		return false
	end
	
	self._startTime = start
	self._stopTime = start + self._duration
	self._pauseTime = -1
	self._isActive = true
	
	return true
end

module.Resume = function(self: Timer): boolean
	assert(module.isTimer(self))
	
	if self._isActive or self._startTime == -1 or self._stopTime == -1 or self._pauseTime == -1 then
		return false
	end
	
	self._stopTime += self._pauseTime - self._startTime
	self._pauseTime = -1
	self._isActive = true
	
	return true
end

module.Pause = function(self: Timer): boolean
	local pause = os.clock()
	
	assert(module.isTimer(self))
	
	if not self._isActive then
		return false
	end
	
	self._pauseTime = pause
	self._isActive = false
	
	return true
end

module.Stop = function(self: Timer): boolean
	assert(module.isTimer(self))
	
	if not self._isActive then
		return false
	end
	
	self._startTime = -1
	self._stopTime = -1
	self._pauseTime = -1
	self._isActive = false
	
	return true
end

module.GetCurrentTime = function(self: Timer): number
	assert(module.isTimer(self))
	
	if os.clock() - self._startTime >= self._stopTime then
		self._isActive = false
	end
	
	if self._isActive then
		return os.clock() - self._startTime
	end
	
	return -1
end

module.SetDuration = function(self: Timer, seconds: number): boolean
	assert(module.isTimer(self))
	assert(isNumber(seconds, false))
	
	self._duration = seconds
	
	return false
end

module.isRunning = function(self: Timer): boolean
	assert(module.isTimer(self))
	return self._isActive and os.clock() < self._stopTime
end

module.isEnded = function(self: Timer): boolean
	assert(module.isTimer(self))
	
	if os.clock() >= self._stopTime then
		self._isActive = false
	end
	
	return not self._isActive
end


module.__index = module

module.__newindex = function(self: Timer, key: any, value: any): nil
	error(`Attempted to create a new index/key in <ComplexNumber> object.\nObject representation: {self}\nIndex/Key: {key}\nValue: {value}`)
end

module.__metatable = "Timer"

return module