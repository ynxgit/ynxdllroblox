-- [PlayerESP]
local RunService = game:GetService("RunService")

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
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and state then
                createHighlight(p.Character, Color3.fromRGB(0, 255, 0))
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum then
                    local info = string.format("%s | HP:%d/%d | W:%d", p.Name, math.floor(hum.Health), hum.MaxHealth, hum.WalkSpeed)
                    if not p.Character:FindFirstChild("ynx_label") then
                        createLabel(p.Character, info, Color3.new(0, 1, 0))
                    elseif p.Character.ynx_label:FindFirstChild("TextLabel") then
                        p.Character.ynx_label.TextLabel.Text = info
                    end
                end
            elseif p.Character then
                if p.Character:FindFirstChild("ynx_esp") then p.Character.ynx_esp:Destroy() end
                if p.Character:FindFirstChild("ynx_label") then p.Character.ynx_label:Destroy() end
            end
        end
    end)
end
