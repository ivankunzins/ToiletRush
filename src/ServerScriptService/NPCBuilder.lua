local TweenService=game:GetService("TweenService")
local NPCBuilder={}

local SKIN=Color3.fromRGB(235,190,145)
local HAIR=Color3.fromRGB(55,35,25)
local SHIRT=Color3.fromRGB(45,105,175)
local PANTS=Color3.fromRGB(35,40,48)
local YELLOW=Color3.fromRGB(255,205,55)

local function p(parent,name,size,cf,color,material)
    local x=Instance.new("Part")
    x.Name=name;x.Size=size;x.CFrame=cf;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false
    x.Color=color;x.Material=material or Enum.Material.SmoothPlastic;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=parent
    return x
end

local function make(parent,name,pos)
    local m=Instance.new("Model");m.Name=name;m.Parent=parent
    local root=p(m,"HumanoidRootPart",Vector3.new(2,2,1),CFrame.new(pos),Color3.new(1,1,1));root.Transparency=1
    p(m,"Torso",Vector3.new(3.2,3.8,1.7),CFrame.new(pos+Vector3.new(0,3.4,0)),SHIRT)
    p(m,"Head",Vector3.new(2.5,2.5,2.5),CFrame.new(pos+Vector3.new(0,6.2,0)),SKIN)
    p(m,"Hair",Vector3.new(2.65,.8,2.65),CFrame.new(pos+Vector3.new(0,7.55,0)),HAIR)
    p(m,"ArmL",Vector3.new(1,3.4,1),CFrame.new(pos+Vector3.new(-2.1,3.4,0)),SHIRT)
    p(m,"ArmR",Vector3.new(1,3.4,1),CFrame.new(pos+Vector3.new(2.1,3.4,0)),SHIRT)
    p(m,"LegL",Vector3.new(1.25,3.3,1.25),CFrame.new(pos+Vector3.new(-.8,.7,0)),PANTS)
    p(m,"LegR",Vector3.new(1.25,3.3,1.25),CFrame.new(pos+Vector3.new(.8,.7,0)),PANTS)
    p(m,"EyeL",Vector3.new(.32,.32,.12),CFrame.new(pos+Vector3.new(-.48,6.35,-1.23)),Color3.new(0,0,0))
    p(m,"EyeR",Vector3.new(.32,.32,.12),CFrame.new(pos+Vector3.new(.48,6.35,-1.23)),Color3.new(0,0,0))
    p(m,"Badge",Vector3.new(.65,.65,.12),CFrame.new(pos+Vector3.new(0,4.05,-.9)),YELLOW)
    m.PrimaryPart=root
    m:SetAttribute("NPC",true)
    return m
end

local function routePoint(y,offset)
    local t=math.clamp((y-22)/72,0,1)
    local angle=math.rad(-90)+t*math.pi*8+(offset or 0)
    return Vector3.new(math.cos(angle)*64,y,math.sin(angle)*64),angle
end

local function patrol(model,y,offset)
    task.spawn(function()
        local phase=offset or 0
        while model.Parent do
            local nextY=y+math.sin(os.clock()*.35+phase)*2.0
            local pos,angle=routePoint(nextY,phase)
            local target=CFrame.new(pos)*CFrame.Angles(0,-angle,0)
            local value=Instance.new("CFrameValue")
            value.Value=model:GetPivot()
            local connection=value:GetPropertyChangedSignal("Value"):Connect(function()
                if model.Parent then model:PivotTo(value.Value) end
            end)
            TweenService:Create(value,TweenInfo.new(4.2,Enum.EasingStyle.Linear),{Value=target}):Play()
            task.wait(4.25)
            connection:Disconnect();value:Destroy()
            phase+=math.rad(55)
        end
    end)
end

function NPCBuilder:Apply(arena)
    local old=arena:FindFirstChild("CrowdNPCs");if old then old:Destroy() end
    local folder=Instance.new("Folder");folder.Name="CrowdNPCs";folder.Parent=arena

    -- A small visual crowd travels around the same spiral as the player.
    local entries={
        {"NPC01",25,0},{"NPC02",28,math.rad(180)},
        {"NPC03",40,math.rad(60)},{"NPC04",43,math.rad(240)},
        {"NPC05",54,math.rad(120)},{"NPC06",57,math.rad(300)},
        {"NPC07",68,math.rad(30)},{"NPC08",72,math.rad(210)},
        {"NPC09",83,math.rad(150)},{"NPC10",89,math.rad(330)},
    }
    for _,d in ipairs(entries) do
        local pos,angle=routePoint(d[2],d[3])
        local model=make(folder,d[1],pos)
        model:PivotTo(CFrame.new(pos)*CFrame.Angles(0,-angle,0))
        patrol(model,d[2],d[3])
    end
    arena:SetAttribute("NPCsReady",true)
end

return NPCBuilder