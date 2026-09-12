local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local feedback = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Feedback")

local music = SoundService:FindFirstChild("ToiletRushMusic") or Instance.new("Sound")
music.Name = "ToiletRushMusic"
music.SoundId = Config.Audio.MusicSoundId
music.Looped = true
music.Volume = Config.Audio.MusicVolume
music.Parent = SoundService
if not music.IsPlaying then
    task.spawn(function()
        pcall(function()
            if not music.IsLoaded then music.Loaded:Wait() end
            music:Play()
        end)
    end)
end

local function playOneShot(soundId, volume, speed)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume
    sound.PlaybackSpeed = speed or 1
    sound.Parent = SoundService
    sound.Ended:Connect(function() sound:Destroy() end)
    task.spawn(function()
        pcall(function()
            if not sound.IsLoaded then sound.Loaded:Wait() end
            sound:Play()
        end)
        task.delay(5, function()
            if sound.Parent then sound:Destroy() end
        end)
    end)
end

feedback.OnClientEvent:Connect(function(kind)
    if kind == "COIN" then
        playOneShot(Config.Audio.CoinSoundId, Config.Audio.CoinVolume, 1.0)
    elseif kind == "RARE_COIN" then
        playOneShot(Config.Audio.RareCoinSoundId, Config.Audio.RareCoinVolume, 1.15)
    elseif kind == "GOAL" then
        playOneShot(Config.Audio.CoinSoundId, 1.0, 0.82)
    elseif kind == "SHOP_SUCCESS" then
        playOneShot(Config.Audio.CoinSoundId, 0.9, 0.7)
    elseif kind == "LEVEL_UP" then
        playOneShot(Config.Audio.CoinSoundId, 0.95, 0.65)
    end
end)

player.AncestryChanged:Connect(function(_, parent)
    if not parent and music then music:Stop() end
end)
