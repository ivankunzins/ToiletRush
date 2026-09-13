local UpperCourse = {}

local WHITE = Color3.fromRGB(245,247,250)
local TILE = Color3.fromRGB(218,226,230)
local DARK = Color3.fromRGB(42,48,52)
local METAL = Color3.fromRGB(120,130,136)
local BLUE = Color3.fromRGB(55,155,205)
local CYAN = Color3.fromRGB(80,190,215)
local GOLD = Color3.fromRGB(245,190,55)
local ORANGE = Color3.fromRGB(232,125,45)
local RED = Color3.fromRGB(210,55,55)
local PURPLE = Color3.fromRGB(128,82,175)
local PINK = Color3.fromRGB(225,100,155)

local function makePart(parent, name, size, cf, material, color, collide)
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
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function makeCylinder(parent, name, diameter, height, cf, material, color, collide)
    local p = makePart(parent, name, Vector3.new(height, diameter, diameter), cf * CFrame.Angles(0, 0, math.rad(90)), material, color, collide)
    p.Shape = Enum.PartType.Cylinder
    return p
end

local function point(radius, angle, y)
    return Vector3.new(math.cos(angle) * radius, y, math.sin(angle) * radius)
end

local function sign(parent, text, pos, width)
    local board = makePart(parent, "FloorSign", Vector3.new(width, 4.5, 0.7), CFrame.new(pos), Enum.Material.Wood, DARK, false)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(width * 17, 68)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = WHITE
    label.TextStrokeTransparency = 0.2
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.Parent = gui
end

local function ring(parent, name, y, innerRadius, outerRadius, segments)
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
    local mid = (innerRadius + outerRadius) / 2
    local radialDepth = outerRadius - innerRadius
    local arcWidth = math.max(7, mid * ((math.pi * 2 / segments) * 0.9))
    for i = 1, segments do
        local angle = (i - 1) * math.pi * 2 / segments
        local cf = CFrame.new(point(mid, angle, y)) * CFrame.Angles(0, -angle, 0)
        local tile = makePart(folder, "RingSegment", Vector3.new(radialDepth, 2.5, arcWidth), cf, Enum.Material.Marble, i % 2 == 0 and Color3.fromRGB(224,231,234) or TILE, true)
        tile:SetAttribute("UpperRoute", true)
    end
    return folder
end

local function rail(parent, y, radius, segments)
    local folder = Instance.new("Folder")
    folder.Name = "SafetyRail"
    folder.Parent = parent
    for i = 1, segments do
        local angle = (i - 1) * math.pi * 2 / segments
        makePart(folder, "RailPost", Vector3.new(1.1, 6.4, 1.1), CFrame.new(point(radius, angle, y + 3.2)), Enum.Material.Metal, METAL, true)
    end
    for i = 1, segments do
        local angle = (i - 0.5) * math.pi * 2 / segments
        local cf = CFrame.new(point(radius, angle, y + 5.4)) * CFrame.Angles(0, -angle, 0)
        makePart(folder, "RailBar", Vector3.new(1, 1, math.max(8, radius * math.pi * 2 / segments)), cf, Enum.Material.Metal, METAL, true)
    end
end

local function stairs(parent, fromPos, toPos, count)
    local delta = toPos - fromPos
    local horizontal = math.sqrt(delta.X * delta.X + delta.Z * delta.Z)
    count = count or math.max(8, math.ceil(horizontal / 5))
    local yaw = math.atan2(delta.X, delta.Z)
    for i = 1, count do
        local t = i / count
        local pos = fromPos + delta * t
        local step = makePart(parent, "CircularStair", Vector3.new(13, 1.7, math.max(4.5, horizontal / count + 1)), CFrame.new(pos) * CFrame.Angles(0, yaw, 0), Enum.Material.Marble, WHITE, true)
        step:SetAttribute("UpperRoute", true)
    end
end

local function hazard(part, motion, speed, distance)
    part:SetAttribute("Hazard", true)
    part:SetAttribute("Motion", motion)
    part:SetAttribute("Speed", speed)
    part:SetAttribute("Distance", distance or 0)
    return part
end

local function floorLamp(parent, y, radius, lightColor)
    for i = 1, 8 do
        local angle = (i - 1) * math.pi / 4 + math.rad(22)
        local lamp = makePart(parent, "WallLamp", Vector3.new(2.2, 4.2, 1.2), CFrame.new(point(radius - 2, angle, y + 5)), Enum.Material.Metal, METAL, false)
        local light = Instance.new("PointLight")
        light.Brightness = 0.8
        light.Range = 12
        light.Color = lightColor
        light.Parent = lamp
    end
