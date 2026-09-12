-- Small UI consistency patch for text that predates the new 30-point lifebuoy rule.
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function patch()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    local menu = playerGui and playerGui:FindFirstChild("ToiletRushMenu")
    if not menu then return end

    for _, object in menu:GetDescendants() do
        if object:IsA("TextLabel") and object.Text == "180s ROUND  •  20s LIFEBUOY SHOP" then
            object.Text = "180s ROUND  •  30 POINTS → BUY LIFEBUOY"
        end
    end
end

player:WaitForChild("PlayerGui").ChildAdded:Connect(function(child)
    if child.Name == "ToiletRushMenu" then
        task.defer(patch)
    end
end)

task.spawn(function()
    while player.Parent do
        patch()
        task.wait(1)
    end
end)
