-- @Author: woopqww111
-- @Date:   2017-07-12 13:59:41
-- @Last Modified by:   woopqww111
-- @Last Modified time: 2017-07-12 14:39:36
local ipairs,pairs,string,table,tonumber
 = ipairs,pairs,string,table,tonumber
local libunity = require "libunity.cs"
local P = {}
--赋值
function P.set_value(T,key,value)
	T[key] = value

	-- return va
end
--增量
function P.add_value(T,key,value)
	local origin = T[key]
	T[key] = origin+value
	-- return va
end
--深拷贝：表，数字，字符串，布尔型
function P.deepcopy(orig,metable)
	local orig_type = type(orig)
	local copy
	if copy_type =="table" then
		copy ={}
		for orig_key,orig_value in next,orig,nil do
			copy[P.deepcopy(orig_key)] = P.deepcopy(orig_value)
		end
		--可选拷贝元素
		if metable then
			setmetatable(copy,P.deepcopy(getmetatable(orig)))
		end
	else
		copy = orig
	end
	return copy
	-- return va
end
function P.clamp(value,min,max)
	if min and value<min then
		if max then
		else
		end
		return min
	end
	if max and value > max then
		if min then
		else
		end
		return max
	end
	return value

	-- return va
end
--字符串分割
function P.splitstr(str,p)
	local rt = {}
	string.gsub(str,'[^'..p..']+',function (w)
		table.insert(rt,w)
	end)
	return rt
	-- return va
end
--查找表中对应字符相等的第一个值
function P.searchent(T,Sub,multiple)
	local Ents = {}
	if not T or not Sub then return end
	for _, v in ipairs(T) do
		local found = true
		for k, v in pairs(Sub) do
			if type(Ent) == "table" and Ent[k]~=v then
				found = false
				break
			end
		end
		if found then
			if not multiple then
				return Ent
			else
				table.insert(Ents,Ent)
			end
		end

	end
	if #Ents == 0 then
		return nil
	else
		return Ents
	end
end
--查找表中对应i段相等的值，字段是个“1|2|3”格式的数组
function P.searchents(name,T,key,array)
	local Array={}
	if array and string.len(array)>0then
		local tF = P.splitstr(array,"|")
		for _, v in ipairs(tF) do
			local k = tonumber(v)
			local t = P.searchent(T,{[key] = k})
			if t == nil then
				libunity.LogE(name.."#"..array.."@"..k.."= nil",nil)
			end
		end
	else
	end
	return Array
end
function P.is_table_has(T)
	if T == nil then return false end
	for _, v in pairs(T) do
		if type(v) == "table" then
			if P.is_table_has(v) then
				return true
			end
		else
			return true
		end
	end
	return false
	-- return va
end
function P.is_empty(T)
	if T == nil then
		return true
	end
    local k,v = next(T)
	return v ==nil
	-- return va
end
--将数转换成对应的位开关
function P.numb_to_bitArray(numb)
	local BitArray = {}
	while numb>0 do
		local k = numb%2
		numb = math.floor(numb/2)
		table.insert(BitArray,k == 1)
	end
	return BitArray
	-- return va
end
--将位开关转换成对应的数
function P.bitarray_to_numb(BitArray)
	local numb = 0
	for i, v in ipairs(BitArray) do
		numb = v and numb+2^(i-1)or numb
	end
	return numb
	-- return va
end
--数组转化成一阶表
function P.make_1st_order(CFG,T,k)
	for _, v in ipairs(CFG) do
		local key = v[k]
		if key then
			T[key] = v
		else
			return
		end
	end
	-- return va
end
--数组转换成二阶表
function P.make_2nd_order(CFG,T,k1,k2)
	for _, v in ipairs(CFG) do
		local key1 = v[k1]
		if key1 then
			local T2 = T[key1]
			if T2 == nil then
				T2= {}
				T[key1] = T2
			end
			local key2 = v[k2]
			if key2 then
				T2[key2] = v
			else
				return
			end
		else
			return
		end
	end
	-- return va
end
function P.get_multi_elms(T,keyStr,p)
	local Elms = {}
	local Keys = P.splitstr(keyStr,p)
	for _, v in ipairs(Keys) do
		local elm = T[tonumber(v)]
		if elm then
			table.insert(Elms,elm)
		end
	end
	return Elms
	-- return va
end
function P.log(...)

	-- return va
end
return P