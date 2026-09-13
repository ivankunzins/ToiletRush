local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Shop = {}

-- Replace the 0 values with Developer Product IDs created in Creator Dashboard.
local PRODUCTS = {
    Lifebuoy = 0,
    Vest = 0,
    Blaster = 0,
}

local NAMES = {
    Lifebuoy = "🛟 СПАСАТЕЛЬНЫЙ КРУГ  •  10 ROBUX",
    Vest = "🦺 СПАСАТЕЛЬНЫЙ ЖИЛЕТ  •  20 ROBUX",
    Blaster = "🔫 БЛАСТЕР  •  40 ROBUX",
}

local pending = {}
local bound = false

local function giveBlaster(player)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    if backpack:FindFirstChild("FlushBlaster") or (player.Character and player.Character:FindFirstChild("FlushBlaster")) then return end
    local tool = Instance.new("Tool")
    tool.Name = "FlushBlaster"
    tool.ToolTip = "Отталкивает игроков водой"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.7,0.7,2.6)
    handle.Color = Color3.fromRGB(40,145,220)
    handle.Material = Enum.Material.SmoothPlastic
    handle.CanCollide = false
    handle.Parent = tool
    tool.Activated:Connect(function()
        local character=player.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local origin=root.Position
        local best,bestDist=nil,45
        for _,other in Players:GetPlayers() do
            if other~=player and other:GetAttribute("RoundActive") and other.Character then
                local r=other.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local delta=r.Position-origin
                    local dist=delta.Magnitude
                    if dist<bestDist and dist>1 and root.CFrame.LookVector:Dot(delta.Unit)>0.35 then best,bestDist=other,dist end
                end
            end
        end
        if best then
            local r=best.Character and best.Character:FindFirstChild("HumanoidRootPart")
            if r then r.AssemblyLinearVelocity=root.CFrame.LookVector*75+Vector3.new(0,12,0) end
        end
    end)
    tool.Parent=backpack
end

local function grant(player, key)
    if key=="Lifebuoy" then
        player:SetAttribute("RobuxLifebuoy",true)
    elseif key=="Vest" then
        player:SetAttribute("RobuxVest",true)
    elseif key=="Blaster" then
        player:SetAttribute("RobuxBlaster",true)
        giveBlaster(player)
    end
end

local function productKey(productId)
    for key,id in pairs(PRODUCTS) do if id>0 and id==productId then return key end end
    return nil
end

function Shop:Apply(arena)
    local old=arena:FindFirstChild("RobuxShop")
    if old then old:Destroy() end
    local shop=Instance.new("Folder")
    shop.Name="RobuxShop"
    shop.Parent=arena
    local items={
        {"Lifebuoy",Vector3.new(-40,25,12),Color3.fromRGB(220,65,55),"🛟"},
        {"Vest",Vector3.new(-25,25,12),Color3.fromRGB(245,145,45),"🦺"},
        {"Blaster",Vector3.new(-10,25,12),Color3.fromRGB(45,145,220),"🔫"},
    }
    for _,d in ipairs(items) do
        local key,pos,color,icon=table.unpack(d)
        local pedestal=Instance.new("Part")
        pedestal.Name=key.."Stand";pedestal.Size=Vector3.new(12,2,9);pedestal.CFrame=CFrame.new(pos);pedestal.Anchored=true;pedestal.Material=Enum.Material.Marble;pedestal.Color=Color3.fromRGB(240,243,245);pedestal.Parent=shop
        local display=Instance.new("Part")
        display.Name=key.."Display";display.Size=Vector3.new(5,4,5);display.CFrame=CFrame.new(pos+Vector3.new(0,3,0));display.Anchored=true;display.Material=Enum.Material.SmoothPlastic;display.Color=color;display.Shape=Enum.PartType.Cylinder;display.Parent=shop
        local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(240,80);gui.StudsOffset=Vector3.new(0,4,0);gui.AlwaysOnTop=true;gui.Parent=display
        local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=NAMES[key];label.TextColor3=Color3.new(1,1,1);label.TextStrokeTransparency=0.2;label.Font=Enum.Font.GothamBlack;label.TextScaled=true;label.Parent=gui
        local prompt=Instance.new("ProximityPrompt");prompt.Name="Buy";prompt.ActionText="КУПИТЬ";prompt.ObjectText=NAMES[key];prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=0.15;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=display
        prompt.Triggered:Connect(function(player)
            local id=PRODUCTS[key]
            if id<=0 then
                local rem=game.ReplicatedStorage:FindFirstChild("Remotes")
                local fb=rem and rem:FindFirstChild("Feedback")
                if fb then fb:FireClient(player,"SHOP_ERROR","Настройте Product ID для "..key.." в Creator Dashboard") end
                return
            end
            pending[player.UserId]=key
            MarketplaceService:PromptProductPurchase(player,id)
        end)
    end
    arena:SetAttribute("RobuxShopReady",true)
end

function Shop:Bind()
    if bound then return end
    bound=true
    MarketplaceService.ProcessReceipt=function(receipt)
        local player=Players:GetPlayerByUserId(receipt.PlayerId)
        if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local key=productKey(receipt.ProductId)
        if not key then return Enum.ProductPurchaseDecision.NotProcessedYet end
        grant(player,key)
        pending[player.UserId]=nil
        local rem=game.ReplicatedStorage:FindFirstChild("Remotes")
        local fb=rem and rem:FindFirstChild("Feedback")
        if fb then fb:FireClient(player,"SHOP_SUCCESS",NAMES[key].." — ГОТОВО!") end
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.defer(function()
                if player:GetAttribute("RobuxBlaster") then giveBlaster(player) end
            end)
        end)
    end)
end

return Shop