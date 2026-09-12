# 🚽 Toilet Rush: DON'T GET FLUSHED!

A colorful bathroom obstacle game inside a giant toilet. Collect points, climb three upper floors, avoid harmless bathroom obstacles, unlock a Lifebuoy and survive the BIG FLUSH.

## Быстрый запуск в Roblox Studio

Rojo не нужен для обычного запуска.

1. Открой Roblox Studio и свой Place.
2. Включи `Game Settings → Security → Allow HTTP Requests`.
3. Открой `View → Command Bar`.
4. Открой `INSTALL.lua` из этого репозитория, скопируй его целиком и вставь в Command Bar.
5. Нажми Enter и дождись сообщения `[ToiletRush] ГОТОВО. Нажми Play.`
6. Нажми Play.

Установщик сам скачивает актуальные исходники из GitHub и создаёт их в правильных сервисах Roblox. Повторный запуск заменяет старые версии скриптов и пересоздаёт runtime-арену.

## Игровой цикл

`ЛОББИ → 10 секунд → 180 секунд раунда → сбор 30+ очков → покупка Lifebuoy → подъём на 3 этажа → кнопка FLUSH → 10-секундный BIG FLUSH → награды → следующий раунд`.

### Очки и спасательный круг

- Обычная монета: **+5 очков**.
- Редкая монета: **+10 очков**.
- Для открытия покупки нужно собрать **30 очков за текущий раунд**.
- После открытия кнопка покупки появляется сразу.
- Lifebuoy стоит **25 сохранённых монет**.
- Круг надевается визуально на персонажа и спасает от BIG FLUSH.
- После покупки круг сохраняется на персонаже даже после обычного падения/респавна до конца раунда.

### Верхний маршрут

Внутри гигантского унитаза есть **3 верхних этажа** с лестницами и забавными препятствиями:

- вращающиеся швабры;
- рулоны туалетной бумаги;
- огромные вантузы;
- мыльные платформы;
- шторка душа;
- светящиеся стрелки и указатели маршрута;
- верхний пьедестал с кнопкой `FLUSH ALL`.

Препятствия **не наносят урон и не убивают игрока** — они блокируют путь или отталкивают. Если игрок всё же падает за пределы маршрута, он автоматически возвращается и продолжает собирать очки в том же раунде.

### BIG FLUSH

Раунд заканчивается через 180 секунд или раньше, если игрок добирается до верхней кнопки и нажимает `E`.

Игрок на верхней кнопке считается спасённым. Игроки ниже втягиваются в слив. Игрок с Lifebuoy также переживает смыв.

## Звук и визуал

- фоновая музыка;
- звук сбора обычных и редких монет;
- частицы воды, пузырьки и блеск монет;
- плитка, окно, зеркало, раковина, душ, полотенца и другие детали ванной;
- улучшенное глобальное освещение и отражения.

Фоновая музыка использует официальный пример Roblox с asset `1841461968`; Roblox указывает его как пример upbeat 2D background audio. urlRoblox Creator Hub — 2D audiohttps://create.roblox.com/docs/tutorials/use-case-tutorials/audio/add-2D-audio

## Прогресс и сохранения

Сохраняются монеты, победы, раунды, серии побед, XP, уровни, ежедневная награда и достижения.

Для DataStore опубликуй игру и включи `Game Settings → Security → Enable Studio Access to API Services` при тестировании в Studio.

## Структура

- `ReplicatedStorage/Config`
- серверные `AchievementService`, `BathroomArchitecture`, `CoinService`, `DataService`, `FlushService`, `HazardService`, `Main`, `RoundService`, `RoundServiceFixed`, `RoundStatsService`, `ShopService`, `UpperCourseBuilder`, `VisualEffectsBuilder`, `WorldBuilder`
- клиентские `Achievements`, `Audio`, `CoinGoal`, `ConsistencyPatch`, `Effects`, `Feedback`, `HUD`, `LifebuoyButton`, `Menu`
- `ToiletArena` и RemoteEvents создаются автоматически при запуске.

## Важно

GitHub содержит исходную версию игры. Roblox Studio используется для реального playtest. Автоматического Roblox runtime в этом workflow нет, поэтому финальную физику, звук и UI нужно проверять через `Play` в Studio.
