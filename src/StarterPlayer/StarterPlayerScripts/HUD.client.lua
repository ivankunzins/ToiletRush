local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild("GameState")
local buyRemote = remotes:WaitForChild("BuyLifebuoy")
local feedbackRemote = remotes:FindFirstChild("Feedback")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local gui = Instance.new("ScreenGui")
gui.Name = "ToiletRushHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local scale = Instance.new("UIScale")
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
local coins = text("Coins", UDim2.fromScale(0.23, 0.055), UDim2.fromScale(0.025, 0.035), "COINS 0", Enum.Font.GothamBlack, Color3.fromRGB(255, 225, 80))
local wins = text("Wins", UDim2.fromScale(0.18, 0.045), UDim2.fromScale(0.025, 0.085), "WINS 0", Enum.Font.GothamBold)
local streak = text("Streak", UDim2.fromScale(0.22, 0.045), UDim2.fromScale(0.025, 0.125), "STREAK 0", Enum.Font.GothamBold)
local buoy = text("Buoy", UDim2.fromScale(0.29, 0.05), UDim2.fromScale(0.69, 0.035), "LIFEBUOY: NO", Enum.Font.GothamBlack)

local comboLabel = text("Combo", UDim2.fromScale(0.25, 0.055), UDim2.fromScale(0.375, 0.205), "COMBO x0", Enum.Font.GothamBlack, Color3.fromRGB(255, 225, 80))
comboLabel.Visible = false

local levelPanel = Instance.new("Frame")
levelPanel.Name = "LevelPanel"
levelPanel.Position = UDim2.fromScale(0.025, 0.175)
levelPanel.Size = UDim2.fromScale(0.25, 0.07)
levelPanel.BackgroundColor3 = Color3.fromRGB(20, 27, 34)
levelPanel.BackgroundTransparency = 0.12
levelPanel.Parent = gui
local levelCorner = Instance.new("UICorner")
levelCorner.CornerRadius = UDim.new(0, 12)
levelCorner.Parent = levelPanel

local levelText = Instance.new("TextLabel")
levelText.Size = UDim2.fromScale(0.27, 0.48)
levelText.Position = UDim2.fromScale(0.04, 0.12)
levelText.BackgroundTransparency = 1
levelText.Text = "LV 1"
levelText.TextColor3 = Color3.fromRGB(255, 225, 80)
levelText.Font = Enum.Font.GothamBlack
levelText.TextScaled = true
levelText.Parent = levelPanel

local xpBack = Instance.new("Frame")
xpBack.Size = UDim2.fromScale(0.62, 0.22)
xpBack.Position = UDim2.fromScale(0.34, 0.22)
xpBack.BackgroundColor3 = Color3.fromRGB(48, 54, 63)
xpBack.Parent = levelPanel
local xpBackCorner = Instance.new("UICorner")
xpBackCorner.CornerRadius = UDim.new(1, 0)
xpBackCorner.Parent = xpBack

local xpFill = Instance.new("Frame")
xpFill.Size = UDim2.fromScale(0, 1)
xpFill.BackgroundColor3 = Color3.fromRGB(100, 205, 255)
xpFill.Parent = xpBack
local xpFillCorner = Instance.new("UICorner")
xpFillCorner.CornerRadius = UDim.new(1, 0)
xpFillCorner.Parent = xpFill

local xpText = Instance.new("TextLabel")
xpText.Size = UDim2.fromScale(0.62, 0.30)
xpText.Position = UDim2.fromScale(0.34, 0.52)
xpText.BackgroundTransparency = 1
xpText.Text = "0 / 100 XP"
xpText.TextColor3 = Color3.fromRGB(185, 200, 210)
xpText.Font = Enum.Font.GothamBold
xpText.TextScaled = true
xpText.Parent = levelPanel

local progressPanel = Instance.new("Frame")
progressPanel.Name = "ProgressPanel"
progressPanel.AnchorPoint = Vector2.new(1, 0)
progressPanel.Position = UDim2.fromScale(0.98, 0.11)
progressPanel.Size = UDim2.fromScale(0.22, 0.15)
progressPanel.BackgroundColor3 = Color3.fromRGB(20, 27, 34)
progressPanel.BackgroundTransparency = 0.16
progressPanel.Parent = gui
local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 14)
pc.Parent = progressPanel

