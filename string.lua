-- @Author: woopqww111
-- @Date:   2017-07-12 11:37:20
-- @Last Modified by:   woopqww111
-- @Last Modified time: 2017-07-12 12:11:00
function string:trim()
	return self:gsub("^%s*(.-)%s*$","%1")
end
function string:split(p)
		local insert = table.insert
		local fields ={}
		local pattern = string.format("([^%s]+)",p)
		for w in self:gfind(pattern)  do
			insert(fields,w)
		end
		if p =="." then p = "%." end
		if (self:find(p)) == 1 then
			table.insert(fields,1,"")
		end
		return fields
end
function string:splitn(p)
	local insert, tonumber = table.insert,tonumber
	local fields = {}
	local pattern = string.format("([^%s]+)",p)
	for w in self:gfind(pattern)  do
			insert(fields,tonumber(w))
		end
		if p =="." then p = "%." end
		if (self:find(p)) == 1 then
			table.insert(fields,1,nil)
		end
		return fields
end
function string:splitgn(g,n)
	local insert = table.insert
	local Groups = self:split(g)
	local Ret = {}
	for _, v in ipairs(Groups) do
		local T = v:splitn(n)
		insert(Ret,{id = T[1],amount = T[2]})
	end
	return Ret

	-- return va
end
--获取目录名
function string:getdir()
	return self:match(".*/(.*)")
end
--获取文件名
function string:getfile()
	return self:match(".*/(.*)")
	-- return va
end
-- "需要数值"
function string.require()
	if curr<req then
		return string.format("[FF0000]%d[-]",req)
	else
		return tostring(req)
	end
	-- return va
end
-- 拥有数量/需要数量
function string.own_needs(own,needs,color,achieveColor)
	if own<needs then
		return string.format("[%s]%d/%d[-]",color or "FF0000",own,needs)
	else
		if achieveColor then
			return string.format("[%s]%d/%d[-]",achieveColor,own,needs)
		else
			return string.format("%d",needs)
		end
	end
	-- return va
end
function string.show_need(own,need,color,achieveColor)
	if own<needs then
		return string.format("[%s]%d[-]",color or "FF0000",need)
	else
		if achieveColor then
			return string.format("[%s]%d[-]",achieveColor,need)
		else
			return string.format("%d",need)
		end
	end
	-- return va
end
local Num2Text = {
	cn = function (num)
		local text
		if num>99999999 then
			text = math.floor(num/100000000+0.5).. _G.ENV.TEXT.nameNum100m
		elseif num>99999 then
			text = math.floor(num/10000+0.5) .. _G.ENV.TEXT.nameNum10k
		else
			text = tostring(num)
		end
		return text

		-- return va
	end,
	en = function (num)
		local text
		local libsystem = require "libsystem.cs"
		if num<1000000 then
			text = libsystem.StringFmt("{0:n0}",num)
		elseif num<1000000000 then
			text = libsystem.StringFmt("{0:n0}",math.ceil(num/1000))
		else
			text = libsystem.StringFmt("{0:n0}",math.ceil(num/1000000))
		end
		return text

		-- return va
	end,
}
Num2Text.tw = Num2Text.cn
function show_num(num)
	local num2text = Num2Text[_G.ENV.lang] or Num2Text.en
	return num2text(num)
	-- return va
end
function string.show_need_num(own,needs,color,achieveColor)
	local now = string.show_num(own)
	if own<needs then
		return string.format("[%s]%s[-]",color or "FF0000",now)
	else
		if achieveColor then
			return string.format("[%s]%s[-]",achieveColor,now)
		else
			return string.format("%s",now)
		end
	end
	-- return va
end