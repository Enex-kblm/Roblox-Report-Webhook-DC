local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local ReportEvent = ReplicatedStorage:WaitForChild("ReportEvent")
local AntiSpamEvent = ReplicatedStorage:WaitForChild("AntiSpamEvent")

local PlayerGui = player:WaitForChild("PlayerGui")

local spamGui = Instance.new("ScreenGui")
spamGui.Name = "AntiSpamPopup"
spamGui.Parent = PlayerGui

local spamFrame = Instance.new("Frame")
spamFrame.Size = UDim2.new(0, 300, 0, 50)
spamFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
spamFrame.AnchorPoint = Vector2.new(0.5, 0.5)
spamFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
spamFrame.Visible = false
spamFrame.Parent = spamGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = spamFrame

local spamLabel = Instance.new("TextLabel")
spamLabel.Size = UDim2.new(1, -20, 1, -20)
spamLabel.Position = UDim2.new(0, 10, 0, 10)
spamLabel.BackgroundTransparency = 1
spamLabel.TextColor3 = Color3.new(1,1,1)
spamLabel.Font = Enum.Font.GothamBold
spamLabel.TextScaled = true
spamLabel.TextWrapped = true
spamLabel.Text = ""
spamLabel.Parent = spamFrame

local function showPopup(messageType, remainingTime, extraData)
	print("[DEBUG] Popup suppressed:", messageType, remainingTime)
end

AntiSpamEvent.OnClientEvent:Connect(showPopup)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ReportUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local function styleFrame(frame)
	frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
	frame.BorderSizePixel = 0
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,8)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(70,70,70)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame
end

local function styleButton(btn, bgColor, textColor)
	btn.BackgroundColor3 = bgColor
	btn.TextColor3 = textColor
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = btn
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = bgColor:Lerp(Color3.new(1,1,1),0.2)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = bgColor
	end)
end

local reportButton = Instance.new("TextButton")
reportButton.Size = UDim2.new(0,140,0,45)
reportButton.Position = UDim2.new(0,20,0,200)
reportButton.Text = "?? Report"
reportButton.TextSize = 18
reportButton.Parent = ScreenGui
styleButton(reportButton, Color3.fromRGB(255,120,0), Color3.new(1,1,1))

local function createFrame(titleText, size, position)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.Visible = false
	frame.Parent = ScreenGui
	styleFrame(frame)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,-40,0,30)
	title.Position = UDim2.new(0,10,0,8)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.TextColor3 = Color3.new(1,1,1)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0,25,0,25)
	closeBtn.Position = UDim2.new(1,-35,0,8)
	closeBtn.Text = "?"
	closeBtn.TextSize = 16
	closeBtn.Parent = frame
	styleButton(closeBtn, Color3.fromRGB(200,50,50), Color3.new(1,1,1))
	closeBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
	end)

	return frame
end

local choiceFrame = createFrame("Pilih Jenis Report", UDim2.new(0,240,0,150), UDim2.new(0.5,-120,0.5,-75))

local bugButton = Instance.new("TextButton")
bugButton.Size = UDim2.new(1,-20,0,40)
bugButton.Position = UDim2.new(0,10,0,45)
bugButton.Text = "?? Report Bug Map"
bugButton.TextSize = 16
bugButton.Parent = choiceFrame
styleButton(bugButton, Color3.fromRGB(255,200,0), Color3.new(0,0,0))

local playerButton = Instance.new("TextButton")
playerButton.Size = UDim2.new(1,-20,0,40)
playerButton.Position = UDim2.new(0,10,0,95)
playerButton.Text = "?? Report Player"
playerButton.TextSize = 16
playerButton.Parent = choiceFrame
styleButton(playerButton, Color3.fromRGB(220,70,70), Color3.new(1,1,1))

