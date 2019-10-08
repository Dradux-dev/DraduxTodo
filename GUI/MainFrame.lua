local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("DraduxTodo_MainFrame", function(self)
    local width = 800
    local height = 800

    local window = StdUi:Window(UIParent, "Dradux ToDo", width, height)
    self:InitWidget(window)
    self:SetObjSize(window, width, height)
    window:SetPoint("CENTER")
    window:SetFrameLevel(7)


    local tabPanel = StdUi:TabPanel(window, width, height, {
        {
            name = "tasks",
            title = "Tasks"
        },
        {
            name = "characters",
            title = "Characters"
        },
        {
            name = "profile",
            title = "Profile"
        }
    })
    window.tabPanel = tabPanel
    StdUi:GlueAcross(tabPanel, window, 10, -25, -10, 30)

    tabPanel:EnumerateTabs(function(tab)
        if tab.name == "characters" then
            window.characters = StdUi:DraduxTodo_CharacterList(tab.frame)
            StdUi:GlueAcross(window.characters, tab.frame, 0, 0, 0, 0)
        elseif tab.name == "profile" then
            window.profile = StdUi:DraduxTodo_Profile(tab.frame)
            StdUi:GlueAcross(window.profile, tab.frame, 0, 0, 0, 0)
        end
    end)


    local versionLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.versionLabel = versionLabel
    versionLabel:SetJustifyH("CENTER")
    versionLabel:SetJustifyV("CENTER")
    versionLabel:SetTextColor(1, 1, 1, 1)
    versionLabel:SetText("0.1.0")
    StdUi:GlueBottom(versionLabel, window, 0, 7, true)

    return window
end)
