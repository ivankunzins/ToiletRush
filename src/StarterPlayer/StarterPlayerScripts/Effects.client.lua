local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild("GameState")
local camera = workspace.CurrentCamera

local function setupCoin(coin)
    if not coin:IsA("BasePart") or coin:GetAttribute("FXReady") then return end
    coin:SetAttribute("FXReady", true)
    local light = Instance.new("PointLight")
    light.Brightness = coin:GetAttribute("Value") == 5 and 2.5 or 1
    light.Range = coin:GetAttribute("Value") == 5 and 14 or 8
    light.Color = coin.Color
    light.Parent = coin
end

task.spawn(function()
    local arena = workspace:WaitForChild("ToiletArena", 30)
    if not arena then return end
    local coins = arena:WaitForChild("Coins")
    for _, coin in coins:GetChildren() do setupCoin(coin) end
    coins.ChildAdded:Connect(setupCoin)
end)

RunService.RenderStepped:Connect(function()
    local arena = workspace:FindFirstChild("ToiletArena")
    local coins = arena and arena:FindFirstChild("Coins")
    if not coins then return end
    local t = os.clock()
    for _, coin in coins:GetChildren() do
        if coin:IsA("BasePart") and coin:GetAttribute("Collected") ~= true then
            local base = coin:GetAttribute("FXBaseCFrame")
            if not base then
                coin:SetAttribute("FXBaseCFrame", true)
                base = coin.CFrame
            end
            local y = math.sin(t * 2.4 + coin.Position.X * 0.03 + coin.Position.Z * 0.02) * 0.18
            coin.CFrame = CFrame.new(coin.Position + Vector3.new(0, y, 0)) * CFrame.Angles(0, t * 1.8, 0)
        end
    end
end)

local function resetCamera()
    if camera then
        TweenService:Create(camera, TweenInfo.new(0.4), {FieldOfView = 70}):Play()
    end
end

stateRemote.OnClientEvent:Connect(function(event, value)
    if event == "FLUSH_START" then
        for i = 1, 16 do
            if camera then
                camera.CFrame *= CFrame.Angles(0, 0, math.rad(math.sin(i * 4) * 2.5))
            end
            task.wait(0.04)
        end
    elseif event == "FLUSH_TICK" and camera then
        local seconds = tonumber(value) or 0
        local fov = 70 + math.max(0, 4 - seconds) * 4
        TweenService:Create(camera, TweenInfo.new(0.18), {FieldOfView = fov}):Play()
    elseif event == "ROUND_START" then
        resetCamera()
    elseif event == "ROUND_RESULTS" then
        resetCamera()
    end
end)
