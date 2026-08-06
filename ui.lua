-- ==========================================
-- 1. THE LIBRARY SOURCE CODE
-- ==========================================
local library = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local Colors = {
    Background = Color3.fromRGB(0, 0, 0),
    Sidebar = Color3.fromRGB(10, 10, 10),
    Accent = Color3.fromRGB(138, 172, 255),
    AccentHover = Color3.fromRGB(158, 188, 255),
    Text = Color3.fromRGB(240, 240, 240),
    DarkText = Color3.fromRGB(140, 140, 140),
    ElementBg = Color3.fromRGB(18, 18, 18),
    ElementHover = Color3.fromRGB(24, 24, 24),
    Ripple = Color3.fromRGB(255, 255, 255),
    Shadow = Color3.fromRGB(138, 172, 255),
    NotiInfo = Color3.fromRGB(138, 172, 255),
    NotiWarn = Color3.fromRGB(255, 170, 0),
    NotiSuccess = Color3.fromRGB(85, 255, 127)
}
local Sounds = { Hover = "rbxassetid://6895079853", Click = "rbxassetid://6895079853", ToggleOn = "rbxassetid://6895079853", ToggleOff = "rbxassetid://6895079853", Tab = "rbxassetid://6895079853", Noti = "rbxassetid://6895079853" }

local function playSound(id, pitch, vol)
    local snd = Instance.new("Sound") snd.SoundId = id snd.PlaybackSpeed = pitch or 1 snd.Volume = vol or 0.5 snd.Parent = SoundService snd:Play() snd.Ended:Connect(function() snd:Destroy() end)
end
local function tween(obj, info, props)
    local t = TweenService:Create(obj, TweenInfo.new(unpack(info)), props) t:Play() return t
end
local function createRipple(parent, x, y)
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5
    local ripple = Instance.new("Frame") ripple.Parent = parent ripple.BackgroundColor3 = Colors.Ripple ripple.BackgroundTransparency = 0.8 ripple.BorderSizePixel = 0 ripple.Position = UDim2.new(0, x - parent.AbsolutePosition.X, 0, y - parent.AbsolutePosition.Y) ripple.Size = UDim2.new(0, 0, 0, 0) ripple.AnchorPoint = Vector2.new(0.5, 0.5) ripple.ZIndex = parent.ZIndex + 1 Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
    tween(ripple, {0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}).Completed:Connect(function() ripple:Destroy() end)
end

