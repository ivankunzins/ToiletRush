local Config = {}

Config.Round = {
    Duration = 180,
    LifebuoyWindow = 20,
    Intermission = 12,
    MinimumPlayers = 1,
}

Config.Economy = {
    StartingCoins = 0,
    CoinValue = 1,
    LifebuoyCost = 25,
    SurvivalReward = 35,
    ParticipationReward = 10,
}

Config.World = {
    ArenaRadius = 115,
    ArenaY = 8,
    CoinCount = 45,
    CoinRespawnSeconds = 3,
    ObstacleCount = 18,
}

Config.Flush = {
    Duration = 9,
    PullRadius = 125,
    PullStrength = 115,
    SpinStrength = 38,
    SinkDepth = 30,
}

return Config
