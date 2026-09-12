local UpperCourseBuilder = {}

local WHITE = Color3.fromRGB(248, 250, 252)
local PORCELAIN = Color3.fromRGB(235, 242, 246)
local BLUE = Color3.fromRGB(55, 205, 255)
local CYAN = Color3.fromRGB(80, 255, 255)
local GOLD = Color3.fromRGB(255, 213, 50)
local PINK = Color3.fromRGB(255, 105, 185)
local PURPLE = Color3.fromRGB(155, 90, 255)
local ORANGE = Color3.fromRGB(255, 150, 45)
local GREEN = Color3.fromRGB(95, 205, 115)
local DARK = Color3.fromRGB(30, 36, 44)
local METAL = Color3.fromRGB(145, 160, 170)
local RED = Color3.fromRGB(235, 55, 55)

local function part(parent, name, size, cf, material, color, collide, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or WHITE
    p.CanCollide = collide ~= false
    p.CanTouch = collide ~= false
    p.CanQuery = collide ~= false
    if shape then p.Shape = shape end
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function cylinder(parent, name, diameter, height, cf, material, color, collide)
    return part(parent, name, Vector3.new(diameter, height, diameter), cf, material, color, collide, Enum.PartType.Cylinder)
end

local function hazard(p, motion, speed, distance)
    p:SetAttribute("Hazard", true)
    p:SetAttribute("Motion", motion)
    p:SetAttribute("Speed", speed)
    p:SetAttribute("Distance", distance or 0)
    return p
end

local function billboard(parent, text, color, width, height, offset)
    local gui = Instance.new("BillboardGui")
    gui.Name = "Guide"
    gui.Size = UDim2.fromOffset(width, height)
    gui.StudsOffset = offset or Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 500
    gui.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeColor3 = DARK
    label.TextStrokeTransparency = 0.1
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.Parent = gui
    return gui
end

local function guideArrow(parent, position, size, rotation)
    local stem = part(parent, "RouteArrowStem", Vector3.new(size.X * 0.22, 0.45, size.Z * 0.72), CFrame.new(position) * CFrame.Angles(0, rotation or 0, 0), Enum.Material.Neon, CYAN, false)
    local tip = part(parent, "RouteArrowTip", Vector3.new(size.X, 0.45, size.Z * 0.35), CFrame.new(position + Vector3.new(0, 0, size.Z * 0.25)) * CFrame.Angles(0, rotation or 0, 0), Enum.Material.Neon, CYAN, false)
    tip.CFrame *= CFrame.Angles(math.rad(35), 0, 0)
    return stem, tip
end

local function floorSign(parent, floor, position, subtitle)
    local board = part(parent, "FloorSign" .. floor, Vector3.new(20, 7, 1.2), CFrame.new(position), Enum.Material.Marble, WHITE, false)
    billboard(board, ("⬆  ЭТАЖ %d\n%s"):format(floor, subtitle), BLUE, 310, 85, Vector3.new(0, 0, -1))
end

local function toiletPipe(parent, y0, y1, radius)
    -- Open porcelain shaft: it visually reads as climbing OUT of the toilet drain.
    local segments = 24
    for i = 1, segments do
        local a = (i / segments) * math.pi * 2
        local wall = part(
            parent,
            "PorcelainPipe",
            Vector3.new(3.8, y1 - y0, 12),
            CFrame.new(math.cos(a) * radius, (y0 + y1) / 2, math.sin(a) * radius) * CFrame.Angles(0, -a, 0),
            Enum.Material.Marble,
            PORCELAIN,
            true
        )
        wall.CanTouch = false
    end
end

local function ringFloor(parent, floor, y, radius, gapAngle)
    local segments = 28
    local segmentAngle = (math.pi * 2) / segments
    local arc = radius * segmentAngle * 0.92
    for i = 1, segments do
        local a = (i - 1) * segmentAngle
        local delta = math.abs(math.atan2(math.sin(a - gapAngle), math.cos(a - gapAngle)))
        if delta > 0.28 then
            local x, z = math.cos(a) * radius, math.sin(a) * radius
            local platform = part(
                parent,
                "Floor" .. floor .. "Platform",
                Vector3.new(arc, 2.4, 16),
                CFrame.new(x, y, z) * CFrame.Angles(0, -a + math.pi / 2, 0),
                Enum.Material.Marble,
                WHITE,
                true
            )
            platform:SetAttribute("UpperRoute", true)
        end
    end

    for i = 1, segments do
        local a = (i - 1) * segmentAngle
        local x, z = math.cos(a) * (radius + 8), math.sin(a) * (radius + 8)
        part(parent, "Floor" .. floor .. "NeonEdge", Vector3.new(2.5, 0.45, 8), CFrame.new(x, y + 1.35, z) * CFrame.Angles(0, -a + math.pi / 2, 0), Enum.Material.Neon, BLUE, false)
    end
end

local function stairRun(parent, fromY, toY, x, zStart, zEnd, side)
    local count = 12
    for i = 1, count do
        local t = i / count
        local y = fromY + (toY - fromY) * t
        local z = zStart + (zEnd - zStart) * t
        local step = part(parent, "UPStep", Vector3.new(18, 2.2, math.abs(zEnd - zStart) / count + 1.2), CFrame.new(x, y, z), Enum.Material.Marble, WHITE, true)
        step:SetAttribute("UpperRoute", true)
        if i % 3 == 1 then
            guideArrow(parent, Vector3.new(x, y + 1.2, z), Vector3.new(3, 0.5, 4), side == 1 and 0 or math.pi)
        end
    end
    for _, dx in ipairs({-10, 10}) do
        local rail = part(parent, "StairRail", Vector3.new(1.2, 5, math.abs(zEnd - zStart) + 4), CFrame.new(x + dx, (fromY + toY) / 2 + 2.5, (zStart + zEnd) / 2), Enum.Material.Metal, BLUE, true)
        rail.CanTouch = false
    end
end

local function addMop(obstacles, position, length, speed)
    cylinder(obstacles, "MopHub", 5, 5, CFrame.new(position), Enum.Material.Metal, DARK, false)
    local bar = part(obstacles, "MopBar", Vector3.new(length, 2.4, 3.4), CFrame.new(position), Enum.Material.Metal, PINK, true)
    hazard(bar, "ROTATE", speed, 0)
    local head = part(obstacles, "MopHead", Vector3.new(12, 3, 6), bar.CFrame * CFrame.new(length / 2 - 6, -2, 0), Enum.Material.Fabric, WHITE, true)
    hazard(head, "ROTATE", speed, 0)
end

local function addPaper(obstacles, position, rotation)
    local roll = cylinder(obstacles, "PaperRoll", 9, 26, CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Fabric, WHITE, true)
    roll.CFrame *= CFrame.Angles(0, rotation or 0, 0)
    hazard(roll, "SWEEP", 0.65, 12)
end

function UpperCourseBuilder:Apply(arena)
    local old = arena:FindFirstChild("UpperCourse")
    if old then old:Destroy() end

    local course = Instance.new("Folder")
    course.Name = "UpperCourse"
    course.Parent = arena

    local obstacles = arena:WaitForChild("Obstacles")

    -- The central porcelain shaft is the main visual idea: you climb out of the toilet hole.
    toiletPipe(course, 13, 69, 17)

    -- Three circular floors with one obvious staircase at each transition.
    ringFloor(course, 1, 22, 62, math.rad(180))
    ringFloor(course, 2, 40, 52, math.rad(0))
    ringFloor(course, 3, 58, 42, math.rad(180))

    stairRun(course, 14, 22, 0, 70, 55, 1)
    stairRun(course, 22, 40, 0, -55, -35, -1)
    stairRun(course, 40, 58, 0, 35, 18, 1)

    floorSign(course, 1, Vector3.new(-78, 26, 55), "ИЗ ЧАШИ")
    floorSign(course, 2, Vector3.new(68, 44, -38), "ВАННАЯ")
    floorSign(course, 3, Vector3.new(-58, 62, 20), "КРЫША")

    billboard(course, "⬆  СЮДА  •  НЕ ЗАБЛУДИСЬ  •  ⬆", GOLD, 520, 65, Vector3.new(0, 70, 0))

    -- Floor 1: brushes, paper and soap. Hazards only block or push.
    addMop(obstacles, Vector3.new(45, 25, 35), 34, 0.75)
    addPaper(obstacles, Vector3.new(-40, 27, 45), 0)
    for i, x in ipairs({-26, 0, 26}) do
        local soap = part(obstacles, "SoapPad1", Vector3.new(9, 2.2, 9), CFrame.new(x, 24, 58), Enum.Material.SmoothPlastic, i % 2 == 0 and BLUE or PINK, true)
        hazard(soap, "PULSE", 1 + i * 0.15, 3)
    end

    -- Floor 2: toilet-paper rollers and giant plungers.
    addPaper(obstacles, Vector3.new(34, 43, -18), 0.5)
    addPaper(obstacles, Vector3.new(-34, 43, -42), 1.0)
    for i, x in ipairs({-25, 25}) do
        local plunger = cylinder(obstacles, "Plunger", 12, 3, CFrame.new(x, 43, -8), Enum.Material.SmoothPlastic, PURPLE, true)
        hazard(plunger, "BOUNCE", 1.1 + i * 0.2, 4)
        local handle = part(obstacles, "PlungerHandle", Vector3.new(2.4, 12, 2.4), CFrame.new(x, 49, -8), Enum.Material.Metal, METAL, true)
        hazard(handle, "BOUNCE", 1.1 + i * 0.2, 4)
    end

    -- Floor 3: final bathroom gauntlet before the flush throne.
    addMop(obstacles, Vector3.new(0, 61, -30), 38, 0.95)
    local curtain = part(obstacles, "ShowerCurtainGate", Vector3.new(30, 12, 1.8), CFrame.new(25, 64, 12), Enum.Material.Fabric, BLUE, true)
    hazard(curtain, "SWEEP", 0.6, 15)
    for i, z in ipairs({-12, 4, 20}) do
        local soap = part(obstacles, "SoapPad3", Vector3.new(8, 2.2, 8), CFrame.new(-20, 61, z), Enum.Material.SmoothPlastic, ORANGE, true)
        hazard(soap, "PULSE", 1.3 + i * 0.1, 2.5)
    end

    -- Huge arrows and labels make the intended direction visible from below.
    for _, data in ipairs({
        {Vector3.new(0, 17, 64), "⬆  ЭТАЖ 1"},
        {Vector3.new(0, 35, -50), "⬆  ЭТАЖ 2"},
        {Vector3.new(0, 53, 30), "⬆  ЭТАЖ 3"},
        {Vector3.new(0, 71, -4), "⬆  КНОПКА СМЫВА"},
    }) do
        local marker = part(course, "RouteMarker", Vector3.new(8, 0.6, 8), CFrame.new(data[1]), Enum.Material.Neon, CYAN, false)
        billboard(marker, data[2], WHITE, 330, 58, Vector3.new(0, 3, 0))
    end

    -- Top = toilet-tank throne. The player presses E to flush the round immediately.
    local top = Instance.new("Folder")
    top.Name = "FlushThrone"
    top.Parent = course

    part(top, "FlushPedestal", Vector3.new(34, 8, 26), CFrame.new(0, 72, -12), Enum.Material.Marble, WHITE, true)
    part(top, "FlushTank", Vector3.new(28, 20, 10), CFrame.new(0, 82, -26), Enum.Material.SmoothPlastic, PORCELAIN, true)
    part(top, "FlushTankTop", Vector3.new(32, 3, 14), CFrame.new(0, 93, -26), Enum.Material.Marble, WHITE, true)
    cylinder(top, "FlushButtonBase", 12, 2, CFrame.new(0, 77, -12), Enum.Material.Metal, METAL, true)
    local button = cylinder(top, "TopFlushButton", 8, 3, CFrame.new(0, 79, -12), Enum.Material.Neon, RED, true)
    button:SetAttribute("TopFlushButton", true)
    billboard(button, "FLUSH ALL", WHITE, 300, 65, Vector3.new(0, 4, 0))

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "FlushButtonPrompt"
    prompt.ActionText = "СМЫТЬ ВСЕХ"
    prompt.ObjectText = "КНОПКА СМЫВА"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = button

    billboard(top, "🚽  ТЫ ДОБРАЛСЯ ДО ВЕРХА!  🚽\nНАЖМИ E И СМЫВАЙ", GOLD, 520, 100, Vector3.new(0, 99, -15))

    -- Small props reinforce the bathroom theme without blocking the route.
    for _, data in ipairs({
        {Vector3.new(74, 23, 20), GREEN},
        {Vector3.new(-74, 41, -12), PINK},
        {Vector3.new(54, 59, 34), ORANGE},
    }) do
        local pot = cylinder(course, "DecorPlantPot", 7, 5, CFrame.new(data[1]), Enum.Material.SmoothPlastic, DARK, false)
        for j = 1, 5 do
            part(course, "DecorLeaf", Vector3.new(2, 8, 2), CFrame.new(data[1] + Vector3.new(math.cos(j) * 2, 6 + (j % 2), math.sin(j) * 2)), Enum.Material.Grass, data[2], false)
        end
    end

    arena:SetAttribute("UpperCourseReady", true)
    arena:SetAttribute("ThreeFloorsReady", true)
    return prompt
end

return UpperCourseBuilder
