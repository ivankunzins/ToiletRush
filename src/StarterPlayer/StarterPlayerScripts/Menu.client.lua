local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local lobbyRemote = remotes:WaitForChild("LobbyAction")
local stateRemote = remotes:WaitForChild("GameState")
local feedbackRemote = remotes:WaitForChild("Feedback")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local gui = Instance.new("ScreenGui")
gui.Name = "ToiletRushMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 40
gui.Parent = player:WaitForChild("PlayerGui")

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = gui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
backdrop.BackgroundTransparency = 0.16
backdrop.BorderSizePixel = 0
backdrop.Parent = gui

local glow = Instance.new("Frame")
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Position = UDim2.fromScale(0.5, 0.5)
glow.Size = UDim2.fromScale(0.82, 0.76)
glow.BackgroundColor3 = Color3.fromRGB(17, 31, 42)
glow.BackgroundTransparency = 0.12
glow.BorderSizePixel = 0
glow.Parent = backdrop
Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 30)
local glowStroke = Instance.new("UIStroke")
glowStroke.Thickness = 2
glowStroke.Transparency = 0.45
glowStroke.Parent = glow

local function label(parent, textValue, size, pos, font, color)
    local t = Instance.new("TextLabel")
    t.Size = size
    t.Position = pos
    t.BackgroundTransparency = 1
    t.Text = textValue
    t.TextColor3 = color or Color3.new(1, 1, 1)
    t.Font = font or Enum.Font.GothamBold
    t.TextScaled = true
    t.TextStrokeTransparency = 0.65
    t.Parent = parent
    return t
end

local title = label(glow, "TOILET RUSH", UDim2.fromScale(0.60, 0.12), UDim2.fromScale(0.06, 0.065), Enum.Font.GothamBlack, Color3.fromRGB(240, 250, 255))
title.TextXAlignment = Enum.TextXAlignment.Left
local subtitle = label(glow, "SURVIVE THE FLUSH", UDim2.fromScale(0.52, 0.05), UDim2.fromScale(0.065, 0.17), Enum.Font.GothamBold, Color3.fromRGB(100, 205, 255))
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local status = label(glow, "WAITING IN LOBBY", UDim2.fromScale(0.50, 0.06), UDim2.fromScale(0.065, 0.24), Enum.Font.GothamBold, Color3.fromRGB(190, 205, 215))
status.TextXAlignment = Enum.TextXAlignment.Left

local play = Instance.new("TextButton")
play.Name = "PlayButton"
play.AnchorPoint = Vector2.new(0, 0)
play.Position = UDim2.fromScale(0.065, 0.70)
play.Size = UDim2.fromScale(0.44, 0.13)
play.BackgroundColor3 = Color3.fromRGB(45, 170, 105)
play.TextColor3 = Color3.new(1, 1, 1)
play.Text = "PLAY"
play.Font = Enum.Font.GothamBlack
play.TextScaled = true
play.AutoButtonColor = false
play.Parent = glow
Instance.new("UICorner", play).CornerRadius = UDim.new(0, 18)
local playStroke = Instance.new("UIStroke")
playStroke.Thickness = 2
playStroke.Transparency = 0.25
playStroke.Parent = play

local daily = Instance.new("TextButton")
daily.Position = UDim2.fromScale(0.065, 0.85)
daily.Size = UDim2.fromScale(0.21, 0.075)
daily.BackgroundColor3 = Color3.fromRGB(35, 48, 58)
daily.TextColor3 = Color3.fromRGB(255, 225, 80)
daily.Text = "DAILY +?"
daily.Font = Enum.Font.GothamBlack
daily.TextScaled = true
daily.AutoButtonColor = false
daily.Parent = glow
Instance.new("UICorner", daily).CornerRadius = UDim.new(0, 12)

local achievements = Instance.new("TextButton")
achievements.Position = UDim2.fromScale(0.295, 0.85)
achievements.Size = UDim2.fromScale(0.21, 0.075)
achievements.BackgroundColor3 = Color3.fromRGB(35, 48, 58)
achievements.TextColor3 = Color3.fromRGB(255, 255, 255)
achievements.Text = "🏆 ACHIEVEMENTS"
achievements.Font = Enum.Font.GothamBold
achievements.TextScaled = true
achievements.AutoButtonColor = false
achievements.Parent = glow
Instance.new("UICorner", achievements).CornerRadius = UDim.new(0, 12)

