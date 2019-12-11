local Vector=require("vector")
require("objects")

backgroundColor=draw.black
textColor=draw.lightgray
defaultColor=draw.white
scale=3/1
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
    initCircle{x=0, y=0, m=9.981e13, r=2064, color=draw.gray, name="B612"}

    initBox{x=0, y=2064+10, Vx=0, Vy=-1, w=5, h=2, name="Spaceship", fill=false, focus=true, other={controlled=true}}
end