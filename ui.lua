--[[
    ynxdll - Custom UI Library
    Toggle: Delete Key
    Theme: Matte Black + Soft Teal Accent
]]
-- NOTE: All strings kept ASCII-safe for executor compatibility

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService = game:GetService("TextService")

if _G.ynxdll_cleanup then
    pcall(_G.ynxdll_cleanup)
end

local destroying = false
local connections = {}

_G.ynxdll_cleanup = function()
    destroying = true
    for _, c in pairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    if _G.ynxdll_gui then pcall(function() _G.ynxdll_gui:Destroy() end) end
    if _G.ynxdll_blur then pcall(function() _G.ynxdll_blur:Destroy() end) end
end

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme
local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(24, 24, 30),
    SurfaceLight = Color3.fromRGB(32, 32, 40),
    Accent = Color3.fromRGB(160, 130, 220),
    AccentDim = Color3.fromRGB(120, 95, 175),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(140, 140, 155),
    Border = Color3.fromRGB(45, 45, 55),
    Danger = Color3.fromRGB(220, 60, 60),
    Success = Color3.fromRGB(60, 200, 120),
    Warning = Color3.fromRGB(220, 180, 50),
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontLight = Enum.Font.Gotham,
}

-- Tween helper
local function tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Blur
local blur = Instance.new("BlurEffect")
blur.Name = "ynxdll_blur"
blur.Size = 0
blur.Parent = Lighting
_G.ynxdll_blur = blur

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ynxdll"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 2147483647
ScreenGui.IgnoreGuiInset = true
_G.ynxdll_gui = ScreenGui

-- Try syn.protect_gui or fallback
pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- State
local menuOpen = false
local currentTab = nil
local tabs = {}
local tabButtons = {}
local toggleKeyCode = Enum.KeyCode.Delete

local function playClick()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://6895079853"
    s.Volume = 0.5
    s.Parent = ScreenGui
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

local function playType()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://6895079853"
    s.PlaybackSpeed = 1.2 + (math.random() * 0.2)
    s.Volume = 0.3
    s.Parent = ScreenGui
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

local function popAnim(obj)
    local scale = obj:FindFirstChild("UIScale")
    if not scale then
        scale = Instance.new("UIScale")
        scale.Parent = obj
    end
    scale.Scale = 0.92
    tween(scale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- -----------------------------------------------------------
-- WATERMARK
-- -----------------------------------------------------------

local Watermark = Instance.new("Frame")
Watermark.Name = "Watermark"
Watermark.Size = UDim2.new(0, 300, 0, 28)
Watermark.AnchorPoint = Vector2.new(0.5, 0)
Watermark.Position = UDim2.new(0.5, 0, 0, 15)
Watermark.BackgroundColor3 = Theme.Surface
Watermark.BorderSizePixel = 0
Watermark.Parent = ScreenGui

local WatermarkCorner = Instance.new("UICorner")
WatermarkCorner.CornerRadius = UDim.new(0, 6)
WatermarkCorner.Parent = Watermark

local WatermarkShadow = Instance.new("ImageLabel")
WatermarkShadow.Name = "Shadow"
WatermarkShadow.Size = UDim2.new(1, 40, 1, 40)
WatermarkShadow.Position = UDim2.new(0, -20, 0, -20)
WatermarkShadow.BackgroundTransparency = 1
WatermarkShadow.Image = "rbxassetid://6014261993"
WatermarkShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
WatermarkShadow.ImageTransparency = 0.5
WatermarkShadow.ScaleType = Enum.ScaleType.Slice
WatermarkShadow.SliceCenter = Rect.new(49, 49, 450, 450)
WatermarkShadow.ZIndex = -1
WatermarkShadow.Parent = Watermark

local WatermarkStroke = Instance.new("UIStroke")
WatermarkStroke.Color = Theme.Border
WatermarkStroke.Thickness = 1
WatermarkStroke.Parent = Watermark

local WatermarkLine = Instance.new("Frame")
WatermarkLine.Name = "AccentLine"
WatermarkLine.Size = UDim2.new(1, 0, 0, 1)
WatermarkLine.Position = UDim2.new(0, 0, 0, 0)
WatermarkLine.BackgroundColor3 = Theme.Accent
WatermarkLine.BorderSizePixel = 0
WatermarkLine.Parent = Watermark

local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Size = UDim2.new(1, 0, 1, 0)
WatermarkLabel.Position = UDim2.new(0, 0, 0, 0)
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.RichText = true
WatermarkLabel.Text = "ynxdll | Loading..."
WatermarkLabel.TextColor3 = Theme.Text
WatermarkLabel.TextSize = 13
WatermarkLabel.Font = Theme.Font
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Center
WatermarkLabel.Parent = Watermark

local gameName = "Unknown Game"
task.spawn(function()
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info and info.Name then
            gameName = info.Name
        end
    end)
end)

