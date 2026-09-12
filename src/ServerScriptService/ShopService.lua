local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local ShopService = {}
local purchased = {}

function ShopService:Reset()
    purchased = {}
end

function ShopService:HasLifebuoy(player)
    return purchased[player] == true
end

function ShopService:Bind(remote, dataService, roundService)
    remote.OnServerEvent:Connect(function(player)
        if roundService:GetTimeLeft() > Config.Round.LifebuoyWindow then
            return
        end
        if self:HasLifebuoy(player) then return end
        if dataService:SpendCoins(player, Config.Economy.LifebuoyCost) then
            purchased[player] = true
            player:SetAttribute("HasLifebuoy", true)
        end
    end)
end

function ShopService:Remove(player)
    purchased[player] = nil
end

return ShopService
