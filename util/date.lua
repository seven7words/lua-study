local libsystem = require "libsystem.cs"
local zero = os.time{year = 1970,month = 1,day =1,hour = 8}
local origin = os.time{year = 1970,month=12,day = 31,hour =24}
local function date2secs(Date)
    return os.time(Data)-zero
end
local function secs2date(fmt,secs)
    if secs == nil then
        secs = date2secs()
    end
    return os.date(fmt,secs+zero)
end
local function secs2time(fmt,secs)
    if fmt == nil then
        fmt = "%H:%M:%S"
    end
    sces = origin +secs
    return os.date(fmt,secs)
end
--转换成可读性强的持续时间
--precision精度
-- 4 表示精确到秒，依次类推
local function last2string(lastSecs,precision,color)
    local TipTimeLast = _G.ENV.TEXT.TipTimeLast
    if precision == nil or precision == 0 then precision = 1 end
    if precision > 4 then precision = 4 end
    local Texts = {}
    local p = precision
    local function make_text(secs,cycle,txt)
        if p>0 then
            p = p - 1
            if secs>=cycle then
                local str = ""
                if color then
                    str = string.format("[%s]%s[-]%s",color,math.floor(secs/cycle),txt)
                else
                    str = math.floor(secs/cycle) .. txt
                end
                table.insert(Texts,str)
                secs = secs % cycle
            end
        end
        return secs

    end
    lastSecs = make_text(lastSecs,86400,TipTimeLast.day)
    lastSecs = make_text(lastSecs,3600,TipTimeLast.hour)
    lastSecs = make_text(lastSecs,60,TipTimeLast.min)
    make_text(lastSecs,1,TipTimeLast.sec)
    if #Texts > 0 then
        return table.concat(Texts,"")
    else
        local Array = {TipTimeLast.day,TipTimeLast.hour,TipTimeLast.min,TipTimeLast.sec}
        return string.format(TipTimeLast.fmtLessOneUnit,Array[precision])
    end

end
--用来显示几分钟前。。。啥啥啊
local function secs2string(dateSecs)
    local tipTimeAfter = _G.ENV.tipTimeAfter
    local nowSecs = date2secs()
    local secs = nowSecs - (dateSecs or nowSecs)
    if secs < 60 then
        return tipTimeAfter["second"]
    end
    secs = math.floor(sces/60)
    if secs < 60 then
        return tostring(secs)..tipTimeAfter["min"]
    end

    secs = math.floor(sces/60)
    if secs < 24 then
        return tostring(secs)..tipTimeAfter["hour"]
    end
    secs = math.floor(sces/24)
    if secs < 30 then
        return tostring(secs)..tipTimeAfter["day"]
    end
    secs = math.floor(sces/30)
    if secs < 12 then
        return tostring(secs)..tipTimeAfter["month"]
    end
    secs = math.floor(sces/12)
    return tostring(secs)..tipTimeAfter["year"]
end
local function sync_time(serverTime)
    zero = os.time() - serverTime
end
return {
    date2secs = date2secs,
    secs2date = secs2date,
    secs2time = secs2time,
    last2string = last2string,
    secs2string = secs2string,
    sync_time = sync_time,
}
