local BathroomArchitecture = {}

local WHITE = Color3.fromRGB(245, 247, 248)
local TILE = Color3.fromRGB(218, 224, 227)
local GROUT = Color3.fromRGB(175, 182, 186)
local DARK = Color3.fromRGB(42, 47, 52)
local METAL = Color3.fromRGB(155, 165, 170)
local GOLD = Color3.fromRGB(255, 211, 58)
local GOLD_DARK = Color3.fromRGB(196, 145, 25)
local GLASS = Color3.fromRGB(130, 190, 215)
local WOOD = Color3.fromRGB(118, 76, 45)

local function makePart(parent, name, size, cf, material, color, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or WHITE
    p.CanCollide = collide ~= false
    p.CanTouch = false
    p.CanQuery = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function addLight(parent, position, brightness, range)
    local p = makePart(parent, "CeilingLight", Vector3.new(7, 0.5, 7), CFrame.new(position), Enum.Material.Neon, Color3.fromRGB(255, 239, 200), false)
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 235, 195)
    light.Brightness = brightness or 1.5
    light.Range = range or 30
    light.Shadows = true
    light.Parent = p
end

local function addTileGrid(parent, wallName, origin, horizontal, vertical, rows, cols, tileW, tileH)
    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            local x = origin.X + horizontal.X * (col * tileW)
            local y = origin.Y + vertical.Y * (row * tileH)
            local z = origin.Z + horizontal.Z * (col * tileW)
            local offset = ((row + col) % 2 == 0) and 0 or 0.5
            x += horizontal.X * (offset * tileW)
            z += horizontal.Z * (offset * tileW)
            local tile = makePart(parent, wallName .. "Tile", Vector3.new(tileW - 0.18, tileH - 0.18, 0.35), CFrame.new(x, y, z), Enum.Material.Marble, (row % 2 == 0) and TILE or WHITE, false)
            tile.CanQuery = false
        end
    end
end

