# Dependency-Injection-Extravagant.luau

This is DIE, short for Dependency Injection Extravagant!

This repository has many modules made for utility purposes in the [Roblox Studio](https://create.roblox.com/docs/studio/setup) game engine. This doesn't mean that it isn't possible to use this in other projects with Luau!

*This repository made with the intent of,*
> "Create it yourself or DIE"

*along with being simple to use.*

Disclaimer: Every module within this repository was never made with the intent of being efficient, nor performant for production code.

**Feel free to use any modules from here within your project!**

## Instructions

\**Last updated for DIE v1.1.0*

Here's how you can download a module from this repository;

- Head over to `Releases`, and find the `.rbxm` file for the module that you would like to use.
- Download the `.rbxm` file onto your computer.
- After downloading the `.rbxm` file, go into your game place in *Roblox Studio*. Copy and paste the file into the `Explorer`.
- Enjoy!

*Alternatively, you can download the `DependencyInjectionExtravagant.vMAJOR.MINOR.PATCH` file. This `.rbxm` file includes the latest releases of every modules, allowing you to only download **1** file instead of multiple.*

Make sure that you also do the following;

- Read the `README` file for more details about the module!
- Read the `_DOCUMENTATION` file for more information on how to use the module!
- Check the `_VERSION` file to make sure that you got the latest release of the module!

### Recommendations

- It is recommended that you read `README`, and `_DOCUMENTATION` files on GitHub as they are written in `.md` file format. These files are also included in the download, but are in `Markdown` format.
- If you don't know how to organize these modules, it is recommended that you put every module in this repository under the same hierachy in the directory tree, because dependencies from these modules are referenced under the same hierachy in the source code.
- If you don't know where to start with a module, it is recommended that you start by reading through the `_DOCUMENTATION` file. This file gives an in-depth description for everything in a module, and should be the most up-to-date.
- If you don't know what pre-requisite modules are missing, it is recommended that you use the `Pre-requisite dependencies` list in the `README` file.

### Troubleshooting

- If you have the required pre-requisite modules, but it couldn't find such module, make sure that the directory path is valid within the source code of the module. Reminder that these dependencies are referenced under the same hierachy.
- If you have the required pre-requisite modules, but it throws an error when the dependency is used, make sure that you have the correct version of them.

## Questions!

This section is for questions (that I mostly came up myself), including some facts about this repository. If you have any other questions, you are free to ask me personally! If your question is frequent enough, I might add them here in the future!

### What is this?

This repository is made to contain a series of modules made for the scripting language called [Luau](https://luau.org/). Hence, the .luau "file extension" of this repository name.

That's all there is to it!

### Why did you make this repository?

Originally, this series was made for *personal coding practices*, and I never had any intention of making them open-sourced. They were made to be simple utility modules that I might use in `Roblox Studio` projects.

Over time, I've figured that creating these modules without anyone to share with or use in an actual project is quite pointless. They would be left to rot on my computer. How unfortunate!

Since I needed to gain some experiences in dealing with open-source projects in the future, I've decided on releasing them here on GitHub! I only hope that someone will find this repository useful to them someday.

## Why use this?

**You don't!**

As said from above, this series was made for *personal coding practices*, so it was never meant to be for **production** code!

However, don't let that discourage you from using them in your project! You can always use them for whatever purposes you want! Whether it is for utility in your game, code review to read through others code, or whatever it is.

## Where did you come up with this name? What is Dependency Injection? That term sounds very dangerous!

Simply put, this repository is following the DI design, or Dependency Injection. Since DI was very close to "die", and I thought it was quite funny, so I decided to make this series *Extravagant*! That means there is an unnecessary amount of modules here, and to make it worse, some modules here also rely on each other!

What a total mess! But that's how this DI design goes.

Speaking of which, the DI design is essentially a program using (injecting) an external program (dependency) that is completely dependent from the main one. That's the basic gist of it.

For more information, refer to the [Wikipedia](https://en.wikipedia.org/wiki/Dependency_injection) page. Please don't ask me! I only chose this term as part of the name, because of the reason above!

Although the name sounds very intimidating, it is not always a bad design choice, especially for bigger projects where no one would want to create these systems themselves. You might see this happening in Luau as well! Take for example, when you get a library, you're essentially injecting a dependency into your script! But don't worry, usually these dependencies had lots of thoughts put into them to make sure that they don't break for every releases.

## When does this DI design fail?

Dependencies update over time, and in turn, it might stop supporting its backward-compatibility functionalities for your program. Sometimes, this is okay, because you can simply keep the old versions, and not update to the newer version. But other times, you might be missing out on huge improvements in later versions of the dependencies.

With that in mind, maintainers for these dependencies usually know what they're doing, and tries to minimize the impact from changes onto existing code.

## What is the meaning of `vMAJOR.MINOR.PATCH` for everything here?

This repository uses [Sementic Versioning](https://semver.org/), a set of rules made for a versioning technique.

Reasons behind this choice can also be found on the same [page](https://semver.org/#why-use-semantic-versioning).

## What do we expect in the future?

I cannot look into the future. Quite sad.

You can expect the quality (and quantity) of this repository to increase over time!

However, don't expect that there won't be any significant changes made to any of the modules. If there are any, I will make sure to document them in the release note!

## Is there anything else to consider when using this XYZ module?

*no.*

As long as you follow the instructions, you shouldn't have any trouble setting up the module.
