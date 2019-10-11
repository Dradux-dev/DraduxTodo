local OperationMechagon = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("OperationMechagon", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function OperationMechagon:Initialize()
    self:Super():Initialize()

    self.type = "OperationMechagon"
    self.essenceID = 22

    self.items = {
        rank1 = 168842,
        crate = 169610,
        cell = 169970,
        oscillator = 168832,
        rank3 = 169774
    }

    self.achievementID = 13789
end

function OperationMechagon:BuildProgressEntry(itemID, max)
    return {
        item = itemID,
        max = max
    }
end

function OperationMechagon:BuildProgress(list)
    local t = {}

    for _, entry in ipairs(list) do
        table.insert(t, {
            name = GetItemInfo(entry.item),
            actual = self:GetItemCount(entry.item),
            max = entry.max
        })
    end

    return t
end

function OperationMechagon:UpdateProgress()
    if self.rank == 0 then
        self.progress = self:BuildProgress({
            self:BuildProgressEntry(self.items.rank1, 1)
        })
    elseif self.rank == 1 then
        self.progress = self:BuildProgress({
            self:BuildProgressEntry(self.items.crate, 2),
            self:BuildProgressEntry(self.items.cell, 5),
            self:BuildProgressEntry(self.items.oscillator, 2)
        })
    elseif self.rank == 2 then
        self.progress = self:BuildProgress({
            self:BuildProgressEntry(self.items.rank3, 4)
        })
    elseif self.rank == 3 then
        self.progress = select(2, self:GetAchievment(self.achievementID))
    else
        self.progress = {}
    end
end

