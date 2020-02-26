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
    initBox{x=5,y=4,w=6,h=0.5,m=1e4,angle=math.rad(40),fill=false,static=false,name="A"}
    initBox{x=5,y=6,Vy=-0.5,angle=math.rad(45),fill=false,name="B"}
end