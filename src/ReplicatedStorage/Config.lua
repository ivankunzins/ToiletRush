local Config = {}

Config.Round = {
    Duration = 180,
    LifebuoyWindow = 20,
    Intermission = 10,
    ResultsDuration = 7,
    MinimumPlayers = 1,
}

Config.Economy = {
    StartingCoins = 30,
    CoinValue = 1,
    RareCoinValue = 5,
    LifebuoyCost = 25,
    SurvivalReward = 40,
    ParticipationReward = 10,
}

Config.World = {
    ArenaRadius = 105,
    ArenaY = 12,
    CoinCount = 54,
    RareCoinCount = 6,
    CoinRespawnSeconds = 4,
    ObstacleCount = 24,
    SpawnCount = 16,
}

Config.Flush = {
    Duration = 10,
    PullRadius = 115,
    PullStrength = 125,
    SpinStrength = 52,
    SinkDepth = 34,
}

return Config
