local Base = DraduxTodo:GetModule("Data"):NewModule("Base", "AceEvent-3.0")

function Base:Initialize()
    self.level = 1
    self.cname = "Dummy"
    self.realm = "Tarren Mill"
    self.faction = "Horde"
    self.class = "MONK"
    self.guid = ""
end

function Base:GetLevel()
    return self.level
end

function Base:GetCharacterName()
    return self.cname
end

function Base:GetFaction()
    return self.faction
end

function Base:GetClass()
    return self.class
end

function Base:GetRealm()
    return self.realm
end

function Base:GetGUID()
    return self.guid
end

function Base:GetVariable(path)
    local name = path[1]
    table.remove(path, 1)

    if name == "name" then
        name = "cname"
    end

    return self[name]
end

function Base:GetVariables()
    return {
        name = "base",
        display = "Base",
        type = "group",
        value = {
            {
                name = "level",
                display = "Level",
                type = "number",
                value = self.level,
                readonly = true
            },
            {
                name = "name",
                display = "Name",
                type = "string",
                value = self.cname,
                readonly = true
            },
            {
                name = "realm",
                display = "Realm",
                type = "string",
                value = self.realm,
                readonly = true
            },
            {
                name = "faction",
                display = "Faction",
                type = "string",
                value = self.faction,
                readonly = true
            },
            {
                name = "class",
                display = "Class",
                type = "string",
                value = self.class,
                readonly = true
            },
            {
                name = "guid",
                display = "GUID",
                type = "string",
                value = self.guid,
                readonly = true
            }
        }
    }
end

function Base:Scan()
    self.level = UnitLevel("player")
    self.cname, self.realm = UnitFullName("player")
    self.faction = UnitFactionGroup("player")
    self.class = select(2, UnitClass("player"))
    self.guid = UnitGUID("player")
end

function Base:IsActivePlayer()
    return UnitGUID("player") == self.guid
end

function Base:FromData(data)
    self.level = data.level
    self.cname = data.name
    self.realm = data.realm
    self.faction = data.faction
    self.class = data.class
    self.guid = data.guid
end

function Base:AsData()
    return {
        level = self.level,
        name = self.cname,
        realm = self.realm,
        faction = self.faction,
        class = self.class,
        guid = self.guid
    }
end

function Base:Log()
    return DraduxTodo:GetModule("Util"):GetModule("Log")
end