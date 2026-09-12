# 🚽 Toilet Rush: DON'T GET FLUSHED!

Collect coins, dodge bathroom hazards, buy a Lifebuoy in the final 20 seconds and survive the BIG FLUSH.

## Быстрый запуск в Roblox Studio

Rojo больше не нужен для обычного запуска.

1. Открой Roblox Studio и свой Place.
2. Включи `Game Settings → Security → Allow HTTP Requests`.
3. Открой `View → Command Bar`.
4. Открой файл `INSTALL.lua` из этого репозитория, скопируй его целиком и вставь в Command Bar.
5. Нажми Enter и дождись сообщения `[ToiletRush] ГОТОВО. Нажми Play.`
6. Нажми Play.

Установщик сам скачает актуальные скрипты из GitHub и создаст их в правильных сервисах Roblox. Повторный запуск установщика безопасен: старые версии этих скриптов и сгенерированный runtime удаляются перед установкой.

## Что устанавливается

- `ReplicatedStorage/Config`
- серверные `CoinService`, `DataService`, `FlushService`, `HazardService`, `Main`, `RoundService`, `ShopService`, `WorldBuilder`
- клиентские `Effects` и `HUD`
- арена `ToiletArena` и RemoteEvents создаются автоматически при запуске игры

## Игровой цикл

10-секундная пауза → 180-секундный раунд → сбор монет → опасности → последние 20 секунд: магазин спасательного круга → 10-секундный BIG FLUSH → награды → следующий раунд.

Лифebuoy стоит 25 монет. Обычная монета даёт +1, редкая +5. Выживший получает +40 монет и победу, игрока, которого смыло, ждёт +10 монет.

## Сохранения

Для DataStore опубликуй игру и включи `Game Settings → Security → Enable Studio Access to API Services` при тестировании в Studio.

## Разработка

Исходники остаются в GitHub и являются источником версии. Roblox Studio — место, где запускается и тестируется игра. `default.project.json` и исходная структура `src/` сохранены для Rojo, если позже понадобится полноценный GitHub → Studio workflow.
