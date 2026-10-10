local Players = game:GetService("Players")

local AchievementService = {}
local dataService = nil
local feedback = nil

AchievementService.Definitions = {
    FIRST_WIN = {Name = "First Flush", Description = "Survive your first boss encounter", Reward = 8},
    COIN_HUNTER = {Name = "Coin Hunter", Description = "Collect 20 coins in one round", Reward = 5},
    RARE_HUNTER = {Name = "Rare Hunter", Description = "Collect 3 rare coins in one round", Reward = 6},
    CLEAN_RUN = {Name = "Clean Run", Description = "Survive a round without being hit by hazards or enemies", Reward = 8},
    STREAK_3 = {Name = "Hot Streak", Description = "Win 3 rounds in a row", Reward = 10},
    STREAK_5 = {Name = "Unstoppable", Description = "Win 5 rounds in a row", Reward = 15},
    COIN_MASTER = {Name = "Coin Master", Description = "Collect 30 coins in one round", Reward = 10},
}

local function notify(player, achievement)
    if feedback then
        feedback:FireClient(player, "ACHIEVEMENT", achievement.Name, achievement.Description, achievement.Reward)
    end
end

function AchievementService:Bind(ds, feedbackRemote)
    dataService = ds
    feedback = feedbackRemote
end

function AchievementService:TryUnlock(player, id)
    local achievement = self.Definitions[id]
    if not achievement or not dataService then return false end
    if dataService:UnlockAchievement(player, id, achievement.Reward) then
        notify(player, achievement)
        return true
    end
    return false
end

function AchievementService:EvaluateRound(player, roundStats, survived)
    if survived then self:TryUnlock(player, "FIRST_WIN") end
    if roundStats.CoinsCollected >= 20 then self:TryUnlock(player, "COIN_HUNTER") end
    if roundStats.RareCoinsCollected >= 3 then self:TryUnlock(player, "RARE_HUNTER") end
    if survived and roundStats.DamageTaken <= 0 and roundStats.HazardsHit <= 0 then self:TryUnlock(player, "CLEAN_RUN") end
    if roundStats.CoinsCollected >= 30 then self:TryUnlock(player, "COIN_MASTER") end

    local streak = player:GetAttribute("WinStreak") or 0
    if streak >= 3 then self:TryUnlock(player, "STREAK_3") end
    if streak >= 5 then self:TryUnlock(player, "STREAK_5") end
end

function AchievementService:GetForPlayer(player)
    local result = {}
    for id, achievement in pairs(self.Definitions) do
        result[id] = {
            Name = achievement.Name,
            Description = achievement.Description,
            Reward = achievement.Reward,
            Unlocked = dataService and dataService:HasAchievement(player, id) == true or false,
        }
    end
    return result
end

Players.PlayerRemoving:Connect(function(player)
    -- DataService owns persistence; this service keeps no player state.
end)

return AchievementService
