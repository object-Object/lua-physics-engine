local type = require("typical")

local Vector = {}
do
    local meta = {
        _metatable = "Private metatable",
        _DESCRIPTION = "Vectors in 2D"
    }

    meta.__index = meta

    function meta:__eq( v )
        if type(v)~="vector" then
            return false
        else
            return self.x==v.x and self.y==v.y
        end
    end

    function meta:__add( v )
        return Vector(self.x + v.x, self.y + v.y)
    end

    function meta:__sub( v )
        return Vector(self.x - v.x, self.y - v.y)
    end

    function meta:__unm()
        return Vector(-self.x, -self.y)
    end

    function meta:__mul( n )
        local tn,ts=type(n),type(self)
        if ts=="number" then
            return Vector(n.x * self, n.y * self)
        elseif tn=="vector" then
            return self.x * n.x + self.y * n.y
        elseif tn=="number" then
            return Vector(self.x * n, self.y * n)
        else
            error("Expected vector or number and vector or number, got "..ts.." and "..tn)
        end
    end

    function meta:__div( s )
        return Vector(self.x * 1/s, self.y * 1/s)
    end

    function meta:__type()
        return "vector"
    end

    function meta:__tostring()
        return ("<%g, %g>"):format(self.x, self.y)
    end

    function meta:cross(v)
        return self.x*v.y-self.y*v.x
    end

    function meta:magnitude()
        return math.sqrt( self.x^2 + self.y^2 )
    end

    meta.mag = meta.magnitude

    function meta:normalize()
        return self/self:mag()
    end

    function meta:project( v )
        local unit=v:normalize()
        local scalarProjection=self.x*unit.x+self.y*unit.y
        return scalarProjection*unit
    end

    function meta:cwPerp()
        return Vector(self.y,-self.x)
    end

    function meta:ccwPerp()
        return Vector(-self.y,self.x)
    end

    function meta:rotate( a )
        return Vector(
        math.cos(a)*self.x - math.sin(a)*self.y,
        math.sin(a)*self.x + math.cos(a)*self.y
        )
    end

    setmetatable( Vector, {
        __call = function( V, x ,y ) return setmetatable( {x = x, y = y}, meta ) end
    } )
end

Vector.__index = Vector

return Vector