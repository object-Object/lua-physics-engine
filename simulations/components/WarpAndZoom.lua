local Vector=require("vector")
local render=require("render")

zoomRate=1.005
zoomDelay=0.5
zoom=1
zoomStart=draw.gettime()
zoomWaiting=false
drawScale=false

table.insert(customInits, function()
    -- create controls --
    draw.clear(backgroundColor)
    -- decrease timewarp
    draw.rect(5,fixY(5),45,fixY(45),textColor)
    draw.fillrect(15,fixY(24),35,fixY(26),textColor)
    -- increase timewarp
    draw.rect(55,fixY(5),95,fixY(45),textColor)
    draw.fillrect(65,fixY(24),85,fixY(26),textColor)
    draw.fillrect(74,fixY(15),76,fixY(35),textColor)
    -- focus minus
    draw.rect(105,fixY(5),145,fixY(45),textColor)
    draw.circle(122,fixY(28),8,textColor)
    draw.line(128,fixY(22),135,fixY(15),textColor)
    draw.fillrect(118,fixY(27),126,fixY(29),textColor)
    -- focus plus
    draw.rect(155,fixY(5),195,fixY(45),textColor)
    draw.circle(172,fixY(28),8,textColor)
    draw.line(178,fixY(22),185,fixY(15),textColor)
    draw.fillrect(168,fixY(27),176,fixY(29),textColor)
    draw.fillrect(171,fixY(24),173,fixY(32),textColor)
    -- clear screen
    draw.rect(205,fixY(5),245,fixY(45),textColor)
    draw.line(212,fixY(33),217,fixY(38),textColor)
    draw.line(212,fixY(33),230,fixY(15),textColor)
    draw.line(215,fixY(30),220,fixY(35),textColor)
    draw.line(230,fixY(15),235,fixY(20),textColor)
    draw.line(217,fixY(38),235,fixY(20),textColor)
    draw.line(230,fixY(15),238,fixY(12),textColor)
    draw.line(235,fixY(20),238,fixY(12),textColor)
    -- save to file
    draw.imagesave("images/ctrl.png",5,fixY(5),245,fixY(45))
    draw.cacheimage("images/ctrl.png")
end)

table.insert(customEvents, function()
    if zoomWaiting and draw.gettime()-zoomStart>zoomDelay then
        zoomWaiting=false
    end
    if not zoomWaiting then
        scale=scale*zoom
    end
end)

table.insert(customRenders, function()
    -- big ugly info string
    draw.string("Scale: "..render.getScale().."\nTimewarp: "..warpRate.."x\nFocused object: "..render.getFocusName().."\nSelected object: "..render.getSelectedName().."\nClear screen each frame: ".. (clearScreen and "yes" or "no"),5,fixY(165),textColor)
    -- controls
    draw.image("images/ctrl.png",5,fixY(45))
end)

table.insert(customTouchBegins, function(x,y)
    if y<fixY(5) and y>fixY(45) then
        if x>5 and x<45 and warpRate>minWarpRate then
            -- decrease warp
            warpRate=warpRate/10
        elseif x>60 and x<100 and warpRate<maxWarpRate then
            -- increase warp
            warpRate=warpRate*10
        elseif x>105 and x<145 then
            -- start decreasing zoom
            scale=scale/1.2
            zoom=1/zoomRate
            zoomStart=draw.gettime()
            zoomWaiting=true
        elseif x>155 and x<195 then
            -- start increasing zoom
            scale=scale*1.2
            zoom=zoomRate
            zoomStart=draw.gettime()
            zoomWaiting=true
        elseif x>205 and x<245 then
            -- clearing screen
            clearScreen=not clearScreen
            if not clearScreen then
                draw.clear(backgroundColor)
            end
        end
    end
    if not (y<fixY(5) and y>fixY(45) and x>5 and x<245) then
        -- select/focus
        for k,o in pairs(objects) do
            local offset=render.getFocusOffset()
            local distance=Vector(o.position.x*scale-x+offset.x,fixY(o.position.y*scale+offset.y)-y)
            local radius=getRadius(o)*scale
            local touchRadius=radius<20 and 20 or radius
            if distance:mag()<touchRadius then
                if selectedObject==k then
                    focusObject=k
                else
                    selectedObject=k
                end
                return
            end
        end
        if selectedObject==false then
            focusObject=false
        else
            selectedObject=false
        end
    end
end)

table.insert(customTouchEnds, function()
    zoom=1
end)