local Task = DraduxTodo:GetModule("Data"):NewModule("Task", "AceEvent-3.0")

--[[
local db = {
    name = "Conflict And Strife: High",
    priority = 1,
    progress = {
        {
            name = "Ranking",
            actual = 192,
            max = 1000
        }
    },
    prerequisites = {
        type = "all",
        conditions = {
            {
                type = "equality",
                variable = {"neck", "conflictAndStrife", "rank"},
                value = 0
            },
            {
                type = "eqaulity",
                variable = {"custom", "essencePriority", "conflictAndStrife"},
                value = "high"
            }
        }
    }
}
]]

function Task:Initialize()
    local DateTime = DraduxTodo:GetModule("Util"):GetModule("DateTime")
    local now = DateTime:Now()

    self.name = ""
    self.prerequisites = nil
    self.category = {}
    self.priority = 1
    self.progress = {}
    self.characters = {}

    self.reset = {
        repetition = 7, -- in days
        time = {
            weekday = 4,
            hour = 9,
            minute = 0
        },
        last = {
            day = now.day,
            month = now.month,
            year = now.year
        },
        next = {
            -- will be replaced after initialization
            day = 1,
            month = 1,
            year = 1970
        },
        timer = nil
    }

    self.handler = {
        strings = {
            priority = "",
            reset = "",
            progress = "",
            gui = "",
        },
        functions = {
            priority = nil,
            reset = nil,
            progress = nil,
            gui = nil,
        }
    }
end

function Task:AsData()
    return {
        name = self.name,
        prerequisites = self.prerequisites,
        reset = {
            repetition = self.reset.repetition,
            time = {
                weekday = self.reset.time.weekday,
                hour = self.reset.time.hour,
                minute = self.reset.time.minute
            },
            last = {
                day = self.reset.last.day,
                month = self.reset.last.month,
                year = self.reset.last.year
            },
            next = {
                day = self.reset.next.day,
                month = self.reset.next.month,
                year = self.reset.next.year
            }
        }
    }
end

function Task:Prerequisites(character)
    local condition = DraduxTodo:GetModule("Util"):GetModule("Condition")
    if not condition then
        return false
    end

    return condition:Evaluate(character, self.prerequisites)
end

function Task:Progress(event, ...)
    local character = self:ActiveCharacter()

    if character and self.handler.progress then
        self.handler.functions.progress(self, character, event, ...)
    end
end

function Task:Priority()
    if self.handler.functions.priority then
        return self.handler.functions.priority()
    end

    return self.priority
end

function Task:Reset()
    -- Set last reset
    self.reset.last.day = self.reset.next.day
    self.reset.last.month = self.reset.next.month
    self.reset.last.year = self.reset.next.year

    self.reset.next = Task:NextReset()

    if self.handler.functions.reset then
        for _, character in ipairs(self.characters) do
            self.handler.functions.reset(self, character)
        end
    end
end

function Task:NextReset()
    local DateTime = DraduxTodo:GetModule("Util"):GetModule("DateTime")

    -- Set next reset
    local days = self.reset.repetition
    if self.reset.time.weekday then
        local now = DateTime:Now()
        local future = (now.weekday + days) % 7

        if future < self.reset.time.weekday then
            future = future + 7
        end

        local decrease = future - self.reset.time.weekday
        days = days - decrease
    end

    return DateTime:Add(self.reset.last, DateTime:Days(days))
end

function Task:StopResetTimer()
    if self.reset.timer then
        self.reset.timer:Cancel()
        self.reset.timer = nil
    end
end

function Task:StartResetTimer()
    if table.getn(self.characters) == 0 then
        -- No characters mean no reset
        return
    end

    if self.reset.repetition == 0 then
        -- No Repeat = No Reset
        return
    end

    local DateTime = DraduxTodo:GetModule("Util"):GetModule("DateTime")
    local now = DateTime:Now()
    if DateTime:IsEqual(now, self.reset.next) then
        if DateTime:IsEqual(now, self.reset.time) then
            self:Reset()
        elseif DateTime:isLess(now, self.reset.time) then
            self:StopResetTimer()

            local duration = DateTime:Duration(now, self.reset.time):InSeconds()
            self.reset.timer = C_Timer.NewTimer(duration, function()
                self:Reset()
            end)
        end
    end
end

function Task:Super()
    local super = {}

    local t = DraduxTodo:GetModule("Data"):GetModule("Task")
    for k,v in pairs(t) do
        if type(v) == "function" then
            super[k] = function(...)
                return t[k](self, ...)
            end
        end
    end

    return super
end

function Task:ActiveCharacter()
    for _, character in ipairs(self.characters) do
        if character:IsActive() then
            return character
        end
    end
end

function Task:SetProgress(character, key, actual, max)
    local guid = character:GetBase():GetGUID()
    local t = self.progress[guid] or {}
    t[key] = {
        actual = actual,
        max = max
    }
    self.progress[guid] = t
end

function Task:Log()
    return DraduxTodo:GetModule("Util"):GetModule("Log")
end