end

local function mop(obstacles, pos, length, speed, color)
    makeCylinder(obstacles, "MopHub", 4.2, 3.5, CFrame.new(pos), Enum.Material.Metal, DARK, false)
    local bar = makePart(obstacles, "MopBar", Vector3.new(length, 2.2, 3), CFrame.new(pos), Enum.Material.Metal, color or PINK, true)
    hazard(bar, "ROTATE", speed, 0)
    local head = makePart(obstacles, "MopHead", Vector3.new(10, 3.2, 5), bar.CFrame * CFrame.new(length / 2 - 5, -2, 0), Enum.Material.Fabric, WHITE, true)
    hazard(head, "ROTATE", speed, 0)
end

local function plunger(obstacles, pos, speed)
    local cup = makeCylinder(obstacles, "PlungerCup", 10, 3, CFrame.new(pos), Enum.Material.SmoothPlastic, PURPLE, true)
    hazard(cup, "BOUNCE", speed, 4)
    local handle = makePart(obstacles, "PlungerHandle", Vector3.new(2.1, 12, 2.1), CFrame.new(pos + Vector3.new(0, 7, 0)), Enum.Material.Metal, METAL, true)
    hazard(handle, "BOUNCE", speed, 4)
end

local function wetTile(obstacles, pos, size)
    local p = makePart(obstacles, "WetFloor", size, CFrame.new(pos), Enum.Material.Glass, BLUE, true)
    p.Transparency = 0.25
    hazard(p, "PULSE", 1.15, 2.5)
end

