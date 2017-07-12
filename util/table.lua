-- @Author: woopqww111
-- @Date:   2017-07-12 13:12:13
-- @Last Modified by:   woopqww111
-- @Last Modified time: 2017-07-12 13:39:20
table.unpack = unpack
function table.void(T)
	if T == nil then
		return true
	else
		local k,v = next(T)
		return v == nil
	end
	-- return va
end
function table.hollow(T)
	if T == nil then
		return true
	end
	for _, v in pairs(T) do
		if type(v) == "table" then
			if not table.hollow(v) then return false end
		else
			return false
		end
	end
	return true
	-- return va
end
function table.clear(T)
	for k, v in pairs(T) do
		T[k] = nil
	end

	-- return va
end
--计算表中的元素数量
function table.count(T)
	local n = 0
	if T then
		for k, v in pairs(T) do
			n = n+1
		end
	end
	return n
end
--获取键值未key的值
function table.take(T,key)
	local Sub = T[key]
	T[key] = nil
	return Sub
	-- return va
end
function table.toarray(T,sort)
	local Array = {}
	for _, v in pairs(T) do
		table.insert(Array,v)
	end
	if sort then table.sort(Array,sort) end

end
--key 和value 互换
function table.swapkv(T)
	local N = {}
	for k, v in pairs(T) do
		N[v] = k
	end
	return N
	-- return va
end
function table.tomap(Array,key)
	local Map = {}
	for _, v in ipairs(Array) do
		Map[v[key]] = v
	end
	return Map
	-- return va
end
function table.arrvalue(Arr)
	local Dst = {}
	for _, v in pairs(Arr) do
		Dst[v] = true
	end
	return Dst
	-- return va
end
--表深拷贝
function table.dup(orig,metable)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy ={}
		for orig_key,orig_value in next,orig,nil do
			copy[table.dup(orig_key)] = table.dup(orig_value)
		end
		--可选拷贝元素
		if metable then
			setmetatable(copy,table.dup(getmetatable(orig)))
		end
	else
		copy = orig
	end
	return copy
	-- return va
end
function table.match(T,Sub,multiple)
	local Ents = {}
	for _, Ent in pairs(T) do
		local found = true
		for k, v in pairs(Sub) do
			if Ent[k] ~= v then
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
	-- return va
end
function table.has(Array,value)
	for i, v in ipairs(Array) do
		if v== value then
			return i,v
		end
	end

	-- return va
end
function table.contains()
	for k,v in pairs(Dict) do
		if v == value then
			return k,v
		end
	end
	-- return va
end
--根据整数位置生成一个布尔数组(我觉得这就是个转成二进制的计算而已)
function table.num2bools(numb)
	local Array = {}
	while numb>0 do
		local k = numb%2
		numb = math.floor(numb/2)
		table.insert(Array,k == 1)
	end
	return Array
	-- return va
end
function table.insert_once(Array,elm)
	for _, v in ipairs(Array) do
		if v == elm then
			return
		end
	end
	table.insert(Array,elm)
	-- return va
end
function table.remove_elm(Array,elm)
	if not Array then return end
	local i,_ = table.has(Array,elm)
	if i then table.remove(Array,i) end
	-- return va
end
function table.get_base_data(this,Lib,tag)
	local Base = this.Base
	if Base == nil then
		Base = Lib[this.id]
		if Base == nil then
			libunity.LogE("{0}#{1}无配置数据",tag,this.id)
		end
		this.Base = Base
	end
	return Base
	-- return va
end
