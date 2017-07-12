local ngui = require "libngui.cs"
local function open_new_window()
    libngui.Create("UI/"..prefab,0)
end
local function close_window(name)
    local UIMGR = MERequire "ui/uimgr.lua"
    if name then
    else
        local UI_DATA = MERequire "datamgr/uidata.lua"
        UIMGR.close_window()
    end
end
local function toast(content)
    _G.UI.Toast.make(nil,content):show()
end

local function mbox(content)
    _G.UI.MessageBox.make("MBNormal")
    :set_param("content",content)
    :show()
end
local function reward(n)
    local GET = _G.PKG["debug/getobj"]
    if GET then
        _G.UI.MessageBox.reward("测试获得道具",GET.get_items(tonumber(n)))
    end
end
local function call_logout()
    local sdk = MERequire "framework/sdk.lua"
    sdk.on_sdk_message('{"method" : "sdk_logouted"}')
end
local function reset_guide()
    -- 关闭所有引导
    local Guide = {["1"] = 0}
    for _,v in ipairs(_G.PKG["guide/list"]) do
        Guide[v] = 0
    end
    local Totorial = {
        rune = 0,
    }
    _G.PKG["datamgr/dydata"].CliData = {Guide = Guide,Tutorial = Tutorial}
    _G.PKG["datamgr/data"].save_clidata()
end
local function combat_guide()
    _G.PKG["datamgr/data"].launch_combat_guide()
end
local function launch_guide(group)
    _G.PKG["datamgr/data"].launch_guide(group,nil,nil)
end
