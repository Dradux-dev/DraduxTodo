local EternalPalace = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("EternalPalace", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function EternalPalace:Initialize()
    self:Super():Initialize()

    self.type = "EternalPalace"
    self.itemID = 169694
    self.achievementID = 13733
end

function EternalPalace:BuildProgress(max)
    return {
        {
            name = GetItemInfo(self.itemID),
            actual = self:GetItemCount(self.itemID),
            max = max,
        }
    }
end

function EternalPalace:UpdateProgress()
    if self.rank == 0 then
        self.progress = self:BuildProgress(9)
    elseif self.rank == 1 then
        self.progress = self:BuildProgress(18)
    elseif self.rank == 2 then
        self.progress = self:BuildProgress(36)
    elseif self.rank == 3 then
        self.progress = select(2, self:GetAchievement(self.achievementID))
    else
        self.progress = {}
    end
end

function EternalPalace:AzerothsUndyingGift()
    self.essenceID = 2
    return self
end

function EternalPalace:CondensedLifeForce()
    self.essenceID = 14
    return self
end

function EternalPalace:VitalityConduit()
    self.essenceID = 21
    return self
end