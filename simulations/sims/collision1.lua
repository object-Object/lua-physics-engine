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
    initCircle{x=2,y=2,r=1,fill=false,name="A"}
    --initBox{x=2,y=2,w=2,h=1,angle=math.pi/4,fill=false,name="A"}
    initBox{x=3.7,y=2,w=2,h=1,angle=-5*math.pi/12,Vrot=0.5,fill=false,name="B"}
    --initBox{x=8,y=2,w=1,h=2,fill=false,name="C"}
    --initCircle{x=9,y=5,r=0.75,Vy=-0.5,fill=false,name="D"}
    --initBox{x=5.85,y=5,w=2,h=2,Vx=-0.5,Vy=-0.5,Vrot=0.75,fill=false,name="E"}
end