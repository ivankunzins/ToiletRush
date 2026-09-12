local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Config = require(game.ReplicatedStorage:WaitForChild("Config"))
local Store = DataStoreService:GetDataStore("ToiletRush_PlayerData_v1")

local DataService = {}
local profiles = {}

local DEFAULT = {
    Coins = Config.Economy.StartingCoins,
    Wins = 0,
    Rounds = 0,
}

local function copyDefault()
    return {
        Coins = DEFAULT.Coins,
        Wins = DEFAULT.Wins,
        Rounds = DEFAULT.Rounds,
    }
end

function DataService:Get(player)
    return profiles[player]
end

function DataService:AddCoins(player, amount)
    local data = profiles[player]
    if not data then return false end
    data.Coins += amount
    local leaderstats = player:FindFirstChild("leaderstats")
    local coins = leaderstats and leaderstats:FindFirstChild("Coins")
    if coins then coins.Value = data.Coins end
    return true
end

function DataService:SpendCoins(player, amount)
    local data = profiles[player]
    if not data or data.Coins < amount then return false end
    data.Coins -= amount
    local leaderstats = player:FindFirstChild("leaderstats")
    local coins = leaderstats and leaderstats:FindFirstChild("Coins")
    if coins then coins.Value = data.Coins end
    return true
end

function DataService:MarkRound(player, survived)
    local data = profiles[player]
    if not data then return end
    data.Rounds += 1
    if survived then data.Wins += 1 end
end

local function load(player)
    local key = "p_" .. player.UserId
    local data = copyDefault()
    local ok, saved = pcall(function()
        return Store:GetAsync(key)
    end)
    if ok and type(saved) == "table" then
        for k in pairs(data) do
            if type(saved[k]) == "number" then data[k] = saved[k] end
        end
    end
    profiles[player] = data

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = data.Coins
    coins.Parent = leaderstats

    local wins = Instance.new("IntValue")
    wins.Name = "Wins"
    wins.Value = data.Wins
    wins.Parent = leaderstats
end

local function save(player)
    local data = profiles[player]
    if not data then return end
    local key = "p_" .. player.UserId
    local payload = {
        Coins = data.Coins,
        Wins = data.Wins,
        Rounds = data.Rounds,
    }
    pcall(function()
        Store:UpdateAsync(key, function()
            return payload
        end)
    end)
    profiles[player] = nil
end

Players.PlayerAdded:Connect(load)
Players.PlayerRemoving:Connect(save)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        save(player)
    end
end)

return DataService