task.spawn(function()
    while task.wait(1) do
        if destroying then break end
        local t = os.date("*t")
        local ampm = t.hour >= 12 and "PM" or "AM"
        local h = t.hour % 12
        if h == 0 then h = 12 end
        local m = string.format("%02d", t.min)
        local timeStr = string.format("%d:%s %s", h, m, ampm)
        
        local hexAccent = string.format("#%02X%02X%02X", Theme.Accent.R*255, Theme.Accent.G*255, Theme.Accent.B*255)
        local hexDim = string.format("#%02X%02X%02X", Theme.Border.R*255, Theme.Border.G*255, Theme.Border.B*255)
        
        WatermarkLabel.Text = string.format('<b><font color="%s">ynxdll</font></b> <font color="%s">|</font> <b>%s</b> <font color="%s">|</font> %s', hexAccent, hexDim, timeStr, hexDim, gameName)
        
        local rawText = string.format("ynxdll | %s | %s", timeStr, gameName)
        local bounds = TextService:GetTextSize(rawText, WatermarkLabel.TextSize, WatermarkLabel.FontBold, Vector2.new(9999, 28))
        tween(Watermark, {Size = UDim2.new(0, bounds.X + 32, 0, 28)}, 0.2)
    end
end)

-- -----------------------------------------------------------
-- NOTIFICATIONS
-- -----------------------------------------------------------

local NotifyFrame = Instance.new("Frame")
NotifyFrame.Name = "NotifyFrame"
NotifyFrame.Size = UDim2.new(0, 260, 1, 0)
NotifyFrame.Position = UDim2.new(1, -270, 0, 0)
NotifyFrame.BackgroundTransparency = 1
NotifyFrame.Parent = ScreenGui

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.Padding = UDim.new(0, 10)
NotifyLayout.Parent = NotifyFrame

local NotifyPadding = Instance.new("UIPadding")
NotifyPadding.PaddingBottom = UDim.new(0, 20)
NotifyPadding.Parent = NotifyFrame

