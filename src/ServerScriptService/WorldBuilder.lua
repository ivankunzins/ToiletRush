local Workspace = game:GetService("Workspace")
local Config = require(game.ReplicatedStorage:WaitForChild("Config"))

local WorldBuilder = {}
local rng = Random.new(20260912)

local function part(parent, name, size, cframe, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.CanCollide = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function label(parent, text, color, size, offset)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(size, 50)
    gui.StudsOffset = offset or Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = parent
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = color
    t.TextScaled = true
    t.Font = Enum.Font.GothamBlack
    t.Parent = gui
end

function WorldBuilder:Build()
    local old = Workspace:FindFirstChild("ToiletArena")
    if old then old:Destroy() end

    local arena = Instance.new("Folder")
    arena.Name = "ToiletArena"
    arena.Parent = Workspace

    local floor = part(arena, "ArenaFloor", Vector3.new(240, 4, 240), CFrame.new(0, 0, 0), Enum.Material.Marble)
    floor.Color = Color3.fromRGB(225, 235, 238)

    -- Giant toilet bowl / arena rim.
    local bowl = part(arena, "Bowl", Vector3.new(185, 12, 185), CFrame.new(0, 3, 0), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
    bowl.Color = Color3.fromRGB(245, 245, 245)
    bowl.CanCollide = true

    local water = part(arena, "Water", Vector3.new(118, 1.5, 118), CFrame.new(0, 10, 0), Enum.Material.Glass, Enum.PartType.Cylinder)
    water.Color = Color3.fromRGB(80, 190, 255)
    water.Transparency = 0.22
    water.CanCollide = false
    water:SetAttribute("IsFlushWater", true)

    for i = 1, 20 do
        local a = (i / 20) * math.pi * 2
        local r = 98
        local x, z = math.cos(a) * r, math.sin(a) * r
        local rim = part(arena, "ToiletRim", Vector3.new(12, 7, 25), CFrame.new(x, 10, z) * CFrame.Angles(0, -a, 0), Enum.Material.Marble)
        rim.Color = Color3.fromRGB(250, 250, 250)
    end

    local drain = part(arena, "Drain", Vector3.new(22, 1, 22), CFrame.new(0, 10.7, 0), Enum.Material.Metal, Enum.PartType.Cylinder)
    drain.Color = Color3.fromRGB(55, 65, 70)
    drain.CanCollide = false

    local sign = part(arena, "Sign", Vector3.new(38, 10, 2), CFrame.new(0, 32, -105), Enum.Material.SmoothPlastic)
    sign.Color = Color3.fromRGB(25, 28, 34)
    label(sign, "🚽 DON'T GET FLUSHED!", Color3.fromRGB(255, 255, 255), 360, Vector3.new(0, 0, 0))

    local spawns = Instance.new("Folder")
    spawns.Name = "Spawns"
    spawns.Parent = arena
    for i = 1, 16 do
        local a = (i / 16) * math.pi * 2
        local r = 72
        local s = part(spawns, "Spawn" .. i, Vector3.new(5, 1, 5), CFrame.new(math.cos(a) * r, 13, math.sin(a) * r), Enum.Material.Neon)
        s.Transparency = 1
        s.CanCollide = false
    end

    local obstacles = Instance.new("Folder")
    obstacles.Name = "Obstacles"
    obstacles.Parent = arena
    for i = 1, Config.World.ObstacleCount do
        local a = rng:NextNumber(0, math.pi * 2)
        local r = rng:NextNumber(25, 82)
        local x, z = math.cos(a) * r, math.sin(a) * r
        local kind = i % 3
        if kind == 0 then
            local b = part(obstacles, "Pipe", Vector3.new(26, 5, 5), CFrame.new(x, 15, z) * CFrame.Angles(0, a, 0), Enum.Material.Metal)
            b.Color = Color3.fromRGB(255, 145, 55)
        elseif kind == 1 then
            local b = part(obstacles, "SoapBlock", Vector3.new(14, 3, 14), CFrame.new(x, 12, z), Enum.Material.SmoothPlastic)
            b.Color = Color3.fromRGB(255, 170, 220)
        else
            local b = part(obstacles, "Brush", Vector3.new(5, 16, 5), CFrame.new(x, 19, z), Enum.Material.Metal, Enum.PartType.Cylinder)
            b.Color = Color3.fromRGB(120, 75, 45)
        end
    end

    local coins = Instance.new("Folder")
    coins.Name = "Coins"
    coins.Parent = arena

    for i = 1, Config.World.CoinCount do
        local a = rng:NextNumber(0, math.pi * 2)
        local r = rng:NextNumber(15, 88)
        local c = part(coins, "Coin" .. i, Vector3.new(2.4, 0.7, 2.4), CFrame.new(math.cos(a) * r, 16, math.sin(a) * r), Enum.Material.Neon, Enum.PartType.Cylinder)
        c.Color = Color3.fromRGB(255, 220, 40)
        c.CanCollide = false
        c.CanTouch = true
        c:SetAttribute("Collected", false)
    end

    return arena
end

return WorldBuilder
