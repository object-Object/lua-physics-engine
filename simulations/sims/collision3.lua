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
    initCircle{x=2,y=2,r=0.5,Vx=5,Vy=0,m=1.5,fill=false,name="1"}
    initCircle{x=8,y=2,r=0.5,Vx=-2,Vy=0,m=2,fill=false,name="2"}
end