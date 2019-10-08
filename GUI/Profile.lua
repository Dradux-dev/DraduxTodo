local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("DraduxTodo_Profile", function(self, parent)
    local width = parent:GetWidth() or 800
    local height = 220
    local width_1 = width - 20
    local width_2 = (width - 30) / 2
    local width_newbutton = 80
    local width_new = (width_1 - 10 - width_newbutton)

    local widget = StdUi:Frame(parent, width, height)
    self:InitWidget(widget)
    self:SetObjSize(widget, width, height)

    local current = StdUi:Dropdown(widget, width_2, 24)
    widget.current = current
    StdUi:GlueTop(current, widget, 10, -30, "LEFT")

    local currentLabel = StdUi:Label(widget, "Current")
    widget.currentLabel = currentLabel
    StdUi:GlueAbove(currentLabel, current, 0, 5, "LEFT")

    local copyFrom = StdUi:Dropdown(widget, width_2, 24)
    widget.copyFrom = copyFrom
    StdUi:GlueRight(copyFrom, current, 10, 0)

    local copyFromLabel = StdUi:Label(widget, "Copy From")
    widget.copyFromLabel = copyFromLabel
    StdUi:GlueAbove(copyFromLabel, copyFrom, 0, 5, "LEFT")

    local delete = StdUi:Dropdown(widget, width_1, 24)
    widget.delete = delete
    StdUi:GlueBelow(delete, current, 0, -30, "LEFT")

    local deleteLabel = StdUi:Label(widget, "Delete")
    widget.deleteLabel = deleteLabel
    StdUi:GlueAbove(deleteLabel, delete, 0, 5, "LEFT")

    local new = StdUi:SimpleEditBox(widget, width_new, 24, "")
    widget.new = new
    StdUi:GlueBelow(new, delete, 0, -30, "LEFT")

    local newLabel = StdUi:Label(widget, "Create New Profile")
    widget.newLabel = newLabel
    StdUi:GlueAbove(newLabel, new, 0, 5, "LEFT")

    local create = StdUi:Button(widget, width_newbutton, 24, "Create")
    widget.create = create
    StdUi:GlueRight(create, new, 10, 0)

    function widget:GetDB()
        return DraduxTodo.db
    end

    function widget:GetCurrentProfile()
        local db = widget:GetDB()
        return db:GetCurrentProfile()
    end

    function widget:GetProfileList(includeCurrent)
        local db = widget:GetDB()

        local profiles = db:GetProfiles()

        local FindCurrentProfile = function()
            local currentProfile = db:GetCurrentProfile()
            for pos, profileName in ipairs(profiles) do
                if profileName == currentProfile then
                    return pos
                end
            end
        end

        local pos = FindCurrentProfile()
        if not includeCurrent and pos then
            table.remove(profiles, pos)
        end

        table.sort(profiles)

        local profile_list = {}
        for index, profileName in ipairs(profiles) do
            table.insert(profile_list, {
                text = profileName,
                value = profileName
            })
        end

        return profile_list
    end

    function widget:Update()
        -- Do not end looping updates
        if not widget.updating then
            widget.updating = true
            current:SetOptions(widget:GetProfileList(true))
            current:SetValue(widget:GetCurrentProfile())

            copyFrom:SetOptions(widget:GetProfileList())
            copyFrom:SetPlaceholder("-- Select --")
            copyFrom:SetText(copyFrom.placeholder)


            delete:SetOptions(widget:GetProfileList())
            delete:SetPlaceholder("-- Select --")
            delete:SetText(delete.placeholder)

            new:SetText("")
            widget.updating = false
        end
    end

    widget:SetScript("OnShow", function()
        widget:Update()
    end)

    create:SetScript("OnClick", function()
        local name = widget.new:GetText()
        if name == "" then
            return
        end

        widget.new:SetText("")
        widget:GetDB():SetProfile(name)
        widget:Update()
    end)

    current.OnValueChanged = function(self, value)
        widget:GetDB():SetProfile(value)
        widget:Update()

        -- Rescan character to enter it in the new profile
        local Manager = DraduxTodo:GetModule("Data"):GetModule("CharacterManager")
        Manager:FromData(DraduxTodo:GetDB().characters or {})
        Manager:Scan()
    end

    copyFrom.OnValueChanged = function(self, value)
        widget:GetDB():CopyProfile(value)
        widget:Update()
        local db = widget:GetDB()
        print(DraduxTodo:GetName().. ": Copied profile " .. value .. " into " .. db:GetCurrentProfile())
    end

    delete.OnValueChanged = function(self, value)
        DraduxTodo:GetUserPermission(parent, {
            callbackYes = function()
                widget:GetDB():DeleteProfile(value)
                widget:Update()
            end,
            callbackNo = function()
                widget:Update()
            end

        })
    end

    return widget
end)