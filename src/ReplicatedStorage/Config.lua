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
    CoinValue = 5,
    RareCoinValue = 10,
    LifebuoyCost = 25,
    LifebuoyUnlockCollected = 30,
    SurvivalReward = 40,
    ParticipationReward = 10,
}

Config.Progression = {
    CoinXP = 2,
    RareCoinBonusXP = 5,
    HazardXP = 3,
    SurvivalXP = 50,
    ParticipationXP = 15,
    LevelBaseXP = 100,
    LevelGrowthXP = 50,
    ComboWindow = 4,
    ComboMax = 10,
    ComboXPPerStack = 1,
    ComboCoinBonusPerStack = 0.10,
}

Config.World = {
    ArenaRadius = 105,
    ArenaY = 12,
    CoinCount = 60,
    RareCoinCount = 8,
    CoinRespawnSeconds = 4,
    ObstacleCount = 28,
    SpawnCount = 16,
}

Config.Hazards = {
    Damage = 28,
    Cooldown = 0.8,
    Knockback = 42,
    VerticalKnockback = 18,
}

Config.Flush = {
    Duration = 10,
    PullRadius = 115,
    PullStrength = 125,
    SpinStrength = 52,
    SinkDepth = 34,
}

return Config
