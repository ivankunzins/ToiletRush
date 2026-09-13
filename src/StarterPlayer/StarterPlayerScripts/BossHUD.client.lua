local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local state=remotes:WaitForChild("GameState")
local gui=Instance.new("ScreenGui");gui.Name="BossHUD";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.Parent=player:WaitForChild("PlayerGui")
local frame=Instance.new("Frame");frame.Name="BossPanel";frame.AnchorPoint=Vector2.new(.5,0);frame.Position=UDim2.fromScale(.5,.055);frame.Size=UDim2.fromOffset(520,104);frame.BackgroundColor3=Color3.fromRGB(25,28,32);frame.BackgroundTransparency=.08;frame.Visible=false;frame.Parent=gui
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,16)
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,-28,0,32);title.Position=UDim2.fromOffset(14,8);title.BackgroundTransparency=1;title.Text="⚠ BOSS — ХРАНИТЕЛЬ ВАННОЙ";title.TextColor3=Color3.fromRGB(255,224,145);title.Font=Enum.Font.GothamBlack;title.TextScaled=true;title.Parent=frame
local bar=Instance.new("Frame");bar.Size=UDim2.new(1,-36,0,18);bar.Position=UDim2.fromOffset(18,46);bar.BackgroundColor3=Color3.fromRGB(65,60,56);bar.Parent=frame;Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
local fill=Instance.new("Frame");fill.Size=UDim2.fromScale(1,1);fill.BackgroundColor3=Color3.fromRGB(205,105,65);fill.Parent=bar;Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
local hp=Instance.new("TextLabel");hp.Size=UDim2.new(1,-36,0,26);hp.Position=UDim2.fromOffset(18,70);hp.BackgroundTransparency=1;hp.Text="30 / 30 HP  •  🔫 10 попаданий бластера  •  🪨 30 камней";hp.TextColor3=Color3.fromRGB(240,242,244);hp.Font=Enum.Font.GothamBold;hp.TextScaled=true;hp.Parent=frame
state.OnClientEvent:Connect(function(action,a,b)
    if action=="BOSS_START" then frame.Visible=true;local max=a or 30;fill.Size=UDim2.fromScale(1,1);hp.Text=max.." / "..max.." HP  •  🔫 10 попаданий бластера  •  🪨 30 камней"
    elseif action=="BOSS_TICK" then
        local current=tonumber(a) or 0;local max=tonumber(b) or 30;frame.Visible=current>0;fill.Size=UDim2.fromScale(math.clamp(current/max,0,1),1);hp.Text=current.." / "..max.." HP  •  🔫 бластер: 3 HP  •  🪨 камень: 1 HP"
    elseif action=="ROUND_START" or action=="INTERMISSION" or action=="ROUND_STATS" then frame.Visible=false end
end)
