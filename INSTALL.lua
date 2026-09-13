-- Toilet Rush — reliable one-paste installer v4
-- Run ONLY in Roblox Studio Edit mode, not while Play/Run is active.
-- Enable Game Settings > Security > Allow HTTP Requests.
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerScriptService=game:GetService("ServerScriptService")
local StarterPlayer=game:GetService("StarterPlayer")
local StarterPlayerScripts=StarterPlayer:WaitForChild("StarterPlayerScripts")
local BASE="https://raw.githubusercontent.com/ivankunzins/ToiletRush/main/"
local VERSION=tostring(os.time())

assert(not RunService:IsRunning(),"STOP PLAY/TEST FIRST. Run installer only in Edit mode.")

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
    if path:match("^src/ReplicatedStorage/") then return ReplicatedStorage end
    if path:match("^src/ServerScriptService/") then return ServerScriptService end
    if path:match("^src/StarterPlayer/StarterPlayerScripts/") then return StarterPlayerScripts end
    error("UNKNOWN DESTINATION: "..path)
end

local function objectName(path)
    local name=path:match("([^/]+)$")
    return name:gsub("%.client%.lua$",""):gsub("%.server%.lua$",""):gsub("%.lua$","")
end

local function className(path)
    if path:match("%.client%.lua$") then return "LocalScript" end
    if path:match("%.server%.lua$") then return "Script" end
    return "ModuleScript"
end

local function download(path)
    local url=BASE..path.."?installer="..VERSION
    local ok,result=pcall(function() return HttpService:GetAsync(url,true) end)
    if not ok then error("DOWNLOAD FAILED: "..path.."\n"..tostring(result)) end
    assert(type(result)=="string" and #result>1,"EMPTY SOURCE: "..path)
    return result
end

print("[ToiletRush] =============================")
print("[ToiletRush] INSTALLER v4 / "..VERSION)
print("[ToiletRush] Downloading fresh sources...")

local sources={}
for i,path in ipairs(paths) do
    sources[path]=download(path)
    print(("[ToiletRush] %02d/%02d downloaded: %s"):format(i,#paths,path))
end

local upper=sources["src/ServerScriptService/UpperCourseV3.lua"]
assert(upper:find("FIVE COMPLETE FLOORS",1,true),"VALIDATION FAILED: UpperCourseV3 is not the 5-floor build")
assert(sources["src/ServerScriptService/Main.server.lua"]:find("UpperCourseV3",1,true),"VALIDATION FAILED: Main is outdated")
assert(sources["src/ServerScriptService/Main.server.lua"]:find("BossMinionService",1,true),"VALIDATION FAILED: BossMinionService is not connected")
assert(sources["src/ServerScriptService/BossMinionService.lua"]:find("BossMinion",1,true),"VALIDATION FAILED: BossMinionService source")
print("[ToiletRush] VALIDATION OK: 5 floors / boss / 25 minions")

-- Remove only generated runtime objects and legacy builder. Do this AFTER all downloads succeeded.
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
    print(("[ToiletRush] %02d/%02d installed: %s"):format(i,#paths,objectName(path)))
end

local marker=ServerScriptService:FindFirstChild("ToiletRushInstallVersion") or Instance.new("StringValue")
marker.Name="ToiletRushInstallVersion"
marker.Value="v4-"..VERSION
marker.Parent=ServerScriptService

print("[ToiletRush] INSTALL COMPLETE")
print("[ToiletRush] 5 FLOORS + CENTRAL BOSS + 25 MINIONS")
print("[ToiletRush] IMPORTANT: now press PLAY")
print("[ToiletRush] =============================")
