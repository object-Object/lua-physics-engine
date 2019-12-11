-- RK4 integration method

local Vector=require("vector")

local function acceleration(object)
    local netForce=Vector(0,0)
    for _,force in pairs(object.forces) do
        netForce=netForce+force.f
    end
    return netForce/object.shape.mass
end

local function evaluate(object,t,dt,d)
    local state={
        x=object.position+d.dx*dt,
        v=object.linearVelocity+d.dv*dt
    }
    local output={
        dx=state.v,
        dv=acceleration(object)
    }
    return output
end

function integrate(object,t,dt)
    local a,b,c,d
    a=evaluate(object,t,dt,{dx=Vector(0,0),dv=Vector(0,0)})
    b=evaluate(object,t,dt*0.5,a)
    c=evaluate(object,t,dt*0.5,b)
    d=evaluate(object,t,dt,c)
    local dxdt = ( a.dx + ( b.dx + c.dx )*2 + d.dx )/6
    local dvdt = ( a.dv + ( b.dv + c.dv )*2 + d.dv )/6
    object.position = object.position + dxdt * dt
    object.linearVelocity = object.linearVelocity + dvdt * dt
end