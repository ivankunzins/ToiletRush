local MarketplaceService=game:GetService("MarketplaceService")
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local Config=require(game.ReplicatedStorage:WaitForChild("Config"))
local Shop={};local bound=false
local PRODUCTS={Lifebuoy=Config.RobuxShop.LifebuoyPassId,Vest=Config.RobuxShop.VestPassId,Blaster=Config.RobuxShop.BlasterPassId}
local NAMES={Lifebuoy="🛟 СПАСАТЕЛЬНЫЙ КРУГ  •  10 ROBUX",Vest="🦺 СПАСАТЕЛЬНЫЙ ЖИЛЕТ  •  20 ROBUX",Blaster="🔫 БЛАСТЕР  •  40 ROBUX"}
local function feedback(player,kind,text)local rem=game.ReplicatedStorage:FindFirstChild("Remotes");local fb=rem and rem:FindFirstChild("Feedback");if fb then fb:FireClient(player,kind,text)end end
local function weld(part,torso)local w=Instance.new("WeldConstraint");w.Part0=part;w.Part1=torso;w.Parent=part end
local function piece(model,torso,name,size,cf,color,material,transparency)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.CastShadow=true;p.Parent=model;weld(p,torso);return p
end
local function giveLifebuoy(player)
    local char=player.Character;if not char or char:FindFirstChild("RobuxLifebuoyVisual") then return end
    local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso");if not torso then return end
    local model=Instance.new("Model");model.Name="RobuxLifebuoyVisual";model.Parent=char
    local ring=Instance.new("Part");ring.Name="LifebuoyRing";ring.Shape=Enum.PartType.Cylinder;ring.Size=Vector3.new(1.05,3.0,3.0);ring.CFrame=torso.CFrame*CFrame.new(0,0,1.35)*CFrame.Angles(0,math.rad(90),0);ring.Color=Color3.fromRGB(235,55,45);ring.Material=Enum.Material.SmoothPlastic;ring.CanCollide=false;ring.CanTouch=false;ring.CanQuery=false;ring.Massless=true;ring.Parent=model;weld(ring,torso)
    for i=0,3 do
        local stripe=piece(model,torso,"WhiteStripe",Vector3.new(1.1,.32,.42),torso.CFrame*CFrame.new(0,0,1.35)*CFrame.Angles(0,math.rad(90),math.rad(i*90)),Color3.fromRGB(248,248,242),Enum.Material.SmoothPlastic)
        stripe.Shape=Enum.PartType.Cylinder
    end
    local label=piece(model,torso,"LifebuoyBadge",Vector3.new(1.0,.16,1.0),torso.CFrame*CFrame.new(0,0,-1.2),Color3.fromRGB(255,255,255),Enum.Material.Neon)
    local gui=Instance.new("BillboardGui");gui.Name="LifebuoyBadge";gui.Size=UDim2.fromOffset(120,34);gui.StudsOffset=Vector3.new(0,2.35,0);gui.AlwaysOnTop=true;gui.Parent=label
    local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text="🛟 СПАСЁН";text.TextColor3=Color3.fromRGB(255,245,245);text.TextStrokeTransparency=.35;text.Font=Enum.Font.GothamBlack;text.TextScaled=true;text.Parent=gui
end
local function giveVest(player)
    local char=player.Character;if not char or char:FindFirstChild("RobuxVestVisual") then return end
    local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso");if not torso then return end
    local model=Instance.new("Model");model.Name="RobuxVestVisual";model.Parent=char
    local orange=Color3.fromRGB(245,105,25);local dark=Color3.fromRGB(38,42,46);local yellow=Color3.fromRGB(255,218,65);local white=Color3.fromRGB(245,245,240)
    piece(model,torso,"VestFront",Vector3.new(3.45,3.35,.34),torso.CFrame*CFrame.new(0,0,-.94),orange)
    piece(model,torso,"VestBack",Vector3.new(3.45,3.35,.34),torso.CFrame*CFrame.new(0,0,.94),orange)
    piece(model,torso,"ShoulderLeft",Vector3.new(.65,.38,2.15),torso.CFrame*CFrame.new(-1.05,1.43,0),orange)
    piece(model,torso,"ShoulderRight",Vector3.new(.65,.38,2.15),torso.CFrame*CFrame.new(1.05,1.43,0),orange)
    piece(model,torso,"WaistBand",Vector3.new(3.55,.48,2.0),torso.CFrame*CFrame.new(0,-1.05,0),orange)
    for _,x in ipairs({-.9,.9}) do piece(model,torso,"BlackStrap",Vector3.new(.3,3.55,2.02),torso.CFrame*CFrame.new(x,0,0),dark) end
    for _,x in ipairs({-.62,.62}) do piece(model,torso,"ReflectiveStripe",Vector3.new(.22,2.75,.38),torso.CFrame*CFrame.new(x,0,-1.13),yellow) end
    for _,x in ipairs({-.48,.48}) do piece(model,torso,"Buckle",Vector3.new(.42,.58,.22),torso.CFrame*CFrame.new(x,-.78,-1.16),dark,Enum.Material.Metal) end
    local badge=piece(model,torso,"SafetyBadge",Vector3.new(.62,.62,.08),torso.CFrame*CFrame.new(0,.45,-1.15),white,Enum.Material.Neon)
    local gui=Instance.new("BillboardGui");gui.Name="ProtectedBadge";gui.Size=UDim2.fromOffset(110,34);gui.StudsOffset=Vector3.new(0,2.45,0);gui.AlwaysOnTop=true;gui.Parent=badge
    local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text="🛡 ЗАЩИЩЁН";label.TextColor3=yellow;label.TextStrokeTransparency=.35;label.Font=Enum.Font.GothamBlack;label.TextScaled=true;label.Parent=gui
    piece(model,torso,"FloatLeft",Vector3.new(.72,1.05,.72),torso.CFrame*CFrame.new(-1.52,.45,0),orange)
    piece(model,torso,"FloatRight",Vector3.new(.72,1.05,.72),torso.CFrame*CFrame.new(1.52,.45,0),orange)
