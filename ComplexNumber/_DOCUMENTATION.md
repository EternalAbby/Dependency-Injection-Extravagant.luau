# WORK IN PROGRESS

This file is made as a temporary solution for a Documentation for this module. Anything below will be moved into the Wiki section in the future. Therefore, it is not guaranteed that this file is complete.

## Note

Function descriptions are included with the function. However, they are not as descriptive as the ones within the `Documentation` section.

As of v1.0.0, due to current limitations with user-generated function descriptions in `Roblox Studio`. Only `Constructor`s, `Function`s, `Raw Method`s and `Method`s will include their respective function descriptions. `Metamethod`s will not have their function descriptions stated. However, they will still be listed here in the `Documentation` section.

As of v1.0.0, this module does not support `number` primitive types that are `math.huge` (inf), and `nan` (not a number). As such, these values should be avoided at all costs. When a `number` primitive type is mentioned, it should be noted that it does not include these values.

As of v1.0.0, valid `RawComplexNumber` types, and valid `ComplexNumber` types are read via `table[key]` (dynamic accessing), meaning if a false-positive type passes the assertion checks, they may trigger the `Metamethod`s of that invalid `metatable`.

## Documentation

This section includes Definitions, Constructors, Functions, Methods, and Metamethods in that order.

## Definitions

These are type definitions that are defined and used within the module.

### RawComplexNumber type

A valid `RawComplexNumber` object is defined to be a valid `RawComplexNumber` type.

A valid `RawComplexNumber` type is defined to be a `table` primitive type, which includes a `real` key, and a `complex` key. Both keys **must** have a value set to a `number` primitive type, as seen in the code block below.

*Note: Any keys besides the ones listed will be ignored in the module.*

```lua
export type RawComplexNumber = {
	["real"]: number,
	["complex"]: number
}
```

### ComplexNumber type

A valid `ComplexNumber` object is defined to be a valid `ComplexNumber` type.

A valid `ComplexNumber` type is defined to be a `table` primitive type, which includes a `real` key, and a `complex` key. Both keys **must** have a value set to a `number` primitive type, as seen in the code block below. Along with that, it must also contain a `metatable` with the `__metatable` metamethod set to `"ComplexNumber"`. This `metatable` should be set from the module itself. However, it can be locally made, which may cause problems when using this module.

*Note: Any keys besides the ones listed will be ignored in the module. Every `ComplexNumber` objects created from this module will not include any keys other than the ones listed.*

```lua
export type ComplexNumber = setmetatable<{
	["real"]: number,
	["complex"]: number
}, typeof(module)>
```

## Constructors

These are constructors that are defined within this module. These can be used by the users to create a new `ComplexNumber` object by specifying the appropriate types for the parameters.

*Note: It is possible to manually create a valid `RawComplexNumber` object, and a valid `ComplexNumber` object. They will be detected as false-positives by the runtime typechecker (using `TypeCheck V0.3.0`). There are currently no plans on reinforcing this as of v1.1.0.*

### .new(real: number, complex: number): ComplexNumber

Creates a new `ComplexNumber` object from `real`, and `complex`.

The components of this constructor is valid for both the general form (where it is formatted using `real`, and `complex`), and the rectangular form (where it is formatted using the `x-coordinate`, and the `y-coordinate`).

Returns the new `ComplexNumber` object.

If failed, throws an assertion error.

Alternatively, for constructing a new `ComplexNumber` object;

- From a valid `RawComplexNumber` type, use the `.fromRaw()` constructor instead.
- From the polar form, use the `.fromPolar()` constructor instead.

### .fromRaw(raw: RawComplexNumber): ComplexNumber

Creates a new `ComplexNumber` object from `raw`.

The components of this constructor is valid for both the general form (where it is formatted using `real`, and `complex`), and the rectangular form (where it is formatted using the `x-coordinate`, and the `y-coordinate`).

