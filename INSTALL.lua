-- Toilet Rush — one-paste Roblox Studio installer
-- Run this entire file in Roblox Studio's Command Bar (Edit mode).
-- First enable: Game Settings > Security > Allow HTTP Requests.

local HttpService=game:GetService("HttpService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerScriptService=game:GetService("ServerScriptService")
local StarterPlayer=game:GetService("StarterPlayer")
local StarterPlayerScripts=StarterPlayer:WaitForChild("StarterPlayerScripts")
local BASE="https://raw.githubusercontent.com/ivankunzins/ToiletRush/main/"

local files={
{path="src/ReplicatedStorage/Config.lua",parent=ReplicatedStorage,name="Config",className="ModuleScript"},
{path="src/ServerScriptService/AchievementService.lua",parent=ServerScriptService,name="AchievementService",className="ModuleScript"},
{path="src/ServerScriptService/BathroomArchitecture.lua",parent=ServerScriptService,name="BathroomArchitecture",className="ModuleScript"},
{path="src/ServerScriptService/BossBlasterPatch.server.lua",parent=ServerScriptService,name="BossBlasterPatch",className="Script"},
{path="src/ServerScriptService/BossService.lua",parent=ServerScriptService,name="BossService",className="ModuleScript"},
{path="src/ServerScriptService/CoinService.lua",parent=ServerScriptService,name="CoinService",className="ModuleScript"},
{path="src/ServerScriptService/DataService.lua",parent=ServerScriptService,name="DataService",className="ModuleScript"},
{path="src/ServerScriptService/FlushService.lua",parent=ServerScriptService,name="FlushService",className="ModuleScript"},
{path="src/ServerScriptService/HazardService.server.lua",parent=ServerScriptService,name="HazardService",className="Script"},
{path="src/ServerScriptService/Main.server.lua",parent=ServerScriptService,name="Main",className="Script"},
{path="src/ServerScriptService/NPCBuilder.lua",parent=ServerScriptService,name="NPCBuilder",className="ModuleScript"},
{path="src/ServerScriptService/RobuxShopService.lua",parent=ServerScriptService,name="RobuxShopService",className="ModuleScript"},
{path="src/ServerScriptService/RoundService.lua",parent=ServerScriptService,name="RoundService",className="ModuleScript"},
{path="src/ServerScriptService/RoundServiceFixed.lua",parent=ServerScriptService,name="RoundServiceFixed",className="ModuleScript"},
{path="src/ServerScriptService/RoundStatsService.lua",parent=ServerScriptService,name="RoundStatsService",className="ModuleScript"},
{path="src/ServerScriptService/ShopService.lua",parent=ServerScriptService,name="ShopService",className="ModuleScript"},
{path="src/ServerScriptService/UpperCourseV2.lua",parent=ServerScriptService,name="UpperCourseV2",className="ModuleScript"},
{path="src/ServerScriptService/VisualEffectsBuilder.lua",parent=ServerScriptService,name="VisualEffectsBuilder",className="ModuleScript"},
{path="src/ServerScriptService/WorldBuilder.lua",parent=ServerScriptService,name="WorldBuilder",className="ModuleScript"},
{path="src/StarterPlayer/StarterPlayerScripts/Achievements.client.lua",parent=StarterPlayerScripts,name="Achievements",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/Audio.client.lua",parent=StarterPlayerScripts,name="Audio",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/BossHUD.client.lua",parent=StarterPlayerScripts,name="BossHUD",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/CoinGoal.client.lua",parent=StarterPlayerScripts,name="CoinGoal",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/ConsistencyPatch.client.lua",parent=StarterPlayerScripts,name="ConsistencyPatch",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/Effects.client.lua",parent=StarterPlayerScripts,name="Effects",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/Feedback.client.lua",parent=StarterPlayerScripts,name="Feedback",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/HUD.client.lua",parent=StarterPlayerScripts,name="HUD",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/LifebuoyButton.client.lua",parent=StarterPlayerScripts,name="LifebuoyButton",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/Menu.client.lua",parent=StarterPlayerScripts,name="Menu",className="LocalScript"},
{path="src/StarterPlayer/StarterPlayerScripts/StartButtonPatch.client.lua",parent=StarterPlayerScripts,name="StartButtonPatch",className="LocalScript"},
}

local function getSource(path)
    local ok,result=pcall(function()return HttpService:GetAsync(BASE..path,true)end)
    if not ok then error("Не удалось скачать "..path.."\n"..tostring(result)) end
    if type(result)~="string" or #result==0 then error("Пустой исходник: "..path) end
    return result
end
local function replace(parent,name,className,source)
    local old=parent:FindFirstChild(name);if old then old:Destroy()end
    local object=Instance.new(className);object.Name=name;object.Source=source;object.Parent=parent
end
print("[ToiletRush] Проверяю исходники...")
local sources={}
for i,item in ipairs(files)do sources[item.path]=getSource(item.path);print(("[ToiletRush] downloaded %d/%d: %s"):format(i,#files,item.name))end
print("[ToiletRush] Очищаю старую версию...")
for _,item in ipairs(files)do local old=item.parent:FindFirstChild(item.name);if old then old:Destroy()end end
local oldBuilder=ServerScriptService:FindFirstChild("UpperCourseBuilder");if oldBuilder then oldBuilder:Destroy()end
local oldBossPatch=ServerScriptService:FindFirstChild("BossBlasterPatch");if oldBossPatch then oldBossPatch:Destroy()end
local oldBossService=ServerScriptService:FindFirstChild("BossService");if oldBossService then oldBossService:Destroy()end
local oldRemotes=ReplicatedStorage:FindFirstChild("Remotes");if oldRemotes then oldRemotes:Destroy()end
local oldArena=workspace:FindFirstChild("ToiletArena");if oldArena then oldArena:Destroy()end
print("[ToiletRush] Устанавливаю...")
for i,item in ipairs(files)do replace(item.parent,item.name,item.className,sources[item.path]);print(("[ToiletRush] installed %d/%d: %s"):format(i,#files,item.name))end
print("[ToiletRush] ГОТОВО. Нажми Play.")
print("[ToiletRush] Схема: 180 секунд подъёма → 5 этажей → центральный BOSS → камни/бластер → аварийный смыв босса.")
print("[ToiletRush] Robux shop: создай 3 Game Pass и вставь IDs в Config.RobuxShop.")
print("[ToiletRush] Для сохранений: опубликуй игру и включи API Services.")
