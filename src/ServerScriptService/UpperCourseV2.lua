local UpperCourse = {}

local WHITE = Color3.fromRGB(245, 247, 250)
local PORCELAIN = Color3.fromRGB(232, 239, 244)
local BLUE = Color3.fromRGB(55, 170, 205)
local CYAN = Color3.fromRGB(75, 215, 235)
local GOLD = Color3.fromRGB(255, 205, 65)
local PINK = Color3.fromRGB(235, 105, 165)
local PURPLE = Color3.fromRGB(135, 90, 185)
local ORANGE = Color3.fromRGB(235, 145, 55)
local DARK = Color3.fromRGB(38, 43, 49)
local METAL = Color3.fromRGB(135, 145, 150)
local RED = Color3.fromRGB(220, 55, 55)
local GREEN = Color3.fromRGB(80, 175, 105)

local function part(parent, name, size, cf, material, color, collide)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame = name, size, cf
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or WHITE
    p.CanCollide = collide ~= false
    p.CanTouch = collide ~= false
    p.CanQuery = collide ~= false
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function cylinder(parent, name, diameter, height, cf, material, color, collide)
    return part(parent, name, Vector3.new(height, diameter, diameter), cf * CFrame.Angles(0, 0, math.rad(90)), material, color, collide, Enum.PartType.Cylinder)
end

local function hazard(p, motion, speed, distance)
    p:SetAttribute("Hazard", true)
    p:SetAttribute("Motion", motion)
    p:SetAttribute("Speed", speed)
    p:SetAttribute("Distance", distance or 0)
    return p
end

local function sign(parent, text, pos, width)
    local board = part(parent, "RouteSign", Vector3.new(width or 16, 5, 0.8), CFrame.new(pos), Enum.Material.Wood, DARK, false)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset((width or 16) * 18, 75)
    gui.StudsOffset = Vector3.new(0, 2.8, 0)
    gui.AlwaysOnTop = true
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = WHITE
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextStrokeTransparency = 0.25
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.Parent = gui
    return board
end

local function arrow(parent, pos, yaw)
    local a = part(parent, "RouteArrow", Vector3.new(2.2, 0.25, 5), CFrame.new(pos) * CFrame.Angles(0, yaw, 0), Enum.Material.SmoothPlastic, CYAN, false)
    a.Transparency = 0.12
end

local function straightFloor(parent, name, y, center, size)
    local floor = part(parent, name, size, CFrame.new(center.X, y, center.Z), Enum.Material.Marble, WHITE, true)
    floor:SetAttribute("UpperRoute", true)
    return floor
end

local function stairs(parent, fromPos, toPos, count)
    local dx, dy, dz = toPos.X-fromPos.X, toPos.Y-fromPos.Y, toPos.Z-fromPos.Z
    local horizontal = math.sqrt(dx*dx + dz*dz)
    count = count or math.max(8, math.ceil(horizontal/6))
    for i=1,count do
        local t=i/count
        local pos=Vector3.new(fromPos.X+dx*t, fromPos.Y+dy*t, fromPos.Z+dz*t)
        local yaw=math.atan2(dx,dz)
        local step=part(parent,"StairStep",Vector3.new(16,1.8,math.max(5,horizontal/count+1)),CFrame.new(pos)*CFrame.Angles(0,yaw,0),Enum.Material.Marble,WHITE,true)
        step:SetAttribute("UpperRoute",true)
        if i%4==1 then arrow(parent,pos+Vector3.new(0,1.05,0),yaw) end
    end
end

local function addMop(obstacles, pos, length, speed)
    cylinder(obstacles,"MopHub",4.5,4,CFrame.new(pos),Enum.Material.Metal,DARK,false)
    local bar=part(obstacles,"MopBar",Vector3.new(length,2.2,3),CFrame.new(pos),Enum.Material.Metal,PINK,true)
    hazard(bar,"ROTATE",speed,0)
    local head=part(obstacles,"MopHead",Vector3.new(10,3,5),bar.CFrame*CFrame.new(length/2-5,-2,0),Enum.Material.Fabric,WHITE,true)
    hazard(head,"ROTATE",speed,0)
end

local function addPlunger(obstacles,pos,speed)
    local cup=cylinder(obstacles,"PlungerCup",10,3,CFrame.new(pos),Enum.Material.SmoothPlastic,PURPLE,true)
    hazard(cup,"BOUNCE",speed,4)
    local handle=part(obstacles,"PlungerHandle",Vector3.new(2.2,12,2.2),CFrame.new(pos+Vector3.new(0,7,0)),Enum.Material.Metal,METAL,true)
    hazard(handle,"BOUNCE",speed,4)
end

