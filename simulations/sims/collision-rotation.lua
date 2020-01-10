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
    initBox{x=3.95,y=7,w=2,h=1,m=1,Vy=-2,fill=false,name="A"}
    initCircle{x=5,y=4,r=0.1,m=100,fill=false,static=true,name="B"}
end