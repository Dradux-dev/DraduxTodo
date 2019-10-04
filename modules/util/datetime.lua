local DateTime = DraduxTodo:GetModule("Util"):NewModule("DateTime")

function DateTime:Now()
    local now = C_DateAndTime.GetCurrentCalendarTime()
    now.day = now.monthDay
    now.monthDay = nil

    return now
end

function DateTime:IsLess(a, b, order)
    order = order or {"year", "month", "day", "hour", "minute", "second"}

    for _, field in ipairs(order) do
        if a[field] and b[field] then
            if a[field] > b[field] then
                return false
            elseif a[field] < b[field] then
                return true
            end
        end
    end

    -- can't tell anything about both
    return false
end

function DateTime:IsGreater(a, b, order)
    order = order or {"year", "month", "day", "hour", "minute", "second"}

    for _, field in ipairs(order) do
        if a[field] and b[field] then
            if a[field] < b[field] then
                return false
            elseif a[field] > b[field] then
                return true
            end
        end
    end

    -- can't tell anything about it
    return false
end

function DateTime:IsEqual(a, b, order)
    order = order or {"year", "month", "day", "hour", "minute", "second"}

    for _, field in ipairs(order) do
        if a[field] and b[field] and a[field] ~= b[field] then
            return false
        end
    end

    return true
end

function DateTime:IsGreaterOrEqual(a, b, order)
    order = order or {"year", "month", "day", "hour", "minute", "second"}
    return DateTime:IsGreater(a, b, order) or DateTime:IsEqual(a, b, order)
end

function DateTime:IsLessOrEqual(a, b, order)
    order = order or {"year", "month", "day", "hour", "minute", "second"}
    return DateTime:IsLess(a, b, order) or DateTime:IsEqual(a, b, order)
end

function DateTime:Unequal(a, b, order)
    order = order or {"year", "month", "day", "hour", "minute", "second"}
    return not DateTime:IsEqual(a, b, order)
end

function DateTime:AddDays(date, days)
    local result = DateTime:Copy(date)
    local amount = days.value

    -- Days
    while amount > 0 do
        local isLeapYear = ((result.year % 4) == 0)
        local monthDays = DateTime:DaysOfMonth(result.month, isLeapYear)
        local remainingDays = monthDays - result.day

        if (remainingDays + 1) <= amount then
            result.day = 1
            result.month = result.month + 1

            if result.month > 12 then
                result.year = result.year + 1
                result.month = result.month - 12
            end

            amount = amount - (remainingDays + 1)
        else
            result.day = result.day + amount
            amount = 0
        end
    end

    return result
end

function DateTime:AddHours(date, hours)
    local result = DateTime:Copy(date)
    local amount = hours.value

    local days = math.floor(amount / 24)
    if days > 0 then
        amount = amount % 24
        result = DateTime:AddDays(result, DateTime:Days(days))
    end

    result.hour = (result.hour or 0) + amount
    if result.hour >= 24 then
        result.hour = result.hour - 24
        result = DateTime:AddDays(result, DateTime:Days(1))
    end

    return result
end

function DateTime:AddMinutes(date, minutes)
    local result = DateTime:Copy(date)
    local amount = minutes.value

    local hours = math.floor(amount / 24)
    if hours > 0 then
        amount = amount % 24
        result = DateTime:AddHours(result, DateTime:Hours(hours))
    end

    result.minutes = (result.minutes or 0) + amount
    if result.minutes >= 60 then
        result.minutes = result.minutes - 60
        result = DateTime:AddHours(result, DateTime:Hours(1))
    end

    return result
end

function DateTime:AddSeconds(date, seconds)
    local result = DateTime:Copy(date)
    local amount = seconds.value

    local minutes = math.floor(amount / 24)
    if minutes > 0 then
        amount = amount % 24
        result = DateTime:AddMinutes(result, DateTime:Minutes(minutes))
    end

    result.seconds = (result.seconds or 0) + amount
    if result.seconds >= 60 then
        result.seconds = result.seconds - 60
        result = DateTime:AddMinutes(result, DateTime:Minutes(1))
    end

    return result
end

function DateTime:Add(date, duration)
    local result = DateTime:Copy(date)

    local days = DateTime:Days(math.floor(duration:InDays()))
    if days.value > 0 then
        result = DateTime:AddDays(result, days)
    end

    local hours = DateTime:Hours(math.floor(duration:InHours() - days:InHours()))
    if hours.value > 0 then
        result = DateTime:AddHours(result, hours)
    end

    local minutes = DateTime:Minutes(math.floor(duration:InMinutes() - days:InMinutes() - hours:InMinutes()))
    if minutes.value > 0 then
        result = DateTime:AddMinutes(result, minutes)
    end

    local seconds = DateTime:Seconds(math.floor(duration:InSeconds() - days:InSeconds() - hours:InSeconds() - minutes:InSeconds()))
    if seconds.value > 0 then
        result = DateTime:AddSeconds(result, seconds)
    end

    return result
