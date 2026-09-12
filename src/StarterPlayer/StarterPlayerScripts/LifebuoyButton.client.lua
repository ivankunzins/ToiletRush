local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local buyRemote = remotes:WaitForChild("BuyLifebuoy")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local gui = Instance.new("ScreenGui")
gui.Name = "LifebuoyGoalUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 26
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.fromScale(0.5, 0.965)
panel.Size = UDim2.fromScale(0.44, 0.12)
panel.BackgroundColor3 = Color3.fromRGB(18, 26, 34)
panel.BackgroundTransparency = 0.08
panel.Visible = false
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = 0.25
stroke.Parent = panel

local goal = Instance.new("TextLabel")
goal.Size = UDim2.fromScale(0.94, 0.34)
goal.Position = UDim2.fromScale(0.03, 0.05)
goal.BackgroundTransparency = 1
goal.TextColor3 = Color3.fromRGB(255, 225, 80)
goal.Font = Enum.Font.GothamBlack
goal.TextScaled = true
goal.Parent = panel

local button = Instance.new("TextButton")
button.Size = UDim2.fromScale(0.86, 0.46)
button.Position = UDim2.fromScale(0.07, 0.47)
button.BackgroundColor3 = Color3.fromRGB(235, 70, 52)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBlack
button.TextScaled = true
button.Text = "🛟 КУПИТЬ СПАСАТЕЛЬНЫЙ КРУГ • 25"
button.Parent = panel
local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0, 13)
bc.Parent = button

local roundActive = false
local busy = false

local function update()
    local collected = math.max(0, math.floor(tonumber(player:GetAttribute("CoinsCollected")) or 0))
    local unlocked = player:GetAttribute("LifebuoyUnlocked") == true
    local has = player:GetAttribute("HasLifebuoy") == true
    local active = player:GetAttribute("RoundActive") == true

    panel.Visible = active and not has
    if not panel.Visible then return end

    if unlocked then
        goal.Text = "🛟 30/30 — СПАСАТЕЛЬНЫЙ КРУГ ОТКРЫТ"
        button.Visible = true
        button.Text = "🛟 КУПИТЬ КРУГ • " .. tostring(Config.Economy.LifebuoyCost) .. " МОНЕТ"
    else
        goal.Text = "🪙 СОБЕРИ " .. tostring(Config.Economy.LifebuoyUnlockCollected) .. " ОЧКОВ • " .. tostring(math.min(collected, Config.Economy.LifebuoyUnlockCollected)) .. "/" .. tostring(Config.Economy.LifebuoyUnlockCollected)
        button.Visible = false
    end
end

button.Activated:Connect(function()
    if busy or player:GetAttribute("LifebuoyUnlocked") ~= true or player:GetAttribute("HasLifebuoy") == true then return end
    busy = true
    TweenService:Create(button, TweenInfo.new(0.08), {Size = UDim2.fromScale(0.90, 0.50)}):Play()
    buyRemote:FireServer()
    task.delay(0.35, function()
        busy = false
        if button.Parent then TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.fromScale(0.86, 0.46)}):Play() end
    end)
end)

for _, attribute in ipairs({"CoinsCollected", "LifebuoyUnlocked", "HasLifebuoy", "RoundActive"}) do
    player:GetAttributeChangedSignal(attribute):Connect(update)
end

task.spawn(function()
    while player.Parent do
        update()
        task.wait(0.15)
    end
end)
