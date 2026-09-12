local UpperCourseBuilder = {}

local WHITE = Color3.fromRGB(245, 248, 250)
local BLUE = Color3.fromRGB(45, 185, 255)
local PINK = Color3.fromRGB(255, 115, 190)
local ORANGE = Color3.fromRGB(255, 155, 45)
local PURPLE = Color3.fromRGB(160, 95, 255)
local DARK = Color3.fromRGB(35, 40, 45)
local METAL = Color3.fromRGB(150, 160, 168)

local function part(parent, name, size, cf, material, color, collide)
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

local function hazard(p, motion, speed, distance)
    p:SetAttribute("Hazard", true)
    p:SetAttribute("Motion", motion)
    p:SetAttribute("Speed", speed)
    p:SetAttribute("Distance", distance)
    return p
end

local function sign(parent, text, position, color)
    local board = part(parent, "CourseSign", Vector3.new(22, 7, 1), CFrame.new(position), Enum.Material.SmoothPlastic, DARK, false)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(300, 70)
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0, 0, -0.8)
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.2
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.Parent = gui
end

function UpperCourseBuilder:Apply(arena)
    local old = arena:FindFirstChild("UpperCourse")
    if old then old:Destroy() end

    local course = Instance.new("Folder")
    course.Name = "UpperCourse"
    course.Parent = arena

    local obstacles = arena:WaitForChild("Obstacles")

    -- Two wide staircases make the upper route readable and actually reachable.
    for side, x in ipairs({-48, 48}) do
        local direction = side == 1 and 1 or -1
        for step = 1, 8 do
            local z = direction * (94 - step * 5.2)
            local y = 14 + step * 1.55
            local stair = part(course, "UpperStep", Vector3.new(25, 2.2, 7), CFrame.new(x, y, z), Enum.Material.Marble, WHITE, true)
            stair.CFrame *= CFrame.Angles(0, 0, math.rad(direction * 3))
        end
    end

    -- Elevated porcelain walkways form a second layer above the bowl.
    local platforms = {
        {Vector3.new(-50, 27, -45), Vector3.new(48, 2, 20), 0},
        {Vector3.new(50, 31, -5), Vector3.new(44, 2, 20), math.rad(90)},
        {Vector3.new(-20, 35, 50), Vector3.new(55, 2, 20), 0},
    }
    for i, data in ipairs(platforms) do
        local p = part(course, "UpperPlatform" .. i, data[2], CFrame.new(data[1]) * CFrame.Angles(0, data[3], 0), Enum.Material.Marble, WHITE, true)
        p:SetAttribute("UpperRoute", true)
        local rim = part(course, "UpperRail" .. i, Vector3.new(data[2].X, 2.2, 1.4), p.CFrame * CFrame.new(0, 3, -data[2].Z / 2), Enum.Material.Metal, BLUE, true)
        rim.CanTouch = false
    end

    -- Rotating mop bars: they block lanes and gently push players back.
    for i, position in ipairs({Vector3.new(-30, 25, -28), Vector3.new(35, 31, 20), Vector3.new(-30, 35, 62)}) do
        local hub = part(obstacles, "MopHub" .. i, Vector3.new(5, 5, 5), CFrame.new(position), Enum.Material.Metal, DARK, false)
        local bar = part(obstacles, "MopBar" .. i, Vector3.new(34, 2.5, 3.5), CFrame.new(position), Enum.Material.Metal, PINK, true)
        hazard(bar, "ROTATE", 0.65 + i * 0.13, 0)
        bar.CFrame *= CFrame.Angles(0, i * 0.8, 0)
        local bristles = part(obstacles, "MopBristles" .. i, Vector3.new(13, 3.5, 5), bar.CFrame * CFrame.new(9, -2, 0), Enum.Material.Fabric, PINK, true)
        bristles:SetAttribute("Hazard", true)
    end

    -- Giant swinging plunger gates.
    for i, position in ipairs({Vector3.new(55, 37, 48), Vector3.new(-62, 29, 15)}) do
        local pole = part(obstacles, "PlungerPole" .. i, Vector3.new(2.5, 18, 2.5), CFrame.new(position + Vector3.new(0, 9, 0)), Enum.Material.Metal, METAL, true)
        pole.CanTouch = false
        local plunger = part(obstacles, "Plunger" .. i, Vector3.new(10, 3, 10), CFrame.new(position), Enum.Material.SmoothPlastic, PURPLE, true)
        hazard(plunger, "BOUNCE", 1.0 + i * 0.25, 4)
        local handle = part(obstacles, "PlungerHandle" .. i, Vector3.new(2, 12, 2), CFrame.new(position + Vector3.new(0, 7, 0)), Enum.Material.Metal, METAL, true)
        hazard(handle, "BOUNCE", 1.0 + i * 0.25, 4)
    end

    -- Rolling toilet-paper bars cross the upper lanes.
    for i, position in ipairs({Vector3.new(0, 39, -55), Vector3.new(72, 33, -32), Vector3.new(-72, 38, 48)}) do
        local roller = part(obstacles, "PaperRoller" .. i, Vector3.new(8, 8, 30), CFrame.new(position), Enum.Material.Fabric, WHITE, true)
        hazard(roller, "SWEEP", 0.75 + i * 0.1, 13)
        local axle = part(obstacles, "PaperAxle" .. i, Vector3.new(34, 2, 2), CFrame.new(position), Enum.Material.Metal, METAL, true)
        axle.CanTouch = false
    end

    -- Soap launch pads bounce harmlessly and change the player's route.
    for i, position in ipairs({Vector3.new(8, 30, -35), Vector3.new(-5, 38, 58), Vector3.new(62, 35, 5), Vector3.new(-65, 32, -30)}) do
        local soap = part(obstacles, "SoapPad" .. i, Vector3.new(10, 2.5, 10), CFrame.new(position), Enum.Material.SmoothPlastic, (i % 2 == 0) and BLUE or PINK, true)
        hazard(soap, "PULSE", 1.2 + i * 0.12, 2.5)
    end

    -- A final narrow gate gives the upper route a funny bathroom-game finish.
    local gate = part(obstacles, "ShowerCurtainGate", Vector3.new(42, 14, 1.5), CFrame.new(0, 29, 82), Enum.Material.Fabric, BLUE, true)
    hazard(gate, "SWEEP", 0.55, 18)
    sign(course, "⬆  UPPER BATHROOM RUN", Vector3.new(0, 46, 100), Color3.fromRGB(255, 225, 80))

    arena:SetAttribute("UpperCourseReady", true)
end

return UpperCourseBuilder
