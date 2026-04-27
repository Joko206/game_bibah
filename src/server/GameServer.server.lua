local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SurahData = require(ReplicatedStorage.Shared.SurahData)

-- ==========================================
-- CINEMATIC LIGHTING
-- ==========================================
local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
bloom.Intensity = 0.28
bloom.Size = 14
bloom.Threshold = 1
bloom.Parent = Lighting

local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
cc.Contrast = 0.08
cc.Saturation = -0.05
cc.TintColor = Color3.fromRGB(232, 236, 224)
cc.Parent = Lighting

Lighting.Brightness = 1.35
Lighting.Ambient = Color3.fromRGB(42, 48, 40)
Lighting.OutdoorAmbient = Color3.fromRGB(28, 34, 30)

local Events = ReplicatedStorage:WaitForChild("Events")
local CreateRoomEvent = Events:WaitForChild("CreateRoom")
local JoinRoomEvent = Events:WaitForChild("JoinRoom")
local LeaveRoomEvent = Events:WaitForChild("LeaveRoom")
local StartGameEvent = Events:WaitForChild("StartGame")
local PlayAgainEvent = Events:WaitForChild("PlayAgain")
local UpdateRoomsEvent = Events:WaitForChild("UpdateRooms")
local RoomStateChangedEvent = Events:WaitForChild("RoomStateChanged")

-- Game State
local Rooms = {}
local PlayerRooms = {}
local RoomCounter = 0

local MAX_LIVES = 3
local MAX_PLAYERS = 4

