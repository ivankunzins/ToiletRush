local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local ShopService = {}
local purchasedBuoy = {}
local inventory = {}
local requestAt = {}
local feedback = nil

local function notify(player, kind, message)
    if feedback then feedback:FireClient(player, kind, message) end
end

local function hasBuoy(player)
    return purchasedBuoy[player] == true or player:GetAttribute("RobuxLifebuoy") == true
end

local function removeModel(character, name)
    local model = character and character:FindFirstChild(name)
    if model then model:Destroy() end
end

local function removeBuoy(player)
    removeModel(player.Character, "LifebuoyVisual")
end

local function addBuoy(player)
    if player:GetAttribute("Eliminated") == true then return end
    local character = player.Character
    if not character or character:FindFirstChild("LifebuoyVisual") then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local model = Instance.new("Model")
    model.Name = "LifebuoyVisual"
    model.Parent = character
    for i = 1, 20 do
        local angle = ((i - 1) / 20) * math.pi * 2
        local segment = Instance.new("Part")
        segment.Name = "RingSegment"
        segment.Shape = Enum.PartType.Cylinder
        segment.Size = Vector3.new(0.62, 1.42, 1.42)
        segment.Material = Enum.Material.SmoothPlastic
        segment.Color = (i % 4 <= 2) and Color3.fromRGB(245, 65, 45) or Color3.fromRGB(248, 245, 225)
        segment.CanCollide = false
        segment.CanTouch = false
        segment.CanQuery = false
        segment.Massless = true
        segment.CFrame = root.CFrame * CFrame.new(math.cos(angle) * 2.25, -0.25, math.sin(angle) * 2.25) * CFrame.Angles(0, angle, math.rad(90))
        segment.Parent = model
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = segment
        weld.Part1 = root
        weld.Parent = segment
    end
end

local function removePistol(player)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild("CoinPistol")
        if tool then tool:Destroy() end
    end
    removeModel(player.Character, "CoinPistol")
end

local function givePistol(player)
    if player:GetAttribute("HasPistol") ~= true then return end
    local backpack = player:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    if backpack:FindFirstChild("CoinPistol") or (player.Character and player.Character:FindFirstChild("CoinPistol")) then return end
    local tool = Instance.new("Tool")
    tool.Name = "CoinPistol"
    tool.ToolTip = "Пистолет для борьбы с Хранителем и его помощниками"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.65, 0.7, 2.1)
    handle.Color = Color3.fromRGB(45, 65, 82)
    handle.Material = Enum.Material.Metal
    handle.CanCollide = false
    handle.CanTouch = false
    handle.Massless = true
    handle.Parent = tool
    local barrel = Instance.new("Part")
    barrel.Name = "Barrel"
    barrel.Size = Vector3.new(0.32, 0.32, 1.1)
    barrel.CFrame = handle.CFrame * CFrame.new(0, 0.08, -1.25)
    barrel.Color = Color3.fromRGB(75, 190, 235)
    barrel.Material = Enum.Material.Neon
    barrel.CanCollide = false
    barrel.CanTouch = false
    barrel.Massless = true
    barrel.Parent = tool
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = barrel
    weld.Parent = barrel
    tool.Parent = backpack
end

local function removeVest(player)
    removeModel(player.Character, "RoundVestVisual")
end

local function addVest(player)
    if player:GetAttribute("HasVest") ~= true then return end
    local character = player.Character
    if not character or character:FindFirstChild("RoundVestVisual") then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not torso then return end
    local model = Instance.new("Model")
    model.Name = "RoundVestVisual"
    model.Parent = character
    local parts = {
        {"VestFront", Vector3.new(2.15, 2.25, 0.28), CFrame.new(0, 0, -0.58), Color3.fromRGB(245, 115, 35)},
        {"VestBack", Vector3.new(2.15, 2.25, 0.28), CFrame.new(0, 0, 0.58), Color3.fromRGB(220, 90, 25)},
        {"VestStrapL", Vector3.new(0.25, 2.3, 1.1), CFrame.new(-0.72, 0, 0), Color3.fromRGB(35, 40, 45)},
        {"VestStrapR", Vector3.new(0.25, 2.3, 1.1), CFrame.new(0.72, 0, 0), Color3.fromRGB(35, 40, 45)},
    }
    for _, item in ipairs(parts) do
        local part = Instance.new("Part")
        part.Name = item[1]
        part.Size = item[2]
        part.CFrame = torso.CFrame * item[3]
        part.Color = item[4]
        part.Material = Enum.Material.SmoothPlastic
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Massless = true
        part.Parent = model
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = part
        weld.Part1 = torso
        weld.Parent = part
    end
end

local function restoreEquipment(player)
    if player:GetAttribute("RoundActive") ~= true then return end
    if player:GetAttribute("HasPistol") == true then givePistol(player) end
    if player:GetAttribute("HasVest") == true then addVest(player) end
    if purchasedBuoy[player] == true then addBuoy(player) end
end

