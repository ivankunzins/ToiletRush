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
        Achievements = {},
    }
end

local function sync(player)
    local data = profiles[player]
    if not data then return end
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return end

    local function setInt(name, value)
        local obj = stats:FindFirstChild(name) or Instance.new("IntValue")
        obj.Name = name
        obj.Value = value
        obj.Parent = stats
    end

    setInt("Coins", data.Coins)
    setInt("Wins", data.Wins)
    setInt("Rounds", data.Rounds)
    setInt("BestStreak", data.BestStreak)

    player:SetAttribute("RoundsPlayed", data.Rounds)
    player:SetAttribute("WinStreak", data.CurrentStreak)
    player:SetAttribute("BestStreak", data.BestStreak)
    player:SetAttribute("DailyStreak", data.DailyStreak)
end

function DataService:Get(player)
    return profiles[player]
end

function DataService:AddCoins(player, amount)
    if type(amount) ~= "number" or amount <= 0 then return false end
    local data = profiles[player]
    if not data then return false end
    data.Coins += math.floor(amount)
    sync(player)
    return true
end

function DataService:SpendCoins(player, amount)
    if type(amount) ~= "number" or amount <= 0 then return false end
    local data = profiles[player]
    if not data or data.Coins < amount then return false end
    data.Coins -= math.floor(amount)
    sync(player)
    return true
end

function DataService:MarkRound(player, survived)
    local data = profiles[player]
    if not data then return end
    data.Rounds += 1
    if survived then
        data.Wins += 1
        data.CurrentStreak += 1
        data.BestStreak = math.max(data.BestStreak, data.CurrentStreak)
    else
        data.CurrentStreak = 0
    end
    sync(player)
end

function DataService:UnlockAchievement(player, id, reward)
    local data = profiles[player]
    if not data or type(id) ~= "string" or data.Achievements[id] then return false end
    data.Achievements[id] = true
    if reward and reward > 0 then
        data.Coins += math.floor(reward)
    end
    sync(player)
    return true
end

function DataService:HasAchievement(player, id)
    local data = profiles[player]
    return data and data.Achievements[id] == true
end

function DataService:ClaimDaily(player)
    local data = profiles[player]
    if not data then return false, 0 end
    local day = math.floor(os.time() / 86400)
    if data.DailyClaim == day then return false, 0 end

    if data.DailyClaim == day - 1 then
        data.DailyStreak += 1
    else
        data.DailyStreak = 1
    end
    data.DailyClaim = day
    local reward = math.min(25 + (data.DailyStreak - 1) * 5, 75)
    data.Coins += reward
    sync(player)
    return true, reward
end

local function write(player, removeAfter)
    if saving[player] or loadFailed[player] then return false end
    local data = profiles[player]
    if not data then return false end

    saving[player] = true
    local payload = {
        Coins = data.Coins,
        Wins = data.Wins,
        Rounds = data.Rounds,
        BestStreak = data.BestStreak,
        CurrentStreak = data.CurrentStreak,
        DailyClaim = data.DailyClaim,
        DailyStreak = data.DailyStreak,
        Achievements = data.Achievements,
    }

    local ok, err = pcall(function()
        Store:UpdateAsync("p_" .. player.UserId, function()
            return payload
        end)
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
    local data = cloneDefault()
    local ok, saved = pcall(function()
        return Store:GetAsync("p_" .. player.UserId)
    end)

    if not ok then
        loadFailed[player] = true
        warn("[ToiletRush] Data load failed for " .. player.Name .. ". Player will not be saved this session.")
    elseif type(saved) == "table" then
        for _, key in ipairs({"Coins", "Wins", "Rounds", "BestStreak", "CurrentStreak", "DailyClaim", "DailyStreak"}) do
            if type(saved[key]) == "number" then
                data[key] = math.max(0, math.floor(saved[key]))
            end
        end
        if type(saved.Achievements) == "table" then
            data.Achievements = saved.Achievements
        end
    end

    profiles[player] = data

    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    sync(player)
end

Players.PlayerAdded:Connect(load)
Players.PlayerRemoving:Connect(function(player)
    write(player, true)
end)

task.spawn(function()
    while true do
        task.wait(60)
        for _, player in Players:GetPlayers() do
            task.spawn(function()
                write(player, false)
            end)
        end
    end
end)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        write(player, true)
    end
end)

return DataService
