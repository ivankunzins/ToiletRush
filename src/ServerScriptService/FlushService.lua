local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(game.ReplicatedStorage:WaitForChild("Config"))

local FlushService = {}

local function rootOf(player)
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

function FlushService:Run(arena, shopService, dataService, stateRemote)
    stateRemote:FireAllClients("FLUSH_START", Config.Flush.Duration)

    local water = arena:FindFirstChild("Water")
    if water then
        TweenService:Create(water, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = Vector3.new(38, 2, 38),
            Transparency = 0.05,
        }):Play()
    end

    local center = Vector3.new(0, 11, 0)
    local started = os.clock()
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        local elapsed = os.clock() - started
        local progress = math.clamp(elapsed / Config.Flush.Duration, 0, 1)
        local radiusFactor = 1 - progress * 0.75

        for _, player in Players:GetPlayers() do
            local root = rootOf(player)
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                if shopService:HasLifebuoy(player) then
                    humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                    root.AssemblyLinearVelocity = Vector3.new(0, 3 + math.sin(elapsed * 5), 0)
                else
                    local offset = root.Position - center
                    local horizontal = Vector3.new(offset.X, 0, offset.Z)
                    local dist = horizontal.Magnitude
                    if dist < Config.Flush.PullRadius then
                        local inward = dist > 1 and -horizontal.Unit or Vector3.zero
                        local tangent = dist > 1 and Vector3.new(-horizontal.Z, 0, horizontal.X).Unit or Vector3.zero
                        local force = inward * Config.Flush.PullStrength * (0.35 + progress) + tangent * Config.Flush.SpinStrength
                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(force + Vector3.new(0, -8 - progress * 22, 0), math.clamp(dt * 4, 0, 1))
                    end
                end
            end
        end
    end)

    task.wait(Config.Flush.Duration)
    connection:Disconnect()

    for _, player in Players:GetPlayers() do
        local survived = shopService:HasLifebuoy(player)
        dataService:MarkRound(player, survived)
        if survived then
            dataService:AddCoins(player, Config.Economy.SurvivalReward)
        else
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.Health = 0 end
            dataService:AddCoins(player, Config.Economy.ParticipationReward)
        end
    end

    stateRemote:FireAllClients("ROUND_RESULTS")
end

return FlushService