local profile = Instance.new("Frame")
profile.AnchorPoint = Vector2.new(1, 0)
profile.Position = UDim2.fromScale(0.94, 0.065)
profile.Size = UDim2.fromScale(0.37, 0.77)
profile.BackgroundColor3 = Color3.fromRGB(22, 29, 37)
profile.BackgroundTransparency = 0.05
profile.Parent = glow
Instance.new("UICorner", profile).CornerRadius = UDim.new(0, 20)
local profileStroke = Instance.new("UIStroke")
profileStroke.Thickness = 1.5
profileStroke.Transparency = 0.5
profileStroke.Parent = profile

local profileTitle = label(profile, "PLAYER PROFILE", UDim2.fromScale(0.86, 0.10), UDim2.fromScale(0.07, 0.06), Enum.Font.GothamBlack, Color3.fromRGB(175, 220, 235))
profileTitle.TextXAlignment = Enum.TextXAlignment.Left
local nameLabel = label(profile, player.DisplayName, UDim2.fromScale(0.86, 0.09), UDim2.fromScale(0.07, 0.16), Enum.Font.GothamBold)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

local levelLabel = label(profile, "LV 1", UDim2.fromScale(0.28, 0.11), UDim2.fromScale(0.07, 0.29), Enum.Font.GothamBlack, Color3.fromRGB(255, 225, 80))
levelLabel.TextXAlignment = Enum.TextXAlignment.Left
local xpLabel = label(profile, "0 / 100 XP", UDim2.fromScale(0.48, 0.08), UDim2.fromScale(0.45, 0.31), Enum.Font.GothamBold, Color3.fromRGB(190, 205, 215))
xpLabel.TextXAlignment = Enum.TextXAlignment.Right

local xpBack = Instance.new("Frame")
xpBack.Position = UDim2.fromScale(0.07, 0.40)
xpBack.Size = UDim2.fromScale(0.86, 0.045)
xpBack.BackgroundColor3 = Color3.fromRGB(52, 60, 70)
xpBack.Parent = profile
Instance.new("UICorner", xpBack).CornerRadius = UDim.new(1, 0)
local xpFill = Instance.new("Frame")
xpFill.Size = UDim2.fromScale(0, 1)
xpFill.BackgroundColor3 = Color3.fromRGB(100, 205, 255)
xpFill.Parent = xpBack
Instance.new("UICorner", xpFill).CornerRadius = UDim.new(1, 0)

local stats = label(profile, "", UDim2.fromScale(0.86, 0.28), UDim2.fromScale(0.07, 0.49), Enum.Font.GothamBold, Color3.fromRGB(225, 230, 235))
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.TextYAlignment = Enum.TextYAlignment.Top

local hint = label(profile, "180s ROUND  •  20s LIFEBUOY SHOP", UDim2.fromScale(0.86, 0.11), UDim2.fromScale(0.07, 0.83), Enum.Font.GothamBold, Color3.fromRGB(125, 150, 165))
hint.TextXAlignment = Enum.TextXAlignment.Left

local queueInfo = label(glow, "", UDim2.fromScale(0.50, 0.045), UDim2.fromScale(0.065, 0.64), Enum.Font.GothamBold, Color3.fromRGB(130, 160, 175))
queueInfo.TextXAlignment = Enum.TextXAlignment.Left

local visible = true
local queued = false
local roundActive = false
local intermissionLeft = 0

local function updateProfile()
    local ls = player:FindFirstChild("leaderstats")
    local coins = ls and ls:FindFirstChild("Coins")
    local wins = ls and ls:FindFirstChild("Wins")
    local rounds = ls and ls:FindFirstChild("Rounds")
    local streak = player:GetAttribute("WinStreak") or 0
    local best = player:GetAttribute("BestStreak") or 0
    local dailyStreak = player:GetAttribute("DailyStreak") or 0
    local level = math.max(1, math.floor(tonumber(player:GetAttribute("Level")) or 1))
    local current = math.max(0, math.floor(tonumber(player:GetAttribute("LevelXP")) or 0))
    local needed = math.max(1, math.floor(tonumber(player:GetAttribute("LevelNextXP")) or Config.Progression.LevelBaseXP))

    levelLabel.Text = "LV " .. level
    xpLabel.Text = current .. " / " .. needed .. " XP"
    xpFill.Size = UDim2.fromScale(math.clamp(current / needed, 0, 1), 1)
    stats.Text = table.concat({
        "🪙  COINS       " .. tostring(coins and coins.Value or 0),
        "🏆  WINS        " .. tostring(wins and wins.Value or 0),
        "🎮  ROUNDS      " .. tostring(rounds and rounds.Value or 0),
        "🔥  STREAK      " .. tostring(streak) .. "   •   BEST " .. tostring(best),
        "🎁  DAILY       " .. tostring(dailyStreak),
    }, "\n")
    daily.Text = "DAILY REWARD"
