local Vector=require("vector")
require("objects")

local outerOrbit=5.835e8 --m
local screenPixels=703
local screenSize=2*outerOrbit+2*7e7

scale=1/(screenSize/screenPixels) --pixels/metre
drawScale=false

function computeForces(o)
    for _,o2 in pairs(objects) do
        if o2~=o then
            local unitVector=Vector(o2.position.x-o.position.x,o2.position.y-o.position.y)
            local r=unitVector:mag()
            unitVector=unitVector/r
            Fg=unitVector*((G*o2.shape.mass*o.shape.mass)/(r^2))
            table.insert(o.forces,{
                f=Fg,
                r=Vector(0,0)
            })
        end
    end
end

function initObjects()
    initCircle{x=0, y=0, m=8.8e25, r=2.56e7, Vx=0, Vy=0, hideVectors=true, color=draw.cyan, name="Uranus"}
    initCircle{x=0, y=4.363e8, m=3.52e21, r=7.889e5, Vx=3667.85, Vy=0, hideVectors=true, color={0.7,0.7,0.7,1}, name="Titania"}
    initCircle{x=5.835e8, y=0, m=3.01e21, r=7.614e5, Vx=0, Vy=-3171.64, hideVectors=true, color={0.6,0.6,0.6,1}, name="Oberon"}
    initCircle{x=0, y=-1.909e8, m=1.35e21, r=5.789e5, Vx=-5545, Vy=0, hideVectors=true, color={0.5,0.5,0.5,1}, name="Ariel"}
    initCircle{x=-2.66e8, y=0, m=1.17e21, r=5.847e5, Vx=0, Vy=4697.46, hideVectors=true, color={0.4,0.4,0.4,1}, name="Umbriel"}
    initCircle{x=0, y=1.299e8, m=6.6e19, r=2.357e5, Vx=6722.02, Vy=0, hideVectors=true, color={0.3,0.3,0.3,1}, name="Miranda"}
end