function class(Sub,Base)
    local BaseMT = getmetatable(Base)
    Sub.__index = BaseMT.__index
    Sub.__newindex = BaseMT.__newindex
    if rawget(Sub,"__tostring") == nil then
        Sub.__tostring = BaseMT.__tostring
    end
    setmetatable(Sub,BaseMT)
    return Sub
end
