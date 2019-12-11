local Vector=require("vector")
require("utils")

local EPATolerance=0.0001

-- support functions --

function furthestVertex(vertices,dir)
    local highest=-math.huge
    local support=Vector(0,0)
    for _,v in pairs(vertices) do
        local dot=v*dir
        if dot>highest then
            highest=dot
            support=v
        end
    end
    return support
end

supports={}

supports.box=function(o,dir)
    local w, h, angle = o.shape.width/2, o.shape.height/2, o.angle
    local vertices={
        rotatePoint(-w,h,angle)+o.position,
        rotatePoint(w,h,angle)+o.position,
        rotatePoint(-w,-h,angle)+o.position,
        rotatePoint(w,-h,angle)+o.position
    }
    return furthestVertex(vertices,dir)
end

supports.circle=function(o,dir)
    return o.position+dir:normalize()*o.shape.radius
end

-- broad --

local intersectBroadList

local function insertionSort(array)
    local len = #array
    local j
    for j = 2, len do
        local key = array[j]
        local i = j - 1
        while i > 0 and array[i].val > key.val do
            array[i + 1] = array[i]
            i = i - 1
        end
        array[i + 1] = key
    end
    return array
end

local function getAABB(o)
    local xMin,xMax,yMin,yMax
    if o.shape.type=="box" then
        local w,h,angle = o.shape.width/2, o.shape.height/2, o.angle
        local p1=rotatePoint(-w,h,angle)
        local p2=rotatePoint(w,h,angle)
        local p3=rotatePoint(-w,-h,angle)
        local p4=rotatePoint(w,-h,angle)
        xMin=math.min(p1.x,p2.x,p3.x,p4.x)+o.position.x
        xMax=math.max(p1.x,p2.x,p3.x,p4.x)+o.position.x
        yMin=math.min(p1.y,p2.y,p3.y,p4.y)+o.position.y
        yMax=math.max(p1.y,p2.y,p3.y,p4.y)+o.position.y
    elseif o.shape.type=="circle" then
        local r=o.shape.radius
        xMin=o.position.x-r
        xMax=o.position.x+r
        yMin=o.position.y-r
        yMax=o.position.y+r
    end
    return {min=Vector(xMin,yMin), max=Vector(xMax,yMax)}
end

local function testAABBOverlap(a,b) -- axis-aligned bounding box
    local d1x = b.min.x - a.max.x
    local d1y = b.min.y - a.max.y
    local d2x = a.min.x - b.max.x
    local d2y = a.min.y - b.max.y

    if d1x > 0 or d1y > 0 or d2x > 0 or d2y > 0 then
        return false
    end

    return true
end

local function testIntersectBroad()
    local active={}
    local possible={}
    local output={}

    if not intersectBroadList then
        -- construct list first time
        intersectBroadList={}
        for key, object in pairs(objects) do
            local aabb=getAABB(object)
            table.insert(intersectBroadList,{val=aabb.min.x, type="min", parent=key})
            table.insert(intersectBroadList,{val=aabb.max.x, type="max", parent=key})
        end
        table.sort(intersectBroadList, function(a,b) return a.val<b.val end)

    else
        -- rebuild list with new values subsequent times
        for k,entry in ipairs(intersectBroadList) do
            if objects[entry.parent] then
                local aabb=getAABB(objects[entry.parent])
                entry.val=aabb[entry.type].x
            else
                table.remove(intersectBroadList,k)
            end
        end
        insertionSort(intersectBroadList)
    end

    -- find intersections in the x axis
    for k,entry in ipairs(intersectBroadList) do
        if entry.type=="min" then
            possible[entry.parent]=table.clone(active)
            table.insert(active,entry.parent)
        elseif entry.type=="max" then
            for k,v in pairs(active) do
                if v==entry.parent then
                    table.remove(active,k)
                    break
                end
            end
        end
    end

    -- find actual intersections
    for obj1,list in pairs(possible) do
        for _,obj2 in pairs(list) do
            if not (output[{obj1,obj2}] or output[{obj2,obj1}]) then
                local a=getAABB(objects[obj1])
                local b=getAABB(objects[obj2])
                if testAABBOverlap(a,b) then
                    output[{obj1,obj2}]=true
                end
            end
        end
    end
    return output
end

-- narrow --

--- GJK ---

local function support(objectA,objectB,dir)
    local sA=supports[objectA.shape.type](objectA,dir)
    local sB=supports[objectB.shape.type](objectB,dir*-1)
    return sA-sB
