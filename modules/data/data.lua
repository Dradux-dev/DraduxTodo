local Data = DraduxTodo:NewModule("Data", "AceEvent-3.0")

function Data:OnModuleCreated(module)
    if module["Initialize"] then
        module:Initialize()
    end
end