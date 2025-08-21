# Direct module

## What is this module?

`Direct` is a module, made specifically for `Roblox Studio`. It extends the functionalities of some specific methods in the `Instance` class to allow more control over how you can traverse through the hierarchy of the objects in the `Explorer`.

In Luau, many objects inherit the `Instance` class. These objects have inherit methods, which when used, will traverse through the hierarchy of the objects, only stopping after satisfying a specific requirement. In other words, methods called `:FindFirst.*()`, and `:Is.*()` (`.*` is regex wildcard expression). They are very useful when validation is needed for the instance. However, they are particularly limited in how much control you have over their returned values, sometimes you might want to search through more into the depth of the objects to find what's beyond the target.

With this motivation, this *open-sourced* module was created. Using this module, all of your worries about this niche use case has been resolved! Quickly direct to your target destination without any further implementation needed!

*Note: Please read the `Note` section in `_DOCUMENTATION` for more details on the performance of this module.*

## Author's note

Thank you for using Direct module!

This was originally made as a coding practice for string parsing, data structures, and algorithms.

~ Direct module made by Abby (@EternalAbby)

## Pre-requisite

- TypeCheck v0.3.0
