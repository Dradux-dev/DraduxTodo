local CharacterManager = DraduxTodo:GetModule("Data"):NewModule("CharacterManager", "AceEvent-3.0")

function CharacterManager:OnEnable()
    self.characters = {}
    self.guid = {}

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LOGOUT")
end

function CharacterManager:Add(character)
    local guid = character:GetBase():GetGUID()

    -- Character does not exists
    if not self.guid[guid] then
        table.insert(self.characters, character)
        self.guid[guid] = table.getn(self.characters)
    end
end

function CharacterManager:New(name)
    return self:NewModule(name, DraduxTodo:GetModule("Data"):GetModule("Character"), "AceEvent-3.0")
end

function CharacterManager:RemoveByGUID(guid)
    -- Update GUID key

    self:UpdateGuidKey()
end

function CharacterManager:UpdateGuidKey()
    for index, character in ipairs(self.characters) do
        local guid = character:GetBase():GetGUID()
        self.guid[guid] = index
    end
end

function CharacterManager:PLAYER_ENTERING_WORLD()
    local guid = UnitGUID("player")

    if not self.guid[guid] then
        local name, realm = UnitFullName("player")
        local fullName = realm .. "_" .. name
        local character = self:New(fullName)
        C_Timer.After(1, function()
            -- If called directly Scan() will be called and later OnEnable() which
            -- overwrites the scanned data
            character:Scan()
        end)

        self:Add(character)
    end

    C_Timer.After(5, function()
        self:Log():Write(self, "PLAYER_ENTERING_WORLD", self:AsData(), "CharacterManager::Data")
    end)
end

function CharacterManager:PLAYER_LOGOUT()

end

function CharacterManager:Log()
    return DraduxTodo:GetModule("Util"):GetModule("Log")
end

function CharacterManager:AsData()
    local t = {}

    for _, character in ipairs(self.characters) do
        table.insert(t, character:AsData())
    end

    return t
end