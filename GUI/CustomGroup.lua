local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("DraduxTodo_CustomGroup", function(self, parent, manager, data)
    local width = parent:GetWidth() or 250
    local height = 36

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    widget.children = {}

    local button = StdUi:Button(widget, 16, 16, "+")
    widget.button = button
    StdUi:GlueTop(button, widget, 10, -10, "LEFT")

    local title = StdUi:FontString(widget, data.display or data.name or "")
    widget.title = title
    StdUi:GlueRight(title, button, 5, 0)

    local child_list = StdUi:Frame(widget, width - 10, 50)
    widget.child_list = child_list
    StdUi:GlueTop(child_list, widget, 10, -36, "LEFT")
    child_list:Hide()

    function widget:AdjustWidth()
        local width = widget:GetParent():GetWidth() or 250
        widget.child_list:SetWidth(width - 10)
    end

    function child_list:AdjustHeight()
        local totalHeight = 0
        for index, child in ipairs(widget.children) do
            totalHeight = totalHeight + child:GetHeight()

            if index ~= 1 then
                totalHeight = totalHeight + 2
            end
        end

        widget.child_list:SetHeight(totalHeight)
        widget:AdjustHeight()
    end

    function widget:AdjustHeight()
        if widget.child_list:IsShown() then
            widget:SetHeight(height + widget.child_list:GetHeight())
        else
            widget:SetHeight(height)
        end


        widget:GetParent():AdjustHeight()
    end

    function widget:SetData(data)
        widget.title:SetText(data.display or data.name or "")
        widget.child_list:Hide()
        widget.button:SetText("+")
        widget:SetHeight(height)

        for _, child in ipairs(widget.children) do
            manager:Release(child)
        end

        local last
        local totalHeight = 0
        widget.children = {}
        for _, element in ipairs(data.value or {}) do
            local child
            if element.type == "group" then
                child = manager:Get("DraduxTodo_CustomGroup", widget.child_list, manager, element)
            elseif element.type == "number" then
                child = manager:Get("DraduxTodo_CustomNumber", widget.child_list, element)
            elseif element.type == "string" then
                child = manager:Get("DraduxTodo_CustomString", widget.child_list, element)
            elseif element.type == "flag" then
                child = manager:Get("DraduxTodo_CustomFlag", widget.child_list, element)
            end

            if child then
                table.insert(widget.children, child)
                child:ClearAllPoints()

                totalHeight = totalHeight + child:GetHeight()
                if last then
                    totalHeight = totalHeight + 2
                    StdUi:GlueBelow(child, last, 0, -2, "LEFT")
                else
                    StdUi:GlueTop(child, widget.child_list, 0, 0, "LEFT")
                end

                last = child
            end
        end

        widget.child_list:SetHeight(totalHeight)
    end

    button:SetScript("OnClick", function()
        if widget.child_list:IsShown() then
            widget.child_list:Hide()
            widget.button:SetText("+")
            widget:SetHeight(height)
        else
            widget.child_list:Show()
            widget.button:SetText("-")
            widget:SetHeight(height + widget.child_list:GetHeight())
        end

        widget:GetParent():AdjustHeight()
    end)


    widget:SetData(data)

    return widget
end)