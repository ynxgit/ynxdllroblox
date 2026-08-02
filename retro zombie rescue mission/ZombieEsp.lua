-- [ZombieESP]
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local function createLabel(parent, text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ynx_label"
    billboard.DistanceScalingMode = Enum.DistanceScalingMode.None 
    billboard.AlwaysOnTop = false 
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.RobotoMono
    label.TextXAlignment = Enum.TextXAlignment.Center
    billboard.Parent = parent
    return billboard
end

local function createHighlight(object, color)
    if object:FindFirstChild("ynx_esp") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ynx_esp"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
    highlight.Parent = object
end

return function(state)
    RunService.Heartbeat:Connect(function()
        local zFolder = Workspace:FindFirstChild("Zombies")
        if zFolder then
            for _, z in pairs(zFolder:GetChildren()) do
                if state then
                    createHighlight(z, Color3.fromRGB(255, 0, 0))
                    local speed = (z:FindFirstChild("Settings") and z.Settings:FindFirstChild("RunSpeed")) and z.Settings.RunSpeed.Value or 0
                    local info = "ZMB | Spd:" .. speed
                    if not z:FindFirstChild("ynx_label") then
                        createLabel(z, info, Color3.new(1, 0, 0))
                    elseif z.ynx_label:FindFirstChild("TextLabel") then
                        z.ynx_label.TextLabel.Text = info
                    end
                else
                    if z:FindFirstChild("ynx_esp") then z.ynx_esp:Destroy() end
                    if z:FindFirstChild("ynx_label") then z.ynx_label:Destroy() end
                end
            end
        end
    end)
end
