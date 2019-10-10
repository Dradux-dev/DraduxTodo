local NeckLevel = DraduxTodo:GetModule("Data"):GetModule("Essence"):NewModule("NeckLevel", DraduxTodo:GetModule("Data"):GetModule("Essence"), "AceEvent-3.0")

function NeckLevel:Initialize()
    self:Super():Initialize()

    self.type = "NeckLevel"
    self.essenceID = 12
    self.achievementID = 13572
end

function NeckLevel:BuildProgress(max)
        return {
            {
                name = "Level",
                actual = self:GetNeckLevel(),
                max = max,
            }
        }
end

function NeckLevel:UpdateProgress()
    if self.rank == 0 then
        self.progress = select(2, self:GetAchievemnt(self.achievementID))
    elseif self.rank == 1 then
        self.progress = self:BuildProgress(54)
    elseif self.rank == 2 then
        self.progress = self:BuildProgress(60)
    elseif self.rank == 3 then
        self.progress = self:BuildProgress(70)
    else
        self.progress = {}
    end
end

