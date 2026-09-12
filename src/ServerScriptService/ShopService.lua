local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local ShopService = {}
local purchased = {}
local requestAt = {}

local function addBuoy(player)
    local character = player.Character
    if not character or character:FindFirstChild("LifebuoyVisual") then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local ring = Instance.new("Part")
    ring.Name = "LifebuoyVisual"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(4.2, 0.65, 4.2)
    ring.Color = Color3.fromRGB(255, 95, 65)
    ring.Material = Enum.Material.Neon
    ring.CanCollide = false
    ring.CanTouch = false
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
end

function ShopService:HasLifebuoy(player)
    return purchased[player] == true
end

function ShopService:Bind(remote, dataService, roundService)
    remote.OnServerEvent:Connect(function(player)
        local now = os.clock()
        if now - (requestAt[player] or 0) < 0.4 then return end
        requestAt[player] = now
        if roundService.State ~= "ROUND" then return end
        if roundService:GetTimeLeft() > Config.Round.LifebuoyWindow then return end
        if self:HasLifebuoy(player) then return end
        if dataService:SpendCoins(player, Config.Economy.LifebuoyCost) then
            purchased[player] = true
            player:SetAttribute("HasLifebuoy", true)
            addBuoy(player)
        end
    end)
end

function ShopService:Remove(player)
    purchased[player] = nil
    requestAt[player] = nil
end

return ShopService
