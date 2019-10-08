local TaskManager = DraduxTodo:GetModule("Data"):NewModule("TaskManager", "AceEvent-3.0")
local Templates = TaskManager:NewModule("Templates")
local Tasks = TaskManager:NewModule("Tasks")


function TaskManager:NewTemplate(name, libs)
    local module = Templates:NewModule(name, DraduxTodo:GetModule("Data"):GetModule("Task"), libs)
    return module
end

function TaskManager:OnInitialize()
    for _, module in pairs(Templates.modules) do
        if module["Initialize"] then
            module:Initialize()
        end
    end
end

function TaskManager:GetCategories()
    local List = DraduxTodo:GetModule("Util"):GetModule("List")

    local function AddCategory(t, category)
        local front = List:PopFront(category)

        if not t[front] then
            if table.getn(category) == 0 then
                t[front] = true
            else
                t[front] = {}
                AddCategory(t[front], category)
            end
        else
            if type(t[front]) == "boolean" and table.getn(category) >= 1 then
                t[front] = {}
            end

            AddCategory(t[front], category)
        end
    end

    local t = {}
    for name, module in pairs(Templates.modules) do
        if module.category then
            AddCategory(t, List:Copy(module.category))
        end
    end

    return t
end

function TaskManager:GetModuleByCategory(category)
    local List = DraduxTodo:GetModule("Util"):GetModule("List")
    local categoryStr = List:Join(category)

    local pos = List:FindFirst_If(Templates.orderedModules, function(element)
        if element.category then
            return categoryStr == List:Join(element.category)
        end

        return false
    end)
    for _, module in ipairs(Templates.orderedModules) do

    end
end


function TaskManager:Log()
    return DraduxTodo:GetModule("Util"):GetModule("Log")
end