end

local function setVisible(value)
    visible = value
    backdrop.Visible = value
end

local function pulse(button)
    local original = button.Size
    local bigger = UDim2.new(original.X.Scale, original.X.Offset + 6, original.Y.Scale, original.Y.Offset + 4)
    TweenService:Create(button, TweenInfo.new(0.07), {Size = bigger}):Play()
    task.delay(0.07, function()
        if button.Parent then
            TweenService:Create(button, TweenInfo.new(0.12), {Size = original}):Play()
        end
    end)
end

play.Activated:Connect(function()
    if queued or roundActive then return end
    pulse(play)
    lobbyRemote:FireServer("PLAY")
end)

daily.Activated:Connect(function()
    pulse(daily)
    feedbackRemote:FireServer("CLAIM_DAILY")
end)

achievements.Activated:Connect(function()
    pulse(achievements)
    local ui = player.PlayerGui:FindFirstChild("AchievementsUI")
    local button = ui and ui:FindFirstChild("AchievementsButton")
    if button and button:IsA("TextButton") then
        button:Activate()
    end
end)

lobbyRemote.OnClientEvent:Connect(function(action, isQueued)
    if action ~= "QUEUE" then return end
    queued = isQueued == true
    if queued then
        play.Text = "QUEUED ✓"
        play.BackgroundColor3 = Color3.fromRGB(48, 105, 125)
        status.Text = "READY FOR THE NEXT ROUND"
        queueInfo.Text = "You are in the queue. Stay ready!"
        setVisible(false)
    else
        play.Text = "PLAY"
        play.BackgroundColor3 = Color3.fromRGB(45, 170, 105)
        status.Text = "WAITING IN LOBBY"
        queueInfo.Text = "Press PLAY to join the next round."
        if not roundActive then setVisible(true) end
    end
end)

stateRemote.OnClientEvent:Connect(function(kind, value)
    if kind == "INTERMISSION" then
        intermissionLeft = tonumber(value) or 0
        if not queued and not roundActive then
            setVisible(true)
            if intermissionLeft > 0 then
                status.Text = "ROUND STARTS IN " .. intermissionLeft .. "s"
            end
        end
    elseif kind == "LOBBY_WAIT" then
        if not queued and not roundActive then
            setVisible(true)
            status.Text = "LOBBY — PRESS PLAY"
            queueInfo.Text = "Waiting for players to join."
        end
    elseif kind == "ROUND_START" then
        roundActive = true
        setVisible(false)
    elseif kind == "FLUSH_START" then
        roundActive = true
        setVisible(false)
    elseif kind == "ROUND_STATS" then
        roundActive = false
        updateProfile()
        if queued then
            setVisible(false)
        else
            setVisible(true)
        end
    end
end)

feedbackRemote.OnClientEvent:Connect(function(kind)
    if kind == "DAILY_SUCCESS" then
        updateProfile()
    end
end)

for _, name in ipairs({"Level", "LevelXP", "LevelNextXP", "WinStreak", "DailyStreak"}) do
    player:GetAttributeChangedSignal(name):Connect(updateProfile)
end

task.spawn(function()
    local ls = player:WaitForChild("leaderstats", 20)
    if ls then
        for _, child in ipairs(ls:GetChildren()) do
            if child:IsA("ValueBase") then
                child.Changed:Connect(updateProfile)
            end
        end
        ls.ChildAdded:Connect(function(child)
            if child:IsA("ValueBase") then child.Changed:Connect(updateProfile) end
            updateProfile()
        end)
    end
    updateProfile()
end)

updateProfile()
