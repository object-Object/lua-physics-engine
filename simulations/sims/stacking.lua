local Vector=require("vector")
require("objects")

backgroundColor=draw.white
textColor=draw.gray
defaultColor=draw.black
scale=60/1
drawScale=true

function computeForces(o)
    table.insert(o.forces,{
        f=g*o.shape.mass,
        r=Vector(0,0)
    })
end

function initObjects()
    initBox{x=4,y=3,w=8,h=1,fill=false,static=true,name="platform"}
    --initBox{x=2,y=4.5,fill=false,name="box1"}
    initCircle{x=5,y=8,r=0.5,fill=false,name="circle1"}
end