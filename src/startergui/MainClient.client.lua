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

local PALETTE = {
    backgroundTop = Color3.fromRGB(16, 22, 20),
    backgroundBottom = Color3.fromRGB(8, 12, 10),
    panelTop = Color3.fromRGB(20, 34, 30),
    panelBottom = Color3.fromRGB(12, 22, 19),
    accentSoft = Color3.fromRGB(112, 152, 120),
    accentGold = Color3.fromRGB(186, 160, 96),
    accentRed = Color3.fromRGB(130, 74, 70),
    textMain = Color3.fromRGB(224, 228, 220),
    textMuted = Color3.fromRGB(162, 170, 158),
}

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local previousGui = PlayerGui:FindFirstChild("GameSambungAyatUI")
if previousGui then
    previousGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameSambungAyatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local function applyGradient(parent, c1, c2, rotation)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2),
    })
    grad.Rotation = rotation or 90
    grad.Parent = parent
end

local function roundCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function stroke(parent, color, thickness)
    local outline = Instance.new("UIStroke")
    outline.Color = color
    outline.Thickness = thickness
    outline.Transparency = 0.2
    outline.Parent = parent
end

local function fadeIn(instance)
    instance.BackgroundTransparency = 1
    TweenService:Create(instance, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
    }):Play()
end

local function createPanel(name, size, position, visible)
    local panel = Instance.new("Frame")
    panel.Name = name
    panel.Size = size
    panel.Position = position
    panel.BackgroundColor3 = PALETTE.panelTop
    panel.Visible = visible
    panel.Parent = ScreenGui

    applyGradient(panel, PALETTE.panelTop, PALETTE.panelBottom, 60)
    roundCorner(panel, 16)
    stroke(panel, PALETTE.accentSoft, 2)
    fadeIn(panel)
    return panel
end

-- Backdrop dihapus agar dunia 3D (lobby masjid & arena) dapat terlihat dengan jelas

local function createLabel(parent, text, size, position, font, color, scaled, align)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Text = text
    label.TextColor3 = color or PALETTE.textMain
    label.Font = font or Enum.Font.GothamSemibold
    label.TextScaled = scaled == nil and true or scaled
    label.TextWrapped = true
    label.TextXAlignment = align or Enum.TextXAlignment.Center
    label.Parent = parent
    return label
end

local function styleButton(button, topColor, bottomColor)
    button.AutoButtonColor = false
    button.BackgroundColor3 = topColor
    button.Text = ""
    applyGradient(button, topColor, bottomColor, 45)
    roundCorner(button, 12)
    stroke(button, PALETTE.accentSoft, 1)

    local t = Instance.new("TextLabel")
    t.Name = "ButtonText"
    t.BackgroundTransparency = 1
    t.Size = UDim2.fromScale(1, 1)
    t.Position = UDim2.fromScale(0, 0)
    t.TextColor3 = PALETTE.textMain
    t.Font = Enum.Font.GothamSemibold
    t.TextScaled = true
    t.TextWrapped = true
    t.Parent = button

    local baseSize = button.Size
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), {
            Size = UDim2.new(baseSize.X.Scale * 1.02, baseSize.X.Offset, baseSize.Y.Scale * 1.02, baseSize.Y.Offset),
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), {Size = baseSize}):Play()
    end)
    return t
end

local MessageBar = createPanel("MessageBar", UDim2.new(0.5, 0, 0.06, 0), UDim2.new(0.25, 0, 0.03, 0), true)
local MessageLabel = createLabel(MessageBar, "Marhaban. Pilih room untuk mulai.", UDim2.fromScale(0.95, 0.9), UDim2.fromScale(0.025, 0.05), Enum.Font.GothamMedium, PALETTE.textMuted)

local LobbyFrame = createPanel("LobbyFrame", UDim2.new(0.64, 0, 0.72, 0), UDim2.new(0.18, 0, 0.16, 0), true)
local LobbyTitle = createLabel(LobbyFrame, "SAMBUNG AYAT", UDim2.new(0.9, 0, 0.13, 0), UDim2.new(0.05, 0, 0.03, 0), Enum.Font.GothamBlack, PALETTE.accentGold)
local LobbySubtitle = createLabel(LobbyFrame, "Tema tenang islami - fokus, nyaman, dan khusyuk", UDim2.new(0.9, 0, 0.08, 0), UDim2.new(0.05, 0, 0.14, 0), Enum.Font.Gotham, PALETTE.textMuted)

