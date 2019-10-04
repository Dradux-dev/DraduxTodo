local Neck = DraduxTodo:GetModule("Data")   :NewModule("Neck", "AceEvent-3.0")

local function GetEssenceModule(self, name, baseName)
    return self:NewModule(name, DraduxTodo:GetModule("Data"):GetModule("Essence"):GetModule(baseName), "AceEvent-3.0")
end

function Neck:OnEnable()
    self.level = 1

    -- Reputation Nazjatar
    self.aegisOfTheDeep = GetEssenceModule(self, "AegisOfTheDeep", "ReputationNazjatar"):AegisOfTheDeep()
    self.theUnboundForce = GetEssenceModule(self, "TheUnboundForce", "ReputationNazjatar"):TheUnboundForce()
    self.theEverRisingTide = GetEssenceModule(self, "TheEverRisingTide", "ReputationNazjatar"):TheEverRisingTide()

    -- Mythic+
    self.animaOfLifeAndDeath = GetEssenceModule(self, "AnimaOfLifeAndDeath", "MythicPlus"):AnimaOfLifeAndDeath()
    self.essenceOfTheFocusingIris = GetEssenceModule(self, "EssenceOfTheFocusingIris", "MythicPlus"):EssenceOfTheFocusingIris()
    self.lifeBindersInvocation = GetEssenceModule(self, "LifeBindersInvocation", "MythicPlus"):LifeBindersInvocation()

    -- Pvp
    self.sphereOfSuppression = GetEssenceModule(self, "SphereOfSuppression", "Pvp"):SphereOfSuppression()
    self.bloodOfTheEnemy = GetEssenceModule(self, "BloodOfTheEnemy", "Pvp"):BloodOfTheEnemy()
    self.artificeTime = GetEssenceModule(self, "ArtificeTime", "Pvp"):ArtificeTime()

    self.conflictAndStrife = GetEssenceModule(self, "ConflictAndStrife", "RatedPvp")
end

function Neck:GetVariable(path)
    local name = path[1]
    table.remove(path, 1)

    if self.modules[name] then
        return self.modules[name]:GetVariable(path)
    else
        return self[name]
    end


end

function Neck:Scan()
    local maxRankPerType = {}
    self.level = C_AzeriteItem.GetPowerLevel(C_AzeriteItem.FindActiveAzeriteItem())
    for _, module in ipairs(self.orderedModules) do
        if module["Scan"] then
            module:Scan()
        end

        maxRankPerType[module.type] = math.max(maxRankPerType[module.type] or 0, module.rank)
    end


    for _, module in ipairs(self.orderedModules) do
        if module.rank < (maxRankPerType[module.type] or 0) then
            module:EnableDiscount()
        else
            module:DisableDiscount()
        end
    end
end

function Neck:FromData(data)
    self.level = data.level
end

function Neck:AsData()
    local t = {
        level = self.level,
        essences = {}
    }

    for name, module in pairs(self.modules) do
        t.essences[name] = module:AsData()
    end

    return t
end