-- ==========================================
-- 3D MAP GENERATOR
-- ==========================================
local function createArena(roomId)
    local offset = Vector3.new(0, 50, roomId * 500)
    
    local arenaModel = Instance.new("Model")
    arenaModel.Name = "Arena_" .. roomId
    arenaModel.Parent = Workspace
    
    -- Pencahayaan
    local ambientLight = Instance.new("PointLight")
    ambientLight.Range = 60
    ambientLight.Brightness = 1.2
    ambientLight.Color = Color3.fromRGB(142, 162, 128)
    
    -- Particle Effect (Debu Kosmik)
    local dust = Instance.new("ParticleEmitter")
    dust.Color = ColorSequence.new(Color3.fromRGB(255, 230, 150))
    dust.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.4), NumberSequenceKeypoint.new(1, 0)})
    dust.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.5), NumberSequenceKeypoint.new(1, 1)})
    dust.Lifetime = NumberRange.new(2, 5)
    dust.Rate = 50
    dust.Speed = NumberRange.new(1, 3)
    dust.SpreadAngle = Vector2.new(180, 180)
    
    -- Spectator Platform (Ruang Tunggu)
    local specPlatform = Instance.new("Part")
    specPlatform.Name = "SpectatorPlatform"
    specPlatform.Size = Vector3.new(40, 2, 20)
    specPlatform.Position = offset + Vector3.new(0, 0, -50)
    specPlatform.Anchored = true
    specPlatform.Material = Enum.Material.Glass
    specPlatform.BrickColor = BrickColor.new("Navy blue")
    specPlatform.Parent = arenaModel
    
    local d1 = dust:Clone()
    d1.Parent = specPlatform
    
    local specGlow = Instance.new("Part")
    specGlow.Size = Vector3.new(42, 1, 22)
    specGlow.Position = specPlatform.Position - Vector3.new(0, 0.5, 0)
    specGlow.Anchored = true
    specGlow.Material = Enum.Material.SmoothPlastic
    specGlow.BrickColor = BrickColor.new("Olive")
    specGlow.Parent = arenaModel
    
    local l1 = ambientLight:Clone()
    l1.Parent = specPlatform

    -- Tembok Pelindung Spectator
    local function createWall(size, pos)
        local w = Instance.new("Part")
        w.Size = size
        w.Position = pos
        w.Anchored = true
        w.Material = Enum.Material.Glass
        w.Color = Color3.fromRGB(70, 92, 83)
        w.Transparency = 0.35
        w.Parent = arenaModel
    end
    
    local wallH = 15
    createWall(Vector3.new(1, wallH, 20), specPlatform.Position + Vector3.new(-20, wallH/2, 0)) -- Kiri
    createWall(Vector3.new(1, wallH, 20), specPlatform.Position + Vector3.new(20, wallH/2, 0))  -- Kanan
    createWall(Vector3.new(40, wallH, 1), specPlatform.Position + Vector3.new(0, wallH/2, -10)) -- Belakang
    createWall(Vector3.new(40, wallH, 1), specPlatform.Position + Vector3.new(0, wallH/2, 10))  -- Depan

    -- Start Platform (Arena Utama)
    local startPlatform = Instance.new("Part")
    startPlatform.Name = "StartPlatform"
    startPlatform.Size = Vector3.new(40, 2, 20)
    startPlatform.Position = offset + Vector3.new(0, 0, 0)
    startPlatform.Anchored = true
    startPlatform.Material = Enum.Material.SmoothPlastic
    startPlatform.BrickColor = BrickColor.new("Dark stone grey")
    startPlatform.Parent = arenaModel
    
    local d2 = dust:Clone()
    d2.Parent = startPlatform
    
    local startGlow = Instance.new("Part")
    startGlow.Size = Vector3.new(42, 1, 22)
    startGlow.Position = startPlatform.Position - Vector3.new(0, 0.5, 0)
    startGlow.Anchored = true
    startGlow.Material = Enum.Material.SmoothPlastic
    startGlow.BrickColor = BrickColor.new("Brown")
    startGlow.Parent = arenaModel
    
    local l2 = ambientLight:Clone()
    l2.Brightness = 0.9
    l2.Color = Color3.fromRGB(168, 142, 88)
    l2.Parent = startPlatform
    
    -- SUCCESS PLATFORM (Zona Aman di Belakang Pintu)
    local successPlatform = Instance.new("Part")
    successPlatform.Name = "SuccessPlatform"
    successPlatform.Size = Vector3.new(40, 2, 20)
    successPlatform.Position = offset + Vector3.new(0, 0, 21)
    successPlatform.Anchored = true
    successPlatform.Material = Enum.Material.SmoothPlastic
    successPlatform.BrickColor = BrickColor.new("Dark stone grey")
    successPlatform.Parent = arenaModel
    
    local successGlow = Instance.new("Part")
    successGlow.Size = Vector3.new(42, 1, 22)
    successGlow.Position = successPlatform.Position - Vector3.new(0, 0.5, 0)
    successGlow.Anchored = true
    successGlow.Material = Enum.Material.SmoothPlastic
    successGlow.BrickColor = BrickColor.new("Sea green")
    successGlow.Parent = arenaModel
    
    local l3 = ambientLight:Clone()
    l3.Brightness = 1
    l3.Color = Color3.fromRGB(132, 184, 132)
    l3.Parent = successPlatform

    -- Void pit di bawah arena untuk reset pemain yang jatuh
    local hellPit = Instance.new("Part")
    hellPit.Name = "HellPit"
    hellPit.Size = Vector3.new(300, 10, 300)
    hellPit.Position = offset + Vector3.new(0, -150, 0)
    hellPit.Anchored = true
    hellPit.Material = Enum.Material.Slate
    hellPit.Color = Color3.fromRGB(50, 36, 34)
    hellPit.Parent = arenaModel
    
    local fire = Instance.new("ParticleEmitter")
    fire.Color = ColorSequence.new(Color3.fromRGB(148, 80, 52), Color3.fromRGB(102, 56, 40))
    fire.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 7)})
    fire.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1)})
    fire.Lifetime = NumberRange.new(2, 3)
    fire.Rate = 120
    fire.Speed = NumberRange.new(8, 14)
    fire.EmissionDirection = Enum.NormalId.Top
    fire.Parent = hellPit
    
    -- Mengeliminasi pemain yang jatuh dari arena
    hellPit.Touched:Connect(function(hit)
        local h = hit.Parent:FindFirstChild("Humanoid")
        if h then h.Health = 0 end
    end)

    -- Pilar Cahaya Bergaya Sci-Fi
    for _, xPos in ipairs({-19, 19}) do
        local pillar = Instance.new("Part")
        pillar.Shape = Enum.PartType.Cylinder
        pillar.Size = Vector3.new(20, 3, 3) -- Orientation Cylinder di Roblox membentang di sumbu X
        pillar.CFrame = CFrame.new(startPlatform.Position + Vector3.new(xPos, 10, 8)) * CFrame.Angles(0, 0, math.pi/2)
        pillar.Anchored = true
        pillar.Material = Enum.Material.SmoothPlastic
        pillar.BrickColor = BrickColor.new("Dark green")
        pillar.Parent = arenaModel
        
        -- Cincin Emas melayang di pilar
        local ring = Instance.new("Part")
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(2, 3.5, 3.5)
        ring.CFrame = CFrame.new(startPlatform.Position + Vector3.new(xPos, 15, 8)) * CFrame.Angles(0, 0, math.pi/2)
        ring.Anchored = true
        ring.Material = Enum.Material.SmoothPlastic
        ring.BrickColor = BrickColor.new("Khaki")
        ring.Parent = arenaModel
    end

    -- Papan Soal Raksasa
    local qBoard = Instance.new("Part")
    qBoard.Name = "QuestionBoard"
    qBoard.Size = Vector3.new(34, 18, 2)
    qBoard.Position = offset + Vector3.new(0, 26, 22) -- Diangkat tinggi ke Y=26 agar tidak terhalang pintu
    qBoard.Anchored = true
    qBoard.Material = Enum.Material.SmoothPlastic
    qBoard.BrickColor = BrickColor.new("Dark green")
    qBoard.Parent = arenaModel
    
    local qScreen = Instance.new("Part")
    qScreen.Size = Vector3.new(32, 16, 2.2)
    qScreen.Position = qBoard.Position
    qScreen.Anchored = true
    qScreen.Material = Enum.Material.SmoothPlastic
    qScreen.BrickColor = BrickColor.new("Really black")
    qScreen.Parent = arenaModel
    
    local qGui = Instance.new("SurfaceGui")
    qGui.Face = Enum.NormalId.Front
    qGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
    qGui.CanvasSize = Vector2.new(1600, 800)
    qGui.Parent = qScreen
    
    local qText = Instance.new("TextLabel")
    qText.Name = "Text"
    qText.Size = UDim2.new(0.9, 0, 0.9, 0)
    qText.Position = UDim2.new(0.05, 0, 0.05, 0)
    qText.BackgroundTransparency = 1
    qText.TextScaled = true
    qText.TextWrapped = true
    qText.TextColor3 = Color3.fromRGB(255, 255, 255)
    qText.Font = Enum.Font.GothamBold
    qText.Text = "Menunggu Game Dimulai..."
    qText.Parent = qGui
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(160, 148, 96)
    uiStroke.Thickness = 3
    uiStroke.Parent = qText
    
    -- 3 Pintu Tegak (Berdiri)
    local doors = {}
    for i = 1, 3 do
        local door = Instance.new("Part")
        door.Name = "Door_" .. i
        door.Size = Vector3.new(10, 14, 1) -- Lebar 10, Tinggi 14, Tebal 1
        door.Position = offset + Vector3.new((i-2)*13, 7, 10.5) -- Rapat dengan batas depan StartPlatform (Z=10)
        door.Anchored = true
        door.Material = Enum.Material.SmoothPlastic
        door.BrickColor = BrickColor.new("Black")
        door.Parent = arenaModel
        
        local dGlow = Instance.new("Part")
        dGlow.Name = "Glow"
        dGlow.Size = Vector3.new(10.5, 14.5, 0.5)
        dGlow.Position = door.Position + Vector3.new(0, 0, 0.5) -- Dipindah ke belakang pintu agar tidak menutupi teks di depan (-Z)
        dGlow.Anchored = true
        dGlow.Material = Enum.Material.SmoothPlastic
        dGlow.BrickColor = BrickColor.new("Dark stone grey")
        dGlow.Parent = door
        
        local dGui = Instance.new("SurfaceGui")
        dGui.Face = Enum.NormalId.Front
        dGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
        dGui.CanvasSize = Vector2.new(500, 700)
        dGui.Parent = door
        
        local dText = Instance.new("TextLabel")
        dText.Name = "Text"
        dText.Size = UDim2.new(0.9, 0, 0.9, 0)
        dText.Position = UDim2.new(0.05, 0, 0.05, 0)
        dText.BackgroundTransparency = 1
        dText.TextScaled = true
        dText.TextWrapped = true
        dText.TextColor3 = Color3.fromRGB(255, 255, 255) -- Teks putih
        dText.Font = Enum.Font.GothamBold
        dText.Text = "Opsi " .. i
        dText.Parent = dGui
        
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Color = Color3.fromRGB(150, 140, 95)
        uiStroke.Thickness = 2
        uiStroke.Parent = dText
        
        table.insert(doors, door)
    end
    
    return {
        model = arenaModel,
        startPos = startPlatform.Position + Vector3.new(0, 5, 0),
        specPos = specPlatform.Position + Vector3.new(0, 5, 0),
        qText = qText,
        doors = doors,
        startPlatform = startPlatform,
        startGlow = startGlow
    }
