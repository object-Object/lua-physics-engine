a={1,5,5,4}
highest=-math.huge
key=1
for i=1,#a-1 do
    if a[i]+a[i+1]>highest then highest=a[i]+a[i+1] key=i+1 end
end
table.insert(a,key,15)
require("print_r")
print_r(a)

local function closestPointToOrigin(A,B)
    local AB=B-A
    local AO=A*-1
    local t=(AB*AO)/(AB.x^2+AB.y^2)
    return A+AB*t
end

local Vector=require("vector")
draw.setscreen(1)
draw.line(350-100,350-100,350+410,350+60,draw.black)
draw.fillcircle(350,350,3,draw.black)
local p=closestPointToOrigin(Vector(-100,-100),Vector(410,60))
draw.fillcircle(350+p.x,350+p.y,3,draw.red)
draw.waittouch()