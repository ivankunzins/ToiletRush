local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild("GameState")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local timeLeft = math.huge
local roundActive = false

local function findButton()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    local hud = playerGui and playerGui:FindFirstChild("ToiletRushHUD")
    return hud and hud:FindFirstChild("LifebuoyButton")
end

local function update()
    local button = findButton()
    if not button then return end

    local has = player:GetAttribute("HasLifebuoy") == true
    local unlocked = player:GetAttribute("LifebuoyUnlocked") == true
    local eligible = roundActive and unlocked and timeLeft <= Config.Round.LifebuoyWindow and not has

    button.Visible = eligible
    if eligible then
        button.Text = "🛟 BUY LIFEBUOY • " .. tostring(Config.Economy.LifebuoyCost) .. " COINS"
    end
end

player:GetAttributeChangedSignal("LifebuoyUnlocked"):Connect(update)
player:GetAttributeChangedSignal("HasLifebuoy"):Connect(update)

stateRemote.OnClientEvent:Connect(function(event, value)
    if event == "ROUND_START" then
        roundActive = true
        timeLeft = tonumber(value) or Config.Round.Duration
    elseif event == "TICK" then
        roundActive = true
        timeLeft = tonumber(value) or timeLeft
    elseif event == "INTERMISSION" or event == "FLUSH_WARNING" or event == "FLUSH_START" or event == "ROUND_RESULTS" then
        roundActive = false
        timeLeft = math.huge
    end
    update()
end)

task.spawn(function()
    while player.Parent do
        update()
        task.wait(0.05)
    end
end)
