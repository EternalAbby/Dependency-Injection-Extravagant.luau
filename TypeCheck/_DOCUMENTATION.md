# WORK IN PROGRESS
This file is made as a temporary solution for a Documentation for this module. Anything below will be moved into the Wiki section in the future. Therefore, it is not guaranteed that this file is complete.

# Note
Due to dependency from `ComplexNumber` module, this module is made public.

Please note that this module does not have an exhaustive list of every types as of v0.1.0. Do expect changes made to this module as it was not meant to be ready for use.

# Documentation
This section includes Functions.

## Functions
These are functions that can be used by the user.

### .isString(candidate: any): boolean
Returns `true` if `candidate` is a `string` primitive type.

### .isNumber(candidate: any, allowSpecial: boolean): boolean
Returns `true` if `candidate` is a `number` primitive type.

Optional `allowSpecial` parameter filters `math.huge`, and `nan`. By default, it is `false`.

### .isComplexNumber(candidate: any): boolean
Returns `true` if `candidate` is a `RawComplexNumber` type, or a `ComplexNumber` type. These types are used in the `ComplexNumber` module.

### .isBoolean(candidate: any, exclude_nil: boolean): boolean
Returns `true` if `candidate` is a `boolean` primitive type.

Optional `exclude_nil` parameter filters `nil`. By default, it is `false`.

### .isTable(candidate: {[any]: any}): boolean
Returns `true` if `candidate` is a `table` primitive type.

### .isArray(candidate: {[number]: any}, ignore_PrerequsiteChecks: boolean?): boolean
Returns `true` if `candidate` is a `table` primitive type, and has only a index-value structure.

### .isDictionary(candidate: {[any]: any}, ignore_PrerequsiteChecks: boolean?): boolean
Returns `true` if `candidate` is a `table` primitive type.

Equivalent to `.isTable()`

### .isRBXObject(candidate: any, classname: string?): boolean
Returns `true` if `candidate` is a `Object` type.

Optional `classname` checks for matching `.ClassName` property of `candidate`.