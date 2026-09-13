local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer

local function apply()
    local gui=player:WaitForChild("PlayerGui"):FindFirstChild("ToiletRushMenu")
    if not gui then return false end
    local button=gui:FindFirstChild("PlayButton",true)
    if not button or not button:IsA("TextButton") then return false end
    button.Text="PLAY"
    button.BackgroundColor3=Color3.fromRGB(38,55,62)
    button.TextColor3=Color3.fromRGB(205,220,225)
    button.BackgroundTransparency=0.08
    button.Size=UDim2.fromScale(0.36,0.105)
    button.Position=UDim2.fromScale(0.065,0.72)
    local stroke=button:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Thickness=1;stroke.Transparency=0.65 end
    button.MouseEnter:Connect(function()
        TweenService:Create(button,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(52,72,80),TextColor3=Color3.fromRGB(240,248,250)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(38,55,62),TextColor3=Color3.fromRGB(205,220,225)}):Play()
    end)
    return true
end

if not apply() then
    task.spawn(function()
        for _=1,30 do
            if apply() then break end
            task.wait(0.25)
        end
    end)
end
