local Dictionary = DraduxTodo:GetModule("Util"):NewModule("Dictionary")

function Dictionary:GetSortedKeySet(t, func)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys, k)
    end

    table.sort(keys, func)

    return keys
end