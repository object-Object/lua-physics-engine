table.insert(customRenders,function()
    local intersects=testIntersectNarrow()
    table.sort(intersects, function(a,b) return a.a<b.a end)
    local output=""
    local offset=6*scale

    draw.fillcircle(offset,fixY(offset),2,draw.black)
    for _,input in pairs(intersects) do
        output=output..objects[input.a].name.." x "..objects[input.b].name.."\n"
        local AB=objects[input.b].position-objects[input.a].position
        local deepestPointA=input.aClosest
        local deepestPointB=input.bClosest

        local objectA=objects[input.a]
        local objectB=objects[input.b]

        local r1=input.aClosest-objectA.position
        local r2=input.bClosest-objectB.position

        draw.fillcircle(deepestPointA.x*scale,fixY(deepestPointA.y*scale),2,draw.orange)
        draw.fillcircle(deepestPointB.x*scale,fixY(deepestPointB.y*scale),2,draw.red)
        draw.line(deepestPointA.x*scale,fixY(deepestPointA.y*scale),(deepestPointA.x-input.MTV.x)*scale,fixY((deepestPointA.y-input.MTV.y)*scale),draw.orange)
        draw.line(deepestPointB.x*scale,fixY(deepestPointB.y*scale),(deepestPointB.x+input.MTV.x)*scale,fixY((deepestPointB.y+input.MTV.y)*scale),draw.red)

        for i=1,#input.simplex-1 do
            local color=draw.blue
            draw.line(input.simplex[i].x*scale+offset,fixY(input.simplex[i].y*scale+offset),input.simplex[i+1].x*scale+offset,fixY(input.simplex[i+1].y*scale+offset),color)
        end
        local color=draw.blue
        draw.line(input.simplex[#input.simplex].x*scale+offset,fixY(input.simplex[#input.simplex].y*scale+offset),input.simplex[1].x*scale+offset,fixY(input.simplex[1].y*scale+offset),color)

        for i=1,#input.simplexGJK-1 do
            draw.line(input.simplexGJK[i].x*scale+offset,fixY(input.simplexGJK[i].y*scale+offset),input.simplexGJK[i+1].x*scale+offset,fixY(input.simplexGJK[i+1].y*scale+offset),draw.cyan)
        end
        draw.line(input.simplexGJK[#input.simplexGJK].x*scale+offset,fixY(input.simplexGJK[#input.simplexGJK].y*scale+offset),input.simplexGJK[1].x*scale+offset,fixY(input.simplexGJK[1].y*scale+offset),draw.cyan)

        draw.line(offset,fixY(offset),input.MTV.x*scale+offset,fixY(input.MTV.y*scale+offset),draw.red)
    end
    draw.string(output,10,100,textColor)
end)