end
local function showShield(player)
    local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");if not root then return end
    local old=char:FindFirstChild("VestShieldEffect");if old then old:Destroy()end
    local s=Instance.new("Part");s.Name="VestShieldEffect";s.Shape=Enum.PartType.Ball;s.Size=Vector3.new(7,7,7);s.CFrame=root.CFrame;s.Anchored=false;s.CanCollide=false;s.CanTouch=false;s.CanQuery=false;s.Massless=true;s.Material=Enum.Material.ForceField;s.Color=Color3.fromRGB(255,220,60);s.Transparency=.55;s.Parent=char;weld(s,root)
    TweenService:Create(s,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(8.5,8.5,8.5),Transparency=1}):Play();task.delay(.3,function()if s and s.Parent then s:Destroy()end end)
end
local function giveBlaster(player)
    local backpack=player:FindFirstChildOfClass("Backpack");if not backpack then return end
    if backpack:FindFirstChild("FlushBlaster") or (player.Character and player.Character:FindFirstChild("FlushBlaster")) then return end
    local tool=Instance.new("Tool");tool.Name="FlushBlaster";tool.ToolTip="Водяной бластер — отталкивает соперника";tool.RequiresHandle=true;tool.CanBeDropped=false
    local h=Instance.new("Part");h.Name="Handle";h.Size=Vector3.new(.8,.8,2.8);h.Color=Color3.fromRGB(35,135,220);h.Material=Enum.Material.SmoothPlastic;h.CanCollide=false;h.Parent=tool
    local nozzle=Instance.new("Part");nozzle.Name="Nozzle";nozzle.Size=Vector3.new(.95,.95,.7);nozzle.CFrame=h.CFrame*CFrame.new(0,0,-1.65);nozzle.Color=Color3.fromRGB(210,230,245);nozzle.Material=Enum.Material.Metal;nozzle.CanCollide=false;nozzle.Parent=tool;local nw=Instance.new("WeldConstraint");nw.Part0=nozzle;nw.Part1=h;nw.Parent=nozzle
    local tank=Instance.new("Part");tank.Name="WaterTank";tank.Shape=Enum.PartType.Cylinder;tank.Size=Vector3.new(1.5,1.5,1.5);tank.CFrame=h.CFrame*CFrame.new(0,.85,.25)*CFrame.Angles(0,math.rad(90),0);tank.Color=Color3.fromRGB(75,185,245);tank.Material=Enum.Material.Glass;tank.Transparency=.18;tank.CanCollide=false;tank.Parent=tool;local tw=Instance.new("WeldConstraint");tw.Part0=tank;tw.Part1=h;tw.Parent=tank
    local glow=Instance.new("PointLight");glow.Color=Color3.fromRGB(80,200,255);glow.Brightness=1.5;glow.Range=7;glow.Parent=nozzle
    local cd=false;tool.Activated:Connect(function()
        if cd then return end;cd=true;task.delay(.8,function()cd=false end)
        local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");if not root then return end
        local target,best=nil,45
        for _,other in Players:GetPlayers() do if other~=player and other:GetAttribute("RoundActive") and other.Character then local r=other.Character:FindFirstChild("HumanoidRootPart");if r then local d=r.Position-root.Position;local dist=d.Magnitude;if dist<best and dist>1 and root.CFrame.LookVector:Dot(d.Unit)>.35 then target,best=other,dist end end end end
        if target then
            local targetRoot=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                if target:GetAttribute("RobuxVest")==true then showShield(target);feedback(player,"BLASTER_BLOCKED","🦺 ЖИЛЕТ ЗАЩИТИЛ ИГРОКА!");feedback(target,"VEST_BLOCK","🛡 БЛАСТЕР ЗАБЛОКИРОВАН ЖИЛЕТОМ!")
                else targetRoot.AssemblyLinearVelocity=root.CFrame.LookVector*78+Vector3.new(0,14,0);feedback(target,"BLASTER_HIT","💦 ТЕБЯ ОТБРОСИЛИ БЛАСТЕРОМ!") end
            end
        end
    end);tool.Parent=backpack
