local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage:WaitForChild("Config"))

local BossService={}
BossService.Active=false
BossService.Defeated=false
BossService.Flushing=false
BossService.Health=0
BossService.Model=nil
BossService.Arena=nil
BossService.DamageBoss=nil
BossService.FlushPrompt=nil
BossService._attackToken=0
BossService._deathToken=0

local function feedback(player,kind,text)
    local rem=ReplicatedStorage:FindFirstChild("Remotes");local fb=rem and rem:FindFirstChild("Feedback")
    if fb and player then fb:FireClient(player,kind,text) end
end

local function feedbackAll(kind,text)
    local rem=ReplicatedStorage:FindFirstChild("Remotes");local fb=rem and rem:FindFirstChild("Feedback")
    if fb then fb:FireAllClients(kind,text) end
end

local function piece(model,name,size,cf,color,material,shape)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true;p.CastShadow=true
    p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
    if shape then p.Shape=shape end
    p.Parent=model
    return p
end

local function makeBillboard(part,text,color,size)
    local gui=Instance.new("BillboardGui");gui.Name="BossLabel";gui.Size=UDim2.fromOffset(size or 260,65);gui.StudsOffset=Vector3.new(0,5,0);gui.AlwaysOnTop=true;gui.Parent=part
    local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=text;label.TextColor3=color;label.TextStrokeTransparency=.2;label.Font=Enum.Font.GothamBlack;label.TextScaled=true;label.Parent=gui
end

