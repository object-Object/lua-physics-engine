local Vector=require("vector")

function AxisVector(mag,xSign,angle,ySign)
    angle=math.rad(angle)
    return Vector(mag*math.cos(angle)*xSign,mag*math.sin(angle)*ySign)
end