local function Notify(title, text, style, duration)
    local color = Theme.Accent
    if style == "Warning" then color = Theme.Warning end
    if style == "Error" then color = Theme.Danger end

    local note = Instance.new("Frame")
    note.Size = UDim2.new(1, 0, 0, 65)
    note.BackgroundColor3 = Theme.Surface
    note.BorderSizePixel = 0
    note.BackgroundTransparency = 1
    note.Parent = NotifyFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = note

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = note

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 20)
    titleLbl.Position = UDim2.new(0, 10, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = color
    titleLbl.TextSize = 13
    titleLbl.Font = Theme.FontBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTransparency = 1
    titleLbl.Parent = note

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -20, 0, 30)
    descLbl.Position = UDim2.new(0, 10, 0, 28)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = text
    descLbl.TextColor3 = Theme.Text
    descLbl.TextSize = 12
    descLbl.Font = Theme.Font
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextYAlignment = Enum.TextYAlignment.Top
    descLbl.TextTransparency = 1
    descLbl.TextWrapped = true
    descLbl.Parent = note

    note.Position = UDim2.new(1, 50, 0, 0)
    tween(note, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween(stroke, {Transparency = 0.5}, 0.4)
    tween(titleLbl, {TextTransparency = 0}, 0.4)
    tween(descLbl, {TextTransparency = 0}, 0.4)

    playClick()

    task.delay(duration or 4, function()
        tween(note, {BackgroundTransparency = 1, Position = UDim2.new(1, 50, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(stroke, {Transparency = 1}, 0.4)
        tween(titleLbl, {TextTransparency = 1}, 0.4)
        tween(descLbl, {TextTransparency = 1}, 0.4)
        task.delay(0.4, function() note:Destroy() end)
    end)
end

-- -----------------------------------------------------------
-- MAIN FRAME
-- -----------------------------------------------------------

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

-- -----------------------------------------------------------
-- TITLE BAR
-- -----------------------------------------------------------

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Theme.Surface
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Bottom cover for title bar rounded corners
local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0, 12)
TitleCover.Position = UDim2.new(0, 0, 1, -12)
TitleCover.BackgroundColor3 = Theme.Surface
TitleCover.BorderSizePixel = 0
TitleCover.Parent = TitleBar

local TitleIcon = Instance.new("ImageLabel")
TitleIcon.Name = "TitleIcon"
TitleIcon.Size = UDim2.new(0, 18, 0, 18)
TitleIcon.Position = UDim2.new(0, 12, 0.5, -9)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image = "rbxassetid://7733911828"
TitleIcon.ImageColor3 = Theme.Accent
TitleIcon.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 36, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ynxdll"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.TextSize = 16
TitleLabel.Font = Theme.FontBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "Version"
VersionLabel.Size = UDim2.new(0, 60, 1, 0)
VersionLabel.Position = UDim2.new(0, 95, 0, 1)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v1.0"
VersionLabel.TextColor3 = Theme.TextDim
VersionLabel.TextSize = 11
VersionLabel.Font = Theme.FontLight
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.Parent = TitleBar

local UserLabel = Instance.new("TextLabel")
UserLabel.Name = "UserLabel"
UserLabel.Size = UDim2.new(0, 150, 1, 0)
UserLabel.Position = UDim2.new(1, -165, 0, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = Player.DisplayName
UserLabel.TextColor3 = Theme.TextDim
UserLabel.TextSize = 12
UserLabel.Font = Theme.Font
UserLabel.TextXAlignment = Enum.TextXAlignment.Right
UserLabel.Parent = TitleBar

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Name = "StatsLabel"
StatsLabel.Size = UDim2.new(0, 200, 1, 0)
StatsLabel.AnchorPoint = Vector2.new(0.5, 0)
StatsLabel.Position = UDim2.new(0.5, 0, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "60 FPS | 12:00 PM"
StatsLabel.TextColor3 = Theme.TextDim
StatsLabel.TextSize = 11
StatsLabel.Font = Theme.Font
StatsLabel.TextXAlignment = Enum.TextXAlignment.Center
StatsLabel.Parent = TitleBar

task.spawn(function()
    local lastTime = tick()
    local frames = 0
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local current = tick()
        if current - lastTime >= 1 then
            local fps = math.floor(frames / (current - lastTime))
            local t = os.date("*t")
            local ampm = t.hour >= 12 and "PM" or "AM"
            local h = t.hour % 12
            if h == 0 then h = 12 end
            local m = string.format("%02d", t.min)
            StatsLabel.Text = string.format("%d FPS | %d:%s %s", fps, h, m, ampm)
            frames = 0
            lastTime = current
        end
    end)
end)

-- Accent line under title
local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 1)
AccentLine.Position = UDim2.new(0, 0, 1, 0)
AccentLine.BackgroundColor3 = Theme.Accent
AccentLine.BackgroundTransparency = 0.7
AccentLine.BorderSizePixel = 0
AccentLine.Parent = TitleBar



-- -----------------------------------------------------------
-- TAB SIDEBAR
-- -----------------------------------------------------------

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = Theme.Surface
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local SidebarCoverTop = Instance.new("Frame")
SidebarCoverTop.Size = UDim2.new(1, 0, 0, 12)
SidebarCoverTop.BackgroundColor3 = Theme.Surface
SidebarCoverTop.BorderSizePixel = 0
SidebarCoverTop.Parent = Sidebar

local SidebarCoverRight = Instance.new("Frame")
SidebarCoverRight.Size = UDim2.new(0, 12, 1, 0)
SidebarCoverRight.Position = UDim2.new(1, -12, 0, 0)
SidebarCoverRight.BackgroundColor3 = Theme.Surface
SidebarCoverRight.BorderSizePixel = 0
SidebarCoverRight.Parent = Sidebar

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
SidebarDivider.BackgroundColor3 = Theme.Border
SidebarDivider.BackgroundTransparency = 0.5
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

local TabList = Instance.new("Frame")
TabList.Name = "TabList"
TabList.Size = UDim2.new(1, -10, 1, -16)
TabList.Position = UDim2.new(0, 5, 0, 8)
TabList.BackgroundTransparency = 1
TabList.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 3)
TabListLayout.Parent = TabList

-- -----------------------------------------------------------
-- CONTENT AREA
-- -----------------------------------------------------------

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -131, 1, -39)
ContentArea.Position = UDim2.new(0, 131, 0, 39)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainFrame

-- -----------------------------------------------------------
-- UI ELEMENT CREATORS
-- -----------------------------------------------------------

local function createScrollFrame(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -16, 1, -8)
    scroll.Position = UDim2.new(0, 8, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.AccentDim
    scroll.ScrollBarImageTransparency = 0.3
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 6)
    padding.Parent = scroll

    return scroll
end

-- Section Header
local function createSection(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = string.upper(text)
    label.TextColor3 = Theme.AccentDim
    label.TextSize = 10
    label.Font = Theme.FontBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = Theme.Border
    line.BackgroundTransparency = 0.6
    line.BorderSizePixel = 0
    line.Parent = frame

    return frame
end

-- Toggle
local function createToggle(parent, text, default, callback)
    local state = default or false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Theme.SurfaceLight
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 13
    label.Font = Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 38, 0, 20)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBg.BackgroundColor3 = state and Theme.Accent or Theme.Border
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function update()
        tween(toggleBg, {BackgroundColor3 = state and Theme.Accent or Theme.Border}, 0.2)
        tween(knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
    end

    -- Hover
    frame.MouseEnter:Connect(function()
        tween(frame, {BackgroundColor3 = Theme.Border}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        tween(frame, {BackgroundColor3 = Theme.SurfaceLight}, 0.15)
    end)

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            playClick()
            popAnim(frame)
            update()
            if callback then pcall(callback, state) end
        end
    end)

    return {frame = frame, setState = function(v) state = v; update() end, getState = function() return state end}
end

-- Slider
local function createSlider(parent, text, min, max, default, callback)
    local value = default or min

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Theme.SurfaceLight
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 13
    label.Font = Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 50, 0, 20)
    valLabel.Position = UDim2.new(1, -58, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(math.floor(value))
    valLabel.TextColor3 = Theme.Accent
    valLabel.TextSize = 12
    valLabel.Font = Theme.FontBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 34)
    sliderBg.BackgroundColor3 = Theme.Border
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = sliderBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- Hover
    frame.MouseEnter:Connect(function()
        tween(frame, {BackgroundColor3 = Theme.Border}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        tween(frame, {BackgroundColor3 = Theme.SurfaceLight}, 0.15)
    end)

    local sliding = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            playClick()
            popAnim(frame)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
            valLabel.Text = tostring(value)
            if callback then pcall(callback, value) end
        end
    end)

    return {frame = frame, getValue = function() return value end}
end

-- Button
local function createButton(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = color or Theme.SurfaceLight
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.TextSize = 13
    btn.Font = Theme.Font
    btn.AutoButtonColor = false
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Theme.Border}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = color or Theme.SurfaceLight}, 0.15)
    end)

    btn.MouseButton1Click:Connect(function()
        playClick()
        popAnim(btn)
        tween(btn, {BackgroundColor3 = Theme.Accent}, 0.08)
        task.wait(0.1)
        tween(btn, {BackgroundColor3 = color or Theme.SurfaceLight}, 0.15)
        if callback then pcall(callback) end
    end)

    return btn
