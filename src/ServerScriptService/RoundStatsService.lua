local RoundStatsService = {}
local stats = {}

local DEFAULT = {
    CoinsCollected = 0,
    RareCoinsCollected = 0,
    HazardsHit = 0,
    DamageTaken = 0,
}

local function fresh()
    return {
        CoinsCollected = 0,
        RareCoinsCollected = 0,
        HazardsHit = 0,
        DamageTaken = 0,
    }
end

function RoundStatsService:Reset(players)
    stats = {}
    for _, player in ipairs(players) do
        stats[player] = fresh()
        for key, value in pairs(DEFAULT) do
            player:SetAttribute(key, value)
        end
    end
end

function RoundStatsService:Get(player)
    return stats[player] or fresh()
end

function RoundStatsService:AddCoin(player, value)
    local s = stats[player]
    if not s then return end
    s.CoinsCollected += value
    if value >= 5 then s.RareCoinsCollected += 1 end
    player:SetAttribute("CoinsCollected", s.CoinsCollected)
    player:SetAttribute("RareCoinsCollected", s.RareCoinsCollected)
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
