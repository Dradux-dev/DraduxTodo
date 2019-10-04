local NazjatarWorldboss = DraduxTodo:GetModule("Data"):GetModule("TaskManager"):NewTemplate("Worldquest_Worldboss_Nazjatar", "AceEvent-3.0")

function NazjatarWorldboss:OnEnable()
    self:Super():OnEnable()

    self.category = {"Worldquest", "Worldboss", "Nazjatar"}
    self:RegisterEvent("QUEST_TURNED_IN", "Progress")

    self.questID = {56056, 56057}
    self.key = "Worldboss killed"

    self:CreateHandlerFunctions()
end

function NazjatarWorldboss:CreateHandlerFunctions()
    self.handler.functions = {
        reset = function(task, character)
            task:NewWeek(character)
        end,
        progress = function(task, character, event, ...)
            task:WorldbossKilled(character)
        end
    }
end

function NazjatarWorldboss:NewWeek(character)
    local alreadyDone = false
    for _, questID in ipairs(self.questID) do
        alreadyDone = alreadyDone or IsQuestFlaggedCompleted(questID)
    end

    local actual = 0
    if alreadyDone then
        actual = 1
    end

    self:SetProgress(character, self.key, actual, 1)
end

function NazjatarWorldboss:WorldbossKilled(character)
    self:SetProgress(character, self.key, 1, 1)
end

