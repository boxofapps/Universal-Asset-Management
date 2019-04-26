# Universal Asset Manager 
An extensible asset manager that is fully controllable through simple commands that you can integrate in your own pipeline.

You can add as many asset definitions as required with the help of the modular structure.

Currently only supports 3ds max.

## What is this trying to solve?

Typically asset managers include the most common asset types for most 3d artists: Models, Materials, Textures, IES, HDRs. They rely on graphic user interfaces to help you manage different asset types. Because they rely on graphic user interfaces they are usually not extensible.

By fully separating the asset management logic from graphic user interface logic, it becomes much simpler to make an asset manager extensible. With just a few lines of code you can integrate any specific asset type that might be important to your business.

Each new asset type is discoverable from your file system and retrievable through the use of simple commands.

I have included an asset type example that let you extract color assets from a .csv table. Each color asset can then output proper linear rgb values taking in consideration the LRV(Light reflectance value) supplied by the manufacturer.

## How it works?

Basic system structure:
* Scanning File System to find assets
* Config files on folders to guide the scanning process
* Config files to describe what files to look for and how they should be processed
* Adapters (or importers) that identify asset source files and output asset objects in 3ds max
* Shared libraries of functions to be used by adapters (that includes my initial work on extracting all the useful functions from HCGAB for public use)
* API for querying assets found by the system. Example: "boa.uam.get("AssetType:Color,ColorName:\*White\*")" will return all color assets that have "white" in the name.
* Per Asset Type objects in 3ds max, so you can perform quick operations with simple commands. Example: "(boa.uam.get("AssetType:Model))[1].merge()" will merge the first model it can find to the scene.

## Current Asset Types
* Models
* RGB LFV CSV Color Table (Example of unusual asset type)

In development:
* Materials (based on material libraries)
* Texture (single textures)
* Texture Set (find normal, glossines and other maps that are associated based on typical name conventions and functions that create basic materials plugging all the maps)
* Timber Floor (asset type that combine textures, materials, geometry modifiers like "Floor Generator", and other relevant properties)
* More Model Functions (Merge as proxy, convert to proxy, convert back from proxy)

## Early Development Considerations (not production ready)
This tool is not production ready at this stage. I only recommend using it for initial experimentation or if you are planning to contribute to this project.

Also at the current state there is no caching feature. If you scan a very big asset library it might freeze your 3ds max for a long time while it goes through all the folders and files.

Config files, syntax, overall structure, adapters, installation setup, might completely change with each new update.

## Installation Process

[Installation and how to use](https://github.com/boxofapps/Universal-Asset-Manager/wiki/Installation-and-how-to-use)

## History
I started my journey with asset managers 10+ years ago with the development of HCG Asset Browser (http://www.scriptspot.com/3ds-max/scripts/hcg-asset-browser-pro)

Video of hcgab: https://www.youtube.com/watch?v=wY4Entr3UXY

My goal was to reduce the amount of repetitive steps 3d artists had to go through to simply merge a model while also making it easy to see what was being merged.

Since then many great asset browsers have been released following that central idea (Project Manager, Connecter). They have introduced many new features and great UIs. But some of these important new features introduced a whole new level of repetitive steps to keep the library consistent.

With connecter for example, if I want to use Tags to categorize models, I have to make sure all models are consistently tagged. If I have too much inconsistency, 3d artists will lose confidence and naturally gravitate back to navigating through folders, as they know that is the place they can find all assets. Also some folders are already working as a "Tag", the problem is that if you add one new model to that folder, you still have to remember add a tag "Chair" to it. This is one of many small problems that as you keep adding to other similar problems makes the whole process too slow to progress.

There is an overlap of what is universal in how most people use assets. Current asset browsers do their best to capture most common feature needs through their UIs. The problem is that if you have a special case that requires a new sort of asset type, then you have to start from scratch, which is not viable for most people.

This tool is universal in the sense that you have a structure that will work as a starting point that help you add, remove or replace any features relevant to your particular workflow. You can add "unlimited" asset definitions to create your own asset management solution.
