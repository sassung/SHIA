--// SHIA - Workspace Targeting
--// LocalScript / built-in executor for your own Roblox experience

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local Settings = {
	SilentAim = false,
	ESP = true,
	ShowFOV = true,

	FOV = 150,
	MinFOV = 60,
	MaxFOV = 350,

	ScanInterval = 30
}

local CachedTargets = {}
local ESPObjects = {}

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "SHIA"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(290, 255)
Main.Position = UDim2.new(0.5, -145, 0.5, -127)
Main.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 42)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "SHIA"
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(38, 38)
Minimize.Position = UDim2.new(1, -42, 0, 2)
Minimize.BackgroundTransparency = 1
Minimize.Text = "−"
Minimize.TextSize = 24
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Main

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.fromOffset(10, 45)
Content.BackgroundTransparency = 1
Content.Parent = Main

--==================================================
-- TOGGLE CREATOR
--==================================================

local function createToggle(text, y, default, callback)

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 0, 38)
	Button.Position = UDim2.fromOffset(0, y)
	Button.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
	Button.BorderSizePixel = 0
	Button.Text = ""
	Button.Parent = Content

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 7)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -70, 1, 0)
	Label.Position = UDim2.fromOffset(12, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextSize = 14
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Button

	local State = Instance.new("TextLabel")
	State.Size = UDim2.fromOffset(55, 30)
	State.Position = UDim2.new(1, -62, 0.5, -15)
	State.BackgroundTransparency = 1
	State.TextSize = 13
	State.Font = Enum.Font.GothamBold
	State.Parent = Button

	local enabled = default

	local function update()
		State.Text = enabled and "ON" or "OFF"
		callback(enabled)
	end

	Button.Activated:Connect(function()
		enabled = not enabled
		update()
	end)

	update()

	return Button
end

createToggle("Silent Aim", 0, Settings.SilentAim, function(v)
	Settings.SilentAim = v
end)

createToggle("ESP", 43, Settings.ESP, function(v)
	Settings.ESP = v

	for _, data in pairs(ESPObjects) do
		if data.Highlight then
			data.Highlight.Enabled = v
		end

		if data.Billboard then
			data.Billboard.Enabled = v
		end
	end
end)

createToggle("Show FOV", 86, Settings.ShowFOV, function(v)
	Settings.ShowFOV = v
end)

--==================================================
-- FOV SLIDER
--==================================================

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, 0, 0, 25)
FOVLabel.Position = UDim2.fromOffset(0, 132)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextSize = 14
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = Content

local Slider = Instance.new("Frame")
Slider.Size = UDim2.new(1, 0, 0, 8)
Slider.Position = UDim2.fromOffset(0, 165)
Slider.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
Slider.BorderSizePixel = 0
Slider.Parent = Content

Instance.new("UICorner", Slider).CornerRadius = UDim.new(1, 0)

local Fill = Instance.new("Frame")
Fill.Size = UDim2.fromScale(0.3, 1)
Fill.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
Fill.BorderSizePixel = 0
Fill.Parent = Slider

Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

local Knob = Instance.new("TextButton")
Knob.Size = UDim2.fromOffset(18, 18)
Knob.AnchorPoint = Vector2.new(0.5, 0.5)
Knob.Position = UDim2.fromScale(0.3, 0.5)
Knob.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
Knob.BorderSizePixel = 0
Knob.Text = ""
Knob.Parent = Slider

Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

local SliderDragging = false

local function updateSlider(x)

	local alpha = math.clamp(
		(x - Slider.AbsolutePosition.X)
			/ Slider.AbsoluteSize.X,
		0,
		1
	)

	Settings.FOV = math.floor(
		Settings.MinFOV +
		(Settings.MaxFOV - Settings.MinFOV) * alpha
	)

	Fill.Size = UDim2.fromScale(alpha, 1)
	Knob.Position = UDim2.fromScale(alpha, 0.5)

	FOVLabel.Text = "FOV: " .. Settings.FOV
end

Knob.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		SliderDragging = true
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not SliderDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		updateSlider(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		SliderDragging = false
	end
end)

FOVLabel.Text = "FOV: " .. Settings.FOV

--==================================================
-- FOV CIRCLE
--==================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = Gui

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Thickness = 2
CircleStroke.Parent = FOVCircle

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

--==================================================
-- ESP
--==================================================

local function removeESP(model)

	local data = ESPObjects[model]

	if data then

		if data.Highlight then
			data.Highlight:Destroy()
		end

		if data.Billboard then
			data.Billboard:Destroy()
		end

		ESPObjects[model] = nil
	end
end

