local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local remote = remotes:WaitForChild("Achievements")
local feedback = remotes:WaitForChild("Feedback")

local gui = Instance.new("ScreenGui")
gui.Name = "AchievementsUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "AchievementsButton"
button.Size = UDim2.fromOffset(150, 42)
button.Position = UDim2.new(0, 16, 1, -62)
button.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "🏆 ДОСТИЖЕНИЯ"
button.TextSize = 15
button.Font = Enum.Font.GothamBold
button.Parent = gui
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(360, 430)
panel.Position = UDim2.new(0, 16, 1, 20)
panel.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 48)
title.Position = UDim2.fromOffset(18, 8)
title.BackgroundTransparency = 1
title.Text = "🏆 ДОСТИЖЕНИЯ"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(36, 36)
close.Position = UDim2.new(1, -44, 0, 10)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 28
close.Font = Enum.Font.GothamBold
close.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -28, 1, -68)
list.Position = UDim2.fromOffset(14, 58)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.Parent = panel
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = list

local function clearList()
    for _, child in list:GetChildren() do
        if child:IsA("Frame") then child:Destroy() end
    end
end

local function render(data)
    clearList()
    local items = {}
    for id, item in pairs(data) do
        item.Id = id
        table.insert(items, item)
    end
    table.sort(items, function(a, b) return a.Unlocked and not b.Unlocked end)

    for _, item in ipairs(items) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -8, 0, 70)
        card.BackgroundColor3 = item.Unlocked and Color3.fromRGB(38, 65, 48) or Color3.fromRGB(31, 33, 42)
        card.Parent = list
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -70, 0, 28)
        name.Position = UDim2.fromOffset(12, 6)
        name.BackgroundTransparency = 1
        name.Text = (item.Unlocked and "✓ " or "🔒 ") .. item.Name
        name.TextColor3 = Color3.new(1, 1, 1)
        name.TextSize = 16
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -24, 0, 26)
        desc.Position = UDim2.fromOffset(12, 34)
        desc.BackgroundTransparency = 1
        desc.Text = item.Description .. "  •  +" .. item.Reward
        desc.TextColor3 = Color3.fromRGB(190, 195, 205)
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = card
    end
    list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
end

button.Activated:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then
        remote:FireServer("GET")
        panel.Position = UDim2.new(0, 16, 1, 20)
        TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 16, 1, -450)
        }):Play()
    end
end)

close.Activated:Connect(function() panel.Visible = false end)

remote.OnClientEvent:Connect(function(action, data)
    if action == "LIST" then render(data) end
end)

feedback.OnClientEvent:Connect(function(kind, name, description, reward)
    if kind ~= "ACHIEVEMENT" then return end
    task.wait(0.05)
    remote:FireServer("GET")
end)
