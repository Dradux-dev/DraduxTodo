local List = DraduxTodo:GetModule("Util"):NewModule("List")

-- List modifications
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

function List:Copy(l)
    local new = {}

    for _, element in ipairs(l) do
        table.insert(new, element)
    end

    return new
end

-- Element based functions
function List:FindFirst(l, needle)
    for index, element in ipairs(l) do
        if element == needle then
            return index
        end
    end
end

function List:FindFirst_If(l, predicate)
    local Function = DraduxTodo:GetModule("Util"):GetModule("Function")

    for index, element in ipairs(l) do
        if Function:SafeCall(predicate, element) then
            return index
        end
    end
end

function List:Join(l, token)
    local s = ""
    for index, element in ipairs(l) do
        if index ~= 1 then
            s = s .. token
        end

        s = s .. element
    end

    return s
end

function List:Join_If(l, token, predicate)
    local Function = DraduxTodo:GetModule("Util"):GetModule("Function")
    local s = ""
    local n = 0

    for index, element in ipairs(l) do
        if Function:SafeCall(predicate, element) then
            n = n + 1
            if n ~= 1 then
                s = s .. token
            end

            s = s .. element
        end
    end

    return s
end

function List:Append_Unique(l, value)
    local pos = List:FindFirst(l, value)
    if not pos then
        table.insert(l, value)
    end
end