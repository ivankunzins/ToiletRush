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
gui.Parent = player:WaitForChild("PlayerGui")

local function text(name, size, position, textValue)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.Size = size
    t.Position = position
    t.BackgroundTransparency = 1
    t.Text = textValue
    t.TextColor3 = Color3.new(1, 1, 1)
    t.TextStrokeTransparency = 0.45
    t.Font = Enum.Font.GothamBold
    t.TextScaled = true
    t.Parent = gui
    return t
end

local timer = text("Timer", UDim2.fromScale(0.26, 0.08), UDim2.fromScale(0.37, 0.025), "WAITING")
local status = text("Status", UDim2.fromScale(0.5, 0.07), UDim2.fromScale(0.25, 0.11), "GET READY")
local coins = text("Coins", UDim2.fromScale(0.22, 0.06), UDim2.fromScale(0.025, 0.03), "COINS: 0")
local buoy = text("Buoy", UDim2.fromScale(0.28, 0.06), UDim2.fromScale(0.70, 0.03), "LIFEBOUY: NO")

local shop = Instance.new("TextButton")
shop.Name = "LifebuoyButton"
shop.Size = UDim2.fromScale(0.32, 0.095)
shop.Position = UDim2.fromScale(0.34, 0.82)
shop.BackgroundTransparency = 0.12
shop.BackgroundColor3 = Color3.fromRGB(22, 30, 38)
shop.TextColor3 = Color3.new(1, 1, 1)
shop.TextStrokeTransparency = 0.4
shop.Font = Enum.Font.GothamBlack
shop.TextScaled = true
shop.Text = "🛟 BUY LIFEBOUY - 25"
shop.Visible = false
shop.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = shop

shop.Activated:Connect(function()
    if not player:GetAttribute("HasLifebuoy") then
        buyRemote:FireServer()
    end
end)

local function updateCoins()
    local ls = player:FindFirstChild("leaderstats")
    local value = ls and ls:FindFirstChild("Coins")
    if value then
        coins.Text = "COINS: " .. value.Value
    end
end

task.spawn(function()
    while gui.Parent do
        updateCoins()
        task.wait(0.25)
    end
end)

player:GetAttributeChangedSignal("HasLifebuoy"):Connect(function()
    local has = player:GetAttribute("HasLifebuoy") == true
    buoy.Text = has and "LIFEBOUY: READY" or "LIFEBOUY: NO"
    if has then shop.Visible = false end
end)

stateRemote.OnClientEvent:Connect(function(event, value)
    if event == "INTERMISSION" then
        timer.Text = "NEXT ROUND " .. tostring(value)
        status.Text = "GET READY..."
        shop.Visible = false
    elseif event == "ROUND_START" then
        timer.Text = "3:00"
        status.Text = "RUN! COLLECT COINS!"
        shop.Visible = false
    elseif event == "TICK" then
        local seconds = tonumber(value) or 0
        local mins = math.floor(seconds / 60)
        local secs = seconds % 60
        timer.Text = string.format("%d:%02d", mins, secs)
        if seconds <= Config.Round.LifebuoyWindow then
            status.Text = "⚠️ FLUSH IN " .. seconds .. "s — BUY A LIFEBOUY!"
            shop.Visible = player:GetAttribute("HasLifebuoy") ~= true
            if seconds <= 10 then
                TweenService:Create(timer, TweenInfo.new(0.2), {TextSize = 46}):Play()
            end
        else
            status.Text = "COLLECT COINS • KEEP MOVING"
            shop.Visible = false
        end
    elseif event == "FLUSH_WARNING" then
        timer.Text = "0:00"
        status.Text = "🚽 FLUSHING!!!"
        shop.Visible = false
    elseif event == "FLUSH_START" then
        status.Text = "HOLD ON!"
    elseif event == "ROUND_RESULTS" then
        status.Text = player:GetAttribute("HasLifebuoy") and "🏆 YOU SURVIVED!" or "💦 YOU GOT FLUSHED!"
    end
end)
