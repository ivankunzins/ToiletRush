local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local RoundStatsService = {}
local stats = {}

local DEFAULT = {
    CoinsCollected = 0,
    RareCoinsCollected = 0,
    HazardsHit = 0,
    DamageTaken = 0,
    MaxCombo = 0,
    ComboBonusCoins = 0,
}

local function fresh()
    return {
        CoinsCollected = 0,
        RareCoinsCollected = 0,
        HazardsHit = 0,
        DamageTaken = 0,
        MaxCombo = 0,
        ComboBonusCoins = 0,
    }
end

function RoundStatsService:Reset(players)
    stats = {}
    for _, player in ipairs(players) do
        stats[player] = fresh()
        for key, value in pairs(DEFAULT) do
            player:SetAttribute(key, value)
        end
        player:SetAttribute("CoinCombo", 0)
        player:SetAttribute("LifebuoyUnlocked", false)
    end
end

function RoundStatsService:Get(player)
    return stats[player] or fresh()
end

function RoundStatsService:AddCoin(player, value, combo, bonusCoins)
    local s = stats[player]
    if not s then return end

    value = math.max(1, math.floor(value or 0))
    s.CoinsCollected += value
    if value >= Config.Economy.RareCoinValue then
        s.RareCoinsCollected += 1
    end
    s.MaxCombo = math.max(s.MaxCombo, combo or 0)
    s.ComboBonusCoins += math.max(0, bonusCoins or 0)

    player:SetAttribute("CoinsCollected", s.CoinsCollected)
    player:SetAttribute("RareCoinsCollected", s.RareCoinsCollected)
    player:SetAttribute("MaxCombo", s.MaxCombo)
    player:SetAttribute("ComboBonusCoins", s.ComboBonusCoins)

    if s.CoinsCollected >= Config.Economy.LifebuoyUnlockCollected then
        player:SetAttribute("LifebuoyUnlocked", true)
    end
end

function RoundStatsService:AddHazardHit(player, damage)
    local s = stats[player]
    if not s then return end
    s.HazardsHit += 1
    s.DamageTaken += math.max(0, math.floor(damage or 0))
    player:SetAttribute("HazardsHit", s.HazardsHit)
    player:SetAttribute("DamageTaken", s.DamageTaken)
end

function RoundStatsService:Remove(player)
    stats[player] = nil
end

return RoundStatsService
