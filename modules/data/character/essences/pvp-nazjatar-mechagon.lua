local PvpNazjatarMechagon = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("PvpNazjatarMechagon", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function PvpNazjatarMechagon:Initialize()
    self:Super():Initialize()

    self.type = "PvpNazjatarMechagon"
    self.essenceID = 15

    self.horde = {
        questID = 56433
    }

    self.alliance = {
        questID = 56128
    }

    self.achievements = {
        rank2 = 13623,
        rank4 = 13720
    }

    self.items = {
        call = 169614,
        commendation = 168802
    }
end

function PvpNazjatarMechagon:GetCommendations(max)
    return {
        name = GetItemInfo(self.items.commendation),
        actual = self:GetItemCount(self.items.commendation),
        max = max
    }
end

function PvpNazjatarMechagon:UpdateProgress()
    if self.rank == 0 then
        local faction = self:GetFactionData()
        local criteria = select(2, self:GetQuest(faction.questID))
        if table.getn(criteria)  >= 1 then
            self.progress = criteria
        else
            self.progress = {
                {
                    name = "Accept Quest",
                    actual = 0,
                    max = 1
                }
            }
        end
    elseif self.rank == 1 then
        self.progress = select(2, self:GetAchievement(self.achievements.rank2))
        table.insert(self.progress, self:GetCommendations(20))
    elseif self.rank == 2 then
        self.progress = {
            {
                name = GetItemInfo(self.items.call),
                actual = self:GetItemCount(self.items.call),
                max = 10
            },
            self:GetCommendations(50)
        }
    elseif self.rank == 3 then
        self.progress = select(2, self:GetAchievement(self.achievements.rank4))
    else
        self.progress = {}
    end
end