end

function DateTime:Duration(start, finish)
    local diff = {
        days = 0,
        month = 0,
        years = 0,
        hours = 0,
        minutes = 0,
    }

    if finish.year and start.year then
        diff.years = finish.year - start.year
        finish.year = nil
        start.year = nil

        if DateTime:IsLess(finish, start) then
            diff.years = diff.years - 1
        end
    end

    if finish.month and start.month then
        diff.month = finish.month - start.month
        finish.month = nil
        start.month = nil

        if DateTime:IsLess(finish, start) then
            diff.month = diff.month - 1
        end
    end

    if finish.day and start.day then
        diff.days = finish.day - start.day
        finish.day = nil
        start.day = nil

        if DateTime:IsLess(finish, start) then
            diff.day = diff.day - 1
        end
    end

    if finish.hour and start.hour then
        diff.hours = finish.hour - start.hour
        finish.hour = nil
        start.hour = nil

        if DateTime:IsLess(finish, start) then
            diff.hour = diff.hour - 1
        end

    end

    if finish.minute and start.minute then
        diff.minutes = finish.minute - start.minute
        finish.minute = nil
        start.minute = nil

        if DateTime:IsLess(finish, start) then
            diff.minutes = diff.minutes - 1
        end
    end

    local yearDays = 0
    for y = 1, diff.years do
        local year = start.year + y
        local isLeapYear = ((year % 4) == 0)
        yearDays = yearDays + DateTime:DaysPerYear(isLeapYear)
    end

    local monthDays = 0
    for m = 1, diff.month do
        local month = start.month + m
        local year = start.year
        if month > 12 then
            month = month - 12
            year = finish.year
        end

        local isLeapYear = ((year % 4) == 0)
        monthDays = monthDays + DateTime:DaysOfMonth(month, isLeapYear)
    end

    local years = DateTime:Days(yearDays)
    local month = DateTime:Days(monthDays)
    local days = DateTime:Days(diff.days)
    local hours = DateTime:Hours(diff.hours)
    local minutes = DateTime:Minutes(diff.minutes)

    local total = years:InMinutes() + month:InMinutes() + days:InMinutes() + hours:InMinutes() + minutes:InMinutes()
    return DateTime:Minutes(total)
end

function DateTime:DaysOfMonth(month, isLeapYear)
    -- Clamp
    if month < 1 then
        month = 1
    elseif month > 12 then
        month = 12
    end

    if month == 1 then
        return 31
    elseif month == 2 then
        if isLeapYear then
            return 29
        else
            return 28
        end
    elseif month == 3 then
        return 31
    elseif month == 4 then
        return 30
    elseif month == 5 then
        return 31
    elseif month == 6 then
        return 30
    elseif month == 7 then
        return 31
    elseif month == 8 then
        return 31
    elseif month == 9 then
        return 30
    elseif month == 10 then
        return 31
    elseif month == 11 then
        return 30
    elseif month == 12 then
        return 31
    end
end

function DateTime:DaysPerYear(isLeapYear)
    if isLeapYear then
        return 366
    else
        return 365
    end
end

function DateTime:CreateDuration(value, ratio)
    local t = {
        value = value,
        ratio = ratio
    }

    function t:Cast(ratio)
        return DateTime:CreateDuration(
            self.value * (1/self.ratio) * ratio,
            ratio
        )
    end

    function t:InSeconds()
        local duration = self:Cast(1)
        return duration.value
    end

    function t:InMinutes()
        local duration = self:Cast(1 / 60)
        return duration.value
    end

    function t:InHours()
        local duration = self:Cast(1 / 3600)
        return duration.value
    end

    function t:InDays()
        local duration = self:Cast(1 / 86400)
        return duration.value
    end

    function t:InWeeks()
        local duration = self:Cast(1 / 604800)
        return duration.value
    end

    return t
end

function DateTime:Seconds(value)
    return DateTime:CreateDuration(value, 1)
end

function DateTime:Minutes(value)
    return DateTime:CreateDuration(value, 1 / 60)
end

function DateTime:Hours(value)
    return DateTime:CreateDuration(value, 1 / 3600)
end

function DateTime:Days(value)
    return DateTime:CreateDuration(value, 1 / 86400)
end

function DateTime:Weeks(value)
    return DateTime:CreateDuration(value, 1 / 604800)
end

function DateTime:Copy(date)
    local copy = {}

    for k, v in pairs(date) do
        if type(v) == "table" then
            copy[k] = DateTime:Copy(v)
        else
            copy[k] = v
        end
    end

    return copy
end