Returns the new `ComplexNumber` object.

If failed, throws an assertion error.

Alternatively, for constructing a new `ComplexNumber` object;

- From the general/rectangular form, use the `.new()` constructor instead.
- From the polar form, use the `.fromPolar()` constructor instead.

### .fromPolar(magnitude: number, argument: number): ComplexNumber

Creates a new `ComplexNumber` object from `magnitude`, and `argument` (angle value is in radians).

The components of this constructor is valid for the polar form (where it is formatted using `magnitude`, and `argument`).

Returns the new `ComplexNumber` object.

If failed, throws an assertion error.

Alternatively, for constructing a new `ComplexNumber` object;

- From the general/rectangular form, use the `.new()` constructor instead.
- From a valid `RawComplexNumber` type, use the `.fromRaw()` constructor instead.

## Functions

These are functions that are defined within this module. These can be used by the users as a pre-made quality of life feature.

### .cis(theta: number): ComplexNumber

Creates a new `ComplexNumber` object that is the result of computing the `cis()` trignometry function using `theta` (angle value is in radians).

This function is equivalent to computing the trigonometry expression: `cos(theta) + 𝒊 sin(theta)`.

Subsequently, it is also the result of Euler's formula: `e^(i * theta) = exp(𝒊 * theta)`.

For a quick summary, this is due to the forumla's property, which states: "...establishes the relationship between the trignometric functions, and the complex exponential function" (Wikipedia). For more details, please refer to the [Wikipedia](https://en.wikipedia.org/wiki/Euler%27s_formula) page for Euler's formula.

Returns the new `ComplexNumber` object.

## Methods

These are methods that are defined within this module. These can be used by the users to perform simple tasks on the `ComplexNumber` object which called the method (`self`).

### :clone(): ComplexNumber

Creates a new copy of the `ComplexNumber` object, whose components are from `self`.

Returns a new `ComplexNumber` object

### :magnitude(): number

Computes the magnitude (modulus/absolute value) of `self`.

Returns the result.

Alternatively, you can use the `__len()` metamethod with the `#` operator for the same result.

### :argument(): number

Computes the argument (counter-clockwise angle from the positive real axis on the complex plane) of `self`.

Returns the result.

### :conjugate(): ComplexNumber

Creates a new `ComplexNumber` object that is the complex conjugate of `self`.

Returns the new `ComplexNumber` object.

If creating a new `ComplexNumber` object is undesirable, use the `:raw_conjugate()` raw method instead.

### :polar(): (number, number)

Computes both the magnitude, and the complex argument of `self`.

Returns the `magnitude`, and the `argument`.

## Raw Methods

These are raw methods that are defined within the module. These can be used by the user to have more control over the modifications of a valid `RawComplexNumber` object, or a valid `ComplexNumber` object.

It is possible to specify as many valid `RawComplexNumber` object, and valid `ComplexNumber` object as you like. The raw methods will *iteratively* compute the operands from left to right (or in other words, from the first argument to the last argument) to `self`.

Some raw methods are similar to their `Method`, and `Metamethod` counterparts, except they will modify the left-most operand components, or `self`, instead of creating a new `ComplexNumber` object. These modifications are done so that it doesn't exhaust memory usages.

Some raw methods are similar to their `Method` counterparts, except they allow valid `RawComplexNumber` objects as their parameters.

As of v1.1.0, support for `number` primitive types are not implemented, yet. However, you can easily create a `RawComplexNumber` object as a workaround for now.

## Raw Methods - Basic Arithmetic Operation

This sub-section includes every raw methods that are the equivalent counterparts of the `Metamethods - Basic Arithmetic Operation` section.

### :raw_unm(self: RawComplexNumber): nil

Modify the components of `self` to its additive inverse.

Returns `nil`.

### :raw_add(self: RawComplexNumber, ...: RawComplexNumber): nil

Modify the components of `self` by performing addition to it for each operand.

