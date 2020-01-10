local Vector=require("vector")
local logger=require("logger")

local inertiaFunctions={

    ["box"]=function(o)
        return (o.shape.mass*(o.shape.width^2+o.shape.height^2))/12
    end,

    ["circle"]=function(o)
        return (o.shape.mass*o.shape.radius^2)/2
    end,

    ["polygon"]=function(o)
        return inertiaFunctions.polygonList[o.shape.sides](o)
    end,

    ["polygonList"]={
        [3]=function(o)
            return (o.shape.mass*o.shape.radius^2)/4
        end,
        [4]=function(o)
            return (o.shape.mass*2*(o.shape.radius*2)^2)/12
        end
    },

}

local function calculateInertia(object,settings)
    local inertia=inertiaFunctions[object.shape.type](object)
    return inertia, settings.static and 0 or 1/inertia
end

local function insertObject(object,settings)
    if settings.k then
        if objects[settings.k] then
            logger.warn("Object "..k.." overwritten")
        end
        objects[settings.k]=object
    else
        table.insert(objects,object)
    end
end

local function initGeneric(settings)
    local object={
        position=Vector(settings.x or 1, settings.y or 1),
        linearVelocity=Vector(settings.Vx or 0, settings.Vy or 0),
        angularVelocity=settings.Vrot or 0,
        angle=settings.angle or 0,
        shape={
            mass=settings.m or 10,
            invMass=settings.static and 0 or settings.m and 1/settings.m or 1/10,
            charge=settings.q or 0,
            color=settings.color or defaultColor,
            fill=settings.fill~=false and true or false,
            inertia=0,
            invInertia=0
        },
        forces={},
        hideVectors=settings.static or settings.hideVectors or false,
        focus=settings.focus or false,
        name=settings.name or "Untitled"
    }
    if settings.other then
        for k,v in pairs(settings.other) do
            object[k]=v
        end
    end
    return object
end

function initBox(settings)
    local box=initGeneric(settings)
    box.shape.type="box"
    box.shape.width=settings.w or 1
    box.shape.height=settings.h or 1
    box.shape.inertia, box.shape.invInertia=calculateInertia(box,settings)
    insertObject(box,settings)
end

function initPolygon(settings)
    local polygon=initGeneric(settings)
    polygon.shape.type="polygon"
    polygon.shape.sides=settings.sides or 4
    polygon.shape.radius=settings.r or 1
    polygon.shape.inertia, polygon.shape.invInertia=calculateInertia(polygon,settings)
    insertObject(polygon,settings)
end

function initCircle(settings)
    local circle=initGeneric(settings)
    circle.shape.type="circle"
    circle.shape.radius=settings.r or 1
    circle.shape.inertia, circle.shape.invInertia=calculateInertia(circle,settings)
    insertObject(circle,settings)
end