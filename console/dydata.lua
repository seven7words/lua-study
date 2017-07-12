local type,table_concat = type,table.concat
local JSON = JSON
local DY_DATA = MERequire "datamgr/dynamicdata.lua"
local function get_by_data( ... )
    local args ={...}
    local tb = DY_DATA
    local content = ""
    for _,v in ipairs(args) do
        local n = tonumber(n)
        if n then
            tb = tb[n]
            content = content.."["..n.."]"
        else
            tb = tb[v]
            content = content .."."..v
        end
        if not tb then
            return content
        end
    end
    content = content .. "\n"
    for k,v in pairs(tb) do
        if v then
            content = content..k.."="..JSON:encode_pretty(v) .."\n"
        end
    end
    return content
end
return {
    data = get_by_data,
}
