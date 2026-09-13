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
local PINK=Color3.fromRGB(225,100,155)

local function part(parent,name,size,cf,material,color,collide)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or WHITE
    p.CanCollide=collide~=false;p.CanTouch=collide~=false;p.CanQuery=collide~=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function cylinder(parent,name,diameter,height,cf,material,color,collide)
    local p=part(parent,name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),material,color,collide);p.Shape=Enum.PartType.Cylinder;return p
end
local function point(radius,angle,y)return Vector3.new(math.cos(angle)*radius,y,math.sin(angle)*radius)end
local function routeAngle(y)
    return math.rad(-90)+math.clamp((y-22)/72,0,1)*math.pi*8
end
local function routePoint(y,radius)return point(radius,routeAngle(y),y)end
local function hazard(p,motion,speed,distance)
    p:SetAttribute("Hazard",true);p:SetAttribute("Motion",motion);p:SetAttribute("Speed",speed);p:SetAttribute("Distance",distance or 0);return p
end

local function spiralRamp(parent)
    local folder=Instance.new("Folder");folder.Name="SpiralRoute";folder.Parent=parent
    local radius=69;local segments=92;local y0=22;local y1=94;local stepAngle=math.pi*8/segments;local dy=(y1-y0)/segments;local width=17
    local pitch=math.atan2(dy,radius*stepAngle)
    for i=1,segments do
        local a=(i-.5)*stepAngle+math.rad(-90);local y=y0+(i-.5)*dy
        local pos=point(radius,a,y)
        local tile=part(folder,"SpiralStep",Vector3.new(width,2.8,radius*stepAngle*1.06),CFrame.new(pos)*CFrame.Angles(pitch,-a,0),Enum.Material.Marble,(i%2==0) and TILE or WHITE,true)
        tile:SetAttribute("UpperRoute",true)
    end
end
local function rim(parent,y,radius)
    local folder=Instance.new("Folder");folder.Name="SpiralRim"..y;folder.Parent=parent
    for i=1,40 do local a=(i-1)*math.pi*2/40;part(folder,"RimPost",Vector3.new(1,5.5,1),CFrame.new(point(radius,a,y+2.8)),Enum.Material.Metal,METAL,true) end
    for i=1,40 do local a=(i-.5)*math.pi*2/40;part(folder,"RimBar",Vector3.new(1,1,math.max(7,math.pi*2*radius/40)),CFrame.new(point(radius,a,y+4.7))*CFrame.Angles(0,-a,0),Enum.Material.Metal,METAL,true) end
end
local function floorMarker(parent,y,n)
    local p=part(parent,"FloorMarker"..n,Vector3.new(14,.35,5),CFrame.new(routePoint(y,67))*CFrame.Angles(0,-routeAngle(y),0),Enum.Material.Neon,({CYAN,BLUE,PURPLE,ORANGE,GOLD})[n],false);p.Transparency=.15
end
local function rotatingBar(parent,y,length,speed,color)
    local pos=routePoint(y,69);cylinder(parent,"RotatorBase",5,2,CFrame.new(pos),Enum.Material.Metal,DARK,false)
    local a=routeAngle(y);local bar=part(parent,"RotatingGate",Vector3.new(length,2.2,3),CFrame.new(pos+Vector3.new(0,2.2,0))*CFrame.Angles(0,-a,0),Enum.Material.Metal,color,true);hazard(bar,"ROTATE",speed,0)
    local tip=part(parent,"GateTip",Vector3.new(3,3,3),bar.CFrame*CFrame.new(length/2,0,0),Enum.Material.Neon,color,true);hazard(tip,"ROTATE",speed,0)
end
local function sweeper(parent,y,length,speed,color)
    local pos=routePoint(y,69);local a=routeAngle(y);local bar=part(parent,"Sweeper",Vector3.new(length,2.4,3),CFrame.new(pos+Vector3.new(0,1.2,0))*CFrame.Angles(0,-a,0),Enum.Material.Metal,color,true);hazard(bar,"SWEEP",speed,math.max(8,length*.55))
end
local function wetPatch(parent,y,size)
    local p=part(parent,"WetPatch",size,CFrame.new(routePoint(y,69)-Vector3.new(0,1,0)),Enum.Material.Glass,BLUE,true);p.Transparency=.28;hazard(p,"PULSE",1.2,2)
