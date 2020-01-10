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
* Non-penetration constraints (i.e. collisions)
* Static objects
* A few debug tools/readouts
* Many useful vector functions in the vector library

## WIP features
Here's what I want to implement, but haven't yet.
* More constraints (e.g. chains)
* More object types

## Known bugs
* Box-box interaction sometimes ends in boxes being thrown at very high speeds
* Small amounts of energy are being added in each collison because it doesn't do continuous detection

## Dependencies
These are the libraries I use for this project.
* Vector library from [this Code Review Stack Exchange page](https://codereview.stackexchange.com/a/107237), heavily modified
* [Typical](https://github.com/hoelzro/lua-typical)
* Draw Library in [Touch Lua +](https://apps.apple.com/us/app/touch-lua/id692368612) (paid)
