local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SurahData = require(ReplicatedStorage.Shared.SurahData)

local Events = ReplicatedStorage:WaitForChild("Events")
local CreateRoomEvent = Events:WaitForChild("CreateRoom")
local JoinRoomEvent = Events:WaitForChild("JoinRoom")
local SubmitAnswerEvent = Events:WaitForChild("SubmitAnswer")
local PlayAgainEvent = Events:WaitForChild("PlayAgain")
local LeaveRoomEvent = Events:WaitForChild("LeaveRoom")
local UpdateRoomsEvent = Events:WaitForChild("UpdateRooms")
local RoomStateChangedEvent = Events:WaitForChild("RoomStateChanged")
local FeedbackEvent = Events:WaitForChild("FeedbackEvent")

local Rooms = {}
local PlayerRooms = {}
local RoomCounter = 0

local MAX_LIVES = 3
local MAX_PLAYERS = 4

-- Function to broadcast room list to lobby players
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

-- Function to broadcast state inside a room
local function broadcastRoomState(room)
    local stateData = {
        state = room.state,
        surahIndex = room.surahIndex,
        ayatIndex = room.ayatIndex,
        players = {},
        turnIndex = room.turnIndex,
        winner = room.winner
    }

    if room.surahIndex and SurahData[room.surahIndex] then
        stateData.currentSurahName = SurahData[room.surahIndex].name
        if room.ayatIndex <= #SurahData[room.surahIndex].ayat then
            stateData.currentAyat = SurahData[room.surahIndex].ayat[room.ayatIndex]
        end
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

-- Get next alive player's turn
local function getNextTurn(room)
    local startIndex = room.turnIndex
    local nextIndex = startIndex
    repeat
        nextIndex = (nextIndex % #room.players) + 1
        if room.lives[room.players[nextIndex]] > 0 then
            return nextIndex
        end
    until nextIndex == startIndex
    return nil -- No one else alive
end

local function checkGameOver(room)
    local aliveCount = 0
    local lastAlive = nil
    local highestScore = -1
    local winner = nil

    for _, p in ipairs(room.players) do
        if room.lives[p] > 0 then
            aliveCount = aliveCount + 1
            lastAlive = p
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
        
        -- Determine winner
        for _, p in ipairs(room.players) do
            if (room.scores[p] or 0) > highestScore then
                highestScore = room.scores[p]
                winner = p
            end
        end
        room.winner = winner and winner.Name or "Tidak ada"
        return true
    end
    return false
end

CreateRoomEvent.OnServerInvoke = function(player)
    if PlayerRooms[player] then return false, "You are already in a room." end
    
    RoomCounter = RoomCounter + 1
    local roomId = tostring(RoomCounter)
    
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
        lives = {[player] = MAX_LIVES}
    }
    
    Rooms[roomId] = newRoom
    PlayerRooms[player] = roomId
    
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
    
    broadcastRooms()
    broadcastRoomState(room)
    
    -- Auto start if full (or host can start manually later, here we just start if > 1 for simplicity)
    if #room.players >= 2 then
        task.wait(2)
        room.state = "Playing"
        broadcastRoomState(room)
    end
    
    return true
end

LeaveRoomEvent.OnServerEvent:Connect(function(player)
    local roomId = PlayerRooms[player]
    if not roomId then return end
    
    local room = Rooms[roomId]
    if room then
        if room.host == player then
            -- Close room
            for _, p in ipairs(room.players) do
                PlayerRooms[p] = nil
                RoomStateChangedEvent:FireClient(p, {state = "Closed"})
            end
            Rooms[roomId] = nil
        else
            -- Remove player
            local newPlayers = {}
            for _, p in ipairs(room.players) do
                if p ~= player then table.insert(newPlayers, p) end
            end
            room.players = newPlayers
            PlayerRooms[player] = nil
            RoomStateChangedEvent:FireClient(player, {state = "Closed"})
            
            if room.state == "Playing" then
                checkGameOver(room)
            end
            if Rooms[roomId] then
                broadcastRoomState(room)
            end
        end
    end
    broadcastRooms()
end)

SubmitAnswerEvent.OnServerInvoke = function(player, answer)
    local roomId = PlayerRooms[player]
    if not roomId then return false, "Not in room" end
    
    local room = Rooms[roomId]
    if room.state ~= "Playing" then return false, "Game is not active" end
    
    local currentTurnPlayer = room.players[room.turnIndex]
    if currentTurnPlayer ~= player then return false, "Not your turn" end
    
    local currentSurah = SurahData[room.surahIndex]
    local correctAnswer = currentSurah.ayat[room.ayatIndex + 1]
    
    if not correctAnswer then
        return false, "Surah finished"
    end
    
    -- Normalize strings
    local function cleanStr(s)
        return s:lower():gsub("[%s%p]", "")
    end
    
    if cleanStr(answer) == cleanStr(correctAnswer) then
        room.scores[player] = room.scores[player] + 10
        room.ayatIndex = room.ayatIndex + 1
        
        FeedbackEvent:FireClient(player, true, "Benar! +10 Poin")
        
        if not checkGameOver(room) then
            room.turnIndex = getNextTurn(room)
        end
    else
        room.lives[player] = room.lives[player] - 1
        FeedbackEvent:FireClient(player, false, "Salah! Nyawa -1")
        
        if room.lives[player] <= 0 then
            FeedbackEvent:FireClient(player, false, "Nyawa habis!")
            if not checkGameOver(room) then
                room.turnIndex = getNextTurn(room)
            end
        end
    end
    
    broadcastRoomState(room)
    return true
end

PlayAgainEvent.OnServerEvent:Connect(function(player)
    local roomId = PlayerRooms[player]
    if not roomId then return end
    
    local room = Rooms[roomId]
    if room and room.host == player and room.state == "Ended" then
        room.state = "Waiting"
        room.surahIndex = math.random(1, #SurahData)
        room.ayatIndex = 1
        room.turnIndex = 1
        
        for _, p in ipairs(room.players) do
            room.scores[p] = 0
            room.lives[p] = MAX_LIVES
        end
        
        broadcastRooms()
        broadcastRoomState(room)
        
        -- Auto start again
        task.wait(2)
        room.state = "Playing"
        broadcastRoomState(room)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    LeaveRoomEvent:FireServer(player) -- Simulate leave
end)
