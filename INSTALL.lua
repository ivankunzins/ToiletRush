-- Toilet Rush — reliable one-paste installer v3
-- Run ONLY in Roblox Studio Edit mode, not while Play/Run is active.
-- Enable Game Settings > Security > Allow HTTP Requests.
local HttpService=game:GetService("HttpService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerScriptService=game:GetService("ServerScriptService")
local StarterPlayer=game:GetService("StarterPlayer")
local StarterPlayerScripts=StarterPlayer:WaitForChild("StarterPlayerScripts")
local BASE="https://raw.githubusercontent.com/ivankunzins/ToiletRush/main/"
local VERSION=tostring(os.time())

local paths={
"src/ReplicatedStorage/Config.lua",
"src/ServerScriptService/AchievementService.lua",
"src/ServerScriptService/BathroomArchitecture.lua",
"src/ServerScriptService/BossBlasterPatch.server.lua",
"src/ServerScriptService/BossMinionService.lua",
"src/ServerScriptService/BossService.lua",
"src/ServerScriptService/CoinService.lua",
"src/ServerScriptService/DataService.lua",
"src/ServerScriptService/FlushService.lua",
"src/ServerScriptService/HazardService.server.lua",
"src/ServerScriptService/Main.server.lua",
"src/ServerScriptService/NPCBuilder.lua",
"src/ServerScriptService/RobuxShopService.lua",
"src/ServerScriptService/RoundService.lua",
"src/ServerScriptService/RoundServiceFixed.lua",
"src/ServerScriptService/RoundStatsService.lua",
"src/ServerScriptService/ShopService.lua",
"src/ServerScriptService/UpperCourseV2.lua",
"src/ServerScriptService/UpperCourseV3.lua",
"src/ServerScriptService/VisualEffectsBuilder.lua",
"src/ServerScriptService/WorldBuilder.lua",
"src/StarterPlayer/StarterPlayerScripts/Achievements.client.lua",
"src/StarterPlayer/StarterPlayerScripts/Audio.client.lua",
"src/StarterPlayer/StarterPlayerScripts/BossHUD.client.lua",
"src/StarterPlayer/StarterPlayerScripts/CoinGoal.client.lua",
"src/StarterPlayer/StarterPlayerScripts/ConsistencyPatch.client.lua",
"src/StarterPlayer/StarterPlayerScripts/Effects.client.lua",
"src/StarterPlayer/StarterPlayerScripts/Feedback.client.lua",
"src/StarterPlayer/StarterPlayerScripts/HUD.client.lua",
"src/StarterPlayer/StarterPlayerScripts/LifebuoyButton.client.lua",
"src/StarterPlayer/StarterPlayerScripts/Menu.client.lua",
"src/StarterPlayer/StarterPlayerScripts/StartButtonPatch.client.lua",
}

local function destination(path)
    if path:sub(1,23)=="src/ReplicatedStorage/" then return ReplicatedStorage end
    if path:sub(1,24)=="src/ServerScriptService/" then return ServerScriptService end
    return StarterPlayerScripts
end

local function objectName(path)
    local name=path:match("([^/]+)$")
    name=name:gsub("%.client%.lua$",""):gsub("%.server%.lua$",""):gsub("%.lua$","")
    return name
end

local function className(path)
    if path:find("%.client%.lua$") then return "LocalScript" end
    if path:find("%.server%.lua$") then return "Script" end
    return "ModuleScript"
end

local function download(path)
    local url=BASE..path.."?installer="..VERSION
    local ok,result=pcall(function() return HttpService:GetAsync(url,true) end)
    if not ok then error("DOWNLOAD FAILED: "..path.."\n"..tostring(result)) end
    if type(result)~="string" or #result<2 then error("EMPTY SOURCE: "..path) end
    return result
end

print("[ToiletRush] INSTALLER v3 / "..VERSION)
if RunService and RunService:IsRunning() then error("STOP PLAY/TEST FIRST. Run installer only in Edit mode.") end

local sources={}
for i,path in ipairs(paths) do
    sources[path]=download(path)
    print(("[ToiletRush] download %d/%d OK: %s"):format(i,#paths,path))
end

local upper=sources["src/ServerScriptService/UpperCourseV3.lua"]
assert(upper:find("FIVE COMPLETE FLOORS",1,true),"UPPERCOURSE VALIDATION FAILED: downloaded file is not the five-floor version")
assert(sources["src/ServerScriptService/BossMinionService.lua"]:find("BossMinion",1,true),"MINION VALIDATION FAILED")
assert(sources["src/ServerScriptService/Main.server.lua"]:find("BossMinionService",1,true),"MAIN VALIDATION FAILED")
print("[ToiletRush] VALIDATION OK: 5 floors + boss + 25 minions")

local oldArena=workspace:FindFirstChild("ToiletArena")
if oldArena then oldArena:Destroy() end
local oldBuilder=ServerScriptService:FindFirstChild("UpperCourseBuilder")
if oldBuilder then oldBuilder:Destroy() end

local function install(path,source)
    local parent=destination(path)
    local name=objectName(path)
    local old=parent:FindFirstChild(name)
    if old then old:Destroy() end
    local obj=Instance.new(className(path))
    obj.Name=name
    obj.Source=source
    obj.Parent=parent
end

for i,path in ipairs(paths) do
    install(path,sources[path])
    print(("[ToiletRush] installed %d/%d: %s"):format(i,#paths,objectName(path)))
end

local marker=ServerScriptService:FindFirstChild("ToiletRushInstallVersion") or Instance.new("StringValue")
marker.Name="ToiletRushInstallVersion"
marker.Value="v3-"..VERSION
marker.Parent=ServerScriptService

print("[ToiletRush] =============================")
print("[ToiletRush] INSTALL COMPLETE v3")
print("[ToiletRush] 5 FLOORS + BOSS + 25 MINIONS")
print("[ToiletRush] Now press PLAY")
print("[ToiletRush] =============================")
