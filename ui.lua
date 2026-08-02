--[[\r
	ui-engine-v2 (Core Backend)\r
--]]
local Library = {}

function Library.Load(ui_options, buildFunc)
	ui_options = ui_options or {
		main_color = Color3.fromRGB(41, 74, 122),
		min_size = Vector2.new(400, 300),
		toggle_key = Enum.KeyCode.RightShift,
		can_resize = true,
	}

	do
		local imgui = game:GetService("CoreGui"):FindFirstChild("imgui")
		if imgui then imgui:Destroy() end
	end

	local imgui = Instance.new("ScreenGui")
	local Prefabs = Instance.new("Frame")
	local Label = Instance.new("TextLabel")
	local Window = Instance.new("ImageLabel")
	local Resizer = Instance.new("Frame")
	local Bar = Instance.new("Frame")
	local Toggle = Instance.new("ImageButton")
	local Base = Instance.new("ImageLabel")
	local Top = Instance.new("ImageLabel")
	local Tabs = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local TabSelection = Instance.new("ImageLabel")
	local TabButtons = Instance.new("Frame")
	local UIListLayout = Instance.new("UIListLayout")
	local Frame = Instance.new("Frame")
	local Tab = Instance.new("Frame")
	local UIListLayout_2 = Instance.new("UIListLayout")
	local TextBox = Instance.new("TextBox")
	local TextBox_Roundify_4px = Instance.new("ImageLabel")
	local Slider = Instance.new("ImageLabel")
	local Title_2 = Instance.new("TextLabel")
	local Indicator = Instance.new("ImageLabel")
	local Value = Instance.new("TextLabel")
	local TextLabel = Instance.new("TextLabel")
	local TextLabel_2 = Instance.new("TextLabel")
	local Circle = Instance.new("ImageLabel")
	local UIListLayout_3 = Instance.new("UIListLayout")
	local Dropdown = Instance.new("TextButton")
	local Indicator_2 = Instance.new("ImageLabel")
	local Box = Instance.new("ImageButton")
	local Objects = Instance.new("ScrollingFrame")
	local UIListLayout_4 = Instance.new("UIListLayout")
	local TextButton_Roundify_4px = Instance.new("ImageLabel")
	local TabButton = Instance.new("TextButton")
	local TextButton_Roundify_4px_2 = Instance.new("ImageLabel")
	local Folder = Instance.new("ImageLabel")
	local Button = Instance.new("TextButton")
	local TextButton_Roundify_4px_3 = Instance.new("ImageLabel")
	local Toggle_2 = Instance.new("ImageLabel")
	local Objects_2 = Instance.new("Frame")
	local UIListLayout_5 = Instance.new("UIListLayout")
	local HorizontalAlignment = Instance.new("Frame")
	local UIListLayout_6 = Instance.new("UIListLayout")
	local Console = Instance.new("ImageLabel")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local Source = Instance.new("TextBox")
	local Comments = Instance.new("TextLabel")
	local Globals = Instance.new("TextLabel")
	local Keywords = Instance.new("TextLabel")
	local RemoteHighlight = Instance.new("TextLabel")
	local Strings = Instance.new("TextLabel")
    local Tokens = Instance.new("TextLabel")
	local Numbers = Instance.new("TextLabel")
	local Info = Instance.new("TextLabel")
	local Lines = Instance.new("TextLabel")
	local ColorPicker = Instance.new("ImageLabel")
	local Palette = Instance.new("ImageLabel")
	local Indicator_3 = Instance.new("ImageLabel")
	local Sample = Instance.new("ImageLabel")
	local Saturation = Instance.new("ImageLabel")
	local Indicator_4 = Instance.new("Frame")
	local Switch = Instance.new("TextButton")
	local TextButton_Roundify_4px_4 = Instance.new("ImageLabel")
	local Title_3 = Instance.new("TextLabel")
	local Button_2 = Instance.new("TextButton")
	local TextButton_Roundify_4px_5 = Instance.new("ImageLabel")
	local DropdownButton = Instance.new("TextButton")
	local Keybind = Instance.new("ImageLabel")
	local Title_4 = Instance.new("TextLabel")
	local Input = Instance.new("TextButton")
	local Input_Roundify_4px = Instance.new("ImageLabel")
	local Windows = Instance.new("Frame")

	imgui.Name = "imgui"
	imgui.Parent = game:GetService("CoreGui")

	Prefabs.Name = "Prefabs"
	Prefabs.Parent = imgui
	Prefabs.BackgroundColor3 = Color3.new(1, 1, 1)
	Prefabs.Size = UDim2.new(0, 100, 0, 100)
	Prefabs.Visible = false

	Label.Name = "Label"
	Label.Parent = Prefabs
	Label.BackgroundColor3 = Color3.new(1, 1, 1)
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(0, 200, 0, 20)
	Label.Font = Enum.Font.GothamSemibold
	Label.Text = "Hello, world 123"
	Label.TextColor3 = Color3.new(1, 1, 1)
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left

	Window.Name = "Window"
	Window.Parent = Prefabs
	Window.Active = true
	Window.BackgroundColor3 = Color3.new(1, 1, 1)
	Window.BackgroundTransparency = 1
	Window.ClipsDescendants = true
	Window.Position = UDim2.new(0, 20, 0, 20)
	Window.Selectable = true
	Window.Size = UDim2.new(0, 200, 0, 200)
	Window.Image = "rbxassetid://2851926732"
	Window.ImageColor3 = Color3.new(0.0823529, 0.0862745, 0.0901961)
	Window.ScaleType = Enum.ScaleType.Slice
	Window.SliceCenter = Rect.new(12, 12, 12, 12)

	Resizer.Name = "Resizer"
	Resizer.Parent = Window
	Resizer.Active = true
	Resizer.BackgroundColor3 = Color3.new(1, 1, 1)
	Resizer.BackgroundTransparency = 1
	Resizer.BorderSizePixel = 0
	Resizer.Position = UDim2.new(1, -20, 1, -20)
	Resizer.Size = UDim2.new(0, 20, 0, 20)

	Bar.Name = "Bar"
	Bar.Parent = Window
	Bar.BackgroundColor3 = ui_options.main_color
	Bar.BorderSizePixel = 0
	Bar.Position = UDim2.new(0, 0, 0, 5)
	Bar.Size = UDim2.new(1, 0, 0, 15)

	Toggle.Name = "Toggle"
	Toggle.Parent = Bar
	Toggle.BackgroundColor3 = Color3.new(1, 1, 1)
	Toggle.BackgroundTransparency = 1
	Toggle.Position = UDim2.new(0, 5, 0, -2)
	Toggle.Rotation = 90
	Toggle.Size = UDim2.new(0, 20, 0, 20)
	Toggle.ZIndex = 2
	Toggle.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=4731371541"

	Base.Name = "Base"
	Base.Parent = Bar
	Base.BackgroundColor3 = ui_options.main_color
	Base.BorderSizePixel = 0
	Base.Position = UDim2.new(0, 0, 0.8, 0)
	Base.Size = UDim2.new(1, 0, 0, 10)
	Base.Image = "rbxassetid://2851926732"
	Base.ImageColor3 = ui_options.main_color
	Base.ScaleType = Enum.ScaleType.Slice
	Base.SliceCenter = Rect.new(12, 12, 12, 12)

	Top.Name = "Top"
	Top.Parent = Bar
	Top.BackgroundColor3 = Color3.new(1, 1, 1)
	Top.BackgroundTransparency = 1
	Top.Position = UDim2.new(0, 0, 0, -5)
	Top.Size = UDim2.new(1, 0, 0, 10)
	Top.Image = "rbxassetid://2851926732"
	Top.ImageColor3 = ui_options.main_color
	Top.ScaleType = Enum.ScaleType.Slice
	Top.SliceCenter = Rect.new(12, 12, 12, 12)

	Tabs.Name = "Tabs"
	Tabs.Parent = Window
	Tabs.BackgroundColor3 = Color3.new(1, 1, 1)
	Tabs.BackgroundTransparency = 1
	Tabs.Position = UDim2.new(0, 15, 0, 60)
	Tabs.Size = UDim2.new(1, -30, 1, -60)

	Title.Name = "Title"
	Title.Parent = Window
	Title.BackgroundColor3 = Color3.new(1, 1, 1)
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 30, 0, 3)
	Title.Size = UDim2.new(0, 200, 0, 20)
	Title.Font = Enum.Font.GothamBold
	Title.Text = "Window"
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.TextSize = 14
	Title.TextXAlignment = Enum.TextXAlignment.Left

	TabSelection.Name = "TabSelection"
	TabSelection.Parent = Window
	TabSelection.BackgroundColor3 = Color3.new(1, 1, 1)
	TabSelection.BackgroundTransparency = 1
	TabSelection.Position = UDim2.new(0, 15, 0, 30)
	TabSelection.Size = UDim2.new(1, -30, 0, 25)
	TabSelection.Visible = false
	TabSelection.Image = "rbxassetid://2851929490"
	TabSelection.ImageColor3 = Color3.new(0.145098, 0.14902, 0.156863)
	TabSelection.ScaleType = Enum.ScaleType.Slice
	TabSelection.SliceCenter = Rect.new(4, 4, 4, 4)

	TabButtons.Name = "TabButtons"
	TabButtons.Parent = TabSelection
	TabButtons.BackgroundColor3 = Color3.new(1, 1, 1)
	TabButtons.BackgroundTransparency = 1
	TabButtons.Size = UDim2.new(1, 0, 1, 0)

	local UIListLayout_ = Instance.new("UIListLayout", TabButtons)
	UIListLayout_.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_.Padding = UDim.new(0, 2)

	local Frame_ = Instance.new("Frame", TabSelection)
	Frame_.BackgroundColor3 = ui_options.main_color
	Frame_.BorderSizePixel = 0
	Frame_.Position = UDim2.new(0, 0, 1, 0)
	Frame_.Size = UDim2.new(1, 0, 0, 2)

	Tab.Name = "Tab"
	Tab.Parent = Prefabs
	Tab.BackgroundColor3 = Color3.new(1, 1, 1)
	Tab.BackgroundTransparency = 1
	Tab.Size = UDim2.new(1, 0, 1, 0)
	Tab.Visible = false

	local UIListLayout_2_ = Instance.new("UIListLayout", Tab)
	UIListLayout_2_.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_2_.Padding = UDim.new(0, 5)

	-- Window Management API setup loader
	local WindowsContainer = Instance.new("Frame", imgui)
	WindowsContainer.Name = "Windows"
	WindowsContainer.Size = UDim2.new(1, 0, 1, 0)
	WindowsContainer.BackgroundTransparency = 1

	local API = {}
	function API:CreateWindow(windowTitle)
		local win = Window:Clone()
		win.Parent = WindowsContainer
		win.Title.Text = windowTitle
		win.Size = UDim2.new(0, ui_options.min_size.X, 0, ui_options.min_size.Y)
		
		-- Simple dragging logic implementation for the window bar
		local dragging, dragInput, dragStart, startPos
		Bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = win.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		game:GetService("UserInputService").InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
				local delta = input.Position - dragStart
				win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)

		local TabApi = {}
		function TabApi:AddButton(text, callback)
			local btn = Button_2:Clone()
			btn.Parent = win.Tabs -- Append to active tab container or frame layout
			btn.Text = text
			btn.MouseButton1Click:Connect(callback)
		end
		return TabApi
	end

	if buildFunc then
		buildFunc(API)
	end
end

return Library