end

-- Dropdown
local function createDropdown(parent, text, options, default, callback)
    local selected = default or options[1]
    local open = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Theme.SurfaceLight
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -8, 0, 36)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 13
    label.Font = Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(0.5, -20, 0, 36)
    selectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = selected .. "  v"
    selectedLabel.TextColor3 = Theme.Accent
    selectedLabel.TextSize = 12
    selectedLabel.Font = Theme.Font
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    selectedLabel.Parent = frame

    local optionFrames = {}
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, -16, 0, 28)
        optBtn.Position = UDim2.new(0, 8, 0, 36 + (i - 1) * 30)
        optBtn.BackgroundColor3 = (opt == selected) and Theme.AccentDim or Theme.Background
        optBtn.BorderSizePixel = 0
        optBtn.Text = opt
        optBtn.TextColor3 = Theme.Text
        optBtn.TextSize = 12
        optBtn.Font = Theme.Font
        optBtn.AutoButtonColor = false
        optBtn.Parent = frame

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn

        optBtn.MouseEnter:Connect(function()
            if opt ~= selected then tween(optBtn, {BackgroundColor3 = Theme.SurfaceLight}, 0.1) end
        end)
        optBtn.MouseLeave:Connect(function()
            if opt ~= selected then tween(optBtn, {BackgroundColor3 = Theme.Background}, 0.1) end
        end)

        optBtn.MouseButton1Click:Connect(function()
            playClick()
            selected = opt
            selectedLabel.Text = selected .. "  v"
            for _, of in ipairs(optionFrames) do
                tween(of.btn, {BackgroundColor3 = (of.opt == selected) and Theme.AccentDim or Theme.Background}, 0.1)
            end
            -- close
            open = false
            tween(frame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
            if callback then pcall(callback, selected) end
        end)

        table.insert(optionFrames, {btn = optBtn, opt = opt})
    end

    -- Toggle dropdown
    local clickRegion = Instance.new("TextButton")
    clickRegion.Size = UDim2.new(1, 0, 0, 36)
    clickRegion.BackgroundTransparency = 1
    clickRegion.Text = ""
    clickRegion.Parent = frame

    clickRegion.MouseButton1Click:Connect(function()
        playClick()
        popAnim(frame)
        open = not open
        local targetHeight = open and (36 + #options * 30 + 6) or 36
        tween(frame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
    end)

    -- Hover on main area
    frame.MouseEnter:Connect(function()
        if not open then tween(frame, {BackgroundColor3 = Theme.Border}, 0.15) end
    end)
    frame.MouseLeave:Connect(function()
        if not open then tween(frame, {BackgroundColor3 = Theme.SurfaceLight}, 0.15) end
    end)

    return {frame = frame, getSelected = function() return selected end}
end

-- Keybind
local function createKeybind(parent, text, default, callback)
    local key = default or Enum.KeyCode.Unknown
    local listening = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Theme.SurfaceLight
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 13
    label.Font = Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 70, 0, 24)
    bindBtn.Position = UDim2.new(1, -80, 0.5, -12)
    bindBtn.BackgroundColor3 = Theme.Background
    bindBtn.BorderSizePixel = 0
    bindBtn.Text = key.Name
    bindBtn.TextColor3 = Theme.Accent
    bindBtn.TextSize = 11
    bindBtn.Font = Theme.Font
    bindBtn.AutoButtonColor = false
    bindBtn.Parent = frame

    local bindCorner = Instance.new("UICorner")
    bindCorner.CornerRadius = UDim.new(0, 4)
    bindCorner.Parent = bindBtn

    bindBtn.MouseButton1Click:Connect(function()
        playClick()
        popAnim(frame)
        listening = true
        bindBtn.Text = "..."
        tween(bindBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
        tween(bindBtn, {TextColor3 = Theme.Background}, 0.15)
    end)

    UserInputService.InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            key = input.KeyCode
            listening = false
            bindBtn.Text = key.Name
            tween(bindBtn, {BackgroundColor3 = Theme.Background}, 0.15)
            tween(bindBtn, {TextColor3 = Theme.Accent}, 0.15)
            if callback then pcall(callback, key) end
        end
    end)

    -- Hover
    frame.MouseEnter:Connect(function()
        tween(frame, {BackgroundColor3 = Theme.Border}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        tween(frame, {BackgroundColor3 = Theme.SurfaceLight}, 0.15)
    end)

    return {frame = frame, getKey = function() return key end}
end

-- Text Input
local function createTextInput(parent, text, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Theme.SurfaceLight
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, -8, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 13
    label.Font = Theme.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.55, -8, 0, 26)
    inputBox.Position = UDim2.new(0.43, 0, 0.5, -13)
    inputBox.BackgroundColor3 = Theme.Background
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.PlaceholderText = placeholder or ""
    inputBox.PlaceholderColor3 = Theme.TextDim
    inputBox.TextColor3 = Theme.Text
    inputBox.TextSize = 12
    inputBox.Font = Theme.Font
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = frame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = inputBox

    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 8)
    inputPadding.PaddingRight = UDim.new(0, 8)
    inputPadding.Parent = inputBox

    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        playType()
    end)

    inputBox.FocusLost:Connect(function(enter)
        if enter and callback then pcall(callback, inputBox.Text) end
    end)

    -- Hover
    frame.MouseEnter:Connect(function()
        tween(frame, {BackgroundColor3 = Theme.Border}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        tween(frame, {BackgroundColor3 = Theme.SurfaceLight}, 0.15)
    end)

    return {frame = frame, getText = function() return inputBox.Text end}
end

-- Label / Info
local function createLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.TextDim
    label.TextSize = 11
    label.Font = Theme.FontLight
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

-- -----------------------------------------------------------
-- TAB SYSTEM
-- -----------------------------------------------------------

local function createTab(name, iconId)
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = name
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false
    tabFrame.Parent = ContentArea

    local scroll = createScrollFrame(tabFrame)

    -- Tab button in sidebar
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.BackgroundColor3 = Theme.Surface
    tabBtn.BackgroundTransparency = 1
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = Theme.TextDim
    tabBtn.TextSize = 12
    tabBtn.Font = Theme.Font
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = TabList

    local tabIcon = Instance.new("ImageLabel")
    tabIcon.Size = UDim2.new(0, 14, 0, 14)
    tabIcon.Position = UDim2.new(0, -20, 0.5, -7)
    tabIcon.BackgroundTransparency = 1
    tabIcon.Image = iconId or ""
    tabIcon.ImageColor3 = Theme.TextDim
    tabIcon.Parent = tabBtn

    local tabBtnCorner = Instance.new("UICorner")
    tabBtnCorner.CornerRadius = UDim.new(0, 6)
    tabBtnCorner.Parent = tabBtn

    local tabBtnPadding = Instance.new("UIPadding")
    tabBtnPadding.PaddingLeft = UDim.new(0, 32)
    tabBtnPadding.Parent = tabBtn

    -- Active indicator
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, -29, 0.2, 0)
    indicator.BackgroundColor3 = Theme.Accent
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = tabBtn

    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 2)
    indicatorCorner.Parent = indicator

    tabBtn.MouseEnter:Connect(function()
        if currentTab ~= name then
            tween(tabBtn, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.SurfaceLight}, 0.15)
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if currentTab ~= name then
            tween(tabBtn, {BackgroundTransparency = 1}, 0.15)
        end
    end)

    tabBtn.MouseButton1Click:Connect(function()
        playClick()
        popAnim(tabBtn)
        -- Deselect all
        for tName, tData in pairs(tabs) do
            tData.frame.Visible = false
            tween(tData.button, {BackgroundTransparency = 1, TextColor3 = Theme.TextDim}, 0.15)
            if tData.icon then tween(tData.icon, {ImageColor3 = Theme.TextDim}, 0.15) end
            tween(tData.indicator, {BackgroundTransparency = 1}, 0.15)
        end
        -- Select this
        tabFrame.Visible = true
        currentTab = name
        tween(tabBtn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceLight, TextColor3 = Theme.Text}, 0.15)
        tween(tabIcon, {ImageColor3 = Theme.Accent}, 0.15)
        tween(indicator, {BackgroundTransparency = 0}, 0.15)
    end)

    tabs[name] = {frame = tabFrame, scroll = scroll, button = tabBtn, indicator = indicator, icon = tabIcon}
    return scroll
