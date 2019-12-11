-- semi-implicit Euler integration method

local Vector=require("vector")

function integrate(object,t,dt)
    local netForce=Vector(0,0)
    for _,force in pairs(object.forces) do
        netForce=netForce+force.f
    end
    local linearAcceleration=netForce/object.shape.mass
    object.linearVelocity=object.linearVelocity+linearAcceleration*dt
    object.position=object.position+object.linearVelocity*dt
end