local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local RoundService = {}
RoundService.State = "INTERMISSION"
RoundService.EndAt = 0

function RoundService:GetTimeLeft()
    if self.State ~= "ROUND" then return 0 end
    return math.max(0, math.ceil(self.EndAt - os.clock()))
end

local function teleportPlayer(player, index, arena)
    if not player.Character then player:LoadCharacter() end
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart", 5)
    local spawns = arena:WaitForChild("Spawns"):GetChildren()
    if root and #spawns > 0 then
        local spawn = spawns[((index - 1) % #spawns) + 1]
        root.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
    end
end

function RoundService:Run(arena, stateRemote, coinService, shopService, flushService, dataService)
    while true do
        self.State = "INTERMISSION"
        stateRemote:FireAllClients("INTERMISSION", Config.Round.Intermission)
        task.wait(Config.Round.Intermission)

        local players = Players:GetPlayers()
        if #players < Config.Round.MinimumPlayers then
            task.wait(2)
            continue
        end

        shopService:Reset()
        for i, player in ipairs(players) do
            player:SetAttribute("HasLifebuoy", false)
            teleportPlayer(player, i, arena)
        end

        coinService:Start(arena, dataService)
        self.State = "ROUND"
        self.EndAt = os.clock() + Config.Round.Duration
        stateRemote:FireAllClients("ROUND_START", Config.Round.Duration)

        while self:GetTimeLeft() > 0 do
            stateRemote:FireAllClients("TICK", self:GetTimeLeft())
            task.wait(1)
        end

        self.State = "FLUSH"
        coinService:Stop()
        stateRemote:FireAllClients("FLUSH_WARNING")
        flushService:Run(arena, shopService, dataService, stateRemote)

        task.wait(5)
    end
end

return RoundService