end

local function selectTab(name)
    local data = tabs[name]
    if not data then return end
    -- Deselect all
    for tName, tData in pairs(tabs) do
        tData.frame.Visible = false
        tween(tData.button, {BackgroundTransparency = 1, TextColor3 = Theme.TextDim}, 0.15)
        if tData.icon then tween(tData.icon, {ImageColor3 = Theme.TextDim}, 0.15) end
        tween(tData.indicator, {BackgroundTransparency = 1}, 0.15)
    end
    -- Select target
    data.frame.Visible = true
    currentTab = name
    tween(data.button, {BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceLight, TextColor3 = Theme.Text}, 0.15)
    if data.icon then tween(data.icon, {ImageColor3 = Theme.Accent}, 0.15) end
    tween(data.indicator, {BackgroundTransparency = 0}, 0.15)
end

local function updateTabSizes()
    local count = 0
    for _ in pairs(tabs) do count = count + 1 end
    if count == 0 then return end
    local padding = 3
    local totalPadding = (count - 1) * padding
    for _, tData in pairs(tabs) do
        tData.button.Size = UDim2.new(1, 0, 1/count, -(totalPadding/count))
    end
end

-- -----------------------------------------------------------
-- SELECT DEFAULT TAB
-- -----------------------------------------------------------

updateTabSizes()
selectTab("Main")

-- -----------------------------------------------------------
-- TOGGLE MENU (DELETE KEY)
-- -----------------------------------------------------------

