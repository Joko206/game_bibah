local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Events = ReplicatedStorage:WaitForChild("Events")
local CreateRoomEvent = Events:WaitForChild("CreateRoom")
local JoinRoomEvent = Events:WaitForChild("JoinRoom")
local LeaveRoomEvent = Events:WaitForChild("LeaveRoom")
local StartGameEvent = Events:WaitForChild("StartGame")
local PlayAgainEvent = Events:WaitForChild("PlayAgain")
local UpdateRoomsEvent = Events:WaitForChild("UpdateRooms")
local RoomStateChangedEvent = Events:WaitForChild("RoomStateChanged")

-- ==========================================
-- UI GENERATOR (NEXT-GEN)
-- ==========================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameSambungAyatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Helpers
local function applyGradient(parent, c1, c2)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    }
    grad.Rotation = 45
    grad.Parent = parent
end

local function applyStroke(parent, color, thickness, mode)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
end

local function addHoverAnim(btn)
    local originalSize = btn.Size
    local hoverSize = UDim2.new(
        originalSize.X.Scale * 1.05, originalSize.X.Offset,
        originalSize.Y.Scale * 1.05, originalSize.Y.Offset
    )
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = hoverSize}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = originalSize}):Play()
    end)
end

local function createBasicFrame(name, visible)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(0.6, 0, 0.7, 0)
    frame.Position = UDim2.new(0.2, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    applyGradient(frame, Color3.fromRGB(20, 25, 35), Color3.fromRGB(30, 40, 60))
    applyStroke(frame, Color3.fromRGB(0, 200, 255), 3)
    frame.Visible = visible
    frame.Parent = ScreenGui
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 20)
    uiCorner.Parent = frame
    return frame
end

