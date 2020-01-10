local Vector=require("vector")
require("objects")

local moonOrbit=3.84e8 --m
local screenPixels=703
local screenSize=2*moonOrbit+2*5e7

backgroundColor=draw.black
defaultColor=draw.white
scale=1/1
drawScale=false
drawVectors=false

function initNoFocusOffset()
    return Vector(width/2,height/2)
end

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
    initCircle{x=0, y=0, m=5.98e24, r=6.38e6, color=draw.darkgreen, name="Earth"}
    initCircle{x=0, y=moonOrbit, m=7.35e22, r=1.74e6, Vx=math.sqrt((G*5.98e24)/moonOrbit), color=draw.lightgray, name="Moon"}

    initBox{x=0, y=6.38e6+300, Vx=7845.597, w=5, h=2, name="Spaceship", focus=true, fill=false, other={controlled=true}}
end