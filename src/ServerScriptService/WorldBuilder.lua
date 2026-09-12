local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Config = require(game.ReplicatedStorage:WaitForChild("Config"))

local WorldBuilder = {}
local rng = Random.new()

local WHITE = Color3.fromRGB(245, 248, 250)
local DARK = Color3.fromRGB(28, 33, 40)
local BLUE = Color3.fromRGB(45, 185, 255)
local GOLD = Color3.fromRGB(255, 213, 50)

local function part(parent, name, size, cframe, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.CanCollide = true
    p.CanTouch = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function billboard(parent, text, color, width, height, offset)
    local gui = Instance.new("BillboardGui")
    gui.Name = "Label"
    gui.Size = UDim2.fromOffset(width, height)
    gui.StudsOffset = offset or Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 250
    gui.Parent = parent
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = color
    t.TextStrokeTransparency = 0.25
    t.TextScaled = true
    t.Font = Enum.Font.GothamBlack
    t.Parent = gui
    return gui
end

local function neonRing(parent, radius, y, segments)
    for i = 1, segments do
        local a = (i / segments) * math.pi * 2
        local p = part(parent, "NeonRim", Vector3.new(3, 0.35, 9), CFrame.new(math.cos(a) * radius, y, math.sin(a) * radius) * CFrame.Angles(0, -a, 0), Enum.Material.Neon)
        p.Color = BLUE
        p.CanCollide = false
        p.CanTouch = false
    end
end

local function hazardAttributes(p, motion, speed, distance)
    p:SetAttribute("Motion", motion)
    p:SetAttribute("Speed", speed)
    p:SetAttribute("Distance", distance)
    p:SetAttribute("Hazard", true)
    return p
end

function WorldBuilder:Build()
    local old = Workspace:FindFirstChild("ToiletArena")
    if old then old:Destroy() end

    Lighting.ClockTime = 14
    Lighting.Brightness = 2.2
    Lighting.EnvironmentDiffuseScale = 0.7
    Lighting.EnvironmentSpecularScale = 0.8

    local atmosphere = Lighting:FindFirstChild("ToiletAtmosphere") or Instance.new("Atmosphere")
    atmosphere.Name = "ToiletAtmosphere"
    atmosphere.Density = 0.25
    atmosphere.Offset = 0.15
    atmosphere.Glare = 0.15
    atmosphere.Haze = 0.8
    atmosphere.Parent = Lighting

    local bloom = Lighting:FindFirstChild("ToiletBloom") or Instance.new("BloomEffect")
    bloom.Name = "ToiletBloom"
    bloom.Intensity = 0.45
    bloom.Size = 22
    bloom.Threshold = 1.1
    bloom.Parent = Lighting

    local color = Lighting:FindFirstChild("ToiletColor") or Instance.new("ColorCorrectionEffect")
    color.Name = "ToiletColor"
    color.Contrast = 0.08
    color.Saturation = 0.12
    color.Parent = Lighting

    local arena = Instance.new("Folder")
    arena.Name = "ToiletArena"
    arena.Parent = Workspace

    local floor = part(arena, "ArenaFloor", Vector3.new(250, 5, 250), CFrame.new(0, -1, 0), Enum.Material.Marble)
    floor.Color = Color3.fromRGB(218, 228, 232)

    local bowl = part(arena, "Bowl", Vector3.new(205, 12, 205), CFrame.new(0, 4, 0), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
    bowl.Color = WHITE

    local inner = part(arena, "InnerBowl", Vector3.new(176, 3, 176), CFrame.new(0, 10, 0), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
    inner.Color = Color3.fromRGB(232, 239, 242)

    local water = part(arena, "Water", Vector3.new(124, 1.5, 124), CFrame.new(0, 11.8, 0), Enum.Material.Glass, Enum.PartType.Cylinder)
    water.Color = BLUE
    water.Transparency = 0.28
    water.CanCollide = false
    water.CanTouch = false
    water:SetAttribute("BaseSize", Vector3.new(124, 1.5, 124))

    neonRing(arena, 61, 12.65, 24)
    neonRing(arena, 93, 12.8, 32)

    local drain = part(arena, "Drain", Vector3.new(26, 1.4, 26), CFrame.new(0, 12.7, 0), Enum.Material.Metal, Enum.PartType.Cylinder)
    drain.Color = Color3.fromRGB(45, 52, 58)
    drain.CanCollide = false
    drain.CanTouch = false
    for i = 1, 8 do
        local a = (i / 8) * math.pi * 2
        local bar = part(arena, "DrainBar", Vector3.new(22, 0.45, 1.1), CFrame.new(0, 13.45, 0) * CFrame.Angles(0, a, 0), Enum.Material.Metal)
        bar.Color = Color3.fromRGB(120, 130, 138)
        bar.CanCollide = false
        bar.CanTouch = false
    end

    local handleBase = part(arena, "FlushHandleBase", Vector3.new(8, 2, 8), CFrame.new(0, 18, -101), Enum.Material.Metal, Enum.PartType.Cylinder)
    handleBase.Color = DARK
    local handle = part(arena, "FlushHandle", Vector3.new(3, 9, 3), CFrame.new(0, 23, -101), Enum.Material.Metal, Enum.PartType.Cylinder)
    handle.Color = Color3.fromRGB(255, 90, 90)
    billboard(handle, "THE BIG FLUSH", Color3.new(1, 1, 1), 260, 45, Vector3.new(0, 5, 0))

    local sign = part(arena, "Sign", Vector3.new(54, 13, 2), CFrame.new(0, 31, -104), Enum.Material.SmoothPlastic)
    sign.Color = DARK
    billboard(sign, "🚽 DON'T GET FLUSHED!", Color3.new(1, 1, 1), 560, 70, Vector3.new(0, 0, 0))

    local instruction = part(arena, "Instruction", Vector3.new(42, 8, 2), CFrame.new(0, 25, 104), Enum.Material.SmoothPlastic)
    instruction.Color = DARK
    billboard(instruction, "RUN • COLLECT • BUY • SURVIVE", Color3.fromRGB(255, 225, 70), 460, 55, Vector3.new(0, 0, 0))

    local spawns = Instance.new("Folder")
    spawns.Name = "Spawns"
    spawns.Parent = arena
    for i = 1, Config.World.SpawnCount do
        local a = (i / Config.World.SpawnCount) * math.pi * 2
        local s = part(spawns, "Spawn" .. i, Vector3.new(5, 0.5, 5), CFrame.new(math.cos(a) * 75, 14, math.sin(a) * 75), Enum.Material.Neon)
        s.Transparency = 1
        s.CanCollide = false
        s.CanTouch = false
    end

    local obstacles = Instance.new("Folder")
    obstacles.Name = "Obstacles"
    obstacles.Parent = arena

    for i = 1, Config.World.ObstacleCount do
        local a = ((i - 1) / Config.World.ObstacleCount) * math.pi * 2 + rng:NextNumber(-0.12, 0.12)
        local r = 32 + ((i * 17) % 52)
        local x, z = math.cos(a) * r, math.sin(a) * r
        local kind = i % 4
        if kind == 0 then
            local b = part(obstacles, "Sweeper", Vector3.new(30, 3.5, 4), CFrame.new(x, 17, z) * CFrame.Angles(0, a, 0), Enum.Material.Metal)
            b.Color = Color3.fromRGB(255, 120, 45)
            hazardAttributes(b, "ROTATE", 0.9 + (i % 3) * 0.18, 0)
            local hub = part(obstacles, "SweeperHub", Vector3.new(6, 6, 6), CFrame.new(x, 17, z), Enum.Material.Metal, Enum.PartType.Ball)
            hub.Color = DARK
            hub.CanCollide = false
            hub.CanTouch = false
        elseif kind == 1 then
            local b = part(obstacles, "Soap", Vector3.new(12, 4, 12), CFrame.new(x, 14, z), Enum.Material.SmoothPlastic)
            b.Color = Color3.fromRGB(255, 145, 205)
            hazardAttributes(b, "BOUNCE", 1.2 + (i % 2) * 0.3, 2.5)
        elseif kind == 2 then
            local b = part(obstacles, "Pipe", Vector3.new(7, 7, 32), CFrame.new(x, 16, z) * CFrame.Angles(0, a, 0), Enum.Material.Metal)
            b.Color = Color3.fromRGB(255, 170, 55)
            hazardAttributes(b, "SWEEP", 0.8 + (i % 4) * 0.12, 9)
        else
            local b = part(obstacles, "Brush", Vector3.new(7, 20, 7), CFrame.new(x, 22, z), Enum.Material.Wood, Enum.PartType.Cylinder)
            b.Color = Color3.fromRGB(125, 78, 42)
            hazardAttributes(b, "ROTATE", 0.55 + (i % 3) * 0.08, 0)
            local bristles = part(obstacles, "Bristles", Vector3.new(13, 3, 13), CFrame.new(x, 31, z), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
            bristles.Color = Color3.fromRGB(45, 48, 52)
            bristles.CanCollide = false
            bristles.CanTouch = false
        end
    end

    local coins = Instance.new("Folder")
    coins.Name = "Coins"
    coins.Parent = arena

    for i = 1, Config.World.CoinCount do
        local a = rng:NextNumber(0, math.pi * 2)
        local r = rng:NextNumber(20, 91)
        local c = part(coins, "Coin" .. i, Vector3.new(2.8, 0.75, 2.8), CFrame.new(math.cos(a) * r, 17, math.sin(a) * r), Enum.Material.Neon, Enum.PartType.Cylinder)
        c.Color = GOLD
        c.CanCollide = false
        c.CanTouch = true
        c:SetAttribute("Collected", false)
        c:SetAttribute("Value", Config.Economy.CoinValue)
    end

    for i = 1, Config.World.RareCoinCount do
        local a = rng:NextNumber(0, math.pi * 2)
        local r = rng:NextNumber(30, 86)
        local c = part(coins, "RareCoin" .. i, Vector3.new(4, 1, 4), CFrame.new(math.cos(a) * r, 20, math.sin(a) * r), Enum.Material.Neon, Enum.PartType.Cylinder)
        c.Color = Color3.fromRGB(180, 90, 255)
        c.CanCollide = false
        c.CanTouch = true
        c:SetAttribute("Collected", false)
        c:SetAttribute("Value", Config.Economy.RareCoinValue)
        billboard(c, "+5", Color3.fromRGB(220, 180, 255), 90, 30, Vector3.new(0, 2.5, 0))
    end

    return arena
end

return WorldBuilder
