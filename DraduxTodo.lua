local StdUi = LibStub("StdUi")
local DraduxTodo = _G["DraduxTodo"]

SLASH_DRADUXTODO1 = "/dtodo"

function SlashCmdList.DRADUXTODO(cmd, editbox)
    -- DraduxTodo:ToggleInterface()
end

local defaultSavedVars = {}

-- Init
function DraduxTodo:OnInitialize()
    self:RegisterEvent("ADDON_LOADED")
end

function DraduxTodo:ADDON_LOADED(event, addonName)
    if event == "ADDON_LOADED" and addonName == "DraduxTodo" then
        self.db = LibStub("AceDB-3.0"):New("DraduxTodoDB", defaultSavedVars)

        for moduleName, module in pairs(self.modules) do
            module:Enable()
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end

function DraduxTodo:ToggleInterface()
    if not self.window then
        -- Create Frame
    end

    ToggleFrame(self.window)
end

function DraduxTodo:GetDB()
    if not DraduxTodo.db then
        DraduxTodo.db = LibStub("AceDB-3.0"):New("DraduxTodoDB", defaultSavedVars)
    end

    return DraduxTodo.db.profile
end

function DraduxTodo:ReleaseContent()
    for _, frame in ipairs(self.window.content.children) do
        frame:Hide()
    end
end

function DraduxTodo:GetContent()
    if not self.window then
        return
    end

    return self.window.content
end

function DraduxTodo:GetSortedKeySet(t, func)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys, k)
    end

    table.sort(keys, func)

    return keys
end

function DraduxTodo:SplitDate(date)
    return {
        day = date % 100,
        month = math.floor(date / 100) % 100,
        year = math.floor(date / 10000)
    }
end

function DraduxTodo:PackDate(date)
    return (date.year * 10000) + (date.month * 100) + date.day
end

function DraduxTodo:SplitTime(time)
    return {
        hours = math.floor(time / 100),
        minutes = time % 100
    }
end

function DraduxTodo:PackTime(time)
    return (time.hours * 100) + time.minutes
end

function DraduxTodo:GetDuration(start_time, end_time)
    local duration = 0

    if end_time < start_time then
        end_time = end_time + 2400
    end

    local s = DraduxTodo:SplitTime(start_time)
    local e = DraduxTodo:SplitTime(end_time)

    while(DraduxTodo:PackTime(s) < DraduxTodo:PackTime(e)) do
        if s.hours < e.hours then
            duration = duration + (60 - s.minutes)
            s.minutes = 0
            s.hours = s.hours + 1
        else
            duration = duration + (e.minutes - s.minutes)
            s.minutes = e.minutes
            s.hours = e.hours
        end
    end

    return duration
end

function DraduxTodo:CreateUID(type)
    local name = UnitName("player")
    local today = date("%d%m%y")
    local now = date("%H%M%S")

    return string.format("%s-%s-%s-%s", (type or "Generic"), name, today, now)
end

function DraduxTodo:Today()
    return tonumber(date("%Y%m%d"))
end

function DraduxTodo:GetUserPermission(parent, options)
    if not self.ask then
        local ask = StdUi:Window(parent, "", 360, 140)
        self.ask = ask
        ask:SetFrameLevel(100)

        local yes = StdUi:Button(ask, 80, 24, "")
        ask.yes = yes
        yes:SetPoint("RIGHT", ask, "CENTER", -5, 0)

        local no = StdUi:Button(ask, 80, 24, "")
        ask.no = no
        no:SetPoint("LEFT", ask, "CENTER", 5, 0)

        ask:Hide()
    end

    self.ask:SetParent(parent)
    self.ask:SetWindowTitle(options.title or "Are you sure?")
    self.ask.yes:SetText(options.yes or "Yes")
    self.ask.no:SetText(options.no or "No")

    self.ask.yes:SetScript("OnClick", function()
        if options.callbackYes then
            options.callbackYes()
        end
        self.ask:Hide()
    end)

    self.ask.no:SetScript("OnClick", function()
        if options.callbackNo then
            options.callbackNo()
        end
        self.ask:Hide()
    end)
    self.ask:SetPoint("CENTER")
    self.ask:Show()
end

function DraduxTodo:FindInTable(t, needle, assosiative)
    local result = {}

    if not assosiative then
        for pos, value in ipairs(t) do
            if value == needle then
                table.insert(result, pos)
            end
        end
    else
        for pos, value in pairs(t) do
            if value == needle then
                table.insert(result, pos)
            end
        end
    end

    if #result == 0 then
        return
    elseif #result == 1 then
        return result[1]
    end

    return result
end

function DraduxTodo:FindInTableIf(t, callback, assosiative)
    local result = {}

    if not assosiative then
        for pos, value in ipairs(t) do
            if callback(value) then
                table.insert(result, pos)
            end
        end
    else
        for pos, value in pairs(t) do
            if callback(value) then
                table.insert(result, pos)
            end
        end
    end

    if #result == 0 then
        return
    elseif #result == 1 then
        return result[1]
    end

    return result
end

function DraduxTodo:GetFirstKey(t)
    for k, _ in pairs(t) do
        return k
    end
end

function DraduxTodo:IterateGroupMembers(forceParty)
    local raid = IsInRaid()
    local party = IsInGroup()
    local raidMember = GetNumGroupMembers()
    local partyMember = GetNumSubgroupMembers()
    local i = 1
    return function()
        local ret
        if not raid and not party and i == 1 then
            ret = 'player'
        elseif not forceParty and raid then
            if i <= raidMember then
                ret = "raid" .. i
            end
        elseif forceParty or party then
            if i == 1 then
                ret = "player"
            elseif i <= partyMember then
                ret = "party" .. (i - 1)
            end
        end

        i = i + 1
        return ret
    end
end