end

local function sameDir(a,b)
    return a*b>0
end

local function doSimplex(list,dir)
    if #list==2 then
        local AB=list[1]-list[2]
        local AO=list[2]*-1
        if sameDir(AB,AO) then
            local z=AB.x*AO.y-AB.y*AO.x
            return Vector(-z*AB.y,z*AB.x)
        else
            return AO
        end
    elseif #list==3 then
        local AB=list[2]-list[3]
        local AC=list[1]-list[3]
        local AO=list[3]*-1
        local ABC=AB.x*AC.y-AB.y*AC.x
        local ABPerp=Vector(AB.y*ABC,-AB.x*ABC)
        local ACPerp=Vector(-ABC*AC.y,ABC*AC.x)
        if sameDir(ACPerp,AO) then
            if sameDir(AC,AO) then
                table.remove(list,2)
                return ACPerp
            else
                if sameDir(AB,AO) then
                    table.remove(list,1)
                    return ABPerp
                else
                    local pointDir=AO*-1
                    if pointDir*list[1]>pointDir*list[2] then
                        table.remove(list,1)
                    else
                        table.remove(list,2)
                    end
                    return AO
                end
            end
        else
            if sameDir(ABPerp,AO) then
                if sameDir(AB,AO) then
                    table.remove(list,1)
                    return ABPerp
                else
                    if pointDir*list[1]>pointDir*list[2] then
                        table.remove(list,1)
                    else
                        table.remove(list,2)
                    end
                    return AO
                end
            else
                return true
            end
        end
    else
        error("Found "..#list.." vertices, expected 2 or 3")
    end
end

local function doGJK(objectA,objectB)
    local S=support(objectA,objectB,Vector(0,1))
    local list={S}
    local dir=S*-1

    while true do
        local A=support(objectA,objectB,dir)
        if A*dir<0 then
            return false, nil
        end
        table.insert(list,A)
        dir=doSimplex(list,dir)
        if dir==true then
            return true, list
        end
    end
end

--- EPA ---

local function lineDistFromOrigin(P1,P2)
    return math.abs(P2.x*P1.y-P2.y*P1.x)/math.sqrt((P2.y-P1.y)^2+(P2.x-P1.x)^2)
end

local function closestPointToOrigin(A,B)
    local AB=B-A
    local AO=A*-1
    local t=(AB*AO)/(AB.x^2+AB.y^2)
    return A+AB*t
end

local function doEPA(objectA,objectB,simplex)
    while true do
        -- find closest edge to origin
        local minDist=math.huge
        local key=0
        for i=1,#simplex do
            local i2=i<#simplex and i+1 or 1
            local currentDist=lineDistFromOrigin(simplex[i],simplex[i2])
            if currentDist<minDist then
                minDist=currentDist
                key=i2
            end
        end
        -- point A is key-1=key2, point B is key
        -- search dir is normal of AB pointing away from origin
        local key2=key>1 and key-1 or #simplex
        local AB=simplex[key]-simplex[key2]
        local AO=simplex[key2]*-1
        local z=AB.x*AO.y-AB.y*AO.x
        -- we normalize this because it needs to be normalized later for projection - support() doesn't require a normalized vector
        local searchDir=Vector(z*AB.y,-z*AB.x):normalize()
        local newPoint=support(objectA,objectB,searchDir)
        -- projecting the support point onto the search dir
        local scalarProjection=newPoint*searchDir
        local projectedPoint=searchDir*scalarProjection
        -- if the projected point is within a tolerance of the distance from the origin to the simplex edge, we've converged and can exit
        if projectedPoint:mag()-minDist<EPATolerance then
            return projectedPoint,key
        end
        -- add new point to the simplex, splitting the previously found edge
        table.insert(simplex,key,newPoint)
    end
end

--- final narrow function ---

function testIntersectNarrow()
    local broadIntersects=testIntersectBroad()
    local output={}
    for input,_ in pairs(broadIntersects) do
        local objectA,objectB
        if input[1]<input[2] then
            objectA=objects[input[1]]
            objectB=objects[input[2]]
        else
            objectA=objects[input[2]]
            objectB=objects[input[1]]
        end
        local success,simplex=doGJK(objectA,objectB)
        if success then
            local MTV,key=doEPA(objectA,objectB,simplex)
            table.insert(output,{a=input[1],b=input[2],MTV=MTV,simplex=simplex,key=key})
        end
    end
    return output
end

-- final --

function solveIntersects()
    local intersects=testIntersectNarrow()

end