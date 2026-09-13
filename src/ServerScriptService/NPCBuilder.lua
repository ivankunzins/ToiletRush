local NPCBuilder = {}

local SKIN = Color3.fromRGB(235,190,145)
local HAIR = Color3.fromRGB(55,35,25)
local SHIRT = Color3.fromRGB(45,105,175)
local PANTS = Color3.fromRGB(35,40,48)
local WHITE = Color3.fromRGB(245,245,242)
local YELLOW = Color3.fromRGB(255,205,55)

local function p(parent,name,size,cf,color,material)
    local x=Instance.new("Part")
    x.Name=name;x.Size=size;x.CFrame=cf;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false
    x.Color=color;x.Material=material or Enum.Material.SmoothPlastic
    x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=parent
    return x
end

local function label(model,text)
    local head=model:FindFirstChild("Head")
    if not head then return end
    local g=Instance.new("BillboardGui");g.Name="Talk";g.Size=UDim2.fromOffset(150,42);g.StudsOffset=Vector3.new(0,2.5,0);g.AlwaysOnTop=true;g.Parent=head
    local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=WHITE;t.TextStrokeTransparency=0.25;t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.Parent=g
end

local function make(parent,name,pos,scale,text,activity)
    local m=Instance.new("Model");m.Name=name;m.Parent=parent
    local root=p(m,"HumanoidRootPart",Vector3.new(2,2,1),CFrame.new(pos),Color3.new(1,1,1));root.Transparency=1
    local torso=p(m,"Torso",Vector3.new(3.2,3.8,1.7),CFrame.new(pos+Vector3.new(0,3.4,0)),SHIRT)
    local head=p(m,"Head",Vector3.new(2.5,2.5,2.5),CFrame.new(pos+Vector3.new(0,6.2,0)),SKIN)
    p(m,"Hair",Vector3.new(2.65,0.8,2.65),CFrame.new(pos+Vector3.new(0,7.55,0)),HAIR)
    p(m,"ArmL",Vector3.new(1,3.4,1),CFrame.new(pos+Vector3.new(-2.1,3.4,0)),SHIRT)
    p(m,"ArmR",Vector3.new(1,3.4,1),CFrame.new(pos+Vector3.new(2.1,3.4,0)),SHIRT)
    p(m,"LegL",Vector3.new(1.25,3.3,1.25),CFrame.new(pos+Vector3.new(-0.8,0.7,0)),PANTS)
    p(m,"LegR",Vector3.new(1.25,3.3,1.25),CFrame.new(pos+Vector3.new(0.8,0.7,0)),PANTS)
    p(m,"EyeL",Vector3.new(0.32,0.32,0.12),CFrame.new(pos+Vector3.new(-0.48,6.35,-1.23)),Color3.new(0,0,0))
    p(m,"EyeR",Vector3.new(0.32,0.32,0.12),CFrame.new(pos+Vector3.new(0.48,6.35,-1.23)),Color3.new(0,0,0))
    p(m,"Badge",Vector3.new(0.65,0.65,0.12),CFrame.new(pos+Vector3.new(0,4.05,-0.9)),YELLOW)
    m.PrimaryPart=root
    m:SetAttribute("NPC",true);m:SetAttribute("Activity",activity or "CHEER")
    label(m,text)
    return m
end

function NPCBuilder:Apply(arena)
    local old=arena:FindFirstChild("CrowdNPCs");if old then old:Destroy() end
    local folder=Instance.new("Folder");folder.Name="CrowdNPCs";folder.Parent=arena
    local data={
        {"NPC_Shopkeeper",Vector3.new(-25,24,7),"Что-нибудь купить?","SHOP"},
        {"NPC_Cheer1",Vector3.new(-5,24,-17),"Давай!","CHEER"},
        {"NPC_Cheer2",Vector3.new(30,24,15),"У тебя получится!","CHEER"},
        {"NPC_Floor2A",Vector3.new(-30,42,15),"Осторожно!","WATCH"},
        {"NPC_Floor2B",Vector3.new(30,42,-15),"Беги!","CHEER"},
        {"NPC_Floor2C",Vector3.new(0,42,16),"Не отставай!","CHEER"},
        {"NPC_Floor3A",Vector3.new(-22,60,-12),"Почти финиш!","CHEER"},
        {"NPC_Floor3B",Vector3.new(22,60,12),"Жми!","CHEER"},
        {"NPC_Floor3C",Vector3.new(0,60,16),"Кнопка там!","POINT"},
        {"NPC_Throne",Vector3.new(10,73,-3),"СМЫВАЙ!","CHEER"},
    }
    for _,d in ipairs(data) do make(folder,d[1],d[2],1,d[3],d[4]) end
    arena:SetAttribute("NPCsReady",true)
end

return NPCBuilder