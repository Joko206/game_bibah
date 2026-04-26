local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
-- UI GENERATOR (Sederhana untuk 3D Obby)
-- ==========================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameSambungAyatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local function createBasicFrame(name, visible)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(0.8, 0, 0.8, 0)
    frame.Position = UDim2.new(0.1, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.Visible = visible
    frame.Parent = ScreenGui
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 15)
    uiCorner.Parent = frame
    return frame
end

local function createText(parent, text, yPos, sizeY)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.9, 0, sizeY, 0)
    label.Position = UDim2.new(0.05, 0, yPos, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = parent
    return label
end

local function createButton(parent, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, 0, 0.1, 0)
    btn.Position = UDim2.new(0.3, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = btn
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    return btn
end

-- 1. LOBBY UI
local LobbyFrame = createBasicFrame("LobbyFrame", true)
createText(LobbyFrame, "LOBBY - 3D OBBY SAMBUNG AYAT", 0.05, 0.1)
local CreateRoomBtn = createButton(LobbyFrame, "BUAT ROOM BARU", 0.2)
CreateRoomBtn.Parent = LobbyFrame
local RoomListFrame = Instance.new("ScrollingFrame")
RoomListFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
RoomListFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
RoomListFrame.BackgroundTransparency = 0.5
RoomListFrame.Parent = LobbyFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = RoomListFrame
UIListLayout.Padding = UDim.new(0, 10)

-- 2. GAME HUD (Tidak menutupi layar, hanya di atas)
local GameHUD = Instance.new("Frame")
GameHUD.Size = UDim2.new(1, 0, 0.15, 0)
GameHUD.BackgroundTransparency = 0.5
GameHUD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
GameHUD.Visible = false
GameHUD.Parent = ScreenGui

local PlayerListLabel = createText(GameHUD, "", 0.1, 0.4)
local StartGameBtn = createButton(GameHUD, "MULAI GAME (Host)", 0.5)
StartGameBtn.Parent = GameHUD
StartGameBtn.Size = UDim2.new(0.2, 0, 0.4, 0)
StartGameBtn.Position = UDim2.new(0.4, 0, 0.5, 0)

-- 3. END UI
local EndFrame = createBasicFrame("EndFrame", false)
createText(EndFrame, "GAME OVER", 0.1, 0.2)
local WinnerText = createText(EndFrame, "Pemenang: -", 0.4, 0.1)
local PlayAgainBtn = createButton(EndFrame, "MAIN ULANG (Host)", 0.6)
PlayAgainBtn.Parent = EndFrame
local LeaveBtn = createButton(EndFrame, "KEMBALI KE LOBBY", 0.75)
LeaveBtn.Parent = EndFrame


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
        rf.Size = UDim2.new(1, 0, 0, 50)
        rf.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        rf.Parent = RoomListFrame
        
        local txt = createText(rf, room.hostName .. "'s Room (" .. room.playerCount .. "/" .. room.maxPlayers .. ")", 0, 1)
        txt.Size = UDim2.new(0.6, 0, 1, 0)
        txt.TextXAlignment = Enum.TextXAlignment.Left
        
        local jbtn = createButton(rf, "JOIN", 0.1)
        jbtn.Parent = rf
        jbtn.Size = UDim2.new(0.3, 0, 0.8, 0)
        jbtn.Position = UDim2.new(0.65, 0, 0.1, 0)
        
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
        PlayerListLabel.Text = "Menunggu pemain..."
        
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
            local marker = p.isTurn and " 🎯(GILIRAN)" or ""
            playersTxt = playersTxt .. p.name .. " [Skor:" .. p.score .. "|Nyawa:" .. p.lives .. "]" .. marker .. "  "
        end
        PlayerListLabel.Text = playersTxt
        
    elseif stateData.state == "Ended" then
        switchUI("End")
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