function ShopService:PrepareRound(players)
    for _, player in ipairs(players) do
        inventory[player] = inventory[player] or {Pistol = false, Vest = false}
        purchasedBuoy[player] = nil
        player:SetAttribute("HasLifebuoy", player:GetAttribute("RobuxLifebuoy") == true)
        player:SetAttribute("HasPistol", inventory[player].Pistol == true)
        player:SetAttribute("HasVest", inventory[player].Vest == true)
        removeBuoy(player)
        removeVest(player)
        if inventory[player].Pistol then givePistol(player) else removePistol(player) end
        if inventory[player].Vest then addVest(player) end
    end
end

function ShopService:FinishRound(player)
    local state = inventory[player] or {Pistol = false, Vest = false}
    local protected = hasBuoy(player)
    state.Pistol = protected and player:GetAttribute("HasPistol") == true or false
    state.Vest = protected and player:GetAttribute("HasVest") == true or false
    inventory[player] = state
    removePistol(player)
    removeVest(player)
    removeBuoy(player)
    purchasedBuoy[player] = nil
    player:SetAttribute("HasPistol", false)
    player:SetAttribute("HasVest", false)
    player:SetAttribute("HasLifebuoy", player:GetAttribute("RobuxLifebuoy") == true)
end

function ShopService:Bind(remote, dataService, roundService, feedbackRemote)
    feedback = feedbackRemote
    local function bindCharacter(player)
        inventory[player] = inventory[player] or {Pistol = false, Vest = false}
        player:SetAttribute("HasPistol", player:GetAttribute("HasPistol") == true)
        player:SetAttribute("HasVest", player:GetAttribute("HasVest") == true)
        player.CharacterAdded:Connect(function()
            task.defer(function() restoreEquipment(player) end)
        end)
    end
    Players.PlayerAdded:Connect(bindCharacter)
    for _, player in ipairs(Players:GetPlayers()) do bindCharacter(player) end

    remote.OnServerEvent:Connect(function(player, action)
        local now = os.clock()
        if now - (requestAt[player] or 0) < 0.3 then return end
        requestAt[player] = now
        action = action or "Lifebuoy"
        if action ~= "Lifebuoy" and action ~= "Pistol" and action ~= "Vest" and action ~= "Heal" then return end
        if roundService.State ~= "ROUND" and roundService.State ~= "BOSS" then
            notify(player, "SHOP_ERROR", "Магазин доступен только во время раунда.")
            return
        end
        if player:GetAttribute("RoundActive") ~= true or player:GetAttribute("Eliminated") == true then
            notify(player, "SHOP_ERROR", "Сейчас нельзя покупать снаряжение.")
            return
        end
        inventory[player] = inventory[player] or {Pistol = false, Vest = false}
        local price, itemName
        if action == "Lifebuoy" then
            if hasBuoy(player) then
                notify(player, "SHOP", "🛟 Круг уже есть. Он сохранит оружие и жилет на следующий раунд.")
                return
            end
            price, itemName = Config.Economy.LifebuoyCost, "спасательный круг"
        elseif action == "Pistol" then
            if player:GetAttribute("HasPistol") == true then
                notify(player, "SHOP", "🔫 Пистолет уже куплен.")
                return
            end
            price, itemName = Config.Economy.PistolCost, "пистолет"
        elseif action == "Vest" then
            if player:GetAttribute("HasVest") == true or player:GetAttribute("RobuxVest") == true then
                notify(player, "SHOP", "🦺 Жилет уже есть.")
                return
            end
            price, itemName = Config.Economy.VestCost, "бронежилет"
        else
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                notify(player, "SHOP_ERROR", "Нельзя пополнить здоровье сейчас.")
                return
            end
            if humanoid.Health >= humanoid.MaxHealth then
                notify(player, "SHOP", "❤️ Здоровье уже полное.")
                return
            end
            price, itemName = Config.Economy.HealCost, "пополнение здоровья"
        end

        if not dataService:SpendCoins(player, price) then
            notify(player, "SHOP_ERROR", ("Не хватает монет: %s стоит %d."):format(itemName, price))
            return
        end

        if action == "Lifebuoy" then
            purchasedBuoy[player] = true
            player:SetAttribute("HasLifebuoy", true)
            addBuoy(player)
            notify(player, "SHOP_SUCCESS", "🛟 Круг куплен за 60 монет: он сохранит пистолет и жилет на следующий раунд.")
        elseif action == "Pistol" then
            player:SetAttribute("HasPistol", true)
            inventory[player].Pistol = true
            givePistol(player)
            notify(player, "SHOP_SUCCESS", "🔫 Пистолет куплен за 30 монет. Он наносит урон боссу и его помощникам.")
        elseif action == "Vest" then
            player:SetAttribute("HasVest", true)
            inventory[player].Vest = true
            addVest(player)
            notify(player, "SHOP_SUCCESS", "🦺 Жилет куплен за 35 монет. Он спасает от одного попадания помощника, но не от босса.")
        elseif action == "Heal" then
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then humanoid.Health = humanoid.MaxHealth end
            notify(player, "SHOP_SUCCESS", "❤️ Здоровье полностью восстановлено за 25 монет.")
        end
    end)
end

function ShopService:Remove(player)
    inventory[player] = nil
    purchasedBuoy[player] = nil
    requestAt[player] = nil
    removeBuoy(player)
    removeVest(player)
    removePistol(player)
end

Players.PlayerRemoving:Connect(function(player) ShopService:Remove(player) end)

return ShopService
