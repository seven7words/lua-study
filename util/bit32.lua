local libsystem = require "libsystem.cs"
local P={}
function P.bor()
    return libsystem.BitOr(a,b)
end
function P.band()
    return libsystem.BitAnd(a,b)
end

_G.bit32 = P
