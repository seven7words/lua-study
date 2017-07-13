-- @Author: woopqww111
-- @Date:   2017-07-13 15:00:01
-- @Last Modified by:   woopqww111
-- @Last Modified time: 2017-07-13 18:48:40
local libngui = require"libngui.cs"
local libunity = require "libunity.cs"
local libasset - require "libasset.cs"
local WindowDEF = MERequire "ui/window.lua"
local DY_DATA = MERequire "datamgr/dynamicdata.lua"

local P = {
	WNDStack = _G.DEF.Stack.new()
	TarWND = nil,
	tweenLength = 0.25,
}
--窗口使用注意：
--1.在栈内管理的窗口，如果使用了打开/关闭动画，需要规避多次触发关闭的问题。
--使用（UICloseButton代替UIButton）
function P.ani_window_open(go)
	return libngui.DOTween("Scale",go,0.3,1,P.tweenLength,{method = "OutBack"})
	-- return va
end
function P.ani_window_close(go)
	return libngui.DOTween("Scale",go,1,0.3,P.tweenLength,{method = "InBack"})
	-- return va
end
function P.on_window_open(go)
	P.ani_window_open(go)
	-- return va
end
local function on_wnd_finished()
	local tw = NGUI.UITweener.current
	libunity.Destroy(tw.gameObject)
	-- return va
end
function P.on_window_close(go)
	local tw = P.ani_window_close(go)
	if tw then
		NGUI.EventDelegate.Add(tw.onFinished,on_wnd_finished,true)
	else
		libunity.Destroy(go)
	end
	-- return va
end
-- ===========================================================
-- 深度 depth
P.DEPTH_G 		= 20			-- 一般全屏独占窗口
P.DEPTH_SUB	 	= 30			-- 独占窗口弹出的子窗口
P.DEPTH_C	    = 50			-- 主控制条（）
P.DEPTH_POP	 	= 60			-- 独立弹出的子窗口，屏蔽控制条交互
P.DEPTH_SEP	    = 90			-- 特殊功能，优先级别较高（比如点金手）
P.DEPTH_TOP	    = 100			-- 最高层的提示框
function P.create(prefab,depth)
	if depth == nil then
		depth = 0
	end
	return libngui.Create(prefab,depth)
	-- return va
end
function P.ani_create(prefab,depth)
	local go = P.create(prefab,depth)
	P.ani_window_open(go)
	return go
	-- return va
end
function P.close(go,delay)
	libunity.Destroy(go,delay or 0)
	-- return va
end
function P.ani_close(go)
	P.on_window_close(go)
	-- return va