end
local function coneGate(parent,y,color)
    local pos=routePoint(y,69);local a=routeAngle(y);local cf=CFrame.new(pos)*CFrame.Angles(0,-a,0)
    local l=part(parent,"GateA",Vector3.new(3,7,3),cf*CFrame.new(-6,3.5,0),Enum.Material.Metal,color,true)
    local r=part(parent,"GateB",Vector3.new(3,7,3),cf*CFrame.new(6,3.5,0),Enum.Material.Metal,color,true)
    local top=part(parent,"GateTop",Vector3.new(15,2,3),cf*CFrame.new(0,7,0),Enum.Material.Metal,color,true)
    hazard(l,"BOUNCE",1,1);hazard(r,"BOUNCE",1,1);hazard(top,"BOUNCE",1,1)
end

function UpperCourse:Apply(arena)
    local old=arena:FindFirstChild("UpperCourse");if old then old:Destroy()end
    local course=Instance.new("Folder");course.Name="UpperCourse";course.Parent=arena
    local obstacles=arena:WaitForChild("Obstacles")
    spiralRamp(course)
    for _,y in ipairs({22,40,58,76,94})do rim(course,y,78)end
    for i,y in ipairs({22,40,58,76,94})do floorMarker(course,y,i)end

    -- Floor 1 stays clean and readable; the shop remains here.
    part(course,"WelcomePad",Vector3.new(26,.5,16),CFrame.new(-58,23,0),Enum.Material.Fabric,DARK,false)
    for x=-68,-48,10 do
        part(course,"Sink",Vector3.new(7,4,5),CFrame.new(x,26,-25),Enum.Material.Marble,WHITE,true)
        cylinder(course,"SinkBowl",4,1,CFrame.new(x,28,-28),Enum.Material.SmoothPlastic,BLUE,true)
        part(course,"Faucet",Vector3.new(1,4,1),CFrame.new(x,30,-25),Enum.Material.Metal,METAL,true)
        part(course,"Mirror",Vector3.new(8,6,.25),CFrame.new(x,29,-31),Enum.Material.Glass,Color3.fromRGB(185,215,225),false).Reflectance=.25
    end

    -- Clear obstacle checkpoints distributed through the spiral.
    rotatingBar(obstacles,30,24,.8,BLUE)
    wetPatch(obstacles,39,Vector3.new(14,2,10))
    coneGate(obstacles,48,PURPLE)
    sweeper(obstacles,58,28,.7,PINK)
    wetPatch(obstacles,67,Vector3.new(15,2,10))
    rotatingBar(obstacles,76,26,.72,ORANGE)
    coneGate(obstacles,85,RED)
    sweeper(obstacles,92,30,.75,GOLD)

    for _,a in ipairs({math.rad(20),math.rad(140),math.rad(260)})do cylinder(course,"PipeStack",7,8,CFrame.new(point(61,a,53)),Enum.Material.Metal,METAL,true)end
    for _,a in ipairs({math.rad(180),math.rad(0),math.rad(300)})do part(course,"LaundryBasket",Vector3.new(6,5,6),CFrame.new(point(60,a,72)),Enum.Material.Plastic,BLUE,true)end

    local throne=Instance.new("Folder");throne.Name="FlushThrone";throne.Parent=course
    part(throne,"FinishPlatform",Vector3.new(30,5,24),CFrame.new(0,97,-60),Enum.Material.Marble,WHITE,true)
    part(throne,"FinishPedestal",Vector3.new(16,7,13),CFrame.new(0,103,-60),Enum.Material.Marble,WHITE,true)
    part(throne,"FlushTank",Vector3.new(18,14,7),CFrame.new(0,111,-72),Enum.Material.SmoothPlastic,WHITE,true)
    cylinder(throne,"FlushButtonBase",10,2,CFrame.new(0,107,-60),Enum.Material.Metal,METAL,true)
    local button=cylinder(throne,"TopFlushButton",7.5,3,CFrame.new(0,109,-60),Enum.Material.Neon,RED,true)
    button:SetAttribute("TopFlushButton",true)
    local prompt=Instance.new("ProximityPrompt");prompt.Name="FlushButtonPrompt";prompt.ActionText="СМЫТЬ БОССА";prompt.ObjectText="АВАРИЙНЫЙ СМЫВ";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=.35;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=button
    arena:SetAttribute("BossFlushPosition",Vector3.new(0,109,-60))
    arena:SetAttribute("UpperCourseReady",true);arena:SetAttribute("FiveFloorsReady",true);arena:SetAttribute("ThreeFloorsReady",true)
end
return UpperCourse