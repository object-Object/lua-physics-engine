local Vector=require("vector")

function table.clone(org)
    return {table.unpack(org)}
end

function table.multiInsert(t,...)
    for k,v in pairs({...}) do
        table.insert(t,v)
    end
end

function math.sign(x)
    if x==math.abs(x) then
        return 1
    else
        return -1
    end
end

function math.osign(x)
    if x==math.abs(x) then
        return -1
    else
        return 1
    end
end

function draw.arrow(x1,y1,x2,y2,headRadius,angle,color)
    draw.line(x1,y1,x2,y2,color)
    draw.fillpolygon(x2,y2,headRadius,3,angle,color)
end

function s(n)
    return n==1 and "" or "s"
end

function math.round(n,places)
    places=places and 10^places or 100
    return math.floor(n*places+0.5)/places
end

function rotatePoint(x,y,angle)
    angle=-angle
    local newX = x*math.cos(angle) - y*math.sin(angle)
    local newY = x*math.sin(angle) + y*math.cos(angle)
    return Vector(newX,newY)
end