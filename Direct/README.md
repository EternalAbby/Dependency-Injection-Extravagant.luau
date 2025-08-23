# Direct module

## What is this module?

`Direct` is a module, made specifically for `Roblox Studio`. It extends the functionalities of some specific methods in the `Instance` class to allow more control over how you can traverse through the hierarchy of the objects in the `Explorer`.

In the `Roblox Studio` game engine, many objects inherit the `Instance` class. That means, these objects inherit methods that allows the user to traverse through the hierarchy of the objects, only stopping after satisfying a specific requirement, then terminates. In other words, methods that are called `:FindFirst.*()`, and `:Is.*()` (`.*` is the regex wildcard expression).

Although they are very useful for validation of the instance, they are quite limited in how much control you have over their returned values. There may be times when you might want to search through beyond the depth of the target.

From that motivation, this *open-sourced* module was created. With this module, you are able to perform this niche use case without any trouble! All of your worries have been resolved, all thanks to this module. Easily direct to your target destination without any further implementation needed!

*Note: Please read the `Note` section in the `_DOCUMENTATION` file for more details on the performance of this module.*

## Author's note

Thank you for using Direct module!

This was originally made as a coding practice for string parsing, data structures, and algorithms.

~ Direct module made by Abby (@EternalAbby)

## Prerequisite

- TypeCheck v0.3.0
