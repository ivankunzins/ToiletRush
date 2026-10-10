local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local buyRemote = remotes:WaitForChild("BuyLifebuoy")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local gui = Instance.new("ScreenGui")
gui.Name = "RoundShopUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 26
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "ShopPanel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.fromScale(0.5, 0.985)
panel.Size = UDim2.fromScale(0.58, 0.205)
panel.BackgroundColor3 = Color3.fromRGB(18, 26, 34)
panel.BackgroundTransparency = 0.06
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Transparency = 0.25
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(0.96, 0.19)
title.Position = UDim2.fromScale(0.02, 0.02)
title.BackgroundTransparency = 1
title.Text = "🛒 МАГАЗИН • КРУГ СОХРАНЯЕТ СНАРЯЖЕНИЕ"
title.TextColor3 = Color3.fromRGB(255, 225, 95)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Parent = panel

local buttons = {}
local definitions = {
    {key = "Pistol", price = Config.Economy.PistolCost},
    {key = "Vest", price = Config.Economy.VestCost},
    {key = "Heal", price = Config.Economy.HealCost},
    {key = "Lifebuoy", price = Config.Economy.LifebuoyCost},
}
for i, item in ipairs(definitions) do
    local button = Instance.new("TextButton")
    button.Name = item.key .. "Button"
    local column = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    button.Size = UDim2.fromScale(0.47, 0.34)
    button.Position = UDim2.fromScale(0.025 + column * 0.49, 0.24 + row * 0.37)
    button.BackgroundColor3 = Color3.fromRGB(40, 110, 135)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBlack
    button.TextScaled = true
    button.TextWrapped = true
    button.Parent = panel
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)
    buttons[item.key] = button
    button.Activated:Connect(function()
        if player:GetAttribute("RoundActive") ~= true then return end
        buyRemote:FireServer(item.key)
    end)
end

local function update()
    local active = player:GetAttribute("RoundActive") == true and player:GetAttribute("Eliminated") ~= true
    panel.Visible = active
    if not active then return end
    local pistol = player:GetAttribute("HasPistol") == true
    local vest = player:GetAttribute("HasVest") == true or player:GetAttribute("RobuxVest") == true
    local buoy = player:GetAttribute("HasLifebuoy") == true or player:GetAttribute("RobuxLifebuoy") == true
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local healthReady = humanoid and humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth
    local states = {
        Pistol = {owned = pistol, text = pistol and "🔫 ПИСТОЛЕТ ✓" or ("🔫 ПИСТОЛЕТ • " .. Config.Economy.PistolCost)},
        Vest = {owned = vest, text = vest and "🦺 ЖИЛЕТ ✓" or ("🦺 ЖИЛЕТ • " .. Config.Economy.VestCost)},
        Heal = {owned = not healthReady, text = healthReady and ("❤️ ВОССТАНОВИТЬ HP • " .. Config.Economy.HealCost) or "❤️ HP ПОЛНОЕ"},
        Lifebuoy = {owned = buoy, text = buoy and "🛟 КРУГ ✓" or ("🛟 КРУГ • " .. Config.Economy.LifebuoyCost)},
    }
    for key, state in pairs(states) do
        local button = buttons[key]
        button.Text = state.text
        button.Active = not state.owned
        button.AutoButtonColor = not state.owned
        button.BackgroundColor3 = state.owned and Color3.fromRGB(45, 85, 65) or Color3.fromRGB(40, 110, 135)
    end
end

for _, attribute in ipairs({"RoundActive", "HasLifebuoy", "RobuxLifebuoy", "HasPistol", "HasVest", "RobuxVest", "Eliminated"}) do
    player:GetAttributeChangedSignal(attribute):Connect(update)
end
player.CharacterAdded:Connect(function() task.defer(update) end)
task.spawn(function()
    while player.Parent do update(); task.wait(0.25) end
end)
