local Vector=require("vector")
require("objects")

backgroundColor=draw.white
textColor=draw.gray
defaultColor=draw.black
scale=40/1
drawScale=true

function computeForces(o)
    table.insert(o.forces,{
        f=Vector(0,0),
        r=Vector(0,0)
    })
end

function initObjects()
    initBox{x=10,y=10,w=10,h=4,Vx=0,fill=false,focus=true,name="ship"}
end

table.insert(customInits,function()
    for k,o in ipairs(objects) do
        o.shape.realWidth=o.shape.width
        o.shape.realHeight=o.shape.height
        o.shape.realMass=o.shape.mass
    end
end)

table.insert(customEvents,function()
    for k,o in ipairs(objects) do
        o.shape.width=o.shape.realWidth*math.sqrt(1-(o.linearVelocity.x^2)/(c^2))
        o.shape.mass=o.shape.realMass/math.sqrt(1-(o.linearVelocity.x^2)/(c^2))
    end
end)

table.insert(customTouchBegins,function(x,y)
    if fixY(y)>100 then
        if y>width/2 then
            speedMove=-8e4
        else
            speedMove=8e4
        end
    end
end)

table.insert(customEvents,function(dt)
    objects[1].linearVelocity.x=objects[1].linearVelocity.x+speedMove
    if objects[1].linearVelocity.x>c-1 then objects[1].linearVelocity.x=c-1 end
    if objects[1].linearVelocity.x<-c+1 then objects[1].linearVelocity.x=-c+1 end
end)

table.insert(customTouchEnds,function()
    speedMove=0
end)