DraduxTodo.Skins = {}
DraduxTodo.Skins.ElvUI = {}


DraduxTodo.Skins.ElvUI.GetSkinModule = function()
    if IsAddOnLoaded("ElvUI") then
        local E, L, V, P, G = unpack(ElvUI)
        if E then
            local S = E:GetModule("Skins")
            return S
        end
    end
end

DraduxTodo.Skins.ElvUI.CloseButton = function(button)
    local S = DraduxTodo.Skins.ElvUI.GetSkinModule()
    if S then
        S:HandleCloseButton(button)
    end
end