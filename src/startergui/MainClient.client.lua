local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Events = ReplicatedStorage:WaitForChild("Events")
local CreateRoomEvent = Events:WaitForChild("CreateRoom")
local JoinRoomEvent = Events:WaitForChild("JoinRoom")
local SubmitAnswerEvent = Events:WaitForChild("SubmitAnswer")
local PlayAgainEvent = Events:WaitForChild("PlayAgain")
local LeaveRoomEvent = Events:WaitForChild("LeaveRoom")
local UpdateRoomsEvent = Events:WaitForChild("UpdateRooms")
local RoomStateChangedEvent = Events:WaitForChild("RoomStateChanged")
local FeedbackEvent = Events:WaitForChild("FeedbackEvent")
local StartGameEvent = Events:WaitForChild("StartGame")

-- ==========================================
-- AUTO GENERATE UI (Agar langsung bisa main!)
-- ==========================================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameSambungAyatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Create UI Elements
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

local function createText(parent, text, yPos, sizeY, textSize)
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
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    return btn
end

-- 1. LOBBY UI
local LobbyFrame = createBasicFrame("LobbyFrame", true)
createText(LobbyFrame, "LOBBY - SAMBUNG AYAT", 0.05, 0.1)
local CreateRoomBtn = createButton(LobbyFrame, "BUAT ROOM BARU", 0.2)
local RoomListFrame = Instance.new("ScrollingFrame")
RoomListFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
RoomListFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
RoomListFrame.BackgroundTransparency = 0.5
RoomListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
RoomListFrame.Parent = LobbyFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = RoomListFrame
UIListLayout.Padding = UDim.new(0, 10)

-- 2. GAME UI
local GameFrame = createBasicFrame("GameFrame", false)
local GameHeader = createText(GameFrame, "Menunggu Pemain...", 0.05, 0.1)

local StartGameBtn = createButton(GameFrame, "MULAI GAME", 0.15)
StartGameBtn.Visible = false

local AyatLabel = createText(GameFrame, "Ayat akan muncul di sini", 0.25, 0.3)
AyatLabel.TextColor3 = Color3.fromRGB(255, 220, 100)

local AnswerBox = Instance.new("TextBox")
AnswerBox.Size = UDim2.new(0.8, 0, 0.15, 0)
AnswerBox.Position = UDim2.new(0.1, 0, 0.55, 0)
AnswerBox.PlaceholderText = "Ketik lanjutan ayat di sini lalu tekan Enter..."
AnswerBox.Text = ""
AnswerBox.TextScaled = true
AnswerBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AnswerBox.TextColor3 = Color3.new(1,1,1)
AnswerBox.Parent = GameFrame

local FeedbackLabel = createText(GameFrame, "", 0.75, 0.1)
local PlayerListLabel = createText(GameFrame, "", 0.85, 0.1)

-- 3. END UI
local EndFrame = createBasicFrame("EndFrame", false)
local EndTitle = createText(EndFrame, "GAME OVER", 0.1, 0.2)
local WinnerText = createText(EndFrame, "Pemenang: -", 0.4, 0.1)
local PlayAgainBtn = createButton(EndFrame, "MAIN ULANG (Host)", 0.6)
local LeaveBtn = createButton(EndFrame, "KEMBALI KE LOBBY", 0.75)


-- ==========================================
-- CLIENT LOGIC
-- ==========================================
local isHost = false

local function switchUI(frame)
    LobbyFrame.Visible = false
    GameFrame.Visible = false
    EndFrame.Visible = false
    frame.Visible = true
end

-- LOBBY LOGIC
CreateRoomBtn.MouseButton1Click:Connect(function()
    local success, roomId = CreateRoomEvent:InvokeServer()
    if success then
        isHost = true
        switchUI(GameFrame)
        GameHeader.Text = "Room: " .. roomId .. " (Menunggu...)"
    else
        warn("Gagal buat room: ", roomId)
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
        jbtn.Size = UDim2.new(0.3, 0, 0.8, 0)
        jbtn.Position = UDim2.new(0.65, 0, 0.1, 0)
        
        jbtn.MouseButton1Click:Connect(function()
            local success, err = JoinRoomEvent:InvokeServer(room.id)
            if success then
                isHost = false
                switchUI(GameFrame)
            else
                warn(err)
            end
        end)
    end
end)

-- GAME LOGIC
RoomStateChangedEvent.OnClientEvent:Connect(function(stateData)
    if stateData.state == "Closed" then
        switchUI(LobbyFrame)
        return
    end

    if stateData.state == "Waiting" then
        switchUI(GameFrame)
        GameHeader.Text = "Menunggu pemain lain..."
        AyatLabel.Text = "-"
        AnswerBox.Visible = false
        
        -- Cek apakah player ini adalah Host dengan iterasi stateData.players
        local isThisPlayerHost = false
        for _, p in ipairs(stateData.players) do
            if p.name == LocalPlayer.Name then
                isThisPlayerHost = p.isHost
            end
        end
        StartGameBtn.Visible = isThisPlayerHost
        
    elseif stateData.state == "Playing" then
        switchUI(GameFrame)
        StartGameBtn.Visible = false
        
        local isMyTurn = false
        local playersTxt = ""
        for _, p in ipairs(stateData.players) do
            if p.name == LocalPlayer.Name then
                isHost = p.isHost
            end
            local marker = p.isTurn and " 🎯(GILIRAN)" or ""
            playersTxt = playersTxt .. p.name .. " [Skor:" .. p.score .. "|Nyawa:" .. p.lives .. "]" .. marker .. "  "
            
            if p.isTurn and p.name == LocalPlayer.Name then
                isMyTurn = true
            end
        end
        PlayerListLabel.Text = playersTxt
        
        if stateData.currentSurahName then
            GameHeader.Text = "Surah: " .. stateData.currentSurahName
            AyatLabel.Text = stateData.currentAyat or "(Selesai)"
        end
        
        AnswerBox.Visible = isMyTurn
        if isMyTurn then
            AnswerBox.PlaceholderText = "GILIRANMU! Ketik di sini..."
        end
        
    elseif stateData.state == "Ended" then
        switchUI(EndFrame)
        WinnerText.Text = "Pemenang: " .. tostring(stateData.winner)
        PlayAgainBtn.Visible = isHost
    end
end)

AnswerBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and AnswerBox.Text ~= "" then
        local ans = AnswerBox.Text
        AnswerBox.Text = ""
        SubmitAnswerEvent:InvokeServer(ans)
    end
end)

FeedbackEvent.OnClientEvent:Connect(function(isCorrect, msg)
    FeedbackLabel.Text = msg
    if isCorrect then
        FeedbackLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        FeedbackLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    task.delay(3, function()
        if FeedbackLabel.Text == msg then FeedbackLabel.Text = "" end
    end)
end)

StartGameBtn.MouseButton1Click:Connect(function()
    StartGameEvent:FireServer()
end)

-- END LOGIC
PlayAgainBtn.MouseButton1Click:Connect(function()
    PlayAgainEvent:FireServer()
end)

LeaveBtn.MouseButton1Click:Connect(function()
    LeaveRoomEvent:FireServer()
    switchUI(LobbyFrame)
end)
