local BodyguardNazjatar = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("BodyguardNazjatar", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function BodyguardNazjatar:Initialize()
    self:Super():Initialize()

    self.type = "BodyguardNazjatar"
    self.essenceID = 27
    self.zoneID = 1355
    self.bodyguards = {
        {
            rank = 0,
            xp = 0,
        },
        {
            rank = 0,
            xp = 0,
        },
        {
            rank = 0,
            xp = 0,
        }
    }

    self.horde = {
        names = {"Neri", "Poen", "Vim"}
    }

    self.alliance = {
        names = {"Inowari", "Ori", "Akana"}
    }
end

function BodyguardNazjatar:GetBodyguardXP(index)
    local xpPerLevel = 300
    local bodyguard = self.bodyguards[index]

    return bodyguard.rank * xpPerLevel + bodyguard.xp
end

function BodyguardNazjatar:BuildProgress(max, type)
    local faction = self:GetFactionData()

    if type == "max" then
        local index = 0
        local xp = 0
        for i=1, table.getn(self.bodyguards or {}) do
            local currentXP = self:GetBodyguardXP(i)
            if index == 0 or currentXP > xp then
                index = i
                xp = currentXP
            end
        end

        return {
            {
                name = faction.names[index],
                actual = xp,
                max = max
            }
        }
    elseif type == "combined" then
        local xp = 0
        for i=1, table.getn(self.bodyguards or {}) do
            xp = xp + self:GetBodyguardXP(i)
        end

        return {
            {
                name = "Total",
                actual = xp,
                max = max
            }
        }
    elseif type == "all" then
        local t = {}

        for index, name in ipairs(faction.names) do
            table.insert(t, {
                name = name,
                actual = self:GetBodyguardXP(index),
                max = max
            })
        end

        return t
    end

    return {}
end

function BodyguardNazjatar:UpdateProgress()
    if self.rank == 0 then
        self.progress = self:BuildProgress(900, "max")
    elseif self.rank == 1 then
        self.progress = self:BuildProgress(3000, "combined")
    elseif self.rank == 2 then
        self.progress = self:BuildProgress(6000, "combined")
    elseif self.rank == 3 then
        self.progress = self:BuildProgress(9000, "all")
    else
        self.progress = {}
    end
end

function BodyguardNazjatar:ScanBodyguard(index, bar)
    local rankText = bar.overrideBarText
    local xpText = bar.barText

    rankText = rankText:gsub("[A-Za-z\\ ]*([0-9]*)", "%1")
    xpText = xpText:gsub("([0-9]*).*", "%1")
    local rank = tonumber(rankText:gsub("([0-9]*)", "%1") or "1")
    local xp = tonumber(xpText:gsub("([0-9]*)", "%1") or "0")

    self.bodyguards[index] = {
        rank = rank,
        xp = xp,
    }
end

function BodyguardNazjatar:ScanBodyguards()
    print("Scanning Bodyguards")
    local t = {WarboardQuestChoiceFrame.Option1, WarboardQuestChoiceFrame.Option2, WarboardQuestChoiceFrame.Option3}
    for index, option in ipairs(t) do
        local frames = option.WidgetContainer.widgetFrames
        for widgetID, widget in pairs(frames) do
            if widget.Bar then
                self:ScanBodyguard(index, widget.Bar)
            end
        end
    end
end

function BodyguardNazjatar:AsData()
    local t = self:Super():AsData()
    t.bodyguards = self.bodyguards

    return t
end

function BodyguardNazjatar:FromData(data)
    self:Super():FromData(data)

    self.bodyguards = {}
    for _, bodyguard in ipairs(data.bodyguards or {}) do
        table.insert(self.bodyguards, {
            rank = bodyguard.rank,
            xp = bodyguard.xp
        })
    end
end

function BodyguardNazjatar:QUEST_CHOICE_UPDATE()
    -- This event is always triggered, whenever the bodyguard choosing frame
    -- in nazjatar is displayed
    if self:GetZone() == self.zoneID then
        if WarboardQuestChoiceFrame and WarboardQuestChoiceFrame:IsShown() then
            self:ScanBodyguards()
        end
    end
end

function BodyguardNazjatar:QUEST_TURNED_IN(questID)
    -- ToDo: Add experience to follower, whenever a bodyguard quest is completed
end