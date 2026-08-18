--// Workspace Targeting UI
--// LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local Settings = {
	SilentAim = false,
	ESP = true,
	ShowFOV = true,
	FOV = 150,
	MinFOV = 60,
	MaxFOV = 350
}

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "WorkspaceTargeting"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(280, 230)
main.Position = UDim2.new(0.5, -140, 0.5, -115)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 40)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "Workspace Targeting"
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 35)
minimize.Position = UDim2.new(1, -40, 0, 3)
minimize.BackgroundTransparency = 1
minimize.Text = "−"
minimize.TextSize = 24
minimize.Font = Enum.Font.GothamBold
minimize.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.fromOffset(10, 45)
content.BackgroundTransparency = 1
content.Parent = main

--==================================================
-- BUTTON HELPER
--==================================================

local function createToggle(name, y, default, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 38)
	button.Position = UDim2.fromOffset(0, y)
	button.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = content

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.fromOffset(12, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button

	local state = Instance.new("TextLabel")
	state.Size = UDim2.fromOffset(50, 30)
	state.Position = UDim2.new(1, -58, 0.5, -15)
	state.BackgroundTransparency = 1
	state.TextSize = 13
	state.Font = Enum.Font.GothamBold
	state.Parent = button

	local enabled = default

	local function update()
		state.Text = enabled and "ON" or "OFF"
		callback(enabled)
	end

	button.Activated:Connect(function()
		enabled = not enabled
		update()
	end)

	update()

	return button
end

createToggle("Silent Aim", 0, Settings.SilentAim, function(value)
	Settings.SilentAim = value
end)

createToggle("ESP", 45, Settings.ESP, function(value)
	Settings.ESP = value
end)

createToggle("Show FOV", 90, Settings.ShowFOV, function(value)
	Settings.ShowFOV = value
end)

--==================================================
-- FOV SLIDER
--==================================================

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, 0, 0, 25)
fovLabel.Position = UDim2.fromOffset(0, 135)
fovLabel.BackgroundTransparency = 1
fovLabel.TextSize = 14
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = content

local slider = Instance.new("Frame")
slider.Size = UDim2.new(1, 0, 0, 8)
slider.Position = UDim2.fromOffset(0, 165)
slider.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
slider.BorderSizePixel = 0
slider.Parent = content

Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0.4, 1)
fill.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
fill.BorderSizePixel = 0
fill.Parent = slider

Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local knob = Instance.new("TextButton")
knob.Size = UDim2.fromOffset(18, 18)
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Position = UDim2.fromScale(0.4, 0.5)
knob.Text = ""
knob.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
knob.BorderSizePixel = 0
knob.Parent = slider

Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

local sliderDragging = false

local function updateSlider(x)
	local alpha = math.clamp(
		(x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X,
		0,
		1
	)

	Settings.FOV = math.floor(
		Settings.MinFOV +
		(Settings.MaxFOV - Settings.MinFOV) * alpha
	)

	fill.Size = UDim2.fromScale(alpha, 1)
	knob.Position = UDim2.fromScale(alpha, 0.5)

	fovLabel.Text = "FOV: " .. Settings.FOV
end

knob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		sliderDragging = true
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if sliderDragging then
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			updateSlider(input.Position.X)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		sliderDragging = false
	end
end)

fovLabel.Text = "FOV: " .. Settings.FOV
updateSlider(
	slider.AbsolutePosition.X +
	slider.AbsoluteSize.X *
	((Settings.FOV - Settings.MinFOV) /
	(Settings.MaxFOV - Settings.MinFOV))
)

--==================================================
-- FOV CIRCLE
--==================================================

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Parent = gui

local circleStroke = Instance.new("UIStroke")
circleStroke.Thickness = 2
circleStroke.Parent = fovCircle

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = fovCircle

--==================================================
-- ESP
--==================================================

local highlights = {}

local function removeESP(model)
	if highlights[model] then
		highlights[model]:Destroy()
		highlights[model] = nil
	end
end

local function addESP(model)
	if highlights[model] then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "TargetESP"
	highlight.Adornee = model
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model

	highlights[model] = highlight
end

local function getTargets()
	local targets = {}

	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model ~= player.Character then
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			local root = model:FindFirstChild("HumanoidRootPart")

			if humanoid and root and humanoid.Health > 0 then
				table.insert(targets, model)

				if Settings.ESP then
					addESP(model)
				else
					removeESP(model)
				end
			end
		end
	end

	return targets
end

--==================================================
-- TARGET SELECTION
--==================================================

local function getClosestTarget()
	local center = camera.ViewportSize / 2
	local closest
	local closestDistance = Settings.FOV

	for _, model in ipairs(getTargets()) do
		local root = model:FindFirstChild("HumanoidRootPart")

		if root then
			local screenPosition, visible =
				camera:WorldToViewportPoint(root.Position)

			if visible and screenPosition.Z > 0 then
				local distance = (
					Vector2.new(screenPosition.X, screenPosition.Y)
					- center
				).Magnitude

				if distance <= closestDistance then
					closestDistance = distance
					closest = model
				end
			end
		end
	end

	return closest
end

--==================================================
-- MINIMIZE
--==================================================

local minimized = false

minimize.Activated:Connect(function()
	minimized = not minimized

	content.Visible = not minimized
	main.Size = minimized
		and UDim2.fromOffset(280, 45)
		or UDim2.fromOffset(280, 230)

	minimize.Text = minimized and "+" or "−"
end)

--==================================================
-- DRAG WINDOW
--==================================================

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging then
		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

--==================================================
-- UPDATE
--==================================================

RunService.RenderStepped:Connect(function()
	fovCircle.Visible = Settings.ShowFOV

	local diameter = Settings.FOV * 2
	fovCircle.Size = UDim2.fromOffset(diameter, diameter)

	local target = getClosestTarget()

	-- Your weapon system can use this target.
	if Settings.SilentAim and target then
		-- Target selected:
		-- target
	end
end)

workspace.DescendantRemoving:Connect(function(object)
	if highlights[object] then
		removeESP(object)
	end
end)
