local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local stateRemote=remotes:WaitForChild("GameState")
local feedbackRemote=remotes:FindFirstChild("Feedback")
local gui=Instance.new("ScreenGui")
gui.Name="ToiletRushHUD";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=20;gui.Parent=player:WaitForChild("PlayerGui")

local scale=Instance.new("UIScale");scale.Parent=gui

local function label(name,size,pos,text,color,font)
    local t=Instance.new("TextLabel")
    t.Name=name;t.Size=size;t.Position=pos;t.BackgroundTransparency=1;t.Text=text
    t.TextColor3=color or Color3.new(1,1,1);t.TextStrokeTransparency=.65;t.Font=font or Enum.Font.GothamBold;t.TextScaled=true;t.Parent=gui
    return t
end

local timer=label("Timer",UDim2.fromScale(.24,.07),UDim2.fromScale(.38,.025),"WAITING",Color3.new(1,1,1),Enum.Font.GothamBlack)
local roundLabel=label("Round",UDim2.fromScale(.18,.035),UDim2.fromScale(.41,.09),"ROUND 0",Color3.fromRGB(210,225,235))
local status=label("Status",UDim2.fromScale(.50,.045),UDim2.fromScale(.25,.125),"GET READY",Color3.fromRGB(235,240,242))
local coins=label("Coins",UDim2.fromScale(.18,.045),UDim2.fromScale(.025,.035),"COINS 0",Color3.fromRGB(255,225,80),Enum.Font.GothamBlack)
local streak=label("Streak",UDim2.fromScale(.18,.038),UDim2.fromScale(.025,.078),"STREAK 0",Color3.fromRGB(225,235,240))
local buoy=label("Buoy",UDim2.fromScale(.20,.038),UDim2.fromScale(.775,.035),"🛟 READY",Color3.fromRGB(245,245,245),Enum.Font.GothamBold)

local level=label("Level",UDim2.fromScale(.13,.04),UDim2.fromScale(.025,.125),"LV 1",Color3.fromRGB(255,225,80),Enum.Font.GothamBlack)
local xp=label("XP",UDim2.fromScale(.17,.035),UDim2.fromScale(.145,.128),"0 XP",Color3.fromRGB(185,205,215))

local combo=label("Combo",UDim2.fromScale(.20,.05),UDim2.fromScale(.40,.20),"COMBO x0",Color3.fromRGB(255,225,80),Enum.Font.GothamBlack)
combo.Visible=false

local daily=Instance.new("TextButton")
daily.Name="DailyButton";daily.AnchorPoint=Vector2.new(0,1);daily.Position=UDim2.fromScale(.025,.965);daily.Size=UDim2.fromScale(.18,.055)
daily.BackgroundColor3=Color3.fromRGB(35,48,58);daily.BackgroundTransparency=.12;daily.TextColor3=Color3.fromRGB(255,225,80);daily.Font=Enum.Font.GothamBlack;daily.TextScaled=true;daily.Text="DAILY";daily.Visible=false;daily.Parent=gui
Instance.new("UICorner",daily).CornerRadius=UDim.new(0,12)

local results=Instance.new("Frame")
results.Name="RoundResults";results.AnchorPoint=Vector2.new(.5,.5);results.Position=UDim2.fromScale(.5,.58);results.Size=UDim2.fromScale(.44,.34)
results.BackgroundColor3=Color3.fromRGB(18,22,29);results.BackgroundTransparency=.04;results.Visible=false;results.ZIndex=30;results.Parent=gui
Instance.new("UICorner",results).CornerRadius=UDim.new(0,18)

local resultsTitle=Instance.new("TextLabel");resultsTitle.Size=UDim2.fromScale(.9,.20);resultsTitle.Position=UDim2.fromScale(.05,.07);resultsTitle.BackgroundTransparency=1;resultsTitle.TextColor3=Color3.new(1,1,1);resultsTitle.Font=Enum.Font.GothamBlack;resultsTitle.TextScaled=true;resultsTitle.ZIndex=31;resultsTitle.Parent=results
local resultsStats=Instance.new("TextLabel");resultsStats.Size=UDim2.fromScale(.84,.55);resultsStats.Position=UDim2.fromScale(.08,.31);resultsStats.BackgroundTransparency=1;resultsStats.TextColor3=Color3.new(1,1,1);resultsStats.Font=Enum.Font.GothamBold;resultsStats.TextScaled=true;resultsStats.TextWrapped=true;resultsStats.ZIndex=31;resultsStats.Parent=results

