local UpperCourse={}

local WHITE=Color3.fromRGB(245,247,250)
local TILE=Color3.fromRGB(218,226,230)
local DARK=Color3.fromRGB(42,48,52)
local METAL=Color3.fromRGB(120,130,136)
local BLUE=Color3.fromRGB(55,155,205)
local CYAN=Color3.fromRGB(80,190,215)
local GOLD=Color3.fromRGB(245,190,55)
local ORANGE=Color3.fromRGB(232,125,45)
local RED=Color3.fromRGB(210,55,55)
local PURPLE=Color3.fromRGB(128,82,175)
local GREEN=Color3.fromRGB(75,160,105)
local PINK=Color3.fromRGB(225,100,155)
local BROWN=Color3.fromRGB(108,78,58)

local function part(parent,name,size,cf,material,color,collide)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
    p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or WHITE
    p.CanCollide=collide~=false;p.CanTouch=collide~=false;p.CanQuery=collide~=false
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
    return p
end

local function cylinder(parent,name,diameter,height,cf,material,color,collide)
    local p=part(parent,name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),material,color,collide)
    p.Shape=Enum.PartType.Cylinder
    return p
end

local function label(parent,text,pos,width)
    local board=part(parent,"FloorSign",Vector3.new(width,4.5,.7),CFrame.new(pos),Enum.Material.Wood,DARK,false)
    local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(width*17,68);gui.StudsOffset=Vector3.new(0,3,0);gui.AlwaysOnTop=true;gui.Parent=board
    local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=WHITE;t.TextStrokeTransparency=.2;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=gui
end

local function radialPoint(radius,angle,y)
    return Vector3.new(math.cos(angle)*radius,y,math.sin(angle)*radius)
end

-- Build a true open-center circular floor from wedge-like rectangular segments.
local function ring(parent,name,y,inner,outer,segments)
    local folder=Instance.new("Folder");folder.Name=name;folder.Parent=parent
    local mid=(inner+outer)/2;local depth=outer-inner
    for i=1,segments do
        local a=(i-1)*(math.pi*2/segments);local da=(math.pi*2/segments)*.94
        local p=radialPoint(mid,a,y)
        local s=part(folder,"RingSegment",Vector3.new(depth,2.5,math.max(7,mid*da)),Enum.Material.Marble,TILE,true)
        s.CFrame=CFrame.new(p)*CFrame.Angles(0,-a,0)
        s:SetAttribute("UpperRoute",true)
        -- Subtle dark grout at alternating seams.
        if i%2==0 then s.Color=Color3.fromRGB(224,231,234) end
    end
    return folder
end

local function railing(parent,y,radius,segments)
    local folder=Instance.new("Folder");folder.Name="SafetyRail";folder.Parent=parent
    for i=1,segments do
        local a=(i-1)*(math.pi*2/segments)
        local p=radialPoint(radius,a,y+3.2)
        local post=part(folder,"RailPost",Vector3.new(1.1,6.4,1.1),CFrame.new(p),Enum.Material.Metal,METAL,true)
        post:SetAttribute("UpperRoute",true)
    end
    for i=1,segments do
        local a=(i-.5)*(math.pi*2/segments);local p=radialPoint(radius,a,y+5.4)
        local bar=part(folder,"RailBar",Vector3.new(1,1,math.max(8,radius*(math.pi*2/segments))),CFrame.new(p)*CFrame.Angles(0,-a,0),Enum.Material.Metal,METAL,true)
        bar:SetAttribute("UpperRoute",true)
    end
end

local function stairs(parent,fromPos,toPos,count)
    local dx,dy,dz=toPos.X-fromPos.X,toPos.Y-fromPos.Y,toPos.Z-fromPos.Z
    local horizontal=math.sqrt(dx*dx+dz*dz);count=count or math.max(8,math.ceil(horizontal/5))
    for i=1,count do
        local t=i/count;local pos=Vector3.new(fromPos.X+dx*t,fromPos.Y+dy*t,fromPos.Z+dz*t)
        local yaw=math.atan2(dx,dz)
        local step=part(parent,"CircularStair",Vector3.new(13,1.7,math.max(4.5,horizontal/count+1)),CFrame.new(pos)*CFrame.Angles(0,yaw,0),Enum.Material.Marble,WHITE,true)
        step:SetAttribute("UpperRoute",true)
        if i%4==0 then
            local a=part(parent,"StairMarker",Vector3.new(2.5,.18,3.5),CFrame.new(pos+Vector3.new(0,1,0))*CFrame.Angles(0,yaw,0),Enum.Material.SmoothPlastic,CYAN,false);a.Transparency=.18
        end
    end
end

local function hazard(p,motion,speed,distance)
    p:SetAttribute("Hazard",true);p:SetAttribute("Motion",motion);p:SetAttribute("Speed",speed);p:SetAttribute("Distance",distance or 0);return p
end

