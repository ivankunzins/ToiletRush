local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local RoundStatsService = require(game.ServerScriptService:WaitForChild("RoundStatsService"))

local CoinService = {}
local connections = {}
local active = false
local feedback = nil

local function resetCoin(coin)
    if not coin or not coin.Parent then
        return
    end
    coin:SetAttribute("Collected", false)
    coin.Transparency = 0
    coin.CanTouch = true
end

local function collect(coin, player, dataService)
    if not active or not coin.Parent or coin:GetAttribute("Collected") then
        return
    end
    if player:GetAttribute("RoundActive") ~= true or player:GetAttribute("Eliminated") == true then
        return
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return
    end

    coin:SetAttribute("Collected", true)
    coin.CanTouch = false
    coin.Transparency = 1

    local value = tonumber(coin:GetAttribute("Value")) or Config.Economy.CoinValue
    value = math.max(1, math.floor(value))

    if not dataService:AddCoins(player, value) then
        resetCoin(coin)
        return
    end

    RoundStatsService:AddCoin(player, value)

    local xp = Config.Progression.CoinXP
    if value >= Config.Economy.RareCoinValue then
        xp += Config.Progression.RareCoinBonusXP
    end
    local xpOk, levelUp, level = dataService:AddXP(player, xp)

    if feedback then
        feedback:FireClient(player, "COIN", "+" .. tostring(value) .. " COINS • +" .. tostring(xp) .. " XP")
        if xpOk and levelUp then
            feedback:FireClient(player, "LEVEL_UP", "LEVEL UP! • LEVEL " .. tostring(level))
        end
    end

    task.delay(Config.World.CoinRespawnSeconds, function()
        if active then
            resetCoin(coin)
        end
    end)
end

local function hookCoin(coin, dataService)
    if not coin:IsA("BasePart") then
        return
    end
    if connections[coin] then
        connections[coin]:Disconnect()
    end
    connections[coin] = coin.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        if player then
            collect(coin, player, dataService)
        end
    end)
end

function CoinService:BindFeedback(remote)
    feedback = remote
end

function CoinService:Start(arena, dataService)
    active = true
    local folder = arena:WaitForChild("Coins")

    -- A coin collected during the final seconds of the previous round must
    -- never stay invisible in the next round.
    for _, coin in folder:GetChildren() do
        resetCoin(coin)
        hookCoin(coin, dataService)
    end
end

function CoinService:Stop()
    active = false
end

return CoinService