end

-- ==========================================
-- LOGIC HELPER
-- ==========================================
local function broadcastRooms()
    local roomList = {}
    for id, room in pairs(Rooms) do
        if room.state == "Waiting" then
            table.insert(roomList, {
                id = id,
                hostName = room.host.Name,
                playerCount = #room.players,
                maxPlayers = room.maxPlayers
            })
        end
    end
    UpdateRoomsEvent:FireAllClients(roomList)
end

local function broadcastRoomState(room)
    local stateData = {
        state = room.state,
        players = {},
        turnIndex = room.turnIndex,
        winner = room.winner
    }

    if room.surahIndex and SurahData[room.surahIndex] then
        stateData.currentSurahName = SurahData[room.surahIndex].name
        stateData.currentAyat = SurahData[room.surahIndex].ayat[room.ayatIndex]
    end

    for _, p in ipairs(room.players) do
        table.insert(stateData.players, {
            name = p.Name,
            score = room.scores[p] or 0,
            lives = room.lives[p] or 0,
            isHost = (p == room.host),
            isTurn = (room.players[room.turnIndex] == p)
        })
    end

    for _, p in ipairs(room.players) do
        RoomStateChangedEvent:FireClient(p, stateData)
    end
end

local function teleportPlayer(player, pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function getNextTurn(room)
    local startIndex = room.turnIndex
    local nextIndex = startIndex
    repeat
        nextIndex = (nextIndex % #room.players) + 1
        if room.lives[room.players[nextIndex]] > 0 then
            return nextIndex
        end
    until nextIndex == startIndex
    return nil
end

local TARGET_SCORE = 100 -- Butuh 10 soal (100 poin) untuk menang

local function checkGameOver(room)
    local aliveCount = 0
    local winner = nil

    for _, p in ipairs(room.players) do
        if room.lives[p] > 0 then
            aliveCount = aliveCount + 1
        end
        if (room.scores[p] or 0) >= TARGET_SCORE then
            winner = p
        end
    end

    local isMultiplayer = #room.players > 1
    local isGameOver = false
    
    if winner then
        isGameOver = true -- Seseorang mencapai 100 poin
    elseif aliveCount == 0 then
        isGameOver = true -- Semua orang mati (termasuk main solo)
    elseif isMultiplayer and aliveCount == 1 then
        isGameOver = true -- Di multiplayer, orang terakhir yang hidup menang
    end

    if isGameOver then
        room.state = "Ended"
        
        -- Tentukan pemenang
        if not winner and aliveCount == 1 and isMultiplayer then
            for _, p in ipairs(room.players) do
                if room.lives[p] > 0 then winner = p end
            end
        end
        
        room.winner = winner and winner.Name or "Tidak ada"
        if room.winner == "Tidak ada" then
            room.arena.qText.Text = "GAME OVER! Semua pemain gugur."
        else
            room.arena.qText.Text = "SELAMAT! Pemenang: " .. room.winner
        end
        
        -- Teleport all back to MOSQUE LOBBY (Vector3.new(0, 5, -40))
        for _, p in ipairs(room.players) do
            teleportPlayer(p, Vector3.new(0, 5, -40))
        end
        
        return true
    end
    return false
end

local function updateArenaQuestion(room)
    -- Pastikan lantai tertutup kembali setelah ada yang jatuh
    room.arena.startPlatform.CanCollide = true
    room.arena.startPlatform.Transparency = 0
    room.arena.startGlow.CanCollide = true
    room.arena.startGlow.Transparency = 0
    
    -- Pastikan pintu tertutup kembali dan warnanya di-reset
    for _, door in ipairs(room.arena.doors) do
        door.CanCollide = true
        door.Transparency = 0
        door.BrickColor = BrickColor.new("Black")
    end
    
    if room.state ~= "Playing" then return end
    
    local currentSurah = SurahData[room.surahIndex]
    local currentAyat = currentSurah.ayat[room.ayatIndex]
    local correctAnswer = currentSurah.ayat[room.ayatIndex + 1]
    
    if not correctAnswer then
        -- Surah habis, ganti ke surah acak baru!
        room.surahIndex = math.random(1, #SurahData)
        room.ayatIndex = 1
        currentSurah = SurahData[room.surahIndex]
        currentAyat = currentSurah.ayat[room.ayatIndex]
        correctAnswer = currentSurah.ayat[room.ayatIndex + 1]
    end
    
    -- Setup Question Text
    local activePlayer = room.players[room.turnIndex]
    room.arena.qText.Text = "[".. activePlayer.Name .. "]\n" .. currentAyat
    
    -- Generate Wrong Options
    local options = {correctAnswer}
    local allAyats = {}
    for _, s in ipairs(SurahData) do
        for _, a in ipairs(s.ayat) do
            if a ~= correctAnswer then table.insert(allAyats, a) end
        end
    end
    
    while #options < 3 do
        local candidate = allAyats[math.random(1, #allAyats)]
        local exists = false
        for _, opt in ipairs(options) do
            if opt == candidate then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(options, candidate)
        end
    end
    
    -- Shuffle Options
    for i = #options, 2, -1 do
        local j = math.random(i)
        options[i], options[j] = options[j], options[i]
    end
    
    room.currentCorrectDoorIndex = 0
    
    -- Assign to doors and bind Touch event
    for i, door in ipairs(room.arena.doors) do
        door.SurfaceGui.Text.Text = options[i]
        
        -- Disconnect old touches
        if room.doorConnections[i] then room.doorConnections[i]:Disconnect() end
        
        local glow = door:FindFirstChild("Glow")
        if glow then glow.BrickColor = BrickColor.new("Dark stone grey") end
        
        if options[i] == correctAnswer then
            room.currentCorrectDoorIndex = i
        end
        
        room.doorConnections[i] = door.Touched:Connect(function(hit)
            local char = hit.Parent
            local player = Players:GetPlayerFromCharacter(char)
            
            if player == activePlayer and room.state == "Playing" and room.processingTurn == false then
                room.processingTurn = true
                
                if i == room.currentCorrectDoorIndex then
                    -- Correct!
                    if room.doorConnections[i] then room.doorConnections[i]:Disconnect() end
                    if not room.scores[player] then room.scores[player] = 0 end
                    room.scores[player] = room.scores[player] + 10
                    
                    door.BrickColor = BrickColor.new("Forest green")
                    door.CanCollide = false -- Nembus!
                    door.Transparency = 0.5
                    if glow then glow.BrickColor = BrickColor.new("Sea green") end
                    
                    -- Biarkan pemain berlari menembus pintu ke platform aman
                    task.wait(1.5)
                    
                    room.ayatIndex = room.ayatIndex + 1
                    
                    local isOver = checkGameOver(room)
                    if not isOver then
                        teleportPlayer(player, room.arena.specPos)
                        room.turnIndex = getNextTurn(room)
                        if room.turnIndex then
                            local nextPlayer = room.players[room.turnIndex]
                            updateArenaQuestion(room)
                            teleportPlayer(nextPlayer, room.arena.startPos)
                        end
                    end
                else
                    room.lives[player] = room.lives[player] - 1
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then hum.Health = 0 end
                    
                    if room.lives[player] <= 0 then
                        if not checkGameOver(room) then
                            room.turnIndex = getNextTurn(room)
                            -- Note: Respawn handler will teleport nextPlayer
                        end
                    end
                end
                
                broadcastRoomState(room)
                task.wait(2)
                if glow then glow.BrickColor = BrickColor.new("Dark stone grey") end
                room.processingTurn = false
            end
        end)
    end
end

-- ==========================================
-- EVENT HANDLERS
-- ==========================================
-- PROCEDURAL MOSQUE LOBBY
-- ==========================================
local function buildLobbyMosque()
    local oldLobby = Workspace:FindFirstChild("LobbyMosque")
    if oldLobby then
        oldLobby:Destroy()
    end

    local lobbyModel = Instance.new("Model")
    lobbyModel.Name = "LobbyMosque"
    lobbyModel.Parent = Workspace
    
    -- Hapus Baseplate Bawaan
    local oldBaseplate = Workspace:FindFirstChild("Baseplate")
    if oldBaseplate then oldBaseplate:Destroy() end

    -- Plaza Utama (Lobby Floor)
    local plaza = Instance.new("Part")
    plaza.Name = "Plaza"
    plaza.Size = Vector3.new(200, 2, 200)
    plaza.Position = Vector3.new(0, -1, 0)
    plaza.Anchored = true
    plaza.Material = Enum.Material.Marble
    plaza.Color = Color3.fromRGB(122, 122, 114)
    plaza.Parent = lobbyModel
    
    -- SpawnLocation
    local spawnLoc = Instance.new("SpawnLocation")
    spawnLoc.Size = Vector3.new(10, 1, 10)
    spawnLoc.Position = Vector3.new(0, 0.5, -40)
    spawnLoc.Anchored = true
    spawnLoc.Material = Enum.Material.SmoothPlastic
    spawnLoc.Color = Color3.fromRGB(96, 118, 100)
    spawnLoc.Parent = lobbyModel

    -- Bangunan Utama Masjid
    local mainBldg = Instance.new("Part")
    mainBldg.Name = "MainBuilding"
    mainBldg.Size = Vector3.new(60, 30, 40)
    mainBldg.Position = Vector3.new(0, 15, 0)
    mainBldg.Anchored = true
    mainBldg.Material = Enum.Material.SmoothPlastic
    mainBldg.Color = Color3.fromRGB(164, 164, 152)
    mainBldg.Parent = lobbyModel
    
    -- Kubah Utama (Dome)
    local dome = Instance.new("Part")
    dome.Name = "Dome"
    dome.Shape = Enum.PartType.Ball
    dome.Size = Vector3.new(35, 35, 35)
    dome.Position = Vector3.new(0, 30 + 17.5 - 5, 0) -- ditenggelamkan sedikit
    dome.Anchored = true
    dome.Material = Enum.Material.SmoothPlastic
    dome.BrickColor = BrickColor.new("Khaki")
    dome.Parent = lobbyModel
    
    -- Pintu Masuk Raksasa (Arch)
    local doorArch = Instance.new("Part")
    doorArch.Size = Vector3.new(15, 20, 2)
    doorArch.Position = Vector3.new(0, 10, -20)
    doorArch.Anchored = true
    doorArch.Material = Enum.Material.SmoothPlastic
    doorArch.BrickColor = BrickColor.new("Dark green")
    doorArch.Parent = lobbyModel
    
    local doorHole = Instance.new("Part")
    doorHole.Size = Vector3.new(13, 19, 2.2)
    doorHole.Position = Vector3.new(0, 9.5, -20)
    doorHole.Anchored = true
    doorHole.Material = Enum.Material.SmoothPlastic
    doorHole.BrickColor = BrickColor.new("Black")
    doorHole.Parent = lobbyModel

    -- Menara (Minarets)
    for _, xPos in ipairs({-35, 35}) do
        local minaret = Instance.new("Part")
        minaret.Shape = Enum.PartType.Cylinder
        minaret.Size = Vector3.new(60, 8, 8) -- X=height di Roblox Cylinder
        minaret.CFrame = CFrame.new(Vector3.new(xPos, 30, -15)) * CFrame.Angles(0, 0, math.pi/2)
        minaret.Anchored = true
        minaret.Material = Enum.Material.SmoothPlastic
        minaret.Color = Color3.fromRGB(150, 150, 140)
        minaret.Parent = lobbyModel
        
        -- Kubah Kecil Menara
        local miniDome = Instance.new("Part")
        miniDome.Shape = Enum.PartType.Ball
        miniDome.Size = Vector3.new(10, 10, 10)
        miniDome.Position = Vector3.new(xPos, 60 + 5 - 2, -15)
        miniDome.Anchored = true
        miniDome.Material = Enum.Material.SmoothPlastic
        miniDome.BrickColor = BrickColor.new("Khaki")
        miniDome.Parent = lobbyModel
    end
    
    -- Cahaya Masjid
    local lobbyLight = Instance.new("PointLight")
    lobbyLight.Range = 100
    lobbyLight.Brightness = 1
    lobbyLight.Color = Color3.fromRGB(187, 166, 126)
    lobbyLight.Parent = mainBldg
end

-- Bangun Masjid saat server pertama kali start
buildLobbyMosque()

-- ==========================================
-- EVENTS
-- ==========================================
CreateRoomEvent.OnServerInvoke = function(player)
    if PlayerRooms[player] then return false, "You are already in a room." end
    
    RoomCounter = RoomCounter + 1
    local roomId = tostring(RoomCounter)
    
    local arena = createArena(RoomCounter)
    
    local newRoom = {
        id = roomId,
        host = player,
        players = {player},
        state = "Waiting",
        maxPlayers = MAX_PLAYERS,
        surahIndex = math.random(1, #SurahData),
        ayatIndex = 1,
        turnIndex = 1,
        scores = {[player] = 0},
        lives = {[player] = MAX_LIVES},
        arena = arena,
        doorConnections = {},
        processingTurn = false
    }
    
    Rooms[roomId] = newRoom
    PlayerRooms[player] = roomId
    
    teleportPlayer(player, arena.specPos)
    broadcastRooms()
    broadcastRoomState(newRoom)
    return true, roomId
end

JoinRoomEvent.OnServerInvoke = function(player, roomId)
    if PlayerRooms[player] then return false, "Already in a room." end
    local room = Rooms[roomId]
    if not room then return false, "Room not found." end
    if room.state ~= "Waiting" then return false, "Game already started." end
    if #room.players >= room.maxPlayers then return false, "Room is full." end
    
    table.insert(room.players, player)
    room.scores[player] = 0
    room.lives[player] = MAX_LIVES
    PlayerRooms[player] = roomId
    
    teleportPlayer(player, room.arena.specPos)
    broadcastRooms()
    broadcastRoomState(room)
    return true
end

StartGameEvent.OnServerEvent:Connect(function(player)
    local roomId = PlayerRooms[player]
    if not roomId then return end
    local room = Rooms[roomId]
    if room and room.host == player and room.state == "Waiting" then
        room.state = "Playing"
        
        local firstPlayer = room.players[room.turnIndex]
        teleportPlayer(firstPlayer, room.arena.startPos)
        updateArenaQuestion(room)
        
        broadcastRoomState(room)
    end
end)

PlayAgainEvent.OnServerEvent:Connect(function(player)
    local roomId = PlayerRooms[player]
    if not roomId then return end
    local room = Rooms[roomId]
    if room and room.host == player and room.state == "Ended" then
        room.state = "Waiting"
        room.surahIndex = math.random(1, #SurahData)
        room.ayatIndex = 1
        room.turnIndex = 1
        room.arena.qText.Text = "Menunggu Game Dimulai..."
        
        for _, p in ipairs(room.players) do
            room.scores[p] = 0
            room.lives[p] = MAX_LIVES
            teleportPlayer(p, room.arena.specPos)
        end
        
        broadcastRooms()
        broadcastRoomState(room)
    end
end)

LeaveRoomEvent.OnServerEvent:Connect(function(player)
    local roomId = PlayerRooms[player]
    if not roomId then return end
    
    local room = Rooms[roomId]
    if room then
        if room.host == player then
            for _, p in ipairs(room.players) do
                PlayerRooms[p] = nil
                RoomStateChangedEvent:FireClient(p, {state = "Closed"})
            end
            room.arena.model:Destroy()
            Rooms[roomId] = nil
        else
            local newPlayers = {}
            for _, p in ipairs(room.players) do
                if p ~= player then table.insert(newPlayers, p) end
            end
            room.players = newPlayers
            PlayerRooms[player] = nil
            RoomStateChangedEvent:FireClient(player, {state = "Closed"})
            
            if room.state == "Playing" then checkGameOver(room) end
            if Rooms[roomId] then broadcastRoomState(room) end
        end
    end
    broadcastRooms()
end)

Players.PlayerRemoving:Connect(function(player)
    local roomId = PlayerRooms[player]
    if not roomId then
        return
    end

    local room = Rooms[roomId]
    if not room then
        PlayerRooms[player] = nil
        return
    end

    if room.host == player then
        for _, p in ipairs(room.players) do
            PlayerRooms[p] = nil
            RoomStateChangedEvent:FireClient(p, {state = "Closed"})
        end

        if room.arena and room.arena.model then
            room.arena.model:Destroy()
        end
        Rooms[roomId] = nil
    else
        local newPlayers = {}
        for _, p in ipairs(room.players) do
            if p ~= player then
                table.insert(newPlayers, p)
            end
        end
        room.players = newPlayers
        room.scores[player] = nil
        room.lives[player] = nil
        PlayerRooms[player] = nil

        if room.state == "Playing" then
            checkGameOver(room)
        end

        if Rooms[roomId] then
            broadcastRoomState(room)
        end
    end

    broadcastRooms()
end)

-- Handle Respawn to teleport back to correct area
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5) -- wait for physics to settle
        local roomId = PlayerRooms[player]
        if roomId then
            local room = Rooms[roomId]
            if room then
                if room.state == "Playing" then
                    if room.players[room.turnIndex] == player and room.lives[player] > 0 then
                        teleportPlayer(player, room.arena.startPos)
                        -- Also if they just died and passed turn to next player, we need to teleport the NEXT player
                        -- Wait, if they died, they respawned here. BUT turn might have passed if lives==0.
                    else
                        teleportPlayer(player, room.arena.specPos)
                        -- If player died and ran out of lives, their turn passed. We must ensure the new turn player is on start.
                        local currentActive = room.players[room.turnIndex]
                        if currentActive and room.lives[currentActive] > 0 then
                            teleportPlayer(currentActive, room.arena.startPos)
                            updateArenaQuestion(room)
                        end
                    end
                else
                    teleportPlayer(player, room.arena.specPos)
                end
            end
        end
    end)
end)
