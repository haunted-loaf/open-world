# An Open World Testbed In Godot

## Things you will need

Godot 4.x is required.

You can use a version compiled with double precision, but there is a bug with the water renderer.

The terrain collider currently depends on support for floating-point viewport textures, or else the
collider will be _very_ inaccurate.

I plan to implement a compute-shader-based method for getting data for the collider, so this problem
will go away in a while, but in the mean time you will enjoy the best results with my custom Godot
branch I maintain at https://github.com/haunted-loaf/godot/

Other than that nonsense, things should Just Work™.
