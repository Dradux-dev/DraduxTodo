local Essence = DraduxTodo:GetModule("Data"):NewModule("Essence", "AceEvent-3.0")

--[[
2 Azeroth's Undying Gift
3 Sphere of Suppression
4 Worldvein Resonance
5 Essence of the Focusing Iris
6 Purification Protocol
7 Anima of Life and Death
12 The Crucible of Flame
13 Nullification Dynamo
14 Condensed Life-Force
15 Ripple in Space
17 The Ever-Rising Tide
18 Artifice of Time
19 The Well of Existence
20 Life-Binder's Invocation
21 Vitality Conduit
22 Vision of Perfection
23 Blood of the Enemy
25 Aegis of the Deep
27 Memory of Lucid Dreams
28 The Unbound Force
32 Conflict and Strife
]]

function Essence:Initialize()
    self.rank = 1
    self.discounted = false
    self.progress = {}
end

function Essence:IsDisounted()
    return self.discounted
end

function Essence:GetRank()
    return self.rank
end

function Essence:GetActual()
    local t = {}
    for _, entry in ipairs(self.progress) do
        table.insert(t, entry.actual)
    end

    return t
end

function Essence:GetMax()
    local t = {}
    for _, entry in ipairs(self.progress) do
        table.insert(t, entry.max)
    end

    return t
end

function Essence:GetProgress()
    return self.progress
end

function Essence:GetFactionData()
    if UnitFactionGroup("player") == "Horde" then
        return self.horde or {}
    else
        return self.alliance or {}
    end
end

function Essence:GetReputation(reputationID, fix)
    if type(fix) == "nil" then
        fix = true
    end

    local function GetInfo(...)
        local id = select(14, ...)
        local actual = select(6, ...)
        local max = select(5, ...)
        local levelList = {3000, 6000, 12000, 21000}

        if fix then
            for _, level in ipairs(levelList) do
                if max <= level then
                    break
                end

                max = max - level
                actual = actual - level
            end
        end

        return id, actual, max
    end

    for factionIndex = 1, GetNumFactions() do
        local id, actual, max = GetInfo(GetFactionInfo(factionIndex))
        if id == reputationID then
            return actual, max
        end
    end

    return 0, 0
end

function Essence:GetMaxDependedReputation(actual, max, desired)

    if max < desired then
        return 0
    elseif max > desired then
        return desired
    end

    return actual
end

function Essence:GetItemCount(itemID)
    return GetItemCount(itemID, true)
end

function Essence:GetCurrency(currencyID)
    local amount = select(2, GetCurrencyInfo(currencyID))
    return amount
end

function Essence:GetQuest(questID)
    local function GetInfo(...)
        local text = select(1, ...)
        if not text then
            return
        end

        local type = select(2, ...)
        local completed = select(3, ...)
        local actual = select(4, ...)
        local max = select(5, ...)

        -- Fix stuff
        text = text:gsub("[0-9]*/[0-9]* (.*)", "%1")

        if type == "object" and not completed and actual == max then
            -- Required for "Storming the Battlefields" quest objective #1 "Win a PVP Island Expedition"
            -- 1: Win a PVP Island Expedition
            -- 2: object
            -- 3: false
            -- 4: 1
            -- 5: 1
            -- if Win a PVP Island Expedition is still open
            actual = 0
        end

        return text, actual, max
    end

    local completed = IsQuestFlaggedCompleted(questID)
    local objectives = {}

    for index = 1, 10 do
        local text, actual, max = GetInfo(GetQuestObjectiveInfo(questID, index, false))
        if text then
            table.insert(objectives, {
                name = text,
                actual = actual,
                max = max
            })
        end
    end

    return completed, objectives
end

function Essence:GetAchievement(achievementID)
    local function GetInfo(...)
        local name = select(1, ...)
        local actual = select(4, ...)
        local max = select(5, ...)

        return name, actual, max
    end

    local completed = select(4, GetAchievementInfo(achievementID))
    local objectives = {}

    for criteriaID = 1, GetAchievementNumCriteria(achievementID) do
        local name, actual, max = GetInfo(GetAchievementCriteriaInfo(achievementID, criteriaID))
        table.insert(objectives, {
            name = name,
            actual = actual,
            max = max
        })
    end

    return completed, objectives
end

function Essence:GetVariable(path)
    local name = path[1]
    table.remove(path, 1)

    if name == "progress" then
        local current = self.progress
        while #path > 1 and current do
            local element = path[1]
            table.remove(path, 1)
            current = current[element]
        end

        return current
    else
        return self[name]
    end
end

function Essence:GetVariables()
    local t = {
        name = self:GetName(),
        display = self:GetName(),
        type = "group",
        value = {
            {
                name = "rank",
                display = "Rank",
                type = "number",
                value = self.rank,
                readonly = true
            },
            {
                name = "discounted",
                display = "Discounted",
                type = "flag",
                value = self.discounted,
                readonly = true
            },
            {
                name = "progress",
                display = "Progress",
                type = "group",
                value = {}
            }
        }
    }

    for index, entry in ipairs(self.progress) do
        table.insert(t.value[3].value, {
            name = index,
            display = "" .. index,
            type = "group",
            value = {
                {
                    name = "name",
                    display = "Name",
                    type = "string",
                    value = entry.name,
                    readonly = true
                },
                {
                    name = "actual",
                    display = "Actual",
                    type = "number",
                    value = entry.actual,
                    readonly = true
                },
                {
                    name = "max",
                    display = "Max",
                    type = "number",
                    value = entry.max,
                    readonly = true
                }
            }
        })
    end

    return t
end

function Essence:Scan()
    for _, data in ipairs(C_AzeriteEssence.GetEssences()) do
        if self:IsCorrectData(data) then
            self:LoadApiData(data)
            self:UpdateProgress()
        end
    end
end

function Essence:IsCorrectData(data)
    return data.ID == self.essenceID
end

function Essence:LoadApiData(data)

    self.rank = data.rank
end

function Essence:AsData()
    return {
        rank = self.rank,
        discounted = self.discounted,
        progress = self.progress
    }
end

function Essence:FromData(data)
    self.rank = data.rank
    self.discounted = data.discounted

    self.progress = {}
    for _, entry in pairs(data.progress) do
        local t = {}
        for k, v in pairs(entry) do
            t[k] = v
        end

        table.insert(self.progress, t)
    end
end

function Essence:Super()
    local super = {}

    local t = DraduxTodo:GetModule("Data"):GetModule("Essence")
    for k,v in pairs(t) do
        if type(v) == "function" then
            super[k] = function(...)
                return t[k](self, ...)
            end
        end
    end

    return super
end

function Essence:UpdateProgress()

end

function Essence:Log()
    return DraduxTodo:GetModule("Util"):GetModule("Log")
end

function Essence:EnableDiscount()
    self.discounted = true
end

function Essence:DisableDiscount()
    self.discounted = false
end