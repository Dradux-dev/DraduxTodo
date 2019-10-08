local StdUi = LibStub("StdUi")

StdUi:RegisterWidget("DraduxTodo_RealmButton", function(self, parent, text)
    local width = parent:GetWidth() or 250
    local height = 20

    local button = CreateFrame("BUTTON", text, parent, "OptionsListButtonTemplate")
    self:InitWidget(button)
    self:SetObjSize(button, width, height)
    button.show_characters = true

    local background = button:CreateTexture(nil, "BACKGROUND")
    button.background = background
    background:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp")
    background:SetBlendMode("ADD")
    background:SetVertexColor(0.5, 0.5, 0.5, 0.25)
    background:SetPoint("TOP", button, "TOP")
    background:SetPoint("BOTTOM", button, "BOTTOM")
    background:SetPoint("LEFT", button, "LEFT")
    background:SetPoint("RIGHT", button, "RIGHT")

    local title = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.title = title
    title:SetHeight(height)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("CENTER")
    title:SetPoint("TOP", button, "TOP")
    title:SetPoint("LEFT", button, "LEFT", 5, 0)
    title:SetPoint("BOTTOM", button, "BOTTOM")
    title:SetPoint("RIGHT", button, "RIGHT")
    title:SetText("")

    function button:SetText(title)
        self.title:SetText(title)
    end

    button:SetScript("OnClick", function()
        button.show_characters = not button.show_characters
        print("Showing Characters: ", button.show_characters)
    end)

    button:SetText(text or "")

    return button
end)