local function createESP(model)

	if ESPObjects[model] then
		return
	end

	local Humanoid = model:FindFirstChildOfClass("Humanoid")
	local Root = model:FindFirstChild("HumanoidRootPart")

	if not Humanoid or not Root then
		return
	end

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "SHIA_ESP"
	Highlight.Adornee = model
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Enabled = Settings.ESP
	Highlight.Parent = model

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "SHIA_Info"
	Billboard.Adornee = Root
	Billboard.Size = UDim2.fromOffset(190, 60)
	Billboard.StudsOffset = Vector3.new(0, 3, 0)
	Billboard.AlwaysOnTop = true
	Billboard.Enabled = Settings.ESP
	Billboard.Parent = Root

	local Info = Instance.new("TextLabel")
	Info.Size = UDim2.fromScale(1, 1)
	Info.BackgroundTransparency = 1
	Info.TextColor3 = Color3.new(1, 1, 1)
	Info.TextStrokeTransparency = 0
	Info.Font = Enum.Font.GothamBold
	Info.TextSize = 13
	Info.Text = model.Name
	Info.Parent = Billboard

	ESPObjects[model] = {
		Highlight = Highlight,
		Billboard = Billboard,
		Label = Info
	}
end

--==================================================
-- WORKSPACE SCANNER
--==================================================

local function scanWorkspace()

	local newTargets = {}

	for _, object in ipairs(workspace:GetDescendants()) do

		if object:IsA("Model")
			and object ~= Player.Character then

			local Humanoid =
				object:FindFirstChildOfClass("Humanoid")

			local Root =
				object:FindFirstChild("HumanoidRootPart")

			if Humanoid
				and Root
				and Humanoid.Health > 0 then

				newTargets[object] = true

				if Settings.ESP then
					createESP(object)
				end
			end
		end
	end

	CachedTargets = newTargets

	-- Remove stale ESP
	for model in pairs(ESPObjects) do

		if not newTargets[model]
			or not model.Parent then

			removeESP(model)
		end
	end
end

-- Initial scan
scanWorkspace()

-- Scan every 30 seconds
task.spawn(function()

	while true do

		task.wait(Settings.ScanInterval)

		if workspace.Parent then
			scanWorkspace()
		end
	end
end)

--==================================================
-- TARGET SELECTION
--==================================================

local function getClosestTarget()

	local Character = Player.Character
	local MyRoot =
		Character and Character:FindFirstChild("HumanoidRootPart")

	if not MyRoot then
		return nil
	end

	local Center = Camera.ViewportSize / 2

	local Closest = nil
	local ClosestDistance = Settings.FOV

	for Model in pairs(CachedTargets) do

		if Model.Parent then

			local Humanoid =
				Model:FindFirstChildOfClass("Humanoid")

			local Root =
				Model:FindFirstChild("HumanoidRootPart")

			if Humanoid
				and Root
				and Humanoid.Health > 0 then

				local ScreenPosition, Visible =
					Camera:WorldToViewportPoint(Root.Position)

				if Visible and ScreenPosition.Z > 0 then

					local Distance =
						(
							Vector2.new(
								ScreenPosition.X,
								ScreenPosition.Y
							) - Center
						).Magnitude

					if Distance <= ClosestDistance then

						ClosestDistance = Distance
						Closest = Model
					end
				end
			end
		end
	end

	return Closest
end

--==================================================
-- ESP UPDATE
--==================================================

RunService.RenderStepped:Connect(function()

	local Character = Player.Character

	local MyRoot =
		Character and Character:FindFirstChild("HumanoidRootPart")

	if MyRoot then

		for Model, Data in pairs(ESPObjects) do

			local Humanoid =
				Model:FindFirstChildOfClass("Humanoid")

			local Root =
				Model:FindFirstChild("HumanoidRootPart")

			if Humanoid and Root and Humanoid.Health > 0 then

				local Distance = math.floor(
					(MyRoot.Position - Root.Position).Magnitude
				)

				Data.Label.Text = string.format(
					"%s\nHP: %d | %d studs",
					Model.Name,
					math.floor(Humanoid.Health),
					Distance
				)

			else
				removeESP(Model)
			end
		end
	end

	-- FOV
	FOVCircle.Visible = Settings.ShowFOV
	FOVCircle.Size =
		UDim2.fromOffset(
			Settings.FOV * 2,
			Settings.FOV * 2
		)

	-- Current selected target
	local Target = getClosestTarget()

	if Settings.SilentAim and Target then
		-- Your own weapon system can use Target here.
		-- Target is the closest valid workspace model
		-- inside the configured FOV.
	end
end)

--==================================================
-- MINIMIZE
--==================================================

local Minimized = false

Minimize.Activated:Connect(function()

	Minimized = not Minimized

	Content.Visible = not Minimized

	Main.Size = Minimized
		and UDim2.fromOffset(290, 45)
		or UDim2.fromOffset(290, 255)

	Minimize.Text = Minimized and "+" or "−"
end)

--==================================================
-- DRAG WINDOW
--==================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = input.Position
		StartPosition = Main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not Dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local Delta = input.Position - DragStart

		Main.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = false
	end
end)

print("[SHIA] Loaded successfully.")
