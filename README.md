# 🚽 Toilet Rush: DON'T GET FLUSHED!

Roblox multiplayer survival game built around one simple question: **who survives the flush?**

## Game loop
1. A 3-minute round begins.
2. Players run around a giant toilet arena and collect Flush Coins.
3. Obstacles force movement, jumping and route decisions.
4. At 20 seconds remaining, the Lifebuoy shop opens.
5. A Lifebuoy costs 25 Flush Coins.
6. At zero, the toilet flush starts: players are pulled toward the drain and spun down.
7. Lifebuoy owners float and survive.
8. Survivors receive a larger reward; eliminated players receive a participation reward.
9. The next round starts after the results window.

## Technical architecture
- **Luau** with server-authoritative gameplay.
- **Rojo** project layout for source-controlled Roblox development.
- Modular services: `DataService`, `RoundService`, `CoinService`, `ShopService`, `FlushService`, `WorldBuilder`.
- RemoteEvents are created by the server at runtime.
- Coin collection and Lifebuoy purchases are validated on the server.
- Player Coins/Wins are persisted with DataStore.
- Arena geometry and collectibles are generated procedurally, so the first playable build needs no external asset pack.
- HUD is generated client-side and designed for mobile touch input.

## Project structure
```text
src/
├── ReplicatedStorage/
│   └── Config.lua
├── ServerScriptService/
│   ├── Main.server.lua
│   ├── DataService.lua
│   ├── WorldBuilder.lua
│   ├── RoundService.lua
│   ├── CoinService.lua
│   ├── ShopService.lua
│   └── FlushService.lua
└── StarterPlayer/
    └── StarterPlayerScripts/
        └── HUD.client.lua
```

## Roblox Studio
1. Install Rojo.
2. Clone this repository.
3. Open a Roblox place in Studio.
4. Start the Rojo server and connect the place using `default.project.json`.
5. For DataStore testing in Studio, enable **Game Settings → Security → Enable Studio Access to API Services** in the test experience.
6. Publish the experience before testing production DataStore behavior.

## Production roadmap
- Replace primitive geometry with polished toilet/obstacle assets.
- Add VFX, SFX, music and camera shake to make the final 20 seconds feel explosive.
- Add more obstacle patterns and arena variants.
- Add cosmetics, quests, streaks and daily rewards.
- Add analytics events and economy balancing.
- Add monetization only after the core loop demonstrates retention.
- Profile server performance with realistic player counts before release.
