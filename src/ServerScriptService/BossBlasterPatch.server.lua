local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local fireRemote = remotes:FindFirstChild("PistolFire") or Instance.new("RemoteEvent")
fireRemote.Name = "PistolFire"
fireRemote.Parent = remotes

local lastShot = {}
local MAX_RANGE = 150
local FIRE_INTERVAL = 0.22

fireRemote.OnServerEvent:Connect(function(player, rayOrigin, rayDirection)
    local now = os.clock()
    if now - (lastShot[player] or 0) < FIRE_INTERVAL then return end
    lastShot[player] = now

    if player:GetAttribute("RoundActive") ~= true or player:GetAttribute("Eliminated") == true then return end
    if player:GetAttribute("HasPistol") ~= true and player:GetAttribute("RobuxBlaster") ~= true then return end
    if typeof(rayOrigin) ~= "Vector3" or typeof(rayDirection) ~= "Vector3" then return end
    if rayDirection.Magnitude < 0.9 or rayDirection.Magnitude > 1.1 then return end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    local head = character:FindFirstChild("Head")
    local allowedOrigin = head and head.Position or (root.Position + Vector3.new(0, 1.5, 0))
    if (rayOrigin - allowedOrigin).Magnitude > 12 then return end

    local arena = Workspace:FindFirstChild("ToiletArena")
    local bossArena = arena and arena:FindFirstChild("BossArena")
    local boss = bossArena and bossArena:FindFirstChild("BathroomGuardian")
    local minions = arena and arena:FindFirstChild("BossMinions")
    if not arena then return end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    params.IgnoreWater = true
    local result = Workspace:Raycast(rayOrigin, rayDirection.Unit * MAX_RANGE, params)
    if not result then return end

    local model = result.Instance:FindFirstAncestorOfClass("Model")
    if not model then return end
    local damageMinion = minions and minions:FindFirstChild("DamageMinion")
    if model:GetAttribute("BossMinion") == true and damageMinion then
        pcall(function() damageMinion:Invoke(player, model) end)
        return
    end

    if boss and boss.Parent and (model == boss or model:IsDescendantOf(boss)) then
        local damageBoss = bossArena and bossArena:FindFirstChild("DamageBoss")
        if damageBoss then
            pcall(function() damageBoss:Invoke(player, Config.Boss.BlasterDamage, "BLASTER") end)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastShot[player] = nil
end)