local function makeCoinVisual(coin, rare)
    if not coin:IsA("BasePart") then return end

    coin.Shape = Enum.PartType.Cylinder
    coin.Size = rare and Vector3.new(1.1, 4.2, 4.2) or Vector3.new(0.9, 3.4, 3.4)
    coin.CFrame = CFrame.new(coin.Position) * CFrame.Angles(0, 0, math.rad(90))
    coin.Material = Enum.Material.Metal
    coin.Color = rare and Color3.fromRGB(170, 95, 255) or GOLD
    coin.CanCollide = false
    coin.CanTouch = true
    coin.CanQuery = true
    coin.CastShadow = false

    local light = coin:FindFirstChild("CoinLight")
    if not light then
        light = Instance.new("PointLight")
        light.Name = "CoinLight"
        light.Brightness = rare and 1.6 or 0.8
        light.Range = rare and 12 or 8
        light.Color = coin.Color
        light.Parent = coin
    end

    local gui = coin:FindFirstChild("CoinPrompt")
    if not gui then
        gui = Instance.new("BillboardGui")
        gui.Name = "CoinPrompt"
        gui.Size = UDim2.fromOffset(110, 42)
        gui.StudsOffset = Vector3.new(0, 2.9, 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 150
        gui.Parent = coin

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = "+" .. tostring(rare and 10 or 5)
        label.TextColor3 = rare and Color3.fromRGB(225, 195, 255) or GOLD
        label.TextStrokeTransparency = 0.2
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.Parent = gui
    end
end

function BathroomArchitecture:Apply(arena)
    local bathroom = arena:FindFirstChild("Bathroom") or Instance.new("Folder")
    bathroom.Name = "Bathroom"
    bathroom.Parent = arena

    -- Make the shell feel like a real, enclosed bathroom instead of a flat arena.
    makePart(bathroom, "FloorTrimBack", Vector3.new(246, 3, 2), CFrame.new(0, 4.5, -113.5), Enum.Material.Marble, WHITE, true)
    makePart(bathroom, "FloorTrimFront", Vector3.new(246, 3, 2), CFrame.new(0, 4.5, 113.5), Enum.Material.Marble, WHITE, true)
    makePart(bathroom, "FloorTrimLeft", Vector3.new(2, 3, 246), CFrame.new(-113.5, 4.5, 0), Enum.Material.Marble, WHITE, true)
    makePart(bathroom, "FloorTrimRight", Vector3.new(2, 3, 246), CFrame.new(113.5, 4.5, 0), Enum.Material.Marble, WHITE, true)

    -- Dark grout gives the large walls a convincing tile scale.
    for y = 7, 49, 6 do
        for _, spec in ipairs({
            {"Back", Vector3.new(246, 0.22, 0.35), CFrame.new(0, y, -113.1)},
            {"Front", Vector3.new(246, 0.22, 0.35), CFrame.new(0, y, 113.1)},
            {"Left", Vector3.new(0.35, 0.22, 246), CFrame.new(-113.1, y, 0)},
            {"Right", Vector3.new(0.35, 0.22, 246), CFrame.new(113.1, y, 0)},
        }) do
            makePart(bathroom, "Grout" .. spec[1], spec[2], spec[3], Enum.Material.SmoothPlastic, GROUT, false)
        end
    end

    -- Large divided window with a believable outdoor backdrop.
    local windowView = makePart(bathroom, "NaturalWindowView", Vector3.new(82, 30, 0.5), CFrame.new(0, 34, -112.9), Enum.Material.SmoothPlastic, Color3.fromRGB(126, 184, 215), false)
    local skyTop = makePart(bathroom, "WindowSky", Vector3.new(78, 12, 0.25), CFrame.new(0, 42, -112.55), Enum.Material.Neon, Color3.fromRGB(105, 180, 225), false)
    local horizon = makePart(bathroom, "WindowHorizon", Vector3.new(78, 10, 0.25), CFrame.new(0, 30, -112.5), Enum.Material.Grass, Color3.fromRGB(92, 145, 78), false)
    local sill = makePart(bathroom, "WindowSill", Vector3.new(88, 2.2, 4), CFrame.new(0, 18.2, -110.5), Enum.Material.Marble, WHITE, true)

    for x = -28, 28, 28 do
        makePart(bathroom, "WindowVerticalFrame", Vector3.new(1.4, 30, 2), CFrame.new(x, 34, -111.7), Enum.Material.Metal, DARK, true)
    end
    makePart(bathroom, "WindowHorizontalFrame", Vector3.new(82, 1.4, 2), CFrame.new(0, 34, -111.7), Enum.Material.Metal, DARK, true)
    makePart(bathroom, "WindowTopFrame", Vector3.new(86, 2, 3), CFrame.new(0, 49, -111.5), Enum.Material.Metal, DARK, true)
    makePart(bathroom, "WindowBottomFrame", Vector3.new(86, 2, 3), CFrame.new(0, 19, -111.5), Enum.Material.Metal, DARK, true)
    windowView.Transparency = 0.25
    skyTop.Transparency = 0.35
    horizon.Transparency = 0.2
    sill.CanTouch = false

    -- Ceiling beams and recessed lights make the room feel architectural.
    for _, x in ipairs({-75, 0, 75}) do
        makePart(bathroom, "CeilingBeam", Vector3.new(3, 2, 218), CFrame.new(x, 53, 0), Enum.Material.Wood, WOOD, true)
        addLight(bathroom, Vector3.new(x, 51.5, -55), 1.8, 34)
        addLight(bathroom, Vector3.new(x, 51.5, 25), 1.5, 30)
    end

    -- More believable vanity, mirror and shower details.
    makePart(bathroom, "VanityCabinet", Vector3.new(32, 14, 13), CFrame.new(-92, 12, -43), Enum.Material.Wood, WOOD, true)
    makePart(bathroom, "VanityCounter", Vector3.new(36, 2.5, 16), CFrame.new(-92, 20, -43), Enum.Material.Marble, WHITE, true)
    local basin = makePart(bathroom, "Basin", Vector3.new(14, 2.5, 10), CFrame.new(-92, 21.5, -43), Enum.Material.SmoothPlastic, WHITE, false)
    basin.Shape = Enum.PartType.Cylinder
    makePart(bathroom, "Faucet", Vector3.new(1.8, 7, 1.8), CFrame.new(-92, 25, -43), Enum.Material.Metal, METAL, false).Shape = Enum.PartType.Cylinder
    local mirror = makePart(bathroom, "VanityMirror", Vector3.new(30, 20, 0.8), CFrame.new(-92, 38, -34.8), Enum.Material.Glass, GLASS, false)
    mirror.Transparency = 0.18

    makePart(bathroom, "ShowerBase", Vector3.new(42, 2, 48), CFrame.new(82, 5, -42), Enum.Material.Marble, WHITE, true)
    local showerWall = makePart(bathroom, "ShowerPanel", Vector3.new(1.5, 39, 52), CFrame.new(61, 24, -42), Enum.Material.Glass, GLASS, true)
    showerWall.Transparency = 0.52
    makePart(bathroom, "ShowerRail", Vector3.new(2, 2, 52), CFrame.new(61, 44, -42), Enum.Material.Metal, METAL, true)
    local head = makePart(bathroom, "ShowerHead", Vector3.new(7, 2, 7), CFrame.new(82, 45, -58), Enum.Material.Metal, METAL, false)
    head.Shape = Enum.PartType.Cylinder

    -- Towel rack, soap bottles and toilet paper add recognizable bathroom scale.
    makePart(bathroom, "TowelRack", Vector3.new(2, 2, 14), CFrame.new(-63, 27, -43), Enum.Material.Metal, METAL, true)
    makePart(bathroom, "Towel", Vector3.new(1, 10, 12), CFrame.new(-63, 21, -43), Enum.Material.Fabric, Color3.fromRGB(85, 145, 170), false)
    for i = 1, 4 do
        local bottle = makePart(bathroom, "SoapBottle", Vector3.new(2.2, 5, 2.2), CFrame.new(-68 + i * 5, 24, -73), Enum.Material.SmoothPlastic, (i % 2 == 0) and Color3.fromRGB(105, 190, 220) or Color3.fromRGB(245, 170, 95), false)
        bottle.Shape = Enum.PartType.Cylinder
    end
    local paper = makePart(bathroom, "PaperRoll", Vector3.new(3, 7, 7), CFrame.new(-101, 17, 22), Enum.Material.SmoothPlastic, WHITE, false)
    paper.Shape = Enum.PartType.Cylinder

    -- Upgrade all existing coins: large, round, metallic and reliable to touch.
    local coins = arena:FindFirstChild("Coins")
    if coins then
        for _, coin in ipairs(coins:GetChildren()) do
            makeCoinVisual(coin, coin.Name:match("^RareCoin") ~= nil)
        end
    end
end

return BathroomArchitecture
