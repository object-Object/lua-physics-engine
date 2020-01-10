local Vector=require("vector")
require("objects")

backgroundColor=draw.white
textColor=draw.gray
defaultColor=draw.black
scale=60/1
drawScale=false
width,height=703,768
paddleMove=0

function computeForces(o)
    table.insert(o.forces,{
        f=Vector(0,0),
        r=Vector(0,0)
    })
end

table.insert(customTouchBegins,function(x,y)
    if y>width/2 then
        paddleMove=-3
    else
        paddleMove=3
    end
end)

table.insert(customEvents,function(dt)
    table.insert(objects[4].forces,{
        f=Vector(0,paddleMove/objects[4].shape.invMass),
        r=Vector(0,0),
        instant=true
    })
    if objects[5].linearVelocity:mag()<0 then
        table.insert(objects[5].forces,{
            f=objects[5].linearVelocity:normalize()/objects[5].shape.invMass,
            r=Vector(0,0),
            instant=true
        })
    end
    if objects[5].position.x<-1 then
        exitMessage="You lost!"
        exit=true
    end
end)

table.insert(customTouchEnds,function()
    paddleMove=0
end)

function initObjects()
    initBox{x=width/(2*scale)-0.5,y=height/scale-0.5,w=width/scale-1,h=1,fill=false,static=true,m=1e30,name="top"}
    initBox{x=width/scale-0.49,y=height/(2*scale),w=1,h=height/scale,fill=false,static=true,m=1e30,name="right"}
    initBox{x=width/(2*scale)-0.5,y=0.5,w=width/scale-1,h=1,fill=false,static=true,m=1e30,name="bottom"}

    initBox{k=4,x=0.5,y=height/(2*scale),w=0.5,h=2,fill=false,m=1e10,name="paddle"}
    --initCircle{k=4,x=0.5,y=height/(2*scale),r=1,fill=false,m=1e10,name="paddle"}

    initCircle{k=5,x=width/(2*scale),y=height/(2*scale),Vx=3,Vy=-1.5,r=0.125,m=1,fill=false,name="ball"}
end