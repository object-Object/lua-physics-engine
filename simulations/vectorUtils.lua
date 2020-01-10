local Vector=require("vector")

function AxisVector(mag,xSign,angle,ySign)
    return Vector(mag*math.cos(angle)*xSign,mag*math.sin(angle)*ySign)
end

function roundVector(v,places)
    return Vector(math.round(v.x,places),math.round(v.y,places))
end