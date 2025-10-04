--!strict

-- Version: 1.1.0

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
	_id: TimerId,
	_protected: boolean
}, typeof(module)>

local protected_timer: TimerStorage = {}
local storage: TimerStorage = {}


-- ** INTERNAL FUNCTIONS ** --

local function isString(candidate: string): boolean
	return typeof(candidate) == "string"
end

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

--[[
Constructor: Creates a new `Timer` object.
<id> must not collide with a pre-existing <Timer> object.
]]
module.new = function(id: TimerId, duration: number, protected: boolean?): Timer
	assert(isNumber(id::number) or isString(id::string), `Failed to perform \`.new()\` constructor. Attempted to set <id> to an invalid type. Expected <string> or <number> type, got <{typeof(id)}>.`)
	assert(not module.hasTimer(id), `Failed to perform \`.new()\` constructor. Attempted to set <id> to a pre-existing <Timer> object.`)
	assert(isNumber(duration), `Failed to perform \`.new()\` constructor. Attempted to set <duration> to an invalid type. Expected <number> type, got <{typeof(duration)}>.`)
	assert(duration > 0, `Failed to perform \`.new()\` constructor. Attempted to set <duration> to a non-positive number, got {duration}.`)
	
	local new = {}
	new._duration = duration
	new._startTime = -1
	new._stopTime = -1
	new._pauseTime = -1
	new._id = id
	new._isActive = false
	new._protected = if protected then protected else false
	
	storage[id] = setmetatable(new, module)
	protected_timer[id] = if protected then storage[id] else nil
	return storage[id]
end


-- ** FUNCTIONS ** --

--[[
Function: Removes the <Timer> object by using <id>.
Returns a boolean to determine whether the <Timer> object existed.
]]
module.remove = function(id: TimerId): boolean
	assert(isNumber(id::number) or isString(id::string), `Failed to perform \`.remove()\` function. Attempted to find a <Timer> object with an invalid <TimerId> type. Expected <string> or <number> type, got <{typeof(id)}>.`)
	assert(not protected_timer[id], `Failed to perform \`.remove()\` function. Attempted to remove a protected <Timer> object.`)
	if storage[id] then
		local to_remove = storage[id]
		to_remove._duration = nil :: any
		to_remove._startTime = nil :: any
		to_remove._stopTime = nil :: any
		to_remove._pauseTime = nil :: any
		to_remove._id = nil :: any
		to_remove._isActive = nil :: any
		to_remove._protected = nil :: any
		
		storage[id] = nil
		return true
	end
	return false
end

--[[
Function: Gets the <Timer> object by using <id>.
Returns the <Timer> object if found, otherwise returns `nil`.
]]
module.getTimer = function(id: TimerId): Timer?
	assert(isNumber(id::number) or isString(id::string), `Failed to perform \`.getTimer()\` function. Attempted to find a <Timer> object with an invalid <TimerId> type. Expected <string> or <number> type, got <{typeof(id)}>.`)
	return storage[id]
end

--[[
Function: Checks whether a <Timer> object with <id> exists.
Returns a boolean to determine whether the <Timer> object existed.
]]
module.hasTimer = function(id: TimerId): boolean
	assert(isNumber(id::number) or isString(id::string), `Failed to perform \`.hasTimer()\` function. Attempted to find a <Timer> object with an invalid <TimerId> type. Expected <string> or <number> type, got <{typeof(id)}>.`)
	return storage[id] ~= nil
end

--[[
Function: Determines if the <candidate> is a valid <Timer> object.
This function checks the memory of <candidate> using an internal storage in the module.
]]
module.isTimer = function(candidate: Timer): boolean
	return typeof(candidate) == "table" and storage[candidate._id] == candidate
end


-- ** METHODS ** --

--[[
Method: Starts the `Timer` object.
This method simulates the `Timer` object.
]]
module.Start = function(self: Timer): boolean
	local start = os.clock()
	
	assert(module.isTimer(self), `Failed to perform \`:Start()\` method. Attempted to start an invalid <Timer> object.`)
	
	self._startTime = start
	self._stopTime = start + self._duration
	self._pauseTime = -1
	self._isActive = true
	return true
