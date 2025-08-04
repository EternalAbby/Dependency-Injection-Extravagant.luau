# Dependency-Injection-Extravagant.luau
This is DIE, short for Dependency Injection Extravagant!

This repository has many modules made for utility purposes in the `Roblox Studio` game engine. This doesn't mean that it isn't possible to use this in other projects with Luau!

Feel free to use any modules from here within your project!

# Instructions
*Updated for v1.1.0 of DIE*

Here's how you can download a module from this repository;
- Head over to `Releases`, and find the .rbxm for the module that you would like to use.
- Download the .rbxm file onto your computer.
- After downloading, go into your `Roblox Studio` place, and paste in the .rbxm file.
- Enjoy!

Make sure that you also do the following;
- Read the `README` file for more details about the module!
- Read the `_DOCUMENTATION` file for more information on how to use the module!
- Check the `_VERSION` file to make sure that you got the latest release of the module!

**Recommendations**
- If you don't know how to organize these modules in your game, I recommend putting every module from `DIE` under the same hierachy in the directory tree. This is because, by default, they are referenced as if they are under the same hierachy in the source code. Of course, you can also simply change the directory path in the source code itself for your own project.
- If you don't know where to start with a module, I recommend starting by reading through the `_DOCUMENTATION` file. This file gives an in-depth description of each function in a module, and should contain the most up-to-date information about a module.
- If you don't know what pre-requisite modules are missing, you can use the `Pre-requisite dependencies` list in the `README` file included with the module.

**Troubleshooting**
- If you think that you have the pre-requisite modules, but it thinks otherwise (that is, it is throwing an error), make sure that the directory path is valid. You can check this by going through the source code of the module. Reminder that these dependencies are referenced as if they are under the same hierachy in the source code.

# Questions!
This section is for questions (that I mostly came up myself), including some facts about this repository. If you have any other questions, you are free to ask me personally! If your question is frequent enough, I might add them here in the future.

## What is this?
This is DIE.

This repository is made to contain a series of modules made for the scripting language called [Luau](https://luau.org/). Hence, the .luau "file extension" of this repository.

That's all there is to it!

## Why did you make this repository?
This is DIE.

Originally, this series was made for *personal coding practices*, and I never had any plans of open-sourcing these. But after some thought, I've figured that creating these modules without anyone to share it with is quite pointless. And since I need to gain some experiences with open-source projects anyway, I've decided on using GitHub, and give it a chance!

## Why use this module?
This is DIE.

**You don't!**

As said from above, this series was made for *personal coding practices*, so it was never meant to be for **production** code!

However, don't let that discourage you from using any of them for yourself! You can always use these for whatever purposes you want! Whether it is utility, code review, or whatever it is you want! I hope others can have a great time looking through this repository!

## Where did you come up with this name? What is Dependency Injection? That term sounds very dangerous!
This is DIE.

Simply put, this repository is following the DI design, or Dependency Injection. Since DI was very close to "die", and I thought it was quite funny, so I decided to make this series *Extravagant*! That means there is an unnecessary amount of modules here, and to make it worse, some modules here also rely on each other!

What a total mess! But that's how this DI design goes.

Speaking of which, the DI design is essentially a program using (injecting) an external program (dependency) that is completely dependent from the main one. That's the basic gist of it. For more information, refer to the [Wikipedia](https://en.wikipedia.org/wiki/Dependency_injection) page. Please don't ask me! I only chose this term as part of the name, because of the reason above!

Although the name sounds very intimidating, it is not always a bad design choice, especially for bigger projects where no one would want to create these systems themselves. You might see this happening in Luau as well! Take for example, when you get a library, you're essentially injecting a dependency into your script! But don't worry, usually these dependencies had lots of thoughts put into them to make sure that they don't break for every releases.

## When does this DI design fail?
This is DIE.

Dependencies update over time, and in turn, it might stop supporting its backward-compatibility functionalities for your program. Sometimes, this is okay, because you can simply keep the old versions, and not update to the newer version. But other times, you might be missing out on huge improvements in later versions of the dependencies.

With that in mind, maintainers for these dependencies usually know what they're doing, and tries to minimize the impact from changes onto existing code.

## What do we expect in the future?
This is DIE.

I cannot look into the future. Quite sad.

You can expect the quality (and quantity) of this repository to increase over time!

However, don't expect that there won't be any significant changes made to any of the modules. If there are any, I will make sure to document them in the release note!

## Is there anything else to consider when using this XYZ module?
no.

As long as you follow the instructions, you shouldn't have any trouble setting up the module.
