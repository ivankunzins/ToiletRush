local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Config = require(game.ReplicatedStorage:WaitForChild("Config"))
local Store = DataStoreService:GetDataStore("ToiletRush_PlayerData_v3")

local DataService = {}
local profiles = {}
local saving = {}
local loadFailed = {}

local DEFAULT = {
    Coins = Config.Economy.StartingCoins,
    Wins = 0,
    Rounds = 0,
    BestStreak = 0,
    CurrentStreak = 0,
    DailyClaim = 0,
    DailyStreak = 0,
    XP = 0,
    Achievements = {},
}

local function cloneDefault()
    return {
        Coins = DEFAULT.Coins,
        Wins = 0,
        Rounds = 0,
        BestStreak = 0,
        CurrentStreak = 0,
        DailyClaim = 0,
        DailyStreak = 0,
        XP = 0,
        Achievements = {},
    }
end

local function levelForXP(xp)
    xp = math.max(0, math.floor(xp or 0))
    local level = 1
    local spent = 0
    while level < 1000 do
        local needed = Config.Progression.LevelBaseXP + (level - 1) * Config.Progression.LevelGrowthXP
        if xp < spent + needed then break end
        spent += needed
        level += 1
    end
    return level, spent
end

local function sync(player)
    local data = profiles[player]
    if not data or not player.Parent then return end
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return end

    local function setInt(name, value)
        local obj = stats:FindFirstChild(name) or Instance.new("IntValue")
        obj.Name = name
        obj.Value = math.max(0, math.floor(value or 0))
        obj.Parent = stats
    end

    setInt("Coins", data.Coins)
    setInt("Wins", data.Wins)
    setInt("Rounds", data.Rounds)
    setInt("BestStreak", data.BestStreak)

    local level, spent = levelForXP(data.XP)
    local nextXP = Config.Progression.LevelBaseXP + (level - 1) * Config.Progression.LevelGrowthXP
    player:SetAttribute("RoundsPlayed", data.Rounds)
    player:SetAttribute("WinStreak", data.CurrentStreak)
    player:SetAttribute("BestStreak", data.BestStreak)
    player:SetAttribute("DailyStreak", data.DailyStreak)
    player:SetAttribute("XP", data.XP)
    player:SetAttribute("Level", level)
    player:SetAttribute("LevelXP", math.max(0, data.XP - spent))
    player:SetAttribute("LevelNextXP", nextXP)
end

function DataService:Get(player)
    return profiles[player]
end

function DataService:IsReady(player)
    return profiles[player] ~= nil and loadFailed[player] ~= true
end

function DataService:AddCoins(player, amount)
    if type(amount) ~= "number" or amount <= 0 then return false end
    local data = profiles[player]
    if not data or loadFailed[player] then return false end
    data.Coins += math.floor(amount)
    sync(player)
    return true
end

function DataService:SpendCoins(player, amount)
    if type(amount) ~= "number" or amount <= 0 then return false end
    local data = profiles[player]
    local cost = math.floor(amount)
    if not data or loadFailed[player] or data.Coins < cost then return false end
    data.Coins -= cost
    sync(player)
    return true
end

function DataService:AddXP(player, amount)
    if type(amount) ~= "number" or amount <= 0 then return false, false, 0 end
    local data = profiles[player]
    if not data or loadFailed[player] then return false, false, 0 end

    local oldLevel = levelForXP(data.XP)
    data.XP += math.max(1, math.floor(amount))
    local newLevel = levelForXP(data.XP)
    sync(player)
    return true, newLevel > oldLevel, newLevel
end

function DataService:MarkRound(player, survived)
    local data = profiles[player]
    if not data or loadFailed[player] then return false end
    data.Rounds += 1
    if survived == true then
        data.Wins += 1
        data.CurrentStreak += 1
        data.BestStreak = math.max(data.BestStreak, data.CurrentStreak)
    else
        data.CurrentStreak = 0
    end
    sync(player)
    return true
end

function DataService:UnlockAchievement(player, id, reward)
    local data = profiles[player]
    if not data or loadFailed[player] or type(id) ~= "string" or data.Achievements[id] then return false end
    data.Achievements[id] = true
    if type(reward) == "number" and reward > 0 then data.Coins += math.floor(reward) end
    sync(player)
    return true
end

function DataService:HasAchievement(player, id)
    local data = profiles[player]
    return data ~= nil and not loadFailed[player] and data.Achievements[id] == true
end

function DataService:ClaimDaily(player)
    local data = profiles[player]
    if not data or loadFailed[player] then return false, 0 end

    local day = math.floor(os.time() / 86400)
    if data.DailyClaim == day then return false, 0 end
    if data.DailyClaim == day - 1 then data.DailyStreak += 1 else data.DailyStreak = 1 end

    data.DailyClaim = day
    local reward = math.min(25 + (data.DailyStreak - 1) * 5, 75)
    data.Coins += reward
    sync(player)
    return true, reward
end

function DataService:ResetRoundProgress(player)
    if not profiles[player] or loadFailed[player] then return false end
    player:SetAttribute("CoinCombo", 0)
    return true
end

local function makePayload(data)
    return {
        Coins = data.Coins,
        Wins = data.Wins,
        Rounds = data.Rounds,
        BestStreak = data.BestStreak,
        CurrentStreak = data.CurrentStreak,
        DailyClaim = data.DailyClaim,
        DailyStreak = data.DailyStreak,
        XP = data.XP,
        Achievements = data.Achievements,
    }
end

local function write(player, removeAfter, waitForExistingSave)
    if loadFailed[player] then return false end
    if saving[player] then
        if not waitForExistingSave then return false end
        local deadline = os.clock() + 10
        while saving[player] and os.clock() < deadline do task.wait() end
        if saving[player] then
            warn("[ToiletRush] Previous save did not finish for " .. player.Name)
            return false
        end
    end

    local data = profiles[player]
    if not data then return false end
    saving[player] = true
    local payload = makePayload(data)
    local ok, err = pcall(function()
        Store:UpdateAsync("p_" .. player.UserId, function() return payload end)
    end)
    saving[player] = nil

    if not ok then
        warn("[ToiletRush] Data save failed for " .. player.Name .. ": " .. tostring(err))
        return false
    end

    if removeAfter then
        profiles[player] = nil
        loadFailed[player] = nil
    end
    return true
end

local function load(player)
    if profiles[player] then return end
    player:SetAttribute("DataReady", false)

    local data = cloneDefault()
    local ok, saved = pcall(function()
        return Store:GetAsync("p_" .. player.UserId)
    end)

    if not ok then
        loadFailed[player] = true
        warn("[ToiletRush] Data load failed for " .. player.Name .. ". Player will not be allowed into rounds this session.")
    elseif type(saved) == "table" then
        for _, key in ipairs({"Coins", "Wins", "Rounds", "BestStreak", "CurrentStreak", "DailyClaim", "DailyStreak", "XP"}) do
            if type(saved[key]) == "number" then data[key] = math.max(0, math.floor(saved[key])) end
        end
        if type(saved.Achievements) == "table" then data.Achievements = saved.Achievements end
    end

    profiles[player] = data
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    sync(player)
    player:SetAttribute("DataReady", loadFailed[player] ~= true)
end

Players.PlayerAdded:Connect(load)
for _, player in Players:GetPlayers() do task.spawn(load, player) end

Players.PlayerRemoving:Connect(function(player)
    write(player, true, true)
end)

task.spawn(function()
    while true do
        task.wait(60)
        for _, player in Players:GetPlayers() do
            task.spawn(function() write(player, false, false) end)
        end
    end
end)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do write(player, true, true) end
end)

return DataService
