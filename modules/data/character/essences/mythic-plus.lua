local MythicPlus = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("MythicPlus", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function MythicPlus:OnEnable()
    self:Super():OnEnable()

    self.type = "MythicPlus"
    self.itemID = 169491
    self.achievementID = 13781
    self.currencyID = 1718
    self.essenceItems = {
        168399,
        168558,
    }
    self.progress = {}
end

function MythicPlus:UpdateProgress()
    if self.rank == 0 then
        self.progress = {
            {
                name = "Mythic +4",
                actual = math.max(self:GetItemCount(self.essenceItems[1]), self:GetItemCount(self.essenceItems[2])),
                max = 1
            }
        }
    elseif self.rank == 1 then
        self.progress = {
            {
                name = "Mythic +7",
                actual = self:GetItemCount(self.essenceItems[2]),
                max = 1
            }
        }
    elseif self.rank == 2 then
        self.progress = {
            {
                name = GetItemInfo(self.itemID),
                actual = self:GetItemCount(self.itemID),
                max = 15
            }
        }
    elseif self.rank == 3 then
        self.progress = select(2, self:GetAchievement(self.achievementID))

        table.insert(self.progress, {
            name = GetCurrencyInfo(self.currencyID),
            actual = self:GetCurrency(self.currencyID),
            max = 800
        })
    else
        self.progress = {}
    end
end

function MythicPlus:AnimaOfLifeAndDeath()
    self.essenceID = 7
    return self
end

function MythicPlus:EssenceOfTheFocusingIris()
    self.essenceID = 5
    return self
end

function MythicPlus:LifeBindersInvocation()
    self.essenceID = 20
    return self
end