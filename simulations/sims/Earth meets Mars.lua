local Vector=require("vector")
require("objects")

local moonOrbit=3.84e8 --m
local screenPixels=703
local screenSize=2*moonOrbit+2*6e7

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
    initCircle{x=0, y=0, m=5.98e24, r=6.38e6, hideVectors=true, color=draw.darkgreen, name="Earth"}
    initCircle{x=0, y=moonOrbit, m=7.35e22, r=1.74e6, Vx=math.sqrt((G*5.98e24)/moonOrbit), hideVectors=true, name="Moon"}
    initCircle{x=moonOrbit+1e7, y=moonOrbit+1e7, m=6.37e23, r=3.4e6, Vx=-1500, Vy=-1200, hideVectors=true, color=draw.red, name="Mars"}
end