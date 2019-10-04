local List = DraduxTodo:GetModule("Util"):NewModule("List")

function List:PopFront(l)
    local front = l[1]
    table.remove(l, 1)
    return front
end

function List:PopBack(l)
    local n = #l
    local back = l[n]
    table.remove(l, n)
    return back
end