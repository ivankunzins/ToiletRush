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

local function part(parent,name,size,cf,material,color,collide)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
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

local function point(radius,angle,y)
    return Vector3.new(math.cos(angle)*radius,y,math.sin(angle)*radius)
end

local function hazard(p,motion,speed,distance)
    p:SetAttribute("Hazard",true);p:SetAttribute("Motion",motion);p:SetAttribute("Speed",speed);p:SetAttribute("Distance",distance or 0)
    return p
end

local function spiralRamp(parent)
    local folder=Instance.new("Folder");folder.Name="SpiralRoute";folder.Parent=parent
    local radius=69
    local startAngle=math.rad(-90)
    local turns=4
    local segments=92
    local y0=22
    local y1=94
    local totalAngle=math.pi*2*turns
    local stepAngle=totalAngle/segments
    local dy=(y1-y0)/segments
    local width=17
    for i=1,segments do
        local a1=startAngle+(i-1)*stepAngle
        local a2=startAngle+i*stepAngle
        local am=(a1+a2)/2
        local y=y0+(i-.5)*dy
        local length=math.max(5.2,2*math.pi*radius*stepAngle/2*1.02)
        local pos=point(radius,am,y)
        local tangent=CFrame.Angles(0,-am-math.pi/2,0)
        local tile=part(folder,"SpiralStep",Vector3.new(width,2.8,length),CFrame.new(pos)*tangent,Enum.Material.Marble,(i%2==0) and TILE or WHITE,true)
        tile:SetAttribute("UpperRoute",true)
    end
end

local function rim(parent,y,radius)
    local folder=Instance.new("Folder");folder.Name="SpiralRim"..tostring(y);folder.Parent=parent
    for i=1,40 do
        local a=(i-1)*math.pi*2/40
        part(folder,"RimPost",Vector3.new(1,5.5,1),CFrame.new(point(radius,a,y+2.8)),Enum.Material.Metal,METAL,true)
    end
    for i=1,40 do
        local a=(i-.5)*math.pi*2/40
        part(folder,"RimBar",Vector3.new(1,1,math.max(7,math.pi*2*radius/40)),CFrame.new(point(radius,a,y+4.7))*CFrame.Angles(0,-a,0),Enum.Material.Metal,METAL,true)
    end
end

local function floorMarker(parent,y,number,angle)
    local pos=point(67,angle,y+1.8)
    local p=part(parent,"FloorMarker"..number,Vector3.new(14,.35,5),CFrame.new(pos)*CFrame.Angles(0,-angle,0),Enum.Material.Neon,({CYAN,BLUE,PURPLE,ORANGE,GOLD})[number],false)
    p.Transparency=.15
end

local function rotatingBar(parent,pos,length,speed,color)
    cylinder(parent,"RotatorBase",5,2,CFrame.new(pos),Enum.Material.Metal,DARK,false)
    local bar=part(parent,"RotatingGate",Vector3.new(length,2.2,3),CFrame.new(pos+Vector3.new(0,2,0)),Enum.Material.Metal,color,true)
    hazard(bar,"ROTATE",speed,0)
    local tip=part(parent,"GateTip",Vector3.new(3,3,3),CFrame.new(pos+Vector3.new(length/2,2,0)),Enum.Material.Neon,color,true)
    hazard(tip,"ROTATE",speed,0)
end

local function sweeper(parent,pos,length,speed,color)
    local bar=part(parent,"Sweeper",Vector3.new(length,2.4,3),CFrame.new(pos),Enum.Material.Metal,color,true)
    hazard(bar,"SWEEP",speed,math.max(8,length*.55))
end

local function wetPatch(parent,pos,size)
    local p=part(parent,"WetPatch",size,CFrame.new(pos),Enum.Material.Glass,BLUE,true)
    p.Transparency=.28;hazard(p,"PULSE",1.2,2)
end

local function coneGate(parent,pos,color)
    local a=part(parent,"GateA",Vector3.new(3,7,3),CFrame.new(pos+Vector3.new(-6,3.5,0)),Enum.Material.Metal,color,true)
    local b=part(parent,"GateB",Vector3.new(3,7,3),CFrame.new(pos+Vector3.new(6,3.5,0)),Enum.Material.Metal,color,true)
    local top=part(parent,"GateTop",Vector3.new(15,2,3),CFrame.new(pos+Vector3.new(0,7,0)),Enum.Material.Metal,color,true)
    hazard(a,"BOUNCE",1.0,1);hazard(b,"BOUNCE",1.0,1);hazard(top,"BOUNCE",1.0,1)
