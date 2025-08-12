# WORK IN PROGRESS
This file is made as a temporary solution for a Documentation for this module. Anything below will be moved into the Wiki section in the future. Therefore, it is not guaranteed that this file is complete.

# Note
Due to current limitations with user-generated function descriptions in Roblox Studio. Only Constructors, Functions, and Methods will include their respective descriptions. Metamethods will not have their function descriptions stated. However, they will be listed here in the Documentation section.

# Documentation
This section includes Definitions, Constructors, Functions, Methods, and Metamethods in that order.

## Definitions
These are type definitions that are used in the module.

### RawComplexNumber type
```lua
export type RawComplexNumber = {
	["real"]: number,
	["complex"]: number
}
```
*`number` primitive type **must not** be `math.huge` (inf), `-math.huge` (-inf), or `nan` (not a number). This is to prevent any unexpected behavior from these special numbers.*

### ComplexNumber type
```lua
export type ComplexNumber = setmetatable<{
	["real"]: number,
	["complex"]: number
}, typeof(module)>
```
*`number` primitive type **must not** be `math.huge` (inf), `-math.huge` (-inf), or `nan` (not a number). This is to prevent any unexpected behavior from these special numbers.*

## Constructors
These are constructors that can be used by the user.

### .new(real: number, complex: number): ComplexNumber
Creates a new `ComplexNumber` object from `real`, and `complex`.

`real`, and `complex` are `number` primitive types. Both `real`, and `complex` **must not** be `math.huge` (inf), `-math.huge` (-inf), or `nan` (not a number) as their respective value.

The accepted expression of this constructor is in both the general form, and the rectangular form (with `real`, and `complex` be substituted by the coordinates of the x-axis, and the y-axis of the complex number on the complex plane respectively)

Returns the new `ComplexNumber` object. If failed, throws an error.

Alternatively, for constructing a new `ComplexNumber` object;
- From a valid `RawComplexNumber` type, use the `.fromRaw()` constructor instead.
- From the polar form, use the `.fromPolar()` constructor instead.

### .fromRaw(raw: RawComplexNumber): ComplexNumber
Creates a new `ComplexNumber` object from `raw`.

`raw` must be a `table` primitive type that can be read via `table[idx]`, and must have a key named `real`, and `complex` with their respective type. Other keys in `raw` are ignored, if there are any. Refer to `Definitions` for its structure.

`real`, and `complex` are `number` primitive types. Both `real`, and `complex` **must not** be `math.huge` (inf), `-math.huge` (-inf), or `nan` (not a number) as their respective value.

Returns the new `ComplexNumber` object. If failed, throws an error.

Alternatively, for constructing a new `ComplexNumber` object;
- From the general/rectangular form, use the `.new()` constructor instead.
- From the polar form, use the `.fromPolar()` constructor instead.

### .fromPolar(magnitude: number, argument: number): ComplexNumber
Creates a new `ComplexNumber` object from `magnitude`, and `argument` (angle is in radians).

`magnitude`, and `argument` are `number` primitive types. Both `magnitude`, and `argument` **must not** be `math.huge` (inf), `-math.huge` (-inf), or `nan` (not a number) as their respective value.

Returns the new `ComplexNumber` object. If failed, throws an error.

Alternatively, for constructing a new `ComplexNumber` object;
- From the general/rectangular form, use the `.new()` constructor instead.
- From a valid `RawComplexNumber` type, use the `.fromRaw()` constructor instead.

## Functions
These are functions that can be used by the user.

### .cis(theta: number): number
Computes the `cis` trigonometry function using an angle `theta` (in radians). `theta` must be a `number` primitive type. `theta` must not be either `inf` nor `nan`.

