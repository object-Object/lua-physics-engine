local Vector=require("vector")
require("utils")

local EPATolerance=0.0001
-- tolerances for sequential impulses
local SIIterationLimit=5
local SITolerance=0.1

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

supports.polygonList={
    [3]=function(o,dir)
        local r,angle=o.shape.radius,o.angle
        local vertices={
            rotatePoint(r,0,angle)+o.position,
            rotatePoint(r/2,-r*math.cos(math.rad(30)),angle)+o.position,
            rotatePoint(-r/2,-r*math.cos(math.rad(30)),angle)+o.position
        }
        return furthestVertex(vertices,dir)
    end,
    [4]=function(o,dir)
        local x, angle = o.shape.radius, o.angle
        local vertices={
            rotatePoint(-x,x,angle)+o.position,
            rotatePoint(x,x,angle)+o.position,
            rotatePoint(-x,-x,angle)+o.position,
            rotatePoint(x,-x,angle)+o.position
        }
        return furthestVertex(vertices,dir)
    end
}

supports.polygon=function(o,dir)
    return supports.polygonList[o.shape.sides](o,dir)
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
    elseif o.shape.type=="circle" or o.shape.type=="polygon" then
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

    -- find actual AABB intersections
    for obj1,list in pairs(possible) do
        for _,obj2 in pairs(list) do
            local objectA,objectB
            if obj1<obj2 then
                objectA=obj1
                objectB=obj2
            else
                objectA=obj2
                objectB=obj1
            end
            if not output[{objectA,objectB}] and not (objects[obj1].shape.static and objects[obj2].shape.static) then
                local a=getAABB(objects[objectA])
                local b=getAABB(objects[objectB])
                if testAABBOverlap(a,b) then
                    output[{objectA,objectB}]=true
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
    local sB=supports[objectB.shape.type](objectB,-dir)
    local support=sA-sB
    support.s1=sA
    support.s2=sB
    return support
end

local function sameDir(a,b)
    return a*b>0
end

local function doSimplex(list,dir)
    if #list==2 then
        local AB=list[1]-list[2]
        local AO=-list[2]
        if sameDir(AB,AO) then
            local z=AB.x*AO.y-AB.y*AO.x
            -- if z is 0, the origin is on the line; this breaks the perpendicular vector, so we need to return a perp vector using per-product
            -- can't just return true because EPA needs a 3-vertex simplex containing the origin as input
            return z~=0 and Vector(-z*AB.y,z*AB.x) or Vector(AB.y,-AB.x)
        else
            return AO
        end
    elseif #list==3 then
        local AB=list[2]-list[3]
        local AC=list[1]-list[3]
        local AO=-list[3]
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
                    local pointDir=-AO
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
    local dir=-S

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
    local AO=-A
    local t=(AB*AO)/(AB.x^2+AB.y^2)
    return A+AB*t
end