end

function UpperCourse:Apply(arena)
    local old=arena:FindFirstChild("UpperCourse");if old then old:Destroy() end
    local course=Instance.new("Folder");course.Name="UpperCourse";course.Parent=arena
    local obstacles=arena:WaitForChild("Obstacles")

    -- One continuous, wide spiral from the first level to the top.
    spiralRamp(course)
    for _,y in ipairs({22,40,58,76,94}) do rim(course,y,78) end
    local floorAngles={math.rad(-90),math.rad(198),math.rad(126),math.rad(54),math.rad(-18)}
    for i,y in ipairs({22,40,58,76,94}) do floorMarker(course,y,i,floorAngles[i]) end

    -- FLOOR 1: clean entrance and visible shop area.
    part(course,"WelcomePad",Vector3.new(26,.5,16),CFrame.new(-58,23,0),Enum.Material.Fabric,DARK,false)
    for x=-68,-48,10 do
        part(course,"Sink",Vector3.new(7,4,5),CFrame.new(x,26,-25),Enum.Material.Marble,WHITE,true)
        cylinder(course,"SinkBowl",4,1,CFrame.new(x,28,-28),Enum.Material.SmoothPlastic,BLUE,true)
        part(course,"Faucet",Vector3.new(1,4,1),CFrame.new(x,30,-25),Enum.Material.Metal,METAL,true)
        part(course,"Mirror",Vector3.new(8,6,.25),CFrame.new(x,29,-31),Enum.Material.Glass,Color3.fromRGB(185,215,225),false).Reflectance=.25
    end

    -- Distinct challenges along the ascent.
    rotatingBar(obstacles,point(69,math.rad(250),31),24,.8,BLUE)
    wetPatch(obstacles,point(69,math.rad(205),36),Vector3.new(14,2,9))
    coneGate(obstacles,point(69,math.rad(145),49),PURPLE)
    sweeper(obstacles,point(69,math.rad(55),60),28,.7,PINK)
    wetPatch(obstacles,point(69,math.rad(-8),67),Vector3.new(15,2,10))
    rotatingBar(obstacles,point(69,math.rad(-75),77),26,.72,ORANGE)
    coneGate(obstacles,point(69,math.rad(205),86),RED)
    sweeper(obstacles,point(69,math.rad(100),91),30,.75,GOLD)

    for _,a in ipairs({math.rad(232),math.rad(92),math.rad(-48)}) do
        cylinder(course,"PipeStack",7,8,CFrame.new(point(61,a,53)),Enum.Material.Metal,METAL,true)
    end
    for _,a in ipairs({math.rad(180),math.rad(0),math.rad(300)}) do
        part(course,"LaundryBasket",Vector3.new(6,5,6),CFrame.new(point(60,a,72)),Enum.Material.Plastic,BLUE,true)
    end

    -- TOP PLATFORM / boss button.
    local throne=Instance.new("Folder");throne.Name="FlushThrone";throne.Parent=course
    part(throne,"FinishPlatform",Vector3.new(30,5,24),CFrame.new(0,97,-60),Enum.Material.Marble,WHITE,true)
    part(throne,"FinishPedestal",Vector3.new(16,7,13),CFrame.new(0,103,-60),Enum.Material.Marble,WHITE,true)
    part(throne,"FlushTank",Vector3.new(18,14,7),CFrame.new(0,111,-72),Enum.Material.SmoothPlastic,WHITE,true)
    cylinder(throne,"FlushButtonBase",10,2,CFrame.new(0,107,-60),Enum.Material.Metal,METAL,true)
    local button=cylinder(throne,"TopFlushButton",7.5,3,CFrame.new(0,109,-60),Enum.Material.Neon,RED,true)
    button:SetAttribute("TopFlushButton",true)
    local prompt=Instance.new("ProximityPrompt")
    prompt.Name="FlushButtonPrompt";prompt.ActionText="СМЫТЬ БОССА";prompt.ObjectText="АВАРИЙНЫЙ СМЫВ";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=.35;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=button

    arena:SetAttribute("BossFlushPosition",Vector3.new(0,109,-60))
    arena:SetAttribute("UpperCourseReady",true)
    arena:SetAttribute("FiveFloorsReady",true)
    arena:SetAttribute("ThreeFloorsReady",true)
end

return UpperCourse