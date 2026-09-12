local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Config = require(game.ReplicatedStorage:WaitForChild("Config"))
local Store = DataStoreService:GetDataStore("ToiletRush_PlayerData_v3")

local DataService = {}
local profiles = {}
local saving = {}
local loadFailed = {}

local DEFAULT = { Coins = Config.Economy.StartingCoins, Wins = 0, Rounds = 0 }

local function cloneDefault()
    return { Coins = DEFAULT.Coins, Wins = DEFAULT.Wins, Rounds = DEFAULT.Rounds }
end

local function sync(player)
    local data = profiles[player]
    if not data then return end
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return end
    local coins = stats:FindFirstChild("Coins")
    local wins = stats:FindFirstChild("Wins")
    if coins then coins.Value = data.Coins end
    if wins then wins.Value = data.Wins end
    player:SetAttribute("RoundsPlayed", data.Rounds)
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
    if survived then data.Wins += 1 end
    sync(player)
end

local function write(player, removeAfter)
    if saving[player] or loadFailed[player] then return false end
    local data = profiles[player]
    if not data then return false end

    saving[player] = true
    local payload = { Coins = data.Coins, Wins = data.Wins, Rounds = data.Rounds }
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
        for key in pairs(data) do
            if type(saved[key]) == "number" then
                data[key] = math.max(0, math.floor(saved[key]))
            end
        end
    end

    profiles[player] = data

    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = stats
    local wins = Instance.new("IntValue")
    wins.Name = "Wins"
    wins.Parent = stats
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