end

--[[
Method: Resumes the `Timer` object.
This method simulates the `Timer` object.
]]
module.Resume = function(self: Timer): boolean
	assert(module.isTimer(self), `Failed to perform \`:Resume()\` method. Attempted to resume an invalid <Timer> object.`)
	
	if self._isActive or self._startTime == -1 or self._stopTime == -1 or self._pauseTime == -1 then
		return false
	end
	
	self._stopTime += os.clock() - self._pauseTime
	self._pauseTime = -1
	self._isActive = true
	return true
end

--[[
Method: Pauses the `Timer` object.
This method simulates the `Timer` object.
]]
module.Pause = function(self: Timer): boolean
	local pause = os.clock()
	
	assert(module.isTimer(self), `Failed to perform \`:Pause()\` method. Attempted to pause an invalid <Timer> object.`)
	
	if not self._isActive then
		return false
	end
	
	self._pauseTime = pause
	self._isActive = false
	return true
end

--[[
Method: Stops the `Timer` object.
This method simulates the `Timer` object.
]]
module.Stop = function(self: Timer): boolean
	assert(module.isTimer(self), `Failed to perform \`:Stop()\` method. Attempted to stop an invalid <Timer> object.`)
	
	if self._startTime == -1 and self._stopTime == -1 and self._pauseTime == -1 and not self._isActive then
		return false
	end
	
	self._startTime = -1
	self._stopTime = -1
	self._pauseTime = -1
	self._isActive = false
	return true
end

--[[
Method: Returns the current time remaining of the `Timer` object.
If the `Timer` object is not active, returns `-1`.
]]
module.GetCurrentTime = function(self: Timer): number
	assert(module.isTimer(self), `Failed to perform \`:GetCurrentTime()\` method. Attempted to perform operation using an invalid <Timer> object.`)
	
	if os.clock() >= self._stopTime then
		self._isActive = false
	end
	
	if self._isActive then
		return self._stopTime - os.clock()
		
	elseif self._pauseTime ~= -1 then
		return self._stopTime - self._pauseTime
	end
	return -1
end

--[[
Method: Sets the duration of the `Timer` object to the amount in <seconds>.
If the <Timer> object is running, this method does not affect it.
]]
module.SetDuration = function(self: Timer, seconds: number): boolean
	assert(module.isTimer(self), `Failed to perform \`:SetDuration()\` method. Attempted to perform operation using an invalid <Timer> object.`)
	assert(isNumber(seconds), `Failed to perform \`:SetDuration()\` method. Attempted to set <duration> to an invalid type. Expected <number> type, got <{typeof(seconds)}>.`)
	assert(seconds > 0, `Failed to perform \`:SetDuration()\` method. Attempted to set <duration> to a non-positive number, got {seconds}.`)
	self._duration = seconds
	return true
end

-- Method: Checks whether the `Timer` object is running.
module.IsActive = function(self: Timer): boolean
	assert(module.isTimer(self), `Failed to perform \`:IsActive()\` method. Attempted to perform operation using an invalid <Timer> object.`)
	return self._isActive and os.clock() < self._stopTime
end

-- Method: Checks whether the `Timer` object has ended.
module.IsInactive = function(self: Timer): boolean
	assert(module.isTimer(self), `Failed to perform \`:IsInactive()\` method. Attempted to perform operation using an invalid <Timer> object.`)
	if self._pauseTime == -1 and os.clock() >= self._stopTime then
		self._isActive = false
	end
	return self._pauseTime == -1 and not self._isActive
end


-- ** METAMETHODS ** --

module.__index = module

module.__newindex = function(self: Timer, key: any, value: any): nil
	error(`Attempted to create a new index/key in <Timer> object.\nObject representation: {self}\nIndex/Key: {key}\nValue: {value}`)
end

module.__metatable = "Timer"

return module