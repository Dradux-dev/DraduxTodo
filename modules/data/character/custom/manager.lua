local Manager = DraduxTodo:GetModule("Data"):NewModule("CustomManager", "AceEvent-3.0")

function Manager:AddCustom(data)
    local module = self:NewModule(data.name, DraduxTodo:GetModule("Data"):GetModule("Custom"), "AceEvent-3.0")
    module:FromData(data)
end

function Manager:GetVariable(path)
    local name = path[1]
    table.remove(path, 1)

    self.modules[name]:GetVariable(path)
end

function Manager:GetVariables()
    return {
        name = "user",
        display = "User",
        type = "group",
        value = {}
    }
end

function Manager:FromData(data)
    for _, element in ipairs(data) do
        self:AddCustom(data)
    end
end

function Manager:AsData()
    local t = {}

    for _, module in pairs(self.modules) do
        table.insert(t, module:AsData())
    end

    return t
end

function Manager:OnModuleCreate(module)
    if module["Initialize"] then
        module:Initialize()
    end
end