local Config = {}

Config.Round = {
    Duration = 180,
    Intermission = 10,
    ResultsDuration = 7,
    MinimumPlayers = 1,
}

Config.Economy = {
    StartingCoins = 0,
    CoinValue = 5,
    RareCoinValue = 10,
    LifebuoyUnlockCollected = 30,
    LifebuoyCost = 25,
    SurvivalReward = 40,
    ParticipationReward = 10,
}

Config.RobuxShop = {
    LifebuoyPassId = 0,
    VestPassId = 0,
    BlasterPassId = 0,
    LifebuoyPrice = 10,
    VestPrice = 20,
    BlasterPrice = 40,
}

Config.Progression = {
    CoinXP = 4,
    RareCoinBonusXP = 8,
    HazardXP = 1,
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
    CoinCount = 24,
    RareCoinCount = 4,
    CoinRespawnSeconds = 3,
    CoinPickupRadius = 5.5,
    ObstacleCount = 0,
    SpawnCount = 16,
    Floors = 5,
    FloorHeight = 18,
}

Config.Hazards = {
    Damage = 0,
    Cooldown = 0.65,
    Knockback = 58,
    VerticalKnockback = 14,
}

Config.Boss = {
    Health = 30,
    BlasterDamage = 3,
    StoneDamage = 1,
    AttackInterval = 2.2,
    AttackDamage = 12,
    FlushHoldSeconds = 10,
    FlushRecoverySeconds = 1.25,
    AttackRange = 150,
    Height = 72,
    StoneCount = 30,
}

Config.Flush = {
    Duration = 10,
    PullRadius = 115,
    PullStrength = 125,
    SpinStrength = 52,
    SinkDepth = 34,
    SafeTopPosition = Vector3.new(0, 95, -12),
}

Config.Audio = {
    CoinSoundId = "rbxassetid://6787582810",
    RareCoinSoundId = "rbxassetid://6787582810",
    MusicSoundId = "rbxassetid://1841461968",
    CoinVolume = 0.65,
    RareCoinVolume = 0.9,
    MusicVolume = 0.16,
}

return Config
