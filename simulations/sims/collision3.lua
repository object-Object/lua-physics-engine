local Vector=require("vector")
require("objects")

backgroundColor=draw.white
textColor=draw.gray
defaultColor=draw.black
scale=60/1
drawScale=true

function computeForces(o)
    table.insert(o.forces,{
        f=Vector(0,0),
        r=Vector(0,0)
    })
end

function initObjects()
    initCircle{x=2,y=1.5,r=0.5,Vx=3,Vy=4,m=1,fill=false,name="A"}
    initCircle{x=8,y=2,r=0.5,Vx=-3,Vy=4,m=1,fill=false,name="B"}
end