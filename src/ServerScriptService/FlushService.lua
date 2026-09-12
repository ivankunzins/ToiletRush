local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(game.ReplicatedStorage:WaitForChild("Config"))

local FlushService = {}

local function rootOf(player)
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function humanoidOf(player)
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

function FlushService:Run(arena, shopService, dataService, stateRemote)
    stateRemote:FireAllClients("FLUSH_START", Config.Flush.Duration)

    local water = arena:FindFirstChild("Water")
    local drain = arena:FindFirstChild("Drain")
    local baseWater = water and (water:GetAttribute("BaseSize") or Vector3.new(124, 1.5, 124))
    local baseDrain = drain and drain.Size

    if water then
        TweenService:Create(water, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = Vector3.new(28, 2.5, 28),
            Transparency = 0.05,
        }):Play()
    end
    if drain then
        TweenService:Create(drain, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = Vector3.new(31, 2, 31),
        }):Play()
    end

    local center = Vector3.new(0, 13, 0)
    local started = os.clock()
    local connection

    connection = RunService.Heartbeat:Connect(function(dt)
        local elapsed = os.clock() - started
        local progress = math.clamp(elapsed / Config.Flush.Duration, 0, 1)
        local pull = Config.Flush.PullStrength * (0.35 + progress * 1.35)
        local spin = Config.Flush.SpinStrength * (0.6 + progress * 1.8)

        if water then
            local scale = 1 - progress * 0.72
            water.Size = Vector3.new(baseWater.X * scale, baseWater.Y + progress, baseWater.Z * scale)
            water.CFrame = CFrame.new(center.X, center.Y - progress * 1.5, center.Z) * CFrame.Angles(0, elapsed * 1.6, 0)
        end

        for _, player in Players:GetPlayers() do
            if player:GetAttribute("RoundActive") ~= true then
                continue
            end

            local root = rootOf(player)
            local humanoid = humanoidOf(player)
            if root and humanoid and humanoid.Health > 0 then
                if shopService:HasLifebuoy(player) then
                    humanoid.AutoRotate = false
                    local phase = player.UserId % 20
                    local orbit = Vector3.new(
                        math.cos(elapsed * 1.8 + phase) * 5,
                        2 + math.sin(elapsed * 5 + phase) * 1.2,
                        math.sin(elapsed * 1.8 + phase) * 5
                    )
                    local target = center + orbit
                    local delta = target - root.Position
                    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(
                        delta * 3 + Vector3.new(0, 4, 0),
                        math.clamp(dt * 5, 0, 1)
                    )
                    root.AssemblyAngularVelocity = Vector3.new(0, 2.5, 0)
                else
                    local offset = root.Position - center
                    local horizontal = Vector3.new(offset.X, 0, offset.Z)
                    local dist = horizontal.Magnitude
                    if dist < Config.Flush.PullRadius then
                        local inward = dist > 0.75 and -horizontal.Unit or Vector3.zero
                        local tangent = dist > 0.75 and Vector3.new(-horizontal.Z, 0, horizontal.X).Unit or Vector3.zero
                        local desired = inward * pull + tangent * spin + Vector3.new(0, -10 - progress * Config.Flush.SinkDepth, 0)
                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desired, math.clamp(dt * 6, 0, 1))
                        root.AssemblyAngularVelocity = Vector3.new(spin * 0.15, spin, spin * 0.08)
                    end
                end
            end
        end
    end)

    for remaining = Config.Flush.Duration, 1, -1 do
        stateRemote:FireAllClients("FLUSH_TICK", remaining)
        task.wait(1)
    end
    if connection then
        connection:Disconnect()
    end

    local survivedCount = 0
    for _, player in Players:GetPlayers() do
        if player:GetAttribute("RoundActive") ~= true then
            continue
        end

        local humanoid = humanoidOf(player)
        local alive = humanoid and humanoid.Health > 0
        local survived = alive and shopService:HasLifebuoy(player)
        if survived then
            survivedCount += 1
        end

        player:SetAttribute("LastRoundSurvived", survived)

        if survived then
            dataService:AddCoins(player, Config.Economy.SurvivalReward)
            dataService:AddXP(player, Config.Progression.SurvivalXP)
            humanoid.AutoRotate = true
        else
            dataService:AddCoins(player, Config.Economy.ParticipationReward)
            dataService:AddXP(player, Config.Progression.ParticipationXP)
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
            end
        end
    end

    stateRemote:FireAllClients("ROUND_RESULTS", survivedCount)

    if water then
        TweenService:Create(water, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
            Size = baseWater,
            Transparency = 0.28,
            CFrame = CFrame.new(0, 11.8, 0),
        }):Play()
    end
    if drain and baseDrain then
        TweenService:Create(drain, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {Size = baseDrain}):Play()
    end
end

return FlushService
