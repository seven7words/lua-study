local string_lower,string_format,string_sub,table_concat
 = string.lower,string.format,string.sub,table.concat
 local libunity = require "libunity.cs"
 local libasset = require "libasset.cs"
 local CONST = MERequire "datamgr/constant.lua"
 local UI_UTIL = MERequire "ui/util.lua"
 local UI_DATA = MERequire "datamgr/uidata.lua"

local function camera_follow(switch)
    if type(switch) == "string" then
        switch = string_lower(switch)
        local go = libunity.Find("/MOBAMgr")
        if go then
            if switch == "on" then
                libunity.SendMessage(go,"SwitchCameraFollow",true)
                elseif switch == "off" then
                    libunity.SendMessage(go,"SwitchCameraFollow",false)
                else
                    return
                end
                _G.UI.Toast.norm_toast("战斗中摄像机跟随："..switch)
            end
        end

end
local function camera_zoom( switch)
    if type(switch) == "string" then
        switch = string_lower(switch)
        local go = libunity.Find("/MOBAMgr")
        if go then
            if switch == "on" then
                libunity.SendMessage(go,"EnableOrbit",true)
                elseif switch == "off" then
                    libunity.SendMessage(go,"EnableOrbit",false)
                else
                    return
                end
                _G.UI.Toast.norm_toast("摄像机距离调整："..switch)
            end
        end
end
local function attack_delay_switch()
    switch = string_lower(switch)
    if "on" == switch then
        UI_DATA.FRMMoba.enableAttackDelay = true
        elseif "off" == switch then
            UI_DATA.FRMMoba.enableAttackDelay = false
        end
        _G.UI.Toast.norm_toast("首次攻击延迟："..switch,3)
end
local function switch_debug_mode()
    UI_DATA.WNDChapter.debug = not UI_DATA.WNDChapter.debug
    if UI_DATA.WNDChapter.debug then
        local UI_DATA_FRMMoba = UI_DATA.FRMMoba
        UI_DATA_FRMMoba.sn = 0
        UI_DATA_FRMMoba.Assets = {
        playerExp = 0,HeroesExp = {},gold = 0,diamond = 0,
    }
        UI_DATA_FRMMoba.Items = {}
    end
    _G.UI.Toast.norm_toast("章节调试模式："..tostring(UI_DATA.WNDChapter.debug),3)
end
local function pass_combat_guide()
    if g_current_level_name == "Stage-xiaoxi-3" then
        local DY_DATA = _G.PKG["datamgr/dydata"]
        DY_DATA.CliData.Guide[0] = 0
        _G.PKG["datamgr/data"].save_clidata()
        _G.PKG["global/scenemgr"].load_home()
    end
end
local function launch_combat_guide()
    _G.PKG["datamgr/data"].launch_combat_guide()
end
local function set_battle_frame(frameIndex)
    _G.PKG["moba/api"].set_battle_frame(frameIndex and tonumber(frameIndex) or nil)
end
return {
    camera = {
    follow = camera_follow,
    zoom = camera_zoom,
},
delay = attack_delay_switch,
debug = switch_debug_mode,
pass = pass_combat_guide,
guide = launch_combat_guide,
frame = set_battle_frame,
}
