local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage:WaitForChild("Config"))
local RoundStatsService=require(game.ServerScriptService:WaitForChild("RoundStatsService"))
local Minions={Active=false,Folder=nil,Arena=nil,_token=0}
local floors={22,40,58,76,94}
local palettes={{Color3.fromRGB(70,115,170),Color3.fromRGB(40,45,55)},{Color3.fromRGB(75,145,105),Color3.fromRGB(45,55,50)},{Color3.fromRGB(175,120,70),Color3.fromRGB(55,48,42)},{Color3.fromRGB(125,90,155),Color3.fromRGB(45,40,52)},{Color3.fromRGB(190,150,55),Color3.fromRGB(55,50,40)}}
local function piece(m,n,s,cf,c,mat)local p=Instance.new("Part");p.Name=n;p.Size=s;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true;p.Color=c;p.Material=mat or Enum.Material.SmoothPlastic;p.Parent=m;return p end
local function feedback(player,k,t)
 local r=ReplicatedStorage:FindFirstChild("Remotes");local f=r and r:FindFirstChild("Feedback");if not f then return end
 if player then f:FireClient(player,k,t);return end
 for _,recipient in ipairs(Players:GetPlayers()) do
  if recipient:GetAttribute("RoundActive")==true then f:FireClient(recipient,k,t) end
 end
