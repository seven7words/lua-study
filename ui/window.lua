-- @Author: woopqww111
-- @Date:   2017-07-12 15:04:47
-- @Last Modified by:   woopqww111
-- @Last Modified time: 2017-07-13 14:49:15
local ipairs,pairs,tostring,setmetatable
 = ipairs,pairs,tostring,setmetatable
local libunity = require "libunity.cs"
local libngui = require "libngui.cs"
local OBJDEF = {}
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	if self then
		return string.format("[Window:%s@%d]",self.path,self.depth)
	else
		return "[WindowDEF]"
	end
end
local function coro_pop_wnd(Wnd)
	if Wnd:is_opened() then
		local pkgName = libngui.GetPkgName(Wnd.go)
		local LC = pkgName and _G.PKG[pkgName]
		if LC and LC.update_view then
			LC.update_view()
		end
	end
end
function OBJDEF:new(path,depth,go)
	local self ={
		path = path,
		depth = depth,
		go = go,
		anim = false,
	}
	return setmetatable(self,OBJDEF)
	-- return va
end
function OBJDEF:is_name(wndName)
	return self.path == "UI/"..wndName
	-- return va
end
function OBJDEF:is_opened()
	return libunity.IsActive(self.go)
	-- return va
end
function OBJDEF:open()
	if not self:is_opened() then
		if self.Cached then
			local UI_DATA = _G.PKG["datamgr/uidata"]
			for k, v in pairs(self.Cached) do
				UI_DATA.set(k,v)
			end
			self.Cached = nil
		end
		self.go = libngui.Create(self.path,self.depth)
		if self.on_open then
			self.on_open()
		end
	end
	libngui.Invoke(nil,coro_pop_wnd,nil,self)
	return self.go
	-- return va
end
function OBJDEF:close(delay)
	if self:is_opened() then
		if self.on_close then
			self.on_close()
		end
		libunity.Destroy(self.go,delay)
	end
	-- return va
end
function OBJDEF:set_event(on_open,on_close)
	self.on_open,self.on_close = on_open,on_close
	return self
	-- return va
end
function OBJDEF:set_cached_data(key,value)
	local UI_DATA = _G.PKG["datamgr/uidata"]
	local Cached = table.need(self,"Cached")
	Cached[key] = value or UI_DATA.get(key)
	-- return va
end
return OBJDEF