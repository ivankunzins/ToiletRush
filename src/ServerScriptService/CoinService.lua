local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local CoinService = {}
local connections = {}
local active = false
local feedback = nil

local function collect(coin, player, dataService)
    if not active or coin:GetAttribute("Collected") then return end
    if player:GetAttribute("RoundActive") ~= true then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    coin:SetAttribute("Collected", true)
    coin.CanTouch = false
    coin.Transparency = 1
    local value = coin:GetAttribute("Value") or Config.Economy.CoinValue
    dataService:AddCoins(player, value)

    if feedback then
        feedback:FireClient(player, "COIN", "+" .. tostring(value))
    end

    task.delay(Config.World.CoinRespawnSeconds, function()
        if coin.Parent and active then
            coin:SetAttribute("Collected", false)
            coin.Transparency = 0
            coin.CanTouch = true
        end
    end)
end

local function hookCoin(coin, dataService)
    if not coin:IsA("BasePart") then return end
    if connections[coin] then connections[coin]:Disconnect() end
    connections[coin] = coin.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        if player then collect(coin, player, dataService) end
    end)
end

function CoinService:BindFeedback(remote)
    feedback = remote
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
