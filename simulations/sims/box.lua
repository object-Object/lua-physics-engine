local Vector=require("vector")
require("objects")

backgroundColor=draw.white
textColor=draw.gray
defaultColor=draw.black
scale=60/1
drawScale=true

function computeForces(o)
    table.insert(o.forces,{
        f=Vector(0,30),
        r=Vector(2,0)
    })
end

function initObjects()
    initBox{x=3,y=3,w=4,h=1, angle=math.rad(30)}
end