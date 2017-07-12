local function select_host(tag)
    local CH_CFG = _G.PKG["datamgr/channelcfg"]
    CH_CFG.select_host(tag)
end
local function select_pid(pid)
    local CH_CFG = _G.PKG["datamgr/channelcfg"]
    CH_CFG.select_pid(tonumber(pid))
end
return {
    select = {
    host = select_host,
    pid = select_pid,
    },
}
