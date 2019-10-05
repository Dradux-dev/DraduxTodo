local Pvp = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("Pvp", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function Pvp:Initialize()
    self:Super():Initialize()

    self.type = "Pvp"
    self.horde = {
        questID = 56500,
    }

    self.alliance = {
        questID = 56499
    }

    self.itemID = 137642
    self.achievementIdRank2 = 13701
    self.achievementIdRank3 = 13702
    self.achievementIdRank4 = 13703

    self.progress = {}
end

function Pvp:UpdateProgress()
    local faction = self:GetFactionData()

    if self.rank == 0 then
        if not self.discounted then
            self.progress = select(2, self:GetQuest(faction.questID))
        else
            self.progress = {
                {
                    name = GetItemInfo(self.itemID),
                    actual = self:GetItemCount(self.itemID),
                    max = 2
                }
            }
        end
    elseif self.rank == 1 then
        self.progress = select(2, self:GetAchievement(self.achievementIdRank2))
        table.insert(self.progress, {
            name = GetItemInfo(self.itemID),
            actual = self:GetItemCount(self.itemID),
            max = 25
        })
    elseif self.rank == 2 then
        self.progress = select(2, self:GetAchievement(self.achievementIdRank3))
        table.insert(self.progress, {
            name = GetItemInfo(self.itemID),
            actual = self:GetItemCount(self.itemID),
            max = 35
        })
    elseif self.rank == 3 then
        self.progress = select(2, self:GetAchievement(self.achievementIdRank4))
    else
        self.progress = {}
    end
end

function Pvp:SphereOfSuppression()
    self.essenceID = 3
    return self
end

function Pvp:BloodOfTheEnemy()
    self.essenceID = 23
    return self
end

function Pvp:ArtificeOfTime()
    self.essenceID = 18
    return self
end