function UpperCourse:Apply(arena)
    local old=arena:FindFirstChild("UpperCourse")
    if old then old:Destroy() end
    local course=Instance.new("Folder")
    course.Name="UpperCourse"
    course.Parent=arena
    local obstacles=arena:WaitForChild("Obstacles")

    -- New route: broad, readable floors connected by one clear zig-zag ascent.
    straightFloor(course,"Floor1",22,Vector3.new(-5,0,0),Vector3.new(104,2.4,54))
    straightFloor(course,"Floor2",40,Vector3.new(8,0,0),Vector3.new(88,2.4,48))
    straightFloor(course,"Floor3",58,Vector3.new(-4,0,0),Vector3.new(72,2.4,42))
    stairs(course,Vector3.new(-74,16,0),Vector3.new(-50,22,0),8)
    stairs(course,Vector3.new(-50,22,0),Vector3.new(45,40,0),20)
    stairs(course,Vector3.new(45,40,0),Vector3.new(-34,58,0),17)
    stairs(course,Vector3.new(-34,58,0),Vector3.new(0,72,-10),8)

    sign(course,"ЭТАЖ 1  •  СПОКОЙНАЯ ЗОНА",Vector3.new(-48,27,23),18)
    sign(course,"ЭТАЖ 2  •  ПРЕПЯТСТВИЯ",Vector3.new(43,45,-20),18)
    sign(course,"ЭТАЖ 3  •  ФИНИШ",Vector3.new(-32,63,16),18)

    -- Floor 1 intentionally has NO hazards. It is the safe onboarding/shop/NPC area.
    local shopZone=part(course,"ShopZone",Vector3.new(30,0.4,22),CFrame.new(-25,23.5,12),Enum.Material.SmoothPlastic,Color3.fromRGB(225,235,238),false)
    shopZone.Transparency=0.35
    sign(course,"SHOP  •  ROBUX",Vector3.new(-25,29,18),13)

    -- Only floors 2 and 3 get obstacles; fewer, larger hazards make the route readable.
    addMop(obstacles,Vector3.new(5,44,-9),30,0.7)
    addPlunger(obstacles,Vector3.new(28,44,12),1.0)
    addPlunger(obstacles,Vector3.new(-12,44,12),1.2)
    local paper=cylinder(obstacles,"PaperRollHazard",9,20,CFrame.new(8,43,17),Enum.Material.Fabric,WHITE,true)
    hazard(paper,"SWEEP",0.55,10)

    addMop(obstacles,Vector3.new(-4,62,2),30,0.85)
    local curtain=part(obstacles,"ShowerCurtainGate",Vector3.new(22,11,1.6),CFrame.new(20,64,-12),Enum.Material.Fabric,BLUE,true)
    hazard(curtain,"SWEEP",0.55,10)
    for _,z in ipairs({-8,8}) do
        local soap=part(obstacles,"SoapPad",Vector3.new(8,2,8),CFrame.new(-22,61,z),Enum.Material.SmoothPlastic,ORANGE,true)
        hazard(soap,"PULSE",1.15,2.5)
    end

    local top=Instance.new("Folder")
    top.Name="FlushThrone"
    top.Parent=course
    part(top,"FlushPedestal",Vector3.new(30,8,24),CFrame.new(0,72,-10),Enum.Material.Marble,WHITE,true)
    part(top,"FlushTank",Vector3.new(24,18,9),CFrame.new(0,82,-24),Enum.Material.SmoothPlastic,PORCELAIN,true)
    cylinder(top,"FlushButtonBase",11,2,CFrame.new(0,77,-10),Enum.Material.Metal,METAL,true)
    local button=cylinder(top,"TopFlushButton",7.5,3,CFrame.new(0,79,-10),Enum.Material.Neon,RED,true)
    button:SetAttribute("TopFlushButton",true)
    local prompt=Instance.new("ProximityPrompt")
    prompt.Name="FlushButtonPrompt"
    prompt.ActionText="СМЫТЬ ВСЕХ"
    prompt.ObjectText="КНОПКА СМЫВА"
    prompt.KeyboardKeyCode=Enum.KeyCode.E
    prompt.HoldDuration=0.35
    prompt.MaxActivationDistance=12
    prompt.RequiresLineOfSight=false
    prompt.Parent=button
    sign(course,"🚽 ФИНИШ  •  E = СМЫТЬ ВСЕХ",Vector3.new(0,99,-10),22)

    -- A few subtle route markers, no neon edge spam.
    for _,p in ipairs({Vector3.new(-64,24,0),Vector3.new(0,42,0),Vector3.new(0,60,0)}) do arrow(course,p,0) end

    arena:SetAttribute("UpperCourseReady",true)
    arena:SetAttribute("ThreeFloorsReady",true)
    return prompt
end

return UpperCourse