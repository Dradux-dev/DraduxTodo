local Function = DraduxTodo:GetModule("Util"):NewModule("Function")

function Function:SafeCall(fn, ...)
    if fn and type(fn) == "function" then
        return fn(...)
    end
end