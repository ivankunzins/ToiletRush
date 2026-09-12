local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local RoundStatsService = require(game.ServerScriptService:WaitForChild("RoundStatsService"))

local RoundService = {}
RoundService.State = "INTERMISSION"
RoundService.EndAt = 0
RoundService.RoundNumber = 0

function RoundService:GetTimeLeft()
    if self.State ~= "ROUND" then return 0 end
    return math.max(0, math.ceil(self.EndAt - os.clock()))
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
end

function RoundService:Run(arena, stateRemote, coinService, shopService, flushService, dataService, achievementService)
    while true do
        self.State = "INTERMISSION"
        for remaining = Config.Round.Intermission, 1, -1 do
            stateRemote:FireAllClients("INTERMISSION", remaining)
            task.wait(1)
        end

        local players = Players:GetPlayers()
        if #players < Config.Round.MinimumPlayers then
            task.wait(1)
            continue
        end

        self.RoundNumber += 1
        shopService:Reset()
        RoundStatsService:Reset(players)
        for i, player in ipairs(players) do
            player:SetAttribute("HasLifebuoy", false)
            player:SetAttribute("RoundActive", true)
            player:SetAttribute("LastRoundSurvived", false)
            teleportPlayer(player, i, arena)
        end

        coinService:Start(arena, dataService)
        self.State = "ROUND"
        self.EndAt = os.clock() + Config.Round.Duration
        stateRemote:FireAllClients("ROUND_START", Config.Round.Duration, self.RoundNumber)

        while self:GetTimeLeft() > 0 do
            local left = self:GetTimeLeft()
            stateRemote:FireAllClients("TICK", left)
            task.wait(1)
        end

        self.State = "FLUSH"
        coinService:Stop()
        stateRemote:FireAllClients("FLUSH_WARNING")
        flushService:Run(arena, shopService, dataService, stateRemote)

        for _, player in Players:GetPlayers() do
            player:SetAttribute("RoundActive", false)
            local survived = player:GetAttribute("LastRoundSurvived") == true
            dataService:MarkRound(player, survived)
            if achievementService then
                achievementService:EvaluateRound(player, RoundStatsService:Get(player), survived)
            end
            stateRemote:FireClient(player, "ROUND_STATS", RoundStatsService:Get(player), survived)
        end
        task.wait(Config.Round.ResultsDuration)
    end
end

return RoundService
