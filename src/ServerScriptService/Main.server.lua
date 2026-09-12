local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local WorldBuilder = require(ServerScriptService:WaitForChild("WorldBuilder"))
local BathroomArchitecture = require(ServerScriptService:WaitForChild("BathroomArchitecture"))
local UpperCourseBuilder = require(ServerScriptService:WaitForChild("UpperCourseBuilder"))
local VisualEffectsBuilder = require(ServerScriptService:WaitForChild("VisualEffectsBuilder"))
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
local lobbyRemote = remote("LobbyAction")

local dailyRequestAt = {}
local achievementRequestAt = {}
local lobbyRequestAt = {}

feedbackRemote.OnServerEvent:Connect(function(player, action)
    if action ~= "CLAIM_DAILY" then return end
    local now = os.clock()
    if now - (dailyRequestAt[player] or 0) < 1 then return end
    dailyRequestAt[player] = now
    local ok, reward = DataService:ClaimDaily(player)
    feedbackRemote:FireClient(player, ok and "DAILY_SUCCESS" or "DAILY_ERROR", ok and "DAILY +" .. reward .. " COINS" or "DAILY ALREADY CLAIMED")
end)

achievementRemote.OnServerEvent:Connect(function(player, action)
    if action ~= "GET" then return end
    local now = os.clock()
    if now - (achievementRequestAt[player] or 0) < 0.5 then return end
    achievementRequestAt[player] = now
    if not DataService:Get(player) then
        task.delay(0.25, function()
            if player.Parent and DataService:Get(player) then
                achievementRemote:FireClient(player, "LIST", AchievementService:GetForPlayer(player))
            end
        end)
        return
    end
    achievementRemote:FireClient(player, "LIST", AchievementService:GetForPlayer(player))
end)

lobbyRemote.OnServerEvent:Connect(function(player, action)
    if action ~= "PLAY" and action ~= "LEAVE" then return end
    local now = os.clock()
    if now - (lobbyRequestAt[player] or 0) < 0.5 then return end
    lobbyRequestAt[player] = now
    if player:GetAttribute("RoundActive") == true then return end
    if action == "PLAY" and not DataService:Get(player) then
        feedbackRemote:FireClient(player, "LOBBY", "Профиль ещё загружается, подожди секунду")
        return
    end
    local queued = action == "PLAY"
    player:SetAttribute("Queued", queued)
    player:SetAttribute("LobbyStatus", queued and "QUEUED" or "LOBBY")
    lobbyRemote:FireClient(player, "QUEUE", queued)
end)

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("HasLifebuoy", false)
    player:SetAttribute("LifebuoyUnlocked", false)
    player:SetAttribute("RoundActive", false)
    player:SetAttribute("FlushActive", false)
    player:SetAttribute("Eliminated", false)
    player:SetAttribute("LastRoundSurvived", false)
    player:SetAttribute("Queued", false)
    player:SetAttribute("LobbyStatus", "LOBBY")
    player:SetAttribute("CoinsCollected", 0)
    player:SetAttribute("CoinGoalNotified", false)

    task.defer(function()
        RoundService:SyncPlayer(player, stateRemote)
        lobbyRemote:FireClient(player, "QUEUE", player:GetAttribute("Queued") == true)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    dailyRequestAt[player] = nil
    achievementRequestAt[player] = nil
    lobbyRequestAt[player] = nil
end)

local arena = WorldBuilder:Build()
BathroomArchitecture:Apply(arena)
UpperCourseBuilder:Apply(arena)
VisualEffectsBuilder:Apply(arena)

local coinsFolder = arena:FindFirstChild("Coins")
if coinsFolder then
    for _, coin in coinsFolder:GetChildren() do
        if coin.Name:match("^RareCoin") then
            local labelGui = coin:FindFirstChild("Label")
            local label = labelGui and labelGui:FindFirstChildOfClass("TextLabel")
            if label then label.Text = "+" .. tostring(Config.Economy.RareCoinValue) end
        end
    end
end

arena:SetAttribute("BuildComplete", true)

AchievementService:Bind(DataService, feedbackRemote)
ShopService:Bind(buyRemote, DataService, RoundService, feedbackRemote)
CoinService:BindFeedback(feedbackRemote)

print(("[ToiletRush] Arena ready. Round=%ss, collect=%s points, lifebuoy=%s coins, upper course=ready, effects=ready"):format(
    Config.Round.Duration,
    Config.Economy.LifebuoyUnlockCollected,
    Config.Economy.LifebuoyCost
))

task.spawn(function()
    RoundService:Run(arena, stateRemote, CoinService, ShopService, FlushService, DataService, AchievementService)
end)
