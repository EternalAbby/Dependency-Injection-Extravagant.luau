# WORK IN PROGRESS

This file is made as a temporary solution for a Documentation for this module. Anything below will be moved into the Wiki section in the future. Therefore, it is not guaranteed that this file is complete.

## Note

Short summary: Only use this module only when necessary (it's slow). Always cache the value if the case is the same (it isn't done internally).

Through extensive testing within an environment that is similar to a general use case for a `Roblox Studio` game project (this module's target game engine), every function within this module performs slower than its built-in counterparts. As such, it is recommended that this module should not be used, unless its features are needed for your use case. Therefore, this module cannot replace those built-in functions.

For details about the performance testing, it is tested at a sample size of `1`, `10^3`, `10^4 * 3`, and `10^6` iterations with varying test cases, ranging from trivial to deep searches. Results vary through each case, but in general, this module is at least **3 times slower** than built-ins, sometimes even worse. Therefore, it is recommended to cache the result of every function call if the case stays the same. The module does not internally cache these result by itself.

To reduce the amount of performance loss when using this module similar to its built-in counterparts, this module will call the built-in instead whenever possible, or terminates early to return the desired result.

## Definitions

These are type definitions within this module.

### FFI_Element type

This type is used in the `.FindFirstInstance()` function in the module. This is not meant to be used by the user.

```lua
type FFI_StackElement = {
	["Instance"]: Instance,
	["Start"]: number,
	["End"]: number
}
```

## Functions

These are functions within this module.

### .GetHierarchyDepth(root: Instance): number

Compute the `depth` of `root`.

A "depth" is defined to be a layer into an Instance.

The total "depth" of an instance is how deep `root` is from the Datamodel `game`.

Returns the "depth".

### .GetFullNameAsStringArray(root: Instance): {string}

Compute the full directory path to `root`. Unlike the built-in `Instance:GetFullName()`, this is returned as a string array.

In Luau, arrays are 1-indexed, so the starting element is at index 1. `root` is the starting element.

Every subsequent ancestor is appended into the array. This process stops at the service provider ancestor of `root`, meaning before it appends the Datamodel `game`.

Returns the resulting array.

### .GetFullNameAsInstancesArray(root: Instance): {Instance}

Compute the full directory path to `root`. Unlike the built-in `Instance:GetFullName()`, this is returned as an Instance array.

In Luau, arrays are 1-indexed, so the starting element is at index 1. `root` is the starting element.

Every subsequent ancestor is appended into the array. This process stops at the service provider ancestor of `root`, meaning before it appends the Datamodel `game`.

Returns the resulting array.

### .FindFirstInstance(name: string | {string}): Instance?

Attempts to find the first `Instance` that satisfies `name`.

`name` can either be a string, the result from the built-in function `Instance:GetFullName()`, or it can be a string array, the result from the `.GetFullNameAsStringArray()` function.

Returns the resulting instance. If failed, returns `nil`.

*Note: As of v1.0.0, there are internally 2 implementations of this function: recursive, and iterative. Currently, the iterative solution is used in the module's source code. This is to prevent possible stack overflow on the function call stack, and memory usage in the worst-case scenario, where searches are very deep, and it reaches the allowed memory usage. However, through testing on **high sample sizes**, and deep searches (5 layers), the iterative solution is much slower than the recursive solution, due to overhead when doing searches. This isn't the case for singular iterations, so it is odd. It should be noted that iterative solutions are theoretically faster than recursive solutions. Actively finding a possible optimization to the iterative solution.*

### .FindFirstDescendant(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?): Instance?

Attempts to find the first descendant in `root` that satisfies `target`. Similar to its built-in counterpart, `root:FindFirstChild(target, true)` (or the deprecated `root:FindFirstDescendant(target)`).

Optionally, the `depth` parameter offsets the hierarchy of the instance to return. By default, this functionality is not used until specified with a positive integer. If a different number type is provided, returns `nil`.

Optionally, the `mode` parameter changes the behavior of the function. The following table shows the behavior used:

| mode             | "default"                           | "class"                                    | "inherit"                                   |
|------------------|-------------------------------------|--------------------------------------------|---------------------------------------------|
| Function         | `root:FindFirstChild(target, true)` | `root:FindFirstChildOfClass(target, true)` | `root:FindFirstChildWhichIsA(target, true)` |
| Built-in/Custom? | Built-in                            | Built-in                                   | Custom                                      |

By default, `mode` is set to use the `"default"` behavior.

Returns the resulting instance.

### .FindFirstAncestor(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?): Instance?

Attempts to find the first ancestor in `root` that satisfies `target`. Similar to its built-in counterpart, `Instance:FindFirstAncestor()`.

Optionally, the `depth` parameter offsets the hierarchy of the instance to return. By default, this functionality is not used until specified with a non-zero integer. If a different number type is provided, returns `nil`.

Optionally, the `mode` parameter changes the behavior of the function. The following table shows the behavior used:

| mode             | "default"                              | "class"                                       | "inherit"                                      |
|------------------|----------------------------------------|-----------------------------------------------|------------------------------------------------|
| Function         | `root:FindFirstAncestor(target, true)` | `root:FindFirstAncestorOfClass(target, true)` | `root:FindFirstAncestorWhichIsA(target, true)` |
| Built-in/Custom? | Built-in                               | Built-in                                      | Custom                                         |

By default, `mode` is set to use the `"default"` behavior.

Returns the resulting instance.

### .IsAncestorOf(root: Instance, target: Instance, depth: number?): (boolean, Instance?)

Determines whether `root` is the ancestor of `target`.

Optionally, the `depth` parameter offsets the hierarchy of the instance to return. By default, this functionality is not used until specified with a non-zero integer. If a different number type is provided, returns `nil`.

Returns the resulting instance.

### .IsDescendant(root: Instance, target: Instance, depth: number?): (boolean, Instance?)

Determines whether `root` is the descendant of `target`.

Optionally, the `depth` parameter offsets the hierarchy of the instance to return. By default, this functionality is not used until specified with a positive integer. If a different number type is provided, returns `nil`.

Returns the resulting instance.