local lastToggle = 0
local function toggleMenu()
    if destroying then return end
    if tick() - lastToggle < 0.4 then return end
    lastToggle = tick()
    
    menuOpen = not menuOpen

    if menuOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 580, 0, 10)
        MainFrame.BackgroundTransparency = 1
        tween(MainFrame, {Size = UDim2.new(0, 580, 0, 420), BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Back)
        tween(blur, {Size = 20}, 0.3)
    else
        tween(MainFrame, {Size = UDim2.new(0, 580, 0, 10), BackgroundTransparency = 1}, 0.25)
        tween(blur, {Size = 0}, 0.25)
        task.delay(0.26, function()
            if not menuOpen then
                MainFrame.Visible = false
            end
        end)
    end
end

local inputConn = UserInputService.InputBegan:Connect(function(input, processed)
    if destroying then return end
    -- Ignoring 'processed' allows you to close the menu even if you clicked inside a text box or somewhere else
    if input.KeyCode == toggleKeyCode then
        toggleMenu()
    end
end)
table.insert(connections, inputConn)

-- -----------------------------------------------------------
-- LOADING SCREEN
-- -----------------------------------------------------------

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(0, 320, 0, 80)
LoadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingFrame.BackgroundColor3 = Theme.Background
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ScreenGui

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 8)
LoadingCorner.Parent = LoadingFrame

local LoadingStroke = Instance.new("UIStroke")
LoadingStroke.Color = Theme.Border
LoadingStroke.Thickness = 1
LoadingStroke.Parent = LoadingFrame

local LoadingShadow = Instance.new("ImageLabel")
LoadingShadow.Size = UDim2.new(1, 40, 1, 40)
LoadingShadow.Position = UDim2.new(0, -20, 0, -20)
LoadingShadow.BackgroundTransparency = 1
LoadingShadow.Image = "rbxassetid://6014261993"
LoadingShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
LoadingShadow.ImageTransparency = 0.5
LoadingShadow.ScaleType = Enum.ScaleType.Slice
LoadingShadow.SliceCenter = Rect.new(49, 49, 450, 450)
LoadingShadow.ZIndex = -1
LoadingShadow.Parent = LoadingFrame

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(1, 0, 0, 30)
LoadingTitle.Position = UDim2.new(0, 0, 0, 10)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "ynxdll"
LoadingTitle.TextColor3 = Theme.Accent
LoadingTitle.TextSize = 18
LoadingTitle.Font = Theme.FontBold
LoadingTitle.Parent = LoadingFrame

local LoadingStatus = Instance.new("TextLabel")
LoadingStatus.Size = UDim2.new(1, 0, 0, 20)
LoadingStatus.Position = UDim2.new(0, 0, 0, 35)
LoadingStatus.BackgroundTransparency = 1
LoadingStatus.Text = "Initializing..."
LoadingStatus.TextColor3 = Theme.TextDim
LoadingStatus.TextSize = 12
LoadingStatus.Font = Theme.Font
LoadingStatus.Parent = LoadingFrame

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(1, -40, 0, 6)
BarBg.Position = UDim2.new(0, 20, 0, 62)
BarBg.BackgroundColor3 = Theme.Surface
BarBg.BorderSizePixel = 0
BarBg.Parent = LoadingFrame
local BarBgCorner = Instance.new("UICorner")
BarBgCorner.CornerRadius = UDim.new(1, 0)
BarBgCorner.Parent = BarBg

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Theme.Accent
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg
local BarFillCorner = Instance.new("UICorner")
BarFillCorner.CornerRadius = UDim.new(1, 0)
BarFillCorner.Parent = BarFill

