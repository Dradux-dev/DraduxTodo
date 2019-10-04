local TaskManager = DraduxTodo:GetModule("Data"):NewModule("TaskManager", "AceEvent-3.0")
local Templates = TaskManager:NewModule("Templates")
local Tasks = TaskManager:NewModule("Tasks")

function TaskManager:OnEnable()

end

function TaskManager:NewTemplate(name, libs)
    local module = Templates:NewModule("Worldquest_Worldboss_Nazjatar", DraduxTodo:GetModule("Data"):GetModule("Task"), libs)
    return module
end