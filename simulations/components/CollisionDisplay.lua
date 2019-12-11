table.insert(customRenders,function()
    local intersects=testIntersectNarrow()
    table.sort(intersects, function(a,b) return a.a<b.a end)
    local output=""
    draw.fillcircle(350,fixY(350),2,draw.black)
    for _,input in pairs(intersects) do
        output=output..objects[input.a].name.." x "..objects[input.b].name.."\n"

        local deepestPointA=supports[objects[input.a].shape.type](objects[input.a],input.MTV*-1)
        local deepestPointB=supports[objects[input.b].shape.type](objects[input.b],input.MTV)
        draw.line(deepestPointA.x*scale,fixY(deepestPointA.y*scale),(deepestPointA.x+input.MTV.x)*scale,fixY((deepestPointA.y+input.MTV.y)*scale),draw.red)
        draw.line(deepestPointB.x*scale,fixY(deepestPointB.y*scale),(deepestPointB.x-input.MTV.x)*scale,fixY((deepestPointB.y-input.MTV.y)*scale),draw.red)

        for i=1,#input.simplex-1 do
            local color=draw.blue
            if input.key==i+1 then color=draw.green end
            draw.line(input.simplex[i].x*scale+350,fixY(input.simplex[i].y*scale+350),input.simplex[i+1].x*scale+350,fixY(input.simplex[i+1].y*scale+350),color)
        end
        local color=draw.blue
        if input.key==1 then color=draw.green end
        draw.line(input.simplex[#input.simplex].x*scale+350,fixY(input.simplex[#input.simplex].y*scale+350),input.simplex[1].x*scale+350,fixY(input.simplex[1].y*scale+350),color)
        draw.line(350,fixY(350),input.MTV.x*scale+350,fixY(input.MTV.y*scale+350),draw.red)
    end
    draw.string(output,10,100,textColor)
end)