# lua-physics-engine
Rigid body physics engine written in Lua. Very work-in-progress.

## Implemented features (so far)
* Graphics, using the iPad app Touch Lua +
* Rigid-body dynamics (including linear and angular velocity, torque, etc.)
* Circles and boxes
* Quite a few different simulation files
* Collision detection using GJK
* Finding the minimum translation vector using EPA
* Non-penetration constraints (i.e. collisions)
* Static objects
* A few debug tools/readouts
* Many useful vector functions in the vector library

## Soon(tm) features
* More constraints (e.g. chains)
* More object types

## Known bugs
* Box-box interaction sometimes results in boxes being thrown at very high speeds (see sims/collision4 for an example)
* Small amounts of energy are being added in each collison because it doesn't do continuous detection
* Stacking boxes doesn't work

## Dependencies
These are all included in the files except for the Draw Library.
* Vector library from [this Code Review Stack Exchange page](https://codereview.stackexchange.com/a/107237), heavily modified
* [Typical](https://github.com/hoelzro/lua-typical)
* Draw Library in [Touch Lua +](https://apps.apple.com/us/app/touch-lua/id692368612) (paid)
