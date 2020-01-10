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
    --initCircle{x=5,y=6,r=1,fill=false,m=1,name="A"}
    --initCircle{x=8,y=6,r=1,Vx=-1,m=1,fill=false,name="B"}
    initBox{x=5,y=2,w=2,h=4,m=15,fill=false,name="C1"}
    --initCircle{x=5,y=2,r=1,m=5,fill=false,name="C2"}
    --initBox{x=7.5,y=3.7,Vx=-1,w=1,h=1,m=3,angle=math.pi/4,fill=false,name="D1"}
    initCircle{x=7.5,y=3.7,r=0.5,Vx=-1,m=3,fill=false,name="D2"}
    --initPolygon{x=7,y=2,sides=3,r=0.5,Vx=-0.1,m=1,angle=math.pi/2,fill=false,name="D3"}
    --initCircle{x=4.5,y=2,r=1,Vx=-0.1,fill=false,name="B"}
    --initBox{x=6,y=5,w=12,h=1,m=5e24,static=true,fill=false,name="Ground"}
    --initBox{x=8,y=2,Vx=-0.1,w=1,h=1,m=1,fill=false,name="E"}
    --initBox{x=7,y=2,w=1,h=1,m=1,fill=false,name="F"}
end