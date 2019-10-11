local ReputationNazjatar = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("ReputationNazjatar", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function ReputationNazjatar:Initialize()
    self:Super():Initialize()

    self.type = "ReputationNazjatar"
    self.currencyID = 1721

    self.horde = {
        reputationID = 2373,
        itemID = 169940
    }

    self.alliance = {
        reputationID = 2400,
        itemID = 169939
    }

    self.progress = {}
end

function ReputationNazjatar:BuildProgress(maxReputation, maxItems)
    local faction = self:GetFactionData()
    local rep, max = self:GetReputation(faction.reputationID)
    local items = self:GetCurrency(self.currencyID)

    return {
        {
            name = "Reputation",
            actual = self:GetMaxDependedReputation(rep, max, maxReputation),
            max = maxReputation
        },
        {
            name = GetCurrencyInfo(self.currencyID),
            actual = items,
            max = maxItems
        }
    }
end

function ReputationNazjatar:UpdateProgress()
    if self.rank == 0 then
        self.progress = self:BuildProgress(6000, 10)
    elseif self.rank == 1 then
        self.progress = self:BuildProgress(12000, 25)
    elseif self.rank == 2 then
        self.progress = self:BuildProgress(21000, 50)
    elseif self.rank == 3 then
        local faction = self:GetFactionData()

        self.progress = {
            {
                name = GetItemInfo(faction.ItemID),
                actual = self:GetItemCount(faction.itemID),
                max = 1
            }
        }
    else
        self.progress = {}
    end
end

function ReputationNazjatar:AegisOfTheDeep()
    self.essenceID = 25
    return self
end

function ReputationNazjatar:TheEverRisingTide()
    self.essenceID = 17
    return self
end

function ReputationNazjatar:TheUnboundForce()
    self.essenceID = 28
    return self
end

