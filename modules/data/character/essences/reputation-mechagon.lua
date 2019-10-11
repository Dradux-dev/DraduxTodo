local ReputationMechagon = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("ReputationMechagon", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function ReputationMechagon:Initialize()
    self:Super():Initialize()

    self.type = "ReputationMechagon"
    self.currencyID = 1721
    self.reputationID = 2391
    self.items = {
        crate = 169610,
        parts = 166846,
        oscillator = 168832,
        paragon = 170061
    }

    self.progress = {}
end

function ReputationMechagon:GetCrateCount()
    local partsPerCrate = 250
    local crates = self:GetItemCount(self.items.crate)
    local parts = self:GetItemCount(self.items.parts)

    return crates + math.floor(parts / partsPerCrate)
end

function ReputationMechagon:BuildProgress(maxReputation, crates, oscillators)
    local rep, max = self:GetReputation(self.reputationID)

    return {
        {
            name = "Reputation",
            actual = self:GetMaxDependedReputation(rep, max, maxReputation),
            max = maxReputation
        },
        {
            name = GetItemInfo(self.items.crate),
            actual = self:GetCrateCount(),
            max = crates
        },
        {
            name = GetItemInfo(self.items.oscillator),
            actual = self:GetItemCount(self.items.oscillator),
            max = oscillators
        }
    }
end

function ReputationMechagon:UpdateProgress()
    if not self.discounted then
        if self.rank == 0 then
            self.progress = self:BuildProgress(6000, 2, 2)
        elseif self.rank == 1 then
            self.progress = self:BuildProgress(12000, 20, 10)
        elseif self.rank == 2 then
            self.progress = self:BuildProgress(21000, 40, 25)
        elseif self.rank == 3 then
            self.progress = {
                {
                    name = GetItemInfo(self.items.paragon),
                    actual = self:GetItemCount(self.items.paragon),
                    max = 1
                }
            }
        else
            self.progress = {}
        end
    else
        if self.rank == 0 then
            self.progress = self:BuildProgress(6000, 2, 1)
        elseif self.rank == 1 then
            self.progress = self:BuildProgress(12000, 8, 4)
        elseif self.rank == 2 then
            self.progress = self:BuildProgress(21000, 40, 25)
        elseif self.rank == 3 then
            self.progress = {
                {
                    name = GetItemInfo(self.items.paragon),
                    actual = self:GetItemCount(self.items.paragon),
                    max = 1
                }
            }
        else
            self.progress = {}
        end
    end
end

function ReputationMechagon:NullificationDynamo()
    self.essenceID = 13
    return self
end

function ReputationMechagon:TheWellOfExistence()
    self.essenceID = 19
    return self
end

function ReputationMechagon:PurificationProtocol()
    self.essenceID = 6
    return self
end

