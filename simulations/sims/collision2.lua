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
    initBox{x=2,y=2,w=1,h=2,fill=false,name="A"}
    initBox{x=3,y=2,w=1,h=1,Vx=-0.1,angle=math.pi/4,fill=false,name="B"}
    --initCircle{x=4.5,y=2,r=1,Vx=-0.1,fill=false,name="B"}
end