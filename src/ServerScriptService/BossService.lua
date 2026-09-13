local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage:WaitForChild("Config"))
local BossService={Active=false,Defeated=false,Flushing=false,Health=0,Model=nil,Arena=nil,DamageBoss=nil,FlushPrompt=nil,_attackToken=0}
local function fb(p,k,t)local r=ReplicatedStorage:FindFirstChild("Remotes");local x=r and r:FindFirstChild("Feedback");if x and p then x:FireClient(p,k,t)end end
local function fba(k,t)local r=ReplicatedStorage:FindFirstChild("Remotes");local x=r and r:FindFirstChild("Feedback");if x then x:FireAllClients(k,t)end end
local function piece(m,n,s,cf,c,mat,shape)local p=Instance.new("Part");p.Name=n;p.Size=s;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true;p.CastShadow=true;p.Color=c;p.Material=mat or Enum.Material.SmoothPlastic;if shape then p.Shape=shape end;p.Parent=m;return p end
local function buildBoss(arena)
 local old=arena:FindFirstChild("BossArena");if old then old:Destroy()end
 local folder=Instance.new("Folder");folder.Name="BossArena";folder.Parent=arena
 local m=Instance.new("Model");m.Name="BathroomGuardian";m.Parent=folder
 local base=Vector3.new(0,26,0);local dark=Color3.fromRGB(72,50,39);local mid=Color3.fromRGB(112,76,53);local light=Color3.fromRGB(151,103,69)
 local core=piece(m,"Core",Vector3.new(25,25,25),CFrame.new(base+Vector3.new(0,18,0)),mid,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 piece(m,"ShoulderMass",Vector3.new(32,22,32),CFrame.new(base+Vector3.new(0,35,0)),dark,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 piece(m,"UpperMass",Vector3.new(28,23,28),CFrame.new(base+Vector3.new(0,51,0)),mid,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 piece(m,"CrownMass",Vector3.new(22,20,22),CFrame.new(base+Vector3.new(0,66,0)),light,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 local head=piece(m,"Face",Vector3.new(18,13,18),CFrame.new(base+Vector3.new(0,73,0)),mid,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 piece(m,"EyeL",Vector3.new(2.5,2.5,1.2),CFrame.new(base+Vector3.new(-4,75,-8)),Color3.fromRGB(245,220,125),Enum.Material.Neon,Enum.PartType.Ball)
 piece(m,"EyeR",Vector3.new(2.5,2.5,1.2),CFrame.new(base+Vector3.new(4,75,-8)),Color3.fromRGB(245,220,125),Enum.Material.Neon,Enum.PartType.Ball)
 piece(m,"Mouth",Vector3.new(7,2,1.3),CFrame.new(base+Vector3.new(0,70.5,-8)),Color3.fromRGB(42,29,24),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 local al=piece(m,"ArmL",Vector3.new(7,30,7),CFrame.new(base+Vector3.new(-22,47,0))*CFrame.Angles(0,0,math.rad(16)),dark,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
 local ar=piece(m,"ArmR",Vector3.new(7,30,7),CFrame.new(base+Vector3.new(22,47,0))*CFrame.Angles(0,0,math.rad(-16)),dark,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
 local hl=piece(m,"HandL",Vector3.new(10,7,10),CFrame.new(base+Vector3.new(-29,32,0)),light,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 local hr=piece(m,"HandR",Vector3.new(10,7,10),CFrame.new(base+Vector3.new(29,32,0)),light,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 m.PrimaryPart=core
 local gui=Instance.new("BillboardGui");gui.Name="BossLabel";gui.Size=UDim2.fromOffset(300,65);gui.StudsOffset=Vector3.new(0,5,0);gui.AlwaysOnTop=true;gui.Parent=head
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text="⚠ BOSS • 30 HP";text.TextColor3=Color3.fromRGB(255,224,120);text.TextStrokeTransparency=.2;text.Font=Enum.Font.GothamBlack;text.TextScaled=true;text.Parent=gui
 local lightObj=Instance.new("PointLight");lightObj.Name="BossLight";lightObj.Color=Color3.fromRGB(205,120,75);lightObj.Brightness=2.5;lightObj.Range=38;lightObj.Parent=head
 local hlgt=Instance.new("Highlight");hlgt.Name="BossHighlight";hlgt.FillColor=Color3.fromRGB(115,72,48);hlgt.FillTransparency=.8;hlgt.OutlineColor=Color3.fromRGB(245,175,90);hlgt.OutlineTransparency=.2;hlgt.Parent=m
 local aura=Instance.new("ParticleEmitter");aura.Name="BossDust";aura.Texture="rbxasset://textures/particles/smoke_main.dds";aura.Rate=8;aura.Lifetime=NumberRange.new(1.2,2.2);aura.Speed=NumberRange.new(2,5);aura.SpreadAngle=Vector2.new(360,360);aura.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,2),NumberSequenceKeypoint.new(1,5)});aura.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.65),NumberSequenceKeypoint.new(1,1)});aura.Parent=core
 local eyeGlow=Instance.new("PointLight");eyeGlow.Name="EyeGlow";eyeGlow.Color=Color3.fromRGB(255,210,90);eyeGlow.Brightness=1.5;eyeGlow.Range=14;eyeGlow.Parent=head
 local drain=Instance.new("Part");drain.Name="BossDrain";drain.Shape=Enum.PartType.Cylinder;drain.Size=Vector3.new(1.2,32,32);drain.CFrame=CFrame.new(0,13.3,0)*CFrame.Angles(0,0,math.rad(90));drain.Anchored=true;drain.Material=Enum.Material.Metal;drain.Color=Color3.fromRGB(55,61,66);drain.CanCollide=false;drain.Parent=folder
 return m,folder,{armL=al,armR=ar,handL=hl,handR=hr,head=head,base=base,handLCF=hl.CFrame,handRCF=hr.CFrame,armLCF=al.CFrame,armRCF=ar.CFrame}
end
local function spawnStones(arena,damageFn)
 local folder=Instance.new("Folder");folder.Name="BossStones";folder.Parent=arena:FindFirstChild("BossArena") or arena
 local floors={22,40,58,76,94};local index=0
 for floor,y in ipairs(floors) do for j=1,6 do index+=1;local a=math.rad((floor*73+j*47)%360);local pos=Vector3.new(math.cos(a)*74,y+3,math.sin(a)*74)
  local rock=Instance.new("Part");rock.Name="Stone_"..index;rock.Shape=Enum.PartType.Ball;rock.Size=Vector3.new(3.5,3.5,3.5);rock.CFrame=CFrame.new(pos);rock.Anchored=true;rock.Material=Enum.Material.Slate;rock.Color=Color3.fromRGB(105,103,98);rock.Parent=folder
  local p=Instance.new("ProximityPrompt");p.Name="ThrowStone";p.ActionText="БРОСИТЬ";p.ObjectText="КАМЕНЬ • 1 УДАР";p.KeyboardKeyCode=Enum.KeyCode.E;p.HoldDuration=.15;p.MaxActivationDistance=9;p.RequiresLineOfSight=false;p.Parent=rock
  p.Triggered:Connect(function(player)if not BossService.Active or BossService.Defeated or not rock.Parent then return end;local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not root or(root.Position-rock.Position).Magnitude>11 then return end;p.Enabled=false;rock.Transparency=1;rock.CanQuery=false;damageFn(player,Config.Boss.StoneDamage,"STONE");fb(player,"BOSS_STONE","🪨 ПОПАДАНИЕ! БОСС ПОТЕРЯЛ 1 HP");task.delay(.35,function()if rock and rock.Parent then rock:Destroy()end end)end)
 end end
end
function BossService:GetHealth()return self.Health end
function BossService:IsDefeated()return self.Defeated end
function BossService:Damage(amount,player,source)
 if not self.Active or self.Defeated then return false end;amount=math.max(0,tonumber(amount)or 0);if amount<=0 then return false end;self.Health=math.max(0,self.Health-amount)
 local m=self.Model;local h=m and m:FindFirstChild("Face");if h then local g=h:FindFirstChild("BossLabel");local l=g and g:FindFirstChildOfClass("TextLabel");if l then l.Text="⚠ BOSS • "..self.Health.." HP"end;local flash=Instance.new("Highlight");flash.FillColor=Color3.fromRGB(255,240,180);flash.FillTransparency=.3;flash.OutlineTransparency=1;flash.Parent=m;task.delay(.14,function()if flash.Parent then flash:Destroy()end end)end;if player then fb(player,"BOSS_HIT",source=="BLASTER" and "🔫 ПОПАДАНИЕ! -"..amount.." HP" or "🪨 КАМЕНЬ ПОПАЛ! -"..amount.." HP")end;if self.Health<=0 then self:Defeat()end;return true
end
function BossService:Defeat()if self.Defeated then return end;self.Defeated=true;self.Active=false;self.Flushing=false;self._attackToken+=1;fba("BOSS_DEFEATED","🏆 BOSS ПОБЕЖДЁН! ПУТЬ ПРОЙДЕН!");if self.Model and self.Model.Parent then local pivot=self.Model:GetPivot();local d=Instance.new("CFrameValue");d.Value=pivot;d:GetPropertyChangedSignal("Value"):Connect(function()if self.Model.Parent then self.Model:PivotTo(d.Value)end end);TweenService:Create(d,TweenInfo.new(1.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Value=pivot*CFrame.new(0,-8,0)*CFrame.Angles(0,math.rad(180),0)}):Play();task.delay(1.6,function()if d.Parent then d:Destroy()end end)end end
function BossService:TriggerFlush(player)
 if not self.Active or self.Defeated or self.Flushing then return false end;local root=player and player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not root or(root.Position-Vector3.new(0,102,-72)).Magnitude>20 then return false end
 self.Flushing=true;fba("BOSS_FLUSH","🚽 БОСС СМЫВАЕТСЯ! 10 СЕКУНД НЕ БЬЁТ!");local m=self.Model;if m and m.Parent then local start=m:GetPivot();local down=start*CFrame.new(0,-42,0)*CFrame.Angles(math.rad(8),0,math.rad(5));local d=Instance.new("CFrameValue");d.Value=start;d:GetPropertyChangedSignal("Value"):Connect(function()if m.Parent then m:PivotTo(d.Value)end end);TweenService:Create(d,TweenInfo.new(1,Enum.EasingStyle.Quad),{Value=down}):Play();task.wait(1);local r=self.Refs;r.handL.CFrame=CFrame.new(-17,23,0);r.handR.CFrame=CFrame.new(17,23,0);r.armL.CFrame=CFrame.new(-11,31,0)*CFrame.Angles(0,0,math.rad(68));r.armR.CFrame=CFrame.new(11,31,0)*CFrame.Angles(0,0,math.rad(-68));task.wait(Config.Boss.FlushHoldSeconds-1);if self.Defeated then d:Destroy();return true end;local up=down*CFrame.new(0,42,0)*CFrame.Angles(math.rad(-8),0,math.rad(-5));TweenService:Create(d,TweenInfo.new(Config.Boss.FlushRecoverySeconds,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Value=up}):Play();task.wait(Config.Boss.FlushRecoverySeconds);d:Destroy();r.handL.CFrame=r.handLCF;r.handR.CFrame=r.handRCF;r.armL.CFrame=r.armLCF;r.armR.CFrame=r.armRCF end;self.Flushing=false;if self.Active and not self.Defeated then fba("BOSS_RETURN","⚠ БОСС ВЫБРАЛСЯ! БЕГИТЕ!")end;return true
end
function BossService:Start(arena)
 self.Active=true;self.Defeated=false;self.Flushing=false;self.Health=Config.Boss.Health;self.Arena=arena;local m,folder,refs=buildBoss(arena);self.Model=m;self.Refs=refs;self.DamageBoss=Instance.new("BindableFunction");self.DamageBoss.Name="DamageBoss";self.DamageBoss.Parent=folder;self.DamageBoss.OnInvoke=function(player,amount,source)return self:Damage(amount,player,source)end;spawnStones(arena,function(player,amount,source)return self:Damage(amount,player,source)end);fba("BOSS_START","⚠ BOSS ПОЯВИЛСЯ! БЛАСТЕР = 10 ПОПАДАНИЙ • КАМНИ = 30 ПОПАДАНИЙ")
 self._attackToken+=1;local token=self._attackToken;task.spawn(function()while self.Active and not self.Defeated and token==self._attackToken do task.wait(Config.Boss.AttackInterval);if not self.Active or self.Defeated or self.Flushing then continue end;local t=refs.head.Position;local pulse=Instance.new("Part");pulse.Shape=Enum.PartType.Ball;pulse.Size=Vector3.new(10,10,10);pulse.Anchored=true;pulse.CanCollide=false;pulse.CanTouch=false;pulse.Material=Enum.Material.Neon;pulse.Color=Color3.fromRGB(230,150,70);pulse.Transparency=.55;pulse.CFrame=CFrame.new(t);pulse.Parent=folder;TweenService:Create(pulse,TweenInfo.new(.45,Enum.EasingStyle.Quad),{Size=Vector3.new(34,34,34),Transparency=1}):Play();task.delay(.5,function()if pulse.Parent then pulse:Destroy()end end);local aim=math.random()*math.pi*2;for _,player in ipairs(Players:GetPlayers())do if player:GetAttribute("RoundActive")==true and player:GetAttribute("Eliminated")~=true then local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");local root=char and char:FindFirstChild("HumanoidRootPart");if hum and root and hum.Health>0 and(root.Position-Vector3.new(0,55,0)).Magnitude<=Config.Boss.AttackRange then hum:TakeDamage(Config.Boss.AttackDamage);root.AssemblyLinearVelocity=Vector3.new(math.cos(aim)*18,10,math.sin(aim)*18);fb(player,"BOSS_ATTACK","💥 БОСС УДАРИЛ! -"..Config.Boss.AttackDamage.." HP")end end end end end)
 return true
end
return BossService