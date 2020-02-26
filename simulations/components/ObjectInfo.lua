local Vector=require("vector")
require("vectorUtils")
local places=5
table.insert(customRenders,function()
    local output=""
    local p=Vector(0,0)
    local e=0
    for _,o in pairs(objects) do
        output=output..o.name..": v="..tostring(roundVector(o.linearVelocity,places)).." ("..math.round(o.linearVelocity:mag(),places)..")   m=".. o.shape.mass.."   vrot="..math.round(o.angularVelocity,places).."   I="..math.round(o.shape.inertia,places).."\n"
        p=p+o.linearVelocity*o.shape.mass
        e=e
        +0.5*o.shape.mass*o.linearVelocity:mag()^2
        +0.5*o.shape.inertia*o.angularVelocity^2
    end
    output=output.."Total momentum: "..tostring(roundVector(p,places)).." ("..math.round(p:mag(),places)..")\nTotal energy: "..math.round(e,places).."\n"
    draw.string(output,10,100,textColor)
end)