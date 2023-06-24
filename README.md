# An Open World Testbed In Godot

## Things you will need

Godot 4.x is required.

## Notes

Because the files are big and I'd run out of LFS quota pretty much immediately, the heightmaps are
not included. You will get error messages the first time you open the project, complaining that the
terain .exr files are missing.

You can (or, should be able to) use the `terrain_generator` scene to produce them locally, and then
close and reopen the project. This only needs to be done once.

In my experience, Godot can sometimes hang when importing the new images. Killing it and starting
Godot again fixes this for me.
