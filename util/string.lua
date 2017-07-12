-- File Name : util/string.lua

-- 模式匹配中Lua支持的所有字符类
    -- .   任意字符
    -- %a  字母
    -- %c  控制字符
    -- %d  数字
    -- %l  小写字母
    -- %p  标点字符
    -- %s  空白符
    -- %u  大写字母
    -- %w  字母和数字
    -- %x  十六进制数字
    -- %z  代表0的字符
-- 上面字符类的大写形式表示小写所代表的集合的补集比如：
    -- %A 非字母的字符
    -- ...
-- 模式匹配中的特殊字符：
    -- (    )   .   %   +   -   *   ?   [   ^   $
    -- 其中%作为特殊字符的转义符，还可以用于所有的非字母的字符的转义符
-- 可以用中括号定义自己的字符类，称作“字符集(char-set)”：
    -- [%w_]    字母、数字和下划线
    -- [01]     二进制数字（即0或1）
    -- [0-9]    即%d
-- 在字符集(char-set)的开始处使用 '^' 表示其补集：[^0-7]

-- 模式修饰符
    -- + 匹配前一字符 1 次或多次，总是进行最长匹配
    -- * 匹配前一字符 0 次或多次，总是进行最长匹配
    -- - 匹配前一字符 0 次或多次，总是进行最短匹配
    -- ? 匹配前一字符0次或1次
    -- 比如"%a+"匹配一个或多个字符（单词）；"%d+"匹配一个或多个数字（整数）
-- 以 '^' 开头的模式只匹配目标串的开始部分，以 '$' 结尾的模式只匹配目 标串的结尾部分

-- '%b' 用来匹配对称的字符。常写为 '%bxy' ，x 和 y 是任意两个不同的字符；
-- x 作为 匹配的开始,y 作为匹配的结束。
-- 比如,'%b()' 匹配以 '(' 开始,以 ')' 结束的字符串

-- 捕获(Captures)
-- Capture是这样一种机制:可以使用模式串的一部分匹配目标串的一部分。将你想
-- 捕获的模式用圆括号括起来,就指定了一个capture。

function string:trim()
    return self:gsub("^%s*(.-)%s*$", "%1")
end

function string:split(p)
    local insert = table.insert
    local fields = {}
    local pattern = string.format("([^%s]+)", p)
    for w in self:gfind(pattern) do insert(fields, w) end
    --self:gsub(pattern, function(w) insert(fields, w) end)

    if p == "." then p = "%." end
    if (self:find(p)) == 1 then
        table.insert(fields, 1, "")
    end
    return fields
end

function string:splitn(p)
    local insert, tonumber = table.insert, tonumber
    local fields = {}
    local pattern = string.format("([^%s]+)", p)
    for w in self:gfind(pattern) do insert(fields, tonumber(w)) end
    --self:gsub(pattern, function(w) insert(fields, tonumber(w)) end)

    if p == "." then p = "%." end
    if (self:find(p)) == 1 then
        table.insert(fields, 1, nil)
    end

    return fields
end

-- 根据"2001:1|1002:2"格式的字符串生成一个表
-- {
--     { id = 2001, amount = 1 ,},
--     { id = 1002, amount = 2 ,},
-- }
function string:splitgn(g, n)
    local insert = table.insert
    local Groups = self:split(g)

    local Ret = {}
    for _,v in ipairs(Groups) do
        local T = v:splitn(n)
        insert(Ret, {id = T[1], amount = T[2]} )
    end

    return Ret
end

-- 获取目录名
function string:getdir()
    return self:match(".*/")
end

-- 获取文件名
function string:getfile()
    return self:match(".*/(.*)")
end

-- "需要数值"
function string.require(req, curr)
    if curr < req then
        return string.format("[FF0000]%d[-]", req)
    else
        return tostring(req)
    end
end

-- "<拥有数量>/<需要数量>"
function string.own_needs(own, needs, color, achieveColor)
    if own < needs then
        return string.format("[%s]%d/%d[-]", color or "FF0000", own, needs)
    else
        if achieveColor then
           return string.format("[%s]%d/%d[-]", achieveColor, own, needs)
        else
            return string.format("%d/%d", own, needs)
        end
    end
end

function string.show_need(own, need, color, achieveColor)
    if own < need then
        return string.format("[%s]%d[-]", color or "FF0000", need)
    else
        if achieveColor then
           return string.format("[%s]%d[-]", achieveColor, need)
        else
            return string.format("%d", need)
        end
    end
end


local Num2Text = {
    cn = function (num)
        local text
        if num > 99999999 then
            text = math.floor(num / 100000000 + 0.5) .. _G.ENV.TEXT.nameNum100m
        elseif num > 99999 then
            text = math.floor(num / 10000 + 0.5) .. _G.ENV.TEXT.nameNum10k
        else
            text = tostring(num)
        end
        return text
    end,

    en = function (num)
        local text
        local libsystem = require "libsystem.cs"
        if num < 1000000 then
            text = libsystem.StringFmt("{0:n0}", num)
        elseif num < 1000000000 then
            text = libsystem.StringFmt("{0:n0}K", math.ceil(num / 1000))
        else
            text = libsystem.StringFmt("{0:n0}M", math.ceil(num / 1000000))
        end
        return text
    end,
}
Num2Text.tw = Num2Text.cn

function string.show_num(num)
    local num2text = Num2Text[_G.ENV.lang] or Num2Text.en
    return num2text(num)
end

--将数字缩写并且查验数量对比进行颜色更改
function string.show_need_num(own, need, color, achieveColor)
    local now = string.show_num(own)
    if own < need then
        return string.format("[%s]%s[-]", color or "FF0000",now)
    else
        if achieveColor then
           return string.format("[%s]%s[-]", achieveColor, now)
        else
            return string.format("%s", now)
        end
    end
end
