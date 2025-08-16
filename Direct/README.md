# Direct module

## What is this module?

`Direct` is a module made for `Roblox Studio`. It allows more control over traversing through the hierarchy of instances in the `Explorer`, and the returned instance when searching through the hierarchy of instances.

In Luau, there are objects that inherits the `Instance` class. These objects have methods, which allow users to traverse the hierarchy of instances for a specific object, which will satisfy some requirements (that is, the methods called `:FindFirst*()`, and `:Is*()`). They are quite useful when you want to validate some requirements for the instance. However, they are quite limited in how much control you have over their returned values, sometimes you want to search through depth to find what's beyond the target.

With this *open-sourced* module, you will be quickly directed to your destination without any other implementation needed at all!

## Author's note

Thank you for using Direct module!

This was originally made as a coding practice for string parsing, and data structure.

~ Direct module made by Abby (@EternalAbby)

## Pre-requisite

- TypeCheck v0.3.0