local bugFrame = createFrame("Report Bug Map", UDim2.new(0,340,0,230), UDim2.new(0.5,-170,0.5,-115))
local bugBox = Instance.new("TextBox")
bugBox.Text = ""
bugBox.Size = UDim2.new(1,-20,0,100)
bugBox.Position = UDim2.new(0,10,0,45)
bugBox.PlaceholderText = "Deskripsi bug yang ditemukan..."
bugBox.TextSize = 16
bugBox.ClearTextOnFocus = false
bugBox.TextWrapped = true
bugBox.BackgroundColor3 = Color3.fromRGB(55,55,55)
bugBox.TextColor3 = Color3.new(1,1,1)
bugBox.BorderSizePixel = 0
bugBox.Parent = bugFrame
styleFrame(bugBox)

local bugSend = Instance.new("TextButton")
bugSend.Size = UDim2.new(1,-20,0,40)
bugSend.Position = UDim2.new(0,10,0,160)
bugSend.Text = "?? Kirim Bug Report"
bugSend.TextSize = 16
bugSend.Parent = bugFrame
styleButton(bugSend, Color3.fromRGB(255,200,0), Color3.new(0,0,0))

local playerFrame = createFrame("Report Player", UDim2.new(0,340,0,270), UDim2.new(0.5,-170,0.5,-135))
local targetBox = Instance.new("TextBox")
targetBox.Text = ""
targetBox.Size = UDim2.new(1,-20,0,40)
targetBox.Position = UDim2.new(0,10,0,45)
targetBox.PlaceholderText = "Nama player yang dilaporkan..."
targetBox.TextSize = 16
targetBox.BackgroundColor3 = Color3.fromRGB(55,55,55)
targetBox.TextColor3 = Color3.new(1,1,1)
targetBox.BorderSizePixel = 0
targetBox.Parent = playerFrame
styleFrame(targetBox)

local reasonBox = Instance.new("TextBox")
reasonBox.Text = ""
reasonBox.Size = UDim2.new(1,-20,0,100)
reasonBox.Position = UDim2.new(0,10,0,95)
reasonBox.PlaceholderText = "Alasan report (cheating, toxic, etc.)..."
reasonBox.TextSize = 16
reasonBox.TextWrapped = true
reasonBox.BackgroundColor3 = Color3.fromRGB(55,55,55)
reasonBox.TextColor3 = Color3.new(1,1,1)
reasonBox.BorderSizePixel = 0
reasonBox.Parent = playerFrame
styleFrame(reasonBox)

local playerSend = Instance.new("TextButton")
playerSend.Size = UDim2.new(1,-20,0,40)
playerSend.Position = UDim2.new(0,10,0,210)
playerSend.Text = "?? Kirim Player Report"
playerSend.TextSize = 16
playerSend.Parent = playerFrame
styleButton(playerSend, Color3.fromRGB(220,70,70), Color3.new(1,1,1))

reportButton.MouseButton1Click:Connect(function()
	choiceFrame.Visible = not choiceFrame.Visible
end)

bugButton.MouseButton1Click:Connect(function()
	choiceFrame.Visible = false
	bugFrame.Visible = true
end)

playerButton.MouseButton1Click:Connect(function()
	choiceFrame.Visible = false
	playerFrame.Visible = true
end)

bugSend.MouseButton1Click:Connect(function()
	local coords = "Tidak diketahui"
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local pos = player.Character.HumanoidRootPart.Position
		coords = string.format("(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)
	end
	local serverId = game.JobId ~= "" and game.JobId or "Solo/Private"

	ReportEvent:FireServer("bug", {
		Reporter = player.Name,
		ServerId = serverId,
		Coords = coords,
		Deskripsi = bugBox.Text
	})

	bugFrame.Visible = false
	bugBox.Text = ""
end)

playerSend.MouseButton1Click:Connect(function()
	local serverId = game.JobId ~= "" and game.JobId or "Solo/Private"

	ReportEvent:FireServer("player", {
		Reporter = player.Name,
		Target = targetBox.Text,
		Reason = reasonBox.Text,
		ServerId = serverId
	})

	playerFrame.Visible = false
	targetBox.Text = ""
	reasonBox.Text = ""
end)