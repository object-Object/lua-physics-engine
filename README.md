# lua-physics-engine
Rigid body physics engine written in Lua. Very work-in-progress.

## Implemented features
As of right now, here's what I've implemented.
* Graphics, using the iPad app Touch Lua +
* Rigid-body dynamics (including linear and angular velocity, torque, etc.)
* Circles and boxes
* Quite a few different simulation files
* Collision detection using GJK
* Finding the minimum translation vector using EPA
* Visualization of the polytope that EPA generates

## WIP features
Here's what I want to implement, but haven't yet.
* Constraints - mainly non-penetration (i.e. collisions)
* More object types

## Known bugs
* When a simulation is started with two circles just touching, there is a crash related to GJK returning an invalid simplex. I don't know why.

## Dependencies
These are the libraries I use for this project.
* Vector library from [this Code Review Stack Exchange page](https://codereview.stackexchange.com/a/107237), heavily modified
* [Typical](https://github.com/hoelzro/lua-typical)
* Draw Library in [Touch Lua +](https://apps.apple.com/us/app/touch-lua/id692368612) (paid)
