local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local Config=require(game.ReplicatedStorage:WaitForChild("Config"))

local function tryConnect(player,tool)
    if not tool:IsA("Tool") or tool.Name~="FlushBlaster" or tool:GetAttribute("BossPatchBound") then return end
    tool:SetAttribute("BossPatchBound",true)
    local cooldown=false
    tool.Activated:Connect(function()
        if cooldown then return end
        cooldown=true;task.delay(.8,function()cooldown=false end)
        local arena=Workspace:FindFirstChild("ToiletArena");local bossArena=arena and arena:FindFirstChild("BossArena");local damageBoss=bossArena and bossArena:FindFirstChild("DamageBoss")
        local boss=bossArena and bossArena:FindFirstChild("BathroomGuardian")
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not damageBoss or not boss or not root or not boss.Parent then return end
        if player:GetAttribute("RoundActive")~=true then return end
        local bossPos=boss:GetPivot().Position;local direction=bossPos-root.Position;local distance=direction.Magnitude
        if distance>105 or distance<2 or root.CFrame.LookVector:Dot(direction.Unit)<.25 then return end
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
