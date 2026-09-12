-- Server-owned hazard animation. The world builder marks moving parts with attributes.
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local arena = Workspace:WaitForChild("ToiletArena", 30)
if not arena then return end
local obstacles = arena:WaitForChild("Obstacles")
local animated = {}

for _, object in obstacles:GetChildren() do
    local motion = object:GetAttribute("Motion")
    if motion then
        animated[#animated + 1] = {
            part = object,
            origin = object.CFrame,
            phase = object:GetAttribute("Phase") or 0,
            speed = object:GetAttribute("Speed") or 1,
            distance = object:GetAttribute("Distance") or 10,
            motion = motion,
        }
    end
end

RunService.Heartbeat:Connect(function()
    local t = os.clock()
    for _, item in animated do
        local object = item.part
        if object.Parent then
            local wave = math.sin(t * item.speed + item.phase)
            if item.motion == "ROTATE" then
                object.CFrame = item.origin * CFrame.Angles(0, t * item.speed, 0)
            elseif item.motion == "BOUNCE" then
                object.CFrame = item.origin + Vector3.new(0, wave * item.distance, 0)
            elseif item.motion == "SWEEP" then
                object.CFrame = item.origin * CFrame.new(wave * item.distance, 0, 0)
            end
        end
    end
end)
