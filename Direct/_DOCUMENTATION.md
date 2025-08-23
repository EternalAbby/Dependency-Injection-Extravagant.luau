# WORK IN PROGRESS

This file is made as a temporary solution for a Documentation for this module. Anything below will be moved into the Wiki section in the future. Therefore, it is not guaranteed that this file is complete.

## Note

Short summary: Only use this module only when necessary (it's slow). Always cache the value if the input cases are the same (it isn't done internally).

Through extensive testing within an environment that is similar to a general use case for a `Roblox Studio` game project (this module's target game engine), every function within this module performs slower than its built-in counterparts. As such, it is recommended that this module should not be used, unless its features are needed for your use case. Therefore, this module cannot replace those built-in functions.

For details about the performance benchmark, it is tested at a sample size of `1`, `10^3`, `10^4 * 3`, and `10^6` iterations with varying test cases, ranging from trivial to deep searches. Results vary through each case, but in general, this module is at least **3 times slower** than built-ins, sometimes even worse. Therefore, it is recommended to cache the result of every function call if the case stays the same. The module does not internally cache these result by itself.

To reduce the amount of performance loss when using this module similar to its built-in counterparts, this module will prioritize calling the built-in function instead whenever possible, or terminates early to return the desired result. Efforts are done to ensure that the performance of this module is optimized for time and space.

## Documentation

This section includes Definitions and Functions in that order.

## Definitions

These are definitions within this module.

### Depth

This module uses the term "depth" to refer to **2** different definitions.

1. A "depth", as in the descending hierarchy of the instance within the `Explorer`, is defined as an integer, corresponding to every steps (via performing recursively the operation `root = root.Parent`) from the `root` towards the DataModel `game`.

	- The total "depth" is the total step needed from the `root` to reach the DataModel `game`.
	- If "depth" is 0, the `root` is the DataModel `game` itself.
	- This can be obtained from the `.GetHierarchyDepth()` function.
	- Example: `game.Workspace.Part` has a "depth" of 2.

2. A "depth", as in the offset parameter for functions, is defined as an integer offset from the `target`. This definition is used for input parameters for functions.

	- If "depth" is positive, this offset goes towards the DataModel `game`.
	- If "depth" is negative and `root` has larger "depth" (def. 1) than `target`, this offset goes towards the `root`. This is impossible to compute if the second requirement is not true.
	- If "depth" is 0, it is the `target` itself.
	- If "depth" is provided as a non-integer, it is truncated into its integer representation.
	- Example: From the root `game.Workspace.Part.Trail` and the target `game.Workspace.Part`: `depth = 1` returns `game.Workspace`, `depth = -1` returns `game.Workspace.Part.Trail`.

## Functions

These are functions within this module. They can provide quality of life functionalities to the users when traversing through the hierarchy of instances in the `Explorer`.

It is important to note that the performance of these functions are not replaceable with their built-in counterparts. Therefore, only use these functions when it is needed, and manually cache the result whenever possible. Refer to the `Note` section above for more details.

### .GetHierarchyDepth(root: Instance): number

Compute the `depth` (def. 1) of `root`.

Returns the `depth`.

### .GetFullNameAsStringArray(root: Instance): {string}

Compute the full directory path of `root`.

Unlike the built-in `Instance:GetFullName()`, this function returns an array of strings instead. Allows more flexibility with the ancestors of `root`.

In Luau, arrays are 1-indexed, so the starting element is at index 1. `root` is the starting element. Every subsequent ancestor is *appended* into the array. This process stops at the service provider ancestor of `root`, meaning before it appends the Datamodel `game` into the array.

Returns the computed array.

### .GetFullNameAsInstancesArray(root: Instance): {Instance}

Compute the full directory path to `root`.

Unlike the built-in `Instance:GetFullName()`, this function returns an array of instances instead. Allows more flexibility with the ancestors of `root`.

In Luau, arrays are 1-indexed, so the starting element is at index 1. `root` is the starting element. Every subsequent ancestor is *appended* into the array. This process stops at the service provider ancestor of `root`, meaning before it appends the Datamodel `game` in the array.

Returns the computed array.

### .FindFirstInstance(name: string | {string}): Instance?

Attempts to find the first `Instance` object that satisfies the `name` parameter.

`name` can either be in the format from the built-in `Instance:GetFullName()`, or in the format from the module's `.GetFullNameAsStringArray()` function.

Returns the `Instance` if found. Otherwise, returns `nil`.

*Note: As of v1.0.0, there are internally 2 implementations of this function: recursive, and iterative. Currently, the iterative solution is used in the module's source code. This is to prevent excessive memory usages when using this function on deep searches. However, through testing on **high sample sizes**, and deep searches (5 layers), the iterative solution is much slower than the recursive solution, due to overhead when doing searches. This isn't the case for singular iterations, so it is quite odd when testing. It should be noted that iterative solutions are theoretically faster than recursive solutions. Actively finding a possible optimization to the iterative solution.*

### .FindFirstDescendant(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?): Instance?

Attempts to find the first `Instance` descendant in `root` that satisfies the `target` parameter.

This function is similar to its built-in counterpart, `root:FindFirstChild(target, true)` (or the deprecated `root:FindFirstDescendant(target)`).

Optionally, the `depth` parameter (def. 2) can be provided into this function. By default, this functionality is not used until specified with a positive integer.

Optionally, the `mode` parameter changes the behavior of the function. The following table shows the behavior used:

| mode             | "default"                           | "class"                                    | "inherit"                                   |
|------------------|-------------------------------------|--------------------------------------------|---------------------------------------------|
| Function         | `root:FindFirstChild(target, true)` | `root:FindFirstChildOfClass(target, true)` | `root:FindFirstChildWhichIsA(target, true)` |
| Built-in/Custom? | Built-in                            | Built-in                                   | Custom                                      |

By default, `mode` is set to use the `"default"` behavior.

Returns the `Instance` if found. Otherwise, returns `nil`.

### .FindFirstAncestor(root: Instance, target: string, depth: number?, mode: ("default" | "class" | "inherit")?): Instance?

Attempts to find the first `Instance` ancestor from `root` that satisfies the `target` parameter.

This function is similar to its built-in counterpart, `root:FindFirstAncestor(target)`.

Optionally, the `depth` parameter (def. 2) can be provided into this function. By default, this functionality is not used until specified with a non-zero integer.

Optionally, the `mode` parameter changes the behavior of the function. The following table shows the behavior used:

| mode             | "default"                              | "class"                                       | "inherit"                                      |
|------------------|----------------------------------------|-----------------------------------------------|------------------------------------------------|
| Function         | `root:FindFirstAncestor(target)`       | `root:FindFirstAncestorOfClass(target)`       | `root:FindFirstAncestorWhichIsA(target)`       |
| Built-in/Custom? | Built-in                               | Built-in                                      | Custom                                         |

By default, `mode` is set to use the `"default"` behavior.

Returns the `Instance` if found. Otherwise, returns `nil`.

### .IsAncestorOf(root: Instance, target: Instance, depth: number?): (boolean, Instance?)

Determines whether the `root` instance is the ancestor of the `target` instance.

This function is similar to its built-in counterpart, `root:IsAncestorOf(target)`.

Optionally, the `depth` parameter (def. 2) can be provided into this function. By default, this functionality is not used until specified with a non-negative integer. If a negative number is provided, returns `nil`.

Returns a boolean as the result of the function. If provided with `depth`, returns the `Instance` found. If failed, returns `nil`.

### .IsDescendanOf(root: Instance, target: Instance, depth: number?): (boolean, Instance?)

Determines whether the `root` instance is the descendant of the `target` instance.

This function is similar to its built-in counterpart, `root:IsDescendantOf(target)`.

Optionally, the `depth` parameter (def. 2) can be provided into this function. By default, this functionality is not used until specified with an integer.

Returns a boolean as the result of the function. If provided with `depth`, returns the `Instance` found. If failed, returns `nil`.