function UpperCourse:Apply(arena)
    local old = arena:FindFirstChild("UpperCourse")
    if old then old:Destroy() end

    local course = Instance.new("Folder")
    course.Name = "UpperCourse"
    course.Parent = arena

    local obstacles = arena:WaitForChild("Obstacles")

    -- FIVE COMPLETE FLOORS. The center remains open for the boss.
    local floors = {
        {1, 22, 88, Color3.fromRGB(190,225,240)},
        {2, 40, 82, Color3.fromRGB(120,205,225)},
        {3, 58, 76, Color3.fromRGB(235,190,125)},
        {4, 76, 70, Color3.fromRGB(170,150,205)},
        {5, 94, 64, Color3.fromRGB(245,205,95)},
    }

    for _, data in ipairs(floors) do
        local n, y, radius, lightColor = data[1], data[2], data[3], data[4]
        ring(course, "Floor" .. n, y, 48, radius, 24)
        rail(course, y, radius - 0.8, 24)
        floorLamp(course, y, radius, lightColor)
    end

    -- FLOOR 1: entrance and shop area.
    sign(course, "ЭТАЖ 1  •  ВХОД  •  МАГАЗИН", Vector3.new(-63, 29, 0), 18)
    sign(course, "ПОДЪЁМ НА 2 ЭТАЖ", Vector3.new(0, 28, 64), 15)
    makePart(course, "WelcomeRug", Vector3.new(28, 0.35, 12), CFrame.new(-58, 23.35, 0), Enum.Material.Fabric, Color3.fromRGB(70,90,100), false)
    for x = -68, -48, 10 do
        makePart(course, "Sink", Vector3.new(7,4,5), CFrame.new(x,26,-25), Enum.Material.Marble, WHITE, true)
        makeCylinder(course, "SinkBowl", 4, 1, CFrame.new(x,28,-28), Enum.Material.SmoothPlastic, BLUE, true)
        makePart(course, "Faucet", Vector3.new(1,4,1), CFrame.new(x,30,-25), Enum.Material.Metal, METAL, true)
        makePart(course, "Mirror", Vector3.new(8,6,0.25), CFrame.new(x,29,-31), Enum.Material.Glass, Color3.fromRGB(185,215,225), false).Reflectance = 0.25
    end

    -- FLOOR 2: wet zone.
    sign(course, "ЭТАЖ 2  •  МОКРАЯ ЗОНА", Vector3.new(-60,47,0), 18)
    wetTile(obstacles, Vector3.new(-25,43,58), Vector3.new(12,2,10))
    wetTile(obstacles, Vector3.new(8,43,-58), Vector3.new(12,2,10))
    mop(obstacles, Vector3.new(-10,44,56), 28, 0.72, BLUE)
    plunger(obstacles, Vector3.new(26,44,48), 1.0)

    -- FLOOR 3: cleaning.
    sign(course, "ЭТАЖ 3  •  УБОРКА", Vector3.new(52,65,0), 18)
    mop(obstacles, Vector3.new(0,62,62), 30, 0.9, PINK)
    plunger(obstacles, Vector3.new(-35,62,42), 1.25)
    local paper = makeCylinder(obstacles, "PaperRollHazard", 9, 9, CFrame.new(25,64,-38), Enum.Material.Fabric, WHITE, true)
    hazard(paper, "SWEEP", 0.6, 12)
    for _, angle in ipairs({math.rad(205), math.rad(245), math.rad(285)}) do
        makePart(course, "LaundryBasket", Vector3.new(5,6,5), CFrame.new(point(61, angle, 61)), Enum.Material.Plastic, BLUE, true)
    end

    -- FLOOR 4: plumbing.
    sign(course, "ЭТАЖ 4  •  САНТЕХНИКА", Vector3.new(-48,83,0), 18)
    for _, angle in ipairs({math.rad(20), math.rad(140), math.rad(260)}) do
        local pipe = makePart(obstacles, "PipeGate", Vector3.new(5,5,18), CFrame.new(point(55, angle, 81)) * CFrame.Angles(0,-angle,math.rad(90)), Enum.Material.Metal, METAL, true)
        hazard(pipe, "ROTATE", 0.75, 0)
    end
    mop(obstacles, Vector3.new(-15,80,48), 26, 1.0, PURPLE)
    makeCylinder(course, "Valve", 10, 2, CFrame.new(0,81,54), Enum.Material.Metal, RED, true)
    makePart(course, "ValveWheel", Vector3.new(1,8,8), CFrame.new(0,81,54) * CFrame.Angles(0,math.rad(90),0), Enum.Material.Metal, GOLD, true).Shape = Enum.PartType.Cylinder

    -- FLOOR 5: final ascent and boss control.
    sign(course, "ЭТАЖ 5  •  ВЕРШИНА", Vector3.new(42,101,0), 18)
    mop(obstacles, Vector3.new(0,98,50), 24, 1.1, ORANGE)
    local gate1 = makePart(obstacles, "FinalGateA", Vector3.new(18,9,2), CFrame.new(-35,99,28), Enum.Material.Metal, ORANGE, true)
    hazard(gate1, "SWEEP", 0.65, 16)
    local gate2 = makePart(obstacles, "FinalGateB", Vector3.new(18,9,2), CFrame.new(35,99,-28), Enum.Material.Metal, RED, true)
    hazard(gate2, "SWEEP", 0.7, 16)

    -- CONNECTING STAIRS BETWEEN ALL FIVE LEVELS.
    stairs(course, Vector3.new(-78,17,0), Vector3.new(-67,22,38), 10)
    stairs(course, Vector3.new(55,35,55), Vector3.new(57,40,-28), 12)
    stairs(course, Vector3.new(-52,53,-40), Vector3.new(45,58,-48), 13)
    stairs(course, Vector3.new(43,71,34), Vector3.new(-28,76,48), 13)
    stairs(course, Vector3.new(-44,89,-32), Vector3.new(0,94,-60), 10)

    -- TOP BOSS CONTROL.
    local throne = Instance.new("Folder")
    throne.Name = "FlushThrone"
    throne.Parent = course
    makePart(throne, "FinishPlatform", Vector3.new(28,5,22), CFrame.new(0,97,-60), Enum.Material.Marble, WHITE, true)
    makePart(throne, "FinishPedestal", Vector3.new(16,7,13), CFrame.new(0,103,-60), Enum.Material.Marble, WHITE, true)
    makePart(throne, "FlushTank", Vector3.new(18,14,7), CFrame.new(0,111,-72), Enum.Material.SmoothPlastic, WHITE, true)
    makeCylinder(throne, "FlushButtonBase", 10, 2, CFrame.new(0,107,-60), Enum.Material.Metal, METAL, true)
    local button = makeCylinder(throne, "TopFlushButton", 7.5, 3, CFrame.new(0,109,-60), Enum.Material.Neon, RED, true)
    button:SetAttribute("TopFlushButton", true)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "FlushButtonPrompt"
    prompt.ActionText = "СМЫТЬ БОССА"
    prompt.ObjectText = "АВАРИЙНЫЙ СМЫВ"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = button
    sign(course, "🚽 ФИНАЛ  •  E = СМЫТЬ БОССА", Vector3.new(0,119,-60), 22)

    arena:SetAttribute("BossFlushPosition", Vector3.new(0,109,-60))
    arena:SetAttribute("UpperCourseReady", true)
    arena:SetAttribute("FiveFloorsReady", true)
    arena:SetAttribute("ThreeFloorsReady", true)

    return prompt
end

return UpperCourse
