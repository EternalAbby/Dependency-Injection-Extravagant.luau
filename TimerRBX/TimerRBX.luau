--!strict
--!optimize 2
--!native

-- TODO: [VERSION 1.0.0] Implement user-defined task. This is run every frame (via RunService.Heartbeat.)
-- TODO: [VERSION 1.0.0] Implement user-defined timestamps. These are run whenever the specified time had elapsed.
-- TODO: [VERSION 1.0.0] Add user-defined function descriptions.

-- TODO: [VERSION 1.1.0] Implement internal storage for Timer properties. In case of any malicious/false modifications from the user. Change source code to use them instead of the ones that is public.
-- TODO: [VERSION 1.1.0] Implement server-protected and client-protected Timer. Splitting `protected` property into 2. Server-protected will act similarly to current `protected`. Client-protected will prevent client-sided destruction of Timer.
-- TODO: [VERSION 1.1.0] Implement object pooling for RemoteEvents.


-- Version: 1.0.0


-- TYPE DEFINITION --

type Timer_Identifier = string | number
type Timer_Action = (...any) -> nil

type Timer_Method = {
	Start: (self: Timer) -> nil,
	Resume: (self: Timer) -> nil,
	Pause: (self: Timer) -> nil,
	Stop: (self: Timer) -> nil,
	
	MarkTimestamp: (self: Timer, timestamp: number, action: Timer_Action) -> nil,
	UnmarkTimestamp: (self: Timer, timestamp: number) -> nil,
	
	GetCurrentTime: (self: Timer) -> number,
	SetDuration: (self: Timer, seconds: number) -> nil,
	ResetTimer: (self: Timer) -> nil,
	
	IsActive: (self: Timer) -> boolean,
	IsInactive: (self: Timer) -> boolean,
	IsPaused: (self: Timer) -> boolean,
}
type Timer_Meta = {
	__index: Timer_Method,
	__newindex: (self: Timer, key: any, value: any) -> nil,
	__metatable: "TimerRBX",
	__tostring: (timer: Timer) -> string
}
export type Timer = setmetatable<{
	duration: number,
	timestamps: {[number]: {Timer_Action}},
	
	startTime: number,
	stopTime: number,
	pauseTime: number,
	
	isActive: boolean,
	
	Started: BindableEvent,
	Resumed: BindableEvent,
	Paused: BindableEvent,
	Stopped: BindableEvent,
	Ended: BindableEvent,
	
	Changed: BindableEvent,
	
	id: Timer_Identifier,
	protected: boolean,
}, Timer_Meta>

type TimerStorage = {
	[Timer_Identifier]: Timer
}

type Module = {
	new: (id: Timer_Identifier, duration: number, protected: boolean?) -> Timer,
	destroy: (id: Timer_Identifier) -> nil,
	isTimer: (candidate: Timer) -> boolean,
	hasTimer: (id: Timer_Identifier) -> boolean
}


-- HELPER FUNCTION --

local function isString(candidate: string): boolean
	return typeof(candidate) == "string"
end

local function isNumber(candidate: number): boolean
	return typeof(candidate) == "number" and candidate == candidate and candidate ~= math.huge and candidate ~= -math.huge
end

local function isTimerId(candidate: Timer_Identifier): boolean
	return isString(candidate::string) or isNumber(candidate::number)
end

local function ThrowTypeError(expected_type: string, arg_name: string, arg_idx: number, arg_val: any): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(2, "n")}\`.\
		Reason: A type error occurred when running the function.\
		Expected: <{expected_type}> type for \`{arg_name}\` (arg #{arg_idx}).\
		Cause: Received <{typeof(arg_val)}> type.\
		--------------------`
	)
end

local function ThrowExistingTimerError(arg_idx: number, arg_val: any): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(2, "n")}\`.\
		Reason: Attempted to create a \`Timer\` object with an existing <TimerId>.\
		Expected: Unique \`TimerId\` per \`Timer\` object for \`id\` (arg #{arg_idx}).\
		Cause: Received {arg_val}.\
		--------------------`
	)
end

local function ThrowDurationError(arg_idx: number, arg_val: any): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(2, "n")}\`.\
		Reason: Attempted to set <duration> to a non-positive number.\
		Expected: <duration> must be a positive number for \`duration\` (arg #{arg_idx}).\
		Cause: Received {arg_val}.\
		--------------------`
	)
