local UpperCourse = {}

local WHITE = Color3.fromRGB(245,247,250)
local PORCELAIN = Color3.fromRGB(232,239,244)
local BLUE = Color3.fromRGB(55,170,205)
local CYAN = Color3.fromRGB(75,190,205)
local GOLD = Color3.fromRGB(255,205,65)
local PINK = Color3.fromRGB(210,105,155)
local PURPLE = Color3.fromRGB(125,90,175)
local ORANGE = Color3.fromRGB(235,145,55)
local DARK = Color3.fromRGB(38,43,49)
local METAL = Color3.fromRGB(135,145,150)
local RED = Color3.fromRGB(220,55,55)
local GREEN = Color3.fromRGB(80,175,105)

local function part(parent,name,size,cf,material,color,collide)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
    p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or WHITE
    p.CanCollide=collide~=false;p.CanTouch=collide~=false;p.CanQuery=collide~=false
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
    return p
end

local function hazard(p,motion,speed,distance)
    p:SetAttribute("Hazard",true);p:SetAttribute("Motion",motion);p:SetAttribute("Speed",speed);p:SetAttribute("Distance",distance or 0);return p
end

local function sign(parent,text,pos,width)
    local board=part(parent,"RouteSign",Vector3.new(width or 16,5,.8),CFrame.new(pos),Enum.Material.Wood,DARK,false)
    local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset((width or 16)*18,75);gui.StudsOffset=Vector3.new(0,2.8,0);gui.AlwaysOnTop=true;gui.Parent=board
    local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=text;label.TextColor3=WHITE;label.TextStrokeTransparency=.25;label.Font=Enum.Font.GothamBlack;label.TextScaled=true;label.Parent=gui
    return board
end

local function arrow(parent,pos,yaw)
    local a=part(parent,"RouteArrow",Vector3.new(2.5,.25,5),CFrame.new(pos)*CFrame.Angles(0,yaw,0),Enum.Material.SmoothPlastic,CYAN,false);a.Transparency=.2
end

local function ringFloor(parent,name,y,outer,inner,segments)
    local folder=Instance.new("Folder");folder.Name=name;folder.Parent=parent
    local mid=(outer+inner)/2;local radial=outer-inner
    local circumference=2*math.pi*mid
    for i=1,segments do
        local a=(i-1)/segments*math.pi*2
        local pos=Vector3.new(math.cos(a)*mid,y,math.sin(a)*mid)
        local tangent=math.rad(90)+a
        local s=part(folder,"FloorSegment",Vector3.new(radial,2.5,math.max(5,circumference/segments+.8)),CFrame.new(pos)*CFrame.Angles(0,tangent,0),Enum.Material.Marble,WHITE,true)
        s:SetAttribute("UpperRoute",true)
    end
    return folder
end

local function spiralStairs(parent,fromY,toY,startAngle,radius)
    local count=12
    for i=1,count do
        local t=i/count
        local angle=startAngle+t*math.rad(42)
        local y=fromY+(toY-fromY)*t
        local pos=Vector3.new(math.cos(angle)*radius,y,math.sin(angle)*radius)
        local step=part(parent,"StairStep",Vector3.new(13,1.7,6.5),CFrame.new(pos)*CFrame.Angles(0,angle+math.rad(90),0),Enum.Material.Marble,WHITE,true)
        step:SetAttribute("UpperRoute",true)
        if i%4==1 then arrow(parent,pos+Vector3.new(0,1.05,0),angle+math.rad(90)) end
    end
end

local function addMop(obstacles,pos,length,speed)
    local hub=part(obstacles,"MopHub",Vector3.new(4.5,4.5,4.5),CFrame.new(pos),Enum.Material.Metal,DARK,true);hub.Shape=Enum.PartType.Ball;hub.CanCollide=false
    local bar=part(obstacles,"MopBar",Vector3.new(length,2.2,3),CFrame.new(pos),Enum.Material.Metal,PINK,true);hazard(bar,"ROTATE",speed,0)
    local head=part(obstacles,"MopHead",Vector3.new(10,3,5),bar.CFrame*CFrame.new(length/2-5,-2,0),Enum.Material.Fabric,WHITE,true);hazard(head,"ROTATE",speed,0)
end

local function addPlunger(obstacles,pos,speed)
    local cup=part(obstacles,"PlungerCup",Vector3.new(10,3,10),CFrame.new(pos),Enum.Material.SmoothPlastic,PURPLE,true);cup.Shape=Enum.PartType.Cylinder;hazard(cup,"BOUNCE",speed,4)
    local handle=part(obstacles,"PlungerHandle",Vector3.new(2.2,12,2.2),CFrame.new(pos+Vector3.new(0,7,0)),Enum.Material.Metal,METAL,true);hazard(handle,"BOUNCE",speed,4)
end

