local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local WorldBuilder = require(ServerScriptService:WaitForChild("WorldBuilder"))
local BathroomArchitecture = require(ServerScriptService:WaitForChild("BathroomArchitecture"))
local UpperCourseBuilder = require(ServerScriptService:WaitForChild("UpperCourseV2"))
local NPCBuilder = require(ServerScriptService:WaitForChild("NPCBuilder"))
local VisualEffectsBuilder = require(ServerScriptService:WaitForChild("VisualEffectsBuilder"))
local DataService = require(ServerScriptService:WaitForChild("DataService"))
local CoinService = require(ServerScriptService:WaitForChild("CoinService"))
local ShopService = require(ServerScriptService:WaitForChild("ShopService"))
local FlushService = require(ServerScriptService:WaitForChild("FlushService"))
local RoundService = require(ServerScriptService:WaitForChild("RoundServiceFixed"))
local AchievementService = require(ServerScriptService:WaitForChild("AchievementService"))
local RobuxShopService = require(ServerScriptService:WaitForChild("RobuxShopService"))

local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
    local r = remotes:FindFirstChild(name)
    if not r then r = Instance.new("RemoteEvent"); r.Name = name; r.Parent = remotes end
    return r
end

local stateRemote = remote("GameState")
local buyRemote = remote("BuyLifebuoy")
local feedbackRemote = remote("Feedback")
local achievementRemote = remote("Achievements")
local lobbyRemote = remote("LobbyAction")

local dailyRequestAt, achievementRequestAt, lobbyRequestAt = {}, {}, {}

feedbackRemote.OnServerEvent:Connect(function(player, action)
    if action ~= "CLAIM_DAILY" then return end
    local now=os.clock(); if now-(dailyRequestAt[player] or 0)<1 then return end; dailyRequestAt[player]=now
    local ok,reward=DataService:ClaimDaily(player)
    feedbackRemote:FireClient(player,ok and "DAILY_SUCCESS" or "DAILY_ERROR",ok and "DAILY +"..reward.." COINS" or "DAILY ALREADY CLAIMED")
end)

achievementRemote.OnServerEvent:Connect(function(player, action)
    if action~="GET" then return end
    local now=os.clock(); if now-(achievementRequestAt[player] or 0)<0.5 then return end; achievementRequestAt[player]=now
    if not DataService:IsReady(player) then feedbackRemote:FireClient(player,"LOBBY","Профиль ещё загружается или недоступен"); return end
    achievementRemote:FireClient(player,"LIST",AchievementService:GetForPlayer(player))
end)

lobbyRemote.OnServerEvent:Connect(function(player, action)
    if action~="PLAY" and action~="LEAVE" then return end
    local now=os.clock(); if now-(lobbyRequestAt[player] or 0)<0.5 then return end; lobbyRequestAt[player]=now
    if player:GetAttribute("RoundActive") then return end
    if action=="PLAY" and not DataService:IsReady(player) then feedbackRemote:FireClient(player,"LOBBY","Профиль ещё загружается. Попробуй ещё раз через секунду."); return end
    local queued=action=="PLAY"
    player:SetAttribute("Queued",queued); player:SetAttribute("LobbyStatus",queued and "QUEUED" or "LOBBY")
    lobbyRemote:FireClient(player,"QUEUE",queued)
end)

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("HasLifebuoy",false); player:SetAttribute("LifebuoyUnlocked",false)
    player:SetAttribute("RoundActive",false); player:SetAttribute("FlushActive",false); player:SetAttribute("Eliminated",false)
    player:SetAttribute("ReachedTop",false); player:SetAttribute("LastRoundSurvived",false)
    player:SetAttribute("Queued",false); player:SetAttribute("LobbyStatus","LOBBY")
    player:SetAttribute("CoinsCollected",0); player:SetAttribute("CoinGoalNotified",false)
    task.defer(function() RoundService:SyncPlayer(player,stateRemote); lobbyRemote:FireClient(player,"QUEUE",false) end)
end)

Players.PlayerRemoving:Connect(function(player)
    dailyRequestAt[player]=nil; achievementRequestAt[player]=nil; lobbyRequestAt[player]=nil
end)

pcall(function() Lighting.Technology=Enum.Technology.Future end)
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=0.22
Lighting.EnvironmentDiffuseScale=0.85
Lighting.EnvironmentSpecularScale=1
Lighting.ExposureCompensation=0.1

local arena=WorldBuilder:Build()
BathroomArchitecture:Apply(arena)
local flushPrompt=UpperCourseBuilder:Apply(arena)
NPCBuilder:Apply(arena)
VisualEffectsBuilder:Apply(arena)

-- Remove visual noise: keep important UI/coins/buttons, but eliminate decorative neon strips/markers.
for _,obj in ipairs(arena:GetDescendants()) do
    if obj:IsA("BasePart") then
        if obj.Name:match("NeonEdge") or obj.Name:match("RouteMarker") then obj:Destroy() end
        if obj.Name:match("RouteArrow") then obj.Material=Enum.Material.SmoothPlastic; obj.Transparency=0.18 end
    end
end

local coinsFolder=arena:FindFirstChild("Coins")
if coinsFolder then
    for _,coin in coinsFolder:GetChildren() do
        if coin.Name:match("^RareCoin") then
            local labelGui=coin:FindFirstChild("Label"); local label=labelGui and labelGui:FindFirstChildOfClass("TextLabel")
            if label then label.Text="+"..tostring(Config.Economy.RareCoinValue) end
        end
    end
end

arena:SetAttribute("BuildComplete",true)
AchievementService:Bind(DataService,feedbackRemote)
ShopService:Bind(buyRemote,DataService,RoundService,feedbackRemote)
RobuxShopService:Bind()
RobuxShopService:Apply(arena)
CoinService:BindFeedback(feedbackRemote)

if flushPrompt then
    flushPrompt.Triggered:Connect(function(player)
        if RoundService.State~="ROUND" or player:GetAttribute("RoundActive")~=true or player:GetAttribute("FlushActive") then return end
        player:SetAttribute("ReachedTop",true)
        if RoundService:RequestFlush(player) then
            feedbackRemote:FireClient(player,"FLUSH_TRIGGERED","🚽 СМЫВ! ВСЕ ВНИЗУ — В ДЫРКУ!")
            flushPrompt.Enabled=false
            task.delay(Config.Flush.Duration+1,function() if flushPrompt and flushPrompt.Parent then flushPrompt.Enabled=true end end)
        end
    end)
end

print(("[ToiletRush] Ready: 180s / 3 floors / safe floor 1 / Robux shop / NPC crowd / reduced neon"):format())
task.spawn(function() RoundService:Run(arena,stateRemote,CoinService,ShopService,FlushService,DataService,AchievementService) end)