local function doEPA(objectA,objectB,simplex)
    -- determine if simplex is CW or CCW
    -- this is needed because if the shapes are just touching and cross product is used to determine perp vector, EPA never converges, so we use per-product, which changes depending on handedness
    local A=Vector(math.huge,math.huge)
    local AKey
    for k,v in ipairs(simplex) do
        if v.y<A.y or (v.y==A.y and v.x>A.x) then
            A=v
            AKey=k
        end
    end
    local B=simplex[AKey>1 and AKey-1 or #simplex]
    local C=simplex[AKey<#simplex and AKey+1 or 1]
    local AB=B-A
    local AC=C-A
    local isClockwise=AC.x*AB.y-AC.y*AB.x>0
    -- actual algorithm
    while true do
        -- find closest edge to origin
        local minDist=math.huge
        local key
        for i=1,#simplex do
            local i2=i<#simplex and i+1 or 1
            local currentDist=lineDistFromOrigin(simplex[i],simplex[i2])
            if currentDist<minDist then
                minDist=currentDist
                key=i2
            end
        end
        -- point A is key-1=key2, point B is key
        -- search dir is normal of AB pointing away from origin, aka out of simplex
        -- we normalize this because it needs to be normalized later for projection - support() doesn't require a normalized vector
        local key2=key>1 and key-1 or #simplex
        local AB=simplex[key]-simplex[key2]
        local searchDir
        if isClockwise then
            searchDir=Vector(AB.y,-AB.x):normalize()
        else
            searchDir=Vector(-AB.y,AB.x):normalize()
        end
        local newPoint=support(objectA,objectB,searchDir)
        -- projecting the support point onto the search dir
        local scalarProjection=newPoint*searchDir
        local projectedPoint=searchDir*scalarProjection
        -- if the projected point is within a tolerance of the distance from the origin to the simplex edge, we've converged and can exit
        if projectedPoint:mag()-minDist<EPATolerance then
            return projectedPoint,simplex[key2],simplex[key]
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
        local objectA=objects[input[1]]
        local objectB=objects[input[2]]
        local success,simplex=doGJK(objectA,objectB)
        if success then
            local simplexGJK=table.deepClone(simplex)
            local MTV,pointA,pointB=doEPA(objectA,objectB,simplex)
            local L=pointB-pointA
            local aClosest,bClosest
            if L==Vector(0,0) then
                aClosest=pointA.s1
                bClosest=pointA.s2
            else
                local lambda2=(-L*pointA)/(L*L)
                local lambda1=1-lambda2
                if lambda1<0 then
                    aClosest=pointB.s1
                    bClosest=pointB.s2
                elseif lambda2<0 then
                    aClosest=pointA.s1
                    bClosest=pointA.s2
                else
                    aClosest=pointA.s1*lambda1+pointB.s1*lambda2
                    bClosest=pointA.s2*lambda1+pointB.s2*lambda2
                end
            end
            table.insert(output,{a=input[1],b=input[2],MTV=MTV,aClosest=aClosest,bClosest=bClosest,simplexGJK=simplexGJK,simplex=simplex})
        end
    end
    return output
end

-- sequential impulses --

function solveIntersects(deltaTime)
    local intersects=testIntersectNarrow()
    if #intersects==0 then return end
    for _,intersect in ipairs(intersects) do
        local object1=objects[intersect.a]
        local object2=objects[intersect.b]
        intersect.depth=intersect.MTV:mag()
        intersect.MTVUnitVector=intersect.MTV/intersect.depth
        local n=intersect.MTVUnitVector
        local m1=object1.shape.invMass
        local I1=object1.shape.invInertia
        local m2=object2.shape.invMass
        local I2=object2.shape.invInertia

        intersect.r1=intersect.aClosest-object1.position
        intersect.r2=intersect.bClosest-object2.position
        local r1=intersect.r1
        local r2=intersect.r2

        intersect.constraintMass=(-n*-n)*m1
        +(n*n)*m2
        +r1:cross(n)^2*I1
        +(-r2):cross(n)^2*I2

        --pause("intersects loop")
        --_=true -- make the pause stop at the right spot
    end
    for i=1,SIIterationLimit do
        local numberConverged=0
        for _,intersect in ipairs(intersects) do
            local object1=objects[intersect.a]
            local object2=objects[intersect.b]
            local n=intersect.MTVUnitVector
            local v1=object1.linearVelocity
            local vrot1=object1.angularVelocity
            local v2=object2.linearVelocity
            local vrot2=object2.angularVelocity
            local r1=intersect.r1
            local r2=intersect.r2
            local m1=object1.shape.invMass
            local I1=object1.shape.invInertia
            local m2=object2.shape.invMass
            local I2=object2.shape.invInertia

            local JV=-n*v1
            +r1:cross(n)*vrot1
            +n*v2
            +-r2:cross(n)*vrot2

            local vn=((v2-v1)*n)*n

            local vTangent1=object1.angularVelocity*r1:mag()
            local sign1=math.sign(vTangent1)
            local tangent1=(r1:cwPerp()*sign1):normalize()*vTangent1

            local vTangent2=object2.angularVelocity*r2:mag()
            local sign2=math.sign(vTangent2)
            local tangent2=(r2:cwPerp()*sign2):normalize()*vTangent2

            local linear1=object1.linearVelocity:project(n)
            local linear2=object2.linearVelocity:project(n)
            local angular1=tangent1:project(n)
            local angular2=tangent2:project(n)

            local b=intersect.depth
            +linear1:mag()
            +linear2:mag()
            +angular1:mag()
            +angular2:mag()

            local lambda=(-JV+b)/intersect.constraintMass

            local dv1=(-n*lambda)*m1
            local dvrot1=(lambda*r1:cross(n))*I1
            local dv2=(n*lambda)*m2
            local dvrot2=(lambda*-r2:cross(n))*I2

            pause("SI iteration")

            local res=1.00
            object1.linearVelocity=object1.linearVelocity+dv1*res
            object2.linearVelocity=object2.linearVelocity+dv2*res
            object1.angularVelocity=object1.angularVelocity+dvrot1*res
            object2.angularVelocity=object2.angularVelocity+dvrot2*res

            if dv1:mag()<SITolerance and dvrot1<SITolerance and dv2:mag()<SITolerance and dvrot2<SITolerance then
                -- this intersect hasn't changed much
                numberConverged=numberConverged+1
            end
        end
        if numberConverged==#intersects then
            -- all are good, exit early
            break
        end
    end
    for _,intersect in ipairs(intersects) do
        local object1=objects[intersect.a]
        local object2=objects[intersect.b]
        object1.position=object1.position+object1.linearVelocity*deltaTime
        object1.angle=object1.angle+object1.angularVelocity*deltaTime
        object2.position=object2.position+object2.linearVelocity*deltaTime
        object2.angle=object2.angle+object2.angularVelocity*deltaTime
    end
end