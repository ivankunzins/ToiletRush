-- Server-authoritative obstacle movement. Obstacles never deal damage: they block routes or shove players away.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Config = require(game.ReplicatedStorage:WaitForChild("Config"))
local RoundStatsService = require(game.ServerScriptService:WaitForChild("RoundStatsService"))

local arena = Workspace:WaitForChild("ToiletArena", 30)
if not arena then return end

local obstacles = arena:WaitForChild("Obstacles")
local animated = {}
local hitAt = {}

local function pushPlayer(part, hit)
    local character = hit:FindFirstAncestorOfClass("Model")
    local player = character and Players:GetPlayerFromCharacter(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not player or player:GetAttribute("RoundActive") ~= true or player:GetAttribute("FlushActive") == true then return end
    if not humanoid or humanoid.Health <= 0 or not root then return end

    local now = os.clock()
    hitAt[player] = hitAt[player] or {}
    if now - (hitAt[player][part] or 0) < Config.Hazards.Cooldown then return end
    hitAt[player][part] = now

    local away = root.Position - part.Position
    local horizontal = Vector3.new(away.X, 0, away.Z)
    if horizontal.Magnitude < 0.1 then
        horizontal = Vector3.new(math.cos(now * 3), 0, math.sin(now * 3))
    end

    local push = horizontal.Unit * Config.Hazards.Knockback + Vector3.new(0, Config.Hazards.VerticalKnockback, 0)
    root.AssemblyLinearVelocity = Vector3.new(push.X, math.max(root.AssemblyLinearVelocity.Y, push.Y), push.Z)
    RoundStatsService:AddHazardHit(player, 0)
    player:SetAttribute("CoinCombo", 0)
end

for _, object in obstacles:GetChildren() do
    local motion = object:GetAttribute("Motion")
    if motion and object:IsA("BasePart") then
        animated[#animated + 1] = {
            part = object,
            origin = object.CFrame,
            phase = object:GetAttribute("Phase") or 0,
            speed = object:GetAttribute("Speed") or 1,
            distance = object:GetAttribute("Distance") or 10,
            motion = motion,
        }
    end

    if object:IsA("BasePart") and object.CanTouch and object:GetAttribute("Hazard") == true then
        object.Touched:Connect(function(hit)
            pushPlayer(object, hit)
        end)
    end
end

Players.PlayerRemoving:Connect(function(player)
    hitAt[player] = nil
    RoundStatsService:Remove(player)
end)

RunService.Heartbeat:Connect(function(tickTime)
    local t = os.clock()
    for _, item in animated do
        local object = item.part
        if object.Parent then
            local wave = math.sin(t * item.speed + item.phase)
            if item.motion == "ROTATE" then
                object.CFrame = item.origin * CFrame.Angles(0, t * item.speed, 0)
            elseif item.motion == "BOUNCE" then
                object.CFrame = item.origin + Vector3.new(0, wave * item.distance, 0)
            elseif item.motion == "SWEEP" then
                object.CFrame = item.origin * CFrame.new(wave * item.distance, 0, 0)
            elseif item.motion == "PULSE" then
                object.CFrame = item.origin * CFrame.new(0, wave * item.distance, 0)
            end
        end
    end
end)
