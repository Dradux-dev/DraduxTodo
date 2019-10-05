local Character = DraduxTodo:GetModule("Data"):NewModule("Character", "AceEvent-3.0")

--[[
local db = {
    [uid] = {
        predefined = {
            base = {
                level = 32,
                faction = 1,
                realm = "Antonidas",
                class = "WARLOCK",
                name = "Firghor",
            },
            neck = {
                level = 65,
                essences = {
                    conflictAndStrife = {
                        rank = 1,
                        actual = 1200,
                        max = 1400
                    },
                }
            }
        },
        user = {
            key = value
        }
    }
}
]]

function Character:Initialize()
    self:Log():Write(self, "OnEnable", "called")
    self.base = self:NewModule("Base", DraduxTodo:GetModule("Data"):GetModule("Base"), "AceEvent-3.0")
    self.neck = self:NewModule("Neck", DraduxTodo:GetModule("Data"):GetModule("Neck"), "AceEvent-3.0")
    self.user = self:NewModule("User", DraduxTodo:GetModule("Data"):GetModule("CustomManager"), "AceEvent-3.0")
end

function Character:GetVariable(path)
    local name = path[1]
    table.remove(path, 1)
    self.modules[name]:GetVariable(path)
end

function Character:GetBase()
    return self.base
end

function Character:IsActive()
    return self.base:IsActivePlayer()
end

function Character:Scan()
    self.base:Scan()
    self.neck:Scan()
end

function Character:AsData()
    return {
        base = self.base:AsData(),
        neck = self.neck:AsData(),
        user = self.user:AsData()
    }
end

function Character:FromData(data)
    self:Log():Write(self, "FromData", data, "Data")

    for k, v in pairs(data) do
        self:Log():Write(self, "FromData", k, "K")
        self:Log():Write(self, "FromData", self[k], "Module")
        self:Log():Write(self, "FromData", (self[k] or {})["FromData"], "FromData Function")
        if self[k] and self[k]["FromData"] then
            self:Log():Write(self, "FromData", k, "Loading module")
            self[k]:FromData(v)
        end
    end
end

function Character:Log()
    return DraduxTodo:GetModule("Util"):GetModule("Log")
end

function Character:OnModuleCreated(module)
    if module["Initialize"] then
        module:Initialize()
    end
end