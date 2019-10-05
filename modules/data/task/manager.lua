local TaskManager = DraduxTodo:GetModule("Data"):NewModule("TaskManager", "AceEvent-3.0")
local Templates = TaskManager:NewModule("Templates")
local Tasks = TaskManager:NewModule("Tasks")


function TaskManager:NewTemplate(name, libs)
    local module = Templates:NewModule(name, DraduxTodo:GetModule("Data"):GetModule("Task"), libs)
    return module
end

function TaskManager:OnModuleCreated(module)
    if module["Initialize"] then
        module:Initialize()
    end
end