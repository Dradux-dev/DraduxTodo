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

function CharacterManager:PLAYER_ENTERING_WORLD()
    self:Log():Write(self, "PLAYER_ENTERING_WORLD", "Loading from DB")
    local db = DraduxTodo:GetDB()
    self:FromData(db.characters)

    self:Log():Write(self, "PLAYER_ENTERING_WORLD", "Trying to create, if not existent")
    self:Log():Write(self, "PLAYER_ENTERING_WORLD", self.guid, "Keys")

    local character
    local name, realm = UnitFullName("player")
    local fullName = realm .. "_" .. name
    if not self.modules[fullName] then
        character = self:New(fullName)

        self:AddAction(fullName, function()
            -- If called directly Scan() will be called and later OnEnable() which
            -- overwrites the scanned data
            self:Log():Write(self, "PLAYER_ENTERING_WORLD", "Scanning")
            character:Scan()
            self:Log():Write(self, "PLAYER_ENTERING_WORLD", character:AsData(), "Scanned")
            self:Add(character)
        end)
    else
        character = self.modules[fullName]
        self:AddAction(fullName, function()
            -- If called directly Scan() will be called and later OnEnable() which
            -- overwrites the scanned data
            self:Log():Write(self, "PLAYER_ENTERING_WORLD", "Scanning")
            character:Scan()
            self:Log():Write(self, "PLAYER_ENTERING_WORLD", character:AsData(), "Scanned")
        end)
    end



    C_Timer.After(5, function()
        self:Log():Write(self, "PLAYER_ENTERING_WORLD", self.guid, "CharacterManager::GUID")
        self:Log():Write(self, "PLAYER_ENTERING_WORLD", self:AsData(), "CharacterManager::Data")
    end)
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
        self:Log():Write(self, "RunActions", self.actions[fullName], "Running actions")
        for _, fn in ipairs(self.actions[fullName]) do
            fn()
        end

        self.actions[fullName] = nil
    end
end

function CharacterManager:AddAction(fullName, fn)
    self:Log():Write(self, "AddAction", fn, fullName)

    if not self.modulesCreated then
        if not self.actions[fullName] then
            self.actions[fullName] = {}
        end

        table.insert(self.actions[fullName], fn)
        self:Log():Write(self, "AddAction", self.actions, "Actions")
    else
        self:RunActions(fullName)
        fn()
    end
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
        local character = self:New(fullName)
        self:AddAction(fullName, function()
            self:Log():Write(self, "FromData", entry, "Loading")
            character:FromData(entry) -- Timer again?!?
            self:Log():Write(self, "FromData", character:AsData(), "Loaded")
            self:Add(character)
        end)
    end
end

function CharacterManager:OnModuleCreated(module)
    self:Log():Write(self, "OnModuleCreated", module:GetName())

    module:Initialize()

    local name = module:GetName()
    self.modulesCreated[name] = true
    self:RunActions(name)
end