local function formatSeconds(seconds)
    seconds=math.max(0,math.floor(tonumber(seconds) or 0))
    return string.format("%d:%02d",math.floor(seconds/60),seconds%60)
end

local function updateStats()
    local ls=player:FindFirstChild("leaderstats")
    local c=ls and ls:FindFirstChild("Coins")
    if c then coins.Text="COINS "..c.Value end
    streak.Text="STREAK "..tostring(player:GetAttribute("WinStreak") or 0)
end

local function updateLevel()
    local lv=math.max(1,math.floor(tonumber(player:GetAttribute("Level")) or 1))
    local current=math.max(0,math.floor(tonumber(player:GetAttribute("LevelXP")) or 0))
    local needed=math.max(1,math.floor(tonumber(player:GetAttribute("LevelNextXP")) or 100))
    level.Text="LV "..lv
    xp.Text=current.." / "..needed.." XP"
end

local function updateBuoy()
    buoy.Text=player:GetAttribute("HasLifebuoy")==true and "🛟 READY" or "🛟 —"
end

local function updateCombo()
    local v=math.max(0,math.floor(tonumber(player:GetAttribute("CoinCombo")) or 0))
    combo.Text="COMBO x"..v;combo.Visible=v>0
end

local function showResults(data,survived)
    data=typeof(data)=="table" and data or {}
    resultsTitle.Text=survived and "🏆 SURVIVED" or "💦 ROUND OVER"
    resultsStats.Text=table.concat({
        "🪙 COINS  "..tostring(data.CoinsCollected or 0),
        "⭐ RARE  "..tostring(data.RareCoinsCollected or 0),
        "🔥 COMBO  x"..tostring(data.MaxCombo or 0),
        "💥 HAZARDS  "..tostring(data.HazardsHit or 0),
    },"\n")
    results.Visible=true
end

local function hideResults() results.Visible=false end

for _,a in ipairs({"Level","LevelXP","LevelNextXP","HasLifebuoy","CoinCombo","WinStreak"}) do
    player:GetAttributeChangedSignal(a):Connect(function()
        updateLevel();updateBuoy();updateCombo();updateStats()
    end)
end

if feedbackRemote then
    feedbackRemote.OnClientEvent:Connect(function(kind,message)
        if kind=="DAILY_SUCCESS" or kind=="DAILY_ERROR" then
            daily.Text=tostring(message)
            task.delay(2,function() if daily.Parent then daily.Text="DAILY" end end)
        end
    end)
end

task.spawn(function()
    while gui.Parent do updateStats();updateLevel();updateBuoy();updateCombo();task.wait(.25) end
end)

stateRemote.OnClientEvent:Connect(function(event,value,roundNumber)
    if event=="INTERMISSION" then
        timer.Text="NEXT "..tostring(value);status.Text="GET READY";daily.Visible=true;hideResults()
    elseif event=="ROUND_START" then
        roundLabel.Text="ROUND "..tostring(roundNumber or 0);timer.Text=formatSeconds(value);status.Text="RUN • COLLECT COINS";daily.Visible=false;hideResults()
    elseif event=="TICK" then
        local seconds=tonumber(value) or 0
        timer.Text=formatSeconds(seconds)
        status.Text=seconds<=30 and "HURRY • KEEP CLIMBING" or "COLLECT COINS • DODGE HAZARDS"
        if seconds<=10 then TweenService:Create(timer,TweenInfo.new(.15),{Rotation=(seconds%2==0) and -2 or 2}):Play() end
    elseif event=="FLUSH_WARNING" then
        timer.Text="0:00";status.Text="BIG FLUSH!";daily.Visible=false
    elseif event=="FLUSH_START" then
        status.Text="HOLD ON!"
    elseif event=="FLUSH_TICK" then
        status.Text="FLUSHING "..tostring(value).."s"
    elseif event=="BOSS_START" then
        timer.Text="BOSS";status.Text="BOSS • FIGHT TO SURVIVE";daily.Visible=false
    elseif event=="BOSS_TICK" then
        timer.Text="BOSS "..tostring(value).." HP";status.Text="ATTACK THE BOSS • DODGE"
    elseif event=="ROUND_STATS" then
        showResults(value,roundNumber==true)
    elseif event=="ROUND_RESULTS" then
        daily.Visible=true
    end
end)

local function fitMobile()
    local camera=workspace.CurrentCamera
    if not camera then return end
    local x=camera.ViewportSize.X
    scale.Scale=x<700 and .72 or x<1000 and .88 or 1
end
fitMobile()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(fitMobile)
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitMobile) end
