local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local Config=require(game.ReplicatedStorage:WaitForChild("Config"))
local function tryConnect(player,tool)
    if not tool:IsA("Tool") or tool.Name~="FlushBlaster" or tool:GetAttribute("BossPatchBound") then return end
    tool:SetAttribute("BossPatchBound",true)
    local cooldown=false
    tool.Activated:Connect(function()
        if cooldown then return end
        cooldown=true;task.delay(.55,function()cooldown=false end)
        local arena=Workspace:FindFirstChild("ToiletArena");local bossArena=arena and arena:FindFirstChild("BossArena");local boss= bossArena and bossArena:FindFirstChild("BathroomGuardian");local minions=arena and arena:FindFirstChild("BossMinions")
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root or player:GetAttribute("RoundActive")~=true or player:GetAttribute("Eliminated")==true then return end
        local origin=root.Position+Vector3.new(0,1.5,0);local direction=root.CFrame.LookVector*130
        local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={player.Character}
        local hit=Workspace:Raycast(origin,direction,params)
        if hit then
            local model=hit.Instance:FindFirstAncestorOfClass("Model")
            local damageMinion=minions and minions:FindFirstChild("DamageMinion")
            if model and model:GetAttribute("BossMinion") and damageMinion then
                pcall(function()damageMinion:Invoke(player,model)end)
                return
            end
        end
        local damageBoss=bossArena and bossArena:FindFirstChild("DamageBoss")
        if not damageBoss or not boss or not boss.Parent then return end
        local bossPos=boss:GetPivot().Position;local toBoss=bossPos-origin;local distance=toBoss.Magnitude
        if distance>150 or distance<2 or root.CFrame.LookVector:Dot(toBoss.Unit)<.20 then return end
        pcall(function()damageBoss:Invoke(player,Config.Boss.BlasterDamage,"BLASTER")end)
    end)
end
local function watch(container,player)
    if not container then return end
    for _,child in ipairs(container:GetChildren()) do tryConnect(player,child) end
    container.ChildAdded:Connect(function(child)tryConnect(player,child)end)
end
local function setup(player)
    local backpack=player:WaitForChild("Backpack",10);watch(backpack,player)
    player.CharacterAdded:Connect(function(char)watch(char,player)end)
    if player.Character then watch(player.Character,player) end
end
Players.PlayerAdded:Connect(setup)
for _,player in ipairs(Players:GetPlayers()) do task.defer(setup,player) end
