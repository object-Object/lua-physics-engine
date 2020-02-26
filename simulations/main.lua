local doCollisionSolving=true
local debug=false

-- requires --
local Vector=require("vector")
local logger=require("logger")
local render
if debug then
    render=require("debugRender")
else
    render=require("render")
end
local getTime=require("getTime")
require("collision")
if debug then
    require("debugger")
else
    pause=function() end
end
require("vectorUtils")
require("utils")
require("integrators/SII") -- type of integration

require("print_r")

-- global constants --
c=299792458 -- speed of light
g=Vector(0,-9.81) -- stage gravity
G=6.674*10^-11 -- universal gravitational constant
k=9e9 -- electrostatic constant
backgroundColor=draw.white
textColor=draw.gray
defaultColor=draw.black
selectColor={red=1,green=0,blue=0,alpha=0.3}
draw.darkgreen={red=40/255,green=184/255,blue=0,alpha=1}
drawScale=true -- whether or not to draw a scale
initialWarpRate=1 -- default warp rate
drawVectors=true --whether or not to draw force, net force, and velocity arrows
exit=false -- modules can set this to stop the program
exitMessage="Exiting." -- modules can set this to print a message on exit
highlightSmallObjects=true -- put a translucent circle around very small objects

-- placeholder functions --
customInits={}
customRenders={}
customEvents={}
customTouchBegins={}
customTouchMoves={}
customTouchEnds={}
initNoFocusOffset=initNoFocusOffset or function() return Vector(0,0) end

-- sim --
require("sims/collision4") -- file containing object and force definitions to be run

-- local constants --
local dt=1/240
minWarpRate=0.1 -- min time warp
maxWarpRate=1e8 -- max time warp

-- variables --
local t=0
local currentTime
warpRate=initialWarpRate -- time warp multiplier
clearScreen=true --whether or not to clear the screen each frame
objects={}

-- components --
--require("components/OrbitalControls")
--require("components/WarpAndZoom")
if not doCollisionSolving then require("components/CollisionDisplay") end
require("components/Nametags")
--require("components/FrameTimeInfo")
require("components/ObjectInfo")

-- functions --
function fixY(y)
    return height-y
end

local function init()
    render.init()

    noFocusOffset=initNoFocusOffset()

    -- per-object things
    for k,o in ipairs(objects) do
        if o.focus==true then
            o.focus=nil
            focusObject=k
        end
        if o.shape.type=="box" and o.shape.fill then
            logger.warn("Filling is not supported for boxes.")
        end
    end

    for _,f in ipairs(customInits) do
        f()
    end

    currentTime=getTime()
end

local function doEvents(dt)
    draw.doevents()
    for _,f in ipairs(customEvents) do
        f(dt)
    end
end

local function tick(deltaTime)
    deltaTime=deltaTime*warpRate
    -- dynamic
    for _,object in pairs(objects) do
        object.forces={}
        doEvents(deltaTime)
        computeForces(object)

        -- linear velocity
        integrate(object,t,deltaTime)

        -- angular velocity
        local torque=0
        for _,f in ipairs(object.forces) do
            torque=torque+f.f.x*f.r.y-f.f.y*f.r.x
        end
        local angularAcceleration=torque*object.shape.invInertia
        object.angularVelocity=object.angularVelocity+angularAcceleration*deltaTime
        object.angle=object.angle+object.angularVelocity*deltaTime
    end
    if doCollisionSolving then solveIntersects(deltaTime) end
end

local function clearInstantForces()
    for _,o in pairs(objects) do
        for k,f in pairs(o.forces) do
            if f.instant then table.remove(o.forces,k) end
        end
    end
end

function getRadius(o)
    local r
    if o.shape.type=="box" then
        r=math.max(o.shape.width,o.shape.height)
    elseif o.shape.type=="circle" or o.shape.type=="polygon" then
        r=o.shape.radius
    end
    return r
end

-- draw events --
draw.tracktouches(function(x,y)
    for _,f in ipairs(customTouchBegins) do
        f(x,y)
    end
end, function(x,y)
    for _,f in ipairs(customTouchMoves) do
        f(x,y)
    end
end,
function(x,y)
    for _,f in ipairs(customTouchEnds) do
        f(x,y)
    end
end)


-- sim loop --
initObjects()
init()
render.render()
render.waitInput()

currentTime=getTime()
while true do
    local newTime=getTime()
    local frameTime=newTime-currentTime
    currentTime=newTime

    while frameTime>0 do
        local deltaTime=math.min(frameTime,dt)
        tick(deltaTime)
        frameTime=frameTime-deltaTime
        t=t+deltaTime*warpRate
    end

    render.render()

    clearInstantForces()

    if exit then
        print(exitMessage)
        break
    end
end