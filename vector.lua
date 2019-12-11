local type = require("typical")

local Vector = {}
do
    local meta = {
        _metatable = "Private metatable",
        _DESCRIPTION = "Vectors in 2D"
    }

    meta.__index = meta

    function meta:__add( v )
        return Vector(self.x + v.x, self.y + v.y)
    end

    function meta:__sub( v )
        return Vector(self.x - v.x, self.y - v.y)
    end

    function meta:__mul( n )
        return type(n)=="vector" and self.x * n.x + self.y * n.y or Vector(self.x * n, self.y * n)
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

    function meta:magnitude()
        return math.sqrt( self.x^2 + self.y^2 )
    end

    meta.mag = meta.magnitude

    function meta:normalize()
        return self/self:mag()
    end

    setmetatable( Vector, {
        __call = function( V, x ,y ) return setmetatable( {x = x, y = y}, meta ) end
    } )
end

Vector.__index = Vector

return Vector