Returns `nil`.

### :raw_sub(self: RawComplexNumber, ...: RawComplexNumber): nil

Modify the components of `self` by performing subtraction to it for each operand.

Returns `nil`.

### :raw_mul(self: RawComplexNumber, ...: RawComplexNumber): nil

Modify the components of `self` by performing multiplication to it for each operand.

Returns `nil`.

### :raw_div(self: RawComplexNumber, ...: RawComplexNumber): nil

Modify the components of `self` by performing division to it for each operand.

At any point, attempting to divide by 0 (0 + 0𝒊) will throw an error.

Returns `nil`.

### :raw_idiv(self: RawComplexNumber, ...: RawComplexNumber): nil

Modify the components of `self` by performing int division to it for each operand.

For each operand, the int division property will take affect. That means, the quotient after each operation is floored.

At any point, attempting to divide by 0 (0 + 0𝒊) will throw an error.

Returns `nil`.

### :raw_mod(): nli

Although this raw method is defined in the source code, it does not have any functionality.

As of v1.1.0, attempting to use this raw method will always throw an error.

### :raw_pow(self: RawComplexNumber, ...: RawComplexNumber): nil

Modify the components of `self` by performing exponentiation to it for each operand.

For edge cases, the results are the ones listed in `__pow()` metamethod.

Returns `nil`.

## Raw Methods - Equality Comparison

This sub-section includes every raw methods that are the equivalent counterparts of the `Metamethods - Equality Comparison` section.

### :raw_eq(self: RawComplexNumber, ...: RawComplexNumber): boolean

Returns a `boolean` determining whether `self` is equivalent to every operands by comparing the `magnitude`.

### :raw_lt(self: RawComplexNumber, ...: RawComplexNumber): boolean

Returns a `boolean` determining whether `self` is less than every operands by comparing the `magnitude`.

### :raw_le(self: RawComplexNumber, ...: RawComplexNumber): boolean

Returns a `boolean` determining whether `self` is less than or equal to every operands by comparing the `magnitude`.

### :raw_gt(self: RawComplexNumber, ...: RawComplexNumber): boolean

Returns a `boolean` determining whether `self` is greater than every operands by comparing the `magnitude`.

### :raw_ge(self: RawComplexNumber, ...: RawComplexNumber): boolean

Returns a `boolean` determining whether `self` is greater than or equal to every operands by comparing the `magnitude`.

## Raw Methods - From Method

This sub-section includes every raw methods that are the equivalent counterparts of the `Methods` section.

### :raw_magnitude(self: RawComplexNumber): number

Similar to `:magnitude` method.

Returns the result.

### :raw_argument(self: RawComplexNumber): number

Similar to `:argument` method.

Returns the result.

### :raw_conjugate(self: RawComplexNumber): nil

Modify `self` to its conjugate.

Returns `nil`

## Raw Methods - Other

### :raw_tostring(self: RawComplexNumber, representation: ("general" | "rectangular" | "polar" | "euler")?): string

Creates a new `string` that is formatted to display `self`, according to `representation` parameter.

By default, `representation` is set to display in the `"general"` form. If `representation` is not set, or it is set to an invalid mode, the default will be used.

Returns the formatted `string` to display `self`.

## Metamethods

These are metamethods defined within the module. These can be used by the users by following the syntactic sugar of traditional metamethods.

Some metamethods create a new `ComplexNumber` object to store their result. This allows easier access to the original `ComplexNumber` objects that performed those operations. If this functionality is undesirable, please refer to the `Raw Methods` section, includes equivalent methods to ones listed here, but modify the components of `self` instead.

## Metamethods - Initial

These are essentially properties within the `metatable` for `ComplexNumber` objects.

### .__index()

This is pointed back into the module.

This allows **O**bject-**O**rientated **P**rogramming (OOP), and syntactic sugars for `ComplexNumber` objects.

### .__newindex()

