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

function Character:OnEnable()
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