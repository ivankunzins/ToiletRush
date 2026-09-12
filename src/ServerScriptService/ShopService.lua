local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local ShopService = {}
local purchased = {}
local requestAt = {}
local feedback = nil

local function notify(player, kind, text)
    if feedback then
        feedback:FireClient(player, kind, text)
    end
end

local function removeBuoy(player)
    local character = player.Character
    if not character then return end
    local visual = character:FindFirstChild("LifebuoyVisual")
    if visual then
        visual:Destroy()
    end
end

local function addBuoy(player)
    if player:GetAttribute("Eliminated") == true then
        return
    end

    local character = player.Character
    if not character or character:FindFirstChild("LifebuoyVisual") then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local model = Instance.new("Model")
    model.Name = "LifebuoyVisual"
    model.Parent = character

    -- Approximate a real inflatable ring from welded rounded segments.
    local segments = 16
    local radius = 2.35
    for i = 1, segments do
        local angle = ((i - 1) / segments) * math.pi * 2
        local segment = Instance.new("Part")
        segment.Name = "RingSegment"
        segment.Shape = Enum.PartType.Cylinder
        segment.Size = Vector3.new(0.72, 1.35, 1.35)
        segment.Material = Enum.Material.SmoothPlastic
        segment.Color = (i % 4 == 1 or i % 4 == 2) and Color3.fromRGB(255, 82, 58) or Color3.fromRGB(248, 245, 230)
        segment.CanCollide = false
        segment.CanTouch = false
        segment.CanQuery = false
        segment.Massless = true
        segment.CFrame = root.CFrame * CFrame.new(math.cos(angle) * radius, -0.35, math.sin(angle) * radius) * CFrame.Angles(0, angle, math.rad(90))
        segment.Parent = model

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = segment
        weld.Part1 = root
        weld.Parent = segment
    end

    local hub = Instance.new("Part")
    hub.Name = "BuoyCenterGuide"
    hub.Size = Vector3.new(2.2, 0.35, 2.2)
    hub.Transparency = 1
    hub.CanCollide = false
    hub.CanTouch = false
    hub.CanQuery = false
    hub.Massless = true
    hub.CFrame = root.CFrame * CFrame.new(0, -0.35, 0)
    hub.Parent = model
    local hubWeld = Instance.new("WeldConstraint")
    hubWeld.Part0 = hub
    hubWeld.Part1 = root
    hubWeld.Parent = hub
end

function ShopService:Reset()
    purchased = {}
    requestAt = {}
    for _, player in Players:GetPlayers() do
        player:SetAttribute("HasLifebuoy", false)
        player:SetAttribute("LifebuoyUnlocked", false)
        removeBuoy(player)
    end
end

function ShopService:HasLifebuoy(player)
    return purchased[player] == true
end

function ShopService:Bind(remote, dataService, roundService, feedbackRemote)
    feedback = feedbackRemote

    remote.OnServerEvent:Connect(function(player)
        local now = os.clock()
        if now - (requestAt[player] or 0) < 0.4 then
            return
        end
        requestAt[player] = now

        if roundService.State ~= "ROUND" then
            notify(player, "SHOP", "Магазин откроется в конце раунда")
            return
        end
        if player:GetAttribute("RoundActive") ~= true or player:GetAttribute("Eliminated") == true then
            notify(player, "SHOP", "❌ Ты уже выбыл из этого раунда")
            return
        end

        if player:GetAttribute("LifebuoyUnlocked") ~= true then
            local collected = tonumber(player:GetAttribute("CoinsCollected")) or 0
            notify(player, "SHOP", "🪙 Собери ещё " .. math.max(0, Config.Economy.LifebuoyUnlockCollected - collected) .. " очков монет")
            return
        end

        local timeLeft = roundService:GetTimeLeft()
        if timeLeft > Config.Round.LifebuoyWindow then
            notify(player, "SHOP", "🛟 Сначала собери 30 очков. Покупка доступна последние 20 секунд")
            return
        end
        if self:HasLifebuoy(player) then
            notify(player, "SHOP", "🛟 Круг уже куплен")
            addBuoy(player)
            return
        end

        if dataService:SpendCoins(player, Config.Economy.LifebuoyCost) then
            purchased[player] = true
            player:SetAttribute("HasLifebuoy", true)
            addBuoy(player)
            notify(player, "SHOP_SUCCESS", "🛟 СПАСАТЕЛЬНЫЙ КРУГ КУПЛЕН — ТЫ СПАСЁН!")
        else
            notify(player, "SHOP_ERROR", "❌ Нужно 25 монет")
        end
    end)

    local function bindCharacter(player)
        player.CharacterAdded:Connect(function()
            task.defer(function()
                if self:HasLifebuoy(player) and player:GetAttribute("Eliminated") ~= true then
                    addBuoy(player)
                end
            end)
        end)
    end

    Players.PlayerAdded:Connect(bindCharacter)
    for _, player in Players:GetPlayers() do
        bindCharacter(player)
    end
end

function ShopService:Remove(player)
    purchased[player] = nil
    requestAt[player] = nil
    removeBuoy(player)
end

Players.PlayerRemoving:Connect(function(player)
    ShopService:Remove(player)
end)

return ShopService
