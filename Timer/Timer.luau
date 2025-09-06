--!strict

local module = {}


-- ** TYPE DEFINITIONS ** --

type TimerId = string | number
type TimerStorage = {[TimerId]: Timer}

export type Timer = setmetatable<{
	_duration: number,
	_startTime: number,
	_stopTime: number,
	_pauseTime: number,
	_isActive: boolean,
	_id: TimerId
}, typeof(module)>

local storage: TimerStorage = {}


-- ** INTERNAL FUNCTIONS ** --

-- This function is from the TypeCheck module.
local function isString(candidate: string): boolean
	if typeof(candidate) ~= "string" then
		return false
	end
	
	return true
end

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


-- ** CONSTRUCTORS ** --

-- Constructor: Creates a new <Timer> object.
module.new = function(duration: number, id: TimerId): Timer
	assert(isNumber(duration))
	assert(duration > 0)
	assert(isNumber(id::number) or isString(id::string))
	assert(module.hasTimer(id))
	
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


-- ** FUNCTIONS ** --

-- Function: Removes the <Timer> object by using TimerId.
module.remove = function(id: TimerId): boolean
	assert(isNumber(id::number) or isString(id::string))
	if storage[id] then
		storage[id] = nil
		return true
	end
	return false
end

-- Function: Gets the <Timer> object by using TimerId.
module.getTimer = function(id: TimerId): Timer?
	assert(isNumber(id::number) or isString(id::string))
	return storage[id]
end

-- Function: Checks whether a <Timer> object with TimerId already exists.
module.hasTimer = function(id: TimerId): boolean
	assert(isNumber(id::number) or isString(id::string))
	return storage[id] ~= nil
end

-- Function: Checks whether the candidate is a valid <Timer> object.
module.isTimer = function(candidate: Timer): boolean
	return candidate and storage[candidate._id] and storage[candidate._id] == candidate
end


-- ** METHODS ** --

-- Method: Simulate starting the <Timer> object.
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

-- Method: Simulate resuming the <Timer> object.
module.Resume = function(self: Timer): boolean
	assert(module.isTimer(self))
	
	if self._isActive or self._startTime == -1 or self._stopTime == -1 or self._pauseTime == -1 then
		return false
	end
	
	self._stopTime += self._pauseTime - self._startTime
	self._isActive = true
	
	return true
end

-- Method: Simulate pausing the <Timer> object.
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

-- Method: Simulate stopping the <Timer> object.
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

-- Method: Returns the current time remaining in the <Timer> object. Returns -1 if not active at the time of function call.
module.GetCurrentTime = function(self: Timer): number
	assert(module.isTimer(self))
	
	if self._pauseTime ~= -1 and os.clock() - self._pauseTime >= self._stopTime
	or self._pauseTime == -1 and os.clock() - self._startTime >= self._stopTime then
		self._isActive = false
	end
	
	if self._isActive then
		return os.clock() - self._startTime
	end
	
	return -1
end

-- Method: Sets the duration of the <Timer> object to the <seconds> parameter. Does not change simulated stop time.
module.SetDuration = function(self: Timer, seconds: number): boolean
	assert(module.isTimer(self))
	assert(isNumber(seconds))
	
	self._duration = seconds
	
	return true
end

-- Method: Checks whether the <Timer> object is running.
module.isRunning = function(self: Timer): boolean
	assert(module.isTimer(self))
	return self._isActive and os.clock() < self._stopTime
end

-- Method: Checks whether the <Timer> object has ended.
module.isEnded = function(self: Timer): boolean
	assert(module.isTimer(self))
	
	if os.clock() >= self._stopTime then
		self._isActive = false
	end
	
	return not self._isActive
end


-- ** METAMETHODS ** --

module.__index = module

module.__newindex = function(self: Timer, key: any, value: any): nil
	error(`Attempted to create a new index/key in <Timer> object.\nObject representation: {self}\nIndex/Key: {key}\nValue: {value}`)
end

module.__metatable = "Timer"

return module