local function mop(obstacles,pos,length,speed,color)
    cylinder(obstacles,"MopHub",4.2,3.5,CFrame.new(pos),Enum.Material.Metal,DARK,false)
    local bar=part(obstacles,"MopBar",Vector3.new(length,2.2,3),CFrame.new(pos),Enum.Material.Metal,color or PINK,true);hazard(bar,"ROTATE",speed,0)
    local head=part(obstacles,"MopHead",Vector3.new(10,3.2,5),bar.CFrame*CFrame.new(length/2-5,-2,0),Enum.Material.Fabric,WHITE,true);hazard(head,"ROTATE",speed,0)
end

local function plunger(obstacles,pos,speed)
    local cup=cylinder(obstacles,"PlungerCup",10,3,CFrame.new(pos),Enum.Material.SmoothPlastic,PURPLE,true);hazard(cup,"BOUNCE",speed,4)
    local handle=part(obstacles,"PlungerHandle",Vector3.new(2.1,12,2.1),CFrame.new(pos+Vector3.new(0,7,0)),Enum.Material.Metal,METAL,true);hazard(handle,"BOUNCE",speed,4)
end

local function wetTile(obstacles,pos,size)
    local p=part(obstacles,"WetFloor",size,CFrame.new(pos),Enum.Material.Glass,BLUE,true);p.Transparency=.25;hazard(p,"PULSE",1.15,2.5)
end

local function floorDecor(parent,y,radius,theme)
    -- Lamps around the outer wall give each ring a finished architectural edge.
    for i=1,8 do
        local a=(i-1)*math.pi/4+math.rad(22)
        local p=radialPoint(radius-2,a,y+5)
        local lamp=part(parent,"WallLamp",Vector3.new(2.2,4.2,1.2),CFrame.new(p)*CFrame.Angles(0,-a,0),Enum.Material.Metal,METAL,false)
        local light=Instance.new("PointLight");light.Brightness=.8;light.Range=12;light.Color=theme;light.Parent=lamp
    end
end

