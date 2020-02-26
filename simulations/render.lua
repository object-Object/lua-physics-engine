local Vector=require("vector")
require("utils")

local render={}

render.drawArrow=function(x1,y1,x2,y2,headRadius,angle,color)
    draw.line(x1,y1,x2,y2,color)
    draw.fillpolygon(x2,y2,headRadius,3,angle,color)
end

render.getFocusOffset=function()
    if focusObject then
        return Vector(
        width/2-objects[focusObject].position.x*scale,
        height/2-objects[focusObject].position.y*scale
        )
    else
        return noFocusOffset
    end
end

render.getScale=function()
    if scale>1 then
        return math.round(scale).." pixel"..s(math.round(scale)).." = 1 metre"
    else
        return "1 pixel = "..math.round(1/scale).." metre"..s(math.round(1/scale))
    end
end

render.getFocusName=function()
    if focusObject then
        return objects[focusObject].name
    else
        return "None"
    end
end

render.getSelectedName=function()
    if selectedObject then
        return objects[selectedObject].name
    else
        return "None"
    end
end

render.init=function()
    draw.setscreen(1)
    draw.clear(backgroundColor)
    width,height=draw.getport()
    print("Dimensions: ",width,height)
    draw.setfont("Helvetica",5)
    draw.setlinestyle(2,"butt")

    -- create scale, save and cache to image file
    if drawScale then
        draw.clear(backgroundColor)
        for n=0,height do
            local tW,tH=draw.stringsize(n/scale)
            local mod=1
            if scale<20 then
                mod=(20-scale)*2
            end
            if n%(scale*mod)==0 then
                if n~=0 then draw.string(n/scale,0,fixY(n+tH/2),textColor) end
                draw.string(n/scale,n-tW/2,fixY(tH),textColor)
            end
        end
        draw.imagesave("images/bg.png",0,0,width,height)
        draw.cacheimage("images/bg.png")
    end
    draw.setfont("Helvetica",20)
end

render.waitInput=function()
    draw.beginframe()
    draw.setfont("Helvetica",30)
    local x,y=draw.stringsize("Tap to start")
    draw.string("Tap to start",width/2-x/2,height/3,textColor)
    draw.setfont("Helvetica",20)
    draw.endframe()
    draw.waittouch()
end

render.render=function()
    local focusOffset=render.getFocusOffset()
    draw.beginframe()
    if clearScreen then
        draw.clear(backgroundColor)
        if drawScale then
            draw.image("images/bg.png",0,0)
        end
    end

    -- objects and vectors
    for k,object in pairs(objects) do
        local posX=object.position.x*scale+focusOffset.x
        local posY=object.position.y*scale+focusOffset.y
        local r=getRadius(object)*scale
        if object.shape.type=="box" then
            local w,h,angle,c = object.shape.width*scale/2, object.shape.height*scale/2, object.angle, object.shape.color
            --[[
1-2
| |
3-4
]]
            local p1=rotatePoint(-w,h,angle)
            local p2=rotatePoint(w,h,angle)
            local p3=rotatePoint(-w,-h,angle)
            local p4=rotatePoint(w,-h,angle)
            draw.line(p1.x+posX,fixY(p1.y+posY),p2.x+posX,fixY(p2.y+posY),c)
            draw.line(p1.x+posX,fixY(p1.y+posY),p3.x+posX,fixY(p3.y+posY),c)
            draw.line(p3.x+posX,fixY(p3.y+posY),p4.x+posX,fixY(p4.y+posY),c)
            draw.line(p2.x+posX,fixY(p2.y+posY),p4.x+posX,fixY(p4.y+posY),c)

        elseif object.shape.type=="circle" then
            if object.shape.fill then
                draw.fillcircle(posX,fixY(posY),r,object.shape.color)
            else
                draw.circle(posX,fixY(posY),r,object.shape.color)
            end
        elseif object.shape.type=="polygon" then
            if object.shape.fill then
                draw.fillpolygon(posX,fixY(posY),r,object.shape.sides,object.angle,object.shape.color)
            else
                draw.polygon(posX,fixY(posY),r,object.shape.sides,object.angle,object.shape.color)
            end
        end
        if r<0.5 and highlightSmallObjects==true then
            -- if this crashes, look for a color table that doesn't have colors defined as {red=x, green=x, blue=x}
            local c=table.deepClone(object.shape.color)
            c[4]=nil
            c.a=nil
            c.alpha=0.5
            draw.fillcircle(posX,fixY(posY),8,c)
        end
        if selectedObject==k then
            draw.circle(posX,fixY(posY),r+10,selectColor)
        end
        --drawGravity(object,posX,posY,r)
        if drawVectors and not object.hideVectors then
            local endX=posX+object.linearVelocity.x*(scale/7)
            local endY=posY+object.linearVelocity.y*(scale/7)
            render.drawArrow(posX,fixY(posY),endX,fixY(endY),4,math.atan2(object.linearVelocity.y,object.linearVelocity.x),draw.blue)
            local netForce=Vector(0,0)
            local count,avgX,avgY=0,0,0
            for _,force in pairs(object.forces) do
                posX=object.position.x*scale+force.r.x*scale+focusOffset.x
                posY=object.position.y*scale+force.r.y*scale+focusOffset.y
                endX=posX+force.f.x*object.shape.invMass*(scale/7)
                endY=posY+force.f.y*object.shape.invMass*(scale/7)
                render.drawArrow(posX,fixY(posY),endX,fixY(endY),4,math.atan2(force.f.y,force.f.x),draw.red)
                netForce=netForce+force.f
                avgX=avgX+posX
                avgY=avgY+posY
                count=count+1
            end
            posX=avgX/count
            posY=avgY/count
            endX=posX+netForce.x*object.shape.invMass*(scale/7)
            endY=posY+netForce.y*object.shape.invMass*(scale/7)
            render.drawArrow(posX,fixY(posY),endX,fixY(endY),4,math.atan2(netForce.y,netForce.x),draw.darkgreen)
        end
    end

    for _,f in ipairs(customRenders) do
        f()
    end

    draw.endframe()
end

return render