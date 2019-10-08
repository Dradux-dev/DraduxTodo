local StdUi = LibStub("StdUi")

local function HideScrollBar(scrollFrame)
    local scrollBar = scrollFrame.panel.scrollBar
    scrollBar.ScrollDownButton:Hide()
    scrollBar.ScrollUpButton:Hide()
    scrollBar.panel:Hide()
    scrollBar.thumb:Hide()
    scrollBar.ThumbTexture:Hide()
    scrollBar:Hide()
end

local function ShowScrollBar(scrollFrame)
    local scrollBar = scrollFrame.panel.scrollBar
    scrollBar.ScrollDownButton:Show()
    scrollBar.ScrollUpButton:Show()
    scrollBar.panel:Show()
    scrollBar.thumb:Show()
    scrollBar.ThumbTexture:Show()
    scrollBar:Show()
end

StdUi:RegisterWidget("DraduxTodo_CharacterList", function(self, parent)
    local WidgetManager = DraduxTodo:GetModule("Gui"):GetModule("WidgetManager")

    local width = parent:GetWidth() or 800
    local height = parent:GetHeight() or 220
    local width_1 = (width - 30) / 3
    local width_2 = 2 * width_1

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local listPanel, listFrame, listChild, listBar = StdUi:ScrollFrame(widget, width_1, height - 20)
    widget.list = {
        panel = listPanel,
        frame = listFrame,
        child = listChild,
        bar = listBar,
        children = {}
    }
    StdUi:GlueTop(listPanel, widget, 10, -10, "LEFT")

    local contentPanel, contentFrame, contentChild, contentBar = StdUi:ScrollFrame(widget, width_2, height - 20)
    widget.content = {
        panel = contentPanel,
        frame = contentFrame,
        child = contentChild,
        bar = contentBar,
        children = {}
    }
    StdUi:GlueRight(contentPanel, listPanel, 10, 0)

    function widget.content.child:AdjustHeight()
        local totalHeight = 0
        for index, child in ipairs(widget.content.children) do
            totalHeight = totalHeight + child:GetHeight()

            if index ~= 1 then
                totalHeight = totalHeight + 2
            end
        end

        widget.content.child:SetHeight(totalHeight)
    end

    function widget:ShowDetails(character)
        local variables = character:GetVariables()

        for _, custom in ipairs(widget.content.children) do
            WidgetManager:Release(custom)
        end

        local last
        widget.content.children = {}
        for _, variable in ipairs(variables.value) do
            local child
            if variable.type == "group" then
                child = WidgetManager:Get("DraduxTodo_CustomGroup", widget.content.child, WidgetManager, variable)
            elseif variable.type == "number" then
                child = WidgetManager:Get("DraduxTodo_CustomNumber", widget.content.child, variable)
            elseif variable.type == "string" then
                child = WidgetManager:Get("DraduxTodo_CustomString", widget.content.child, variable)
            elseif variable.type == "flag" then
                child = WidgetManager:Get("DraduxTodo_CustomFlag", widget.content.child, variable)
            end

            -- Make sure to not fuck up with a non-existent type
            if child then
                table.insert(widget.content.children, child)
                child:ClearAllPoints()

                if last then
                    StdUi:GlueBelow(child, last, 0, -2, "LEFT")
                else
                    StdUi:GlueTop(child, widget.content.child, 0, 0, "LEFT")
                end

                last = child
            end
        end

    end

    function widget:CreateButtons(realms, chars)
        local margin = -2
        local indent = 5

        local Manager = DraduxTodo:GetModule("Data"):GetModule("CharacterManager")

        if not widget.realm_buttons then
            widget.realm_buttons = {}
        end

        if not widget.char_buttons then
            widget.char_buttons = {}
        end

        table.sort(realms, function(a, b)
            return a < b
        end)

        local last
        local char_counter = 1
        for realm_index, realm in ipairs(realms or {}) do
            if not widget.realm_buttons[realm_index] then
                widget.realm_buttons[realm_index] = StdUi:DraduxTodo_RealmButton(widget.list.child, realm)
            end

            local button = widget.realm_buttons[realm_index]
            button:SetText(realm)
            button:ClearAllPoints()
            if realm_index == 1 then
                StdUi:GlueTop(button, widget.list.child, 0, 0, "LEFT")
            else
                StdUi:GlueBelow(button, last, -indent, margin, "LEFT")
            end

            last = button

            table.sort(chars[realm] or {}, function(a, b)
                return a < b
            end)

            for char_index, character_name in ipairs(chars[realm] or {}) do
                local character = Manager:GetCharacter(realm, character_name)

                if not widget.char_buttons[char_counter] then
                    widget.char_buttons[char_counter] = StdUi:DraduxTodo_ClassButton(widget.list.child, character:GetBase():GetCharacterName(), character:GetBase():GetClass())
                end

                local button = widget.char_buttons[char_counter]
                char_counter = char_counter + 1

                button:SetName(character:GetBase():GetCharacterName())
                button:SetClass(character:GetBase():GetClass())
                button:ClearAllPoints()

                if char_index == 1 then
                    StdUi:GlueBelow(button, last, indent, margin, "LEFT")
                else
                    StdUi:GlueBelow(button, last, 0, margin, "LEFT")
                end

                button:SetScript("OnClick", function()
                    widget:ShowDetails(character)
                end)

                last = button
            end
        end
    end

    function widget:UpdateList()
        local Manager = DraduxTodo:GetModule("Data"):GetModule("CharacterManager")
        local realms = Manager:GetRealmList()
        local chars = Manager:GetRealmBasedList()

        widget:CreateButtons(realms, chars)
    end

    HideScrollBar(widget.list.frame)
    HideScrollBar(widget.content.frame)

    widget:SetScript("OnShow", function()
        widget:UpdateList()
    end)

    WidgetManager:CreateType(
            "DraduxTodo_CustomGroup",
            function(parent, manager, data)
                return StdUi:DraduxTodo_CustomGroup(parent, manager, data)
            end,
            function(widget, parent, manager, data)
                widget:SetParent(parent)
                widget:AdjustWidth()
                widget:SetData(data)
            end,
            function(widget)
                widget:SetData({})
            end
    )

    WidgetManager:CreateType(
            "DraduxTodo_CustomString",
            function(parent, data)
                return StdUi:DraduxTodo_CustomString(parent, data)
            end,
            function(widget, parent, data)
                widget:SetParent(parent)
                widget:AdjustWidth()
                widget:SetData(data)
            end,
            function(widget)
            end
    )

    WidgetManager:CreateType(
            "DraduxTodo_CustomNumber",
            function(parent, data)
                return StdUi:DraduxTodo_CustomNumber(parent, data)
            end,
            function(widget, parent, data)
                widget:SetParent(parent)
                widget:AdjustWidth()
                widget:SetData(data)
            end,
            function(widget)
            end
    )

    WidgetManager:CreateType(
            "DraduxTodo_CustomFlag",
            function(parent, data)
                return StdUi:DraduxTodo_CustomFlag(parent, data)
            end,
            function(widget, parent, data)
                widget:SetParent(parent)
                widget:AdjustWidth()
                widget:SetData(data)
            end,
            function(widget)
            end
    )

    return widget
end)