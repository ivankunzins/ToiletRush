local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local gui = Instance.new("ScreenGui")
gui.Name = "ToiletRushCoinGoal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 21
gui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Name = "Goal"
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.fromScale(0.5, 0.265)
label.Size = UDim2.fromScale(0.34, 0.045)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 225, 80)
label.TextStrokeTransparency = 0.35
label.Font = Enum.Font.GothamBlack
label.TextScaled = true
label.Visible = false
label.Parent = gui

local function update()
    local active = player:GetAttribute("RoundActive") == true
    local eliminated = player:GetAttribute("Eliminated") == true
    if not active or eliminated then
        label.Visible = false
        return
    end

    local collected = math.max(0, math.floor(tonumber(player:GetAttribute("CoinsCollected")) or 0))
    local goal = Config.Economy.LifebuoyUnlockCollected
    label.Text = collected >= goal
        and "🛟 GOAL COMPLETE • LIFEBUOY UNLOCKED"
        or "🪙 COIN GOAL  " .. tostring(math.min(collected, goal)) .. " / " .. tostring(goal) .. " POINTS"
    label.Visible = true
end

player:GetAttributeChangedSignal("RoundActive"):Connect(update)
player:GetAttributeChangedSignal("Eliminated"):Connect(update)
player:GetAttributeChangedSignal("CoinsCollected"):Connect(update)
player:GetAttributeChangedSignal("LifebuoyUnlocked"):Connect(update)

task.spawn(function()
    while player.Parent do
        update()
        task.wait(0.1)
    end
end)
