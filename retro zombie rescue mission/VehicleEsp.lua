-- [VehicleESP]
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
        local vFolders = {Workspace:FindFirstChild("Vehicles"), Workspace:FindFirstChild("VipVehicles")}
        for _, folder in pairs(vFolders) do
            if folder then
                for _, v in pairs(folder:GetChildren()) do
                    if state then
                        createHighlight(v, Color3.fromRGB(0, 0, 255))
                        local owner = v:FindFirstChild("PurchaseOwner") and v.PurchaseOwner.Value or "None"
                        local fuel = (v:FindFirstChild("FuelSetting") and v.FuelSetting:FindFirstChild("Fuel")) and v.FuelSetting.Fuel.Value or 0
                        local info = "Veh | Own:" .. owner .. " | F:" .. fuel
                        if not v:FindFirstChild("ynx_label") then
                            createLabel(v, info, Color3.new(0, 0, 1))
                        elseif v.ynx_label:FindFirstChild("TextLabel") then
                            v.ynx_label.TextLabel.Text = info
                        end
                    else
                        if v:FindFirstChild("ynx_esp") then v.ynx_esp:Destroy() end
                        if v:FindFirstChild("ynx_label") then v.ynx_label:Destroy() end
                    end
                end
            end
        end
    end)
end