local panelTitle = text("Title", UDim2.fromScale(0.88, 0.25), UDim2.fromScale(0.06, 0.07), "PLAYER PROGRESS", Enum.Font.GothamBlack, Color3.fromRGB(180, 220, 235))
panelTitle.Parent = progressPanel
local roundsText = text("Rounds", UDim2.fromScale(0.88, 0.22), UDim2.fromScale(0.06, 0.36), "ROUNDS 0", Enum.Font.GothamBold)
roundsText.Parent = progressPanel
local bestText = text("Best", UDim2.fromScale(0.88, 0.22), UDim2.fromScale(0.06, 0.61), "BEST STREAK 0", Enum.Font.GothamBold)
bestText.Parent = progressPanel

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
shop.Text = "BUY LIFEBUOY • 25 COINS"
shop.Visible = false
shop.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = shop
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = 0.35
stroke.Parent = shop

local daily = Instance.new("TextButton")
daily.Name = "DailyButton"
daily.AnchorPoint = Vector2.new(0, 1)
daily.Position = UDim2.fromScale(0.025, 0.96)
daily.Size = UDim2.fromScale(0.24, 0.075)
daily.BackgroundColor3 = Color3.fromRGB(35, 48, 58)
daily.BackgroundTransparency = 0.08
daily.TextColor3 = Color3.fromRGB(255, 225, 80)
daily.Font = Enum.Font.GothamBlack
daily.TextScaled = true
daily.Text = "DAILY REWARD"
daily.Parent = gui
local dc = Instance.new("UICorner")
dc.CornerRadius = UDim.new(0, 15)
dc.Parent = daily

local results = Instance.new("Frame")
results.Name = "RoundResults"
results.AnchorPoint = Vector2.new(0.5, 0.5)
results.Position = UDim2.fromScale(0.5, 0.62)
results.Size = UDim2.fromScale(0.48, 0.44)
results.BackgroundColor3 = Color3.fromRGB(18, 22, 29)
results.BackgroundTransparency = 1
results.Visible = false
results.ZIndex = 30
results.Parent = gui
local resultsCorner = Instance.new("UICorner")
resultsCorner.CornerRadius = UDim.new(0, 20)
resultsCorner.Parent = results
local resultsStroke = Instance.new("UIStroke")
resultsStroke.Thickness = 2
resultsStroke.Transparency = 0.25
resultsStroke.Parent = results

local resultsTitle = Instance.new("TextLabel")
resultsTitle.Size = UDim2.fromScale(0.9, 0.18)
resultsTitle.Position = UDim2.fromScale(0.05, 0.06)
resultsTitle.BackgroundTransparency = 1
resultsTitle.Text = "ROUND COMPLETE"
resultsTitle.TextColor3 = Color3.new(1, 1, 1)
resultsTitle.Font = Enum.Font.GothamBlack
resultsTitle.TextScaled = true
resultsTitle.ZIndex = 31
resultsTitle.Parent = results

local resultsSubtitle = Instance.new("TextLabel")
resultsSubtitle.Size = UDim2.fromScale(0.9, 0.12)
resultsSubtitle.Position = UDim2.fromScale(0.05, 0.22)
resultsSubtitle.BackgroundTransparency = 1
resultsSubtitle.Text = ""
resultsSubtitle.TextColor3 = Color3.fromRGB(190, 205, 215)
resultsSubtitle.Font = Enum.Font.GothamBold
resultsSubtitle.TextScaled = true
resultsSubtitle.ZIndex = 31
resultsSubtitle.Parent = results

local resultsStats = Instance.new("TextLabel")
resultsStats.Size = UDim2.fromScale(0.82, 0.42)
resultsStats.Position = UDim2.fromScale(0.09, 0.37)
resultsStats.BackgroundTransparency = 1
resultsStats.Text = ""
resultsStats.TextColor3 = Color3.new(1, 1, 1)
resultsStats.Font = Enum.Font.GothamBold
resultsStats.TextSize = 18
resultsStats.TextWrapped = true
resultsStats.TextXAlignment = Enum.TextXAlignment.Left
resultsStats.TextYAlignment = Enum.TextYAlignment.Center
resultsStats.ZIndex = 31
resultsStats.Parent = results

