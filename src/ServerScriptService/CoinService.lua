local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local CoinService = {}
local connections = {}
local active = false

local function collect(coin, player, dataService)
    if not active or coin:GetAttribute("Collected") then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    coin:SetAttribute("Collected", true)
    coin.CanTouch = false
    coin.Transparency = 1
    local value = coin:GetAttribute("Value") or Config.Economy.CoinValue
    dataService:AddCoins(player, value)

    task.delay(Config.World.CoinRespawnSeconds, function()
        if coin.Parent then
            coin:SetAttribute("Collected", false)
            coin.Transparency = 0
            coin.CanTouch = true
        end
    end)
end

local function hookCoin(coin, dataService)
    if connections[coin] then connections[coin]:Disconnect() end
    connections[coin] = coin.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        if player then collect(coin, player, dataService) end
    end)
end

function CoinService:Start(arena, dataService)
    active = true
    local folder = arena:WaitForChild("Coins")
    for _, coin in folder:GetChildren() do
        hookCoin(coin, dataService)
    end
end

function CoinService:Stop()
    active = false
end

return CoinService