end

local function ThrowProtectedError(arg_idx: number, arg_val: any): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(2, "n")}\`.\
		Reason: Attempted to remove a protected \`Timer\` object.\
		Expected: Cannot remove a protected \`Timer\` object.\
		Cause: Attempted to remove \`Timer\` object with TimerId {arg_val} (arg #{arg_idx}).\
		--------------------`
	)
end

local function ThrowTimerOperationError(): nil
	error(`\
		--------------------\
		Error: Failed to perform \`{debug.info(2, "n")}\`.\
		Reason: Attempted to do perform Timer operation on an invalid \`Timer\` object.\
		Expected: Object to be a \`Timer\` object.\
		Cause: Provided object is not a \`Timer\` object.\
		--------------------`
	)
end

local function ResetTimer(timer: Timer): nil
	timer.startTime = -1
	timer.stopTime = -1
	timer.pauseTime = -1
	timer.isActive = false
	return nil
end

local function FormatDigit(n: number, digits: number): string
	return (`%0{digits}i`::any):format(tostring(n))
end

local function Check(expression: boolean, err_func: (...any) -> nil, ...: any): nil
	if expression then
		err_func(...)
	end
	return nil
end


-- INTERNAL VARIABLE --

local RunService = game:GetService("RunService")

local storage: TimerStorage = {}
local protected_storage: TimerStorage = {}

local index_table: Timer_Method = {} :: Timer_Method
local timer_meta: Timer_Meta = {} :: Timer_Meta
local module: Module = {} :: Module


-- METHOD --

index_table.Start = function(self: Timer): nil
	local currentTime = os.clock()
	
	Check(module.isTimer(self), ThrowTimerOperationError)
	
	self.startTime = currentTime
	self.stopTime = currentTime + self.duration
	self.pauseTime = -1
	self.isActive = true
	
	self.Started:Fire(currentTime, os.clock())
	
	return nil
end

index_table.Resume = function(self: Timer): nil
	local currentTime = os.clock()
	
	Check(module.isTimer(self), ThrowTimerOperationError)
	
	if self.isActive or self.startTime == -1 or self.stopTime == -1 or self.pauseTime == -1 then
		return nil
	end
	
	self.stopTime += currentTime - self.pauseTime
	self.pauseTime = -1
	self.isActive = true
	
	self.Resumed:Fire(currentTime, os.clock())
	
	return nil
end

index_table.Pause = function(self: Timer): nil
	local currentTime = os.clock()
	
	Check(module.isTimer(self), ThrowTimerOperationError)
	
	if not self.isActive then
		return nil
	end
	
	self.pauseTime = currentTime
	self.isActive = false
	
	return nil
end

index_table.Stop = function(self: Timer): nil
	Check(module.isTimer(self), ThrowTimerOperationError)
	
	if self.startTime == -1 and self.stopTime == -1 and self.pauseTime == -1 and not self.isActive then
		return nil
	end
	
	self.startTime = -1
	self.stopTime = -1
	self.pauseTime = -1
	self.isActive = false
	return nil
end

index_table.GetCurrentTime = function(self: Timer): number
	Check(module.isTimer(self), ThrowTimerOperationError)
	
	if os.clock() >= self.stopTime then
		self.isActive = false
	end
	
	if self.isActive then
		return self.stopTime - os.clock()
		
	elseif self.pauseTime ~= -1 then
		return self.stopTime - self.pauseTime
	end
	return -1
end

index_table.SetDuration = function(self: Timer, seconds: number): nil
	Check(module.isTimer(self), ThrowTimerOperationError)
	Check(isNumber(seconds), ThrowTypeError, "number" ,"seconds", 2, seconds)
	Check(seconds > 0, ThrowDurationError, seconds, 2)
	
	self.duration = seconds
	return nil
end

index_table.MarkTimestamp = function(self: Timer, timestamp: number, action: Timer_Action): nil
	return nil
end

index_table.UnmarkTimestamp = function(self: Timer, timestamp: number): nil
	return nil
end

index_table.IsActive = function(self: Timer): boolean
	Check(module.isTimer(self), ThrowTimerOperationError)
	return self.isActive and os.clock() < self.stopTime
end

index_table.IsInactive = function(self: Timer): boolean
	Check(module.isTimer(self), ThrowTimerOperationError)
	if self.pauseTime == -1 and os.clock() >= self.stopTime then
		self.isActive = false
	end
	return self.pauseTime == -1 and not self.isActive