local function addRotatingGate(obstacles,pos,length,speed,color)
    local bar=part(obstacles,"RotatingGate",Vector3.new(length,2.5,3),CFrame.new(pos),Enum.Material.Metal,color,true);hazard(bar,"ROTATE",speed,0)
    local cap=part(obstacles,"GateCap",Vector3.new(5,3,5),CFrame.new(pos),Enum.Material.Metal,DARK,false);cap.Shape=Enum.PartType.Ball
end

function UpperCourse:Apply(arena)
    local old=arena:FindFirstChild("UpperCourse");if old then old:Destroy() end
    local course=Instance.new("Folder");course.Name="UpperCourse";course.Parent=arena
    local obstacles=arena:WaitForChild("Obstacles")

    local floors={
        {1,22,96,58,"ЭТАЖ 1  •  ВХОД И SHOP"},
        {2,40,94,57,"ЭТАЖ 2  •  ПЕРВЫЕ ИСПЫТАНИЯ"},
        {3,58,92,55,"ЭТАЖ 3  •  ДИНАМИКА"},
        {4,76,90,53,"ЭТАЖ 4  •  СЛОЖНЫЙ МАРШРУТ"},
        {5,94,88,51,"ЭТАЖ 5  •  ФИНИШ"},
    }
    for _,d in ipairs(floors) do
        local idx,y,outer,inner,title=table.unpack(d)
        ringFloor(course,"Floor"..idx,y,outer,inner,28)
        sign(course,title,Vector3.new(-outer+10,y+5,-8),22)
        if idx==1 then
            sign(course,"SHOP  •  ROBUX",Vector3.new(-70,y+5,25),15)
        end
    end

    for i=1,4 do
        spiralStairs(course,22+(i-1)*18+1.5,40+(i-1)*18-1.5,math.rad(-145+(i-1)*82),78-(i-1)*2)
    end

    -- Floor 1 is deliberately calm: no hazards, with space for the shop and detailed bathroom props.
    local shopZone=part(course,"ShopZone",Vector3.new(34,.4,25),CFrame.new(-70,23.4,24),Enum.Material.SmoothPlastic,Color3.fromRGB(225,235,238),false);shopZone.Transparency=.35

    -- Obstacles start on floor 2 and get denser as the player climbs.
    addMop(obstacles,Vector3.new(-55,44,38),32,.65)
    addPlunger(obstacles,Vector3.new(38,44,-45),1.0)
    addRotatingGate(obstacles,Vector3.new(0,44,66),38,.55,PINK)

    addMop(obstacles,Vector3.new(55,62,18),34,.82)
    addPlunger(obstacles,Vector3.new(-44,62,-42),1.15)
    addRotatingGate(obstacles,Vector3.new(-4,62,68),42,.72,ORANGE)

    addMop(obstacles,Vector3.new(-56,80,-5),36,.9)
    addPlunger(obstacles,Vector3.new(48,80,-28),1.3)
    addRotatingGate(obstacles,Vector3.new(2,80,65),44,.82,PURPLE)
    for _,x in ipairs({-22,22}) do
        local pad=part(obstacles,"SoapPad",Vector3.new(10,2,10),CFrame.new(x,79,38),Enum.Material.SmoothPlastic,BLUE,true);hazard(pad,"PULSE",1.25,3)
    end

    addMop(obstacles,Vector3.new(50,98,8),38,1.0)
    addPlunger(obstacles,Vector3.new(-42,98,-22),1.4)
    addRotatingGate(obstacles,Vector3.new(0,98,62),48,.95,RED)
    local curtain=part(obstacles,"ShowerCurtainGate",Vector3.new(28,12,1.6),CFrame.new(-5,100,-52),Enum.Material.Fabric,BLUE,true);hazard(curtain,"SWEEP",.65,12)

    local top=Instance.new("Folder");top.Name="FlushThrone";top.Parent=course
    part(top,"FlushPedestal",Vector3.new(28,6,22),CFrame.new(0,97,-72),Enum.Material.Marble,WHITE,true)
    part(top,"FlushTank",Vector3.new(22,15,8),CFrame.new(0,107,-84),Enum.Material.SmoothPlastic,PORCELAIN,true)
    local button=part(top,"TopFlushButton",Vector3.new(8,4,8),CFrame.new(0,102,-72),Enum.Material.Neon,RED,true);button.Shape=Enum.PartType.Cylinder;button:SetAttribute("TopFlushButton",true)
    local prompt=Instance.new("ProximityPrompt");prompt.Name="FlushButtonPrompt";prompt.ActionText="СМЫТЬ БОССА";prompt.ObjectText="АВАРИЙНЫЙ СМЫВ";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=.35;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=button
    sign(course,"ФИНИШ  •  E = СМЫТЬ БОССА",Vector3.new(0,111,-72),25)

    arena:SetAttribute("UpperCourseReady",true)
    arena:SetAttribute("FiveFloorsReady",true)
    return prompt
end

return UpperCourse