local CreateRoomBtn = Instance.new("TextButton")
CreateRoomBtn.Size = UDim2.new(0.4, 0, 0.11, 0)
CreateRoomBtn.Position = UDim2.new(0.3, 0, 0.24, 0)
CreateRoomBtn.Parent = LobbyFrame
styleButton(CreateRoomBtn, Color3.fromRGB(44, 86, 68), Color3.fromRGB(29, 56, 45)).Text = "BUAT ROOM"

local RoomListFrame = Instance.new("ScrollingFrame")
RoomListFrame.Name = "RoomList"
RoomListFrame.Size = UDim2.new(0.9, 0, 0.52, 0)
RoomListFrame.Position = UDim2.new(0.05, 0, 0.41, 0)
RoomListFrame.CanvasSize = UDim2.fromOffset(0, 0)
RoomListFrame.ScrollBarThickness = 6
RoomListFrame.BackgroundColor3 = Color3.fromRGB(14, 20, 18)
RoomListFrame.BackgroundTransparency = 0.2
RoomListFrame.BorderSizePixel = 0
roundCorner(RoomListFrame, 12)
stroke(RoomListFrame, PALETTE.accentSoft, 1)
RoomListFrame.Parent = LobbyFrame

local RoomListLayout = Instance.new("UIListLayout")
RoomListLayout.Padding = UDim.new(0, 10)
RoomListLayout.Parent = RoomListFrame

RoomListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    RoomListFrame.CanvasSize = UDim2.fromOffset(0, RoomListLayout.AbsoluteContentSize.Y + 10)
end)

local GameHUD = createPanel("GameHUD", UDim2.new(0.86, 0, 0.24, 0), UDim2.new(0.07, 0, 0.03, 0), false)
local AyatLabel = createLabel(GameHUD, "Menunggu ronde dimulai...", UDim2.new(0.95, 0, 0.5, 0), UDim2.new(0.025, 0, 0.08, 0), Enum.Font.GothamBold, PALETTE.accentGold)
local PlayerListLabel = createLabel(GameHUD, "", UDim2.new(0.95, 0, 0.22, 0), UDim2.new(0.025, 0, 0.56, 0), Enum.Font.Gotham, PALETTE.textMain, true, Enum.TextXAlignment.Left)

local StartGameBtn = Instance.new("TextButton")
StartGameBtn.Size = UDim2.new(0.26, 0, 0.25, 0)
StartGameBtn.Position = UDim2.new(0.37, 0, 0.72, 0)
StartGameBtn.Parent = GameHUD
styleButton(StartGameBtn, Color3.fromRGB(86, 75, 40), Color3.fromRGB(56, 48, 24)).Text = "MULAI GAME"

local EndFrame = createPanel("EndFrame", UDim2.new(0.58, 0, 0.56, 0), UDim2.new(0.21, 0, 0.22, 0), false)
local EndTitle = createLabel(EndFrame, "GAME SELESAI", UDim2.new(0.9, 0, 0.22, 0), UDim2.new(0.05, 0, 0.08, 0), Enum.Font.GothamBlack, PALETTE.accentGold)
local WinnerText = createLabel(EndFrame, "Pemenang: -", UDim2.new(0.9, 0, 0.14, 0), UDim2.new(0.05, 0, 0.36, 0), Enum.Font.GothamSemibold, PALETTE.textMain)

local PlayAgainBtn = Instance.new("TextButton")
PlayAgainBtn.Size = UDim2.new(0.42, 0, 0.17, 0)
PlayAgainBtn.Position = UDim2.new(0.29, 0, 0.58, 0)
PlayAgainBtn.Parent = EndFrame
styleButton(PlayAgainBtn, Color3.fromRGB(44, 86, 68), Color3.fromRGB(29, 56, 45)).Text = "MAIN LAGI"

local LeaveBtn = Instance.new("TextButton")
LeaveBtn.Size = UDim2.new(0.42, 0, 0.17, 0)
LeaveBtn.Position = UDim2.new(0.29, 0, 0.79, 0)
LeaveBtn.Parent = EndFrame
styleButton(LeaveBtn, Color3.fromRGB(82, 56, 50), Color3.fromRGB(52, 35, 31)).Text = "KEMBALI KE LOBBY"

local isHost = false

local function setMessage(text)
    MessageLabel.Text = text
end

local function switchUI(mode)
    LobbyFrame.Visible = mode == "Lobby"
    GameHUD.Visible = mode == "Game"
    EndFrame.Visible = mode == "End"
end

