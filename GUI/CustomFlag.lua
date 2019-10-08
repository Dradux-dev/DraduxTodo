local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("DraduxTodo_CustomFlag", function(self, parent, data)
    local width = parent:GetWidth() or 250
    local height = 36
    local width_2 = (width - 30) / 2

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local label = StdUi:FontString(widget, data.display or data.name or "")
    widget.label = label
    StdUi:GlueLeft(label, widget, 10, 0, true)

    local input = StdUi:Checkbox(widget, "", width_2, 24)
    widget.input = input
    widget.input:SetChecked(data.value)
    StdUi:GlueLeft(input, widget, 20 + width_2, 0, true)

    function widget:AdjustWidth()
        local width = widget:GetParent():GetWidth() or 250
        local width_2 = (width - 30) / 2

        widget.input:SetWidth(width_2)
        widget.input:ClearAllPoints()
        StdUi:GlueLeft(input, widget, 20 + width_2, 0, true)
    end

    function widget:SetData(data)
        widget.label:SetText(data.display or data.name or "")
        widget.input:SetChecked(data.value)

        if data.readonly then
            widget.input:Disable()
        else
            widget.input:Enable()
        end
    end

    widget:SetData(data)

    return widget
end)