local resultsHint = Instance.new("TextLabel")
resultsHint.Size = UDim2.fromScale(0.9, 0.10)
resultsHint.Position = UDim2.fromScale(0.05, 0.85)
resultsHint.BackgroundTransparency = 1
resultsHint.Text = "NEXT ROUND STARTING SOON"
resultsHint.TextColor3 = Color3.fromRGB(150, 170, 180)
resultsHint.Font = Enum.Font.GothamBold
resultsHint.TextScaled = true
resultsHint.ZIndex = 31
resultsHint.Parent = results

local function pulse(button)
    local original = button.Size
    local bigger = UDim2.new(original.X.Scale, original.X.Offset + 8, original.Y.Scale, original.Y.Offset + 4)
    TweenService:Create(button, TweenInfo.new(0.08), {Size = bigger}):Play()
    task.delay(0.08, function()
        if button.Parent then
            TweenService:Create(button, TweenInfo.new(0.12), {Size = original}):Play()
        end
    end)
end

shop.Activated:Connect(function()
    pulse(shop)
    if not player:GetAttribute("HasLifebuoy") then
        buyRemote:FireServer()
    end
end)

daily.Activated:Connect(function()
    pulse(daily)
    if feedbackRemote then
        feedbackRemote:FireServer("CLAIM_DAILY")
    end
end)

local function updateStats()
    local ls = player:FindFirstChild("leaderstats")
    local coinValue = ls and ls:FindFirstChild("Coins")
    local winValue = ls and ls:FindFirstChild("Wins")
    local roundsValue = ls and ls:FindFirstChild("Rounds")
    local bestValue = ls and ls:FindFirstChild("BestStreak")
    if coinValue then coins.Text = "COINS " .. coinValue.Value end
    if winValue then wins.Text = "WINS " .. winValue.Value end
    if roundsValue then roundsText.Text = "ROUNDS " .. roundsValue.Value end
    if bestValue then bestText.Text = "BEST STREAK " .. bestValue.Value end
    streak.Text = "STREAK " .. tostring(player:GetAttribute("WinStreak") or 0)
end

local function updateBuoy()
    local has = player:GetAttribute("HasLifebuoy") == true
    buoy.Text = has and "LIFEBUOY: READY" or "LIFEBUOY: NO"
    if has then shop.Visible = false end
end

local function updateLevel()
    local level = math.max(1, math.floor(tonumber(player:GetAttribute("Level")) or 1))
    local current = math.max(0, math.floor(tonumber(player:GetAttribute("LevelXP")) or 0))
    local needed = math.max(1, math.floor(tonumber(player:GetAttribute("LevelNextXP")) or Config.Progression.LevelBaseXP))
    levelText.Text = "LV " .. tostring(level)
    xpText.Text = tostring(current) .. " / " .. tostring(needed) .. " XP"
    local ratio = math.clamp(current / needed, 0, 1)
    TweenService:Create(xpFill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale(ratio, 1)}):Play()
end

local function updateCombo()
    local value = math.max(0, math.floor(tonumber(player:GetAttribute("CoinCombo")) or 0))
    comboLabel.Text = "COMBO x" .. tostring(value)
    comboLabel.Visible = value > 0
end

local function showResults(stats, survived)
    stats = typeof(stats) == "table" and stats or {}
    local coinsCollected = tonumber(stats.CoinsCollected) or 0
    local rareCoins = tonumber(stats.RareCoinsCollected) or 0
    local hazards = tonumber(stats.HazardsHit) or 0
    local damage = tonumber(stats.DamageTaken) or 0
    local maxCombo = tonumber(stats.MaxCombo) or 0
    local bonusCoins = tonumber(stats.ComboBonusCoins) or 0

    resultsTitle.Text = survived and "🏆 YOU SURVIVED!" or "💦 YOU GOT FLUSHED!"
    resultsSubtitle.Text = survived and "+" .. tostring(Config.Economy.SurvivalReward) .. " COINS • WIN" or "+" .. tostring(Config.Economy.ParticipationReward) .. " COINS • BETTER LUCK NEXT ROUND"
    resultsStats.Text = table.concat({
        "🪙  Coins collected     " .. tostring(coinsCollected),
        "⭐  Rare coins            " .. tostring(rareCoins),
        "🔥  Max combo           x" .. tostring(maxCombo),
        "💰  Combo bonus         +" .. tostring(bonusCoins),
        "💥  Hazard hits          " .. tostring(hazards),
        "❤️  Damage taken       " .. tostring(damage),
    }, "\n")

    results.Visible = true
    results.Position = UDim2.fromScale(0.5, 0.62)
    results.BackgroundTransparency = 1
    TweenService:Create(results, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.55),
        BackgroundTransparency = 0.04,
    }):Play()
