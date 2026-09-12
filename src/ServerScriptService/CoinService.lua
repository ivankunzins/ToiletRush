local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage:WaitForChild("Config"))

local CoinService = {}
local connections = {}
local active = false

local function hookCoin(coin, dataService)
    if connections[coin] then connections[coin]:Disconnect() end
    connections[coin] = coin.Touched:Connect(function(hit)
        if not active or coin:GetAttribute("Collected") then return end
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        if not player then return end
        coin:SetAttribute("Collected", true)
        coin.Transparency = 1
        coin.CanTouch = false
        dataService:AddCoins(player, Config.Economy.CoinValue)
        task.delay(Config.World.CoinRespawnSeconds, function()
            if coin.Parent then
                coin:SetAttribute("Collected", false)
                coin.Transparency = 0
                coin.CanTouch = true
            end
        end)
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