end
local function make(parent,name,pos,floor,index)local c=palettes[floor];local m=Instance.new("Model");m.Name=name;m.Parent=parent;local root=piece(m,"Root",Vector3.new(2,2,1),CFrame.new(pos),Color3.new(1,1,1));root.Transparency=1;piece(m,"Body",Vector3.new(3.2,3.8,1.8),CFrame.new(pos+Vector3.new(0,3.2,0)),c[1]);piece(m,"Head",Vector3.new(2.5,2.5,2.5),CFrame.new(pos+Vector3.new(0,6.05,0)),c[1]);piece(m,"Hood",Vector3.new(2.7,.7,2.7),CFrame.new(pos+Vector3.new(0,7.35,0)),c[2]);piece(m,"ArmL",Vector3.new(.9,3.3,.9),CFrame.new(pos+Vector3.new(-2,3.2,0)),c[2]);piece(m,"ArmR",Vector3.new(.9,3.3,.9),CFrame.new(pos+Vector3.new(2,3.2,0)),c[2]);piece(m,"LegL",Vector3.new(1.15,3,1.15),CFrame.new(pos+Vector3.new(-.75,.65,0)),c[2]);piece(m,"LegR",Vector3.new(1.15,3,1.15),CFrame.new(pos+Vector3.new(.75,.65,0)),c[2]);piece(m,"EyeL",Vector3.new(.3,.3,.12),CFrame.new(pos+Vector3.new(-.45,6.15,-1.22)),Color3.fromRGB(255,220,120),Enum.Material.Neon);piece(m,"EyeR",Vector3.new(.3,.3,.12),CFrame.new(pos+Vector3.new(.45,6.15,-1.22)),Color3.fromRGB(255,220,120),Enum.Material.Neon);local stone=piece(m,"AttackStone",Vector3.new(1.5,1.5,1.5),CFrame.new(pos+Vector3.new(0,4,-2)),Color3.fromRGB(105,103,98),Enum.Material.Slate);stone.Shape=Enum.PartType.Ball;stone.Transparency=1;m.PrimaryPart=root;m:SetAttribute("BossMinion",true);m:SetAttribute("Floor",floor);m:SetAttribute("Alive",true);m:SetAttribute("Index",index);m:SetAttribute("HomeAngle",(floor*67+index*61)%360);return m end
local function hide(m)m:SetAttribute("Alive",false);for _,p in ipairs(m:GetDescendants())do if p:IsA("BasePart") then p.Transparency=1 end end end
local function respawn(m,token)task.delay(10,function()if Minions.Active and token==Minions._token and m.Parent then local floor=m:GetAttribute("Floor");local angle=math.rad(m:GetAttribute("HomeAngle") or 0);local pos=Vector3.new(math.cos(angle)*68,floors[floor]+1.5,math.sin(angle)*68);m:PivotTo(CFrame.new(pos,Vector3.new(0,floors[floor]+1.5,0)));for _,p in ipairs(m:GetDescendants())do if p:IsA("BasePart") and p.Name~="Root" then p.Transparency=0 end end;m:SetAttribute("Alive",true);feedback(nil,"MINION_RESPAWN","👹 ПОМОЩНИК ВЕРНУЛСЯ НА ЭТАЖ!")end end)end
function Minions:DamageMinion(player,minion)if not self.Active or not self.Folder or not minion or not minion:IsDescendantOf(self.Folder) or minion:GetAttribute("BossMinion")~=true or minion:GetAttribute("Alive")~=true then return false end;if not player or player:GetAttribute("RoundActive")~=true or player:GetAttribute("Eliminated")==true then return false end;local pr=player.Character and player.Character:FindFirstChild("HumanoidRootPart");local mr=minion.PrimaryPart;if not pr or not mr or (pr.Position-mr.Position).Magnitude>125 then return false end;hide(minion);feedback(player,"MINION_KILL","💥 ПОМОЩНИК УБИТ! ВОЗРОДИТСЯ ЧЕРЕЗ 10 СЕКУНД");respawn(minion,self._token);return true end
local function nearest(pos)local best,bd=nil,math.huge;for _,plr in ipairs(Players:GetPlayers())do if plr:GetAttribute("RoundActive")==true and plr:GetAttribute("Eliminated")~=true then local ch=plr.Character;local root=ch and ch:FindFirstChild("HumanoidRootPart");local hum=ch and ch:FindFirstChildOfClass("Humanoid");if root and hum and hum.Health>0 then local d=(root.Position-pos).Magnitude;if d<bd then best,bd=plr,d end end end end;return best,bd end
local function attack(minion,target)
    local character = target.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local head = minion:FindFirstChild("Head")
    local stone = minion:FindFirstChild("AttackStone")
    if not root or not humanoid or humanoid.Health <= 0 or not head or not stone then return end
    if target:GetAttribute("RoundActive") ~= true or target:GetAttribute("Eliminated") == true then return end

    -- Use a separate projectile so minion patrol animations cannot move it mid-flight.
    local projectile = stone:Clone()
    projectile.Name = "MinionProjectile"
    projectile.Transparency = 0
    projectile.Anchored = true
    projectile.CanCollide = false
    projectile.CanTouch = false
    projectile.CanQuery = true
    local startCFrame = head.CFrame * CFrame.new(0, -1, -2)
    local endCFrame = CFrame.new(root.Position + Vector3.new(0, 1, 0))
    projectile.CFrame = startCFrame
    projectile.Parent = workspace

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {character}
    params.MaxParts = 1

    local startedAt = os.clock()
    local duration = 0.48
    local resolved = false
    local connection
    local function cleanup()
        if resolved then return end
        resolved = true
        if connection then
            connection:Disconnect()
            connection = nil
        end
        if projectile.Parent then projectile:Destroy() end
    end

    connection = RunService.Heartbeat:Connect(function()
        if not Minions.Active or not minion.Parent or not target.Parent
            or target.Character ~= character
            or target:GetAttribute("RoundActive") ~= true
            or target:GetAttribute("Eliminated") == true
            or humanoid.Health <= 0 then
            cleanup()
            return
        end

        local alpha = math.clamp((os.clock() - startedAt) / duration, 0, 1)
        projectile.CFrame = startCFrame:Lerp(endCFrame, alpha)
        local ok, hits = pcall(function()
            return workspace:GetPartBoundsInBox(projectile.CFrame, projectile.Size, params)
        end)
        if ok and #hits > 0 then
            cleanup()
            target:SetAttribute("Eliminated", true)
            RoundStatsService:AddDamageTaken(target, humanoid.Health)
            humanoid.Health = 0
            feedback(target, "MINION_HIT", "💥 ПОМОЩНИК ПОПАЛ! ВОЗРОЖДЕНИЕ ЧЕРЕЗ 10 СЕКУНД")
            task.delay(10, function()
                if target.Parent and target:GetAttribute("RoundActive") == true then
                    target:SetAttribute("Eliminated", false)
                    target:LoadCharacter()
                    feedback(target, "MINION_RESPAWN", "↻ ТЫ ВЕРНУЛСЯ В ИГРУ!")
                end
            end)
        elseif alpha >= 1 then
            cleanup()
        end
    end)

    task.delay(duration + 0.15, cleanup)
