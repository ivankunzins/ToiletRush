local MarketplaceService=game:GetService("MarketplaceService")
local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage:WaitForChild("Config"))

local Shop={}
local bound=false

local PRODUCTS={
    Lifebuoy=Config.RobuxShop.LifebuoyPassId,
    Vest=Config.RobuxShop.VestPassId,
    Blaster=Config.RobuxShop.BlasterPassId,
}
local NAMES={
    Lifebuoy="🛟 СПАСАТЕЛЬНЫЙ КРУГ  •  10 ROBUX",
    Vest="🦺 СПАСАТЕЛЬНЫЙ ЖИЛЕТ  •  20 ROBUX",
    Blaster="🔫 БЛАСТЕР  •  40 ROBUX",
}

local function feedback(player,kind,text)
    local rem=game.ReplicatedStorage:FindFirstChild("Remotes")
    local fb=rem and rem:FindFirstChild("Feedback")
    if fb then fb:FireClient(player,kind,text) end
end

local function giveBlaster(player)
    local backpack=player:FindFirstChildOfClass("Backpack");if not backpack then return end
    if backpack:FindFirstChild("FlushBlaster") or (player.Character and player.Character:FindFirstChild("FlushBlaster")) then return end
    local tool=Instance.new("Tool");tool.Name="FlushBlaster";tool.ToolTip="Водяной бластер — отталкивает соперника";tool.RequiresHandle=true;tool.CanBeDropped=false
    local handle=Instance.new("Part");handle.Name="Handle";handle.Size=Vector3.new(0.8,0.8,2.8);handle.Color=Color3.fromRGB(45,145,220);handle.Material=Enum.Material.SmoothPlastic;handle.CanCollide=false;handle.Parent=tool
    local cooldown=false
    tool.Activated:Connect(function()
        if cooldown then return end;cooldown=true;task.delay(0.8,function()cooldown=false end)
        local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");if not root then return end
        local target,best=nil,45
        for _,other in Players:GetPlayers() do
            if other~=player and other:GetAttribute("RoundActive") and other.Character then
                local r=other.Character:FindFirstChild("HumanoidRootPart")
                if r then local d=r.Position-root.Position;local dist=d.Magnitude;if dist<best and dist>1 and root.CFrame.LookVector:Dot(d.Unit)>0.35 then target,best=other,dist end end
            end
        end
        if target then local r=target.Character and target.Character:FindFirstChild("HumanoidRootPart");if r then r.AssemblyLinearVelocity=root.CFrame.LookVector*78+Vector3.new(0,14,0) end end
    end)
    tool.Parent=backpack
end

local function grant(player,key)
    if key=="Lifebuoy" then player:SetAttribute("RobuxLifebuoy",true)
    elseif key=="Vest" then player:SetAttribute("RobuxVest",true)
    elseif key=="Blaster" then player:SetAttribute("RobuxBlaster",true);giveBlaster(player) end
end

local function passKey(passId)
    for key,id in pairs(PRODUCTS) do if tonumber(id) and tonumber(id)>0 and id==passId then return key end end
end

function Shop:Apply(arena)
    local old=arena:FindFirstChild("RobuxShop");if old then old:Destroy() end
    local shop=Instance.new("Folder");shop.Name="RobuxShop";shop.Parent=arena
    local items={
        {"Lifebuoy",Vector3.new(-40,25,12),Color3.fromRGB(220,65,55)},
        {"Vest",Vector3.new(-25,25,12),Color3.fromRGB(245,145,45)},
        {"Blaster",Vector3.new(-10,25,12),Color3.fromRGB(45,145,220)},
    }
    for _,d in ipairs(items) do
        local key,pos,color=table.unpack(d)
        local stand=Instance.new("Part");stand.Name=key.."Stand";stand.Size=Vector3.new(12,2,9);stand.CFrame=CFrame.new(pos);stand.Anchored=true;stand.Material=Enum.Material.Marble;stand.Color=Color3.fromRGB(238,242,244);stand.Parent=shop
        local display=Instance.new("Part");display.Name=key.."Display";display.Size=Vector3.new(5,4,5);display.CFrame=CFrame.new(pos+Vector3.new(0,3,0));display.Anchored=true;display.Material=Enum.Material.SmoothPlastic;display.Color=color;display.Shape=Enum.PartType.Cylinder;display.Parent=shop
        local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(260,90);gui.StudsOffset=Vector3.new(0,4,0);gui.AlwaysOnTop=true;gui.Parent=display
        local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text=NAMES[key].."\nНажми E — купить";text.TextColor3=Color3.new(1,1,1);text.TextStrokeTransparency=0.2;text.Font=Enum.Font.GothamBlack;text.TextScaled=true;text.Parent=gui
        local prompt=Instance.new("ProximityPrompt");prompt.Name="Buy";prompt.ActionText="КУПИТЬ";prompt.ObjectText=NAMES[key];prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=0.15;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=display
        prompt.Triggered:Connect(function(player)
            local id=PRODUCTS[key]
            if not id or id<=0 then feedback(player,"SHOP_ERROR","Для товара не задан Game Pass ID. Добавим ID после создания Pass.");return end
            local ok,owned=pcall(function() return MarketplaceService:UserOwnsGamePassAsync(player.UserId,id) end)
            if ok and owned then grant(player,key);feedback(player,"SHOP_SUCCESS",NAMES[key].." — уже куплено и доступно!");return end
            MarketplaceService:PromptGamePassPurchase(player,id)
        end)
    end
    arena:SetAttribute("RobuxShopReady",true)
end

function Shop:Bind()
    if bound then return end;bound=true
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function() task.defer(function() if player:GetAttribute("RobuxBlaster") then giveBlaster(player) end end) end)
    end)
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
        if not purchased then return end
        local key=passKey(passId)
        if key then grant(player,key);feedback(player,"SHOP_SUCCESS",NAMES[key].." — КУПЛЕНО!") end
    end)
    for _,player in Players:GetPlayers() do
        task.spawn(function()
            for key,id in pairs(PRODUCTS) do
                if id and id>0 then
                    local ok,owned=pcall(function() return MarketplaceService:UserOwnsGamePassAsync(player.UserId,id) end)
                    if ok and owned then grant(player,key) end
                end
            end
        end)
    end
end

return Shop