function UpperCourse:Apply(arena)
    local old=arena:FindFirstChild("UpperCourse");if old then old:Destroy()end
    local course=Instance.new("Folder");course.Name="UpperCourse";course.Parent=arena
    local obstacles=arena:WaitForChild("Obstacles")

    -- Five open-center circular floors. The center remains completely open for the boss.
    local floors={{1,22,88},{2,40,82},{3,58,76},{4,76,70},{5,94,64}}
    for _,d in ipairs(floors) do
        local n,y,r=table.unpack(d)
        ring(course,"Floor"..n,y,48,r,24)
        railing(course,y,r-.8,24)
    end

    -- Floor 1: polished, calm onboarding area with shop frontage and bathroom details.
    floorDecor(course,22,88,Color3.fromRGB(190,225,240))
    label(course,"ЭТАЖ 1  •  ВХОД  •  МАГАЗИН",Vector3.new(-63,29,0),18)
    label(course,"ПОДЪЁМ НА 2 ЭТАЖ",Vector3.new(0,28,64),15)
    local rug=part(course,"WelcomeRug",Vector3.new(28,.35,12),CFrame.new(-58,23.35,0),Enum.Material.Fabric,Color3.fromRGB(70,90,100),false)
    rug.Shape=Enum.PartType.Block
    for x=-68,-48,10 do
        local sink=part(course,"Sink",Vector3.new(7,4,5),CFrame.new(x,26,-25),Enum.Material.Marble,WHITE,true)
        cylinder(course,"SinkBowl",4,1,CFrame.new(x,28,-28),Enum.Material.SmoothPlastic,BLUE,true)
        part(course,"Faucet",Vector3.new(1,4,1),CFrame.new(x,30,-25),Enum.Material.Metal,METAL,true)
    end
    for x=-70,-50,10 do
        local mirror=part(course,"Mirror",Vector3.new(8,6,.25),CFrame.new(x,29,-31),Enum.Material.Glass,Color3.fromRGB(185,215,225),false);mirror.Reflectance=.25
    end

    -- Five distinct difficulty identities, all kept on the perimeter.
    label(course,"ЭТАЖ 2  •  МОКРАЯ ЗОНА",Vector3.new(-60,47,0),18)
    floorDecor(course,40,82,Color3.fromRGB(120,205,225))
    wetTile(obstacles,Vector3.new(-25,43,58),Vector3.new(12,2,10));wetTile(obstacles,Vector3.new(8,43,-58),Vector3.new(12,2,10))
    mop(obstacles,Vector3.new(-10,44,56),28,.72,BLUE);plunger(obstacles,Vector3.new(26,44,48),1.0)
    for i=1,4 do
        local a=math.rad(35+i*38);local p=radialPoint(65,a,43)
        part(course,"Floor2Warning",Vector3.new(2,.2,5),CFrame.new(p)*CFrame.Angles(0,-a,0),Enum.Material.SmoothPlastic,CYAN,false)
    end

    label(course,"ЭТАЖ 3  •  УБОРКА",Vector3.new(52,65,0),18)
    floorDecor(course,58,76,Color3.fromRGB(235,190,125))
    mop(obstacles,Vector3.new(0,62,62),30,.9,PINK);plunger(obstacles,Vector3.new(-35,62,42),1.25)
    local paper=part(obstacles,"PaperRollHazard",Vector3.new(9,9,9),CFrame.new(25,64,-38),Enum.Material.Fabric,WHITE,true);paper.Shape=Enum.PartType.Cylinder;hazard(paper,"SWEEP",.6,12)
    for _,a in ipairs({math.rad(205),math.rad(245),math.rad(285)}) do
        local p=radialPoint(61,a,61)
        part(course,"LaundryBasket",Vector3.new(5,6,5),CFrame.new(p),Enum.Material.Plastic,BLUE,true)
    end

    label(course,"ЭТАЖ 4  •  САНТЕХНИКА",Vector3.new(-48,83,0),18)
    floorDecor(course,76,70,Color3.fromRGB(170,150,205))
    for _,a in ipairs({math.rad(20),math.rad(140),math.rad(260)}) do
        local p=radialPoint(55,a,81)
        local pipe=part(obstacles,"PipeGate",Vector3.new(5,5,18),CFrame.new(p)*CFrame.Angles(0,-a,math.rad(90)),Enum.Material.Metal,METAL,true);hazard(pipe,"ROTATE",.75,0)
    end
    mop(obstacles,Vector3.new(-15,80,48),26,1.0,PURPLE)
    local valve=cylinder(course,"Valve",10,2,CFrame.new(0,81,54),Enum.Material.Metal,RED,true)
    local wheel=part(course,"ValveWheel",Vector3.new(1,8,8),valve.CFrame*CFrame.Angles(0,math.rad(90),0),Enum.Material.Metal,GOLD,true);wheel.Shape=Enum.PartType.Cylinder

    label(course,"ЭТАЖ 5  •  ВЕРШИНА",Vector3.new(42,101,0),18)
    floorDecor(course,94,64,Color3.fromRGB(245,205,95))
    -- Final floor is tense but readable: three large moving gates and a clear finish lane.
    mop(obstacles,Vector3.new(0,98,50),24,1.1,ORANGE)
    local gate=part(obstacles,"FinalGate",Vector3.new(18,9,2),CFrame.new(-35,99,28),Enum.Material.Metal,ORANGE,true);hazard(gate,"SWEEP",.65,16)
    local gate2=part(obstacles,"FinalGate",Vector3.new(18,9,2),CFrame.new(35,99,-28),Enum.Material.Metal,RED,true);hazard(gate2,"SWEEP",.7,16)

    -- Spiral-ish perimeter stairs: each climb changes direction, forcing players to read the next section.
    stairs(course,Vector3.new(-78,17,0),Vector3.new(-67,22,38),10)
    stairs(course,Vector3.new(55,35,55),Vector3.new(57,40,-28),12)
    stairs(course,Vector3.new(-52,53,-40),Vector3.new(45,58,-48),13)
    stairs(course,Vector3.new(43,71,34),Vector3.new(-28,76,48),13)
    stairs(course,Vector3.new(-44,89,-32),Vector3.new(0,94,-60),10)

    -- The center is intentionally left empty; only the boss occupies it.
    local top=Instance.new("Folder");top.Name="FlushThrone";top.Parent=course
    part(top,"FinishPlatform",Vector3.new(28,5,22),CFrame.new(0,97,-60),Enum.Material.Marble,WHITE,true)
    part(top,"FinishPedestal",Vector3.new(16,7,13),CFrame.new(0,103,-60),Enum.Material.Marble,WHITE,true)
    part(top,"FlushTank",Vector3.new(18,14,7),CFrame.new(0,111,-72),Enum.Material.SmoothPlastic,WHITE,true)
    cylinder(top,"FlushButtonBase",10,2,CFrame.new(0,107,-60),Enum.Material.Metal,METAL,true)
    local button=cylinder(top,"TopFlushButton",7.5,3,CFrame.new(0,109,-60),Enum.Material.Neon,RED,true)
    button:SetAttribute("TopFlushButton",true)
    local prompt=Instance.new("ProximityPrompt");prompt.Name="FlushButtonPrompt";prompt.ActionText="СМЫТЬ БОССА";prompt.ObjectText="АВАРИЙНЫЙ СМЫВ";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=.35;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=button
    label(course,"🚽 ФИНАЛ  •  E = СМЫТЬ БОССА",Vector3.new(0,119,-60),22)

    -- Align boss flush validation with the new finish location.
    arena:SetAttribute("BossFlushPosition",Vector3.new(0,109,-60))
    arena:SetAttribute("UpperCourseReady",true);arena:SetAttribute("FiveFloorsReady",true);arena:SetAttribute("ThreeFloorsReady",true)
    return prompt
end

return UpperCourse