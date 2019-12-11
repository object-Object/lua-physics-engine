local Vector=require("vector")
require("objects")

backgroundColor=draw.white
textColor=draw.gray
defaultColor=draw.black
scale=80/1
drawScale=true

function computeForces(o)
    for _,o2 in pairs(objects) do
        if o2~=o and not (o.static and o2.static) then
            local unitVector=Vector(o2.position.x-o.position.x,o2.position.y-o.position.y)
            local r=unitVector:mag()
            unitVector=unitVector/r
            Fe=unitVector*(-(k*o2.shape.charge*o.shape.charge)/(r^2))
            table.insert(o.forces,{
                f=Fe,
                r=Vector(0,0)
            })
        end
    end
end

function initObjects()
    initBox{x=1, y=1, w=1, h=1, q=2e-3, m=10000, static=true}
    initBox{x=7, y=1, w=1, h=1, q=2e-3, m=10000, static=true}
    initCircle{x=4, y=6, r=0.05, q=1e-5, m=0.1}
end