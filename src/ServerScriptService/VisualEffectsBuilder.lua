local VisualEffectsBuilder = {}

local function emitter(parent, name, texture, color, rate, lifetime, speed, size)
    local old = parent:FindFirstChild(name)
    if old then old:Destroy() end

    local e = Instance.new("ParticleEmitter")
    e.Name = name
    e.Texture = texture
    e.Color = ColorSequence.new(color)
    e.Rate = rate
    e.Lifetime = NumberRange.new(lifetime[1], lifetime[2])
    e.Speed = NumberRange.new(speed[1], speed[2])
    e.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, size),
        NumberSequenceKeypoint.new(1, 0),
    })
    e.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 1),
    })
    e.LightEmission = 0.7
    e.SpreadAngle = Vector2.new(180, 180)
    e.RotSpeed = NumberRange.new(-80, 80)
    e.Parent = parent
    return e
end

function VisualEffectsBuilder:Apply(arena)
    local water = arena:FindFirstChild("Water")
    if water then
        emitter(water, "WaterSparkles", "rbxassetid://1266170131", Color3.fromRGB(100, 220, 255), 8, {1.2, 2.2}, {1, 3}, 0.45)
    end

    local drain = arena:FindFirstChild("Drain")
    if drain then
        emitter(drain, "DrainBubbles", "rbxassetid://1266170131", Color3.fromRGB(180, 245, 255), 5, {0.8, 1.5}, {2, 5}, 0.35)
    end

    local bathroom = arena:FindFirstChild("Bathroom")
    if bathroom then
        for _, object in bathroom:GetChildren() do
            if object.Name == "ShowerHead" and object:IsA("BasePart") then
                emitter(object, "ShowerMist", "rbxassetid://1266170131", Color3.fromRGB(175, 225, 255), 18, {0.4, 0.9}, {4, 8}, 0.28)
            end
        end
    end

    local coins = arena:FindFirstChild("Coins")
    if coins then
        for _, coin in coins:GetChildren() do
            if coin:IsA("BasePart") then
                emitter(coin, "CoinSparkle", "rbxassetid://1266170131", coin.Name:match("^RareCoin") and Color3.fromRGB(210, 150, 255) or Color3.fromRGB(255, 225, 80), 2, {0.35, 0.8}, {0.2, 0.8}, 0.18)
            end
        end
    end

    arena:SetAttribute("VisualEffectsReady", true)
end

return VisualEffectsBuilder
