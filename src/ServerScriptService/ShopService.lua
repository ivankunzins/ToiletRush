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
    local visual = character and character:FindFirstChild("LifebuoyVisual")
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

    local ring = Instance.new("Part")
    ring.Name = "LifebuoyVisual"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(4.2, 0.65, 4.2)
    ring.Color = Color3.fromRGB(255, 95, 65)
    ring.Material = Enum.Material.Neon
    ring.CanCollide = false
    ring.CanTouch = false
    ring.CanQuery = false
    ring.Massless = true
    ring.CFrame = root.CFrame * CFrame.new(0, -0.6, 0)
    ring.Parent = character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = ring
    weld.Part1 = root
    weld.Parent = ring
end

function ShopService:Reset()
    purchased = {}
    requestAt = {}
    for _, player in Players:GetPlayers() do
        player:SetAttribute("HasLifebuoy", false)
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

        local timeLeft = roundService:GetTimeLeft()
        if timeLeft > Config.Round.LifebuoyWindow then
            notify(player, "SHOP", "🛟 Спасательный круг доступен последние 20 секунд")
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
            notify(player, "SHOP_SUCCESS", "🛟 СПАСАТЕЛЬНЫЙ КРУГ КУПЛЕН!")
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