end
local function patrol(minion,token)local floor=minion:GetAttribute("Floor");local index=minion:GetAttribute("Index");local base=((floor*67+index*61)%360);task.spawn(function()local step=0;while Minions.Active and token==Minions._token and minion.Parent do task.wait(3.2);if not minion:GetAttribute("Alive") then continue end;step+=1;local a=math.rad(base+((step%3)-1)*28);local pos=Vector3.new(math.cos(a)*68,floors[floor]+1.5,math.sin(a)*68);local cf=CFrame.new(pos,Vector3.new(0,floors[floor]+1.5,0));local v=Instance.new("CFrameValue");v.Value=minion:GetPivot();local c=v.Changed:Connect(function(x)if minion.Parent then minion:PivotTo(x)end end);TweenService:Create(v,TweenInfo.new(1.8,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Value=cf}):Play();task.delay(1.9,function()c:Disconnect();v:Destroy()end)end end)end
local function spawnOne(self,token,floor,index)
    if not self.Active or token~=self._token or not self.Folder then return end
    local angle=math.rad((floor*67+index*61)%360)
    local pos=Vector3.new(math.cos(angle)*68,floors[floor]+1.5,math.sin(angle)*68)
    local minion=make(self.Folder,"BossMinion_F"..floor.."_"..index,pos,floor,index)
    patrol(minion,token)
end
local function spawnWave(self,token,firstIndex,lastIndex)
    for floor=1,5 do
        for index=firstIndex,lastIndex do
            spawnOne(self,token,floor,index)
        end
    end
end
function Minions:Start(arena)
    self:Stop()
    self.Active=true
    self.Arena=arena
    self._token+=1
    local token=self._token
    self._lastAttackAt={}
    local folder=Instance.new("Folder")
    folder.Name="BossMinions"
    folder.Parent=arena
    self.Folder=folder
    local bindable=Instance.new("BindableFunction")
    bindable.Name="DamageMinion"
    bindable.OnInvoke=function(player,minion) return self:DamageMinion(player,minion) end
    bindable.Parent=folder

    local delays=Config.Boss.MinionWaveDelays or {8,30,58}
    local waves={
        {at=delays[1] or 8,first=1,last=1,message="👹 ВОЛНА 1/3: 5 помощников выходят на все этажи!"},
        {at=delays[2] or 30,first=2,last=3,message="⚠ ВОЛНА 2/3: Хранитель вызвал ещё 10 помощников!"},
        {at=delays[3] or 58,first=4,last=5,message="🚨 ВОЛНА 3/3: Последние 10 помощников в игре!"},
    }
    task.spawn(function()
        local previous=0
        for _,wave in ipairs(waves) do
            task.wait(math.max(0,wave.at-previous))
            if not self.Active or token~=self._token or not self.Folder then return end
            spawnWave(self,token,wave.first,wave.last)
            feedback(nil,"MINION_EVENT",wave.message)
            previous=wave.at
        end
    end)

    task.spawn(function()
        while self.Active and token==self._token do
            task.wait(Config.Boss.MinionGlobalAttackInterval or 2.8)
            if not self.Active or token~=self._token or not self.Folder then break end
            local now=os.clock()
            local candidates={}
            for _,minion in ipairs(folder:GetChildren()) do
                if minion:IsA("Model") and minion:GetAttribute("Alive")==true then
                    local root=minion.PrimaryPart
                    local target,distance
                    if root then target,distance=nearest(root.Position) end
                    local last=self._lastAttackAt[minion] or -math.huge
                    if target and distance<95 and now-last>=(Config.Boss.MinionPerUnitCooldown or 7) then
                        table.insert(candidates,{minion=minion,target=target})
                    end
                end
            end
            if #candidates>0 then
                local chosen=candidates[math.random(1,#candidates)]
                self._lastAttackAt[chosen.minion]=now
                attack(chosen.minion,chosen.target)
            end
        end
    end)
    return true
end
function Minions:Stop()self.Active=false;self._token+=1;self._lastAttackAt={};if self.Folder then self.Folder:Destroy();self.Folder=nil end end
return Minions