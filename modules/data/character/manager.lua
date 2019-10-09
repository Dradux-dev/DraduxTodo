local CharacterManager = DraduxTodo:GetModule("Data"):NewModule("CharacterManager", "AceEvent-3.0")

function CharacterManager:OnInitialize()
    self.characters = {}
    self.guid = {}
    self.actions = {}
    self.modulesCreated = {}

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

function CharacterManager:Scan()
    for _, character in ipairs(self.characters or {}) do
        if character:IsActive() then
            character:Scan()
        end
    end
end

function CharacterManager:PLAYER_ENTERING_WORLD()
    local db = DraduxTodo:GetDB()
    self:FromData(db.characters)

    local character
    local name, realm = UnitFullName("player")
    local fullName = realm .. "_" .. name
    if not self.modules[fullName] then
        character = self:New(fullName)

        self:AddAction(fullName, function()
            -- If called directly Scan() will be called and later OnEnable() which
            -- overwrites the scanned data
            character:Scan()
            self:Add(character)
        end)
    else
        character = self.modules[fullName]
        self:AddAction(fullName, function()
            -- If called directly Scan() will be called and later OnEnable() which
            -- overwrites the scanned data
            character:Scan()
        end)
    end
end

function CharacterManager:PLAYER_LOGOUT()
    local db = DraduxTodo:GetDB()
    db.characters = self:AsData()
end

function CharacterManager:Log()
    return DraduxTodo:GetModule("Util"):GetModule("Log")
end

function CharacterManager:RunActions(fullName)
    if self.actions[fullName] then
        for _, fn in ipairs(self.actions[fullName]) do
            fn()
        end

        self.actions[fullName] = nil
    end
end

function CharacterManager:AddAction(fullName, fn)
    if not self.modulesCreated then
        if not self.actions[fullName] then
            self.actions[fullName] = {}
        end

        table.insert(self.actions[fullName], fn)
    else
        self:RunActions(fullName)
        fn()
    end
end

function CharacterManager:GetCharacter(realm, name)
    return self.modules[(realm or "") .. "_" .. (name or "")]
end

function CharacterManager:GetRealmList()
    local List = DraduxTodo:GetModule("Util"):GetModule("List")
    local realms = {}

    for _, character in ipairs(self.characters) do
        List:Append_Unique(realms, character:GetBase():GetRealm())
    end

    return realms
end

function CharacterManager:GetRealmBasedList()
    local List = DraduxTodo:GetModule("Util"):GetModule("List")
    local chars = {}

    for _, character in ipairs(self.characters) do
        local realm = character:GetBase():GetRealm()
        if not chars[realm] then
            chars[realm] = {}
        end

        List:Append_Unique(chars[realm], character:GetBase():GetCharacterName())
    end

    return chars
end

function CharacterManager:AsData()
    local t = {}

    for _, character in ipairs(self.characters) do
        table.insert(t, character:AsData())
    end

    return t
end

function CharacterManager:FromData(data)
    for _, entry in ipairs(data or {}) do
        local fullName = entry.base.realm .. "_" .. entry.base.name
        local character = self.modules[fullName]
        if not character then
            character = self:New(fullName)
        end

        self:AddAction(fullName, function()
            character:FromData(entry)
            self:Add(character)
        end)
    end
end

function CharacterManager:OnModuleCreated(module)
    if module["Initialize"] then
        module:Initialize()
    end

    local name = module:GetName()
    self.modulesCreated[name] = true

    self:RunActions(name)
end