end
function P.new_window(prefab,depth)
	depth = depth or P.DEPTH_G
	local n = 0
	if depth == P.DEPTH_G then
		--关闭栈中所有可见的界面
		while true do
			local TopWnd = P.WNDStack:peek(n)
			if TopWnd and TopWnd:is_opened() then
				TopWnd:close()
				n = n+1
			else
				break
			end
		end
	else
		--栈顶窗口的深度如果相同就关闭
		local TopWnd = P.WNDStack:peek()
		if TopWnd and TopWnd.depth == depth then
			TopWnd:close()
			n = n+1
		end
	end
	local NewWnd = WindowDEF:new(prefab,depth)
	NewWnd.prevN = n > 0 and n or 1
	P.WNDStack:push(NewWnd)
	libunity.LogI("Push {0},{1},{2}",NewWnd,NewWnd.prevN,#P.WNDStack)
	return NewWnd
	-- return va
end
--窗口管理，放到一个栈内
--在指定的深度打开一个新窗口兵压入栈，关闭原栈顶窗口
--记录窗口动作位push，可在窗口回收消息内并判断此动作
function P.create_window(prefab,depth,instantly)
	P.action = "push"
	local NewWnd = P.new_window(prefab,depth)
	NewWnd:open()
	if NewWnd.depth > P.DEPTH_C then
		if not instantly then
			P.ani_window_open(NewWnd.go)
		end
	end
	P.action = nil
	return NewWnd
	-- return va
end
--弹出并关闭栈顶窗口
function P.pop_window(instantly)
	local n = 0
	local TopWnd = P.WNDStack:pop()
	if TopWnd then
		if TopWnd:is_opened() then
			n = TopWnd.prevN
			local delay = 0
			if TopWnd.depth > P.DEPTH_C then
				if not instantly then
					local tw = P.ani_window_close(TopWnd.go)
					delay = tw and (1-tw.tweenFactor) * tw.duration or 0
				end
			end
				TopWnd:close(delay)
		end
			libunity.LogI("Pop {0},{1},{2}",TopWnd,TopWnd.prevN,#P.WNDStack)
	end
	return n
	-- return va
end
--关闭栈顶窗口，并弹出栈内的下一个窗口
--记录窗口动作为pop，可在窗口启动|回收消息内判断此动作
function P.close_window(instantly)
	P.action = "pop"
	local n = P.pop_window(instantly)
	for i = 1, n-1 do
		local OldWnd = P.WNDStack:peek(i)
		if OldWnd and not OldWnd:is_opened() then
			libunity.LogI("Reopen"..tostring(OldWnd))
			OldWnd:open()
		end
	end
	P.action = nil
	-- return va
end
--重新打开栈顶窗口
function P.open_topwnd()
	local Wnds,n = {},0
	while true do
		local Wnd = P.WNDStack:peek(n)
		if Wnd then
			table.insert(Wnds,1,Wnd)
			if Wnd.depth <= P.DEPTH_G then break end
		else break end
		n = n + 1
	end
	P.action = "pop"
	for i, v in ipairs(Wnds) do
		v:open()
	end
	P.action = nil
	return Wnds[1]
	-- return va
end
function P.top(n)
	return P.WNDStack:peek(n or 0)
	-- return va
end
--从指定栈顶往下查找指定名称的界面是否压栈
function P.stacked(n,...)
	if n == nil then n = 0 end
	local Names = {}
	for _, v in ipairs({...}) do
		Names["UI/"..v] = true
	end
	while true do
		local TopWnd = P.WNDStack:peek(n)
		if TopWnd then
			if Names[TopWnd.path] then
				return true
			end
			n = n +1
		else
			break
		end
	end
	return false
	-- return va
end
--在堆栈中查找一个打开的界面
function P.find(name)
	local n = 0
	while true do
		local TopWnd = P.WNDStack:peek(n)
		if TopWnd then
			if TopWnd:is_opened() and TopWnd:is_name(name) then
				return TopWnd
			end
			n = n +1
		else
			break
		end
	end

	-- return va
end
--更新可见窗口的显示
function P.update_view(name)
	if name then
		local LC = MERequire(name)
		if LC and LC.update_view then
			LC.update_view()
		else
			libunity.LogW("update_view:"..name.."is nil")
		end
	else
		local UI_TOP = _G.PKG["ui/assetmgr"]
		if UI_TOP then UI_TOP.update_view() end
		local n = 0
		while true do
			local TopWnd = P.WNDStack:peek(n)
			if TopWnd and TopWnd:is_opened() then
				local pkgName = libngui.GetPkgName(TopWnd.go)
				local LC = pkgName and _G.PKG[pkgName]
				if LC and LC.update_view then LC.update_view() end
				n = n + 1
				else
					break
				end
			end
		end
	-- return va
end
--某个组的当前Toggle状态置为关闭
function P.uncheck_toggle(group)
	local current = NGUI.UIToggle.GetActiveToggle(group)
	if current then
		current.optionCanBeNone = true
		current.value = false
		current.optionCanBeNone = false
	end
	-- return va
end
function P.calc_scroll(Scroll,target,offset)
	local movement = tostring(Scroll.movement)
	local size = Scroll.bounds.size
	local panel = Scroll.panel
	local clipW,clipH = panel.width,panel.height
	if movement == "Horizontal" and size.x <= clipW then return end
	if movement == "Vertical" and size.y<=clipH then return end
	size = UE.Vector2(size.x,size.y)
	local maxOffset = size-UE.Vector2(clipW,clipH) + panel.clipSoftness *2
	local scrollTrans = Scroll.transform
	local targetPos = target.transform.position
	local origin = scrollTrans:InverseTransformPoint(UE.Vector3.zero)
	if movement == "Horizontal" then
		pos = pos - origin
		if offset then
			if pos.x > 0 then
				pos.x = pos.x + offset
			else
				pos.x = pos.x - offset
			end
		end
		if pos.x > 0 then
			pos.x = pos.x - clipW/2
			if pos.x < 0 then pos.x =0 end
		else
			pos.x = pos.x + clipW/2
			if pos.x>0 then pos.x = 0 end
		end
		pos.x = math.min(maxOffset.x,pos.x)
		pos.x = - pos.x
		pos.y = 0
	elseif movement == "Vertical" then
		pos = origin - pos
		if offset then
			if pos.y>0 then
				pos.y = pos.y+offset
			else
				pos.y=pos.y-offset
			end
		end
		if pos.y>0 then
			pos.y = pos.y-clipH/2
			if pos.y<0 then pos.y = 0 end
		else
			pos.y = pos.y+clipH/2
			if pos.y > 0 then pos.y = 0 end
		end
		pos.z = 0
		return pos,-pos.x/maxOffset.x,pos.y/maxOffset.y
	-- return va
end
function P.move_scroll(Scroll,target,offset)
	local pos = P.calc_scroll(Scroll,target,offset)
	Scroll:MoveRelative(pos)
	-- return va
end
--打开商店音效
function P.play_store_sound()
	local snd = "voice_store03"
	local rnd = math.random(1,100)
	if rnd > 90 then
		snd = "voice_store02"
	else
		snd = "voice_store01"
	end
	libunity.PlaySound("Sound/"..snd)

	-- return va
end
--进入战役音效，当音效引导存在时不播放
function P.play_story_sound(va)
	local snd = "main_campaignclick3"
	local rnd = math.random(1,100)
	if rnd > 90 then
		snd = "main_campaignclick1"
	else
		snd = "main_campaignclick2"
	end
	libunity.PlaySound("Sound/"..snd)
	-- return va
end
local goVersion
function P.display_version(visible)
	if not libunity.IsObject(goVersion) then
		local goDebug = libunity.Find("/UIROOT/Debug")
		libunity.NewChild(goDebug,"UI/LogPrint")
		goVersion = libunity.NewChild(goDebug,"UI/Version")
		local AppVer,AssetVer = libasset.GetVersion()
		libngui.SetText(GO(goVersion,"lbVer"),string.format(_G.ENV.TEXT.fmtVersion,AssetVer.version))
	end
	libunity.SetActive(goVersion,visible)
	-- return va

end
function P.blocking(duration,action)
	if duration and duration > 0 then
		local block = libunity.AddChild("/UIROOT","UI/TopmostBlock")
		libunity.Invoke(nil,function ()
			libunity.Destroy(block)
			action()
		end,duration)
	else
		action()
	end
	-- return va
end
function P.masking(duration,from,to,stay)
	if duration > 0 then
		local mask = libunity.FindGameObject(nil,"/UIROOT/TopmostMask") or
		libunity.DOTween("Color",mask,from,to,duration)
		if not stay then
			libunity.Destroy(mask,duration)
		end
	else
		libunity.Destroy("/UIROOT/TopmostMask")
	end

	-- return va
end
--加载背景图片
function P.load_bgtex(name,onLoaded,param)
	if type(onLoaded) ~= "function" then
		param = onLoaded
		onLoaded = function (a,o,p)
		libngui.SetTexture(p,o)
			-- return va
		end
	end
	if name and #name > 0 then
		local path = string.format("TexChapters/%s/%s",name,name)
		libasset.LoadAsync(UE.Texture.GetType(),path,true,onLoaded,param)
		libasset.LimitAsset("TexChapters",3)
	else
		onLoaded("",nil,param)end
	-- return va
end
--加载背景UI
function P.load_bgui(name,onLoaded,param)
	local root = libunity.FindGameObject(nil,"/UI Back")
	or libunity.AddChild(nil,"UI/UI Back")
	local Sub = libngui.GenLuaTable(GO(root),"Root"),"root")
P.load_bgtex(major,function (a,o,p)
	libngui.SetTexture(Sub.texTemp,Sub.texMajor.mainTexture)
	libngui.SetTexture(Sub.texMajor,o)
	libngui.BeginTween("TweenAlpha",Sub.texMajor,0,1,0.5)
end)
P.load_bgtex(minor,function (a,o,p)
	libngui.SetTexture(Sub.texMajor,o,true)
end)
	-- return va
end
--隐藏背景UI
function P.hide_bgui()
	local root = libunity.FindGameObject(nil,"/UI Back")
	if root then
		libngui.SetTexture(GO(root,"Root/spMajor"),nil)
		libngui.SetTexture(GO(root,"Root/spMinor"),nil)
		libunity.Destroy(root)
	end
	-- return va
end
--把背景移到第二UI
function P.move_away(root,back)
	local uiback = libunity.FindGameObject(nil,"/UI Back")
	 or libunity.AddChild(nil,"UI/UI Back")
	 local back = libunity.FindGameObject(root,back)
	 libunity.SetParent(back,GO(uiback,"Root"),false)
	 libunity.SetLayer(back,"UI2nd")
	 libngui.ReActive(back)
	-- return va
end
function P.move_back(root,back)
	local uiback = libunity.FindGameObject(nil,"/UI Back")
	if uiback then
		 back = libunity.FindGameObject(uiback,"Root/"..back)
		 libunity.SetActive(back,false)
		 libunity.SetParent(back,root,false)
	end

	-- return va
end

--播放UI特效
function P.play_uifx(fxName,parent,name,multiple)
	local fxPath = "UIFX"..fxName
	libasset.LoadAsync(UI.GameObjcet.GetType(),fxPath,true,function (a,o,p)
		if name == nil then name = fxName:getfile()end
		local fxGo = not multiple and libunity.FindGameObject(parent,name) or nil
		if fxGo == nil and o then libunity.NewChild(parent,o,name) end

		-- return va
	end)
	-- return va
end
function P.add_ink()
local ink = libunity.FindGameObject(nil,"/UIROOT/SubInk")
or libunity.AddChild("/UIROOT","UI/SubInk")
local tex = libunity.FindGameObject(ink,"SubPanel/tex_")
libngui.StopTween(tex)
libngui.SetDimension(tex,3000,3000)
return ink
	-- return va
end
--播放水墨出现效果
function P.plau_ink()
	local ink = P.add_ink()
	local tex = libunity.FindGameObject(ink,"SubPanel/tex_")
	libngui.BeginTween("TweenWidth",tex,3000,1,0.5)
	libngui.BeginTween("TweenHeight",tex,3000,1,0.5)
	libunity.Destroy(ink,0.5)

	-- return va
end
--[[下面是group界面生成方法。。。
	Grp是容器的额表，初始值
	{
	root = <GameObject>,Ent = {go =<GameObject>,...},
	}
	@reg 是为容器内每控件的触发函数赋值的函数
]]
local GroupDEF = {}
GroupDEF.__index = GroupDEF

do
--生成模板Ent
 function GroupDEF:init(prefab,entName)
 	if entName == nil then
 		entName = "ent"
 	end
 	local ent = libunity.FindGameObject(self.root,entName)
 	if ent == nil then
 		if type(prefab) == "string" then
 			prefab = "UI/"..prefab
 		end
 		ent = libunity.NewChild(self.root,prefab,entName)
 	end
 	local Ent = libngui.GenLuaTable(ent,"go")
 	if self.reg then self.reg(nil,Ent) end
 	libunity.SetActive(ent,false)
 	self.Ent = Ent
 	return Ent
 	-- return va
 end
 function GroupDEF:has(i)
 	return libunity.FindGameObject(self.root,self.Ent.go.name..i)
 	-- return va
 end
 --查找并返回一个存在deEnt
 function GroupDEF:get(i)
 	local go = libunity.FindGameObject(self.root,self.Ent.go.name..i)
 	if go then return libngui.GenLuaTable(go,"go") end
 	-- return va
 end
 function GroupDEF:gen(i)
 	local Ent,isNew = self.get(i),false
 	if Ent == nil then
 		local ent = self.Ent.go
 		local go = libunity.NewChild(self.root,ent,ent.name..i)
 		libunity.SetActive(go,true)
 		Ent = libngui.GenLuaTable(go,"go")
 		if self.reg then
 			self.reg(Ent,self.Ent)
 		end
 		isNew = true
 	else
 		libunity.SetActive(Ent.go,true)
 	end
 	-- return va
 end
 --生成并初始化多个Ent
 function GroupDEF:dup(b,cbf)
 	for i = 1, n do
 		local Ent,isNew = self:gen(i)
 		if cbf then cbf(i,Ent,isNew) end

 	end
 	local i,root,entName = n+1,self.root,self.Ent.go.name
 	while true do
 		local go = libunity.FindGameObject(root,entName..i)
 		if go then
 			libunity.SetActive(go,false)
 			i = i +1
 			else break end
 	end
 	-- return va
 end
 --遍历(索引=1，2，3，。。。)
 function GroupDEF:pairs(activeOnly)
 	local i = 0
 	if activeOnly then
 	else
 		return function ()
 			i = i+1
 			local v = self:get(i)
 			if v then return i,v else return nil,nil end
 		end
 	end
 	-- return va
 end
 --遍历不生成UI结构，仅遍历GameObject
 function GroupDEF:ipairs(activeOnly)
 	local entName = self.Ent.go.name
 	local parent = self.root.transform
 	local i = 0
 	if activeOnly then
 		return function ()
 			while true do
 				i = i + 1
 				local trans = parent:Find(entName..i)
 				if trans == nil then return end
 				local go = trans.gameObject
 				if go.activeSelf then return i,go end
 			end
 		end
 	else
 		return function ()
 			i = i + 1
 			local trans = parent:Find(entName..i)
 				if trans == nil then return end
 		end
 	-- return va
 end
 --初始化多个Ent
 function GroupDEF:view(List,cbf)
 	for i,v in self:pairs() do
 		local Obj = List[i]
 		if Obj then
 			libunity.SetActive(v.go,true)
 		else
 			libunity.SetActive(v.go,false)
 		end
 	end
 	-- return va
 end
 function GroupDEF:set_active(i,active)
 	local entName = self.Ent.go.name
 	local n = 0
 	if i then
 		libunity.SetActive(GO(self.root,entName..i),active)
 	else
 		local root = self.root.transform
 		for i = 1, root.childCount do
 			local ent = root:GetChild(i-1)
 			if ent.name:match(entName.."%d+$") then
 				n = n+1
 				libunity.SetActive(ent,active)
 			end
 		end
 	end

 	-- return va
 end
 function GroupDEF:show()
 	return self:set_active(nil,true)
 	-- return va
 end
 function GroupDEF:hide()
 	return self:set_active(nil,false)
 	-- return va
 end
 --仅显示特定数量的Ent
 function GroupDEF:limit(n)
 	local entName = self.Ent.go.name
 	local root = self.root.transform
 	for i = 1, root.childCount do
 		local ent = root:GetChild(i-1)
 		if ent.name:match(entName.."%d+$") then
 			libunity.SetActive(ent,i<=n)
 		end
 	end
 	-- return va
 end
 function GroupDEF:combine(Ent,prefab,subName)
 	local Sub = Ent[subName]
 	if Sub == nil then
 		local go = libunity.NewChild(Ent.go,prefab,subName)
 		libunity.SetEnable(go,"Collider",false)
 		Sub = libngui.GenLuaTable(go,"root")
 		Ent[subName] = Sub
 	end
 	Sub.__index = Sub
 	setmetatable(Ent,Sub)
 	-- return va
 end
 function GroupDEF:gen_combine(i,prefab,subName)
 	if subName == nil then subName ="Sub" end
 	local Ent,isNew = self:gen(i)
 	self:combine(Ent,"UI/"..prefab,subName)
 	return Ent,isNew
 	-- return va
 end
 --生成和合并初始化多个Ent
 function GroupDEF:dup_combine(n,prefab,cbf,subName)
 	if subName == nil then subName = "Sub" end
 	local GameObject = import("UnityEngine.GameObject")
 	local prefab = libasset.Load(UE.GameObject.GetType(),"UI/"..prefab)
 	self:dup(n,function (i,Ent,isNew)
 		self:combine(Ent,prefab,subName)
 		if cbf then cbf(i,Ent,isNew) end
 	end)
 	-- return va
 end
 --完成“UI组”嘞的额定义
 --生成组函数（自动），保存控件的生成方法在容器表内
 function P.make_group(Grp,reg)
 	Grp.reg = reg
 	return setmetatable(Grp,GroupDEF)
 	-- return va
 end
 --生成组函数（手动） 保存控件的额生成方法在容器表内
 function P.complete_group(prefab,Grp,reg,entName)
 	P.make_group(Grp,reg)
 	if prefab then Grp:init(prefab,entName) end
 	return Grp
 	-- return va
 end
 --动态创建一个UI控件
 function P.gen_prefab(prefab,Root,subName)
 	if subName == nil then subName = "Sub" end
 	local Sub = Root[subName]
 	if Sub == nil then
 		local root = Root.root or Root.go
 		local go = libunity.NewChild(root,"UI/"..prefab,subName)
 		Sub = libngui.GenLuaTable(go,"root")
 		Root[subName] = Sub
 	end
 	return Sub
 	-- return va
 end