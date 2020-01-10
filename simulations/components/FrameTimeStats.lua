mindt=math.huge
minnumdt=0
maxdt=-math.huge
maxnumdt=0
totaldt=0
totalnumdt=0
table.insert(customEvents,function(dt)
    if dt>maxdt then
        maxdt=dt
        maxnumdt=0
    elseif dt==maxdt then
        maxnumdt=maxnumdt+1
    elseif dt<mindt then
        mindt=dt
        minnumdt=0
    elseif dt==mindt then
        minnumdt=minnumdt+1
    end
    totaldt=totaldt+dt
    totalnumdt=totalnumdt+1
end)

function fraction(num)
    if num>1 then
        return tostring(math.round(num))
    else
        return "1/"..tostring(math.round(1/num))
    end
end

table.insert(customRenders,function()
    draw.string("Frame time stats\nMin: "..fraction(mindt).." ("..minnumdt..")\nAvg: "..fraction(totaldt/totalnumdt).."\nMax: "..fraction(maxdt).." ("..maxnumdt..")\nFrame count: "..totalnumdt,10,400,textColor)
end)