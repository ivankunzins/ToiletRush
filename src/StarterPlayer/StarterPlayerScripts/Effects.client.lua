local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild("GameState")

local function getCamera()
    return workspace.CurrentCamera
end

local function setupCoin(coin)
    if not coin:IsA("BasePart") or coin:GetAttribute("FXReady") then
        return
    end

    coin:SetAttribute("FXReady", true)
    coin:SetAttribute("FXBasePosition", coin.Position)

    local light = Instance.new("PointLight")
    local rare = tonumber(coin:GetAttribute("Value")) == Config.Economy.RareCoinValue
    light.Brightness = rare and 2.5 or 1
    light.Range = rare and 14 or 8
    light.Color = coin.Color
    light.Parent = coin
end

local Config = require(ReplicatedStorage:WaitForChild("Config"))

task.spawn(function()
    local arena = workspace:WaitForChild("ToiletArena", 30)
    if not arena then
        return
    end

    local coins = arena:WaitForChild("Coins")
    for _, coin in coins:GetChildren() do
        setupCoin(coin)
    end
    coins.ChildAdded:Connect(setupCoin)
end)

RunService.RenderStepped:Connect(function()
    local arena = workspace:FindFirstChild("ToiletArena")
    local coins = arena and arena:FindFirstChild("Coins")
    if not coins then
        return
    end

    local t = os.clock()
    for _, coin in coins:GetChildren() do
        if coin:IsA("BasePart") and coin:GetAttribute("Collected") ~= true then
            local base = coin:GetAttribute("FXBasePosition")
            if typeof(base) == "Vector3" then
                local y = math.sin(t * 2.4 + base.X * 0.03 + base.Z * 0.02) * 0.18
                coin.CFrame = CFrame.new(base + Vector3.new(0, y, 0)) * CFrame.Angles(0, t * 1.8, 0)
            end
        end
    end
end)

local function resetCamera()
    local camera = getCamera()
    if camera then
        TweenService:Create(camera, TweenInfo.new(0.4), {FieldOfView = 70}):Play()
    end
end

stateRemote.OnClientEvent:Connect(function(event, value)
    if event == "FLUSH_START" then
        for i = 1, 16 do
            local camera = getCamera()
            if camera then
                camera.CFrame *= CFrame.Angles(0, 0, math.rad(math.sin(i * 4) * 2.5))
            end
            task.wait(0.04)
        end
    elseif event == "FLUSH_TICK" then
        local camera = getCamera()
        if camera then
            local seconds = tonumber(value) or 0
            local fov = 70 + math.max(0, 4 - seconds) * 4
            TweenService:Create(camera, TweenInfo.new(0.18), {FieldOfView = fov}):Play()
        end
    elseif event == "ROUND_START" or event == "ROUND_RESULTS" then
        resetCamera()
    end
end)
