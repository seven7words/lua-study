-- @Author: woopqww111
-- @Date:   2017-07-13 14:50:46
-- @Last Modified by:   woopqww111
-- @Last Modified time: 2017-07-13 14:59:37
local tostring,math = tostring,math
local libngui = require"libngui.cs"
local libunity = require "libunity.cs"
local libnetwork = require "libnetwork.cs"
local UIMGR = MERequire "ui/uimgr.lua"
local UTIL = MERequire　"util/util.lua"
local TEXT = MERequire("localize/"..LANG.."/text.lua")

local P = {}
local TIPFloat_Target = {}
--目标提示框
--@content 提示框显示内容
--@target 提示框右下对齐的目标控件
--@time 提示框存在时间（默认2秒）
function P.show_float_tip_target(content,target,time)
	local dura = 2
	if not libunity.IsActive(TIPFloat_Target.go) then
		local go = UIMGR.create("UI/TIPFloat_Target",110)
		TIPFloat_Target = {
			go = go,
			lnContent = libunity.FindComponent(go,"lbContent","UILabel")
		}
	end
	TIPFloat_Target.lbContent.text = content
	libngui.AnchorTo(TIPFloat_Target.lbContent,"BottomRight",target,"Top",10,20)
	libngui.BeginTween("TweenAlpha",TIPFloat_Target.go,1,0,0.5,nil,dura-0.8)
	libunity.ReActive(TIPFloat_Target.go)
	-- return va
end
function P.lasttime_string(lastSeconds,Fmt)
	libunity.LogE("use _G.PKG[\"util/date\"].last2string instead.")

	-- return va
end
return P