Throws an error if you attempt to create a new key/index.

### .__metatable

Returns the string `"ComplexNumber"` when using `getmetatable()` on a `ComplexNumber` object.

## Metamethods - Basic Arithmetic Operation

These metamethods define the syntactic sugar for `ComplexNumber` objects to perform basic arithmetic operations.

### .__unm(a: ComplexNumber): ComplexNumber

Creates a new `ComplexNumber` object that is the additive inverse of `a`.

Returns the new `ComplexNumber` object. If `a` is not a `ComplexNumber`, throws an error.

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

Although this metamethod is defined in the source code, it does not have any functionality.

As of v1.0.0, attempting to use the `%` operator will always throw an error.

### .__pow(a: ComplexNumber | number, b: ComplexNumber | number): ComplexNumber

Creates a new `ComplexNumber` object that is the exponentiation of `a`, and `b`.

Here's a list of every edge cases, and its returned values.

| Index | Edge case          | Result                                                         |
|-------|--------------------|----------------------------------------------------------------|
| 1     | 0 ^ 0              | 1 + 0𝒊                                                         |
| 2     | 0 ^ purely-complex | Error: Undefined limit behavior for purely imaginary exponent. |
| 3     | 0 ^ +real          | 0 + 0𝒊                                                         |
| 4     | 0 ^ -real          | Error: Attempted to perform division by zero.                  |

*Note: For case 1, and 3, the returned value is a new `ComplexNumber` object, not a `number` primitive type.*

Returns the new `ComplexNumber` object. If neither `a`, or `b` is the correct type, throws an error.

## Metamethods - Equality Comparison

All metamethods compute the magnitude of both `a`, and `b` to compare.

### .__eq(a: ComplexNumber, b: ComplexNumber): boolean

Determines whether both `a`, and `b` are *equivalent* (or the expression `a == b`).

This metamethod only fires when both `a`, and `b` have this `metatable`. For reasons why, refer to this [link here](https://create.roblox.com/docs/luau/metatables#metamethods).

Returns `true` if equivalent. Otherwise, returns `false`.

### .__lt(a: ComplexNumber, b: ComplexNumber): boolean

Determines whether `a` is *strictly less than* `b` (or the expression `a < b`).

This metamethod only fires when both `a`, and `b` have this `metatable`. For reasons why, refer to this [link here](https://create.roblox.com/docs/luau/metatables#metamethods).

Because this is also used for *strictly greater than*, this metamethod is equivalent to determining whether `b` is *strictly greater than* `a` (or the expression `b > a`). For reasons why, they are also outlined in the link above.

Returns `true` if `a` is strictly less than `b`. Otherwise, returns `false`.

### .__le(a: ComplexNumber, b: ComplexNumber): boolean

Determines whether `a` is *less than or equal to* `b` (or the expression `a <= b`).

This metamethod only fires when both `a`, and `b` have this `metatable`. For reasons why, refer to this [link here](https://create.roblox.com/docs/luau/metatables#metamethods).

Because this is also used for *greater than or equal to*, this metamethod is equivalent to determining whether `b` is *greater than or equal to* `a` (or the expression `b >= a`). For reasons why, they are also outlined in the link above.

Returns `true` if `a` is less than or equal to `b`. Otherwise, returns `false`.

## Metamethods - Other

These don't have any proper classifications, so they are placed here.

### .__len(self: ComplexNumber): number

Computes the magnitude (modulus/absolute value) of the ComplexNumber object.

Returns the result.

Alternatively, you can call the `:magnitude()` method with the same result. Internally, this metamethod directs to the method.

### .__tostring(self: ComplexNumber): string

Creates a new `string` that is formatted to display `self`, The representation is in general form, similar to that of the built-in `cmath` module in Python.

For more functionality in displaying the `string`, use the `:raw_tostring()` raw method instead.

Returns the formatted `string` to display `self`.

#### **EXAMPLE CODE**

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