function library:CreateWindow(config)
    config = config or {}
    local TitleText = config.Title or "Menu"
    local WatermarkFormat = config.Watermark or TitleText .. " | {time} | {game}"
    local ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift

    if CoreGui:FindFirstChild("YnxdllLib") then CoreGui.YnxdllLib:Destroy() end

    local UI = Instance.new("ScreenGui") UI.Name = "YnxdllLib" UI.Parent = CoreGui UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling UI.IgnoreGuiInset = true UI.DisplayOrder = 2147483647 UI.Enabled = true

    local NotiContainer = Instance.new("Frame") NotiContainer.Parent = UI NotiContainer.BackgroundTransparency = 1 NotiContainer.Position = UDim2.new(1, -320, 1, -20) NotiContainer.Size = UDim2.new(0, 300, 1, 0) NotiContainer.AnchorPoint = Vector2.new(0, 1)
    local NotiList = Instance.new("UIListLayout") NotiList.Parent = NotiContainer NotiList.SortOrder = Enum.SortOrder.LayoutOrder NotiList.VerticalAlignment = Enum.VerticalAlignment.Bottom NotiList.Padding = UDim.new(0, 10)

    local function Notify(title, message, notiType, duration)
        notiType = notiType or "info" duration = duration or 3
        local typeColor = Colors.NotiInfo if notiType == "warn" then typeColor = Colors.NotiWarn elseif notiType == "success" then typeColor = Colors.NotiSuccess end
        local card = Instance.new("Frame") card.Parent = NotiContainer card.BackgroundColor3 = Colors.ElementBg card.BackgroundTransparency = 1 card.Size = UDim2.new(1, 0, 0, 60) card.Position = UDim2.new(1, 20, 0, 0) Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
        local stripe = Instance.new("Frame") stripe.Parent = card stripe.BackgroundColor3 = typeColor stripe.Size = UDim2.new(0, 4, 1, 0) stripe.BackgroundTransparency = 1 Instance.new("UICorner", stripe).CornerRadius = UDim.new(0, 6)
        local txtTitle = Instance.new("TextLabel") txtTitle.Parent = card txtTitle.BackgroundTransparency = 1 txtTitle.Position = UDim2.new(0, 15, 0, 10) txtTitle.Size = UDim2.new(1, -25, 0, 20) txtTitle.Font = Enum.Font.GothamBold txtTitle.Text = title txtTitle.TextColor3 = typeColor txtTitle.TextSize = 14 txtTitle.TextXAlignment = Enum.TextXAlignment.Left txtTitle.TextTransparency = 1
        local txtMsg = Instance.new("TextLabel") txtMsg.Parent = card txtMsg.BackgroundTransparency = 1 txtMsg.Position = UDim2.new(0, 15, 0, 30) txtMsg.Size = UDim2.new(1, -25, 0, 20) txtMsg.Font = Enum.Font.Gotham txtMsg.Text = message txtMsg.TextColor3 = Colors.Text txtMsg.TextSize = 12 txtMsg.TextXAlignment = Enum.TextXAlignment.Left txtMsg.TextTransparency = 1
        playSound(Sounds.Noti, 1.2, 0.4)
        tween(card, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}) tween(stripe, {0.4}, {BackgroundTransparency = 0}) tween(txtTitle, {0.4}, {TextTransparency = 0}) tween(txtMsg, {0.4}, {TextTransparency = 0})
        task.spawn(function() task.wait(duration) tween(card, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In}, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}) tween(stripe, {0.4}, {BackgroundTransparency = 1}) tween(txtTitle, {0.4}, {TextTransparency = 1}) tween(txtMsg, {0.4}, {TextTransparency = 1}) task.wait(0.4) card:Destroy() end)
    end

    local Watermark = Instance.new("Frame") Watermark.Parent = UI Watermark.BackgroundColor3 = Colors.ElementBg Watermark.Position = UDim2.new(0.5, 0, 0, 20) Watermark.Size = UDim2.new(0, 300, 0, 30) Watermark.AnchorPoint = Vector2.new(0.5, 0) Watermark.Visible = true Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
    local WMStroke = Instance.new("UIStroke") WMStroke.Parent = Watermark WMStroke.Color = Colors.Accent WMStroke.Thickness = 1 WMStroke.Transparency = 0.5
    local WMText = Instance.new("TextLabel") WMText.Parent = Watermark WMText.BackgroundTransparency = 1 WMText.Size = UDim2.new(1, 0, 1, 0) WMText.Font = Enum.Font.GothamMedium WMText.Text = "" WMText.TextColor3 = Colors.Text WMText.TextSize = 13
    task.spawn(function() local gameName = game.Name if gameName == "" or gameName == "Game" then gameName = "Roblox" end while task.wait(1) do local str = string.gsub(WatermarkFormat, "{time}", os.date("%I:%M %p")) str = string.gsub(str, "{game}", gameName) WMText.Text = str end end)

    local MainContainer = Instance.new("Frame") MainContainer.Parent = UI MainContainer.BackgroundColor3 = Colors.Background MainContainer.BorderSizePixel = 0 MainContainer.Size = UDim2.new(1, 0, 1, 0) MainContainer.Visible = false
    local Sidebar = Instance.new("Frame") Sidebar.Parent = MainContainer Sidebar.BackgroundColor3 = Colors.Sidebar Sidebar.BorderSizePixel = 0 Sidebar.Size = UDim2.new(0, 220, 1, 0) Sidebar.ZIndex = 2
    local TitleLabel = Instance.new("TextLabel") TitleLabel.Parent = Sidebar TitleLabel.BackgroundTransparency = 1 TitleLabel.Position = UDim2.new(0, 0, 0, 25) TitleLabel.Size = UDim2.new(1, 0, 0, 40) TitleLabel.Font = Enum.Font.GothamBold TitleLabel.Text = TitleText TitleLabel.TextColor3 = Colors.Accent TitleLabel.TextSize = 32 TitleLabel.TextXAlignment = Enum.TextXAlignment.Center TitleLabel.ZIndex = 2
    local TabContainer = Instance.new("Frame") TabContainer.Parent = Sidebar TabContainer.BackgroundTransparency = 1 TabContainer.Position = UDim2.new(0, 0, 0, 90) TabContainer.Size = UDim2.new(1, 0, 1, -90) TabContainer.ZIndex = 2
    local TabListLayout = Instance.new("UIListLayout") TabListLayout.Parent = TabContainer TabListLayout.Padding = UDim.new(0, 8)
    local ContentArea = Instance.new("Frame") ContentArea.Parent = MainContainer ContentArea.BackgroundTransparency = 1 ContentArea.Position = UDim2.new(0, 220, 0, 0) ContentArea.Size = UDim2.new(1, -220, 1, 0)

    local window = {} local activeTab = nil
    function window:Notify(...) Notify(...) end

    function window:CreateTab(name)
        local tab = {}
        local TabButton = Instance.new("TextButton") TabButton.Parent = TabContainer TabButton.BackgroundColor3 = Colors.ElementBg TabButton.BackgroundTransparency = 1 TabButton.Size = UDim2.new(1, 0, 0, 45) TabButton.Font = Enum.Font.GothamMedium TabButton.Text = "    " .. name TabButton.TextColor3 = Colors.DarkText TabButton.TextSize = 15 TabButton.TextXAlignment = Enum.TextXAlignment.Left TabButton.ClipsDescendants = true
        local Indicator = Instance.new("Frame") Indicator.Parent = TabButton Indicator.BackgroundColor3 = Colors.Accent Indicator.Position = UDim2.new(0, 0, 0.5, -10) Indicator.Size = UDim2.new(0, 3, 0, 0) Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 2)
        local TabContent = Instance.new("ScrollingFrame") TabContent.Parent = ContentArea TabContent.BackgroundTransparency = 1 TabContent.Position = UDim2.new(0, 30, 0, 30) TabContent.Size = UDim2.new(1, -60, 1, -60) TabContent.ScrollBarThickness = 2 TabContent.ScrollBarImageColor3 = Colors.Sidebar TabContent.Visible = false
        local ContentList = Instance.new("UIListLayout") ContentList.Parent = TabContent ContentList.Padding = UDim.new(0, 12)
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20) end)

        TabButton.MouseEnter:Connect(function() if activeTab.Button ~= TabButton then tween(TabButton, {0.2}, {TextColor3 = Colors.Text}) end end)
        TabButton.MouseLeave:Connect(function() if activeTab.Button ~= TabButton then tween(TabButton, {0.2}, {TextColor3 = Colors.DarkText}) end end)
        TabButton.MouseButton1Click:Connect(function()
            if activeTab.Button == TabButton then return end playSound(Sounds.Tab, 0.9, 0.3) createRipple(TabButton, UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
            tween(activeTab.Button, {0.2}, {TextColor3 = Colors.DarkText, BackgroundTransparency = 1}) tween(activeTab.Indicator, {0.3}, {Size = UDim2.new(0, 3, 0, 0)}) activeTab.Content.Visible = false
            activeTab = {Button = TabButton, Content = TabContent, Indicator = Indicator} TabContent.Visible = true tween(TabButton, {0.2}, {TextColor3 = Colors.Accent, BackgroundTransparency = 0.8}) tween(Indicator, {0.3}, {Size = UDim2.new(0, 3, 0, 20)})
        end)
        if not activeTab then activeTab = {Button = TabButton, Content = TabContent, Indicator = Indicator} TabContent.Visible = true TabButton.TextColor3 = Colors.Accent TabButton.BackgroundTransparency = 0.8 Indicator.Size = UDim2.new(0, 3, 0, 20) end

        function tab:CreateButton(text, callback)
            local btn = Instance.new("TextButton") btn.Parent = TabContent btn.BackgroundColor3 = Colors.ElementBg btn.Size = UDim2.new(1, -10, 0, 45) btn.Font = Enum.Font.GothamMedium btn.Text = text btn.TextColor3 = Colors.Text btn.TextSize = 14 btn.ClipsDescendants = true Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseEnter:Connect(function() tween(btn, {0.2}, {BackgroundColor3 = Colors.ElementHover}) end) btn.MouseLeave:Connect(function() tween(btn, {0.2}, {BackgroundColor3 = Colors.ElementBg}) end) btn.MouseButton1Down:Connect(function() tween(btn, {0.1}, {Size = UDim2.new(1, -14, 0, 41)}) end)
            btn.MouseButton1Up:Connect(function() playSound(Sounds.Click, 1.1, 0.4) createRipple(btn, UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) tween(btn, {0.3}, {Size = UDim2.new(1, -10, 0, 45)}) callback() end)
        end

        function tab:CreateToggle(text, callback)
            local toggled = false local frame = Instance.new("TextButton") frame.Parent = TabContent frame.BackgroundColor3 = Colors.ElementBg frame.BackgroundTransparency = 1 frame.Size = UDim2.new(1, -10, 0, 45) frame.Text = ""
            local label = Instance.new("TextLabel") label.Parent = frame label.BackgroundTransparency = 1 label.Position = UDim2.new(0, 15, 0, 0) label.Size = UDim2.new(1, -60, 1, 0) label.Font = Enum.Font.GothamMedium label.Text = text label.TextColor3 = Colors.Text label.TextSize = 14 label.TextXAlignment = Enum.TextXAlignment.Left
            local pill = Instance.new("Frame") pill.Parent = frame pill.BackgroundColor3 = Colors.Sidebar pill.Position = UDim2.new(1, -55, 0.5, -12) pill.Size = UDim2.new(0, 42, 0, 24) Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
            local glow = Instance.new("ImageLabel") glow.Parent = pill glow.BackgroundTransparency = 1 glow.Position = UDim2.new(0.5, 0, 0.5, 0) glow.Size = UDim2.new(1, 20, 1, 20) glow.AnchorPoint = Vector2.new(0.5, 0.5) glow.Image = "rbxassetid://5028857472" glow.ImageColor3 = Colors.Shadow glow.ZIndex = 0
            local puck = Instance.new("Frame") puck.Parent = pill puck.BackgroundColor3 = Colors.DarkText puck.Position = UDim2.new(0, 2, 0.5, -10) puck.Size = UDim2.new(0, 20, 0, 20) puck.ZIndex = 2 Instance.new("UICorner", puck).CornerRadius = UDim.new(1, 0)
            frame.MouseButton1Click:Connect(function() toggled = not toggled playSound(toggled and Sounds.ToggleOn or Sounds.ToggleOff, toggled and 1.2 or 0.8, 0.3) local tPos = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10) tween(puck, {0.4}, {Position = tPos, BackgroundColor3 = toggled and Colors.Text or Colors.DarkText}) tween(pill, {0.3}, {BackgroundColor3 = toggled and Colors.Accent or Colors.Sidebar}) tween(glow, {0.3}, {ImageTransparency = toggled and 0.6 or 1}) callback(toggled) end)
        end

        function tab:CreateSlider(text, min, max, default, callback)
            local value = default or min local frame = Instance.new("Frame") frame.Parent = TabContent frame.BackgroundColor3 = Colors.ElementBg frame.BackgroundTransparency = 1 frame.Size = UDim2.new(1, -10, 0, 60)
            local label = Instance.new("TextLabel") label.Parent = frame label.BackgroundTransparency = 1 label.Position = UDim2.new(0, 15, 0, 5) label.Size = UDim2.new(1, -70, 0, 20) label.Font = Enum.Font.GothamMedium label.Text = text label.TextColor3 = Colors.Text label.TextSize = 14 label.TextXAlignment = Enum.TextXAlignment.Left
            local slideBg = Instance.new("TextButton") slideBg.Parent = frame slideBg.BackgroundColor3 = Colors.Sidebar slideBg.Position = UDim2.new(0, 15, 0, 35) slideBg.Size = UDim2.new(1, -30, 0, 6) slideBg.Text = "" Instance.new("UICorner", slideBg).CornerRadius = UDim.new(1, 0)
            local slideFill = Instance.new("Frame") slideFill.Parent = slideBg slideFill.BackgroundColor3 = Colors.Accent slideFill.Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0) Instance.new("UICorner", slideFill).CornerRadius = UDim.new(1, 0)
            local puck = Instance.new("Frame") puck.Parent = slideFill puck.AnchorPoint = Vector2.new(0.5, 0.5) puck.BackgroundColor3 = Colors.Text puck.Position = UDim2.new(1, 0, 0.5, 0) puck.Size = UDim2.new(0, 14, 0, 14) Instance.new("UICorner", puck).CornerRadius = UDim.new(1, 0)
            local dragging = false
            local function update(input) local pos = math.clamp((input.Position.X - slideBg.AbsolutePosition.X) / slideBg.AbsoluteSize.X, 0, 1) value = math.floor(min + ((max - min) * pos)) tween(slideFill, {0.05}, {Size = UDim2.new(pos, 0, 1, 0)}) callback(value) end
            slideBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end end) UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end) UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
        end

        function tab:CreateDropdown(text, options, callback)
            local expanded = false local itemHeight = 35 local frame = Instance.new("Frame") frame.Parent = TabContent frame.BackgroundColor3 = Colors.ElementBg frame.Size = UDim2.new(1, -10, 0, 45) frame.ClipsDescendants = true Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local btn = Instance.new("TextButton") btn.Parent = frame btn.BackgroundTransparency = 1 btn.Size = UDim2.new(1, 0, 0, 45) btn.Font = Enum.Font.GothamMedium btn.Text = "  " .. text btn.TextColor3 = Colors.Text btn.TextSize = 14 btn.TextXAlignment = Enum.TextXAlignment.Left
            local scrollArea = Instance.new("ScrollingFrame") scrollArea.Parent = frame scrollArea.BackgroundTransparency = 1 scrollArea.Position = UDim2.new(0, 10, 0, 50) scrollArea.Size = UDim2.new(1, -20, 1, -55) scrollArea.ScrollBarThickness = 2 scrollArea.CanvasSize = UDim2.new(0, 0, 0, #options * (itemHeight + 2))
            local list = Instance.new("UIListLayout") list.Parent = scrollArea list.Padding = UDim.new(0, 2)
            for i, opt in pairs(options) do
                local optBtn = Instance.new("TextButton") optBtn.Parent = scrollArea optBtn.BackgroundColor3 = Colors.Sidebar optBtn.Size = UDim2.new(1, -10, 0, itemHeight) optBtn.Font = Enum.Font.Gotham optBtn.Text = "  " .. opt optBtn.TextColor3 = Colors.DarkText optBtn.TextSize = 13 optBtn.TextXAlignment = Enum.TextXAlignment.Left Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
                optBtn.MouseButton1Click:Connect(function() callback(opt) expanded = false tween(frame, {0.4}, {Size = UDim2.new(1, -10, 0, 45)}) end)
            end
            btn.MouseButton1Click:Connect(function() expanded = not expanded local th = math.min(#options, 4) * (itemHeight + 2) tween(frame, {0.4}, {Size = expanded and UDim2.new(1, -10, 0, 50 + th) or UDim2.new(1, -10, 0, 45)}) end)
        end

        function tab:CreateTextbox(text, placeholder, callback)
            local frame = Instance.new("Frame") frame.Parent = TabContent frame.BackgroundColor3 = Colors.ElementBg frame.Size = UDim2.new(1, -10, 0, 45) Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local box = Instance.new("TextBox") box.Parent = frame box.BackgroundColor3 = Colors.Sidebar box.Position = UDim2.new(1, -165, 0.5, -15) box.Size = UDim2.new(0, 150, 0, 30) box.Font = Enum.Font.Gotham box.PlaceholderText = placeholder box.Text = "" box.TextColor3 = Colors.Text box.TextSize = 13 Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
            box.FocusLost:Connect(function() callback(box.Text) end)
        end

        return tab
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == ToggleKey then
            local state = not MainContainer.Visible
            MainContainer.Visible = state Watermark.Visible = not state
            playSound("rbxassetid://6895079853", state and 0.8 or 1.2, 0.4)
        end
    end)
    return window
end


-- ==========================================
-- 2. YOUR SCRIPT USING THE LIBRARY
-- ==========================================

-- Initialize the main window
local Window = library:CreateWindow({
    Title = "Project X", 
    Watermark = "Project X | {time} | {game} | v1.0", 
    ToggleKey = Enum.KeyCode.Delete 
})

-- Send a startup notification
Window:Notify("System Hooked", "Welcome to Project X. Press Delete to toggle menu.", "success", 5)


-- ==========================================
-- COMBAT TAB
-- ==========================================
local CombatTab = Window:CreateTab("Combat")

CombatTab:CreateToggle("Enable Aimbot", function(state)
    if state then
        print("Aimbot ON")
        Window:Notify("Combat", "Aimbot enabled.", "info", 3)
    else
        print("Aimbot OFF")
    end
end)

CombatTab:CreateDropdown("Target Part", {"Head", "Torso", "Random", "Closest"}, function(selectedOption)
    print("Aimbot now targeting:", selectedOption)
end)

CombatTab:CreateSlider("Aimbot Smoothing", 1, 10, 5, function(value)
    print("Smoothing set to:", value)
end)


-- ==========================================
-- VISUALS TAB
-- ==========================================
local VisualsTab = Window:CreateTab("Visuals")

VisualsTab:CreateToggle("Player ESP", function(state)
    -- Put your ESP logic here
end)

VisualsTab:CreateSlider("Max Render Distance", 50, 5000, 1000, function(value)
    print("ESP Distance:", value)
end)


-- ==========================================
-- SETTINGS TAB
-- ==========================================
local SettingsTab = Window:CreateTab("Settings")

SettingsTab:CreateTextbox("Target Player Name", "Username...", function(text)
    print("Target set to:", text)
    Window:Notify("Target Updated", "Locked onto: " .. text, "warn", 3)
end)

SettingsTab:CreateButton("Unload Menu", function()
    if game:GetService("CoreGui"):FindFirstChild("YnxdllLib") then
        game:GetService("CoreGui").YnxdllLib:Destroy()
        print("Menu destroyed.")
    end
end)
