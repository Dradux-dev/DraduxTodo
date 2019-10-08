local WidgetManager = DraduxTodo:GetModule("Gui"):NewModule("WidgetManager")

local StdUi = LibStub("StdUi")

function WidgetManager:OnEnable()
    self.widgets = {}
end

function WidgetManager:CreateType(name, create, update, release)
    local t = {
        unused = {},
        used = {}
    }

    function t:Get(...)
        local List = DraduxTodo:GetModule("Util"):GetModule("List")

        local widget
        if table.getn(self.unused) >= 1 then
            widget = List:PopFront(self.unused)
            update(widget, ...)
        else
            widget = create(...)
        end

        widget.widget_type = name
        widget:Show()
        table.insert(self.used, widget)

        return widget
    end

    function t:Release(widget)
        local List = DraduxTodo:GetModule("Util"):GetModule("List")
        local pos = List:FindFirst(self.used, widget)
        if pos then
            table.remove(self.used, pos)
            table.insert(self.unused, widget)
            widget:Hide()

            release(widget)
        end
    end

    self.widgets[name] = t
end

function WidgetManager:Get(name, ...)
    local List = DraduxTodo:GetModule("Util"):GetModule("List")
    return self.widgets[name]:Get(...)
end

function WidgetManager:Release(widget)
    local List = DraduxTodo:GetModule("Util"):GetModule("List")
    self.widgets[widget.widget_type]:Release(widget)
end