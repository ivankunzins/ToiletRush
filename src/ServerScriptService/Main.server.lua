local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local WorldBuilder = require(ServerScriptService:WaitForChild("WorldBuilder"))
local BathroomArchitecture = require(ServerScriptService:WaitForChild("BathroomArchitecture"))
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
    if action ~= "CLAIM_DAILY" then
        return
    end

    local now = os.clock()
    if now - (dailyRequestAt[player] or 0) < 1 then
        return
    end
    dailyRequestAt[player] = now

    local ok, reward = DataService:ClaimDaily(player)
    if ok then
        feedbackRemote:FireClient(player, "DAILY_SUCCESS", "DAILY +" .. reward .. " COINS")
    else
        feedbackRemote:FireClient(player, "DAILY_ERROR", "DAILY ALREADY CLAIMED")
    end
end)

achievementRemote.OnServerEvent:Connect(function(player, action)
    if action ~= "GET" then
        return
    end

    local now = os.clock()
    if now - (achievementRequestAt[player] or 0) < 0.5 then
        return
    end
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
    if action ~= "PLAY" and action ~= "LEAVE" then
        return
    end

    local now = os.clock()
    if now - (lobbyRequestAt[player] or 0) < 0.5 then
        return
    end
    lobbyRequestAt[player] = now

    if player:GetAttribute("RoundActive") == true then
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
AchievementService:Bind(DataService, feedbackRemote)
ShopService:Bind(buyRemote, DataService, RoundService, feedbackRemote)
CoinService:BindFeedback(feedbackRemote)

print(("[ToiletRush] Arena ready. Round=%ss, Lifebuoy window=%ss, collect=%s points, cost=%s coins"):format(
    Config.Round.Duration,
    Config.Round.LifebuoyWindow,
    Config.Economy.LifebuoyUnlockCollected,
    Config.Economy.LifebuoyCost
))

task.spawn(function()
    RoundService:Run(arena, stateRemote, CoinService, ShopService, FlushService, DataService, AchievementService)
end)
