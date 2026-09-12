-- Toilet Rush — one-paste Roblox Studio installer
-- Run this entire file in Roblox Studio's Command Bar (Edit mode).
-- First enable: Game Settings > Security > Allow HTTP Requests.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local BASE = "https://raw.githubusercontent.com/ivankunzins/ToiletRush/main/"

local files = {
    {path = "src/ReplicatedStorage/Config.lua", parent = ReplicatedStorage, name = "Config", className = "ModuleScript"},
    {path = "src/ServerScriptService/CoinService.lua", parent = ServerScriptService, name = "CoinService", className = "ModuleScript"},
    {path = "src/ServerScriptService/DataService.lua", parent = ServerScriptService, name = "DataService", className = "ModuleScript"},
    {path = "src/ServerScriptService/FlushService.lua", parent = ServerScriptService, name = "FlushService", className = "ModuleScript"},
    {path = "src/ServerScriptService/HazardService.server.lua", parent = ServerScriptService, name = "HazardService", className = "Script"},
    {path = "src/ServerScriptService/Main.server.lua", parent = ServerScriptService, name = "Main", className = "Script"},
    {path = "src/ServerScriptService/RoundService.lua", parent = ServerScriptService, name = "RoundService", className = "ModuleScript"},
    {path = "src/ServerScriptService/ShopService.lua", parent = ServerScriptService, name = "ShopService", className = "ModuleScript"},
    {path = "src/ServerScriptService/WorldBuilder.lua", parent = ServerScriptService, name = "WorldBuilder", className = "ModuleScript"},
    {path = "src/StarterPlayer/StarterPlayerScripts/Effects.client.lua", parent = StarterPlayerScripts, name = "Effects", className = "LocalScript"},
    {path = "src/StarterPlayer/StarterPlayerScripts/Feedback.client.lua", parent = StarterPlayerScripts, name = "Feedback", className = "LocalScript"},
    {path = "src/StarterPlayer/StarterPlayerScripts/HUD.client.lua", parent = StarterPlayerScripts, name = "HUD", className = "LocalScript"},
}

local function getSource(path)
    local url = BASE .. path:gsub(" ", "%%20")
    local ok, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    if not ok then
        error("Не удалось скачать " .. path .. "\\n" .. tostring(result))
    end
    return result
end

local function replace(parent, name, className, source)
    local old = parent:FindFirstChild(name)
    if old then old:Destroy() end

    local object = Instance.new(className)
    object.Name = name
    object.Source = source
    object.Parent = parent
    return object
end

print("[ToiletRush] Установка началась...")

-- Stop/remove old game scripts first so a rerun cannot create duplicates.
for _, item in ipairs(files) do
    local old = item.parent:FindFirstChild(item.name)
    if old then old:Destroy() end
end

-- Remove generated runtime folders; they will be recreated by Main.
local oldRemotes = ReplicatedStorage:FindFirstChild("Remotes")
if oldRemotes then oldRemotes:Destroy() end
local oldArena = workspace:FindFirstChild("ToiletArena")
if oldArena then oldArena:Destroy() end

for i, item in ipairs(files) do
    local source = getSource(item.path)
    replace(item.parent, item.name, item.className, source)
    print(("[ToiletRush] %d/%d: %s"):format(i, #files, item.name))
end

print("[ToiletRush] ГОТОВО. Нажми Play.")
print("[ToiletRush] Для сохранений опубликуй игру и включи API Services в Game Settings > Security.")
