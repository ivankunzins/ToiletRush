# 🚽 Toilet Rush: DON'T GET FLUSHED!

A fast Roblox multiplayer survival game: collect coins, dodge ridiculous bathroom hazards, buy a Lifebuoy in the final 20 seconds, and survive the BIG FLUSH.

## Core loop
- 10-second intermission.
- 180-second survival round.
- Collect regular coins (+1) and rare coins (+5).
- Dodge rotating sweepers, bouncing soap, moving pipes and giant brushes.
- At 20 seconds: the Lifebuoy shop opens.
- Lifebuoy price: 25 coins.
- At zero: water contracts, the drain expands, players spin and are pulled inward.
- Lifebuoy owners orbit the drain and survive.
- Survivors get +40 coins and a win; flushed players get +10 participation coins.
- Results screen, then the next round.

## Engineering
- Luau.
- Server-authoritative round, economy, purchases and rewards.
- DataStore persistence for Coins, Wins and Rounds.
- Rojo project layout.
- Procedural arena: no external asset pack is required for the first playable build.
- Client-only cosmetic effects are isolated from authoritative gameplay.

## Project structure
```text
src/
├── ReplicatedStorage/Config.lua
├── ServerScriptService/
│   ├── Main.server.lua
│   ├── DataService.lua
│   ├── WorldBuilder.lua
│   ├── RoundService.lua
│   ├── CoinService.lua
│   ├── ShopService.lua
│   ├── FlushService.lua
│   └── HazardService.server.lua
└── StarterPlayer/StarterPlayerScripts/
    ├── HUD.client.lua
    └── Effects.client.lua
```

## Studio setup
1. Install Rojo.
2. Clone the repository.
3. Open a Roblox place in Studio.
4. Start Rojo and connect with `default.project.json`.
5. Publish the experience before production testing.
6. For DataStore testing in Studio, enable **Game Settings → Security → Enable Studio Access to API Services**.

## Next production pass
- Replace primitives with custom low-poly bathroom assets.
- Add original SFX/music and flush audio cues.
- Add stronger water VFX, particles and camera shake.
- Add arena variants and rotating obstacle layouts.
- Add quests, streaks, cosmetics and daily rewards.
- Add analytics and economy balancing before monetization.
