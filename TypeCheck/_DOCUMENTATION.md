# WORK IN PROGRESS
This file is made as a temporary solution for a Documentation for this module. Anything below will be moved into the Wiki section in the future. Therefore, it is not guaranteed that this file is complete.

# Note
Due to dependency from `ComplexNumber` module, this module is made public.

Disclaimer: This module does **not** include an exhaustive list of every Luau primitive types as of v0.1.1. As this module is still in its unstable state, do expect future changes made to this module that *may* any existing code. You have been warned.

# Documentation
This section includes Definitions, and Functions in that order.

## Definitions
These are type definitions from DIE modules, which are supported by this module.

### RawComplexNumber type
This type is from the ComplexNumber module.
```lua
type RawComplexNumber = {
	["real"]: number,
	["complex"]: number
}
```

## Functions
These are functions that can be used by the user.

### .isString(candidate: string?): boolean
Returns `true` if `candidate` is a `string` primitive type.

### .isNumber(candidate: number?, allowSpecial: boolean?): boolean
Returns `true` if `candidate` is a valid `number` primitive type.

Optional `allowSpecial` parameter filters `math.huge`, and `nan`. By default, it is `false`.

### .isComplexNumber(candidate: RawComplexNumber?): boolean
Returns `true` if `candidate` is a `RawComplexNumber` type, or a `ComplexNumber` type. These types are used in the `ComplexNumber` module.

### .isBoolean(candidate: boolean | nil, exclude_nil: boolean?): boolean
Returns `true` if `candidate` is a `boolean` primitive type.

Optional `exclude_nil` parameter filters `nil`. By default, it is `false`.

### .isTable(candidate: {[any]: any}): boolean
Returns `true` if `candidate` is a `table` primitive type.

### .isArray(candidate: {[number]: any}, ignore_PrerequsiteChecks: boolean?): boolean
Returns `true` if `candidate` is a `table` primitive type, and has only a index-value structure.

In other words, returns `true` if `candidate` is a valid `array`.

### .isDictionary(candidate: {[any]: any}, ignore_PrerequsiteChecks: boolean?): boolean
Returns `true` if `candidate` is a `table` primitive type.

Equivalent to using the `.isTable()` function.

### .isRBXObject(candidate: Object?, classname: string?): boolean
Returns `true` if `candidate` is a `Object` type.


Optional `classname` parameter checks for matching `.ClassName` property of `candidate`.
