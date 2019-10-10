local Neck = DraduxTodo:GetModule("Data")   :NewModule("Neck", "AceEvent-3.0")

local function GetEssenceModule(self, name, baseName)
    return self:NewModule(name, DraduxTodo:GetModule("Data"):GetModule("Essence"):GetModule(baseName), "AceEvent-3.0")
end

function Neck:Initialize()
    self.level = 1

    -- Neck Level
    self.theCrucibleOfFlame = GetEssenceModule(self, "TheCrucibleOfFlame", "NeckLevel")

    -- Reputation Nazjatar
    self.aegisOfTheDeep = GetEssenceModule(self, "AegisOfTheDeep", "ReputationNazjatar"):AegisOfTheDeep()
    self.theUnboundForce = GetEssenceModule(self, "TheUnboundForce", "ReputationNazjatar"):TheUnboundForce()
    self.theEverRisingTide = GetEssenceModule(self, "TheEverRisingTide", "ReputationNazjatar"):TheEverRisingTide()

    -- Bodyguard Nazjatar
    self.memoryOfLucidDreams = GetEssenceModule(self, "MemoryOfLucidDreams", "BodyguardNazjatar")

    -- Mythic+
    self.animaOfLifeAndDeath = GetEssenceModule(self, "AnimaOfLifeAndDeath", "MythicPlus"):AnimaOfLifeAndDeath()
    self.essenceOfTheFocusingIris = GetEssenceModule(self, "EssenceOfTheFocusingIris", "MythicPlus"):EssenceOfTheFocusingIris()
    self.lifeBindersInvocation = GetEssenceModule(self, "LifeBindersInvocation", "MythicPlus"):LifeBindersInvocation()

    -- PvP
    self.sphereOfSuppression = GetEssenceModule(self, "SphereOfSuppression", "Pvp"):SphereOfSuppression()
    self.bloodOfTheEnemy = GetEssenceModule(self, "BloodOfTheEnemy", "Pvp"):BloodOfTheEnemy()
    self.artificeOfTime = GetEssenceModule(self, "ArtificeOfTime", "Pvp"):ArtificeOfTime()

    -- Rated PvP
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

function Neck:GetVariables()
    local t = {
        name = "neck",
        display = "Heart of Azeroth",
        type = "group",
        value = {
            {
                name = "level",
                display = "Level",
                type = "number",
                value = self.level,
                readonly = true
            }
        }
    }

    local Dictionary = DraduxTodo:GetModule("Util"):GetModule("Dictionary")
    local essences = Dictionary:GetSortedKeySet(self.modules, function(a, b)
        return a < b
    end)

    for index, essence in ipairs(essences) do
        local module = self.modules[essence]
        local vars = module:GetVariables()
        vars.name =  essence
        table.insert(t.value, vars)
    end

    return t
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

    for k, v in pairs(data.essences) do
        if self.modules[k] then
            self.modules[k]:FromData(v)
        end
    end
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

function Neck:OnModuleCreated(module)
    if module["Initialize"] then
        module:Initialize()
    end
end

function Neck:QUEST_CHOICE_UPDATE()
    for _, module in ipairs(self.orderedModules) do
        if module["QUEST_CHOICE_UPDATE"] then
            module:QUEST_CHOICE_UPDATE()
        end
    end
end