end

local function hideResults()
    if not results.Visible then return end
    local tween = TweenService:Create(results, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.fromScale(0.5, 0.62),
        BackgroundTransparency = 1,
    })
    tween:Play()
    tween.Completed:Once(function() results.Visible = false end)
end

task.spawn(function()
    while gui.Parent do
        updateStats()
        updateLevel()
        updateCombo()
        updateBuoy()
        task.wait(0.2)
    end
end)

player:GetAttributeChangedSignal("HasLifebuoy"):Connect(updateBuoy)
player:GetAttributeChangedSignal("Level"):Connect(updateLevel)
player:GetAttributeChangedSignal("LevelXP"):Connect(updateLevel)
player:GetAttributeChangedSignal("LevelNextXP"):Connect(updateLevel)
player:GetAttributeChangedSignal("CoinCombo"):Connect(updateCombo)

local function formatSeconds(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

stateRemote.OnClientEvent:Connect(function(event, value, roundNumber)
    if event == "INTERMISSION" then
        timer.Text = "NEXT ROUND " .. tostring(value)
        status.Text = "GET READY • COLLECT YOUR DAILY REWARD"
        shop.Visible = false
        hideResults()
    elseif event == "ROUND_START" then
        roundLabel.Text = "ROUND " .. tostring(roundNumber or 0)
        timer.Text = formatSeconds(value)
        status.Text = "RUN! COLLECT COINS!"
        shop.Visible = false
        daily.Visible = false
        hideResults()
    elseif event == "TICK" then
        local seconds = tonumber(value) or 0
        timer.Text = formatSeconds(seconds)
        if seconds <= Config.Round.LifebuoyWindow then
            status.Text = "FLUSH IN " .. seconds .. "s • GET A LIFEBUOY!"
            shop.Visible = not player:GetAttribute("HasLifebuoy")
            if seconds <= 10 then
                TweenService:Create(timer, TweenInfo.new(0.15), {Rotation = (seconds % 2 == 0) and -2 or 2}):Play()
            end
        else
            status.Text = "COLLECT COINS • DODGE EVERYTHING"
            shop.Visible = false
        end
    elseif event == "FLUSH_WARNING" then
        timer.Text = "0:00"
        status.Text = "BIG FLUSH!!!"
        shop.Visible = false
        TweenService:Create(timer, TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 5, true), {Rotation = 6}):Play()
    elseif event == "FLUSH_START" then
        status.Text = "HOLD ON! THE TOILET IS FLUSHING!"
    elseif event == "FLUSH_TICK" then
        status.Text = "FLUSHING... " .. tostring(value) .. "s"
    elseif event == "ROUND_STATS" then
        showResults(value, roundNumber == true)
    elseif event == "ROUND_RESULTS" then
        daily.Visible = true
    end
end)

if feedbackRemote then
    feedbackRemote.OnClientEvent:Connect(function(kind, message)
        if kind == "DAILY_SUCCESS" then
            daily.Text = tostring(message)
            task.delay(2.5, function()
                if daily.Parent then daily.Text = "DAILY REWARD" end
            end)
        elseif kind == "DAILY_ERROR" then
            daily.Text = tostring(message)
            task.delay(1.5, function()
                if daily.Parent then daily.Text = "DAILY REWARD" end
            end)
        end
    end)
end

local cameraConnection
local function fitMobile()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    if viewport.X < 700 then
        scale.Scale = 0.72
        progressPanel.Visible = false
    elseif viewport.X < 1000 then
        scale.Scale = 0.88
        progressPanel.Visible = true
    else
        scale.Scale = 1
        progressPanel.Visible = true
    end
    if cameraConnection then cameraConnection:Disconnect() end
    cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitMobile)
end

fitMobile()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(fitMobile)
