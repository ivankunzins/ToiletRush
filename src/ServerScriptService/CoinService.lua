local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local RoundStatsService = require(game.ServerScriptService:WaitForChild("RoundStatsService"))

local CoinService = {}
local connections = {}
local active = false
local feedback = nil
local combo = {}
local comboAt = {}

local function resetCoin(coin)
    if not coin or not coin.Parent then
        return
    end
    coin:SetAttribute("Collected", false)
    coin.Transparency = 0
    coin.CanTouch = true
end

local function resetCombo(player)
    combo[player] = 0
    comboAt[player] = 0
    if player.Parent then
        player:SetAttribute("CoinCombo", 0)
    end
end

local function addCombo(player)
    local now = os.clock()
    local previous = comboAt[player] or 0
    if now - previous > Config.Progression.ComboWindow then
        combo[player] = 0
    end
    combo[player] = math.min((combo[player] or 0) + 1, Config.Progression.ComboMax)
    comboAt[player] = now
    player:SetAttribute("CoinCombo", combo[player])
    return combo[player]
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

    local currentCombo = addCombo(player)
    local bonusRate = math.min(
        (currentCombo - 1) * Config.Progression.ComboCoinBonusPerStack,
        Config.Progression.ComboMax * Config.Progression.ComboCoinBonusPerStack
    )
    local bonusCoins = math.floor(value * bonusRate)
    local totalCoins = value + bonusCoins

    if not dataService:AddCoins(player, totalCoins) then
        resetCoin(coin)
        resetCombo(player)
        return
    end

    RoundStatsService:AddCoin(player, value, currentCombo, bonusCoins)

    local xp = Config.Progression.CoinXP
    if value >= Config.Economy.RareCoinValue then
        xp += Config.Progression.RareCoinBonusXP
    end
    xp += math.max(0, currentCombo - 1) * Config.Progression.ComboXPPerStack

    local xpOk, levelUp, level = dataService:AddXP(player, xp)

    if feedback then
        local comboText = currentCombo > 1 and " • COMBO x" .. tostring(currentCombo) or ""
        local bonusText = bonusCoins > 0 and " • BONUS +" .. tostring(bonusCoins) or ""
        feedback:FireClient(player, "COIN", "+" .. tostring(totalCoins) .. " COINS • +" .. tostring(xp) .. " XP" .. comboText .. bonusText)
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
    combo = {}
    comboAt = {}
    local folder = arena:WaitForChild("Coins")

    for _, player in Players:GetPlayers() do
        resetCombo(player)
    end

    for _, coin in folder:GetChildren() do
        resetCoin(coin)
        hookCoin(coin, dataService)
    end
end

function CoinService:Stop()
    active = false
    for _, player in Players:GetPlayers() do
        resetCombo(player)
    end
end

Players.PlayerRemoving:Connect(function(player)
    combo[player] = nil
    comboAt[player] = nil
end)

return CoinService
