local Log = DraduxTodo:GetModule("Util"):NewModule("Log")

function Log:OnInitialize()
    self.print = false
    self.virag = true
end

function Log:Print(from, ...)
    if self.print then
        print(from .. ": ", ...)
    end
end

function Log:Virag(from, v, n)
    if self.virag and ViragDevTool_AddData then
        ViragDevTool_AddData(v, from .. ": " .. (n or ""))
    end
end

function Log:ModuleName(module)
    return module.name or module.moduleName or ""
end

function Log:From(module, functionName)
    return Log:ModuleName(module) .. ": " .. (functionName or "") .. ": "
end

function Log:Write(module, functionName, v, n)
    local from = Log:From(module, functionName)
    Log:Print(from, n, v)
    Log:Virag(from, v, n)
end



