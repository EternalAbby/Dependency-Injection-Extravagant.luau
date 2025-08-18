# Direct module

## What is this module?

`Direct` is a module made for `Roblox Studio`. It allows more control over traversing through the hierarchy of instances in the `Explorer`, and the returned instance when searching through the hierarchy of instances.

In Luau, there are objects that inherits the `Instance` class. These objects have methods, which allow users to traverse the hierarchy of instances for a specific object, which will satisfy some requirements (that is, the methods called `:FindFirst*()`, and `:Is*()`). They are quite useful when you want to validate some requirements for the instance. However, they are quite limited in how much control you have over their returned values, sometimes you want to search through depth to find what's beyond the target.

With this *open-sourced* module, all of your worries about this niche use-case is resolved! Quickly direct to your destination without any further implementation needed!

*Note: Through extensive testing, this module performs slower than built-in functions (In most test cases, it is slower by more than 3 times, or worse. Although the differences are only in single-digit microseconds). If a function is used similar to its built-in function counterpart, this module will use that function instead, or terminates early for the desired result. It is recommended not to use module to replace built-ins, especially when used constantly, only use this module when its features are necessary for your use-cases, or calls are cached properly so that further calls are not mindlessly performed.*

## Author's note

Thank you for using Direct module!

This was originally made as a coding practice for string parsing, data structures, and algorithms.

~ Direct module made by Abby (@EternalAbby)

## Pre-requisite

- TypeCheck v0.3.0
