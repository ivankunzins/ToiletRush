local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild("GameState")
local buyRemote = remotes:WaitForChild("BuyLifebuoy")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local gui = Instance.new("ScreenGui")
gui.Name = "ToiletRushHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = gui

local function text(name, size, position, textValue, font, color)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.Size = size
    t.Position = position
    t.BackgroundTransparency = 1
    t.Text = textValue
    t.TextColor3 = color or Color3.new(1, 1, 1)
    t.TextStrokeTransparency = 0.45
    t.Font = font or Enum.Font.GothamBold
    t.TextScaled = true
    t.Parent = gui
    return t
end

local timer = text("Timer", UDim2.fromScale(0.30, 0.075), UDim2.fromScale(0.35, 0.025), "WAITING", Enum.Font.GothamBlack)
local roundLabel = text("Round", UDim2.fromScale(0.22, 0.04), UDim2.fromScale(0.39, 0.095), "ROUND 0", Enum.Font.GothamBold, Color3.fromRGB(220, 230, 235))
local status = text("Status", UDim2.fromScale(0.62, 0.065), UDim2.fromScale(0.19, 0.145), "GET READY", Enum.Font.GothamBold)

local coins = text("Coins", UDim2.fromScale(0.23, 0.055), UDim2.fromScale(0.025, 0.035), "🪙 0", Enum.Font.GothamBlack, Color3.fromRGB(255, 225, 80))
local wins = text("Wins", UDim2.fromScale(0.18, 0.045), UDim2.fromScale(0.025, 0.085), "🏆 0", Enum.Font.GothamBold)
local buoy = text("Buoy", UDim2.fromScale(0.29, 0.05), UDim2.fromScale(0.69, 0.035), "🛟 NO LIFEBOUY", Enum.Font.GothamBlack)

local shop = Instance.new("TextButton")
shop.Name = "LifebuoyButton"
shop.AnchorPoint = Vector2.new(0.5, 1)
shop.Size = UDim2.fromScale(0.40, 0.09)
shop.Position = UDim2.fromScale(0.5, 0.96)
shop.BackgroundTransparency = 0.08
shop.BackgroundColor3 = Color3.fromRGB(22, 30, 38)
shop.TextColor3 = Color3.new(1, 1, 1)
shop.TextStrokeTransparency = 0.4
shop.Font = Enum.Font.GothamBlack
shop.TextScaled = true
shop.Text = "🛟 BUY LIFEBOUY • 25 COINS"
shop.Visible = false
shop.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = shop

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = 0.35
stroke.Parent = shop

shop.Activated:Connect(function()
    if not player:GetAttribute("HasLifebuoy") then
        buyRemote:FireServer()
    end
end)

local function updateStats()
    local ls = player:FindFirstChild("leaderstats")
    local coinValue = ls and ls:FindFirstChild("Coins")
    local winValue = ls and ls:FindFirstChild("Wins")
    if coinValue then coins.Text = "🪙 " .. coinValue.Value end
    if winValue then wins.Text = "🏆 " .. winValue.Value end
end

local function updateBuoy()
    local has = player:GetAttribute("HasLifebuoy") == true
    buoy.Text = has and "🛟 LIFEBOUY READY" or "🛟 NO LIFEBOUY"
    if has then shop.Visible = false end
end

task.spawn(function()
    while gui.Parent do
        updateStats()
        updateBuoy()
        task.wait(0.2)
    end
end)

player:GetAttributeChangedSignal("HasLifebuoy"):Connect(updateBuoy)

stateRemote.OnClientEvent:Connect(function(event, value, roundNumber)
    if event == "INTERMISSION" then
        timer.Text = "NEXT ROUND " .. tostring(value)
        status.Text = "GET READY • THE BATHROOM IS DANGEROUS"
        shop.Visible = false
    elseif event == "ROUND_START" then
        roundLabel.Text = "ROUND " .. tostring(roundNumber or 0)
        timer.Text = "3:00"
        status.Text = "RUN! COLLECT COINS!"
        shop.Visible = false
    elseif event == "TICK" then
        local seconds = tonumber(value) or 0
        timer.Text = string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
        if seconds <= Config.Round.LifebuoyWindow then
            status.Text = "⚠️ FLUSH IN " .. seconds .. "s • BUY A LIFEBOUY!"
            shop.Visible = not player:GetAttribute("HasLifebuoy")
            if seconds <= 10 then
                TweenService:Create(timer, TweenInfo.new(0.15), {Rotation = (seconds % 2 == 0) and -2 or 2}):Play()
            end
        else
            status.Text = "COLLECT COINS • DODGE THE HAZARDS"
            shop.Visible = false
        end
    elseif event == "FLUSH_WARNING" then
        timer.Text = "0:00"
        status.Text = "🚽 BIG FLUSH!!!"
        shop.Visible = false
        TweenService:Create(timer, TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 5, true), {Rotation = 6}):Play()
    elseif event == "FLUSH_START" then
        status.Text = "💦 HOLD ON! THE TOILET IS FLUSHING!"
    elseif event == "FLUSH_TICK" then
        status.Text = "💦 FLUSHING... " .. tostring(value) .. "s"
    elseif event == "ROUND_RESULTS" then
        local survived = player:GetAttribute("LastRoundSurvived") == true
        status.Text = survived and "🏆 YOU SURVIVED! +40 COINS" or "💦 YOU GOT FLUSHED! +10 COINS"
    end
end)

local function fitMobile()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    if viewport.X < 700 then
        scale.Scale = 0.82
    elseif viewport.X < 1000 then
        scale.Scale = 0.92
    else
        scale.Scale = 1
    end
end

fitMobile()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(fitMobile)
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitMobile)
end
