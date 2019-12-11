local Vector=require("vector")
require("objects")

local distance=2e11 --m
local screenPixels=703
local screenSize=2*distance+2*6e7

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
    initCircle{x=-distance/2, y=0, m=3e30, r=1.1e9, Vy=-22439.95, hideVectors=true, name="Binary Alpha"}
    initCircle{x=distance/2, y=0, m=3e30, r=1.1e9, Vy=22439.95, hideVectors=true, name="Binary Beta"}
end