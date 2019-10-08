local Custom = DraduxTodo:GetModule("Data"):NewModule("Custom", "AceEvent-3.0")

--[[
local db = {
    {
        name = "Essence Priority",
        type = "group",
        value = {
            {
                name = "Conflict and Strife",
                type = "select",
                options = {"high", "medium", "low", "offspec"},
                value = "high"
            },
            {
                name = "The Crucible of Flame",
                type = "select",
                options = {"high", "medium", "low", "offspec"},
                value = "high"
            }
        }
    },
}

types:
 * none
 * group
 * select
 * flag
 * number
 * string
]]


function Custom:Initialize()
    self.name = ""
    self.type = "none"
    self.value = ""
end

function Custom:AddCustom(data)
    local module = self:NewModule(data.name, DraduxTodo:GetModule("Data"):GetModule("Custom"), "AceEvent-3.0")
    module:FromData(data)
end

function Custom:GetVariable(path)
    local name = path[1]
    table.remove(path, 1)

    if self.modules[name] then
        return self.modules[name]:GetVariable(path)
    else
        return self[name]
    end
end

function Custom:GetVariables()
    return {
        name = self.name,
        type = self.type,
        value = self.value
    }
end

function Custom:FromData(data)
    self.name = data.name
    self.type = data.type

    if data.type == "group" then
        for _, element in ipairs(data.value) do
            self:AddCustom(element)
        end
    elseif data.type == "select" then
        self.options = data.options
        self.value = data.value
    else
        self.value = data.value
    end
end

function Custom:AsData()
    if self.type == "group" then
        local t = {}

        for moduleName, module in pairs(self.modules) do
            table.insert(t, module:AsData())
        end

        return {
            name = self.name,
            type = self.type,
            value = t
        }
    elseif self.type == "select" then
        return {
            name = self.name,
            type = self.type,
            options = self.options,
            value = self.value
        }
    else
        return {
            name = self.name,
            type = self.type,
            value = self.value
        }
    end
end

function Custom:OnModuleCreated(module)
    if module["Initialize"] then
        module:Initialize()
    end
end