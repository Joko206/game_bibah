local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local SurahData = require(ReplicatedStorage.Shared.SurahData)

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
    
    -- Spectator Platform
    local specPlatform = Instance.new("Part")
    specPlatform.Name = "SpectatorPlatform"
    specPlatform.Size = Vector3.new(40, 1, 20)
    specPlatform.Position = offset + Vector3.new(0, 0, -50)
    specPlatform.Anchored = true
    specPlatform.BrickColor = BrickColor.new("Dark stone grey")
    specPlatform.Parent = arenaModel
    
    -- Start Platform (Challenge)
    local startPlatform = Instance.new("Part")
    startPlatform.Name = "StartPlatform"
    startPlatform.Size = Vector3.new(40, 1, 20)
    startPlatform.Position = offset + Vector3.new(0, 0, 0)
    startPlatform.Anchored = true
    startPlatform.BrickColor = BrickColor.new("Bright blue")
    startPlatform.Parent = arenaModel
    
    -- Question Board
    local qBoard = Instance.new("Part")
    qBoard.Name = "QuestionBoard"
    qBoard.Size = Vector3.new(30, 15, 1)
    qBoard.Position = offset + Vector3.new(0, 8, 20)
    qBoard.Anchored = true
    qBoard.BrickColor = BrickColor.new("Really black")
    qBoard.Parent = arenaModel
    
    local qGui = Instance.new("SurfaceGui")
    qGui.Face = Enum.NormalId.Back
    qGui.Parent = qBoard
    local qText = Instance.new("TextLabel")
    qText.Name = "Text"
    qText.Size = UDim2.new(1, 0, 1, 0)
    qText.BackgroundTransparency = 1
    qText.TextScaled = true
    qText.TextColor3 = Color3.new(1, 1, 1)
    qText.Text = "Menunggu Game Dimulai..."
    qText.Parent = qGui
    
    -- 3 Doors (Paths)
    local doors = {}
    for i = 1, 3 do
        local door = Instance.new("Part")
        door.Name = "Door_" .. i
        door.Size = Vector3.new(8, 1, 20)
        door.Position = offset + Vector3.new((i-2)*12, 0, 15)
        door.Anchored = true
        door.BrickColor = BrickColor.new("Medium stone grey")
        door.Parent = arenaModel
        
        local dGui = Instance.new("SurfaceGui")
        dGui.Face = Enum.NormalId.Top
        dGui.Parent = door
        local dText = Instance.new("TextLabel")
        dText.Name = "Text"
        dText.Size = UDim2.new(1, 0, 1, 0)
        dText.BackgroundTransparency = 1
        dText.TextScaled = true
        dText.TextColor3 = Color3.new(0, 0, 0)
        dText.Text = "Opsi " .. i
        dText.Parent = dGui
        
        table.insert(doors, door)
    end
    
    return {
        model = arenaModel,
        specPos = specPlatform.Position + Vector3.new(0, 3, 0),
        startPos = startPlatform.Position + Vector3.new(0, 3, 0),
        qText = qText,
        doors = doors
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

local function checkGameOver(room)
    local aliveCount = 0
    local highestScore = -1
    local winner = nil

    for _, p in ipairs(room.players) do
        if room.lives[p] > 0 then
            aliveCount = aliveCount + 1
        end
    end

    local ayatCompleted = false
    if room.surahIndex and SurahData[room.surahIndex] then
        if room.ayatIndex >= #SurahData[room.surahIndex].ayat then
            ayatCompleted = true
        end
    end

    if aliveCount <= 1 or ayatCompleted then
        room.state = "Ended"
        
        for _, p in ipairs(room.players) do
            if (room.scores[p] or 0) > highestScore then
                highestScore = room.scores[p]
                winner = p
            end
        end
        room.winner = winner and winner.Name or "Tidak ada"
        room.arena.qText.Text = "GAME OVER! Pemenang: " .. room.winner
        
        -- Teleport all back to spec
        for _, p in ipairs(room.players) do
            teleportPlayer(p, room.arena.specPos)
        end
        
        return true
    end
    return false
end

local function updateArenaQuestion(room)
    if room.state ~= "Playing" then return end
    
    local currentSurah = SurahData[room.surahIndex]
    local currentAyat = currentSurah.ayat[room.ayatIndex]
    local correctAnswer = currentSurah.ayat[room.ayatIndex + 1]
    
    if not correctAnswer then
        checkGameOver(room)
        return
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
    
    table.insert(options, allAyats[math.random(1, #allAyats)])
    table.insert(options, allAyats[math.random(1, #allAyats)])
    
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
        
        if options[i] == correctAnswer then
            room.currentCorrectDoorIndex = i
            door.BrickColor = BrickColor.new("Medium stone grey")
        else
            door.BrickColor = BrickColor.new("Medium stone grey")
        end
        
        room.doorConnections[i] = door.Touched:Connect(function(hit)
            local char = hit.Parent
            local player = Players:GetPlayerFromCharacter(char)
            
            if player == activePlayer and room.state == "Playing" and room.processingTurn == false then
                room.processingTurn = true
                
                if i == room.currentCorrectDoorIndex then
                    -- Correct!
                    door.BrickColor = BrickColor.new("Lime green")
                    room.scores[player] = room.scores[player] + 10
                    room.ayatIndex = room.ayatIndex + 1
                    
                    teleportPlayer(player, room.arena.specPos)
                    
                    if not checkGameOver(room) then
                        room.turnIndex = getNextTurn(room)
                        local nextPlayer = room.players[room.turnIndex]
                        teleportPlayer(nextPlayer, room.arena.startPos)
                        updateArenaQuestion(room)
                    end
                else
                    -- Wrong! (Killbrick)
                    door.BrickColor = BrickColor.new("Really red")
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
                door.BrickColor = BrickColor.new("Medium stone grey")
                room.processingTurn = false
            end
        end)
    end
end

-- ==========================================
-- EVENT HANDLERS
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
    LeaveRoomEvent:FireServer(player)
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