end

index_table.IsPaused = function(self: Timer): boolean
	Check(module.isTimer(self), ThrowTimerOperationError)
	return self.pauseTime ~= -1 and not self.isActive
end

index_table = index_table :: Timer_Method


-- METATABLE --

timer_meta.__index = index_table
timer_meta.__newindex = function(self: Timer, key: any, value: any): nil
	error(`Attempted to create a new index/key in <Timer> object.\nObject representation: {self}\nIndex/Key: {key}\nValue: {value}`)
end
timer_meta.__metatable = "TimerRBX"
timer_meta.__tostring = function(self: Timer): string
	-- Converts the current time into HH:MM:SS.SSS format. If it is inactive or unknown, returns 00:00:00.000 by default.
	
	local timerTime = self:GetCurrentTime()
	
	if timerTime == -1 then
		return "00:00:00.000"
	end
	
	local hours, minutes, seconds
	
	hours, timerTime = timerTime // 216000, timerTime % 216000
	minutes, timerTime = timerTime // 3600, timerTime % 3600
	seconds, timerTime = timerTime // 60, timerTime % 60
	
	hours = FormatDigit(hours, 2)
	minutes = FormatDigit(minutes, 2)
	seconds = FormatDigit(seconds, 2)
	timerTime = FormatDigit(timerTime, 3)
	
	return `{hours}:{minutes}:{seconds}:{timerTime}`
end

timer_meta = timer_meta :: Timer_Meta


-- MODULE --

module = {
	new = function(id: Timer_Identifier, duration: number, protected: boolean?): Timer
		Check(isTimerId(id), ThrowTypeError, "TimerId", "id", 1, id)
		Check(not module.hasTimer(id), ThrowExistingTimerError, id, 1)
		Check(isNumber(duration), ThrowTypeError, "number" ,"duration", 2, duration)
		Check(duration > 0, ThrowDurationError, duration, 2)
			
		local self: Timer = setmetatable({
			duration = duration,
			timestamps = {},
			
			startTime = -1,
			stopTime = -1,
			pauseTime = -1,
			
			isActive = false,
			
			Started = Instance.new("BindableEvent"),
			Resumed = Instance.new("BindableEvent"),
			Paused = Instance.new("BindableEvent"),
			Stopped = Instance.new("BindableEvent"),
			Ended = Instance.new("BindableEvent"),
			
			Changed = Instance.new("BindableEvent"),
			
			id = id,
			protected = if protected then protected else false
		}, timer_meta)
		storage[id] = self
		protected_storage[id] = if protected then self else nil
		return self
	end,
	
	destroy = function(id: Timer_Identifier): nil
		Check(isTimerId(id), ThrowTypeError, "TimerId", "id", 1, id)
		Check(not protected_storage[id], ThrowProtectedError, 1, id)
		
		local object = storage[id]
		
		table.clear(object.timestamps)
		
		object.duration = nil :: any
		object.timestamps = nil :: any
		
		object.startTime = nil :: any
		object.stopTime = nil :: any
		object.pauseTime = nil :: any
		
		object.isActive = nil :: any
		
		object.Started:Destroy()
		object.Resumed:Destroy()
		object.Paused:Destroy()
		object.Stopped:Destroy()
		object.Ended:Destroy()
		
		object.Started = nil :: any
		object.Resumed = nil :: any
		object.Paused = nil :: any
		object.Stopped = nil :: any
		object.Ended = nil :: any
		
		object.id = nil :: any
		object.protected = nil :: any
		
		storage[id] = nil
		return nil
	end,
	
	isTimer = function(candidate: Timer): boolean
		return type(candidate) == "table" and storage[candidate.id] == candidate
	end,
	
	hasTimer = function(id: Timer_Identifier): boolean
		Check(isTimerId(id), ThrowTypeError, "TimerId", "id", 1, id)
		return storage[id] ~= nil
	end
}

RunService.Heartbeat:Connect(function(_deltaTime: number)
	local currentTime = os.clock()
	
	for _, timer in storage do
		if timer.isActive and timer.stopTime > currentTime then
			ResetTimer(timer)
			timer.Stopped:Fire(currentTime)
			timer.Ended:Fire(currentTime)
		end
	end
end)

return module
