local Vector=require("vector")
require("utils")

local render={}

render.init = function()
    print("[Render] Initialized")
end

render.render = function()
    --print(objects[1].linearVelocity,objects[2].linearVelocity)
end

render.waitInput = function()
    io.write("[Render] Waiting for input: ")
    io.read()
end

return render