local function buildBoss(arena)
    local old=arena:FindFirstChild("BossArena");if old then old:Destroy() end
    local folder=Instance.new("Folder");folder.Name="BossArena";folder.Parent=arena
    local model=Instance.new("Model");model.Name="BathroomGuardian";model.Parent=folder
    local base=Vector3.new(0,26,0)
    -- A tall stylized clay-like guardian: rounded stacked body, restrained face and long arms.
    local dark=Color3.fromRGB(82,57,43);local mid=Color3.fromRGB(112,76,53);local light=Color3.fromRGB(143,98,65)
    local core=piece(model,"Core",Vector3.new(25,25,25),CFrame.new(base+Vector3.new(0,18,0)),mid,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    piece(model,"ShoulderMass",Vector3.new(31,22,31),CFrame.new(base+Vector3.new(0,35,0)),dark,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    piece(model,"UpperMass",Vector3.new(27,23,27),CFrame.new(base+Vector3.new(0,51,0)),mid,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    piece(model,"CrownMass",Vector3.new(21,20,21),CFrame.new(base+Vector3.new(0,66,0)),light,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    local head=piece(model,"Face",Vector3.new(18,13,18),CFrame.new(base+Vector3.new(0,73,0)),mid,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    piece(model,"EyeL",Vector3.new(2.4,2.4,1.2),CFrame.new(base+Vector3.new(-4,75,-8)),Color3.fromRGB(245,220,125),Enum.Material.Neon,Enum.PartType.Ball)
    piece(model,"EyeR",Vector3.new(2.4,2.4,1.2),CFrame.new(base+Vector3.new(4,75,-8)),Color3.fromRGB(245,220,125),Enum.Material.Neon,Enum.PartType.Ball)
    piece(model,"Mouth",Vector3.new(7,2.2,1.3),CFrame.new(base+Vector3.new(0,70.5,-8)),Color3.fromRGB(48,35,29),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    local armL=piece(model,"ArmL",Vector3.new(7,30,7),CFrame.new(base+Vector3.new(-22,47,0))*CFrame.Angles(0,0,math.rad(16)),dark,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
    local armR=piece(model,"ArmR",Vector3.new(7,30,7),CFrame.new(base+Vector3.new(22,47,0))*CFrame.Angles(0,0,math.rad(-16)),dark,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
    local handL=piece(model,"HandL",Vector3.new(9,7,9),CFrame.new(base+Vector3.new(-29,32,0)),light,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    local handR=piece(model,"HandR",Vector3.new(9,7,9),CFrame.new(base+Vector3.new(29,32,0)),light,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    model.PrimaryPart=core
    makeBillboard(head,"⚠ BOSS • 30 HP",Color3.fromRGB(255,224,120),250)
    local aura=Instance.new("PointLight");aura.Name="BossLight";aura.Color=Color3.fromRGB(205,120,75);aura.Brightness=2; aura.Range=35;aura.Parent=head
    local highlight=Instance.new("Highlight");highlight.Name="BossHighlight";highlight.FillColor=Color3.fromRGB(115,72,48);highlight.FillTransparency=.78;highlight.OutlineColor=Color3.fromRGB(245,175,90);highlight.OutlineTransparency=.25;highlight.Parent=model
    local drain=Instance.new("Part");drain.Name="BossDrain";drain.Shape=Enum.PartType.Cylinder;drain.Size=Vector3.new(1.2,32,32);drain.CFrame=CFrame.new(0,13.3,0)*CFrame.Angles(0,0,math.rad(90));drain.Anchored=true;drain.Material=Enum.Material.Metal;drain.Color=Color3.fromRGB(55,61,66);drain.CanCollide=false;drain.Parent=folder
    return model,folder,{armL=armL,armR=armR,handL=handL,handR=handR,head=head,base=base}
end

local function spawnStones(arena,damageFn)
    local folder=Instance.new("Folder");folder.Name="BossStones";folder.Parent=arena:FindFirstChild("BossArena") or arena
    local floors={22,40,58,76,94}
    local index=0
    for floor,y in ipairs(floors) do
        for j=1,6 do
            index+=1
            local angle=math.rad((floor*73+j*47)%360)
            local radius=74
            local pos=Vector3.new(math.cos(angle)*radius,y+3,math.sin(angle)*radius)
            local rock=Instance.new("Part");rock.Name="Stone_"..index;rock.Shape=Enum.PartType.Ball;rock.Size=Vector3.new(3.5,3.5,3.5);rock.CFrame=CFrame.new(pos);rock.Anchored=true;rock.Material=Enum.Material.Slate;rock.Color=Color3.fromRGB(105,103,98);rock.Parent=folder
            local prompt=Instance.new("ProximityPrompt");prompt.Name="ThrowStone";prompt.ActionText="БРОСИТЬ";prompt.ObjectText="КАМЕНЬ • 1 УДАР";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=.15;prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false;prompt.Parent=rock
            prompt.Triggered:Connect(function(player)
                if not BossService.Active or BossService.Defeated or BossService.Flushing or not rock.Parent then return end
                local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not root or (root.Position-rock.Position).Magnitude>11 then return end
                prompt.Enabled=false;rock.Transparency=1;rock.CanQuery=false
                damageFn(player,Config.Boss.StoneDamage,"STONE")
                feedback(player,"BOSS_STONE","🪨 ПОПАДАНИЕ! БОСС ПОТЕРЯЛ 1 HP")
                task.delay(.35,function()if rock and rock.Parent then rock:Destroy()end end)
            end)
        end
    end
end

function BossService:GetHealth() return self.Health end
function BossService:IsDefeated() return self.Defeated end

function BossService:Damage(amount,player,source)
    if not self.Active or self.Defeated or self.Flushing then return false end
    amount=math.max(0,tonumber(amount) or 0)
    if amount<=0 then return false end
    self.Health=math.max(0,self.Health-amount)
    local model=self.Model
    local head=model and model:FindFirstChild("Face")
    if head then
        local gui=head:FindFirstChild("BossLabel");local label=gui and gui:FindFirstChildOfClass("TextLabel")
        if label then label.Text="⚠ BOSS • "..self.Health.." HP" end
        local flash=Instance.new("Highlight");flash.FillColor=Color3.fromRGB(255,240,180);flash.FillTransparency=.35;flash.OutlineTransparency=1;flash.Parent=model
        task.delay(.12,function()if flash and flash.Parent then flash:Destroy()end end)
    end
    if player then feedback(player,"BOSS_HIT",source=="BLASTER" and "🔫 ПОПАДАНИЕ! -"..amount.." HP" or "🪨 КАМЕНЬ ПОПАЛ! -"..amount.." HP") end
    if self.Health<=0 then self:Defeat() end
    return true
end

function BossService:Defeat()
    if self.Defeated then return end
    self.Defeated=true;self.Active=false;self.Flushing=false
    self._attackToken+=1
    if self.Model and self.Model.Parent then
        local pivot=self.Model:GetPivot()
        local goal=pivot*CFrame.new(0,-8,0)*CFrame.Angles(0,math.rad(180),0)
        local driver=Instance.new("CFrameValue");driver.Value=pivot;driver:GetPropertyChangedSignal("Value"):Connect(function()if self.Model and self.Model.Parent then self.Model:PivotTo(driver.Value)end end)
        TweenService:Create(driver,TweenInfo.new(1.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Value=goal}):Play()
        task.delay(1.5,function()if driver then driver:Destroy()end end)
    end
    feedbackAll("BOSS_DEFEATED","🏆 BOSS ПОБЕЖДЁН! ПУТЬ ПРОЙДЕН!")
end

function BossService:TriggerFlush(player)
    if not self.Active or self.Defeated or self.Flushing then return false end
    local root=player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position-Vector3.new(0,94,-72)).Magnitude>20 then return false end
    self.Flushing=true
    feedbackAll("BOSS_FLUSH","🚽 БОСС СМЫВАЕТСЯ! 10 СЕКУНД НЕ БЬЁТ!")
    local model=self.Model
    if model and model.Parent then
        local start=model:GetPivot()
        local down=start*CFrame.new(0,-42,0)*CFrame.Angles(math.rad(8),0,math.rad(5))
        local driver=Instance.new("CFrameValue");driver.Value=start
        driver:GetPropertyChangedSignal("Value"):Connect(function()if model and model.Parent then model:PivotTo(driver.Value)end end)
        TweenService:Create(driver,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Value=down}):Play()
        task.wait(Config.Boss.FlushHoldSeconds)
        if self.Defeated then driver:Destroy();return true end
        local up=down*CFrame.new(0,42,0)*CFrame.Angles(math.rad(-8),0,math.rad(-5))
        TweenService:Create(driver,TweenInfo.new(Config.Boss.FlushRecoverySeconds,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Value=up}):Play()
        task.wait(Config.Boss.FlushRecoverySeconds)
        driver:Destroy()
    end
    self.Flushing=false
    if self.Active and not self.Defeated then feedbackAll("BOSS_RETURN","⚠ БОСС ВЫБРАЛСЯ! БЕГИТЕ!") end
    return true
end

function BossService:Start(arena)
    self.Active=true;self.Defeated=false;self.Flushing=false;self.Health=Config.Boss.Health;self.Arena=arena
    local model,folder,refs=buildBoss(arena);self.Model=model;self.Refs=refs
    self.DamageBoss=Instance.new("BindableFunction");self.DamageBoss.Name="DamageBoss";self.DamageBoss.Parent=folder
    self.DamageBoss.OnInvoke=function(player,amount,source)return self:Damage(amount,player,source)end
    spawnStones(arena,function(player,amount,source)return self:Damage(amount,player,source)end)
    feedbackAll("BOSS_START","⚠ BOSS ПОЯВИЛСЯ! БЛАСТЕР = 10 ПОПАДАНИЙ • КАМНИ = 30 ПОПАДАНИЙ")
    self._attackToken+=1;local token=self._attackToken
    task.spawn(function()
        while self.Active and not self.Defeated and token==self._attackToken do
            task.wait(Config.Boss.AttackInterval)
            if not self.Active or self.Defeated or self.Flushing then continue end
            for _,player in ipairs(Players:GetPlayers()) do
                if player:GetAttribute("RoundActive")==true and player:GetAttribute("Eliminated")~=true then
                    local char=player.Character;local humanoid=char and char:FindFirstChildOfClass("Humanoid");local root=char and char:FindFirstChild("HumanoidRootPart")
                    if humanoid and root and humanoid.Health>0 and (root.Position-Vector3.new(0,55,0)).Magnitude<=Config.Boss.AttackRange then
                        humanoid:TakeDamage(Config.Boss.AttackDamage)
                        root.AssemblyLinearVelocity=Vector3.new(0,7,0)
                        feedback(player,"BOSS_ATTACK","💥 БОСС УДАРИЛ! -"..Config.Boss.AttackDamage.." HP")
                    end
                end
            end
        end
    end)
    return true
end

return BossService
