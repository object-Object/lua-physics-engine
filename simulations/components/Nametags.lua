local render=require("render")

table.insert(customRenders,function()
    for _,object in pairs(objects) do
        local focusOffset=render.getFocusOffset()
        local posX=object.position.x*scale+focusOffset.x
        local posY=object.position.y*scale+focusOffset.y
        draw.string(object.name,posX,fixY(posY),textColor)
    end
end)