end
local function grant(player,key)
    if key=="Lifebuoy" then player:SetAttribute("RobuxLifebuoy",true);giveLifebuoy(player)
    elseif key=="Vest" then player:SetAttribute("RobuxVest",true);giveVest(player)
    elseif key=="Blaster" then player:SetAttribute("RobuxBlaster",true);giveBlaster(player) end
end
local function passKey(passId)for key,id in pairs(PRODUCTS)do if tonumber(id) and tonumber(id)>0 and id==passId then return key end end end
function Shop:Apply(arena)
    local old=arena:FindFirstChild("RobuxShop");if old then old:Destroy()end
    local shop=Instance.new("Folder");shop.Name="RobuxShop";shop.Parent=arena
    local items={{"Lifebuoy",Vector3.new(-40,25,12),Color3.fromRGB(220,65,55)},{"Vest",Vector3.new(-25,25,12),Color3.fromRGB(245,145,45)},{"Blaster",Vector3.new(-10,25,12),Color3.fromRGB(45,145,220)}}
    for _,d in ipairs(items)do local key,pos,color=table.unpack(d)
        local stand=Instance.new("Part");stand.Name=key.."Stand";stand.Size=Vector3.new(12,2,9);stand.CFrame=CFrame.new(pos);stand.Anchored=true;stand.Material=Enum.Material.Marble;stand.Color=Color3.fromRGB(238,242,244);stand.Parent=shop
        local display=Instance.new("Part");display.Name=key.."Display";display.Size=Vector3.new(5,4,5);display.CFrame=CFrame.new(pos+Vector3.new(0,3,0));display.Anchored=true;display.Material=Enum.Material.SmoothPlastic;display.Color=color;display.Shape=Enum.PartType.Cylinder;display.Parent=shop
        local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(260,90);gui.StudsOffset=Vector3.new(0,4,0);gui.AlwaysOnTop=true;gui.Parent=display
        local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text=NAMES[key].."\nНажми E — купить";text.TextColor3=Color3.new(1,1,1);text.TextStrokeTransparency=.2;text.Font=Enum.Font.GothamBlack;text.TextScaled=true;text.Parent=gui
        local prompt=Instance.new("ProximityPrompt");prompt.Name="Buy";prompt.ActionText="КУПИТЬ";prompt.ObjectText=NAMES[key];prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=.15;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=display
        prompt.Triggered:Connect(function(player)local id=PRODUCTS[key];if not id or id<=0 then feedback(player,"SHOP_ERROR","Для товара не задан Game Pass ID.");return end;local ok,owned=pcall(function()return MarketplaceService:UserOwnsGamePassAsync(player.UserId,id)end);if ok and owned then grant(player,key);feedback(player,"SHOP_SUCCESS",NAMES[key].." — доступно!");return end;MarketplaceService:PromptGamePassPurchase(player,id)end)
    end
    arena:SetAttribute("RobuxShopReady",true)
end
function Shop:Bind()
    if bound then return end;bound=true
    local function restore(player)
        player.CharacterAdded:Connect(function()task.defer(function()if player:GetAttribute("RobuxLifebuoy")then giveLifebuoy(player)end;if player:GetAttribute("RobuxVest")then giveVest(player)end;if player:GetAttribute("RobuxBlaster")then giveBlaster(player)end end)end)
    end
    Players.PlayerAdded:Connect(restore);for _,p in Players:GetPlayers()do restore(p)end
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)if purchased then local key=passKey(passId);if key then grant(player,key);feedback(player,"SHOP_SUCCESS",NAMES[key].." — КУПЛЕНО!")end end end)
    for _,player in Players:GetPlayers()do task.spawn(function()for key,id in pairs(PRODUCTS)do if id and id>0 then local ok,owned=pcall(function()return MarketplaceService:UserOwnsGamePassAsync(player.UserId,id)end);if ok and owned then grant(player,key)end end end end)end
end
return Shop