local function createText(parent, text, yPos, sizeY, alignLeft)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.9, 0, sizeY, 0)
    label.Position = UDim2.new(0.05, 0, yPos, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    if alignLeft then label.TextXAlignment = Enum.TextXAlignment.Left end
    applyStroke(label, Color3.fromRGB(0, 0, 0), 2, Enum.ApplyStrokeMode.Contextual)
    label.Parent = parent
    return label
end

local function createButton(parent, text, yPos, c1, c2)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0.12, 0)
    btn.Position = UDim2.new(0.25, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "" -- Kosongkan teks tombol asli agar tidak terpengaruh UIGradient
    applyGradient(btn, c1 or Color3.fromRGB(0, 180, 200), c2 or Color3.fromRGB(0, 100, 150))
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    applyStroke(btn, Color3.fromRGB(255, 255, 255), 2)
    
    -- Buat TextLabel terpisah agar teks tidak terkena efek camouflage dari UIGradient
    local txtLabel = Instance.new("TextLabel")
    txtLabel.Size = UDim2.new(1, 0, 1, 0)
    txtLabel.BackgroundTransparency = 1
    txtLabel.Text = text
    txtLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    txtLabel.TextScaled = true
    txtLabel.Font = Enum.Font.SourceSansBold
    txtLabel.Parent = btn
    
    return btn
end

-- 1. LOBBY UI
local LobbyFrame = createBasicFrame("LobbyFrame", true)
local LobbyTitle = createText(LobbyFrame, "SAMBUNG AYAT 3D", 0.05, 0.1)
LobbyTitle.TextColor3 = Color3.fromRGB(0, 255, 200)

local CreateRoomBtn = createButton(LobbyFrame, "BUAT ROOM BARU", 0.2, Color3.fromRGB(0, 200, 100), Color3.fromRGB(0, 120, 50))
addHoverAnim(CreateRoomBtn)
local RoomListFrame = Instance.new("ScrollingFrame")
RoomListFrame.Size = UDim2.new(0.9, 0, 0.55, 0)
RoomListFrame.Position = UDim2.new(0.05, 0, 0.38, 0)
RoomListFrame.BackgroundTransparency = 0.8
RoomListFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RoomListFrame.BorderSizePixel = 0
RoomListFrame.Parent = LobbyFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = RoomListFrame
UIListLayout.Padding = UDim.new(0, 10)

-- 2. GAME HUD
local GameHUD = Instance.new("Frame")
GameHUD.Size = UDim2.new(1, 0, 0.25, 0)
GameHUD.BackgroundTransparency = 1
GameHUD.Visible = false
GameHUD.Parent = ScreenGui

local AyatLabel = createText(GameHUD, "Ayat soal akan muncul di sini", 0.05, 0.4)
AyatLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
applyStroke(AyatLabel, Color3.fromRGB(50, 20, 0), 3, Enum.ApplyStrokeMode.Contextual)

local PlayerListLabel = createText(GameHUD, "", 0.5, 0.25)
PlayerListLabel.TextColor3 = Color3.fromRGB(200, 240, 255)

local StartGameBtn = createButton(GameHUD, "MULAI GAME", 0.6, Color3.fromRGB(255, 150, 0), Color3.fromRGB(200, 80, 0))
StartGameBtn.Size = UDim2.new(0.15, 0, 0.25, 0)
StartGameBtn.Position = UDim2.new(0.425, 0, 0.75, 0)
addHoverAnim(StartGameBtn)

-- 3. END UI
local EndFrame = createBasicFrame("EndFrame", false)
local EndTitle = createText(EndFrame, "GAME OVER", 0.1, 0.2)
local WinnerText = createText(EndFrame, "Pemenang: -", 0.4, 0.1)
local PlayAgainBtn = createButton(EndFrame, "MAIN ULANG", 0.6)
addHoverAnim(PlayAgainBtn)
local LeaveBtn = createButton(EndFrame, "KEMBALI KE LOBBY", 0.75, Color3.fromRGB(200, 50, 50), Color3.fromRGB(120, 20, 20))
addHoverAnim(LeaveBtn)


-- ==========================================
-- CLIENT LOGIC
-- ==========================================
local isHost = false

local function switchUI(mode)
    LobbyFrame.Visible = (mode == "Lobby")
    GameHUD.Visible = (mode == "Game")
    EndFrame.Visible = (mode == "End")
end

-- LOBBY LOGIC
CreateRoomBtn.MouseButton1Click:Connect(function()
    local success, roomId = CreateRoomEvent:InvokeServer()
    if success then
        isHost = true
        switchUI("Game")
    end
end)

UpdateRoomsEvent.OnClientEvent:Connect(function(rooms)
    for _, child in ipairs(RoomListFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for _, room in ipairs(rooms) do
        local rf = Instance.new("Frame")
        rf.Size = UDim2.new(1, 0, 0, 60)
        rf.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        applyGradient(rf, Color3.fromRGB(40, 50, 70), Color3.fromRGB(20, 25, 35))
        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0, 10)
        rc.Parent = rf
        applyStroke(rf, Color3.fromRGB(100, 150, 255), 2)
        rf.Parent = RoomListFrame
        
        local txt = createText(rf, "  " .. room.hostName .. "'s Room (" .. room.playerCount .. "/" .. room.maxPlayers .. ")", 0.1, 0.8, true)
        txt.Size = UDim2.new(0.6, 0, 0.8, 0)
        
        local jbtn = createButton(rf, "JOIN", 0.1)
        jbtn.Size = UDim2.new(0.3, 0, 0.8, 0)
        jbtn.Position = UDim2.new(0.65, 0, 0.1, 0)
        addHoverAnim(jbtn)
        
        jbtn.MouseButton1Click:Connect(function()
            local success, err = JoinRoomEvent:InvokeServer(room.id)
            if success then
                isHost = false
                switchUI("Game")
            end
        end)
    end
end)

-- GAME LOGIC
RoomStateChangedEvent.OnClientEvent:Connect(function(stateData)
    if stateData.state == "Closed" then
        switchUI("Lobby")
        return
    end

    if stateData.state == "Waiting" then
        switchUI("Game")
        PlayerListLabel.Text = "Menunggu pemain lain..."
        AyatLabel.Text = "Belum Dimulai"
        
        local isThisPlayerHost = false
        for _, p in ipairs(stateData.players) do
            if p.name == LocalPlayer.Name then isThisPlayerHost = p.isHost end
        end
        StartGameBtn.Visible = isThisPlayerHost
        
    elseif stateData.state == "Playing" then
        switchUI("Game")
        StartGameBtn.Visible = false
        
        local playersTxt = ""
        for _, p in ipairs(stateData.players) do
            if p.name == LocalPlayer.Name then isHost = p.isHost end
            local marker = p.isTurn and " 🎯" or ""
            playersTxt = playersTxt .. p.name .. " [Skor:" .. p.score .. " | Nyawa:" .. p.lives .. "]" .. marker .. "   "
        end
        PlayerListLabel.Text = playersTxt
        
        if stateData.currentSurahName then
            AyatLabel.Text = "Surah: " .. stateData.currentSurahName .. "\n" .. (stateData.currentAyat or "(Selesai)")
        end
        
    elseif stateData.state == "Ended" then
        switchUI("End")
        
        if stateData.winner == LocalPlayer.Name then
            EndTitle.Text = "MENANG!"
            EndTitle.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            EndTitle.Text = "GAME OVER"
            EndTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        WinnerText.Text = "Pemenang: " .. tostring(stateData.winner)
        PlayAgainBtn.Visible = isHost
    end
end)

StartGameBtn.MouseButton1Click:Connect(function()
    StartGameEvent:FireServer()
end)

PlayAgainBtn.MouseButton1Click:Connect(function()
    PlayAgainEvent:FireServer()
end)

LeaveBtn.MouseButton1Click:Connect(function()
    LeaveRoomEvent:FireServer()
    switchUI("Lobby")
end)
