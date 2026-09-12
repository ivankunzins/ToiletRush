local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Feedback")

local gui = Instance.new("ScreenGui")
gui.Name = "ToiletRushFeedback"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 30
gui.Parent = player:WaitForChild("PlayerGui")

local stack = Instance.new("Frame")
stack.Name = "Stack"
stack.AnchorPoint = Vector2.new(0.5, 0)
stack.Position = UDim2.fromScale(0.5, 0.20)
stack.Size = UDim2.fromScale(0.72, 0.34)
stack.BackgroundTransparency = 1
stack.Parent = gui

local layout = Instance.new("UIListLayout")
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Padding = UDim.new(0, 5)
layout.Parent = stack

local function show(kind, message)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 42)
    label.BackgroundColor3 = kind == "SHOP_SUCCESS" and Color3.fromRGB(24, 120, 75)
        or kind == "SHOP_ERROR" and Color3.fromRGB(150, 55, 50)
        or Color3.fromRGB(25, 35, 45)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.Text = tostring(message)
    label.TextTransparency = 1
    label.Parent = stack

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = label

    local stroke = Instance.new("UIStroke")
    stroke.Transparency = 0.55
    stroke.Parent = label

    TweenService:Create(label, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextTransparency = 0,
        BackgroundTransparency = 0.12,
    }):Play()

    task.delay(kind == "COIN" and 0.8 or 1.8, function()
        if not label.Parent then return end
        local hideTween = TweenService:Create(label, TweenInfo.new(0.2), {
            TextTransparency = 1,
            BackgroundTransparency = 1,
        })
        hideTween:Play()
        hideTween.Completed:Wait()
        label:Destroy()
    end)
end

remote.OnClientEvent:Connect(show)
