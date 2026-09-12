local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local WorldBuilder = require(ServerScriptService:WaitForChild("WorldBuilder"))
local DataService = require(ServerScriptService:WaitForChild("DataService"))
local CoinService = require(ServerScriptService:WaitForChild("CoinService"))
local ShopService = require(ServerScriptService:WaitForChild("ShopService"))
local FlushService = require(ServerScriptService:WaitForChild("FlushService"))
local RoundService = require(ServerScriptService:WaitForChild("RoundService"))
local AchievementService = require(ServerScriptService:WaitForChild("AchievementService"))

local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
    local r = remotes:FindFirstChild(name)
    if not r then
        r = Instance.new("RemoteEvent")
        r.Name = name
        r.Parent = remotes
    end
    return r
end

local stateRemote = remote("GameState")
local buyRemote = remote("BuyLifebuoy")
local feedbackRemote = remote("Feedback")
local achievementRemote = remote("Achievements")

feedbackRemote.OnServerEvent:Connect(function(player, action)
    if action ~= "CLAIM_DAILY" then return end
    local ok, reward = DataService:ClaimDaily(player)
    if ok then
        feedbackRemote:FireClient(player, "DAILY_SUCCESS", "DAILY +" .. reward .. " COINS")
    else
        feedbackRemote:FireClient(player, "DAILY_ERROR", "DAILY ALREADY CLAIMED")
    end
end)

achievementRemote.OnServerEvent:Connect(function(player, action)
    if action == "GET" then
        achievementRemote:FireClient(player, "LIST", AchievementService:GetForPlayer(player))
    end
end)

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("HasLifebuoy", false)
    player:SetAttribute("RoundActive", false)
    player:SetAttribute("LastRoundSurvived", false)
end)

local arena = WorldBuilder:Build()
AchievementService:Bind(DataService, feedbackRemote)
ShopService:Bind(buyRemote, DataService, RoundService, feedbackRemote)
CoinService:BindFeedback(feedbackRemote)

print(("[ToiletRush] Arena ready. Round=%ss, Lifebuoy window=%ss, cost=%s coins"):format(
    Config.Round.Duration,
    Config.Round.LifebuoyWindow,
    Config.Economy.LifebuoyCost
))

task.spawn(function()
    RoundService:Run(arena, stateRemote, CoinService, ShopService, FlushService, DataService, AchievementService)
end)
