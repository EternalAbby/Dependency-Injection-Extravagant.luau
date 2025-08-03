# Dependancy-Injection-Extravagant.luau
This is DIE, short for Dependancy Injection Extravagant!

This repository has many modules. These are made for utility purposes in the `Roblox Studio` game engine, but if possible, you can use this in other projects that also uses Luau!

Feel free to use any modules from here within your project!

# Instructions
Since I haven't learnt how to properly allow others to add the source code into their game, you can't expect this section to be ethical. I'm still trying to work on this as GitHub, and this whole open-source thing is still new to me.

To start, here are some of my recommendations for your project.

- If you're going to want to have some *code organizations* in your project, please create a `Folder` named `Modules` for any modules that you want to be used throughout the project.

- After that, a personal recommendation for this series, you could either create another `Folder` named `Dependancy Injection Extravagant`, or `D.I.E.`, or `DIE`, or whatever you want to call it to store the modules in this repository. Otherwise, you can simply create another `ModuleScript` for this. Modules in this repository may reference other modules within here as well, so **make sure to set their directory path correctly and provide their dependancy as well**!

- Here's the unethical part, find the source code of the module that you want to use, and paste it into your `ModuleScript`. That's all there is to it, please remember that you need to supply their dependancies as well!

# Questions!
I came up with these questions myself, so if you have anymore, you can always ask me personally! And I might add them into here in the future.

## What is this?
This is DIE.

A series of modules made for Luau. Hence, the .luau at the end of this repository.

That's all there is to it!

## Why did you make this module?
This is DIE.

Originally, this is made as *personal coding practices*. But along the journey, I've figured that creating these modules without anyone to share it with is quite pointless. From there, I've decided to give GitHub a chance!

As of writing this draft, there are still lots for me to discover, so I hope this will serve as a starting point of my journey on this site. So far, there isn't any proper code organizations for this repository, which will be my next concern.

## Why use this module?
This is DIE.

**You don't!**

As said from above, this is made as *personal coding practices*, so it's not meant as **production code**! However, don't let that discourage you from using any of these modules for your own means! Whether it is used for utility purposes within your projects, or as a code review for your very own practices! There are lots to explore, and I hope others can have a great time looking through the source code of this module!

## Where did you come up with this name? What is Dependancy Injection? That term sounds very dangerous!
This is DIE.

Because DI, short for Dependancy Injection, was very close to "die", I wanted to find another word in place for "E". What better way to do it than to make this module *Extravagant*! Well, meaning that there is unnecessary amount of modules. And to make it worse, some modules within the module also rely on each other! What a mess! But that's how DI design goes.

Speaking of which, the DI design is essentially a program using (injecting) an external program (dependancy) that is completely dependent from the main one. That's the basic gist of it. For more information, don't ask me! I only chose this term into the name, because of the reason above!

And don't worry! This is not always a bad design choice, for bigger projects, it's best to have a dependancy that already handles an operation for you without having to recreate the system again. Since this is a Luau module, let's take a familiar example with the Luau language. When getting a library, say the `table` library, you're essentially injecting another dependancy into your script! Fortunately, there are usually no side effects when using these libraries in your script as they shouldn't change their functionalities over time, those developers know what they're doing more than I do! lol

## What are the side effects of the DI design?
This is DIE.

Well, as dependancy keeps on getting updated, your program might not function as it is supposed to. This may be because the dependancy no longer supporting the original code of your program. And another problem arises when the dependancy might have crucial optimizations that your program needs for that significant performance boost.

With that in mind, developers who actively handle these dependancies know what they're doing, and usually tries not to cause huge impact on existing source code. That is to say, you can just simply keep the previous version instead of updating, but again, that performance boost from the lastest version might be very important. Take the example above, the developers behind Luau knows that significant changes will destroy existing codes, so as a promise, everything they do is always backwards compatible with their previous versions, only adding upon their existing coding style.

However, don't expect me to do the same as them. I cannot look into the future, so I can't say for certain that any of the modules will have significant changes later on in development. But I can say for certain that, if there are any changes, I will make sure to document on them!

## What do we expect in the future?
This is DIE.

As I said, I cannot look into the future.

However, you can expect the quality, and quantity of this repository over time! Please note that, as of writing this draft, I'm still trying to get into the outside world of coding here, and using GitHub as my first place for me to start!

## Is there anything else we need to consider when using this <XYZ> module?
This is DIE.

Please remember to supply the modules with their dependancies as well!
