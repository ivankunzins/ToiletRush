local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Config = require(game.ReplicatedStorage:WaitForChild("Config"))
local Store = DataStoreService:GetDataStore("ToiletRush_PlayerData_v2")

local DataService = {}
local profiles = {}
local saving = {}

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

local function load(player)
    local data = cloneDefault()
    local ok, saved = pcall(function()
        return Store:GetAsync("p_" .. player.UserId)
    end)
    if ok and type(saved) == "table" then
        for key in pairs(data) do
            if type(saved[key]) == "number" then data[key] = math.max(0, math.floor(saved[key])) end
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

local function save(player)
    if saving[player] then return end
    local data = profiles[player]
    if not data then return end
    saving[player] = true
    local payload = { Coins = data.Coins, Wins = data.Wins, Rounds = data.Rounds }
    pcall(function()
        Store:UpdateAsync("p_" .. player.UserId, function()
            return payload
        end)
    end)
    saving[player] = nil
    profiles[player] = nil
end

Players.PlayerAdded:Connect(load)
Players.PlayerRemoving:Connect(save)
game:BindToClose(function()
    for _, player in Players:GetPlayers() do save(player) end
end)

return DataService
