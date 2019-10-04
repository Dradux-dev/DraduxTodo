local RatedPvp = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("RatedPvp", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function RatedPvp:OnEnable()
    self:Super():OnEnable()

    self.type = "RatedPvp"
    self.essenceID = 32
    self.itemID = 169590
end

function RatedPvp:GetMaxRanking()
    local max = 0
    for i=1, 4 do
        local ranking = GetPersonalRatedInfo(i)

        if ranking > max then
            max = ranking
        end
    end

    return max
end

function RatedPvp:GetUpgradeItemCount()
    return GetItemCount(self.itemID, true)
end

function RatedPvp:BuildProgress(type, max)
    if type == "ranking" then
        return {
            {
                name = "Ranking",
                actual = self:GetMaxRanking(),
                max = max,
            }
        }
    elseif type == "item" then
        return {
            {
                name = GetItemInfo(self.itemID),
                actual = self:GetItemCount(self.itemID),
                max = max
            }
        }
    end

    return {}
end

function RatedPvp:UpdateProgress()
    if self.rank == 0 then
        self.progress = self:BuildProgress("ranking", 1000)
    elseif self.rank == 1 then
        self.progress = self:BuildProgress("ranking", 1400)
    elseif self.rank == 2 then
        self.progress = self:BuildProgress("item", 15)
    elseif self.rank == 3 then
        self.progress = self:BuildProgress("ranking", 2400)
    else
        self.progress = {}
    end
end

