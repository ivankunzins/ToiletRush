local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local fireRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PistolFire")
local bound = {}
local lastShot = 0

local function bindTool(tool)
    if not tool:IsA("Tool") or (tool.Name ~= "CoinPistol" and tool.Name ~= "FlushBlaster") or bound[tool] then return end
    bound[tool] = true
    tool.Activated:Connect(function()
        if UserInputService:GetFocusedTextBox() then return end
        local now = os.clock()
        if now - lastShot < 0.18 then return end
        lastShot = now
        local camera = workspace.CurrentCamera
        if not camera then return end
        local mouse = player:GetMouse()
        local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
        fireRemote:FireServer(ray.Origin, ray.Direction.Unit)
    end)
    tool.Destroying:Connect(function() bound[tool] = nil end)
end

local function watch(container)
    for _, child in ipairs(container:GetChildren()) do bindTool(child) end
    container.ChildAdded:Connect(bindTool)
end

watch(player:WaitForChild("Backpack"))
player.CharacterAdded:Connect(watch)
if player.Character then watch(player.Character) end