This function is equivalent to computing the trigonometry formula: `cos(theta) + 𝒊 sin(theta)`. Subsequently, it is also the result of Euler's formula: `e^(i * theta) = exp(𝒊 * theta)`. In some details, this is due to the formula's property, which "establishes the relationship between the trignometric functions, and the complex exponential function" (Wikipedia). For more details, please refer to the [Wikipedia](https://en.wikipedia.org/wiki/Euler%27s_formula) page for Euler's formula.

Returns a new `ComplexNumber` object as the result from computing `cis()`. If failed, throws an error.


## Methods
These are methods that can be used by the user.

### :clone(): ComplexNumber
Creates a new copy of the `ComplexNumber` object.

Returns a new `ComplexNumber` object, whose components are from the `ComplexNumber` object, which called this method.

### :magnitude(): number
Computes the magnitude (modulus/absolute value) of the `ComplexNumber` object.

Returns the result.

Alternatively, you can use the `__len()` metamethod with the `#` operator for the same result.

### :argument(): number
Computes the argument (counter-clockwise angle from the positive real axis) of the ComplexNumber object.

Returns the result.

### :conjugate(): number
Creates a new ComplexNumber object that is the complex conjugate to the ComplexNumber object which this method was called on.

Returns the result.

### :polar(): (number, number)
Computes both the magnitude, and the complex argument.

Returns the result


## Raw Methods
These are raw methods that can be used by the user. These methods are similar to their metamethod counterparts, except they will modify the left-most operand. Operations are performed from left to right. All raw methods can also be used on valid `RawComplexNumber` types.

-- TBA --

## Metamethods
These are metamethods that can be used by the user.

## Metamethods - Basic Arithmetic Operation
These metamethods define the syntatic sugar for `ComplexNumber` objects to perform basic arithmetic operations.

### .__unm(a: ComplexNumber): ComplexNumber
Creates a new `ComplexNumber` object that is the additive inverse of `a`.

Returns the new `ComplexNumber` object.

### .__add(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
Creates a new `ComplexNumber` object that is the sum of `a`, and `b`.

Returns the new `ComplexNumber` object. If neither `a`, or `b` is the correct type, throws an error.

### .__sub(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
Creates a new `ComplexNumber` object that is the difference of `a`, and `b`.

Returns the new `ComplexNumber` object. If neither `a`, or `b` is the correct type, throws an error.

### .__mul(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
Creates a new `ComplexNumber` object that is the product of `a`, and `b`.

Returns the new `ComplexNumber` object. If neither `a`, or `b` is the correct type, throws an error.

### .__div(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
Creates a new `ComplexNumber` object that is the ratio of `a`, and `b`.

Returns the new `ComplexNumber` object. If neither `a`, or `b` is the correct type, throws an error.

### .__idiv(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
Creates a new `ComplexNumber` object that is the ratio of `a`, and `b`. Then, takes the integer representation for each parts.

Equivalent to using `.__div()` metamethod, then applying `math.floor()` to the real, and imaginary parts.

Returns the new `ComplexNumber` object. If neither `a`, or `b` is the correct type, throws an error.

### .__mod(a: ComplexNumber | number, b: ComplexNumber | number): nil
Although this method is defined in the source code, it does not have any functionality.

As of v1.0.0, attempting to use the `%` operator will always throw an error.

### .__pow(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber
Creates a new `ComplexNumber` object that is the exponentiation of `a`, and `b`.

Here's a list of every edge cases, and its returned values.
```
1. 0 ^ 0						->			1
2. 0 ^ purely-complex			->			Error: Undefined limit behavior for purely imaginary exponent.
3. 0 ^ +real					->			0
4. 0 ^ -real					->			Error: Attempted to perform division by zero.
```
*Note: For case 1, and 3, the returned value is a new `ComplexNumber` object.*

Returns the new `ComplexNumber` object. If neither `a`, or `b` is the correct type, throws an error.

## Metamethods - Equality Comparison
### .__eq(a: ComplexNumber, b: ComplexNumber): boolean
Determines whether both `a`, and `b` are *equivalent* (or the expression `a == b`). This is done by comparing their magnitude.

Returns `true` if equivalent. Otherwise, returns `false`.

### .__lt(a: ComplexNumber, b: ComplexNumber): boolean
Determines whether `a` is *strictly less than* `b` (or the expression `a < b`). This is done by comparing their magnitude.

Because this is also used for *strictly greater than*, this metamethod is equivalent to determining whether `b` is *strictly greater than* `a` (or the expression `b > a`).

Returns `true` if `a` is strictly less than `b`. Otherwise, returns `false`.

### .__le(a: ComplexNumber, b: ComplexNumber): boolean
Determines whether `a` is *less than or equal to* `b` (or the expression `a <= b`). This is done by comparing their magnitude.

Because this is also used for *greater than or equal to*, this metamethod is equivalent to determining whether `b` is *greater than or equal to* `a` (or the expression `b >= a`).

Returns `true` if `a` is less than or equal to `b`. Otherwise, returns `false`.

## Metamethods - Other
### .__newindex
Throws an error if you attempt to create a new key/index.

### .__metatable
Returns the string `"ComplexNumber"` when using `getmetatable()` on a `ComplexNumber` object.

### .__len(self: ComplexNumber): number
Computes the magnitude (modulus/absolute value) of the ComplexNumber object.

Returns the result.

Alternatively, you can call the `:magnitude()` method with the same result. Internally, this metamethod directs to the method.

As of v1.0.0, there is no error handling.

### .__tostring(self: ComplexNumber): string
Creates a string representation of the `ComplexNumber` object. The display format is in rectangular form, similar to that of the built-in `cmath` module in Python.

Returns the resulting formatted string.

**EXAMPLE CODE**

ServerScriptService.Script
```lua
local ComplexNumber = require(path.to.module)
local num = ComplexNumber.new(2, 3)
print(num) -- using print() calls __tostring
```

Output
```lua
(2 + 3𝒊)
```
