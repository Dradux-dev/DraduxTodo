local Condition = DraduxTodo:GetModule("Util"):NewModule("Condition", "AceEvent-3.0")

function Condition:Evaluate(solver, data)
    data = data or { type = "true" }

    if data.type == "true" then
        return true
    elseif data.type == "false" then
        return false
    elseif data.type == "all" then
        return self:All(solver, data)
    elseif data.type == "any" then
        return self:Any(solver, data)
    elseif data.type == "not" then
        return self:Not(solver, data)
    elseif data.type == "equality" then
        return self:Equality(solver, data)
    end

    return false
end

function Condition:Convert(value, type)
    if type == "boolean" then
        return tonumber(value) ~= 0
    elseif type == "number" then
        return tonumber(value)
    elseif type == "string" then
        return tostring(value)
    end
end

function Condition:All(solver, data)
    local success = true

    for _, condition in ipairs(data.conditions) do
        success = success and self:Evaluate(solver, condition)
    end

    return success
end

function Condition:Any(solver, data)
    local success = false

    for _, condition in ipairs(data.conditions) do
        success = success or self:Evaluate(solver, condition)
    end

    return success
end

function Condition:Not(solver, data)
    return not self:Evaluate(solver, data.condition)
end

function Condition:Equality(solver, data)
    local variable = solver:GetVariable(data.variable)
    return variable == self:Convert(data.value, type(variable))
end