task.spawn(function()
    local steps = {
        "Initializing environment...",
        "Bypassing anticheat...",
        "Loading UI modules...",
        "Fetching user data...",
        "Ready."
    }
    
    for i, step in ipairs(steps) do
        LoadingStatus.Text = step
        tween(BarFill, {Size = UDim2.new(i / #steps, 0, 1, 0)}, 0.4)
        task.wait(0.4 + math.random() * 0.4)
    end
    
    task.wait(0.3)
    tween(LoadingFrame, {BackgroundTransparency = 1}, 0.5)
    tween(LoadingTitle, {TextTransparency = 1}, 0.5)
    tween(LoadingStatus, {TextTransparency = 1}, 0.5)
    tween(BarBg, {BackgroundTransparency = 1}, 0.5)
    tween(BarFill, {BackgroundTransparency = 1}, 0.5)
    tween(LoadingStroke, {Transparency = 1}, 0.5)
    tween(LoadingShadow, {ImageTransparency = 1}, 0.5)
    
    task.wait(0.5)
    LoadingFrame:Destroy()
    
    toggleMenu()
    task.wait(0.3)
    Notify("ynxdll loaded", "Press your toggle key to open or close the menu at any time.", "Info", 5)
end)

-- ========================================================================= --
-- USER CONFIGURATION / TABS (EDIT BELOW THIS LINE)
-- ========================================================================= --

-- -----------------------------------------------------------
-- BUILD TABS
-- -----------------------------------------------------------

-- > MAIN
local mainScroll = createTab("Main", "rbxassetid://7733674079")
createSection(mainScroll, "General")
createToggle(mainScroll, "Anti-AFK", false, function(v) end)
createToggle(mainScroll, "Auto Rejoin", false, function(v) end)
createToggle(mainScroll, "Infinite Yield", false, function(v) end)
createButton(mainScroll, "Rejoin Server", nil, function() end)
createButton(mainScroll, "Server Hop", nil, function() end)
createSection(mainScroll, "Scripts")
createTextInput(mainScroll, "Execute", "paste script...", function(v) end)
createButton(mainScroll, "Execute Clipboard", Theme.AccentDim, function() end)

-- > PLAYER
local playerScroll = createTab("Player", "rbxassetid://7733765045")
createSection(playerScroll, "Movement")
createSlider(playerScroll, "WalkSpeed", 0, 500, 16, function(v) end)
createSlider(playerScroll, "JumpPower", 0, 500, 50, function(v) end)
createToggle(playerScroll, "Infinite Jump", false, function(v) end)
createToggle(playerScroll, "Noclip", false, function(v) end)
createToggle(playerScroll, "Fly", false, function(v) end)
createSlider(playerScroll, "Fly Speed", 0, 500, 50, function(v) end)
createSection(playerScroll, "Gravity")
createSlider(playerScroll, "Gravity", 0, 500, 196, function(v) end)
createDropdown(playerScroll, "Teleport To", {"Spawn", "Random Player", "Waypoint 1", "Waypoint 2"}, "Spawn", function(v) end)
createButton(playerScroll, "Reset Character", Theme.Warning, function() end)

-- > VISUALS
local visualScroll = createTab("Visuals", "rbxassetid://7733774602")
createSection(visualScroll, "ESP")
createToggle(visualScroll, "Player ESP", false, function(v) end)
createToggle(visualScroll, "Box ESP", false, function(v) end)
createToggle(visualScroll, "Name ESP", false, function(v) end)
createToggle(visualScroll, "Health Bar", false, function(v) end)
createToggle(visualScroll, "Distance ESP", false, function(v) end)
createToggle(visualScroll, "Tracers", false, function(v) end)
createSection(visualScroll, "Chams")
createToggle(visualScroll, "Player Chams", false, function(v) end)
createSlider(visualScroll, "Chams Transparency", 0, 100, 50, function(v) end)
createDropdown(visualScroll, "Cham Color", {"Team Color", "Red", "Cyan", "Green", "Custom"}, "Team Color", function(v) end)
createSection(visualScroll, "World")
createToggle(visualScroll, "Fullbright", false, function(v) end)
createSlider(visualScroll, "FOV", 30, 120, 70, function(v) end)
createToggle(visualScroll, "No Fog", false, function(v) end)

-- > COMBAT
local combatScroll = createTab("Combat", "rbxassetid://7733971936")
createSection(combatScroll, "Aimbot")
createToggle(combatScroll, "Aimbot Enabled", false, function(v) end)
createDropdown(combatScroll, "Target Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(v) end)
createSlider(combatScroll, "FOV Radius", 10, 500, 120, function(v) end)
createSlider(combatScroll, "Smoothness", 1, 50, 5, function(v) end)
createKeybind(combatScroll, "Aim Key", Enum.KeyCode.E, function(v) end)
createToggle(combatScroll, "Show FOV Circle", false, function(v) end)
createSection(combatScroll, "Misc Combat")
createToggle(combatScroll, "Kill Aura", false, function(v) end)
createSlider(combatScroll, "Aura Range", 1, 50, 15, function(v) end)
createToggle(combatScroll, "Auto Parry", false, function(v) end)

-- > MISC
local miscScroll = createTab("Misc", "rbxassetid://7733911828")
createSection(miscScroll, "Tools")
createButton(miscScroll, "Copy Game ID", nil, function() end)
createButton(miscScroll, "Copy Player List", nil, function() end)
createToggle(miscScroll, "Click TP", false, function(v) end)
createKeybind(miscScroll, "TP Key", Enum.KeyCode.T, function(v) end)
createSection(miscScroll, "Character")
createToggle(miscScroll, "God Mode (Client)", false, function(v) end)
createSlider(miscScroll, "Hitbox Expand", 1, 50, 5, function(v) end)
createToggle(miscScroll, "Anti-Void", false, function(v) end)
createSection(miscScroll, "Chat")
createToggle(miscScroll, "Chat Spam", false, function(v) end)
createTextInput(miscScroll, "Spam Msg", "enter message...", function(v) end)
createSlider(miscScroll, "Spam Delay", 1, 30, 5, function(v) end)

-- > SETTINGS
local settingsScroll = createTab("Settings", "rbxassetid://7734068321")
createSection(settingsScroll, "Menu")
createKeybind(settingsScroll, "Toggle Key", Enum.KeyCode.Delete, function(v)
    toggleKeyCode = v
end)
createSlider(settingsScroll, "Menu Opacity", 50, 100, 100, function(v)
    MainFrame.BackgroundTransparency = 1 - (v / 100)
end)
createDropdown(settingsScroll, "Accent Color", {"Purple", "Teal", "Blue", "Red", "Pink", "Green"}, "Purple", function(v)
    local colors = {
        Teal = Color3.fromRGB(0, 200, 180),
        Purple = Color3.fromRGB(160, 130, 220),
        Blue = Color3.fromRGB(60, 130, 255),
        Red = Color3.fromRGB(220, 70, 70),
        Pink = Color3.fromRGB(230, 100, 180),
        Green = Color3.fromRGB(60, 200, 120),
    }
    if colors[v] then
        Theme.Accent = colors[v]
        TitleLabel.TextColor3 = colors[v]
        AccentLine.BackgroundColor3 = colors[v]
        pcall(function()
            TitleBar.TitleIcon.ImageColor3 = colors[v]
        end)
        pcall(function()
            Watermark.AccentLine.BackgroundColor3 = colors[v]
        end)
    end
end)
createSection(settingsScroll, "Config")
createTextInput(settingsScroll, "Config Name", "my_config", function(v) end)
createButton(settingsScroll, "Save Config", Theme.AccentDim, function() end)
createButton(settingsScroll, "Load Config", nil, function() end)
createSection(settingsScroll, "Info")
createLabel(settingsScroll, "ynxdll v1.0 - made with luv")
createLabel(settingsScroll, "Game: " .. tostring(game.PlaceId))
createSection(settingsScroll, "Danger Zone")
createButton(settingsScroll, "[!] Destroy Menu", Theme.Danger, function()
    if destroying then return end
    destroying = true
    -- Animate out
    tween(MainFrame, {BackgroundTransparency = 1, Size = UDim2.new(0, 580, 0, 0)}, 0.4)
    tween(blur, {Size = 0}, 0.3)
    task.wait(0.45)
    blur:Destroy()
    ScreenGui:Destroy()
end)

-- > PLAYERS LIST
local playersListScroll = createTab("Players List", "rbxassetid://7733765045")
local playersTabFrame = playersListScroll.Parent

-- Submenu for player info
local infoScroll = createScrollFrame(playersTabFrame)
infoScroll.Visible = false

local selPlayer = nil
createButton(infoScroll, "< Back to List", Theme.SurfaceLight, function()
    infoScroll.Visible = false
    playersListScroll.Visible = true
    selPlayer = nil
end)
createSection(infoScroll, "Player Info")
local selNameLabel = createLabel(infoScroll, "Name: None")
local selDisplayLabel = createLabel(infoScroll, "DisplayName: None")
local selAgeLabel = createLabel(infoScroll, "Account Age: N/A")

createSection(infoScroll, "Actions")
createButton(infoScroll, "Spectate", Theme.Accent, function()
    if not selPlayer then return end
    Notify("Spectate", "Spectating " .. selPlayer.Name .. " (Coming Soon)", "Info", 3)
end)
createButton(infoScroll, "Fling", Theme.Danger, function()
    if not selPlayer then return end
    Notify("Fling", "Attempting to fling " .. selPlayer.Name .. " (Coming Soon)", "Warning", 3)
end)

-- Main list view
createSection(playersListScroll, "Player List")
createButton(playersListScroll, "[ Refresh List ]", Theme.SurfaceLight, function()
    refreshPlayers()
end)

local playerListContainer = Instance.new("Frame")
playerListContainer.Size = UDim2.new(1, 0, 0, 0)
playerListContainer.BackgroundTransparency = 1
playerListContainer.Parent = playersListScroll

local plLayout = Instance.new("UIListLayout")
plLayout.SortOrder = Enum.SortOrder.LayoutOrder
plLayout.Padding = UDim.new(0, 6)
plLayout.Parent = playerListContainer

plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playerListContainer.Size = UDim2.new(1, 0, 0, plLayout.AbsoluteContentSize.Y)
end)

local function getDistance(plr)
    if plr == Player then return 0 end
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return 9999 end
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return 9999 end
    return (Player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
end

function refreshPlayers()
    for _, child in ipairs(playerListContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local plrs = Players:GetPlayers()
    table.sort(plrs, function(a, b)
        return getDistance(a) < getDistance(b)
    end)
    
    for _, plr in ipairs(plrs) do
        local dist = getDistance(plr)
        local text = plr.Name
        if plr == Player then
            text = text .. " (You)"
        else
            text = text .. " (" .. math.floor(dist) .. " studs)"
        end
        
        createButton(playerListContainer, text, Theme.SurfaceLight, function()
            selPlayer = plr
            selNameLabel.Text = "Name: " .. plr.Name
            selDisplayLabel.Text = "DisplayName: " .. plr.DisplayName
            
            local age = plr.AccountAge
            local years = math.floor(age / 365)
            local months = math.floor((age % 365) / 30)
            local days = (age % 365) % 30
            local ageStr = ""
            if years > 0 then ageStr = ageStr .. years .. " Years, " end
            if months > 0 then ageStr = ageStr .. months .. " Months, " end
            ageStr = ageStr .. days .. " Days"
            
            selAgeLabel.Text = "Account Age: " .. ageStr
            
            playersListScroll.Visible = false
            infoScroll.Visible = true
        end)
    end
end

-- Initial populate
task.spawn(function()
    task.wait(1)
    pcall(refreshPlayers)
end)

-- > TEST
local testScroll = createTab("Test", "rbxassetid://7733964719")
createSection(testScroll, "Notifications")
createButton(testScroll, "Test Info", Theme.Accent, function()
    Notify("Info", "This is an info notification.", "Info", 3)
end)
createButton(testScroll, "Test Warning", Theme.Warning, function()
    Notify("Warning", "This is a warning notification.", "Warning", 3)
end)
createButton(testScroll, "Test Error", Theme.Danger, function()
    Notify("Error", "This is an error notification.", "Error", 3)
end)

-- -----------------------------------------------------------
-- SELECT DEFAULT TAB
-- -----------------------------------------------------------

updateTabSizes()
selectTab("Main")

