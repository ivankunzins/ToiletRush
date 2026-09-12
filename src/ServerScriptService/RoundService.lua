local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local RoundStatsService = require(game.ServerScriptService:WaitForChild("RoundStatsService"))

local RoundService = {}
RoundService.State = "INTERMISSION"
RoundService.EndAt = 0
RoundService.PhaseEndAt = 0
RoundService.RoundNumber = 0

function RoundService:GetTimeLeft()
    if self.State ~= "ROUND" then
        return 0
    end
    return math.max(0, math.ceil(self.EndAt - os.clock()))
end

function RoundService:GetQueuedPlayers()
    local queued = {}
    for _, player in Players:GetPlayers() do
        if player:GetAttribute("Queued") == true then
            table.insert(queued, player)
        end
    end
    return queued
end

function RoundService:SyncPlayer(player, stateRemote)
    if not player.Parent then
        return
    end

    if self.State == "INTERMISSION" then
        local remaining = math.max(0, math.ceil(self.PhaseEndAt - os.clock()))
        stateRemote:FireClient(player, "INTERMISSION", remaining)
    elseif self.State == "ROUND" then
        stateRemote:FireClient(player, "ROUND_START", Config.Round.Duration, self.RoundNumber)
        stateRemote:FireClient(player, "TICK", self:GetTimeLeft())
    elseif self.State == "FLUSH" then
        local remaining = math.max(0, math.ceil(self.PhaseEndAt - os.clock()))
        stateRemote:FireClient(player, "FLUSH_START", Config.Flush.Duration)
        stateRemote:FireClient(player, "FLUSH_TICK", remaining)
    end
end

local function teleportPlayer(player, index, arena)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not humanoid or humanoid.Health <= 0 then
        player:LoadCharacter()
        character = player.Character or player.CharacterAdded:Wait()
    end

    local root = character:WaitForChild("HumanoidRootPart", 8)
    local newHumanoid = character:FindFirstChildOfClass("Humanoid")
    local spawns = arena:WaitForChild("Spawns"):GetChildren()
    if root and #spawns > 0 then
        local spawn = spawns[((index - 1) % #spawns) + 1]
        root.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    if newHumanoid then
        newHumanoid.Health = newHumanoid.MaxHealth
        newHumanoid.AutoRotate = true
    end
    return newHumanoid
end

function RoundService:Run(arena, stateRemote, coinService, shopService, flushService, dataService, achievementService)
    while true do
        self.State = "INTERMISSION"
        self.EndAt = 0
        self.PhaseEndAt = os.clock() + Config.Round.Intermission

        for remaining = Config.Round.Intermission, 1, -1 do
            stateRemote:FireAllClients("INTERMISSION", remaining)
            task.wait(1)
        end
        self.PhaseEndAt = 0

        local players = self:GetQueuedPlayers()
        if #players < Config.Round.MinimumPlayers then
            stateRemote:FireAllClients("LOBBY_WAIT", #players, Config.Round.MinimumPlayers)
            task.wait(1)
            continue
        end

        self.RoundNumber += 1
        shopService:Reset()
        RoundStatsService:Reset(players)
        local deathConnections = {}

        for i, player in ipairs(players) do
            player:SetAttribute("HasLifebuoy", false)
            player:SetAttribute("RoundActive", true)
            player:SetAttribute("FlushActive", false)
            player:SetAttribute("Eliminated", false)
            player:SetAttribute("LastRoundSurvived", false)
            player:SetAttribute("LobbyStatus", "IN_ROUND")

            local humanoid = teleportPlayer(player, i, arena)
            if humanoid then
                deathConnections[player] = humanoid.Died:Connect(function()
                    if player:GetAttribute("RoundActive") == true then
                        player:SetAttribute("Eliminated", true)
                    end
                end)
            end
        end

        coinService:Start(arena, dataService)
        self.State = "ROUND"
        self.EndAt = os.clock() + Config.Round.Duration
        self.PhaseEndAt = self.EndAt
        stateRemote:FireAllClients("ROUND_START", Config.Round.Duration, self.RoundNumber)

        while self:GetTimeLeft() > 0 do
            local left = self:GetTimeLeft()
            stateRemote:FireAllClients("TICK", left)
            task.wait(1)
        end

        self.State = "FLUSH"
        self.EndAt = 0
        self.PhaseEndAt = os.clock() + Config.Flush.Duration
        coinService:Stop()
        for _, player in Players:GetPlayers() do
            if player:GetAttribute("RoundActive") == true then
                player:SetAttribute("FlushActive", true)
            end
        end

        stateRemote:FireAllClients("FLUSH_WARNING")
        flushService:Run(arena, shopService, dataService, stateRemote)
        self.PhaseEndAt = 0

        for _, player in Players:GetPlayers() do
            if player:GetAttribute("RoundActive") ~= true then
                continue
            end

            player:SetAttribute("RoundActive", false)
            player:SetAttribute("FlushActive", false)
            player:SetAttribute("LobbyStatus", "QUEUED")
            local survived = player:GetAttribute("LastRoundSurvived") == true
            dataService:MarkRound(player, survived)

            if achievementService then
                achievementService:EvaluateRound(player, RoundStatsService:Get(player), survived)
            end

            stateRemote:FireClient(player, "ROUND_STATS", RoundStatsService:Get(player), survived)
        end

        for _, connection in pairs(deathConnections) do
            connection:Disconnect()
        end

        task.wait(Config.Round.ResultsDuration)
    end
end

return RoundService