local function renderRooms(rooms)
    for _, child in ipairs(RoomListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    if #rooms == 0 then
        local empty = createLabel(RoomListFrame, "Belum ada room aktif. Silakan buat room baru.", UDim2.new(1, -12, 0, 52), UDim2.new(0, 6, 0, 0), Enum.Font.Gotham, PALETTE.textMuted, false)
        empty.TextSize = 18
        return
    end

    for _, room in ipairs(rooms) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -12, 0, 72)
        card.Position = UDim2.new(0, 6, 0, 0)
        card.BackgroundColor3 = Color3.fromRGB(18, 28, 25)
        card.Parent = RoomListFrame
        roundCorner(card, 10)
        stroke(card, PALETTE.accentSoft, 1)

        local roomLabel = createLabel(
            card,
            string.format("Room %s  |  Host: %s  |  %d/%d pemain", room.id, room.hostName, room.playerCount, room.maxPlayers),
            UDim2.new(0.66, 0, 0.82, 0),
            UDim2.new(0.03, 0, 0.09, 0),
            Enum.Font.Gotham,
            PALETTE.textMain,
            true,
            Enum.TextXAlignment.Left
        )
        roomLabel.TextSize = 15

        local join = Instance.new("TextButton")
        join.Size = UDim2.new(0.26, 0, 0.68, 0)
        join.Position = UDim2.new(0.71, 0, 0.16, 0)
        join.Parent = card
        styleButton(join, Color3.fromRGB(69, 103, 84), Color3.fromRGB(45, 67, 55)).Text = "MASUK"

        join.MouseButton1Click:Connect(function()
            local success, err = JoinRoomEvent:InvokeServer(room.id)
            if success then
                isHost = false
                setMessage("Berhasil bergabung ke room. Menunggu host memulai game.")
                switchUI("Game")
            else
                setMessage("Gagal masuk room: " .. tostring(err))
            end
        end)
    end
end

CreateRoomBtn.MouseButton1Click:Connect(function()
    local success, roomIdOrError = CreateRoomEvent:InvokeServer()
    if success then
        isHost = true
        setMessage("Room dibuat. Anda adalah host room " .. tostring(roomIdOrError) .. ".")
        switchUI("Game")
    else
        setMessage("Gagal membuat room: " .. tostring(roomIdOrError))
    end
end)

UpdateRoomsEvent.OnClientEvent:Connect(function(rooms)
    renderRooms(rooms)
end)

RoomStateChangedEvent.OnClientEvent:Connect(function(stateData)
    if stateData.state == "Closed" then
        switchUI("Lobby")
        setMessage("Anda kembali ke lobby.")
        StartGameBtn.Visible = false
        return
    end

    if stateData.state == "Waiting" then
        switchUI("Game")
        AyatLabel.Text = "Menunggu host memulai game..."
        PlayerListLabel.Text = ""

        local isThisPlayerHost = false
        local lines = {}
        for _, p in ipairs(stateData.players) do
            if p.name == LocalPlayer.Name then
                isThisPlayerHost = p.isHost
                isHost = p.isHost
            end
            table.insert(lines, string.format("%s - skor %d - nyawa %d", p.name, p.score, p.lives))
        end

        PlayerListLabel.Text = table.concat(lines, "\n")
        StartGameBtn.Visible = isThisPlayerHost
        setMessage("Room aktif. Siapkan hafalan untuk ronde berikutnya.")
    elseif stateData.state == "Playing" then
        switchUI("Game")
        StartGameBtn.Visible = false

        local lines = {}
        for _, p in ipairs(stateData.players) do
            if p.name == LocalPlayer.Name then
                isHost = p.isHost
            end
            local marker = p.isTurn and " <GILIRAN>" or ""
            table.insert(lines, string.format("%s - skor %d - nyawa %d%s", p.name, p.score, p.lives, marker))
        end
        PlayerListLabel.Text = table.concat(lines, "\n")

        if stateData.currentSurahName then
            AyatLabel.Text = string.format("Surah %s\n%s", stateData.currentSurahName, stateData.currentAyat or "(selesai)")
        else
            AyatLabel.Text = "Menunggu soal berikutnya..."
        end

        setMessage("Ronde berjalan. Pilih sambungan ayat yang benar.")
    elseif stateData.state == "Ended" then
        switchUI("End")
        WinnerText.Text = "Pemenang: " .. tostring(stateData.winner)
        PlayAgainBtn.Visible = isHost

        if stateData.winner == LocalPlayer.Name then
            EndTitle.Text = "ALHAMDULILLAH, MENANG"
            EndTitle.TextColor3 = Color3.fromRGB(145, 193, 128)
            setMessage("Selamat, Anda memenangkan ronde ini.")
        else
            EndTitle.Text = "GAME SELESAI"
            EndTitle.TextColor3 = PALETTE.accentGold
            setMessage("Ronde selesai. Anda bisa lanjut main lagi.")
        end
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
    setMessage("Keluar dari room dan kembali ke lobby.")
end)
