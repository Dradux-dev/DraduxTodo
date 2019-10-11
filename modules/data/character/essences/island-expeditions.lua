local IslandExpedition = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("IslandExpedition", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function IslandExpedition:Initialize()
    self:Super():Initialize()

    self.type = "IslandExpedition"
    self.essenceID = 4

    self.items = {
        rank2 = 169687,
        rank3 = 169765,
        rank4 = 166883
    }

    self.horde = {
        questID = 53435
    }

    self.alliance = {
        questID = 53436
    }

end

function IslandExpedition:BuildProgress(itemID, max)
    return {
        {
            name = GetItemInfo(itemID),
            actual = self:GetItemCount(itemID),
            max = max,
        }
    }
end

function IslandExpedition:UpdateProgress()
    local faction = self:GetFactionData()

    if self.rank == 0 then
        self.progress = select(2, self:GetQuest(faction.questID))
    elseif self.rank == 1 then
        self.progress = self:BuildProgress(self.items.rank2, 15)
    elseif self.rank == 2 then
        self.progress = self:BuildProgress(self.items.rank3, 3)
    elseif self.rank == 3 then
        self.progress = self:BuildProgress(self.items.rank4, 1)
    else
        self.progress = {}
    end
end

