local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local ShopService = {}
local purchased = {}
local requestAt = {}
local feedback = nil

local function notify(player, kind, text)
    if feedback then feedback:FireClient(player, kind, text) end
end

local function removeBuoy(player)
    local character = player.Character
    if not character then return end
    local visual = character:FindFirstChild("LifebuoyVisual")
    if visual then visual:Destroy() end
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

    local segments = 20
    local radius = 2.25
    for i = 1, segments do
        local angle = ((i - 1) / segments) * math.pi * 2
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
        segment.CFrame = root.CFrame * CFrame.new(math.cos(angle) * radius, -0.25, math.sin(angle) * radius) * CFrame.Angles(0, angle, math.rad(90))
        segment.Parent = model
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = segment
        weld.Part1 = root
        weld.Parent = segment
    end

    local center = Instance.new("Part")
    center.Name = "BuoyCenter"
    center.Size = Vector3.new(1.8, 0.3, 1.8)
    center.Transparency = 1
    center.CanCollide = false
    center.CanTouch = false
    center.CanQuery = false
    center.Massless = true
    center.CFrame = root.CFrame * CFrame.new(0, -0.25, 0)
    center.Parent = model
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = center
    weld.Part1 = root
    weld.Parent = center
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
        if now - (requestAt[player] or 0) < 0.4 then return end
        requestAt[player] = now

        if roundService.State ~= "ROUND" or player:GetAttribute("RoundActive") ~= true then
            notify(player, "SHOP", "🛟 Круг можно купить только во время раунда")
            return
        end
        if player:GetAttribute("Eliminated") == true then
            notify(player, "SHOP", "❌ Ты сейчас не участвуешь")
            return
        end
        if player:GetAttribute("LifebuoyUnlocked") ~= true then
            local collected = tonumber(player:GetAttribute("CoinsCollected")) or 0
            notify(player, "SHOP", "🪙 Собери ещё " .. math.max(0, Config.Economy.LifebuoyUnlockCollected - collected) .. " очков")
            return
        end
        if self:HasLifebuoy(player) then
            notify(player, "SHOP", "🛟 Круг уже надет")
            addBuoy(player)
            return
        end

        if dataService:SpendCoins(player, Config.Economy.LifebuoyCost) then
            purchased[player] = true
            player:SetAttribute("HasLifebuoy", true)
            addBuoy(player)
            notify(player, "SHOP_SUCCESS", "🛟 СПАСАТЕЛЬНЫЙ КРУГ НАДЕТ — BIG FLUSH ТЕБЕ НЕ СТРАШЕН!")
        else
            notify(player, "SHOP_ERROR", "❌ Нужно 25 монет")
        end
    end)

    local function bindCharacter(player)
        player.CharacterAdded:Connect(function()
            task.defer(function()
                if self:HasLifebuoy(player) and player:GetAttribute("Eliminated") ~= true then addBuoy(player) end
            end)
        end)
    end

    Players.PlayerAdded:Connect(bindCharacter)
    for _, player in Players:GetPlayers() do bindCharacter(player) end
end

function ShopService:Remove(player)
    purchased[player] = nil
    requestAt[player] = nil
    removeBuoy(player)
end

Players.PlayerRemoving:Connect(function(player) ShopService:Remove(player) end)

return ShopService
