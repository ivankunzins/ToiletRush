local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

stateRemote.OnClientEvent:Connect(function(event, value)
    if event == "FLUSH_START" then
        for i = 1, 12 do
            if camera then camera.CFrame *= CFrame.Angles(0, 0, math.rad(math.sin(i * 4) * 2)) end
            task.wait(0.05)
        end
    elseif event == "FLUSH_TICK" and camera then
        local seconds = tonumber(value) or 0
        if seconds <= 3 then
            TweenService:Create(camera, TweenInfo.new(0.18), {FieldOfView = 72 + (3 - seconds) * 3}):Play()
        end
    end
end)
